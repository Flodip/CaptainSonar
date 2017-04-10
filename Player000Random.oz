functor
import
   Input
   OS
   System
export 
   portPlayer:StartPlayer 
define 
   %Utilities
   NewPortObject
   %Getter and setter
   Porter
   %Player
   StartPlayer 
   TreatStream
   
   PID
   PLife
   PTimeSurface
	PIsSurface
in

   fun {NewPortObject Behaviour Init}
      proc {MsgLoop S1 State}
	 case S1
	 of Msg|S2 then
	    {MsgLoop S2 {Behaviour Msg State}}
	 [] nil then skip
	 end
      end
   Sin
   in
      thread {MsgLoop Sin Init} end
      {NewPort Sin}
   end

   fun {Porter LifeInit IsSurfaceInit TurnSurfaceInit}
      fun {Loop Msg Life IsSurface TurnSurface}
	 case Msg
	 of getLife(N) then N = Life Life
	 % life = life - N
	 [] damage(N) then Life - N
	 [] isSurface then IsSurface
	 [] getTurnSurface then TurnSurface
	 [] downTurnSurface(N) then TurnSurface - N
	 end
      end
   in
      {NewPortObject Loop LifeInit IsSurfaceInit TurnSurfaceInit}
   end
   
   fun{StartPlayer Color ID} 
      Stream 
      Port 
   in 
      PID = id(id:ID color:Color name:player000random)
      PLife = Input.maxDamage
      PTimeSurface = 0
      PIsSurface = true
      {NewPort Stream Port} 
      thread {TreatStream Stream} end 
      Port 
   end

   proc{TreatStream Stream}
      
      case Stream
      of nil then skip
      [] initPosition(ID Position)|T then
	 X Y in
	 X = ({OS.rand} mod Input.nColumn)+1
	 Y = ({OS.rand} mod Input.nRow)+1
	      
	 Position = pt(x:X y:Y)
	 ID = PID
      [] move(ID Position Direction)|T then
	 if Direction == surface then 
	    PIsSurface = true
	    PTimeSurface = Input.turnSurface
	 else
	    skip end %not finished
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
end