functor
import
	Player042BasicAI
	Player023AdvancedAI
	Player005Custom
	Player053Human
	....
export
	playerGenerator:PlayerGenerator
define
	PlayerGenerator
in
	fun{PlayerGenerator Kind Color ID}
		case Kind
		of player042basicai then {Player042BasicAI.portPlayer Color ID}
		[] player005custom then {Player005Custom.portPlayer Color ID}
		...
		end
	end
end