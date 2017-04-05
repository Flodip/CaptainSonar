functor
import
	Player000Random
export
	playerGenerator:PlayerGenerator
define
	PlayerGenerator
in
	fun{PlayerGenerator Kind Color ID}
		case Kind
		of player000random then {Player000Radom.portPlayer Color ID}
		end
	end
end