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

   In
   ToNorth
   ToSouth
   ToWest
   ToEast
in 
   fun{StartPlayer Color ID} 
      Stream 
      Port
   in 
      {NewPort Stream Port} 
      thread {TreatStream Stream id(id:ID color:Color name:player000flo1)} end 
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
      {System.show '---IsCorrectMove---'}
      {System.show 'Position '#Position}
      {System.show 'PathHistoric '#PathHistoric}
      {System.show 'Ground? '#{GetValueMap Position}}
      {System.show {And {GetValueMap Position} == 0 {Not {In Position PathHistoric}}}}
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

      if {CanFireAt pt(x:X y:Y)} then
         pt(x:X y:Y)
      elseif {CanFireAt pt(x:~X y:Y)} then
         pt(x:~X y:Y)
      elseif {CanFireAt pt(x:X y:~Y)} then
         pt(x:X y:~Y)
      elseif {CanFireAt pt(x:~X y:~Y)} then
         pt(x:~X y:~Y)
      else
         %search for other coord
         {GiveCoordAttack PlayerPos Min Max}
      end
   end

   %Main could have PLife, PPosition, ect too to control the Player
   %but it is still good that the player has this information for strategic purposes
   proc{TreatStream StreamInit PIDInit}
      proc {Loop Stream PID PLife PIsSurface PPosition PItemsCharge PItems PMines PPathHistoric}
	 case Stream
	 of nil then skip
	 [] initPosition(ID Position)|T then
	    X Y in
	    X = ({OS.rand} mod Input.nColumn)+1
	    Y = ({OS.rand} mod Input.nRow)+1
	    
	    Position = pt(x:X y:Y)
	    ID = PID
	    {Loop T PID PLife PIsSurface Position PItemsCharge PItems PMines Position|nil}
	 [] move(ID Position Direction)|T then
	    D in
	    %If the submarine is blocked, it must go at the surface
	    if {IsBlocked PPosition PPathHistoric} then
	       D = 0
	    else
	       D = ({OS.rand} mod 4) +1
	    end
	    %surface
	    if D == 0 then
	       Direction = surface
	       Position = PPosition
	       ID=PID
	       {Loop T PID PLife true PPosition PItemsCharge PItems PMines nil}
	    %move north, south, east or west
	    else
	       X Y Pos Dir in
	       X = PPosition.x
	       Y = PPosition.y
	       
	       case D of 1 then
		  Dir = east
		  Pos = {ToEast PPosition}
	       [] 2 then 
		  Dir = west
		  Pos = {ToWest PPosition}
	       [] 3 then 
		  Dir = north
		  Pos = {ToNorth PPosition}
	       [] 4 then 
		  Dir = south
		  Pos = {ToSouth PPosition}
	       else skip
	       end
	       %Move OK
	       if {IsCorrectMove Pos PPathHistoric} then
	          Direction = Dir
		  Position = Pos
		  ID=PID
	          {Loop T PID PLife PIsSurface Position PItemsCharge 
	          	PItems PMines {Append PPathHistoric Position|nil}}
	       %Move KO, asks again
	       else
	          {Loop Stream PID PLife PIsSurface PPosition PItemsCharge PItems PMines PPathHistoric}
	       end
	    end
	 [] dive|T then
	    {Loop T PID PLife false PPosition PItemsCharge PItems PMines PPosition|nil}
	 [] chargeItem(ID KindItem)|T then 
	    ID = PID
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

	    {Loop T PID PLife PIsSurface PPosition ItemsC Items PMines PPathHistoric}
	 [] fireItem(ID KindFire)|T then
	    X Y Position CoordAtk in
	    case PItems of
	       it(missile:1 mine:0 sonar:0 drone:0) then
	       ID = PID
	       CoordAtk = {GiveCoordAttack PPosition Input.minDistanceMissile Input.maxDistanceMissile}
	       {Wait CoordAtk}
	       KindFire = missile(CoordAtk)
	       
	       {Loop T PID PLife PIsSurface PPosition PItemsCharge 
		it(missile:0 mine:0 sonar:0 drone:0) PMines PPathHistoric}
	    [] it(missile:0 mine:1 sonar:0 drone:0) then
	       ID = PID
	       CoordAtk = {GiveCoordAttack PPosition Input.minDistanceMissile Input.maxDistanceMissile}
	       {Wait CoordAtk}
	       KindFire =  mine(CoordAtk)
	       {Loop T PID PLife PIsSurface PPosition PItemsCharge 
		it(missile:0 mine:0 sonar:0 drone:0) {Append PMines Position|nil} PPathHistoric}
	    [] it(missile:0 mine:0 sonar:1 drone:0) then
	       ID = PID
	       KindFire = sonar
	       {Loop T PID PLife PIsSurface PPosition PItemsCharge 
		it(missile:0 mine:0 sonar:0 drone:0) PMines PPathHistoric}
	    %not yet managed
	    [] it(missile:0 mine:0 sonar:0 drone:1) then
	       ID = PID
	       KindFire = null
	       {Loop T PID PLife PIsSurface PPosition PItemsCharge 
	 	it(missile:0 mine:0 sonar:0 drone:0) PMines PPathHistoric}
	    else
	       ID = PID
	       KindFire = null
	       {Loop T PID PLife PIsSurface PPosition PItemsCharge 
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

	    {Loop T PID PLife PIsSurface PPosition PItemsCharge PItems NewPMines PPathHistoric}
	 [] isSurface(ID Answer)|T then
	    ID = PID
	    Answer = PIsSurface
	    {Loop T PID PLife PIsSurface PPosition PItemsCharge PItems PMines PPathHistoric}
	 [] sayMove(ID Direction)|T then 
	    {Loop T PID PLife PIsSurface PPosition PItemsCharge PItems PMines PPathHistoric}
	 [] saySurface(ID)|T then {Loop T PID PLife PIsSurface PPosition PItemsCharge PItems PMines PPathHistoric}
	 [] sayCharge(ID KindItem)|T then {Loop T PID PLife PIsSurface PPosition PItemsCharge PItems PMines PPathHistoric}
  	 [] sayMinePlaced(ID)|T then {Loop T PID PLife PIsSurface PPosition PItemsCharge PItems PMines PPathHistoric}
	 [] sayMissileExplode(ID Position Message)|T then {Loop T PID PLife PIsSurface PPosition PItemsCharge PItems PMines PPathHistoric}
	 [] sayMineExplode(ID Position Message)|T then {Loop T PID PLife PIsSurface PPosition PItemsCharge PItems PMines PPathHistoric}
	 [] sayPassingDrone(Drone ID Answer)|T then {Loop T PID PLife PIsSurface PPosition PItemsCharge PItems PMines PPathHistoric}
	 [] sayAnswerDrone(Drone ID Answer)|T then {Loop T PID PLife PIsSurface PPosition PItemsCharge PItems PMines PPathHistoric}
	 [] sayPassingSonar(ID Answer)|T then {Loop T PID PLife PIsSurface PPosition PItemsCharge PItems PMines PPathHistoric}
	 [] sayAnswerSonar(ID Answer)|T then {Loop T PID PLife PIsSurface PPosition PItemsCharge PItems PMines PPathHistoric}
	 [] sayDeath(ID)|T then {Loop T PID PLife PIsSurface PPosition PItemsCharge PItems PMines PPathHistoric}
	 [] sayDamageTaken(ID Damage LifeLeft)|T then {Loop T PID PLife PIsSurface PPosition PItemsCharge PItems PMines PPathHistoric}
	 end
      end
   in
      {Loop StreamInit PIDInit Input.maxDamage true unit itc(missile:0 mine:0 sonar:0 drone:0) it(missile:0 mine:0 sonar:0 drone:0) nil nil}
   end
end