object MainForm: TMainForm
  Left = 233
  Top = 123
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Exemple SEA'
  ClientHeight = 202
  ClientWidth = 316
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 120
  TextHeight = 16
  object FileLbl: TLabel
    Left = 10
    Top = 10
    Width = 25
    Height = 16
    Caption = 'File:'
  end
  object InfoLbl: TLabel
    Left = 10
    Top = 138
    Width = 293
    Height = 32
    Alignment = taCenter
    AutoSize = False
    Caption = 
      'Attention : le fichier crypte ecrasera le fichier original. En c' +
      'as de doute, faites des copies avant.'
    WordWrap = True
  end
  object KeyLbl: TLabel
    Left = 10
    Top = 39
    Width = 26
    Height = 16
    Caption = 'Key:'
  end
  object TypeLbl: TLabel
    Left = 8
    Top = 69
    Width = 35
    Height = 16
    Caption = 'Type:'
  end
  object FileEdit: TEdit
    Left = 60
    Top = 6
    Width = 149
    Height = 24
    ReadOnly = True
    TabOrder = 0
    Text = 'Enter filename ...'
    OnClick = FileEditEnter
  end
  object EncryptBtn: TButton
    Tag = 1
    Left = 10
    Top = 98
    Width = 97
    Height = 31
    Caption = 'Crypt'
    Enabled = False
    TabOrder = 1
    OnClick = EncryptBtnClick
  end
  object DecryptBtn: TButton
    Tag = 2
    Left = 113
    Top = 98
    Width = 97
    Height = 31
    Caption = 'Decrypt'
    Enabled = False
    TabOrder = 2
    OnClick = EncryptBtnClick
  end
  object QuitBtn: TButton
    Left = 217
    Top = 98
    Width = 92
    Height = 31
    Caption = 'Exit'
    TabOrder = 3
    OnClick = QuitBtnClick
  end
  object Bar: TProgressBar
    Left = 10
    Top = 177
    Width = 299
    Height = 21
    TabOrder = 4
  end
  object KeyEdit: TEdit
    Left = 60
    Top = 34
    Width = 149
    Height = 22
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    TabOrder = 5
  end
  object RandomBtn: TButton
    Left = 217
    Top = 6
    Width = 92
    Height = 56
    Caption = 'Random key'
    TabOrder = 6
    OnClick = RandomBtnClick
  end
  object FastOption: TRadioButton
    Left = 83
    Top = 69
    Width = 94
    Height = 21
    Caption = 'Fast crypt'
    TabOrder = 7
  end
  object SecureOption: TRadioButton
    Left = 198
    Top = 69
    Width = 107
    Height = 21
    Caption = 'Security crypt'
    Checked = True
    TabOrder = 8
    TabStop = True
  end
  object OpenDlg: TOpenDialog
    Filter = 'Tous les fichiers|*.*'
    Title = 'Parcourir ...'
    Left = 16
    Top = 160
  end
end
