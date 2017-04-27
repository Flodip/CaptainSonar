functor
import
   Player009Random
   PlayerBasicAI
export
	playerGenerator:PlayerGenerator
define
   PlayerGenerator
in
   fun{PlayerGenerator Kind Color ID}
      case Kind
      of player000random then {Player009Random.portPlayer Color ID}
      [] playerbasicai then {PlayerBasicAI.portPlayer Color ID}
      end
   end
end