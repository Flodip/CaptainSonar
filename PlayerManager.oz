functor
import
   Player009Random
   Player009BasicAI

   PlayerBasicAI
export
	playerGenerator:PlayerGenerator
define
   PlayerGenerator
in
   fun{PlayerGenerator Kind Color ID}
      case Kind
      of player009random then {Player009Random.portPlayer Color ID}
      [] player009basicai then {Player009BasicAI.portPlayer Color ID}
      [] playerbasicai then {PlayerBasicAI.portPlayer Color ID}
      end
   end
end