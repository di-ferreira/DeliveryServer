object ViewMainServer: TViewMainServer
  Left = 805
  Top = 336
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'Delivery Server'
  ClientHeight = 228
  ClientWidth = 190
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poDesigned
  OnClose = FormClose
  OnCreate = FormCreate
  TextHeight = 15
  object BtnServer: TButton
    Left = 8
    Top = 48
    Width = 168
    Height = 49
    Caption = 'SERVER'
    TabOrder = 0
    OnClick = BtnServerClick
  end
  object BtnBot: TButton
    Left = 8
    Top = 112
    Width = 168
    Height = 49
    Caption = 'BOT'
    TabOrder = 1
  end
  object EdtPorta: TLabeledEdit
    Left = 55
    Top = 16
    Width = 121
    Height = 29
    Alignment = taRightJustify
    EditLabel.Width = 35
    EditLabel.Height = 29
    EditLabel.Caption = 'PORTA'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Segoe UI'
    Font.Style = []
    LabelPosition = lpLeft
    LabelSpacing = 10
    NumbersOnly = True
    ParentFont = False
    TabOrder = 2
    Text = '9000'
  end
  object TrayIcon: TTrayIcon
    BalloonHint = 'Running'
    BalloonTitle = 'Delivery Server'
    BalloonFlags = bfInfo
    PopupMenu = PopupMenu
    OnDblClick = TrayIconDblClick
    Left = 24
    Top = 176
  end
  object ApplicationEvents: TApplicationEvents
    OnMinimize = ApplicationEventsMinimize
    Left = 80
    Top = 176
  end
  object PopupMenu: TPopupMenu
    Left = 128
    Top = 176
    object PPServer: TMenuItem
      Caption = 'SERVER'
      OnClick = PPServerClick
    end
    object PPBot: TMenuItem
      Caption = 'BOT'
    end
  end
end
