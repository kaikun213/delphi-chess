unit uKoenig;
interface
  uses uschach, Classes;
type

  TKoenig = class(TSchachFigur)
             constructor Create;
             function KannZiehen(P:TPosition; MitSP:Boolean): Boolean; override;
             procedure MoveTo(P:TPosition); override;
             procedure AppendZugListe(var L:TStringList); override;
            end;

implementation
uses uTurm;

const ddxyKoenig: Array[1..11] of TPosition =
   ((x:0;y:1),(x:0;y:-1),(x:-1;y:0),(x:-1;y:1),(x:-1;y:-1),
    (x:1;y:0),(x:1;y:1),(x:1;y:-1),(x:-2;y:0),(x:-3;y:0),(x:2;y:0));
{Alle 11 Positionen die ein König ziehen kann}
{------------------------------------------------------------------------------}
constructor TKoenig.Create;
  begin
  inherited Create;
  Typ := Koenig;
  end;
{------------------------------------------------------------------------------}
function TKoenig.KannZiehen(P:TPosition; MitSP:Boolean): Boolean;
var PImBrett, PIstFrei, PIstFeind, PIstSchraeg, PIstGerade, {PIstNichtSchach,}
     PIstRochade :Boolean;
    gf :TFarbe;
    PIstNichtKoenigskreis:Boolean;
begin
 gf:=GegenFarbe(Farbe);
 PIstNichtKoenigskreis := (Abstand(P,KoenigsPosition[gf])>1);

 PImBrett := (P.x >= 1) and (P.x <= 8) and (P.y >= 1) and (P.y <= 8);

 PIstFrei := Brett[P.x,P.y] = nil;

 PIstFeind := (Brett[P.x,P.y] <> nil) and (Farbe <> Brett[P.x,P.y].Farbe);

 PIstSchraeg := ((P.x=Position.x+1)and(P.y=Position.y+1)) or
                ((P.x=Position.x+1)and(P.y=Position.y-1)) or
                ((P.x=Position.x-1)and(P.y=Position.y+1)) or
                ((P.x=Position.x-1)and(P.y=Position.y-1));

 PIstGerade :=  ((P.x=Position.x+1)and(P.y=Position.y)) or
                ((P.x=Position.x)and(P.y=Position.y-1)) or
                ((P.x=Position.x-1)and(P.y=Position.y)) or
                ((P.x=Position.x)and(P.y=Position.y+1));

 PIstRochade :=   ((Farbe=weiss) and (P.y=1) and (P.x=3) and RochadeWQ) or         {Q und K verwechselt!}
                  ((Farbe=weiss) and (P.y=1) and (P.x=7) and RochadeWK) or
                  ((Farbe=schwarz) and (P.y=8) and (P.x=3) and RochadeSQ) or
                  ((Farbe=schwarz) and (P.y=8) and (P.x=7) and RochadeSK);
  {fehlt:  überstrichene Felder müssen frei sein;
           auch Startpos. und überstrichene Felder dürfen nicht im Schach stehen}

 Result := PImBrett and PIstNichtKoenigskreis and
           (((PIstFrei or PIstFeind) and (PIstSchraeg or PIstGerade)) or
           (PIstFrei and PIstRochade));

 if MitSP then Result:=Result and Schachprobe(P);

end;
{--------------------------------Benjamin---------------------------------}
procedure TKoenig.MoveTo(P:TPosition);
var diff, turmPos : TPosition;
    turm : TTurm;

begin
  diff.x := P.x - Position.x;
  diff.y := P.y - Position.y;

  if Abs(diff.x) = 2 then //ROCHADE!
  begin
    if diff.x < 0 then
    begin
      if Farbe = schwarz then turm := Brett[1,8] as TTurm
      else turm := Brett[1,1] as TTurm;
    end
    else
    begin
      if Farbe = schwarz then turm := Brett[8,8] as TTurm
      else turm := Brett[8,1] as TTurm;
    end;
    turmPos.y := Position.y;
    turmPos.x := Position.x + diff.x div 2;
    turm.MoveTo(turmPos);
  end;

  if Farbe = schwarz then
  begin
    RochadeSK := false;
    RochadeSQ := false;
  end
  else
  begin
    RochadeWK := false;
    RochadeWQ := false;
  end;
  inherited MoveTo(P);
  KoenigsPosition[Farbe]:=Position;
end;

procedure TKoenig.AppendZugListe(var L:TStringList);
var P:TPosition;
    DeltaY,k:Integer;
begin
 if Farbe=weiss then DeltaY:=1
                else DeltaY:=-1;
 for k:=1 to 11  {nicht 4!} do
  begin
   P.x:=Position.x+ddxyKoenig[k].x;
   P.y:=Position.y+ddxyKoenig[k].y*DeltaY;
   if (1<=P.x) and (P.x<=8) and (1<=P.y) and (P.y<=8) and KannZiehen(P,true) then
        L.add(PosToStr(Position)+'-'+PosToStr(P));
  end;
end;

end.

