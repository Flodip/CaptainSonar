functor
import
   QTk at 'x-oz://system/wp/QTk.ozf'
   Input
    OS
export
   portWindow:StartWindow
define

   MainURL={OS.getCWD}
   Img_water = {QTk.newImage photo(url:MainURL#"/images/water.gif")}
   Img_ground = {QTk.newImage photo(url:MainURL#"/images/dirt.gif")}
   Img_sub = {QTk.newImage photo(url:MainURL#"/images/sub.gif")}
   Img_bomb = {QTk.newImage photo(url:MainURL#"/images/bomb.gif")}
   Img_expl_2 = {QTk.newImage photo(url:MainURL#"/images/expl/2.gif")}
   Img_expl_4 = {QTk.newImage photo(url:MainURL#"/images/expl/4.gif")}
   Img_expl_5 = {QTk.newImage photo(url:MainURL#"/images/expl/5.gif")}
   Img_expl_7 = {QTk.newImage photo(url:MainURL#"/images/expl/7.gif")}
   StartWindow
   TreatStream

   RemoveItem
   RemovePath
   RemovePlayer

   Map = Input.map

   NRow = Input.nRow
   NColumn = Input.nColumn


   DrawSubmarine
   MoveSubmarine
   DrawMine
   ExplosionN
   RemoveMine
   DrawPath

   BuildWindow

   Label
   Squares
   DrawMap

   StateModification

   UpdateLife
in

%%%%% Build the initial window and set it up (call only once)
   fun{BuildWindow}
      Grid GridScore Toolbar Desc DescScore Window
   in
      Toolbar=lr(glue:we tbbutton(text:"Quit" glue:w action:toplevel#close))
      Desc=grid(handle:Grid height:500 width:500)
      DescScore=grid(handle:GridScore height:100 width:500)
      Window={QTk.build td(Toolbar Desc DescScore)}

      {Window show}

      % configure rows and set headers
      {Grid rowconfigure(1 minsize:50 weight:0 pad:5)}
      for N in 1..NRow do
	 {Grid rowconfigure(N+1 minsize:50 weight:0 pad:5)}
	 {Grid configure({Label N} row:N+1 column:1 sticky:wesn)}
      end
      % configure columns and set headers
      {Grid columnconfigure(1 minsize:50 weight:0 pad:5)}
      for N in 1..NColumn do
	 {Grid columnconfigure(N+1 minsize:50 weight:0 pad:5)}
	 {Grid configure({Label N} row:1 column:N+1 sticky:wesn)}
      end
      % configure scoreboard
      {GridScore rowconfigure(1 minsize:50 weight:0 pad:5)}
      for N in 1..(Input.nbPlayer) do
	 {GridScore columnconfigure(N minsize:50 weight:0 pad:5)}
      end

      {DrawMap Grid}

      handle(grid:Grid score:GridScore)
   end


%%%%% Squares of water and island
   Squares = square(0:label(text:"" width:2 height:2 image:Img_water)
		    1:label(text:"" width:2 height:2 image:Img_ground)
		   )

%%%%% Labels for rows and columns
   fun{Label V}
      label(text:V borderwidth:5 relief:groove bg:c(55 136 253) ipadx:5 ipady:5)
   end

%%%%% Function to draw the map
   proc{DrawMap Grid}
      proc{DrawColumn Column M N}
	 case Column
	 of nil then skip
	 [] T|End then
	    {Grid configure(Squares.T row:M+1 column:N+1 sticky:wesn)}
	    {DrawColumn End M N+1}
	 end
      end
      proc{DrawRow Row M}
	 case Row
	 of nil then skip
	 [] T|End then
	    {DrawColumn T M 1}
	    {DrawRow End M+1}
	 end
      end
   in
      {DrawRow Map 1}
   end

%%%%% Init the submarine
   fun{DrawSubmarine Grid ID Position}
      Handle HandlePath HandleScore X Y Id Color LabelSub LabelScore
   in
      pt(x:X y:Y) = Position
      id(id:Id color:Color name:_) = ID

      LabelSub = label(text:"S" handle:Handle relief:raised image:Img_sub bg:Color)
      LabelScore = label(text:Input.maxDamage borderwidth:5 handle:HandleScore relief:solid bg:Color ipadx:5 ipady:5)
      HandlePath = {DrawPath Grid Color X Y}
      {Grid.grid configure(LabelSub row:X+1 column:Y+1 sticky:wesn)}
      {Grid.score configure(LabelScore row:1 column:Id sticky:wesn)}
      {HandlePath 'raise'()}
      {Handle 'raise'()}
      guiPlayer(id:ID score:HandleScore submarine:Handle mines:nil path:HandlePath|nil)
   end


   fun{MoveSubmarine Position}
      fun{$ Grid State}
	 ID HandleScore Handle Mine Path NewPath X Y
      in
	 guiPlayer(id:ID score:HandleScore submarine:Handle mines:Mine path:Path) = State
	 pt(x:X y:Y) = Position
	 NewPath = {DrawPath Grid ID.color X Y}
	 {Grid.grid remove(Handle)}
	 {Grid.grid configure(Handle row:X+1 column:Y+1 sticky:wesn)}
	 {NewPath 'raise'()}
	 {Handle 'raise'()}
	 guiPlayer(id:ID score:HandleScore submarine:Handle mines:Mine path:NewPath|Path)
      end
   end

   fun{DrawMine Position}
      fun{$ Grid State}
	 ID HandleScore Handle Mine Path LabelMine HandleMine X Y
      in
	 guiPlayer(id:ID score:HandleScore submarine:Handle mines:Mine path:Path) = State
	 pt(x:X y:Y) = Position
	 LabelMine = label(image:Img_bomb handle:HandleMine bg:ID.color)
	 {Grid.grid configure(LabelMine row:X+1 column:Y+1)}
	 {HandleMine 'raise'()}
	 {Handle 'raise'()}
	 guiPlayer(id:ID score:HandleScore submarine:Handle mines:mine(HandleMine Position)|Mine path:Path)
      end
   end
   /* NEW */

   fun{ExplosionN N Position}
      fun{$ Grid State}
	 ID HandleScore Handle Mine Path LabelMine HandleMine X Y Img_expl
      in
	  case N
	  of 1 then Img_expl = Img_expl_2
	  [] 2 then Img_expl = Img_expl_4
	  [] 3 then Img_expl = Img_expl_5
	  else Img_expl = Img_expl_7
	  end
	 guiPlayer(id:ID score:HandleScore submarine:Handle mines:Mine path:Path) = State
	 pt(x:X y:Y) = Position
	 LabelMine = label(image:Img_expl handle:HandleMine bg:c(55 136 253))
	 {Grid.grid configure(LabelMine row:X+1 column:Y+1)}
	 {HandleMine 'raise'()}
	 {Handle 'raise'()}
	 guiPlayer(id:ID score:HandleScore submarine:Handle mines:mine(HandleMine Position)|Mine path:Path)
      end
   end
   /*END NEW*/

   local
      fun{RmMine Grid Position List}
	 case List
	 of nil then nil
	 [] H|T then
	    if (H.2 == Position) then
	       {RemoveItem Grid H.1}
	       T
	    else
	       H|{RmMine Grid Position T}
	    end
	 end
      end
   in
      fun{RemoveMine Position}
	 fun{$ Grid State}
	    ID HandleScore Handle Mine Path NewMine
	 in
	    guiPlayer(id:ID score:HandleScore submarine:Handle mines:Mine path:Path) = State
	    NewMine = {RmMine Grid Position Mine}
	    guiPlayer(id:ID score:HandleScore submarine:Handle mines:NewMine path:Path)
	 end
      end
   end

   fun{DrawPath Grid Color X Y}
      Handle LabelPath
   in
      LabelPath = label(text:"" handle:Handle bg:Color)
      {Grid.grid configure(LabelPath row:X+1 column:Y+1)}
      Handle
   end

   proc{RemoveItem Grid Handle}
      {Grid.grid forget(Handle)}
   end


   fun{RemovePath Grid State}
      ID HandleScore Handle Mine Path
   in
      guiPlayer(id:ID score:HandleScore submarine:Handle mines:Mine path:Path) = State
      for H in Path.2 do
	 {RemoveItem Grid H}
      end
      guiPlayer(id:ID score:HandleScore submarine:Handle mines:Mine path:Path.1|nil)
   end

   fun{UpdateLife Life}
      fun{$ Grid State}
	 HandleScore
      in
	 guiPlayer(id:_ score:HandleScore submarine:_ mines:_ path:_) = State
	 {HandleScore set(Life)}
	 State
      end
   end


   fun{StateModification Grid WantedID State Fun}
      case State
      of nil then nil
      [] guiPlayer(id:ID score:_ submarine:_ mines:_ path:_)|Next then
	 if (ID == WantedID) then
	    {Fun Grid State.1}|Next
	 else
	    State.1|{StateModification Grid WantedID Next Fun}
	 end
      end
   end


   fun{RemovePlayer Grid WantedID State}
      case State
      of nil then nil
      [] guiPlayer(id:ID score:HandleScore submarine:Handle mines:M path:P)|Next then
	 {HandleScore set(0)}
	 if (ID == WantedID) then
	    for H in P do
	       {RemoveItem Grid H}
	    end
	    for H in M do
	       {RemoveItem Grid H.1}
	    end
	    {RemoveItem Grid Handle}
	    Next
	 else
	    State.1|{RemovePlayer Grid WantedID Next}
	 end
      end
   end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun{StartWindow}
      Stream
      Port
   in
      {NewPort Stream Port}
      thread
	 {TreatStream Stream nil nil}
      end
      Port
   end

   proc{TreatStream Stream Grid State}
      case Stream
      of nil then skip
      [] buildWindow|T then NewGrid in
	 NewGrid = {BuildWindow}
	 {TreatStream T NewGrid State}
      [] initPlayer(ID Position)|T then NewState in
	 NewState = {DrawSubmarine Grid ID Position}
	 {TreatStream T Grid NewState|State}
      [] movePlayer(ID Position)|T then
	 {TreatStream T Grid {StateModification Grid ID State {MoveSubmarine Position}}}
      [] lifeUpdate(ID Life)|T then
	 {TreatStream T Grid {StateModification Grid ID State {UpdateLife Life}}}
	 {TreatStream T Grid State}
      [] putMine(ID Position)|T then
	 {TreatStream T Grid {StateModification Grid ID State {DrawMine Position}}}
      [] removeMine(ID Position)|T then
	 {TreatStream T Grid {StateModification Grid ID State {RemoveMine Position}}}
      [] surface(ID)|T then
	 {TreatStream T Grid {StateModification Grid ID State RemovePath}}
      [] removePlayer(ID)|T then
	 {TreatStream T Grid {RemovePlayer Grid ID State}}
      [] explosion(ID Position)|T then
	 {TreatStream T Grid State}
      [] explosion(ID N Position)|T then
	 {TreatStream T Grid {StateModification Grid ID State {ExplosionN N Position}}}
      [] drone(ID Drone)|T then
	 {TreatStream T Grid State}
      [] sonar(ID)|T then
	 {TreatStream T Grid State}
      [] _|T then
	 {TreatStream T Grid State}
      end
   end
end
