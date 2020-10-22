unit DameHauptFm;
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids,ImgList, StdCtrls, ComCtrls,
  Dame, ZugListen, Spin, ExtCtrls, Menus, Sockets, CheckLst,
  IdTCPConnection, IdTCPClient, IdBaseComponent, IdComponent, IdTCPServer;

type
  THauptFormular = class(TForm)
    SpielFeldDG: TDrawGrid;
    FelderIL: TImageList;
    NeuButton: TButton;
    Memo1: TMemo;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    ZurueckButton: TButton;
    PageControl1: TPageControl;
    ZugListeTS: TTabSheet;
    Label15: TLabel;
    PosEdit: TEdit;
    Label18: TLabel;
    FarbeEdit: TEdit;
    LokaleZugListeButton: TButton;
    TestTS: TTabSheet;
    ZeigeTestFeldButton: TButton;
    ZuTestenCB: TComboBox;
    Label19: TLabel;
    TestDurchfuehrenButton: TButton;
    GlobaleZugListeButton: TButton;
    MaxZiehtButton: TButton;
    TiefeSE: TSpinEdit;
    MaxSpieltRG: TRadioGroup;
    Label20: TLabel;
    CheatButton: TButton;
    TestFeldCB: TComboBox;
    MainMenu1: TMainMenu;
    Datei1: TMenuItem;
    Spielstandspeichern1: TMenuItem;
    Spielstandladen1: TMenuItem;
    SaveDialog1: TSaveDialog;
    OpenDialog1: TOpenDialog;
    StatusBar: TStatusBar;
    Netzwerk1: TMenuItem;
    MinSpieltRG: TRadioGroup;
    AbbrechenButton: TButton;
    procedure SpielFeldDGDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure FormCreate(Sender: TObject);
    procedure SpielFeldDGDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure SpielFeldDGDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure NeuButtonClick(Sender: TObject);
    procedure LokaleZugListeButtonClick(Sender: TObject);
    procedure SpielFeldDGEndDrag(Sender, Target: TObject; X, Y: Integer);
    procedure ZurueckButtonClick(Sender: TObject);
    procedure ZeigeTestFeldButtonClick(Sender: TObject);
    procedure TestDurchfuehrenButtonClick(Sender: TObject);
    procedure GlobaleZugListeButtonClick(Sender: TObject);
    procedure MaxZiehtButtonClick(Sender: TObject);
    procedure CheatButtonClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Spielstandspeichern1Click(Sender: TObject);
    procedure Spielstandladen1Click(Sender: TObject);
    procedure Netzwerk1Click(Sender: TObject);
    procedure MinSpieltRGClick(Sender: TObject);
    procedure AbbrechenButtonClick(Sender: TObject);
   end;

var  HauptFormular: THauptFormular;
     XDrag,YDrag:Integer; {merkt sich Pos. des gezogenen Feld}
     MausZug:TZug;        {Zug mit der Maus bzw. sein Vorgänger}
     IsDragging, MausZugErlaubt, SchlagZwangBesteht, MaxSpieltSchwarz,
      Abbrechen:Boolean;
     LastP:TPos;          {letzte Maus-Position beim Ziehen}
     Max : TFarbe;        {Farbe des Computers (Max): weiss oder schwarz}
     Min : TFarbe;        {Farbe des Gegners (Min): weiss oder schwarz}
     MaxAmZug:Boolean = false;
     var SpielZugListe:TZugListe;         {Liste aller im Spiel gemachten Züge}

procedure Note(s:String);
procedure MinZieht;
procedure MaxZieht;

implementation
{$R *.dfm}
 uses Tests, Strategie, CheatFm, NetzwerkFm;

procedure Note(s:String);
begin
 HauptFormular.Memo1.Lines.add(s);
end;

{*****************************************************************************}
procedure THauptFormular.FormCreate(Sender: TObject);
begin
 MaxSpieltSchwarz:=true;
 MaxAmZug:=true;
 Max:=Schwarz;
 Min:=Weiss;
 Init(MaxSpieltSchwarzFeld);

 IsDragging:=false;
 MausZug.Count:=0;
 MausZugErlaubt:=false;
 LastP.x:=0;
 LastP.y:=0;
 MaxZiehtButton.enabled:=MaxAmZug;
 ZurueckButton.enabled:=false;
 SpielZugListe:=TZugListe.Create;
 Abbrechen:=false;
 Debug:=false;
end;


procedure THauptFormular.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
 wait:=false;
 Debug:=false;
 with NetzwerkFormular do
  begin
   if IdTCPClient.Connected then
      IdTCPClient.Disconnect;
   if ServerRunning then
      StopServer;   
  end;
end;

{*****************************************************************************}

procedure THauptFormular.NeuButtonClick(Sender: TObject);
begin
 MaxSpieltSchwarz:=(MaxSpieltRG.ItemIndex = 0);
 MaxAmZug:=MaxSpieltSchwarz;
 if MaxSpieltSchwarz then
  begin
   Max:=Schwarz;
   Min:=Weiss;
   Init(MaxSpieltSchwarzFeld);
  end else
  begin
   Max:=Weiss;
   Min:=Schwarz;
   Init(MaxSpieltWeissFeld);
  end;

 Memo1.Lines.Clear;
 IsDragging:=false;
 MausZug.Count:=0;
 MausZugErlaubt:=false;
 LastP.x:=0;
 LastP.y:=0;

 SpielfeldDG.Repaint;

 MaxZiehtButton.enabled:=MaxAmZug;
 SpielZugListe.Clear;
 Abbrechen:=false;
end;

{****************************************************************************}

procedure MinZieht;
begin
 Application.ProcessMessages;
 if Abbrechen then exit;
 VollZiehe(MausZug);
 Note('Min:'+ZugToStr(MausZug));
 with HauptFormular do
  begin
   ZurueckButton.enabled:=true;
   MaxZiehtButton.enabled:=true;
   MaxAmZug:=true;
  end;

 HauptFormular.SpielFeldDG.Repaint;
 MaxZieht;
 HauptFormular.SpielFeldDG.Repaint;
end;

procedure MaxZieht;
var t,w:Integer;
    Z:TZug;
    s:String;
begin
 Application.ProcessMessages;
 if Abbrechen then exit;
 t:=HauptFormular.TiefeSE.Value;
 w:=MaxWert(t,Z);
 if HatGewonnen(Max) then
  begin
   Note('Bedaure, Sie haben verloren.');
   exit;
  end else
 if HatGewonnen(Min) then
  begin
   Note('Gratuliere, Sie haben gewonnen!');
   exit;
  end;

 Note('Max:'+ZugToStr(Z)+' Wert='+IntToStr(w));
 Vollziehe(Z);
 with HauptFormular do
  begin
   SpielfeldDG.Repaint;
   MaxZiehtButton.enabled:=false;
   ZurueckButton.enabled:=true;
  end;
 MaxAmZug:=false;
 SchlagZwangBesteht:=SchlagZwang(Min);

 if HauptFormular.MinSpieltRG.ItemIndex>0 then {Min wird von remote gespielt}
  with NetzwerkFormular do
    begin
     ZugSpiegeln(Z);
     IdTCPClient.WriteLn(ZugToStr(Z));  {Max-Zug mitteilen}
     s:=IdTCPClient.ReadLn;
     HauptFormular.Memo1.Lines.Add(s);
    end;
end;


{****************************************************************************}

procedure THauptFormular.SpielFeldDGDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
var Index:Byte;
begin
 if (ACol+ARow) mod 2 = 1 then Index:=F[ACol+1,ARow+1]+1
                          else Index:=0;                {Index in der ImageList}
 FelderIL.Draw(SpielFeldDG.Canvas,49*ACol,49*ARow,Index);
end;

{****************************************************************************}

procedure THauptFormular.SpielFeldDGDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
var ACol,ARow:Integer;
    P:TPos;
    IstDunklesFeld,Start,neu:Boolean;
    c:TFarbe;
begin
 Accept:=false;
 if MaxAmzug or (MinSpieltRG.ItemIndex>0) then exit;
 SpielFeldDG.MouseToCell(X,Y,ACol,ARow); {Umwandlung Pixel in Grid-Koordinaten}
 P.x:=ACol+1;
 P.y:=ARow+1;

 IstDunklesFeld:=((P.x+P.y) mod 2 = 1);
 if not IstDunklesFeld then exit;                   {nur dort wird gespielt}
 if MaxSpieltSchwarz and IstSchwarzIn(P) or
  not MaxSpieltSchwarz and IstWeissIn(P) then exit; {nur Min zieht mit der Maus}

 Start:=not IsDragging and not IstLeer(P);
 if Start then
  begin
   IsDragging:=true;
   with MausZug do
    begin
     Count:=1;
     Pos[1]:=P;
    end;
   LastP:=P;
   if ZugListeTS.Visible then
    begin
     PosEdit.Text:='('+IntToStr(P.x)+','+IntToStr(P.y)+')';
     FarbeEdit.Text:=IntToStr(F[P.x,P.y]);
    end;
 //  ZugAusgeben(MausZug,Memo1);
  end;


 neu:=(P.x<>LastP.x) or (P.y<>LastP.y);
 if neu then
  begin
   with MausZug do
    begin
     inc(Count);
     Pos[Count]:=P;
    end;
   LastP:=P;
   MausZugErlaubt:=ZugErlaubt(MausZug,SchlagZwangBesteht);   {Neuberechnung}
//   ZugAusgeben(MausZug,Memo1);
  end;

 Accept:=Start or MausZugErlaubt;

 c:=F[MausZug.Pos[1].x,MausZug.Pos[1].y];

 if not Accept and neu and not (IstLeer(P) and SprungExistiert(c,P,nirgends)) then
 {nicht entfernen, wenn als Zwischenstation gebraucht}
  begin
   dec(MausZug.Count);                       {Position entfernen}
//   ZugAusgeben(MausZug);
  end;

end;

procedure THauptFormular.SpielFeldDGDragDrop(Sender, Source: TObject; X,
  Y: Integer);
var ACol, ARow:Integer;
begin
 SpielFeldDG.MouseToCell(X,Y,ACol,ARow); {Umwandlung Pixel in Grid-Koordinaten}
 if MausZugErlaubt and (MinSpieltRG.ItemIndex=0) then
   MinZieht;
end;

procedure THauptFormular.SpielFeldDGEndDrag(Sender, Target: TObject; X,
  Y: Integer);
{wird auch bei missglücktem Drop wg. accept=false aufgerufen}
begin
 IsDragging:=false;
 MausZugErlaubt:=false;
// MausZug.Count:=0;
 LastP.x:=0;
 LastP.y:=0;
end;

{****************************************************************************}


procedure THauptFormular.MaxZiehtButtonClick(Sender: TObject);
begin
 MaxZieht;
 SchlagZwangBesteht:=SchlagZwang(Min);
end;
{****************************************************************************}

procedure THauptFormular.ZurueckButtonClick(Sender: TObject);
var more:Boolean;
begin
 more:=(SpielZugListe.Count>0);
 NimmZugZurueck;
 if more then
  begin
   SpielfeldDG.Repaint;
   Memo1.Lines.Delete(Memo1.Lines.Count-1); {letzte Zeile löschen}
   MaxAmZug:=not MaxAmZug;
   MaxZiehtButton.enabled:=MaxAmZug;
   ZurueckButton.enabled:=(SpielZugListe.Count>0);
   if not MaxAmZug then
     SchlagZwangBesteht:=SchlagZwang(Min);
  end; 
end;

{****************************************************************************}

procedure THauptFormular.LokaleZugListeButtonClick(Sender: TObject);
var P:TPos;
    c:TFarbe;
    L:TZugListe;
begin
 try
  P.x:=StrToInt(PosEdit.Text[2]);
  P.y:=StrToInt(PosEdit.Text[4]);
  c:=StrToInt(FarbeEdit.Text);
  L:=LokaleZugListe(P,c,0,false,false,nirgends);  {ohne externen Schlagzwang}
  Memo1.Lines.Clear;
  L.Ausgeben(Memo1);
 except
  on E:Exception do
   ShowMessage(E.Message);
 end;
end;

procedure THauptFormular.GlobaleZugListeButtonClick(Sender: TObject);
var c:TFarbe;
    L:TZugListe;
    SchlagZwangBesteht:Boolean;
begin
 c:=StrToInt(FarbeEdit.Text);
 if IstDame(c) then dec(c);        {c darf nur Weiss oder Schwarz sein}
 SchlagZwangBesteht:=SchlagZwang(c);
 L:=GlobaleZugListe(c,SchlagZwangBesteht);
 Memo1.Lines.Clear;
 L.Ausgeben(Memo1);
end;

{****************************************************************************}

procedure THauptFormular.ZeigeTestFeldButtonClick(Sender: TObject);
begin
 if TestFeldCB.ItemIndex=0 then init(TestFeld1)
                           else init(TestFeld2);
 SpielFeldDG.Repaint;
 Memo1.Lines.Clear;
end;

procedure THauptFormular.TestDurchfuehrenButtonClick(Sender: TObject);
var OK:Boolean;
     s:String;
begin
 OK:=false;
 init(TestFeld1);
 case ZuTestenCB.ItemIndex of
  0:  OK:=Teste_Anzahl;
  1:  OK:=Teste_IstLeer;
  2:  OK:=Teste_IstImFeld;
  3:  OK:=Teste_IstWeiss;
  4:  OK:=Teste_IstSchwarz;
  5:  OK:=Teste_IstGegner;
  6:  OK:=Teste_SindGleichfarbig;
  7:  OK:=Teste_IstDame;
  8:  OK:=Teste_Abstand;
  9:  OK:=Teste_ZielAbstand;
 10:  OK:=Teste_Richtung;
 11:  OK:=Teste_RichtungErlaubt;
 12:  OK:=Teste_GleichGerichtet;
 13:  OK:=Teste_IstGerade;
 14:  OK:=Teste_Mittelpunkt;
 15:  OK:=Teste_SprungMoeglich;
 16:  OK:=Teste_SprungExistiert;
 17:  OK:=Teste_ZugErlaubt;
 end;
 s:='Test '+ZuTestenCB.Items[ZuTestenCB.ItemIndex];
 if OK then Note(s+' bestanden')
       else Note(s+' nicht bestanden');
end;


procedure THauptFormular.CheatButtonClick(Sender: TObject);
var x,y:Integer;
begin
 for x:=1 to 8 do
  for y:=1 to 8 do
   CheatFormular.StringGrid1.Cells[x-1,y-1]:=IntToStr(F[x,y]);
 if MaxAmZug then CheatFormular.WerIstDranRG.ItemIndex:=0
             else CheatFormular.WerIstDranRG.ItemIndex:=1;
 CheatFormular.Show;
end;

procedure THauptFormular.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if Key=VK_F7 then wait:=false;  {falls Debug=true}
end;


procedure THauptFormular.Spielstandspeichern1Click(Sender: TObject);
var T:TextFile;
    s:String;
    x,y,k:Integer;
begin
 ForceCurrentDirectory:=true;
 with SaveDialog1 do
  begin
   s:=ExtractFilePath(Application.ExeName)+'Spielverläufe';
   InitialDir:=s;
   if execute then
    begin
     if FileExists(FileName) then
       if MessageDlg('Datei existiert bereits. Überschreiben?',
          mtConfirmation, [mbYes, mbNo], 0) <> mrYes then exit;

     AssignFile(T,FileName);
     Rewrite(T);
     for y:=1 to 8 do
      begin
       if y=1 then s:='(('
              else s:='(';
       for x:=1 to 8 do
        begin
         s:=s+IntToStr(F[x,y]);
         if x<8 then s:=s+','
                else s:=s+')';
        end;
       if y<8 then s:=s+','
              else s:=s+')';
       writeln(T,s);
      end;
      writeln(T);

     writeln(T,IntToStr(SpielZugListe.Count)+':');
     for k:=1 to SpielZugListe.Count do
      writeln(T,ZugToStr(SpielZugListe.ZugNr(k)));
     writeln(T);

     writeln(T,IntToStr(GS.Count)+':');
     s:='';
     for k:=1 to GS.Count do
      begin
       s:=s+IntToStr(GS.Steine[k]);
       if k<GS.Count then s:=S+',';
      end;
     writeln(T,s);
     writeln(T);

     if MaxAmZug then writeln(T,'Max')
                 else writeln(T,'Min');

     writeln(T);
     writeln(T,IntToStr(TiefeSE.Value));
     CloseFile(T);
    end;

  end;
end;

procedure THauptFormular.Spielstandladen1Click(Sender: TObject);
var T:TextFile;
    s,s1:String;
    x,y,k,n,x0,p:Integer;
    Z:TZug;
begin
 ForceCurrentDirectory:=true;
 with OpenDialog1 do
  begin
   s:=ExtractFilePath(Application.ExeName)+'Spielverläufe';
   InitialDir:=s;
   if execute then
    begin
     AssignFile(T,FileName);
     Reset(T);
     for y:=1 to 8 do
      begin
       readln(T,s);
       if y=1 then x0:=3
              else x0:=2;
       for x:=1 to 8 do
         F[x,y]:=StrToInt(s[2*(x-1)+x0]);
      end;
      readln(T);

     readln(T,s);
     p:=Pos(':',s);
     s1:=copy(s,1,p-1);
     n:=StrToInt(s1);
     SpielZugListe.Clear;
     for k:=1 to n do
      begin
       readln(T,s);
       Z:=StrToZug(s);
       SpielZugListe.Copy(Z);
      end;

     readln(T);
     readln(T,s);
     p:=length(s);
     s1:=copy(s,1,p-1);
     GS.Count:=StrToInt(s1);

     readln(T,s);
     for k:=1 to GS.Count do
       GS.Steine[k]:=StrToInt(s[2*(k-1)+1]);
     readln(T);
     readln(T,s);
     MaxAmZug:=(s='Max');

     readln(T);
     readln(T,s);
     TiefeSE.Value:=StrToInt(s);

     CloseFile(T);

     SpielFeldDG.Repaint;
     Memo1.Lines.Clear;
    end;

  end;
end;

procedure THauptFormular.Netzwerk1Click(Sender: TObject);
begin
 NetzwerkFormular.Show;
end;

procedure THauptFormular.MinSpieltRGClick(Sender: TObject);
begin
 if MinSPieltRG.ItemIndex>0 then {Min soll von remote gespielt werden}
  with  NetzwerkFormular do
   begin
    if not (ServerRunning and IdTCPClient.Connected) then
     begin
      ShowMessage('Nicht mit Remote verbunden');
      MinSpieltRG.ItemIndex:=0;
     end;   
   end;

end;

procedure THauptFormular.AbbrechenButtonClick(Sender: TObject);
begin
 Abbrechen:=true;
end;

end.
