functor
import
   GUI
   Input
   PlayerManager
   System
define
   P
   ListPlayers

   InitPlayers
in
   fun {InitPlayers}
      fun {IPR N Players Colors ListPlayers}
         P in
         case Players#Colors of (Kind|T1)#(Color|T2) then
            {System.show Kind#Color}
            P = {PlayerManager.playerGenerator Kind Color N}
            {System.show P}
            ListPlayers = {Append ListPlayers P|nil}
            {IPR N+1 T1 T2 ListPlayers}
         else ListPlayers
         end
      end
      in
         {IPR 1 Input.players Input.colors nil}
   end

   %1. Create the port for the GUI and launch its interface
   %2. Create the port for every player using the PlayerManager and assign an unique id between
   %   1 and Input.nbPlayer(<idnum>). The ids are given in the order they are defined in the input file
   %3. Ask every player to set up (choose its initial point,  they all are at the surface at this time)
   %4. When every player has set up, launch the game (either run in turn by turn or in simultaneous mode,
   %   as specified by the input file)

   %Port GUI init and display Window
   P = {GUI.portWindow}
   {Send P buildWindow}
   {System.show 'Window initialized'}
   
   %Ports Players init
   ListPlayers = {InitPlayers}
   {System.show ListPlayers}
end