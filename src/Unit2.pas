unit Unit2;
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids;

type
  TForm2 = class(TForm)
    StringGrid1: TStringGrid;
    BrettZeichnenButton: TButton;
    Memo1: TMemo;
    FENFromBoardButton: TButton;
    BoardFromFENButton: TButton;
    BrettAktualisierenButton: TButton;
    KannZiehenButton: TButton;
    procedure BrettZeichnenButtonClick(Sender: TObject);
    procedure FENFromBoardButtonClick(Sender: TObject);
    procedure BoardFromFENButtonClick(Sender: TObject);
    procedure BrettAktualisierenButtonClick(Sender: TObject);
    procedure KannZiehenButtonClick(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var  Form2: TForm2;

implementation
{$R *.dfm}

uses uSchach, uFEN, uBauern, uSpringer, uLaeufer, uTurm, uDame, uKoenig;

procedure TForm2.BrettZeichnenButtonClick(Sender: TObject);
var x,y:Integer;
    c:Char;
    Typ:TTyp;
begin
 for y:=1 to 8 do
  for x:=1 to 8 do
    if Brett[x,y]<>nil then
       begin
        Typ:=Brett[x,y].Typ;
        c:=TypToStr(Typ)[1];
        if Brett[x,y].Farbe=weiss then c:=UpCase(c);
         StringGrid1.Cells[x-1,8-y]:=c;
       end else
       StringGrid1.Cells[x-1,8-y]:='';
end;

procedure TForm2.FENFromBoardButtonClick(Sender: TObject);
begin
 Memo1.Lines.Add(FENFromBoard);
end;

procedure TForm2.BoardFromFENButtonClick(Sender: TObject);
begin
 BoardFromFEN(Memo1.SelText);
end;

procedure TForm2.BrettAktualisierenButtonClick(Sender: TObject);
var x,y:Integer;
    s:String;
    F:TSchachFigur;
begin
 for y:=1 to 8 do
  for x:=1 to 8 do
   begin
    if Brett[x,y]<>nil then Brett[x,y].Destroy;
    s:=StringGrid1.cells[x-1,8-y];
    F:=nil;
    if s<>'' then
     begin
       case s[1] of
        'p','P': F:=TBauer.Create;
        'b','B': F:=TLaeufer.Create;
        'n','N': F:=TSpringer.Create;
        'r','R': F:=TTurm.Create;
        'q','Q': F:=TDame.Create;
        'k','K': F:=TKoenig.Create;
       end;
       F.Position.x:=x;
       F.Position.y:=y;
       if ord(s[1])>93    then F.Farbe:=schwarz
                          else F.Farbe:=weiss;
     end;
    Brett[x,y]:=F;
   end;

end;

procedure TForm2.KannZiehenButtonClick(Sender: TObject);
var x,y,x1,y1:Integer;
    F:TSchachFigur;
    P:TPosition;
    s:String;
begin
 x:=StringGrid1.Selection.Left+1;
 y:=8-StringGrid1.Selection.Top;
 F:=Brett[x,y];
 if F<>nil then
  begin
   s:=TypToStr(F.Typ);
   if F.Farbe=weiss then s:=UpCase(s[1]);
   Memo1.Lines.Add(s+' auf '+StrFromColumn(x)+IntToStr(y)+' kann ziehen nach:');
   for x1:=1 to 8 do
    for y1:=1 to 8 do
     begin
      P.x:=x1;
      P.y:=y1;
      if F.KannZiehen(P,true) then
          Memo1.Lines.add(StrFromColumn(x1)+IntToStr(y1));
     end;
  end

end;

end.
