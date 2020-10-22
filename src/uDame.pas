unit uDame;
interface
uses uSchach,uTurm,ulaeufer;
type

  TDame = class(TSchachFigur)
            constructor Create;
            function KannZiehen(P:TPosition; MitSP:Boolean): Boolean; override;
            end;
implementation

constructor TDame.Create;
  begin
  inherited Create;
  Typ := Dame;
  end;



function TDame.Kannziehen(P:TPosition; MitSP:Boolean):Boolean;
var PImBrett,PIstFrei,PGeradeWegIstFrei,PDiagonalWegIstFrei:Boolean;
begin
 PImBrett:= (1<=p.x) and (P.x<=8) and (1<=p.y) and (P.y<=8);
 PIstFrei:= (Brett[P.x,P.y]<>nil) and (farbe <> (Brett[P.x,P.y].Farbe))
             or (Brett[P.x,P.y]=nil);                   {Bezeichner passt nicht}
 PGeradeWegIstFrei:= GradeIstFrei(Position,P);
 PDiagonalWegIstFrei:= KannZiehenSchraegeLauflinie(Position,P);

 Result:= PImBrett and
          (PIstFrei and PGeradeWegIstFrei) or       {PIstFrei ausklammern}
          (PIstFrei and PDiagonalWegIstFrei);
 if MitSP then Result:=Result and Schachprobe(P);
end;


end.
