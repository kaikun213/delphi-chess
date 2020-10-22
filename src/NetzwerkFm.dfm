object NetzwerkFormular: TNetzwerkFormular
  Left = 483
  Top = 263
  Width = 525
  Height = 536
  Caption = 'Netzwerk'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 8
    Top = 16
    Width = 225
    Height = 225
    Caption = 'Server auf diesem Computer'
    TabOrder = 0
    object Label2: TLabel
      Left = 12
      Top = 16
      Width = 35
      Height = 13
      Caption = 'local IP'
    end
    object Label3: TLabel
      Left = 136
      Top = 16
      Width = 44
      Height = 13
      Caption = 'local Port'
    end
    object Label5: TLabel
      Left = 8
      Top = 160
      Width = 186
      Height = 13
      Caption = 'Nur n'#246'tig, wenn Max (dieser Computer )'
    end
    object Label6: TLabel
      Left = 8
      Top = 176
      Width = 66
      Height = 13
      Caption = 'schwarz spielt'
    end
    object StartServerButton: TButton
      Left = 4
      Top = 126
      Width = 75
      Height = 25
      Caption = '&Start server'
      TabOrder = 0
      OnClick = StartServerButtonClick
    end
    object StopServerButton: TButton
      Left = 137
      Top = 126
      Width = 75
      Height = 25
      Caption = 'S&top server'
      TabOrder = 1
      OnClick = StopServerButtonClick
    end
    object LocalPortEdit: TEdit
      Left = 136
      Top = 32
      Width = 65
      Height = 21
      TabOrder = 2
      Text = '9099'
    end
    object IPLB: TCheckListBox
      Left = 4
      Top = 32
      Width = 109
      Height = 89
      ItemHeight = 13
      TabOrder = 3
    end
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 483
    Width = 517
    Height = 19
    Panels = <
      item
        Width = 250
      end
      item
        Width = 50
      end>
  end
  object GroupBox2: TGroupBox
    Left = 8
    Top = 248
    Width = 225
    Height = 233
    Caption = 'Client auf diesem Computer'
    TabOrder = 2
    object Label1: TLabel
      Left = 8
      Top = 24
      Width = 77
      Height = 13
      Caption = 'remote server IP'
    end
    object Label4: TLabel
      Left = 136
      Top = 24
      Width = 54
      Height = 13
      Caption = 'remote Port'
    end
    object Label7: TLabel
      Left = 16
      Top = 120
      Width = 154
      Height = 13
      Caption = 'Wei'#223' verbindet sich mit Schwarz'
    end
    object RemoteIPEdit: TEdit
      Left = 14
      Top = 57
      Width = 83
      Height = 21
      TabOrder = 0
      Text = '192.168.2.109'
    end
    object RemotePortEdit: TEdit
      Left = 138
      Top = 57
      Width = 71
      Height = 21
      TabOrder = 1
      Text = '9099'
    end
    object ConnectButton: TButton
      Left = 10
      Top = 85
      Width = 75
      Height = 25
      Caption = 'Connect'
      TabOrder = 2
      OnClick = ConnectButtonClick
    end
    object DisconnectButton: TButton
      Left = 136
      Top = 85
      Width = 75
      Height = 25
      Caption = 'Disconnect'
      TabOrder = 3
      OnClick = DisconnectButtonClick
    end
    object CommandsCB: TComboBox
      Tag = 99
      Left = 17
      Top = 152
      Width = 145
      Height = 21
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 4
      Text = 'DATE'
      Items.Strings = (
        'DATE'
        'TIME'
        'QUIT'
        'FARBE')
    end
    object SendCommandButton: TButton
      Tag = 99
      Left = 13
      Top = 190
      Width = 84
      Height = 25
      Caption = 'Send command'
      TabOrder = 5
      OnClick = SendCommandButtonClick
    end
  end
  object btnClearMessages: TButton
    Left = 406
    Top = 438
    Width = 90
    Height = 25
    Caption = 'Clear messages'
    TabOrder = 3
    OnClick = btnClearMessagesClick
  end
  object NetzwerkLB: TListBox
    Left = 240
    Top = 16
    Width = 257
    Height = 417
    ItemHeight = 13
    TabOrder = 4
  end
  object IdTCPClient: TIdTCPClient
    MaxLineAction = maException
    ReadTimeout = 0
    OnDisconnected = IdTCPClientDisconnected
    OnConnected = IdTCPClientConnected
    Port = 0
    Left = 184
    Top = 400
  end
  object IdTCPServer: TIdTCPServer
    Bindings = <>
    CommandHandlers = <>
    DefaultPort = 0
    Greeting.NumericCode = 0
    MaxConnectionReply.NumericCode = 0
    OnConnect = IdTCPServerConnect
    OnExecute = IdTCPServerExecute
    OnDisconnect = IdTCPServerDisconnect
    ReplyExceptionCode = 0
    ReplyTexts = <>
    ReplyUnknownCommand.NumericCode = 0
    TerminateWaitTime = 60000
    Left = 176
    Top = 80
  end
end
