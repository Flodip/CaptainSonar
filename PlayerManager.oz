functor
import
   Player000Random
   Player000RandomBis
   Player000Flo1
   Player000Flo2
export
	playerGenerator:PlayerGenerator
define
   PlayerGenerator
in
   fun{PlayerGenerator Kind Color ID}
      case Kind
      of player000random then {Player000Random.portPlayer Color ID}
      [] player000randombis then {Player000RandomBis.portPlayer Color ID}
      [] player000flo1 then {Player000Flo1.portPlayer Color ID}
      [] player000flo2 then {Player000Flo2.portPlayer Color ID}
      end
   end
end