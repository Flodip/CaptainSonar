import 
	Input 
export 
	portPlayer:StartPlayer 
define 
	StartPlayer 
	TreatStream
in 
	fun{StartPlayer Color ID} 
		Stream 
		Port 
	in 
		{NewPort Stream Port} 
		thread {TreatStream Stream <p1> <p2> ...} end 
		Port 
	end
	
	proc{TreatStream Stream <p1> <p2> ...}
		case Stream
		of nil then skip
		[] initPosition(ID Position)|T then
		[] move(ID Position Direction)|T then
		[] dive|T then
		[] chargeItem(ID KindItem)|T then
		[] fireItem(ID KindFire)|T then
		[] fireMine(ID Mine)|T then
		[] isSurface(ID Answer)|T then
		[] sayMove(ID Direction)|T then
		[] saySurface(ID Direction)|T then
		[] sayCharge(ID KindItem)|T then
		[] sayMinePlaced(ID)|T then
		[] sayMissileExplode(ID Position Message)|T then
		[] sayMineExplode(ID Position Message)|T then
		[] sayPassingDrone(Drone ID Answer)|T then
		[] sayAnswerDrone(Drone ID Answer)|T then
		[] sayPassingSonar(ID Answer)|T then
		[] sayAnswerSonar(ID Answer)|T then
		[] sayDeath(ID)|T then
		[] sayDamageTaken(ID Damage LifeLeft)|T then
		end
	end 
end