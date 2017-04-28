functor
import
   OS
   System
export
   isTurnByTurn:IsTurnByTurn
   nRow:NRow
   nColumn:NColumn
   map:Map
   nbPlayer:NbPlayer
   players:Players
   colors:Colors
   thinkMin:ThinkMin
   thinkMax:ThinkMax
   turnSurface:TurnSurface
   maxDamage:MaxDamage
   missile:Missile
   mine:Mine
   sonar:Sonar
   drone:Drone
   minDistanceMine:MinDistanceMine
   maxDistanceMine:MaxDistanceMine
   minDistanceMissile:MinDistanceMissile
   maxDistanceMissile:MaxDistanceMissile

   % Gen map
   generateMap:GenerateMap
   generateMapProc:GenerateMapProc
   defaultMapProc:DefaultMapProc
define
   IsTurnByTurn
   NRow
   NColumn
   Map

   GenerateMap
   PercentOfGround
   %Map generation
   DefaultMapProc
   GenerateMapProc
   /* AUX METH MAP GENERATION */
   Nth
   GenerateList
   DeletePt
   Work
   DoMerge
   CanMerge
   IsMergeable
	SideBySide

   NbPlayer
   Players
   Colors
   ThinkMin
   ThinkMax
   TurnSurface
   MaxDamage
   Missile
   Mine
   Sonar
   Drone
   MinDistanceMine
   MaxDistanceMine
   MinDistanceMissile
   MaxDistanceMissile

in

%%%% Style of game %%%%

   IsTurnByTurn = true

%%%% Description of the map %%%%

   NRow = 10
   NColumn = 10

   GenerateMap = true
   PercentOfGround = 40

   proc {DefaultMapProc}
     Map = [[0 0 0 0 0 0 0 0 0 0]
  	  [0 0 0 0 0 0 0 0 0 0]
  	  [0 0 0 1 1 0 0 0 0 0]
  	  [0 0 1 1 0 0 1 0 0 0]
  	  [0 0 0 0 0 0 0 0 0 0]
  	  [0 0 0 0 0 0 0 0 0 0]
  	  [0 0 0 1 0 0 1 1 0 0]
  	  [0 0 1 1 0 0 1 0 0 0]
  	  [0 0 0 0 0 0 0 0 0 0]
  	  [0 0 0 0 0 0 0 0 0 0]]
   end
   
   
   fun {Nth List X}
      if X == 0 then
      List.1
      else
	 {Nth List.2 X-1} end
   end
   
   fun {GenerateList Map}
      fun {Loop X Y MaxX MaxY Map}
	 if X == MaxX then nil
	 elseif Y == MaxY then {Loop X+1 0 MaxX MaxY Map}
	 else
	    Val in
	    Val = {Nth {Nth Map X} Y}
	% {Browse 'X:'#X#'Y:'#Y#' : '#Val}
	    if Val == 0 then pt(x:X y:Y)|{Loop X Y+1 MaxX MaxY Map}
	    else {Loop X Y+1 MaxX MaxY Map} end
	 end
      end
   in
      {Loop 0 0 NRow NColumn Map}
   end
   
   fun {DeletePt List Pt}
      case List
      of nil then nil
      [] H|T then
	 if H == Pt then T
	 else H|{DeletePt T Pt} end
      end
   end
   fun {Work ListP} ListValid ListTest in 
      ListValid = ListP.1
      ListTest = {DeletePt ListP ListP.1} 
      {DoMerge ListTest ListValid}
   end
   
   fun {DoMerge ListWater ListValid}
      if {List.length ListWater} == 0 then true
      else
	 Val in
	 Val = {CanMerge ListWater ListValid}
	 if Val \= nil then
	    {DoMerge {DeletePt ListWater Val} Val|ListValid}
	 else
	    false
	 end
	 
      end
   end
   
   fun {CanMerge List ListValid}
      case List
      of nil then nil
   [] H|T then
	 if {IsMergeable H ListValid} == true then H else {CanMerge T ListValid} end
      end
   end
   
   fun {IsMergeable Pt ListP}
      case ListP
   of nil then false
      [] H|T then
	 if {SideBySide H Pt} == true then true
	 else {IsMergeable Pt T} end
      [] H then
	 if {SideBySide H Pt} then true
	 else false end
      end
   end
   
   fun {SideBySide Pt1 Pt2}
      if Pt1.x+1 == Pt2.x andthen Pt1.y == Pt2.y then true
      elseif Pt1.x-1 == Pt2.x andthen Pt1.y == Pt2.y then true
      elseif Pt1.y+1 == Pt2.y andthen Pt1.x == Pt2.x then true
      elseif Pt1.y-1 == Pt2.y andthen Pt1.x == Pt2.x then true
      else false
      end
	end	
   
   fun {GenerateMapProc}
      fun {LoopLg N}
	 if N == 0 then nil
	 else
	    if ({OS.rand} mod 100) < PercentOfGround then
	       1|{LoopLg N-1}
	    else
	       0|{LoopLg N-1}
	    end
	 end
      end
      fun {Loop Row Col}
	 if Row =< 0 then nil
	 else {LoopLg Col}|{Loop Row-1 Col} end
      end
      Val ListWater in
      Val = {Loop NRow NColumn}
      %{Browse Val} 
      ListWater = {GenerateList Val}
      if {Work ListWater} == true then Map = Val true
      else {System.show 'Generation de map incorrect ... Nouvel essai'} false 
      end
   end
   /*proc {GenerateMapProc}
      fun {LoopLg N}
	 if N == 0 then nil
	 else
	    if ({OS.rand} mod 100) < PercentOfGround then
	       1|{LoopLg N-1}
	    else
	       0|{LoopLg N-1}
	    end
	 end
      end
      fun {Loop Row Col}
	 if Row =< 0 then nil
	 else {LoopLg Col}|{Loop Row-1 Col} end
      end
   in
    Map = {Loop NRow NColumn}
   end*/
   
   
%%%% Players description %%%%

   NbPlayer = 2
   Players = [player009basicai player009random]
   Colors = [yellow c(255 128 64)]

%%%% Thinking parameters (only in simultaneous) %%%%

   ThinkMin = 50
   ThinkMax = 300

%%%% Surface time/turns %%%%

   TurnSurface = 3

%%%% Life %%%%

   MaxDamage = 4

%%%% Number of load for each item %%%%

   Missile = 3
   Mine = 3
   Sonar = 3
   Drone = 3

%%%% Distances of placement %%%%

   MinDistanceMine = 1
   MaxDistanceMine = 2
   MinDistanceMissile = 1
   MaxDistanceMissile = 4
end
