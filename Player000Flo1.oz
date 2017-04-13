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
in 
   fun{StartPlayer Color ID} 
      Stream 
      Port
      PID PLife PTimeSurface PIsSurface
	in 
      PID = id(id:ID color:Color name:player000flo1)
      PLife = Input.maxDamage
      PTimeSurface = 0
      PIsSurface = true
      {NewPort Stream Port} 
      thread {TreatStream Stream PID PLife PTimeSurface PIsSurface} end 
      Port 
   end
   
	%Position type: pt(x:X y:Y)
   fun{IsGround Position}
      true
   end
   
   proc{TreatStream StreamInit PIDInit PLifeInit PTimeSurfaceInit PIsSurfaceInit}
      proc {Loop Stream PID PLife PTimeSurface PIsSurface PPosition}
	 case Stream
	 of nil then skip
	 [] initPosition(ID Position)|T then
	    X Y in
	    X = ({OS.rand} mod Input.nColumn)+1
	    Y = ({OS.rand} mod Input.nRow)+1
	    
	    Position = pt(x:X y:Y)
	    ID = PID
	    {Loop T PID PLife PTimeSurface PIsSurface Position}
	 [] move(ID Position Direction)|T then
	    D in
	    D = {OS.rand} mod 5
	    
	    if D == 0 then
	       Direction = surface
	       Position = PPosition
	       
	       {Loop T PID PLife Input.turnSurface true PPosition}
	    else
	       X Y in
	       X = Position.x
	       Y = Position.y
	       
	       case D of 1 then
		  Direction = east
		  Position = pt(x:X y:Y+1)
	       [] 2 then 
		  Direction = west
		  Position = pt(x:X y:Y-1)
	       [] 3 then 
		  Direction = north
		  Position = pt(x:X-1 y:Y)
	       [] 4 then 
		  Direction = south
		  Position = pt(x:X+1 y:Y)
	       else skip
	       end
	       
	       {Loop T PID PLife PTimeSurface PIsSurface Position}
	    end
	 [] dive|T then skip
	 [] chargeItem(ID KindItem)|T then skip
	 [] fireItem(ID KindFire)|T then skip
	 [] fireMine(ID Mine)|T then skip
	 [] isSurface(ID Answer)|T then skip
	 [] sayMove(ID Direction)|T then skip
	 [] saySurface(ID Direction)|T then skip
	 [] sayCharge(ID KindItem)|T then skip
			[] sayMinePlaced(ID)|T then skip
	 [] sayMissileExplode(ID Position Message)|T then skip
	 [] sayMineExplode(ID Position Message)|T then skip
	 [] sayPassingDrone(Drone ID Answer)|T then skip
	 [] sayAnswerDrone(Drone ID Answer)|T then skip
	 [] sayPassingSonar(ID Answer)|T then skip
			[] sayAnswerSonar(ID Answer)|T then skip
	 [] sayDeath(ID)|T then skip
	 [] sayDamageTaken(ID Damage LifeLeft)|T then skip
	 end
      end
   in
      {Loop StreamInit PIDInit PLifeInit PTimeSurfaceInit PIsSurfaceInit unit}
   end
end