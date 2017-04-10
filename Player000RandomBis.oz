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

	PID
	PLife
	PTimeSurface
	PIsSurface
in 
   fun{StartPlayer Color ID} 
      Stream 
      Port 
   in 
      PID = id(id:ID color:Color name:player000randombis)
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