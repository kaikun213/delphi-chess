unit uSpringer;    //von Benni und Carlos
interface
  uses uschach, Classes;
//------------------------------------------------------------------------------
  type

  TSpringer = class(TSchachFigur)
               constructor Create;
               function KannZiehen(P:TPosition; MitSP:Boolean): Boolean; override;
               procedure AppendZugListe(var L:TStringList); override;
            end;
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
implementation

const
 ddxySpringer: Array[1..8] of TPosition =
    ((x:-1;y:2),(x:-2;y:1),(x:-2;y:-1),(x:1;y:-2),
     (x:2;y:1),(x:2;y:-1),(x:-1;y:-2),(x:1;y:2));
    {Alle Positionen die ein Springer ziehen kann(8)}

constructor TSpringer.Create;
  begin
  inherited Create;
  Typ:=Springer;                                         {war Typ := Laeufer; !}
  end;
//------------------------------------------------------------------------------
function TSpringer.KannZiehen(P:TPosition; MitSP:Boolean): Boolean;
var PImBrett, PIstFrei, PIstFeind, PIstDada :Boolean;
begin
  PImBrett := (P.x >= 1) and (P.x <= 8) and (P.y >= 1) and (P.y <= 8);

  PIstFrei := Brett[P.x,P.y] = nil;

  PIstFeind := (Brett[P.x,P.y] <> nil) and (Farbe <> Brett[P.x,P.y].Farbe);

  PIstDada := (P.x = Position.x +1) and ((P.y = Position.y +2) or (P.y = Position.y -2)) or
              (P.x = Position.x +2) and ((P.y = Position.y +1) or (P.y = Position.y -1)) or
              (P.x = Position.x -1) and ((P.y = Position.y +2) or (P.y = Position.y -2)) or
              (P.x = Position.x -2) and ((P.y = Position.y +1) or (P.y = Position.y -1));

  Result := PImBrett and
            ((PIstFrei and PIstDada) or
            (PIstFeind and PIstDada));
  if MitSP then Result:=Result and Schachprobe(P);
end;
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


procedure TSpringer.AppendZugListe(var L:TStringList);
var P:TPosition;
    DeltaY,k:Integer;
begin
 if Farbe=weiss then DeltaY:=1         {beim Springer unnötig!}
                else DeltaY:=-1;
 for k:=1 to 8 do
  begin
   P.x:=Position.x+ddxySpringer[k].x;
   P.y:=Position.y+ddxySpringer[k].y*DeltaY;
   if (1<=P.x) and (P.x<=8) and (1<=P.y) and (P.y<=8) and KannZiehen(P,true) then
        L.add(PosToStr(Position)+'-'+PosToStr(P)); {Muss optimiert werden}
  end;
end;


end.
