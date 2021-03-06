unit uABVerfahren;

interface
 uses uSchach, uBenJak, uFen, Classes, Forms, HauptFm,SysUtils;

function MaxWertAB(Tiefe,a,b:Integer; var MaxZug:TZug): Integer;
function MinWertAB(Tiefe,a,b:Integer): Integer;

implementation

function MaxWertAB(Tiefe,a,b:Integer; var MaxZug:TZug): Integer;
var IstPatt, More:Boolean;
    ZugListe:TStringList;
    k,w:Integer;
    Zug:TZug;
    Fen:String;
begin
 Application.ProcessMessages;
 if Abbrechen then
   raise Exception.Create('Abbruch!');

 MaxZug:='';
 Result:= worst-1; {schlechter als alles M�gliche}
 if IstMatt(Max,IstPatt) then Result:=a else
 if IstMatt(Min,IstPatt) then Result:=b else
 if IstPatt then Result:=0 else
 if Tiefe = 0 then begin
                   Result:=Heuristik;
                   if Result < a then Result:=a else
                   if Result > b then Result:=b
                   end else
  begin
  ZugListe:=ZugListeVon(Max);  {Deklariert in uSchach als Computer}
   k:=1;
   More:=(k<=Zugliste.Count);
   while More do
   begin
   Zug:=ZugListe[k-1];   {k-ter Zug}
    Fen:=FenfromBoard;   {Zustand sicher}
    Execute(Zug);
    w:=MinWertAB(Tiefe-1,a,b);
    if w > Result then
     begin
     a:=w;
     MaxZug:=Zug;
     Result:=w;
     end;
    BoardfromFen(Fen);   {Zustand wiederherstellen}
    if Result=b then More:=false ; {Abbrechen der Z�hlschleife/Abschneiden}
    k:=k+1;
    More:= More and (k<=Zugliste.Count);
   end;
   Zugliste.Destroy;
  end;
end;

function MinWertAB(Tiefe,a,b:Integer): Integer;
var IstPatt, More:Boolean;
    ZugListe:TStringList;
    k,w:Integer;
    Zug,Dummy:TZug;
    Fen:String;
begin
 Result:= best+1; {schlechter als alles M�gliche}
 if IstMatt(Max,IstPatt) then Result:=a else
 if IstMatt(Min,IstPatt) then Result:=b else
 if IstPatt then Result:=0 else
 if Tiefe = 0 then begin
                   Result:=Heuristik;
                   if Result < a then Result:=a else
                   if Result > b then Result:=b
                   end else
  begin
  ZugListe:=ZugListeVon(Min);  {Deklariert in uSchach als Computer}
   k:=1;
   More:=(k<=Zugliste.Count);
   while More do
   begin
   Zug:=ZugListe[k-1];   {k-ter Zug}
    Fen:=FenfromBoard;   {Zustand sicher}
    Execute(Zug);
    w:=MaxWertAB(Tiefe-1,a,b,Dummy);
    if w < Result then
     begin
     b:=w;
     Result:=w;
     end;
    BoardfromFen(Fen);   {Zustand wiederherstellen}
    if Result=a then More:=false ; {Abbrechen der Z�hlschleife/Abschneiden}
    k:=k+1;
    More:= More and (k<=Zugliste.Count);
   end;
   Zugliste.Destroy;
  end;
end;




end.
