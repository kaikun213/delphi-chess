unit uBenJak;

interface uses uSchach,HauptFM,Classes;

type
 TDeckungsZaehler = Array[1..16] of Integer;

const worst = -1000000;
      best  = 1000000;
      Figurenwerte : Array[Bauer..Dame] of Integer = (100,325,275,475,900);


function Heuristik:Integer;

implementation

function DeckungsListeVon(Farbe:TFarbe):TStringList;
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
     begin
      F.Farbe:=Gegenfarbe(F.Farbe);
      F.AppendZugListe(L);
      F.Farbe:=Gegenfarbe(F.Farbe);
     end;
   end;
 Result:=L;
end;



// MAX UND MIN M�GLICHERWEISE NOCH VERTAUSCHT!! TESTEN
function Heuristik:Integer;
var kn,kn1,n,n1,k,k1,x,y,MaxFigurenPunkte,MinFigurenPunkte,ZugPunkteMax,ZugPunkteMin,DeckungsPunkte,ExtraPunkte,GesamtPunkte:Integer;
    L,L1,DeckungsListeMax,DeckungsListeMin:TStringList;
    ZugMax,ZugMin:TZug;
    H,P,P1,B,B1:TPosition;
    DeckungsPunkteMin,DeckungsPunkteMax:TDeckungsZaehler;
begin
  MaxFigurenPunkte:=0;
  MinFigurenPunkte:=0;
  GesamtPunkte:=0;
  ZugPunkteMax:=0;
  ZugPunkteMin:=0;
  DeckungsPunkte:=0;

{******************************* FigurenPunkte von Min/Max zum abziehen/dazukommen **********************************}
 for x:=1 to 8 do
  for y:=1 to 8 do
   begin
    if (Brett[x,y]<>nil) and (Brett[x,y].Farbe=Max) then
     begin
        if Brett[x,y].Typ = Bauer then MaxFigurenPunkte:=MaxFigurenPunkte+Figurenwerte[Bauer];
        if Brett[x,y].Typ = Laeufer then MaxFigurenPunkte:=MaxFigurenPunkte+Figurenwerte[Laeufer];
        if Brett[x,y].Typ = Springer then MaxFigurenPunkte:=MaxFigurenPunkte+Figurenwerte[Springer];
        if Brett[x,y].Typ = Turm then MaxFigurenPunkte:=MaxFigurenPunkte+Figurenwerte[Turm];
        if Brett[x,y].Typ = Dame then MaxFigurenPunkte:=MaxFigurenPunkte+Figurenwerte[Dame]
     end

    else
    if (Brett[x,y]<>nil) and (Brett[x,y].Farbe=Min) then
     begin
        if Brett[x,y].Typ = Bauer then MinFigurenPunkte:=MinFigurenPunkte+Figurenwerte[Bauer];
        if Brett[x,y].Typ = Laeufer then MinFigurenPunkte:=MinFigurenPunkte+Figurenwerte[Laeufer];
        if Brett[x,y].Typ = Springer then MinFigurenPunkte:=MinFigurenPunkte+Figurenwerte[Springer];
        if Brett[x,y].Typ = Turm then MinFigurenPunkte:=MinFigurenPunkte+Figurenwerte[Turm];
        if Brett[x,y].Typ = Dame then MinFigurenPunkte:=MinFigurenPunkte+Figurenwerte[Dame]
     end;
   end;
   // Minpunkte abziehen (!) Und beides noch in GesamtPunkte einbauen

{******************************* ZugPunkte & DeckungsPunkte von Max die dazu kommen **********************************}
  L:=ZugListeVon(Max);
  L1:=ZugListeVon(Min);
  n:=0;
  ZugPunkteMax:=ZugPunkteMax + (L.Count*5);
   for k:=1 to L.Count do
   begin
   ZugMax:=L[k-1];
   P:=StrToPos(ZugMax[4]+ZugMax[5]);
   B:=StrToPos(ZugMax[1]+ZugMax[2]);
 //   if ((Brett[B.x,B.y]<>nil) and (Brett[B.x,B.y].Farbe=Max) and (Brett[B.x,B.y].Typ=Bauer)) and ((P.y=1) or (P.y=8)) then ExtraPunkte:=ExtraPunkte+50 else
 //   if ((Brett[B.x,B.y]<>nil) and (Brett[B.x,B.y].Farbe=Max) and (Brett[B.x,B.y].Typ=Bauer)) and ((P.y=2) or (P.y=7)) then ExtraPunkte:=ExtraPunkte+10 else  // Bauer kurz vor Damenverwandlung Punkte!
    if (Brett[P.x,P.y]<>nil) and (Brett[P.x,P.y].Farbe=Min) then
     begin
     n:=n+1;  //Z�hlervariable f�r n�chste Figur (Anzahl Deckungen einer schlagbaren Figur)
     ZugPunkteMax:=ZugPunkteMax +  15;
     DeckungsListeMin:=DeckungsListeVon(Min);
     for k1:=1 to DeckungsListeMin.Count do     // (L1)
      begin
       ZugMin:=DeckungsListeMin[k1-1];
       H:= StrToPos(ZugMin[4]+ZugMin[5]);
       if (H.x = P.x) and (H.y = P.y) then DeckungsPunkteMin[n]:=DeckungsPunkteMin[n]+1 //{DeckungsPunkte:= DeckungsPunkte-50} direkt GEDECKT (DIE GEGNERFIGUR welche sonst geschlagen werden k�nnte)
       else if (Brett[H.x,H.y]<>nil) and (Brett[H.x,H.y].Farbe=Min)// Farbe gleich (Ist nur n�tig wenn DeckungsListe auch Freie/Gegner Felder nimmt)
        then DeckungsPunkte:= DeckungsPunkte-3;
      end;

    end;
   end;

{******************************* ZugPunkte & DeckungsPunkte von Min die abgezogen werden **********************************}
   n1:=0;
   ZugPunkteMin:=ZugPunkteMin + (L1.Count*3);
    for k:=1 to L1.Count do
   begin
   ZugMin:=L1[k-1];
   P1:=StrToPos(ZugMin[4]+ZugMin[5]);
   B1:=StrToPos(ZugMin[1]+ZugMin[2]);
 //   if ((Brett[B1.x,B1.y]<>nil) and (Brett[B1.x,B1.y].Farbe=Max) and (Brett[B1.x,B1.y].Typ=Bauer)) and ((P1.y=1) or (P1.y=8)) then ExtraPunkte:=ExtraPunkte-50 else
 //   if ((Brett[B1.x,B1.y]<>nil) and (Brett[B1.x,B1.y].Farbe=Max) and (Brett[B1.x,B1.y].Typ=Bauer)) and ((P1.y=2) or (P1.y=7)) then ExtraPunkte:=ExtraPunkte-25 else  // Bauer kurz vor Damenverwandlung Punkte!
    if (Brett[P1.x,P1.y]<>nil) and (Brett[P1.x,P1.y].Farbe=Max) then
    begin
    n1:=n1+1;      //Gleiches Prinzip nur Umgekehrt: Z�hlervariable f�r n�chste Figur (Anzahl Deckungen einer schlagbaren Figur)
    ZugPunkteMin:=ZugPunkteMin + 25;
    DeckungsListeMax:=DeckungsListeVon(Max);
    for k1:=1 to DeckungsListeMax.Count do
      begin
       ZugMax:=DeckungsListeMax[k1-1];
       H:= StrToPos(ZugMax[4]+ZugMax[5]);
       if (H.x = P1.x) and (H.y = P1.y) then DeckungsPunkteMax[n1]:=DeckungsPunkteMax[n1]+1 // direktes DECKEN ( Figur die geschlagen werden k�nnte sonst)
        else if (Brett[H.x,H.y]<>nil) and (Brett[H.x,H.y].Farbe=Max)// Farbe gleich (Ist nur n�tig wenn DeckungsListe auch Freie/Gegner Felder nimmt)
        then DeckungsPunkte:= DeckungsPunkte+5;
      end;

    end;
   end;

{******************************* DeckungsPunkte welche geschlagen werden k�nnen **********************************}
  for kn:=1 to n do
   begin
   if DeckungsPunkteMin[kn]=0 then DeckungsPunkte:=DeckungsPunkte+45 else // Punkte die dazukommen wenn eine Figur die Max schlagen kann gar nicht gedeckt ist (sehr gut)
      DeckungsPunkte:= DeckungsPunkte - round((DeckungsPunkteMin[kn]*1.5) *10);   //Statt 1.5 w�re ^1.5 besser hier .. Optimieren <<<
   end;

     for kn1:=1 to n1 do
   begin
   if DeckungsPunkteMin[kn1]=0 then DeckungsPunkte:=DeckungsPunkte-75 else // Punkte die abgezogen werden wenn eine Figur von Max die von min geschlagen werden kann ungedeckt ist (sehr schlecht)
    DeckungsPunkte:= DeckungsPunkte + round((DeckungsPunkteMax[kn1]*1.75) *12);   //Statt 1.5 w�re ^1.5 besser hier .. Optimieren <<<
   end;

{******************************* ExtraPunkte: z.B. K�nigsPosition,imSchach,Rochaderechte,Bauernrechte,kurzvor Dameverwandelung(schon oben) (...) **********************************}
 if ImSchach(Max) then ExtraPunkte:=ExtraPunkte-30 else
  if ImSchach(Min) then ExtraPunkte:=ExtraPunkte+30;

GesamtPunkte:= GesamtPunkte + MaxFigurenPunkte - MinFigurenPunkte + ZugPunkteMax - ZugPunkteMin + DeckungsPunkte + ExtraPunkte;

Result:=GesamtPunkte;

end;

end.
