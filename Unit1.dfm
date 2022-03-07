object Form1: TForm1
  Left = 305
  Top = 214
  Width = 577
  Height = 268
  AutoSize = True
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 96
    Width = 50
    Height = 13
    Caption = #1044#1077#1074#1080#1072#1094#1080#1103
  end
  object Label2: TLabel
    Left = 16
    Top = 32
    Width = 112
    Height = 13
    Caption = #1062#1077#1085#1090#1088#1072#1083#1100#1085#1072#1103' '#1095#1072#1089#1090#1086#1090#1072
  end
  object Label3: TLabel
    Left = 216
    Top = 24
    Width = 6
    Height = 23
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clMaroon
    Font.Height = -19
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label4: TLabel
    Left = 16
    Top = 168
    Width = 104
    Height = 13
    Caption = #1052#1086#1097#1085#1086#1089#1090#1100' '#1087#1077#1088#1077#1076#1072#1095#1080
  end
  object Label5: TLabel
    Left = 192
    Top = 8
    Width = 122
    Height = 19
    Caption = #1051#1077#1074#1099#1081' Ctrl - PTT'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clGreen
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label6: TLabel
    Left = 456
    Top = 8
    Width = 92
    Height = 13
    Caption = 'berartvlad@mail.ru'
  end
  object Button1: TButton
    Left = 0
    Top = 0
    Width = 75
    Height = 25
    Caption = 'Tx'
    TabOrder = 0
    Visible = False
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 96
    Top = 0
    Width = 75
    Height = 25
    Caption = 'Rx'
    TabOrder = 1
    Visible = False
    OnClick = Button2Click
  end
  object TrackBar1: TTrackBar
    Left = 8
    Top = 48
    Width = 553
    Height = 45
    Max = 1000
    Position = 500
    TabOrder = 2
    OnChange = TrackBar1Change
  end
  object TrackBar2: TTrackBar
    Left = 8
    Top = 120
    Width = 553
    Height = 45
    Max = 100
    Position = 3
    TabOrder = 3
    OnChange = TrackBar2Change
  end
  object TrackBar3: TTrackBar
    Left = 8
    Top = 184
    Width = 545
    Height = 45
    Max = 127
    Position = 10
    TabOrder = 4
    OnChange = TrackBar3Change
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 300
    Left = 256
    Top = 272
  end
  object Timer2: TTimer
    Interval = 100
    OnTimer = Timer2Timer
    Left = 208
    Top = 8
  end
end
