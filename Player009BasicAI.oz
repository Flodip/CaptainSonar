functor
import
   Input
   OS
   System
export 
   portPlayer:StartPlayer 
define 
   StartPlayer 
   TreatStream

   GetValueMap
   IsCorrectMove
   CanFireAt
   IsBlocked
   GiveCoordAttack
   GetValidCorner

   In
   ToNorth
   ToSouth
   ToWest
   ToEast
   DistanceBetween
   SufferExplosion

   InitListEnemies
in 
   fun{StartPlayer Color ID} 
      Stream 
      Port
   in 
      {System.show Input.map}
      {NewPort Stream Port} 
      thread {TreatStream Stream id(id:ID color:Color name:player009basicai)} end 
      Port 
   end

   fun {GetValueMap Position}
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
      if Position.x < 1 then ~1
      elseif Position.y < 1 then ~1
      elseif Position.x > Input.nRow then ~1
      elseif Position.y > Input.nColumn then ~1
      else
	 {LoopY Position.y {LoopX Position.x Input.map}}
      end
   end

   fun {IsCorrectMove Position PathHistoric}
      %{System.show '---IsCorrectMove---'}
      %{System.show 'Position '#Position}
      %{System.show 'PathHistoric '#PathHistoric}
      %{System.show 'Ground? '#{GetValueMap Position}}
      %{System.show {And {GetValueMap Position} == 0 {Not {In Position PathHistoric}}}}
      {And {GetValueMap Position} == 0 {Not {In Position PathHistoric}}}
   end

   fun {CanFireAt Position}
      {GetValueMap Position} == 0
   end

   fun {IsBlocked Position PathHistoric}
      %Blocked if (East is path visited or Ground) And same for West, North, South..
      East West North South in
      East = {ToEast Position}
      West = {ToWest Position}
      North = {ToNorth Position}
      South = {ToSouth Position}

      {And
         {And
            {And
               {Or ({GetValueMap East} == ~1) {Or ({GetValueMap East} == 1) {In East PathHistoric}}}
               {Or ({GetValueMap West} == ~1) {Or ({GetValueMap West} == 1) {In West PathHistoric}}}
            }
            {Or ({GetValueMap North} == ~1) {Or ({GetValueMap North} == 1) {In North PathHistoric}}}
         }
         {Or ({GetValueMap South} == ~1) {Or ({GetValueMap South} == 1) {In South PathHistoric}}}
      }
   end

   fun {In Position ListPosition}
      if ListPosition == nil then false
      elseif ListPosition.1 == Position then true
      else {In Position ListPosition.2} end  
   end

   fun {ToEast P}
      pt(x:P.x y:P.y+1)
   end

   fun {ToWest P}
      pt(x:P.x y:P.y-1)
   end

   fun {ToNorth P}
      pt(x:P.x-1 y:P.y)
   end

   fun {ToSouth P}
      pt(x:P.x+1 y:P.y)
   end

   fun {DistanceBetween Pos1 Pos2}
      {Number.abs (Pos1.x - Pos2.x)} + {Number.abs (Pos1.y - Pos2.y)}
   end

   %give correct coord for the mine or missile to be launched
   %PlayerPos	: Position of the player launching the attack
   %Type	: Type of the weapon used
   %Position 	: Position at which the weapon is firing
   fun {GiveCoordAttack PlayerPos Min Max}
      X Y in
      X = {OS.rand} mod (Max+1)
      if X < Min then
	 Y = ({OS.rand} mod (Max-Min+1)) + Min - X
      elseif X == Max then
         Y = 0
      else % Min <= X < Max
         Y = {OS.rand} mod (Max-X+1)
      end

      if {CanFireAt pt(x:(PlayerPos.x + X) y:(PlayerPos.y + Y))} then
         pt(x:(PlayerPos.x + X) y:(PlayerPos.y + Y))
      elseif {CanFireAt pt(x:(PlayerPos.x + ~X) y:(PlayerPos.y + Y))} then
         pt(x:(PlayerPos.x + ~X) y:(PlayerPos.y + Y))
      elseif {CanFireAt pt(x:(PlayerPos.x + X) y:(PlayerPos.y + ~Y))} then
         pt(x:(PlayerPos.x + X) y:(PlayerPos.y + ~Y))
      elseif {CanFireAt pt(x:(PlayerPos.x + ~X) y:(PlayerPos.y + ~Y))} then
         pt(x:(PlayerPos.x + ~X) y:(PlayerPos.y + ~Y))
      else
         %search for other coord
         {GiveCoordAttack PlayerPos Min Max}
      end
   end

   %returns Live left of the player
   fun {SufferExplosion PID PosMissile PosPlayer PLife ?Message}
      %Distance: Distance between the explosion center and the player
      %LifeLeft: Life left after the explosion
      Distance LifeLeft in 
      Distance = {DistanceBetween PosPlayer PosMissile}
      if Distance < 2 then
         %Damage: Damage taken due to the explosion
         local Damage in
            if Distance == 0 then Damage = 2
            else Damage = 1 end
	 
	    LifeLeft = PLife - Damage

	    if LifeLeft =< 0 then
	       Message = sayDeath(PID)
	    else
	       Message = sayDamageTaken(PID Damage LifeLeft)
	    end
          end
      else
	 Message = null
	 LifeLeft = PLife
      end
      LifeLeft	
   end

   fun {InitListEnemies PlayerID}
      fun {Loop Player ListEnemies}
         NewListEnemies in
         if Player > Input.nbPlayer then ListEnemies
         else
            % The player is not his own enemy
            if Player \= PlayerID.id then
               {AdjoinList ListEnemies [Player#enemy(life:Input.maxDamage)] NewListEnemies}
               {Loop Player+1 NewListEnemies}
            else
               {Loop Player+1 ListEnemies}
            end
         end
      end
   in
      {Loop 1 enemies()}
   end

   %Precondition: There is at least one square of water on the map
   fun {GetValidCorner}
      fun {Loop I J}
         if {GetValueMap pt(x:I y:J)} == 0 then
            pt(x:I y:J)
         else
            if J == Input.nColumn then
               {Loop I+1 1}
            else
               {Loop I J+1}
            end
         end
      end
   in
      {Loop 1 1}
   end

   %Main could have PLife, PPosition, ect too to control the Player
   %but it is still good that the player has this information for strategic purposes
   proc{TreatStream StreamInit PIDInit}
      %PModeMove: 1 -> goes to the est of the map
      %		  2 -> goes to the west of the map
      proc {Loop Stream PID PLife ListEnemies PIsSurface PModeMove PPosition PItemsCharge PItems PMines PPathHistoric}
	 case Stream
	 of nil then skip
	 [] initPosition(ID Position)|T then
	    %Init at the corner of the map and move as much as possible without making surface
	    Position = {GetValidCorner}
	    ID = PID
	    {Loop T PID PLife ListEnemies PIsSurface PModeMove Position PItemsCharge PItems PMines Position|nil}
	 [] move(ID Position Direction)|T then
	    D in
	    %If the submarine is blocked, it must go at the surface
	    if {IsBlocked PPosition PPathHistoric} then
	       Direction = surface
	       Position = PPosition
	       ID=PID
	       {Loop T PID PLife ListEnemies true PModeMove PPosition PItemsCharge PItems PMines nil}
	    else
	       %goes south est
	       if PModeMove == 1 then
	          if {IsCorrectMove {ToEast PPosition} PPathHistoric} then
	             Direction = east
	             Position = {ToEast PPosition}
	          elseif {IsCorrectMove {ToSouth PPosition} PPathHistoric} then
	             if PPosition.y > (Input.nColumn div 4)*3 then
	                % Go to mode 2
	                {Loop Stream PID PLife ListEnemies PIsSurface 2 PPosition PItemsCharge PItems PMines PPathHistoric}
	             else
	                Direction = south
	                Position = {ToSouth PPosition}
	             end
	          elseif {IsCorrectMove {ToNorth PPosition} PPathHistoric} then
	             Direction = north
	             Position = {ToNorth PPosition}
	          else
	             if PPosition.x < (Input.nRow div 4)*3 then
	                % Go to mode 2
	                {Loop Stream PID PLife ListEnemies PIsSurface 2 PPosition PItemsCharge PItems PMines PPathHistoric}
	             else
	                % Go to mode 4
	                {Loop Stream PID PLife ListEnemies PIsSurface 4 PPosition PItemsCharge PItems PMines PPathHistoric}
	             end
	          end
	       %goes south west
	       elseif PModeMove == 2 then
	          if {IsCorrectMove {ToWest PPosition} PPathHistoric} then
	             Direction = west
	             Position = {ToWest PPosition}
	          elseif {IsCorrectMove {ToSouth PPosition} PPathHistoric} then
	             if PPosition.y < (Input.nColumn div 4) then
	                % Go to mode 2
	                {Loop Stream PID PLife ListEnemies PIsSurface 1 PPosition PItemsCharge PItems PMines PPathHistoric}
	             else
	                Direction = south
	                Position = {ToSouth PPosition}
	             end
	          elseif {IsCorrectMove {ToNorth PPosition} PPathHistoric} then
	             Direction = north
	             Position = {ToNorth PPosition}
	          else
	             if PPosition.x < (Input.nRow div 4)*3 then
	                % Go to mode 1
	                {Loop Stream PID PLife ListEnemies PIsSurface 1 PPosition PItemsCharge PItems PMines PPathHistoric}
	             else
	                % Go to mode 3
	                {Loop Stream PID PLife ListEnemies PIsSurface 3 PPosition PItemsCharge PItems PMines PPathHistoric}
	             %should not be possible to loop infinitely between the modes thanks to IsBlocked
	             end
	          end
	       %goes north est
	       elseif PModeMove == 3 then
	          if {IsCorrectMove {ToEast PPosition} PPathHistoric} then
	             Direction = east
	             Position = {ToEast PPosition}
	          elseif {IsCorrectMove {ToNorth PPosition} PPathHistoric} then
	             if PPosition.y > (Input.nColumn div 4)*3 then
	                % Go to mode 4
	                {Loop Stream PID PLife ListEnemies PIsSurface 4 PPosition PItemsCharge PItems PMines PPathHistoric}
	             else
	                Direction = north
	                Position = {ToNorth PPosition}
	             end
	          elseif {IsCorrectMove {ToSouth PPosition} PPathHistoric} then
	             Direction = south
	             Position = {ToSouth PPosition}
	          else
	             if PPosition.x > (Input.nRow div 4) then
	                % Go to mode 4
	                {Loop Stream PID PLife ListEnemies PIsSurface 4 PPosition PItemsCharge PItems PMines PPathHistoric}
	             else
	                % Go to mode 2
	                {Loop Stream PID PLife ListEnemies PIsSurface 2 PPosition PItemsCharge PItems PMines PPathHistoric}
	             end
	          end
	       %goes north west
	       else
	          if {IsCorrectMove {ToWest PPosition} PPathHistoric} then
	             Direction = west
	             Position = {ToWest PPosition}
	          elseif {IsCorrectMove {ToNorth PPosition} PPathHistoric} then
	             if PPosition.y < (Input.nColumn div 4) then
	                % Go to mode 3
	                {Loop Stream PID PLife ListEnemies PIsSurface 3 PPosition PItemsCharge PItems PMines PPathHistoric}
	             else
	                Direction = north
	                Position = {ToNorth PPosition}
	             end
	          elseif {IsCorrectMove {ToSouth PPosition} PPathHistoric} then
	             Direction = south
	             Position = {ToSouth PPosition}
	          else
	             if PPosition.x > (Input.nRow div 4) then
	                % Go to mode 3
	                {Loop Stream PID PLife ListEnemies PIsSurface 3 PPosition PItemsCharge PItems PMines PPathHistoric}
	             else
	                % Go to mode 1
	                {Loop Stream PID PLife ListEnemies PIsSurface 1 PPosition PItemsCharge PItems PMines PPathHistoric}
	             end
	          end
	       end
	       ID = PID
	       {Loop T PID PLife ListEnemies PIsSurface PModeMove Position PItemsCharge 
	          	PItems PMines {Append PPathHistoric Position|nil}}
	    end
	 [] dive|T then
	    {Loop T PID PLife ListEnemies false PModeMove PPosition PItemsCharge PItems PMines PPosition|nil}
	 [] chargeItem(ID KindItem)|T then 
	    ItemsC Items TmpC Tmp in
	    case ({OS.rand} mod 4) of 0 then 
	       if PItemsCharge.missile+1 == Input.missile then
	          KindItem = missile
	          TmpC = 0
	          Tmp = PItems.missile+1
	       else
	          TmpC = PItemsCharge.missile+1
	          Tmp = PItems.missile
	          KindItem = null
	       end
	       ItemsC = itc(missile:TmpC mine:PItemsCharge.mine sonar:PItemsCharge.sonar drone:PItemsCharge.drone)
	       Items = it(missile:Tmp mine:PItems.mine sonar:PItems.sonar drone:PItems.drone)
	    [] 1 then
	       if PItemsCharge.mine+1 == Input.mine then
	          KindItem = mine
	          TmpC = 0
	          Tmp = PItems.mine+1
	       else
	          TmpC = PItemsCharge.mine+1
	          Tmp = PItems.mine
	          KindItem = null
	       end
	       ItemsC = itc(missile:PItemsCharge.missile mine:TmpC sonar:PItemsCharge.sonar drone:PItemsCharge.drone)
	       Items = it(missile:PItems.missile mine:Tmp sonar:PItems.sonar drone:PItems.drone)
	    [] 2 then
	       if PItemsCharge.sonar+1 == Input.sonar then
	          KindItem = sonar
	          TmpC = 0
	          Tmp = PItems.sonar+1
	       else
	          TmpC = PItemsCharge.sonar+1
	          Tmp = PItems.sonar
	          KindItem = null
	       end
	       ItemsC = itc(missile:PItemsCharge.missile mine:PItemsCharge.mine sonar:TmpC drone:PItemsCharge.drone)
	       Items = it(missile:PItems.missile mine:PItems.mine sonar:Tmp drone:PItems.drone)
	    else
	       if PItemsCharge.drone+1 == Input.drone then
	          KindItem = drone
	          TmpC = 0
	          Tmp = PItems.drone+1
	       else
	          TmpC = PItemsCharge.drone+1
	          Tmp = PItems.drone
	          KindItem = null
	       end
	       ItemsC = itc(missile:PItemsCharge.missile mine:PItemsCharge.mine sonar:PItemsCharge.sonar drone:TmpC)
	       Items = it(missile:PItems.missile mine:PItems.mine sonar:PItems.sonar drone:Tmp)
	    end
	    ID = PID
	    {Loop T PID PLife ListEnemies PIsSurface PModeMove PPosition ItemsC Items PMines PPathHistoric}
	 [] fireItem(ID KindFire)|T then
	    X Y Position CoordAtk in
	    case PItems of
	    it(missile:1 mine:0 sonar:0 drone:0) then
	    ID = PID
	    KindFire = missile({GiveCoordAttack PPosition Input.minDistanceMissile Input.maxDistanceMissile})

	    {Loop T PID PLife ListEnemies PIsSurface PModeMove PPosition PItemsCharge 
	    	it(missile:0 mine:0 sonar:0 drone:0) PMines PPathHistoric}
	    [] it(missile:0 mine:1 sonar:0 drone:0) then
	       ID = PID
	       KindFire = mine({GiveCoordAttack PPosition Input.minDistanceMine Input.maxDistanceMine})
	       {Loop T PID PLife ListEnemies PIsSurface PModeMove PPosition PItemsCharge 
	       	   it(missile:0 mine:0 sonar:0 drone:0) {Append PMines Position|nil} PPathHistoric}
	    [] it(missile:0 mine:0 sonar:1 drone:0) then
	       ID = PID
	       KindFire = sonar
	       {Loop T PID PLife ListEnemies PIsSurface PModeMove PPosition PItemsCharge 
	 	it(missile:0 mine:0 sonar:0 drone:0) PMines PPathHistoric}
	    %not yet managed
	    [] it(missile:0 mine:0 sonar:0 drone:1) then
	       ID = PID
	       KindFire = null
	       {Loop T PID PLife ListEnemies PIsSurface PModeMove PPosition PItemsCharge 
	 	it(missile:0 mine:0 sonar:0 drone:0) PMines PPathHistoric}
	    else
	       ID = PID
	       KindFire = null
	       {Loop T PID PLife ListEnemies PIsSurface PModeMove PPosition PItemsCharge 
	 	PItems PMines PPathHistoric}
	    end
	 [] fireMine(ID Mine)|T then 
	 	WillFireMine NewPMines in
	 	WillFireMine = {OS.rand} mod 1
	 	ID = PID

	 	if({And WillFireMine == 1 PMines \= nil}) then
	 	   Mine = PMines.1
	 	   NewPMines = PMines.2
	 	else
	 	   Mine = nil
	 	   NewPMines = PMines
	 	end

	    {Loop T PID PLife ListEnemies PIsSurface PModeMove PPosition PItemsCharge PItems NewPMines PPathHistoric}
	 [] isSurface(ID Answer)|T then
	    ID = PID
	    Answer = PIsSurface
	    {Loop T PID PLife ListEnemies PIsSurface PModeMove PPosition PItemsCharge PItems PMines PPathHistoric}
	 [] sayMove(ID Direction)|T then 
	    {Loop T PID PLife ListEnemies PIsSurface PModeMove PPosition PItemsCharge PItems PMines PPathHistoric}
	 [] saySurface(ID)|T then {Loop T PID PLife ListEnemies PIsSurface PModeMove PPosition PItemsCharge PItems PMines PPathHistoric}
	 [] sayCharge(ID KindItem)|T then {Loop T PID PLife ListEnemies PIsSurface PModeMove PPosition PItemsCharge PItems PMines PPathHistoric}
  	 [] sayMinePlaced(ID)|T then {Loop T PID PLife ListEnemies PIsSurface PModeMove PPosition PItemsCharge PItems PMines PPathHistoric}
	 [] sayMissileExplode(ID Position Message)|T then

	    %TODO: save that the player ID has used one of his missile

	    LifeLeft in
	    LifeLeft = {SufferExplosion PID Position PPosition PLife ?Message}

	    {Loop T PID LifeLeft ListEnemies PIsSurface PModeMove PPosition PItemsCharge PItems PMines PPathHistoric}
	 [] sayMineExplode(ID Position Message)|T then {Loop T PID PLife ListEnemies PIsSurface PModeMove PPosition PItemsCharge PItems PMines PPathHistoric}
	    
	    %TODO: save that the player ID has used one of his placed mine

	    LifeLeft in
	    LifeLeft = {SufferExplosion PID Position PPosition PLife ?Message}

	    {Loop T PID LifeLeft ListEnemies PIsSurface PModeMove PPosition PItemsCharge PItems PMines PPathHistoric}
	 % Drones not yet managed
	 [] sayPassingDrone(Drone ID Answer)|T then {Loop T PID PLife ListEnemies PIsSurface PModeMove PPosition PItemsCharge PItems PMines PPathHistoric}
	 % Drones not yet managed
	 [] sayAnswerDrone(Drone ID Answer)|T then {Loop T PID PLife ListEnemies PIsSurface PModeMove PPosition PItemsCharge PItems PMines PPathHistoric}
	 % Sonars not yet managed
	 [] sayPassingSonar(ID Answer)|T then {Loop T PID PLife ListEnemies PIsSurface PModeMove PPosition PItemsCharge PItems PMines PPathHistoric}
	 % Sonars not yet managed
	 [] sayAnswerSonar(ID Answer)|T then {Loop T PID PLife ListEnemies PIsSurface PModeMove PPosition PItemsCharge PItems PMines PPathHistoric}
	 [] sayDeath(ID)|T then
	    NewListEnemies in
	    {AdjoinList ListEnemies [ID.id#null] NewListEnemies}
	    {Loop T PID PLife NewListEnemies PIsSurface PModeMove PPosition PItemsCharge PItems PMines PPathHistoric}
	 [] sayDamageTaken(ID Damage LifeLeft)|T then
	    %can use Damage information to estimate Player position

	    NewListEnemies Enemy in
	    Enemy = ListEnemies.(ID.id)
	    if Enemy == null then
	       NewListEnemies = ListEnemies
	    else
	       {AdjoinList ListEnemies [ID.id#enemy(life:LifeLeft)] NewListEnemies}
	    end
	    {Loop T PID PLife ListEnemies PIsSurface PModeMove PPosition PItemsCharge PItems PMines PPathHistoric}
	 [] H|T then
	    {System.show 'Invalid Msg'}
	    {Loop T PID PLife ListEnemies PIsSurface PModeMove PPosition PItemsCharge PItems PMines PPathHistoric}	
	 end
      end
   in
      local Enemies in
         Enemies = {InitListEnemies PIDInit}
         {Loop StreamInit PIDInit Input.maxDamage Enemies true 1 unit itc(missile:0 mine:0 sonar:0 drone:0) it(missile:0 mine:0 sonar:0 drone:0) nil nil}
      end
   end
end