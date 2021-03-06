unit uFEN;

interface
uses SysUtils, StrUtils, uSchach,uBauern,uSpringer,uLaeufer,uTurm,uDame,uKoenig;

function FENFromBoard : string;
procedure BoardFromFEN(_fen : String);
function TypToStr(_typ : TTyp) : string;
function StrFromColumn(_i:Integer):string;
function ColumnFromString(_s :char):Integer;

implementation

function TypToStr(_typ : TTyp) : string;
begin
  case _typ of
    Bauer: Result:='p';
    Laeufer: Result:='b';
    Springer: Result:='n';
    Turm: Result:='r';
    Dame: Result:='q';
    Koenig: Result:='k';
  end;
end;

function StrToTyp(_s : char) : TTyp;
begin
  Result:=Bauer;
 { case _s of                   f�r alle Gro�buchstaben war Result=Bauer!
    'p': Result:=Bauer;
    'b': Result:=Laeufer;
    'n': Result:=Springer;
    'r': Result:=Turm;
    'q': Result:=Dame;
    'k': Result:=Koenig;
  end; }

  case _s of
    'p','P': Result:=Bauer;
    'b','B': Result:=Laeufer;
    'n','N': Result:=Springer;
    'r','R': Result:=Turm;
    'q','Q': Result:=Dame;
    'k','K': Result:=Koenig;
  end;

end;

function StrFromColumn(_i:Integer):string;  {umst�ndlich!}
begin
  case _i of
    1: Result:='a';
    2: Result:='b';
    3: Result:='c';
    4: Result:='d';
    5: Result:='e';
    6: Result:='f';
    7: Result:='g';
    8: Result:='h';
  end;
end;

{Carlos}
function ColumnFromString(_s :char):Integer;   {dto.}
begin
 Result:=0;
  case _s of
    'a': Result:=1;
    'b': Result:=2;
    'c': Result:=3;
    'd': Result:=4;
    'e': Result:=5;
    'f': Result:=6;
    'g': Result:=7;
    'h': Result:=8;
  end;
end;


function FENFromBoard : string;
var s : String;
    x,y, emptyCount : Integer;
begin
  s := '';
  emptyCount:= 0;
  for y:=8 downto 1 do                     { for y:= 1 to 8 do: anders herum!}
  begin
    for x:= 1 to 8 do
    begin
      if Brett[x,y] <> nil then
      begin
        if emptyCount > 0 then s := s + IntToStr(emptyCount);
        emptyCount := 0;
        {s := s + TypToStr(Brett[x,y].Typ);  TypToStr lieferte nur Kleinbuchstaben}
        if Brett[x,y].Farbe=schwarz then s:=s+TypToStr(Brett[x,y].Typ)
                                    else s:=s+UpCase(TypToStr(Brett[x,y].Typ)[1]);
      end                                   {f�r Farbe=weiss: Gro�buchstaben!}
      else inc(emptyCount);
    end;
    if emptyCount > 0 then s := s + IntToStr(emptyCount);
    emptyCount := 0;
    s:=s+'/'
  end;
  SetLength(s, Length(s)-1);
  s:=s+' ';
  if spieler = weiss then s:= s + 'w '
  else s:= s + 'b ';

  if rochadeWK then  s:= s + 'K';
  if rochadeWQ then  s:= s + 'Q';
  if rochadeSK then  s:= s + 'k';
  if rochadeSQ then  s:= s + 'q';

  if not (rochadeWK or rochadeWQ or rochadeSK or rochadeSQ) then s:= s + '-';

  s:= s + ' ';

  if not ((enpassantPos.x = 0) or (enpassantPos.y= 0)) then
    s:= s + StrFromColumn(enpassantPos.x)+ IntToStr(enpassantPos.y)
  else s:= s+'-';

  Result := s;
end;

procedure BoardFromFEN(_fen : String);
{darf nicht von Methoden von Schachfiguren aufgerufen werden, da diese hier
 zerst�rt und neu erzeugt werden werden}
var y, x, emptyCount, i, j : Integer;
    sub : string;
    F:TSchachFigur;
    C:TFarbe;
    T:TTyp;
begin
  for C:=schwarz to weiss do
   for T:=Bauer to Koenig do
    AnzahlFiguren[C,T]:=0;

  for x:=1 to 8 do
   for y:=1 to 8 do
    begin
     if Brett[x,y]<>nil then Brett[x,y].Destroy;
     Brett[x,y]:=nil;
    end;
      
  i:= 1;
  {for y := 1 to 8 do    : wenn y die Schachzeilen sind: anders herum! vgl. FEN}
  for y:=8 downto 1 do
  begin
    x := 1;
    while (_fen[i] <> '/') and (_fen[i]<>' ') do
    begin
      if TryStrToInt(_fen[i], emptyCount) then
      begin
        for j:= 1 to emptyCount do
        begin
          Brett[x,y] := nil;
          inc(x);
        end;
      end
      else
      begin
      (*
        Brett[x,y] := TSchachfigur.Create;       {muss aus richtiger Klasse erzeugen: TBauer...}
        Brett[x,y].Position.x := x;
        Brett[x,y].Position.y := y;
        Brett[x,y].Typ := StrToTyp(_fen[i]);     {Typ setzen gen�gt nicht}
                                                 {Farbe fehlt}
       *)
        case _fen[i] of
          'p','P': F:=TBauer.Create;
          'b','B': F:=TLaeufer.Create;
          'n','N': F:=TSpringer.Create;
          'r','R': F:=TTurm.Create;
          'q','Q': F:=TDame.Create;
          'k','K': F:=TKoenig.Create;
          else F:=nil;
        end;
       F.Position.x:=x;
       F.Position.y:=y;
       if ord(_fen[i])>90    then F.Farbe:=schwarz
                             else F.Farbe:=weiss;
       Brett[x,y]:=F;

       inc(AnzahlFiguren[F.Farbe,F.Typ]);
       if F.Typ=Koenig then KoenigsPosition[F.Farbe]:=F.Position;


       inc(x);
      end;
      inc(i);
    end;
    inc(i);
  end;
  inc(i);
  if _fen[i] = 'b' then
    spieler := schwarz
  else
    spieler := weiss;
  i:= i+1;

  sub:='';

  while _fen[i] <> ' ' do
  begin
    sub := sub + _fen[i];
    inc(i);
  end;
  rochadeWK := AnsiContainsStr(sub, 'K');
  rochadeWQ := AnsiContainsStr(sub, 'Q');
  rochadeSK := AnsiContainsStr(sub, 'k');
  rochadeSQ := AnsiContainsStr(sub, 'q');
  inc(i);
  if _fen[i] = '-' then enpassantPos.x := 0
  else
  begin
    enpassantPos.x:= ColumnFromString(_fen[i]);
    inc(i);
    enpassantPos.y:= StrToInt(_fen[i]);
  end;
end;

end.
 