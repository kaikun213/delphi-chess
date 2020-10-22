unit uHeuristik;

interface

const worst = -1000;
      best  = 1000;

function Heuristik:Integer;

implementation
uses uSchach;

function Heuristik:Integer;
var x,y,MaxZ,MinZ:Integer;
begin
 MaxZ:=0;
 MinZ:=0;
 for x:=1 to 8 do
  for y:=1 to 8 do
   begin
    if (Brett[x,y]<>nil) and (Brett[x,y].Farbe=Max) then MaxZ:=MaxZ+1
     else if (Brett[x,y]<>nil) and (Brett[x,y].Farbe=Min) then MinZ:=MinZ+1;
   end;
 if ImSchach(Max) then Result:=-10 else
  if ImSchach(Min) then Result:=10;
Result:=Result+(MaxZ-MinZ);
end;


end.



