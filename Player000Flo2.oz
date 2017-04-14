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
   
   IsGround
   IsInBounds
in 
   fun{StartPlayer Color ID} 
      Stream 
      Port
   in 
      {NewPort Stream Port} 
      thread {TreatStream Stream id(id:ID color:Color name:player000flo2)} end 
      Port 
   end

   fun {IsGround Position}
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
	 true
      elseif Position.y < 1 then
	 true
      elseif Position.x > Input.nRow then 
	 true
      elseif Position.y > Input.nColumn then 
	 true
      else
	 {LoopY Position.y {LoopX Position.x Input.map}} == 1
      end
   end

   fun {IsInBounds Position}
      {And Position.x =< Input.nRow Position.y =< Input.nColumn}
   end

   
   proc{TreatStream StreamInit PIDInit}
      proc {Loop Stream PID PLife PTimeSurface PIsSurface PPosition PItemsCharge PItems}
	 case Stream
	 of nil then skip
	 [] initPosition(ID Position)|T then
	    X Y in
	    X = ({OS.rand} mod Input.nColumn)+1
	    Y = ({OS.rand} mod Input.nRow)+1
	    
	    Position = pt(x:X y:Y)
	    ID = PID
	    {Loop T PID PLife PTimeSurface PIsSurface Position PItemsCharge PItems}
	 [] move(ID Position Direction)|T then
	    D in
	    D = {OS.rand} mod 5
	    if D == 0 then
	       Direction = surface
	       Position = PPosition
	       
	       {Loop T PID PLife Input.turnSurface true PPosition PItemsCharge PItems}
	    else
	       X Y Pos Dir in
	       X = PPosition.x
	       Y = PPosition.y
	       
	       case D of 1 then
		  Dir = east
		  Pos = pt(x:X y:Y+1)
	       [] 2 then 
		  Dir = west
		  Pos = pt(x:X y:Y-1)
	       [] 3 then 
		  Dir = north
		  Pos = pt(x:X-1 y:Y)
	       [] 4 then 
		  Dir = south
		  Pos = pt(x:X+1 y:Y)
	       else skip
	       end
	       
	       if {And {Not {IsGround Pos}} {IsInBounds Pos}} then
	          Direction = Dir
	          Position = Pos
	          {Loop T PID PLife PTimeSurface PIsSurface Position PItemsCharge PItems}
	       else
	          {Loop Stream PID PLife PTimeSurface PIsSurface PPosition PItemsCharge PItems}
	       end
	    end
	 [] dive|T then
	    {Loop T PID PLife PTimeSurface false PPosition PItemsCharge PItems}
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

	    {Loop T PID PLife PTimeSurface PIsSurface PPosition ItemsC Items}
	 [] fireItem(ID KindFire)|T then {Loop T PID PLife PTimeSurface PIsSurface PPosition PItemsCharge PItems}
	    %Trouver tactique, ca sert a rien de tout mettre en random
	 [] fireMine(ID Mine)|T then {Loop T PID PLife PTimeSurface PIsSurface PPosition PItemsCharge PItems}
	 [] isSurface(ID Answer)|T then
	    ID = PID
	    Answer = PIsSurface
	    {Loop T PID PLife PTimeSurface PIsSurface PPosition PItemsCharge PItems}
	 [] sayMove(ID Direction)|T then {Loop T PID PLife PTimeSurface PIsSurface PPosition PItemsCharge PItems}
	 [] saySurface(ID)|T then {Loop T PID PLife PTimeSurface PIsSurface PPosition PItemsCharge PItems}
	 [] sayCharge(ID KindItem)|T then {Loop T PID PLife PTimeSurface PIsSurface PPosition PItemsCharge PItems}
			[] sayMinePlaced(ID)|T then {Loop T PID PLife PTimeSurface PIsSurface PPosition PItemsCharge PItems}
	 [] sayMissileExplode(ID Position Message)|T then {Loop T PID PLife PTimeSurface PIsSurface PPosition PItemsCharge PItems}
	 [] sayMineExplode(ID Position Message)|T then {Loop T PID PLife PTimeSurface PIsSurface PPosition PItemsCharge PItems}
	 [] sayPassingDrone(Drone ID Answer)|T then {Loop T PID PLife PTimeSurface PIsSurface PPosition PItemsCharge PItems}
	 [] sayAnswerDrone(Drone ID Answer)|T then {Loop T PID PLife PTimeSurface PIsSurface PPosition PItemsCharge PItems}
	 [] sayPassingSonar(ID Answer)|T then {Loop T PID PLife PTimeSurface PIsSurface PPosition PItemsCharge PItems}
			[] sayAnswerSonar(ID Answer)|T then {Loop T PID PLife PTimeSurface PIsSurface PPosition PItemsCharge PItems}
	 [] sayDeath(ID)|T then {Loop T PID PLife PTimeSurface PIsSurface PPosition PItemsCharge PItems}
	 [] sayDamageTaken(ID Damage LifeLeft)|T then {Loop T PID PLife PTimeSurface PIsSurface PPosition PItemsCharge PItems}
	 end
      end
   in
      {Loop StreamInit PIDInit Input.maxDamage 0 true unit itc(missile:0 mine:0 sonar:0 drone:0) it(missile:0 mine:0 sonar:0 drone:0)}
   end
end