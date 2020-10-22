unit uBauern;
interface
 uses uSchach, uDame, Classes;

type
 
 TBauer = class(TSchachFigur)
            constructor Create;
            function KannZiehen(P:TPosition;  MitSP:Boolean):Boolean; override;
            procedure MoveTo(P:TPosition); override;
            procedure WirdDame;
            procedure AppendZugListe(var L:TStringList); override;
           end;


implementation

const ddxyBauer: Array[1..4] of TPosition =
                                   ((x:0;y:1),(x:0;y:2),(x:-1;y:1),(x:1;y:1));
                                   {Alle 4 Positionen die ein Bauer ziehen kann}

constructor TBauer.Create;
begin
 inherited Create;
 Typ:=Bauer;
end;

procedure TBauer.MoveTo(P:TPosition);
var deltaY:Integer;
    T:TTyp;
    F:TFarbe;
    P0:TPosition;
begin
 if Farbe = weiss then deltaY:=1
                  else deltaY:=-1;

 if (P.x=enpassantPos.x) and (P.y=enpassantPos.y) then {enpassant-Zug}
  begin                       {seitlich statt normal schlagen}
     T:=Bauer;
     F:=GegenFarbe(Farbe);
     Dec(AnzahlFiguren[F,T]);
     Brett[P.x,Position.y].Destroy;
     Brett[P.x,Position.y]:=nil;
    end;

 P0:=Position;
 inherited MoveTo(P);  {löscht enpassantPos}

 if (P0.x=P.x) and (P0.y+2*deltaY=P.y) then {Doppelzug}
  begin
   enpassantPos.x:=P0.x;              {übersprungenes Feld}
   enpassantPos.y:=P0.y+1*deltaY;
  end;

 WirdDame;
end;

procedure TBauer.WirdDame ;
var  Dame1:TDame;
     F:TFarbe;
     P:TPosition;
begin
 P:=Position;               {sichern}
 F:=Farbe;

 if ((farbe=schwarz) and (Position.y = 1)) or
    ((farbe=weiss) and (Position.y = 8)) then
  begin
   Dame1:=TDame.Create;
   Dame1.Position:=P;
   Dame1.Farbe:=F;

//   destroy;                             {Speicherleck?}
   brett[P.x,P.y]:=Dame1;                 {jetzt sind Position und Farbe weg!}
   Dec(AnzahlFiguren[F,Bauer]);
   Inc(AnzahlFiguren[F,Dame]);
  end;
end;


function TBauer.KannZiehen(P:TPosition;MitSP:Boolean):Boolean;
var PImBrett, PIstFrei, PIstDavor, PIstZweiDavor, EnPassant,
    PIstSchraegDavor, AufGrundlinie, PIstFeind :Boolean;
    deltaY:Integer;          {Zugrichtung}
begin
 PImBrett:=(1<=P.x) and (P.x<=8) and (1<=P.y) and (P.y<=8);
 PIstFrei:=(Brett[P.x,P.y]=nil);
 if Farbe = weiss then deltaY:=1
                  else deltaY:=-1;
 PIstDavor:=(P.x=Position.x) and (P.y=Position.y+deltaY);
 PIstZweiDavor:=(P.x=Position.x) and
                (Brett[P.x,Position.y+1*deltaY]=nil) and
                (P.y=Position.y+2*deltaY);
                
 PIstSchraegDavor:=((P.x=Position.x+1) or (P.x=Position.x-1))
                     and  (P.y=Position.y+deltaY);
 AufGrundlinie:=(Farbe=weiss) and (Position.y=2) or
                (Farbe=schwarz) and (Position.y=7);
 PIstFeind:=(Brett[P.x,P.y]<>nil) and (Farbe <> Brett[P.x,p.y].Farbe);

 EnPassant:= PIstSchraegDavor  and
            (P.x=enpassantPos.x) and (P.y=enpassantPos.y) and
            (Brett[P.x,Position.y]<>nil) and
            (Brett[P.x,Position.y].Farbe<>Farbe);

 Result:=PImBrett and (
         (PIstFrei and (PIstDavor or AufGrundlinie and PIstZweiDavor)) or
         (PIstFeind and PIstSchraegDavor) or
         EnPassant);
 if MitSP then Result:=Result and Schachprobe(P);

end;

procedure TBauer.AppendZugListe(var L:TStringList);
var P:TPosition;
    DeltaY,k:Integer;
begin
 if Farbe=weiss then DeltaY:=1
                else DeltaY:=-1;
 for k:=1 to 4 do
  begin
   P.x:=Position.x+ddxyBauer[k].x;
   P.y:=Position.y+ddxyBauer[k].y*DeltaY;
   if (1<=P.x) and (P.x<=8) and (1<=P.y) and (P.y<=8) and KannZiehen(P,true) then
        L.add(PosToStr(Position)+'-'+PosToStr(P)); {Muss optimiert werden}
  end;
end;

end.
