functor
import
   OS
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
   DefaultMapProc
   GenerateMapProc

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
   PercentOfGround = 11

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

    proc {GenerateMapProc}
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
 end


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
