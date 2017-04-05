functor
import
	Player000Random
	Player000RandomBis
export
	playerGenerator:PlayerGenerator
define
	PlayerGenerator
in
	fun{PlayerGenerator Kind Color ID}
		case Kind
		of player000random then {Player000Radom.portPlayer Color ID}
		[] player000randombis then {Player000RandomBis.portPlayer Color ID}
		end
	end
end