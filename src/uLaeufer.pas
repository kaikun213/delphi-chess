unit ulaeufer;    //von Anton und Philipp

interface

  uses uschach;
//------------------------------------------------------------------------------
  type

  TLaeufer = class(TSchachFigur)
            constructor Create;
            function KannZiehen(P:TPosition; MitSP:Boolean): Boolean; override;
            end;
//------------------------------------------------------------------------------
  function KannZiehenSchraegeLauflinie(Pstart,Pziel:TPosition):Boolean;
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
implementation

constructor TLaeufer.Create;
  begin
  inherited Create;
  Typ := Laeufer;
  end;
//------------------------------------------------------------------------------

function TLaeufer.KannZiehen(P:TPosition; MitSP:Boolean): Boolean;  {kann zur Zeit nicht schlagen!}
var PImBrett, PIstFrei, PIstFeind: Boolean;
    F: TSchachFigur;
begin
  F := Brett[P.x,P.y];
  PImBrett := ImBrett(P);
  PIstFrei := (F = nil);
  PIstFeind := (F<>nil) and (F.Farbe <> Farbe);  {F<>nil fehlte!}
  Result := PImBrett and (PIstFeind or PIstFrei)
   and KannZiehenSchraegeLauflinie(Position,P);    {Endlos-Schleife!}

   if MitSP then Result:=Result and Schachprobe(P);
end;
//------------------------------------------------------------------------------

function KannZiehenSchraegeLauflinie(Pstart,Pziel:TPosition):Boolean;
//wird nur aufgerufen, wenn das Ziel im Brett ist
  var PAufLauflinie, LauflinieIstFrei: Boolean;
      p1: TPosition;
      i,d: Integer;
  begin
  PAufLaufLinie := false;
{  LauflinieIstFrei := false;}
//  Result := false;
  d := 0;
//----------------- PAufLauflinie:
//----------------- Ist Lauflinie x+1, y+1 ?
  i := 1;
  p1 := Pstart;
  while (i <= 8) and ImBrett(p1) and (not PAufLauflinie) do
    begin
    if GleichP(Pziel,p1) then
      begin
      PAufLauflinie := true;
      d := 1;
      end
        else
        begin
        p1.x := p1.x + 1;
        p1.y := p1.y + 1;
        i := i + 1;
        end;
    end;
//----------------- Ist Lauflinie x-1, y-1 ?
  i := 1;
  p1 := Pstart;
    while (i <= 8) and ImBrett(p1) and (not PAufLauflinie) do
      begin
      if GleichP(Pziel,p1) then
        begin
        PAufLauflinie := true;
        d := 4;
        end
          else
          begin
          p1.x := p1.x - 1;
          p1.y := p1.y - 1;
          i := i + 1;
          end;
      end;
//----------------- Ist Lauflinie x-1, y+1 ?
  i := 1;
  p1 := Pstart;
    while (i <= 8) and ImBrett(p1) and (not PAufLauflinie) do
      begin
      if GleichP(Pziel,p1) then
        begin
        PAufLauflinie := true;
        d := 2;
        end
          else
          begin
          p1.x := p1.x - 1;
          p1.y := p1.y + 1;
          i := i + 1;
          end;
      end;
//----------------- Ist Lauflinie x+1, y-1 ?
  i := 1;
  p1 := Pstart;
    while (i <= 8) and ImBrett(p1) and (not PAufLauflinie) do
      begin
      if GleichP(Pziel,p1) then
        begin
        PAufLauflinie := true;
        d := 3;
        end
          else
          begin
          p1.x := p1.x + 1;
          p1.y := p1.y - 1;
          i := i + 1;
          end;
      end;
//----------------- LauflinieIstFrei
  p1 := Pstart;
  LauflinieIstfrei := true;
  if PAufLauflinie then
    begin
      case d of
      1:          begin
                    while ((p1.x <> Pziel.x - 1) and (p1.y <> Pziel.y - 1)
                    and LaufLinieIstfrei) do
                      begin
                      p1.x:=p1.x+1;
                      p1.y:=p1.y+1;
                      if (Brett[p1.x,p1.y] <> nil)
                        then LauflinieIstFrei := false;
                      end;
                  end;

      2:          begin
                    while ((p1.x <> Pziel.x + 1) and (p1.y <> Pziel.y - 1)
                    and LaufLinieIstfrei) do
                      begin
			                p1.x := p1.x-1;
			                p1.y := p1.y+1;
                      if (Brett[p1.x,p1.y] <> nil)
                        then LauflinieIstFrei := false;
                      end;
                  end;

      3:          begin
                    while ((p1.x <> Pziel.x - 1) and (p1.y <> Pziel.y + 1)
                    and LaufLinieIstfrei) do
                      begin
			                p1.x := p1.x+1;
			                p1.y := p1.y-1;
                      if (Brett[p1.x,p1.y] <> nil)
                        then LauflinieIstFrei := false;
                      end;
                  end;
                  
      4:          begin
                    while ((p1.x <> Pziel.x + 1) and (p1.y <> Pziel.y + 1)
                    and LaufLinieIstfrei) do
                      begin
			                p1.x := p1.x-1;
			                p1.y := p1.y-1;
                      if (Brett[p1.x,p1.y] <> nil)
                        then LauflinieIstFrei := false;
                      end;
                  end;
      end;
    end;
  Result := PAufLauflinie and LauflinieIstFrei;
  end;
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
end.
