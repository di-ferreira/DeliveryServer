object ViewMainServer: TViewMainServer
  Left = 805
  Top = 336
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Delivery Server'
  ClientHeight = 357
  ClientWidth = 268
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poDesktopCenter
  OnClose = FormClose
  OnCreate = FormCreate
  TextHeight = 15
  object BtnServer: TButton
    Left = 8
    Top = 88
    Width = 249
    Height = 49
    Caption = 'SERVER'
    TabOrder = 1
    OnClick = BtnServerClick
  end
  object BtnBot: TButton
    Left = 8
    Top = 248
    Width = 249
    Height = 49
    Caption = 'CONNECT BOT'
    TabOrder = 4
    OnClick = BtnBotClick
  end
  object EdtPorta: TLabeledEdit
    Left = 8
    Top = 38
    Width = 249
    Height = 29
    Alignment = taRightJustify
    EditLabel.Width = 35
    EditLabel.Height = 15
    EditLabel.Caption = 'PORTA'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Segoe UI'
    Font.Style = []
    LabelSpacing = 10
    NumbersOnly = True
    ParentFont = False
    TabOrder = 0
    Text = '9000'
  end
  object EdtSimultaneos: TLabeledEdit
    Left = 8
    Top = 198
    Width = 113
    Height = 29
    Alignment = taRightJustify
    EditLabel.Width = 82
    EditLabel.Height = 30
    EditLabel.Caption = 'ATENDIMENTO '#13#10'SIMULT'#194'NEOS'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Segoe UI'
    Font.Style = []
    LabelSpacing = 10
    NumbersOnly = True
    ParentFont = False
    TabOrder = 2
    Text = '20'
  end
  object EdtTempoInatividade: TLabeledEdit
    Left = 144
    Top = 198
    Width = 113
    Height = 29
    Alignment = taRightJustify
    EditLabel.Width = 113
    EditLabel.Height = 30
    EditLabel.Caption = 'TEMPO INATIVIDADE '#13#10'(min)'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Segoe UI'
    Font.Style = []
    LabelSpacing = 10
    NumbersOnly = True
    ParentFont = False
    TabOrder = 3
    Text = '2'
  end
  object TrayIcon: TTrayIcon
    BalloonHint = 'Running'
    BalloonTitle = 'Delivery Server'
    BalloonFlags = bfInfo
    PopupMenu = PopupMenu
    OnDblClick = TrayIconDblClick
    Left = 40
    Top = 304
  end
  object ApplicationEvents: TApplicationEvents
    OnMinimize = ApplicationEventsMinimize
    Left = 96
    Top = 304
  end
  object PopupMenu: TPopupMenu
    Left = 144
    Top = 304
    object PPServer: TMenuItem
      Caption = 'SERVER'
      OnClick = PPServerClick
    end
    object PPBot: TMenuItem
      Caption = 'BOT'
    end
  end
  object Bot: TInject
    InjectJS.AutoUpdateTimeOut = 10
    Config.AutoDelay = 1000
    AjustNumber.LengthPhone = 8
    AjustNumber.DDIDefault = 55
    FormQrCodeType = Ft_Http
    OnGetUnReadMessages = BotGetUnReadMessages
    Left = 224
    Top = 304
  end
end
