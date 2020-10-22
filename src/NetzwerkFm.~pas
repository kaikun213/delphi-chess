unit NetzwerkFm;
{Weiß-Computer startet auf Knopfdruck, bestimmt den ersten Zug und führt ihn
 aus. Solange das Spiel nicht zuende ist, teilt Weiß-Client alle eigenen
 ausgeführten Züge dem Schwarz-Server mit und erfragt den Antwortzug.}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, CheckLst, IdBaseComponent, IdComponent, IdTCPServer,
  IdStack,IdGlobal,IdSocketHandle, ComCtrls, IdTCPConnection, IdTCPClient,
  ExtCtrls;

type
  TNetzwerkFormular = class(TForm)
    GroupBox1: TGroupBox;
    StartServerButton: TButton;
    StopServerButton: TButton;
    Label2: TLabel;
    Label3: TLabel;
    LocalPortEdit: TEdit;
    StatusBar: TStatusBar;
    GroupBox2: TGroupBox;
    RemoteIPEdit: TEdit;
    RemotePortEdit: TEdit;
    ConnectButton: TButton;
    DisconnectButton: TButton;
    Label1: TLabel;
    Label4: TLabel;
    CommandsCB: TComboBox;
    SendCommandButton: TButton;
    btnClearMessages: TButton;
    IdTCPClient: TIdTCPClient;
    NetzwerkLB: TListBox;
    IPLB: TCheckListBox;
    IdTCPServer: TIdTCPServer;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure PopulateIPAddresses;
    procedure StartServerButtonClick(Sender: TObject);
    function StartServer:Boolean;
    function StopServer:Boolean;
    procedure StopServerButtonClick(Sender: TObject);
    procedure btnClearMessagesClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure IdTCPServerConnect(AThread: TIdPeerThread);
    procedure IdTCPServerExecute(AThread: TIdPeerThread);
    procedure ConnectButtonClick(Sender: TObject);
    procedure LockControls(ALock: Boolean);
    procedure SendCommandButtonClick(Sender: TObject);
    procedure DisconnectButtonClick(Sender: TObject);
    procedure IdTCPClientConnected(Sender: TObject);
    procedure IdTCPClientDisconnected(Sender: TObject);
    procedure IdTCPServerDisconnect(AThread: TIdPeerThread);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  end;

var NetzwerkFormular: TNetzwerkFormular;
    ErrorSL:TStringList;
    ServerRunning,ClientConnected:Boolean;

implementation

uses HauptFm, uSchach, uFEN;
{$R *.dfm}

{****************************************************************************}

procedure TNetzwerkFormular.StartServerButtonClick(Sender: TObject);
var x,i : integer;
begin
 x:=0;
 for i := 0 to IPLB.Count-1 do
   if IPLB.Checked[i] then inc(x);

 if x<1 then
   begin
    ShowMessage('Cannot proceed until you select at least one IP to bind!');
    exit;
   end;

 ErrorSL.Clear;
 if not StartServer then
    ShowMessage('Error starting server' + #13 + #13 + ErrorSL.text);
end;

procedure TNetzwerkFormular.StopServerButtonClick(Sender: TObject);
begin
 ErrorSL.Clear;
 if not ServerRunning then
   begin
    ShowMessage('Server it not running - no need to stop !');
    Exit;
   end;
 if not StopServer then
    ShowMessage('Error stopping server ' + #13 + #13 + ErrorSL.Text);
end;

procedure TNetzwerkFormular.ConnectButtonClick(Sender: TObject);
begin
 with IdTCPClient do
   begin
    Host:=RemoteIPEdit.Text;
    Port:=StrToint(RemotePortEdit.Text);
     try
      Connect(3000); // add a timeout here if you wish, eg: Connect(3000) = timeout after 3 seconds.
 //    ConnectButton.Enabled := false;
      DisconnectButton.Enabled := true;
      StatusBar.Panels[1].Text:='Client connected';
      ClientConnected:=true;
     except
      on E : Exception do
         begin
          LockControls(True);
          ShowMessage(E.Message);
          StatusBar.Panels[1].Text:='connected failed';
          ClientConnected:=false;
         end;
      end;
    end;
end;

{*****************************************************************************}

procedure TNetzwerkFormular.SendCommandButtonClick(Sender: TObject);
{Kontrollanfrage an den Server, mit dem man verbunden ist:}
var LCommand, LInString : String;
    LInInteger : Integer;
begin
 LCommand := CommandsCB.Text;           {gewählte Anfrage}
 LInInteger := -1;                      {"nichts" zugewiesen}

 with IdTCPClient do
    begin
     try
      WriteLn(LCommand);                {sende Anfrage an Server}
      case CommandsCB.ItemIndex of      {je nach Anfrage ...}
        0..2: LInString := ReadLn;      {String-Antwort des Servers lesen}
        3: LInInteger := ReadInteger;   {... bzw. Integer-Antwort lesen}
      end;

      if LInInteger <> -1 then         {Antwort war eine Zahl  (FARBE)}
        LInString := ColToStr(TFarbe(LInInteger));

      NetzwerkLB.Items.Append('We asked -> ' + LCommand);
      NetzwerkLB.Items.Append('Server said -> ' + LInString);

     except
      on E : Exception do
         begin
          LockControls(True);
          ShowMessage(E.Message);
         end;
     end;
    end;
end;
{****************************************************************************}

procedure TNetzwerkFormular.IdTCPServerExecute(AThread: TIdPeerThread);
{eigenener Server erhält eine Anfrage von einem Client und schickt eine Antwort;
 beim Schachspiel entspricht das dem Mausklick von Min}
var  Command,s : String;
     sPos,fPos:TPosition;
     MaxZug:TZug;
begin
  Command := AThread.Connection.ReadLn;                         {Anfrage lesen}

 {Anfrage analysieren und beantworten:}
  if Command = 'TIME' then
      AThread.Connection.WriteLn(FormatDateTime('hh:nn:ss',now)) else
  if Command = 'DATE' then
      AThread.Connection.WriteLn(FormatDateTime('dd/mmm/yyyy',date)) else
  if Command = 'QUIT' then
      begin
       AThread.Connection.WriteLn('Goodbye!');
//       IdTCPServerDisconnect(AThread);
       AThread.Connection.Disconnect;
      end else
  if Command = 'FARBE' then
      AThread.Connection.WriteInteger(ord(Max)) else
      
  if Form1.MinSpieltRG.ItemIndex>0 then {spiele Min von Remote}
//     AThread.Connection.WriteLn('Command not recognised - try again!');
    begin
      s:=Command;
      sPos.x:=ColumnFromString(s[1]);
      sPos.y:=StrToInt(s[2]);
      fPos.x:=ColumnFromString(s[4]);
      fPos.y:=StrToInt(s[5]);

      MinZiehtMaxZieht(sPos,fPos,MaxZug);
      AThread.Connection.WriteLn(MaxZug);  {Antwort zurücksenden}
    end;
end;

{****************************************************************************}

function TNetzwerkFormular.StartServer: Boolean;
var Binding : TIdSocketHandle;
    i : integer;
begin
 if not StopServer then
   begin
    ErrorSL.Append('Error stopping server');
    Result := false;
    exit;
   end;

 IdTCPServer.Bindings.Clear; // bindings cannot be cleared until TidTCPServer is inactive
 try
  try
   for i := 0 to IPLB.Count-1 do
    if IPLB.Checked[i] then
       begin
        Binding := IdTCPServer.Bindings.Add;
        Binding.IP := IPLB.Items.Strings[i];
        Binding.Port := StrToInt(LocalPortEdit.Text);
        NetzwerkLB.Items.append('Server bound to IP ' + Binding.IP + ' on port ' + LocalPortEdit.Text);
       end;

   IdTCPServer.Active := true;
   Result := IdTCPServer.Active;
   ServerRunning := Result;
   NetzwerkLB.Items.Append('Server started');
   if Result then StatusBar.Panels[0].Text := 'Server running'
             else StatusBar.Panels[0].Text := 'Server stopped';

 except
  on E : Exception do
    begin
     NetzwerkLB.Items.Append('Server not started');
     ErrorSL.append(E.Message);
     Result := false;
     ServerRunning := result;
    end;
  end;
 finally
  NetzwerkLB.Items.Append('_________________');
 end;
end;

function TNetzwerkFormular.StopServer: Boolean;
begin
 IdTCPServer.Active := false;
 IdTCPServer.Bindings.Clear;
 Result := not IdTCPServer.Active;
 ServerRunning := Result;
 if Result then
   begin
    StatusBar.Panels[0].Text := 'Server stopped';
    NetzwerkLB.Items.Append('Server stopped');
   end else
   begin
    StatusBar.Panels[0].Text := 'Server running';
    NetzwerkLB.Items.Append('Server not stopped');
   end;
end;

{***************************************************************************}

procedure TNetzwerkFormular.FormCreate(Sender: TObject);
begin
 ErrorSL := TStringList.Create;
 PopulateIPAddresses;
end;

procedure TNetzwerkFormular.PopulateIPAddresses;
begin
 with IPLB do
   begin
    Clear;
    Items := GStack.LocalAddresses;
    Items.Insert(0, '127.0.0.1');
   end;
end;



procedure TNetzwerkFormular.btnClearMessagesClick(Sender: TObject);
begin
 NetzwerkLB.Clear;
end;

procedure TNetzwerkFormular.FormDestroy(Sender: TObject);
begin
 FreeAndNil(ErrorSL);
end;

{****************************************************************************}

procedure TNetzwerkFormular.IdTCPServerConnect(AThread: TIdPeerThread);
{erzeugt einen neuen Thread, der die Anfragen der Verbindung abwickelt}
var s:String;
begin
 ClientConnected:=true;
 {Server grüßt den Client, der eine Verbindung wollte:}
 s:='Willkommen auf '+IdTCPServer.LocalName;
 AThread.Connection.WriteLn(s);

 {Meldung im eigenen Netzwerkformular:}
 s:='Server connected to remote client '+AThread.Connection.Socket.Binding.PeerIP;
 NetzwerkLB.Items.Append(s);
 NetzwerkLB.Items.Append('_________________');
end;

procedure TNetzwerkFormular.IdTCPServerDisconnect(AThread: TIdPeerThread);
var s:String;
begin
 ClientConnected:=false;
 s:='Server disconnected from remote client '+AThread.Connection.Socket.Binding.PeerIP;
 NetzwerkLB.Items.Append(s);
 NetzwerkLB.Items.Append('_________________');
 LockControls(false);
end;

{****************************************************************************}



procedure TNetzwerkFormular.LockControls(ALock: Boolean);
var i:integer;
begin
for i:=0 to componentcount-1 do
   if TControl(Components[i]).Tag = 99 then
       TControl(Components[i]).Enabled := ALock;
end;

{*****************************************************************************}


procedure TNetzwerkFormular.DisconnectButtonClick(Sender: TObject);
begin
 if IdTCPClient.Connected then
   try
    IdTCPClient.Disconnect; // we can disconnect from either the server or the client side
    ConnectButton.Enabled := true;
    DisconnectButton.Enabled := false;
    ClientConnected:=false;
    StatusBar.Panels[1].Text:='Client disconnected';
   except on E : Exception do
        ShowMessage(E.Message);
   end;
end;

procedure TNetzwerkFormular.IdTCPClientConnected(Sender: TObject);
{wird ausgelöst nach einer erfolgreichen Verbindungs-Anfrage}
var  LString : String;
begin
  LString := IdTCPClient.ReadLn;
  NetzwerkLB.Items.Append('Connected to remote server');
  NetzwerkLB.Items.Append('Server said -> ' + LString);
  NetzwerkLB.Items.Append('_________________');
  LockControls(true);
  ClientConnected:=true;
end;

procedure TNetzwerkFormular.IdTCPClientDisconnected(Sender: TObject);
{wird ausgelöst nach einer erfolgreichen Trennungs-Anfrage}
begin
 NetzwerkLB.Items.Append('Client said: Disconnected from remote server');
 NetzwerkLB.Items.Append('_________________');
 LockControls(false);
 ClientConnected:=false;
end;


procedure TNetzwerkFormular.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 if DisConnectButton.Enabled then
  DisConnectButtonClick(self);
end;

end.
