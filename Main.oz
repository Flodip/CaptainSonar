functor
import
   GUI
   Input
   PlayerManager
   System
define
   P
   InitPlayers
in
   %1. Create the port for the GUI and launch its interface
   %2. Create the port for every player using the PlayerManager and assign an unique id between
   %   1 and Input.nbPlayer(<idnum>). The ids are given in the order they are defined in the input file
   %3. Ask every player to set up (choose its initial point,  they all are at the surface at this time)
   %4. When every player has set up, launch the game (either run in turn by turn or in simultaneous mode,
   %   as specified by the input file)

   P = {GUI.portWindow}
   {Send P buildWindow}

    proc{InitPlayers Num}
       {System.show Num}
       {InitPlayers Num - 1}
    end
    
   {InitPlayers Input.nbPlayer}
   
end