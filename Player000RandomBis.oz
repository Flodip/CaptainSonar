functor
import
   Input
   OS
   System
export 
   portPlayer:LaunchServer
define 
   %Setters and getters
   NewPortObj
   Porter
   X
   Y
   Id
   IsSurface
   Life
   TurnSurface
   LaunchServer

   Object
   %Util
   
   %Player
   StartPlayer 
   TreatStream
   
   PID
   PLife
   PTimeSurface
   PIsSurface
in
%%%%%%%% Setters and getters %%%%%%%%%%%%%%%%%%%%%%%%%
% Utilisation :
   % S = {LaunchServer}
   % Setter : {Send S setX(1)}
   % Getter : {Send S getX(X)} --> Will be bound to X
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
fun {NewPortObj Behaviour Init}
   proc {MsgLoop S1 State}
      case S1
      of Msg|S2 then
    {MsgLoop S2 {Behaviour Msg State}}
      [] nil then skip
      end
   end
   Sin
in
   thread {MsgLoop Sin Init} end
   {NewPort Sin}
end

fun {X}
   fun {Loop Msg X}
      case Msg
      of setX(N) then N
      [] getX(N) then N = X
    X
      end
   end
in
   {NewPortObj Loop 0}
end

fun {Y}
   fun {Loop Msg Y}
      case Msg
      of setY(N) then N
      [] getY(N) then N = Y
    Y
      end
   end
in
   {NewPortObj Loop 0}
end

fun {Id}
   fun {Loop Msg Id}
      case Msg
      of setId(N) then
    {System.show'Id : '#N}
    N
      [] getId(N) then N = Id
    Id
      end
   end
in
   {NewPortObj Loop null}
end

fun {IsSurface}
   fun {Loop Msg IsSurface}
      case Msg
      of setIsSurface(N) then N
      [] isSurface(N) then N = IsSurface
    IsSurface
      end
   end
in
   {NewPortObj Loop true}
end

fun {Life}
   fun {Loop Msg Life}
      case Msg
      of setLife(N) then
    {System.show 'Life : '#N}
    N
      [] getLife(N) then N = Life
    Life
      end
   end
in
   {NewPortObj Loop Input.maxDamage}
end

fun {TurnSurface}
   fun {Loop Msg TurnSurface}
      case Msg
      of setTurnSurface(N) then N
      [] getTurnSurface(N) then N = TurnSurface
    TurnSurface
      end
   end
in
   {NewPortObj Loop 0}
end

fun {LaunchServer Color ID}
   proc {Loop S Xs Ys Ids ISs Ls TSs}
      case S
    %X setter+getter
      of getX(N)|T then {Send Xs getX(N)} {Loop T Xs Ys Ids ISs Ls TSs}
      [] setX(N)|T then {Send Xs setX(N)} {Loop T Xs Ys Ids ISs Ls TSs}
    %Y setter+getter
      [] getY(N)|T then {Send Ys getY(N)} {Loop T Xs Ys Ids ISs Ls TSs}
      [] setY(N)|T then {Send Ys setY(N)} {Loop T Xs Ys Ids ISs Ls TSs}
    %Id
      [] getId(N)|T then {Send Ids getId(N)} {Loop T Xs Ys Ids ISs Ls TSs}
      [] setId(N)|T then {Send Ids setId(N)} {Loop T Xs Ys Ids ISs Ls TSs}
    %Life 
      [] getLife(N)|T then {Send Ls getLife(N)} {Loop T Xs Ys Ids ISs Ls TSs} 
      [] setLife(N)|T then {Send Ls setLife(N)} {Loop T Xs Ys Ids ISs Ls TSs}
    %IsSurface
      [] isSurface(N)|T then {Send ISs isSurface(N)} {Loop T Xs Ys Ids ISs Ls TSs} 
      [] setIsSurface(N)|T then {Send ISs setIsSurface(N)} {Loop T Xs Ys Ids ISs Ls TSs}
    %TurnSurface
      [] getTurnSurface(N)|T then {Send TSs getTurnSurface(N)} {Loop T Xs Ys Ids ISs Ls TSs} 
      [] setTurnSurface(N)|T then {Send TSs setTurnSurface(N)} {Loop T Xs Ys Ids ISs Ls TSs}
    %Pattern error
      else skip
      end
   end
   P S Xs Ys Ids ISs Ls TSs
   %Player vars
   Stream Port
in
   Object={NewPort S}
   Xs={X}
   Ys={Y}
   Ids={Id}
   ISs={IsSurface}
   Ls={Life}
   TSs ={TurnSurface}
   thread {Loop S Xs Ys Ids ISs Ls TSs} end
   
   %Starting up Object
%   PID = id(id:ID color:Color name:player000random)
   {Send Object setId(id(id:ID color:Color name:player000randombis))}
   
%   On init maxDamage is set to Input.maxDamage
%   PLife = Input.maxDamage
%   On init timeSurface is set to 0   
%   PTimeSurface = 0
%   On init PIsSurface is set to true
%   PIsSurface = true
   {NewPort Stream Port} 
   thread {TreatStream Stream} end 
   Port
end

%%%%%%%%% End setters and getters %%%%%%%%%%%%%%%%%%%%

%%%%%%%%% Utilities  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%% End utilities  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   proc{TreatStream Stream}
      case Stream
      of nil then skip
      [] initPosition(ID Position)|T then
    X Y in 
    X = ({OS.rand} mod Input.nColumn)+1
    Y = ({OS.rand} mod Input.nRow)+1
         
    Position = pt(x:X y:Y)
    {Send Object getId(ID)}
      [] move(ID Position Direction)|T then
    if Direction == surface then 
       PIsSurface = true
       PTimeSurface = Input.turnSurface
    else
       skip end %not finished
      [] dive|T then skip
      [] chargeItem(ID KindItem)|T then skip
      [] fireItem(ID KindFire)|T then skip
      [] fireMine(ID Mine)|T then skip
      [] isSurface(ID Answer)|T then skip
      [] sayMove(ID Direction)|T then skip
      [] saySurface(ID Direction)|T then skip
      [] sayCharge(ID KindItem)|T then skip
      [] sayMinePlaced(ID)|T then skip
      [] sayMissileExplode(ID Position Message)|T then skip
      [] sayMineExplode(ID Position Message)|T then skip
      [] sayPassingDrone(Drone ID Answer)|T then skip
      [] sayAnswerDrone(Drone ID Answer)|T then skip
      [] sayPassingSonar(ID Answer)|T then skip
      [] sayAnswerSonar(ID Answer)|T then skip
      [] sayDeath(ID)|T then skip
      [] sayDamageTaken(ID Damage LifeLeft)|T then skip
      end
   end 
end