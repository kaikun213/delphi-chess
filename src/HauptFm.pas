unit hauptfm;

interface

  uses
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
    Dialogs, ExtCtrls, StdCtrls, ImgList, Spin, uSchach;
//------------------------------------------------------------------------------
  type
    TForm1 = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    SchachCanvas: TPaintBox;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    Panel7: TPanel;
    Panel8: TPanel;
    Panel9: TPanel;
    Panel10: TPanel;
    Panel11: TPanel;
    Panel12: TPanel;
    Panel13: TPanel;
    Panel14: TPanel;
    Panel15: TPanel;
    Panel16: TPanel;
    Panel17: TPanel;
    Panel18: TPanel;
    Panel19: TPanel;
    Panel20: TPanel;
    Panel21: TPanel;
    Panel22: TPanel;
    Panel23: TPanel;
    Panel24: TPanel;
    Panel25: TPanel;
    Panel26: TPanel;
    Panel27: TPanel;
    Panel28: TPanel;
    Panel29: TPanel;
    Panel30: TPanel;
    Panel31: TPanel;
    Panel32: TPanel;
    Panel33: TPanel;
    Panel34: TPanel;
    Panel35: TPanel;
    Panel36: TPanel;
    Panel37: TPanel;
    Panel38: TPanel;
    Panel39: TPanel;
    Panel40: TPanel;
    Panel41: TPanel;
    Panel42: TPanel;
    ImageList1: TImageList;
    TiefeSE: TSpinEdit;
    IchbinRG: TRadioGroup;
    ZurueckButton: TButton;
    FenEingabeEd: TEdit;
    FenBu: TButton;
    BoardFu: TButton;
    Edit1: TEdit;
    ResetBu: TButton;
    MaxStartButton: TButton;
    NetzwerkButton: TButton;
    MinSpieltRG: TRadioGroup;
    Memo1: TMemo;
    AbbrechenButton: TButton;
    procedure SchachCanvasPaint(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SchachCanvasMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure ZurueckButtonClick(Sender: TObject);
    procedure FenBuClick(Sender: TObject);
    procedure BoardFuClick(Sender: TObject);
    procedure ResetBuClick(Sender: TObject);
    procedure IchbinRGClick(Sender: TObject);
    procedure MaxStartButtonClick(Sender: TObject);
    procedure NetzwerkButtonClick(Sender: TObject);
    procedure MinSpieltRGClick(Sender: TObject);
    procedure AbbrechenButtonClick(Sender: TObject);
    private
      procedure BrettZeichnen;
    end;
//------------------------------------------------------------------------------
  var
    Form1: TForm1;
    History:String;
    Abbrechen,Inprogress:Boolean;

procedure MinZiehtMaxZieht(sPos,fPos:TPosition; var MaxZug:TZug);
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
implementation
{$R *.dfm}

  uses uFen, uABVerfahren,uBenJak, NetzwerkFm;
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
procedure TForm1.BrettZeichnen;
var l, h, brettL, feldL, z, r: Integer;
    brettR: TRect;
    feldR: TRect;
    farbehell, farbedunkel, farbe1, farbe2, farbez: TColor;
begin
l := Form1.SchachCanvas.width;
h := Form1.SchachCanvas.height;
farbehell:= clInfobk;
farbedunkel:= clMaroon;

if l > h then brettl:= h else //Brett immer Rechteckig
  brettl:= l;                                   {wird nicht benutzt}

feldL := brettL div 8;
brettL := feldL * 8; //Anpassen des Bretts

setrect(BrettR,0,0,brettL,brettL); //Schachbrett Umrandung
Form1.SchachCanvas.Canvas.Pen.Color:=clBlack;
Form1.SchachCanvas.Canvas.Rectangle(BrettR);

farbe1:= farbehell;
farbe2:= farbedunkel;
setrect(feldR,0,0,feldL,feldL); //Felder
for z:=1 to 8 do
  begin
    for r:= 1 to 8 do
      begin
        if (r mod 2) > 0 then //Farbwechsel
          farbez := farbe1 else
          farbez := farbe2;
        Form1.SchachCanvas.Canvas.Brush.Color:=farbez;
        Form1.SchachCanvas.Canvas.Rectangle(feldR);
        feldR.Left:=feldR.Right;
        feldR.Right:=feldR.Left+feldL;
        //hier Koordinaten merken
      end;
    if farbe1 = farbehell then // Farbtausch
      begin
        farbe1:=farbedunkel;
        farbe2:=farbehell;
      end else
      begin
        farbe1:=farbehell;
        farbe2:=farbedunkel;
      end;
    feldR.Left:=0;
    feldR.Right:=feldL;
    feldR.Top:=feldR.Bottom;
    feldR.Bottom:=feldR.Top+feldL;
  end;

  for z:=1 to 8 do
    begin
      for r:= 1 to 8 do
        begin
          if Brett[z,r] <> nil then
            begin
              Form1.ImageList1.Draw(Form1.SchachCanvas.Canvas, (z-1)*feldL,(8 - r)*feldL,
                              Integer(Brett[z,r].Typ) * 2 + Integer(Gegenfarbe(Brett[z,r].Farbe)));
            end;
        end;
     end;


end;

procedure TForm1.FormShow(Sender: TObject);
begin
 //Form2.Show;
end;

procedure TForm1.SchachCanvasPaint(Sender: TObject);
begin
  BrettZeichnen;
end;

procedure TForm1.SchachCanvasMouseDown(Sender: TObject; Button: TMouseButton;
                                       Shift: TShiftState; X, Y: Integer);
var fPos : TPosition;
    MaxZug : TZug;
begin
  if Inprogress then exit;
  fPos.x := X div 80 + 1;
  fPos.y := 9 - (Y div 80 + 1);

  if startPos.x = 0 then
  begin
     if Brett[fPos.x, fPos.y] <> nil then startPos := fPos;
  end else
  begin
   History:=FenFromBoard;
   if (Min = Brett[startPos.x, startPos.y].Farbe) and
 	     Brett[startPos.x, startPos.y].KannZiehen(fPos,true) then
         MinZiehtMaxZieht(startPos,fPos,MaxZug);

   startPos.x := 0;
   startPos.y := 0;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
 if IchbinRG.ItemIndex = 0 then Min := Weiss else Min := Schwarz;
 Max := Gegenfarbe(Min);
 Spieler := Weiss;
 BoardFromFEN('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1');
 Abbrechen:=false;
end;

procedure TForm1.ZurueckButtonClick(Sender: TObject);
begin
 if History<>'' then
  BoardFromFen(History);
 BrettZeichnen;
end;

procedure TForm1.FenBuClick(Sender: TObject);
begin
 BoardFromFen(FenEingabeEd.Text);
 BrettZeichnen;
 History:=FenEingabeEd.Text;
end;

procedure TForm1.BoardFuClick(Sender: TObject);
begin
 Edit1.Text := FenFromBoard;
end;

procedure TForm1.ResetBuClick(Sender: TObject);
begin
 BoardFromFen('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq -');
 BrettZeichnen;
 gameOver:=false;
 Abbrechen:=false;
end;

procedure TForm1.IchbinRGClick(Sender: TObject);
begin
if IchbinRG.ItemIndex = 0 then Min := Weiss else Min := Schwarz;
 Max := Gegenfarbe(Min);
end;


procedure TForm1.MaxStartButtonClick(Sender: TObject);
var MaxZug,MinZug : TZug;
    Tiefe : Integer;
    istPatt, more:Boolean;
    winner:TFarbe;
begin
 Abbrechen:=false;
 if Max = schwarz then exit;                          {nur Weiß kann starten}
 winner:=weiss;  {damit Delphi nicht meckert}

 more:=true;
 while more do
  begin
    Tiefe:=TiefeSE.Value;
    MaxWertAB(Tiefe,worst-1,best+1,MaxZug);  {als Prozedur aufrufen}
    Execute(MaxZug);
    BrettZeichnen;
    Memo1.Lines.Add('weiß:'+MaxZug);


    gameOver:=IstMatt(Min, istPatt) or istPatt;
    if gameOver and not istPatt then winner := Max;

    if not gameOver and (MinSpieltRG.ItemIndex>0) then {Min wird von remote gespielt}
      with NetzwerkFormular do
        begin
         IdTCPClient.WriteLn(MaxZug);     {Max-Zug an Remote-Server (schwarz) schicken}

         MinZug:=IdTCPClient.ReadLn;      {Antwortzug lesen}
         Memo1.Lines.Add('schwarz:'+MinZug);
         Execute(MinZug);

         gameOver:=IstMatt(Max, istPatt) or istPatt;
         if gameOver and not istPatt then winner := Min;
         more:=not gameOver;
        end
        else more:=false;
  end;

 if istPatt then ShowMessage('Es ist ein Patt!') else
  if gameOver then ShowMessage(ColToStr(winner) + ' gewinnt!');
end;


procedure TForm1.NetzwerkButtonClick(Sender: TObject);
begin
 NetzwerkFormular.Show;
end;


procedure TForm1.MinSpieltRGClick(Sender: TObject);
var OK:Boolean;
begin
 if MinSPieltRG.ItemIndex>0 then {Min soll von remote gespielt werden}

  with  NetzwerkFormular do
   begin
    OK:=(Min=schwarz) and ClientConnected or
        (Max=schwarz) and ServerRunning;
    if not OK then
     begin
      ShowMessage('Nicht mit Remote verbunden. Farben komplementär?');
//      MinSpieltRG.ItemIndex:=0;
     end;
   end;  
end;


{****************************************************************************}

procedure MinZiehtMaxZieht(sPos,fPos:TPosition; var MaxZug:TZug);
var istPatt:Boolean;
    winner:TFarbe;
    Tiefe:Integer;
begin
   Inprogress:= true;
   Brett[sPos.x, sPos.y].MoveTo(fPos);   {Min zieht von sPos nach fPos}
   Form1.BrettZeichnen;

   winner:=weiss;                       {damit Delphi nicht meckert}  
   gameOver:=IstMatt(Max, istPatt) or istPatt;
   if gameOver and not istPatt then winner := Min;

   if not gameOver then
    begin
     Tiefe:=Form1.TiefeSE.Value;
     MaxWertAB(Tiefe,worst-1,best+1,MaxZug);   {als Prozedur aufrufen}
     Execute(MaxZug);
     Form1.BrettZeichnen;

     gameOver:=IstMatt(Min, istPatt) or istPatt;
     if gameOver and not istPatt then winner := Max;
    end;

   if gameOver then
    begin
     if istPatt then  ShowMessage('Es ist ein Patt!')
     else ShowMessage(ColToStr(winner) + ' gewinnt!');
    end;
    Inprogress:=false;
end;


procedure TForm1.AbbrechenButtonClick(Sender: TObject);
begin
 Abbrechen:=true;
end;

end.
