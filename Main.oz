functor
import
   GUI
   Input
   PlayerManager
   System
define
   % Util Methods
   IsGround
   
   Judge
   ListPlayers
   ListTimeSurfacePlayers

   InitPlayers
   InitPosPlayers
   PlayByTurn
   
   GetTimeSurface
   SetTimeSurface


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
   fun {IsGround X Y}
      fun {LoopX X M}
	 if X == 1 then
	    M.1
	 else
	    {LoopX X-1 M.2}
	 end
      end
      fun {LoopY Y M}
	 if Y == 1 then M.1 else {LoopY Y-1 M.2} end
      end
      Rep
   in
      Rep = {LoopY Y {LoopX X Input.map}}
      Rep == 1
   end
   
   %%%%%%%%%% End utilities %%%%%%%%%%%%%%%%%%%%%

   %%%%%%%%%% MAIN METHODS %%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   fun {InitPlayers}
      %loops through each Players and Colors from Input and associates them
      fun {IPR N Players Colors TimeSurfacePlayers}
         TimeSurface in
         case Players#Colors of (Kind|T1)#(Color|T2) then
            %The time surface left before diving is 0 at the first turn
	    TimeSurfacePlayers = 0|TimeSurface
            {PlayerManager.playerGenerator Kind Color N}|{IPR N+1 T1 T2 TimeSurface}
         else 
            TimeSurface = nil
            nil
         end
      end
   in
      {IPR 1 Input.players Input.colors ListTimeSurfacePlayers}
   end

   proc {InitPosPlayers}
      %TODO Check + impl isNotGround methds
      %loops through each Players and asks them their initial Pos
      proc {IPPR Players}
         Pos ID in
         case Players of nil then skip
         [] P|T then 
            {Send P initPosition(ID Pos)}
            {Send Judge initPlayer(ID Pos)}
            {IPPR T}
         else skip
         end
      end
   in
      {IPPR ListPlayers}
   end

   proc {PlayByTurn Players}
      case Players of P|T then
         {System.show '---Player "#P#" turn---'}
         ID Surface in
         {Send P isSurface(ID Surface)}
         %If Player at surface, he has to wait x turns before diving
         if Surface then
            TimeSurface in
            TimeSurface = {GetTimeSurface ID}
            if TimeSurface == 0 then
               {Send P dive}
            else {SetTimeSurface ID TimeSurface-1} end
         else
            ID Position Direction in
            {Send P move(ID Position Direction)}
            %Ask Player if he wants to move or dive
            if Direction == surface then 
               {Send Judge surface(ID)}
               {BroadcastSurface T ID}
               {SetTimeSurface ID Input.turnSurface}
            else
               {Send Judge movePlayer(ID Position)}
               {BroadcastMove T ID Position}
            end
         end
         %Player put at the end of the list, and we begin the next player's turn
         {PlayByTurn {Append T P|nil}}
      end
   end

   %%%%%%%%%% END MAIN METHODS %%%%%%%%%%%%%%%%%%


   %%%%%%%%%% MISC METHODS %%%%%%%%%%%%%%%%%%%%%%

   fun {GetTimeSurface ID}
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
   end

   %%%%%%%%%% END MISC METHODS %%%%%%%%%%%%%%%%%%

  
   %%%%%%%%%% BROADCAST METHODS %%%%%%%%%%%%%%%%%

   % Broadcast message Msg to players in Players
   proc {Broadcast Msg Players}
      proc {Br L}
         case L of nil then skip
         [] H|T then
            {Send H Msg}
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

   proc {BroadcastMissileExplode Players ID Position Message}
      {Broadcast sayMissileExplode(ID Position Message) Players}
   end

   proc {BroadcastMineExplode Players ID Position Message}
      {Broadcast sayMineExplode(ID Position Message) Players}
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

   proc {BroadcastDamageTaken Players ID LifeLeft}
      {Broadcast sayDamageTaken(ID LifeLeft) Players}
   end

%%%%%%%%%% END BROADCAST METHOD %%%%%%%%%%%%%%


   %Port GUI init and display Window
   Judge = {GUI.portWindow}
   {Send Judge buildWindow}
   {System.show 'Window initialized'}
   
   %Ports Players init
   {System.show 'Starting player initialization'}
   ListPlayers = {InitPlayers}
   {System.show 'Players Port initialized'}
   %Player initial position
   {System.show 'Starting player pos initialization'}
   {InitPosPlayers}
   {System.show 'Players Pos initialized'}

   %Lets the game begin
   if(Input.isTurnByTurn) then
      {PlayByTurn ListPlayers}
   else
      skip
   end
end