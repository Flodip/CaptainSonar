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
		thread {TreatStream Stream} end 
		Port 
	end
	
	proc{TreatStream Stream}
		case Stream
		of nil then skip
		[] initPosition(ID Position)|T then skip
		[] move(ID Position Direction)|T then skip
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