unit uSchach;
interface
 uses Graphics, Classes, SysUtils, Dialogs;

type
 TZug = String;
 TPosition = record
              x,y:Integer;
             end;

 TFarbe = (schwarz, weiss);
 TTyp   = (Bauer,Laeufer,Springer,Turm,Dame,Koenig);
 TSchachFigur = class
                 Position: TPosition;
                 Farbe:TFarbe;
                 aktiv:Boolean;
                 Typ:TTyp;
                 BildIndex:Integer; {in der Bilder-Liste}

                 constructor Create;
                 destructor Destroy; override;
                 procedure Zeichnen;
                 function KannZiehen(P:TPosition; MitSP:Boolean):Boolean; virtual;  {Nachfolger (Figuren) Also AbgeleiteteKlassen erben und k�nnen dies ver�ndern!(per override) dann "Result:=inherited KannZiehen(P);"}
                 procedure MoveTo(P:TPosition); virtual;
                 function Schachprobe(P:TPosition):Boolean; 
                 procedure AppendZugListe(var L:TStringList); virtual;
                end;

var Brett : Array[1..8,1..8] of TSchachFigur;
    Spieler,Max,Min : TFarbe;
    RochadeWK,RochadeWQ,RochadeSK,RochadeSQ : Boolean;
    enpassantPos:TPosition;
    AnzahlFiguren : Array[schwarz..weiss,Bauer..Koenig] of Integer;
    KoenigsPosition : Array[schwarz..weiss] of TPosition;
	  startPos:TPosition;
    gameOver:Boolean;


function Gegenfarbe(F:TFarbe):TFarbe;
function Abstand(p1,p2:TPosition):Integer;
function IstFrei(P:TPosition) : Boolean;
function ImBrett(P:TPosition) : Boolean;
function GleichP(P1,P2:TPosition):Boolean;
function PosToStr(P:TPosition) : String;
function StrToPos(S:String) : TPosition;
function ColToStr(c:TFarbe) : String;

procedure Execute(Zug:String);
function ZugListeVon(Farbe:TFarbe):TStringList;
function ImSchach(F:TFarbe):Boolean;
function IstMatt(Farbe:TFarbe; var IstPatt:Boolean):Boolean;

implementation
 uses uFEN;

constructor TSchachFigur.Create;
begin
 inherited Create;
 Position.x:=0;     {muss noch gesetzt werden}
 Position.y:=0;
 Farbe:=weiss;
 aktiv:=true;
 Typ:=Bauer;
end;

destructor TSchachFigur.Destroy;
begin
 inherited destroy;
end;

procedure TSchachFigur.Zeichnen;
begin
end;

function TSchachFigur.KannZiehen(P:TPosition; MitSP:Boolean):Boolean;
begin
 Result:=false;
end;

{Ben,Marlon}
procedure TSchachFigur.MoveTo(P:TPosition); //KannZiehen muss vorher gepr�ft werden
var T:TTyp;
    F:TFarbe;
begin
   if Brett[P.x,p.y]<>nil then
    begin      {schlagen}
     T:=Brett[P.x,P.y].Typ;
     F:=Brett[P.x,P.y].Farbe;

     {Anton:} 
     if (T=Turm) and (F=Weiss) then
      begin
       if (P.x=8) and (P.y=1) then RochadeWK:=false;
       if (P.x=1) and (P.y=1) then RochadeWQ:=false;
       end;
      if (T=Turm) and (F=Schwarz) then
        begin
          if (P.x=8) and (P.y=8) then RochadeSK:=false;
          if (P.x=1) and (P.y=8) then RochadeSQ:=false;
        end;

     Dec(AnzahlFiguren[F,T]);
     Brett[P.x,P.y].Destroy;
     Brett[P.x,P.y]:=nil;
    end;
   Brett[Position.x,Position.y]:= nil;
   Position:=P;
   Brett[P.x,P.y]:=self;
   enpassantPos.x:=0;
   enpassantPos.y:=0;
end;

function TSchachFigur.SchachProbe(P:TPosition):Boolean;
{pr�ft, ob man nach dem Zug nach P nicht im Schach st�nde}
var F,FE:TSchachFigur;
    P0,KP0:TPosition;
begin
 {merken}
 F:=Brett[P.x,P.y];
 P0:=Position;
 KP0:=KoenigsPosition[Farbe];

 {einfaches Probeziehen ohne Move}
 Brett[P0.x,P0.y]:=nil;
 Brett[P.x,P.y]:=self;
 Position:=P;

 if (Typ=Bauer) and (F=nil) and (P0.x<>P.x)
    then FE:=Brett[P.x,P0.y]        {Enpassant-Schlag: geschlagener Bauer}
    else FE:=nil;

 if Typ=Koenig then KoenigsPosition[Farbe]:=P;

 {nicht im Schach?}
 Result:=not ImSchach(Farbe);

 {zur�ckziehen}
 Position:=P0;
 Brett[P0.x,P0.y]:=self;
 Brett[P.x,P.y]:=F;

 if (Typ=Bauer) and (F=nil) and (P0.x<>P.x)
    then Brett[P.x,P0.y]:=FE;

 if Typ=Koenig then KoenigsPosition[Farbe]:=P0;
end;

{Jakob,Alexander}
procedure TSchachFigur.AppendZugListe(var L:TStringList);
var x1,y1:Integer;
    P:TPosition;
begin
 for x1:=1 to 8 do
  for y1:=1 to 8 do
   begin
    P.x:=x1;
    P.y:=y1;
    if KannZiehen(P,true) then
      L.add(PosToStr(Position)+'-'+PosToStr(P)); {Muss optimiert werden}
   end;
end;

{*****************************************************************}

function Gegenfarbe(F:TFarbe):TFarbe;
begin
if F = weiss then
   result := schwarz
   else
   result := weiss;
end;


function Abstand(p1,p2:TPosition):Integer;
var x,y:Integer;
begin
 x := abs(p1.x - p2.x);
 y := abs(p1.y - p2.y);
 if x<y then result := y
        else result := x;
end;


function IstFrei(P:TPosition) : Boolean;
begin
 Result:=(Brett[P.x,P.y]=nil);
end;

function ImBrett(P:TPosition) : Boolean;
begin
 Result:=(P.x in [1..8]) and (P.y in [1..8]);
end;

{Carlos}
function PosToStr(P:TPosition) : String;
begin
 Result := StrFromColumn(P.x) + IntToStr(P.y);
end;

{Erik, Dario}
function ColToStr(c:TFarbe) : String;
begin
  if c = weiss then Result := 'Wei�'
  else Result := 'Schwarz';
end;

{Carlos}
function StrToPos(S:String) : TPosition;
var ersterTeil, zweiterTeil : char;
begin
  ersterTeil := S[1];
  zweiterTeil := S[2];
  Result.x := ColumnFromString(ersterTeil);
  Result.y := StrToInt(zweiterTeil);
end;

function GleichP(P1,P2:TPosition):Boolean;
begin
 Result:=(P1.x=P2.x) and (P1.y=P2.y);
end;


procedure Execute(Zug:String);
var StartPos, ZielPos : TPosition;
begin
  StartPos := StrToPos(Zug[1]+Zug[2]);
  ZielPos := StrToPos(Zug[4] + Zug[5]);
  Brett[StartPos.x, StartPos.y].MoveTo(ZielPos);
end;

{Jakob, Alexander}
function ZugListeVon(Farbe:TFarbe):TStringList;
var  x1,y1:Integer;
         L:TStringList;
         F:TSchachFigur;
begin
 L:=TStringList.Create;
 for x1:=1 to 8 do
  for y1:=1 to 8 do
   begin
    F:= Brett[x1,y1];
    if (F<>nil) and (F.Farbe = Farbe) then
     F.AppendZugListe(L);
   end;
 Result:=L;
end;

{***************************************************************************}

{Anton und Philipp}
function ImSchach(F:TFarbe):Boolean;
var x,y:Integer;
begin
 Result:=false;
 x:=1;
 while (x<=8) and not Result do
   begin
    y:=1;
    while (y<=8) and not Result do
       begin
         if (Brett[x,y]<>nil) and (Brett[x,y].Farbe<>F) and
            Brett[x,y].Kannziehen(Koenigsposition[F],false)  {ohne Schachprobe!}
                   then Result:=true;
        inc(y);
       end;
    inc(x);
   end;
end;

{Anton}
function IstMatt(Farbe:TFarbe; var IstPatt:Boolean):Boolean;
var i:Integer;
    L:TStringList;
    Zug,fen:String;
begin
 L:=ZugListeVon(Farbe);
 Result:=ImSchach(Farbe);
 i:=0;
 while Result  and (i<L.Count) do   {!!!}
  begin
    Zug:=L.Strings[i];
    Fen:=FenfromBoard;
    Execute(Zug);
    if not ImSchach(Farbe) then Result:=false;
    inc(i);
    BoardfromFen(Fen);
  end;
 IstPatt:=not Result and (L.Count = 0);
 L.Clear;
 L.Destroy;
end;

end.
