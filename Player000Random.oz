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
	
	proc{TreatStream Stream <p1> <p2> ...} % has as many parameters as you want ... 
	end 
end