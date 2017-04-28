functor
import
   GUI
   Input
   PlayerManager
   System
   OS
define
   IsCorrectMove
   SimulateThinking

   Judge
   ListPlayers
   ListTimeSurfacePlayers
   IsWinner

   InitPlayers
   InitPosPlayers
   PlaySimultaneous
   MainGame
   GenerateMapLoop
   %GetTimeSurface
   %SetTimeSurface

   PlaySound
   DoExplosionAnimation


   Broadcast
   BroadcastMove
   BroadcastSurface
   BroadcastCharge
   BroadcastMinePlaced
   BroadcastMissileExplode
   BroadcastMineExplode
   BroadcastPassingDrone
   BroadcastAnswerDrone
   BroadcastPassingSonar
   BroadcastAnswerSonar
   BroadcastDamageTaken
   BroadcastDeath
in

%%%%%%%%%% Util  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fun {IsCorrectMove Position}
      fun {LoopX X M}
	 if X == 1 then
	    M.1
	 else
	    {LoopX X-1 M.2}
	 end
      end
      fun {LoopY Y M}
	 if Y < 1 then 1 elseif Y == 1 then M.1 else {LoopY Y-1 M.2} end
      end
    in
       if Position.x < 1 then
	  false
       elseif Position.y < 1 then
	  false
       elseif Position.x > Input.nRow then
	  false
       elseif Position.y > Input.nColumn then
	  false
       else
	  {LoopY Position.y {LoopX Position.x Input.map}} == 0
       end
    end

    proc {SimulateThinking}
      Delta
    in
      Delta = Input.thinkMax - Input.thinkMin + 1
      {Delay (({OS.rand} mod Delta) + Input.thinkMin)}
    end

    proc {PlaySound Msg}
       Command Args Stdin Stdout Pid in
       Command = aplay

       case Msg of explosion then
          Args = './explosion.wav'|nil
       else
          Args = './explosion.wav'|nil
       end

       {OS.pipe Command Args Pid Stdin#Stdout}
    end

    proc {DoExplosionAnimation ID Position}
       thread
          {Send Judge explosion(ID t(num:1 pos:Position))}
          {Delay 200}
          {Send Judge removeMine(ID Position)}
          {Send Judge explosion(ID t(num:2 pos:Position))}
          {Delay 200}
          {Send Judge removeMine(ID Position)}
          {Send Judge explosion(ID t(num:3 pos:Position))}
          {Delay 200}
          {Send Judge removeMine(ID Position)}
          {Send Judge explosion(ID t(num:4 pos:Position))}
          {Delay 200}
          {Send Judge removeMine(ID Position)}
       end
    end

    fun {IsWinner Players}
       fun {Loop P I}
          if P == nil then 
             I == 1
          else
             if P.1 \= null then
                {Loop P.2 I+1}
             else
                {Loop P.2 I}
             end
          end
       end
    in
       {Loop Players 0}
    end

%%%%%%%%%% End utilities %%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%% MAIN METHODS %%%%%%%%%%%%%%%%%%%%%%%%%%%

    fun {InitPlayers}
      %loops through each Players and Colors from Input and associates them
       fun {IPR N Players Colors TimeSurfacePlayers}
	  TimeSurface in
	  case Players#Colors of (Kind|T1)#(Color|T2) then
            %The time surface left before diving is 0 at the first turn
	     TimeSurfacePlayers = 1|TimeSurface
	     {PlayerManager.playerGenerator Kind Color N}|{IPR N+1 T1 T2 TimeSurface}
	  else
	     TimeSurfacePlayers = nil
	     nil
	  end
       end
    in
       {IPR 1 Input.players Input.colors ListTimeSurfacePlayers}
    end

    proc {InitPosPlayers}
      %loops through each Players and asks them their initial Pos
       proc {IPPR Players}
	  Pos ID in
	  case Players of nil then skip
	  [] P|T then
	     {Send P initPosition(ID Pos)}
            %The position is incorrect, asked a new one
	     if {Not {IsCorrectMove Pos}} then
		{IPPR Players}
            %The position is sent to the GUI and asks the next player
	     else
		{Send Judge initPlayer(ID Pos)}
		{IPPR T}
	     end
	  else skip
	  end
       end
    in
       {IPPR ListPlayers}
    end

    proc {PlaySimultaneous Players TimeSurfacePlayers}
       case Players
       of H|T then
	  thread {MainGame H|nil TimeSurfacePlayers} end
	  {PlaySimultaneous T TimeSurfacePlayers}
       else skip
       end
    end

    proc {MainGame Players TimeSurfacePlayers}
       if Input.isTurnByTurn == false then
          {SimulateThinking}
       end
       case Players#TimeSurfacePlayers of (P|T)#(TimeSurface|TimeT) then
          Time in
          %Player dead
	  if P == null then
	     Time = null
	     skip
          %Player still alive
	  else
             if {IsWinner Players} then
                local X ID Ans in
                   %send isSurface to have ID
                   {Send P isSurface(ID Ans)}
                   {System.show 'WINNER:'#ID.name}
                   %Block process, the game has ended
                   {Wait X}
                end
             else
	     ID Surface in
	     {Send P isSurface(ID Surface)}
	     {System.show '-------Player'#ID.id#'------'}
             %If Player at surface, he has to wait x turns before diving
	     if Surface then
		if TimeSurface == 1 then
		   {Send P dive}
		else Time = TimeSurface-1 end
	     else
		ID Position Direction IDTmp in
		{Send P move(ID Position Direction)}
		{Wait ID}
		IDTmp = ID
                %Ask Player if he wants to move or dive
		if Direction == surface then
		   {Send Judge surface(IDTmp)}
		   {BroadcastSurface T IDTmp}
		   Time = Input.turnSurface-1
		else
		   Time = TimeSurface
		   if {Not {IsCorrectMove Position}} then
                      {System.show 'incorrect move'}
		      {MainGame Players TimeSurfacePlayers}
		   else
		      {Send Judge movePlayer(IDTmp Position)}
		      {BroadcastMove T IDTmp Position}

                      %Can charge an item
		      local ID KindItem in
	                 {Send P chargeItem(ID KindItem)}
		         {Wait KindItem}
		         if KindItem == null then
                            {System.show 'charge item - item+1'}
		            skip
		         else
                            {System.show 'charge item'}
			    {BroadcastCharge T ID KindItem}
		         end
		       end

                      %Can fire an item
                      %We dont check if the player has enough charges
                      UpdatedPlayers1 UpdatedPlayers2 in
		      local ID KindItem Position Drone Msg in
			 {Send P fireItem(ID KindItem)}
			 {Wait KindItem}
			 case KindItem of null then
                            UpdatedPlayers1 = Players
			 [] mine(Position) then
                            {System.show 'put mine'}
			    {BroadcastMinePlaced T ID}
			    {Send Judge putMine(ID Position)}
                            UpdatedPlayers1 = Players
			 [] missile(Position) then
                            {System.show 'launch missile'}
                            UpdatedPlayers1 = {BroadcastMissileExplode Players ID Position}
			    try {PlaySound explosion}
			    catch X then
                                {System.show 'Error on sound'#X}
                            end
                            {DoExplosionAnimation ID Position}
			 [] sonar then %TODO
                            {System.show 'launch sonar'}
                            UpdatedPlayers1 = Players
			 [] drone then %TODO
                            {System.show 'send drone'}
                            UpdatedPlayers1 = Players
			 else
                            {System.show 'fire nothing'}
                            UpdatedPlayers1 = Players
			 end
		      end
                      %if player is dead, stop
                      if UpdatedPlayers1.1 \= null then 
		         local ID Mine Msg in
                            {Send P fireMine(ID Mine)}
                            {Wait ID}
                            if ID == null then
                               % PLAYER DEAD
                               {System.show 'dead'}
                               {MainGame {Append UpdatedPlayers1.2 null|nil} {Append TimeT Time|nil}}
                            else
			       if Mine == null then
                                  {System.show 'cannot fire mine'}
			          UpdatedPlayers2 = UpdatedPlayers1
			       else
                                  {System.show 'fire mine'}
                                  UpdatedPlayers2 = {BroadcastMineExplode UpdatedPlayers1 P Mine}
			       end
                               {MainGame {Append UpdatedPlayers2.2 UpdatedPlayers2.1|nil} {Append TimeT Time|nil}}
                             end
                          end
                       else
                          % PLAYER DEAD
                          {MainGame {Append UpdatedPlayers1.2 null|nil} {Append TimeT Time|nil}}
                       end
		   end
		end
                end
	     end
	  end
         %Player put at the end of the list, and we begin the next player's turn
	  %{Delay 300}
	  {MainGame {Append T P|nil} {Append TimeT Time|nil}}
       end
    end

%%%%%%%%%% END MAIN METHODS %%%%%%%%%%%%%%%%%%


%%%%%%%%%% MISC METHODS %%%%%%%%%%%%%%%%%%%%%%

    /*fun {GetTimeSurface ID}
       fun {GTSr IDr TimeSurfacePlayers}
	  case TimeSurfacePlayers of nil then nil
	  [] H|T then
	     if IDr == 1 then H
	     else {GTSr IDr-1 T} end
	  end
       end
    in
       {GTSr ID.id ListTimeSurfacePlayers}
    end

    proc {SetTimeSurface ID TimeSurface}
       Tmp = nil
       proc {STSr IDr TimeSurfacePlayers}
	  case TimeSurfacePlayers of nil then skip
	  [] H|T then
	     if IDr == 1 then ListTimeSurfacePlayers = {Append Tmp Input.turSurface|T}
	     else {STSr IDr-1 T} end
	  end
       end
    in
       {STSr ID.id ListTimeSurfacePlayers}
    end*/

%%%%%%%%%% END MISC METHODS %%%%%%%%%%%%%%%%%%


%%%%%%%%%% BROADCAST METHODS %%%%%%%%%%%%%%%%%

   % Broadcast message Msg to players in Players
    proc {Broadcast Msg Players}
       proc {Br L}
	  case L of nil then skip
	  [] H|T then
             if H == null then skip
             else
	        {Send H Msg}
             end
	     {Br T}
	  end
       end
    in
       {Br Players}
    end

    proc {BroadcastMove Players ID Position}
       {Broadcast sayMove(ID Position) Players}
    end

    proc {BroadcastSurface Players ID}
       {Broadcast saySurface(ID) Players}
   end

    proc {BroadcastCharge Players ID KindItem}
       {Broadcast sayCharge(ID KindItem) Players}
    end

    proc {BroadcastMinePlaced Players ID}
       {Broadcast sayMinePlaced(ID) Players}
   end

    fun {BroadcastMissileExplode Players ID Position}
       fun {Loop P}
          Message in
          case P of nil then nil
          [] H|T then 
             if H == null then null|{Loop T}
             else 
                {Send H sayMissileExplode(ID Position Message)}
                case Message of null then 
                   H|{Loop T}
                [] sayDeath(PID) then
                   {Send Judge lifeUpdate(PID 0)}
                   {Send Judge removePlayer(PID)}
                   {BroadcastDeath Players PID}
                   null|{Loop T}
                [] sayDamageTaken(PID Damage LifeLeft) then
                   {Send Judge lifeUpdate(PID LifeLeft)}
                   {BroadcastDamageTaken Players PID Damage LifeLeft}
                   H|{Loop T}
                end
             end
          end
       end
    in
       {Loop Players}
    end

    fun {BroadcastMineExplode Players ID Position}
       fun {Loop P}
          Message in
          case P of nil then nil
          [] H|T then 
             if H == null then null|{Loop T}
             else 
                {Send H sayMineExplode(ID Position Message)}
                case Message of null then 
                   H|{Loop T}
                [] sayDeath(PID) then
                   {Send Judge lifeUpdate(PID 0)}
                   {Send Judge removePlayer(PID)}
                   {BroadcastDeath Players PID}
                   null|{Loop T}
                [] sayDamageTaken(PID Damage LifeLeft) then
                    {System.show PID}
                   {Send Judge lifeUpdate(PID LifeLeft)}
                   {BroadcastDamageTaken Players PID Damage LifeLeft}
                   H|{Loop T}
                end
             end
          end
       end
    in
       {Loop Players}
    end

    proc {BroadcastPassingDrone Players Drone ID Answer}
      {Broadcast sayPassingDrone(Drone ID Answer) Players}
    end

    proc {BroadcastAnswerDrone Players Drone ID Answer}
       {Broadcast sayAnswerDrone(Drone ID Answer) Players}
    end

    proc {BroadcastPassingSonar Players ID Answer}
       {Broadcast sayPassingSonar(ID Answer) Players}
    end

    proc {BroadcastAnswerSonar Players ID Answer}
       {Broadcast sayAnswerSonar(ID Answer) Players}
    end

    proc {BroadcastDeath Players ID}
       {Broadcast sayDeath(ID) Players}
    end

   proc {BroadcastDamageTaken Players ID Damage LifeLeft}
      {Broadcast sayDamageTaken(ID Damage LifeLeft) Players}
   end

   proc {GenerateMapLoop}
      if {Input.generateMapProc} == false then {GenerateMapLoop} else skip end
   end
   
%%%%%%%%%% END BROADCAST METHOD %%%%%%%%%%%%%%


   %Port GUI init and display Window
   if Input.generateMap == true then
      {GenerateMapLoop}
   else
      {Input.defaultMapProc}
   end
   Judge = {GUI.portWindow}
   {Send Judge buildWindow}
   {Delay 1800}
   {System.show 'Window initialized'}

   %Ports Players init
   {System.show 'Starting player initialization'}
   ListPlayers = {InitPlayers}
   {System.show 'Players Port initialized'}
   %Player initial position
   {InitPosPlayers}
   {System.show 'Players Pos initialized'}

   %Lets the game begin
   if(Input.isTurnByTurn) then
      {MainGame ListPlayers ListTimeSurfacePlayers}
   else
      {PlaySimultaneous ListPlayers ListTimeSurfacePlayers}
   end
end
