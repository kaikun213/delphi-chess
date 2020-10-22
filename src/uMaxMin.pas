unit uMaxMin;

interface
 uses uSchach, uHeuristik, uFen, Classes;

function MaxWert(Tiefe:Integer; var MaxZug:TZug): Integer;
function MinWert(Tiefe:Integer): Integer;

implementation

function MaxWert(Tiefe:Integer; var MaxZug:TZug): Integer;
var IstPatt:Boolean;
    ZugListe:TStringList;
    k,w:Integer;
    Zug:TZug;
    Fen:String;
begin
 MaxZug:='';
 if IstMatt(Max,IstPatt) then Result:=worst else
 if IstMatt(Min,IstPatt) then Result:=best else
 if IstPatt then Result:=0 else
 if Tiefe = 0 then Result:=Heuristik else
  begin
  Result:= worst-1; {schlechter als alles Mögliche}
  ZugListe:=ZugListeVon(Max);  {Deklariert in uSchach als Computer}
  for k:=1 to ZugListe.Count do
   begin
   Zug:=ZugListe[k-1];   {k-ter Zug}
    Fen:=FenfromBoard;   {Zustand sicher}
    Execute(Zug);
    w:=MinWert(Tiefe-1);
    if w > Result then
     begin
     MaxZug:=Zug;
     Result:=w;
     end;
    BoardfromFen(Fen);   {Zustand wiederherstellen}
   end;
  end;
end;

function MinWert(Tiefe:Integer): Integer;
var IstPatt:Boolean;
    ZugListe:TStringList;
    k,w:Integer;
    Zug, Dummy:TZug;
    Fen:String;
begin
 if IstMatt(Max,IstPatt) then Result:=worst else
 if IstMatt(Min,IstPatt) then Result:=best else
 if IstPatt then Result:=0 else
 if Tiefe = 0 then Result:=Heuristik else
  begin
  Result:= best+1; {besser als alles Mögliche}
  ZugListe:=ZugListeVon(Min);  {Deklariert in uSchach als Computer}
  for k:=1 to ZugListe.Count do
   begin
   Zug:=ZugListe[k-1];   {k-ter Zug}
    Fen:=FenfromBoard;   {Zustand sicher}
    Execute(Zug);
    w:=MaxWert(Tiefe-1,Dummy);
    if w < Result then Result:=w;
    BoardfromFen(Fen);   {Zustand wiederherstellen}
   end;
  end;
end;


end.
