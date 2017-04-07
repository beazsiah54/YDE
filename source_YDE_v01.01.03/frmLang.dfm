object frmLanguage: TfrmLanguage
  Left = 352
  Top = 193
  Width = 279
  Height = 249
  Caption = 'Update'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnKeyUp = FormKeyUp
  PixelsPerInch = 96
  TextHeight = 13
  object Gauge1: TGauge
    Left = 136
    Top = 8
    Width = 105
    Height = 41
    Progress = 0
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 192
    Width = 263
    Height = 19
    Panels = <>
    SimplePanel = True
  end
  object btnUpdateProgram: TButton
    Left = 16
    Top = 16
    Width = 113
    Height = 25
    Caption = 'Update Program'
    TabOrder = 1
    OnClick = btnUpdateProgramClick
    OnKeyUp = btnUpdateProgramKeyUp
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 56
    Width = 241
    Height = 113
    Caption = 'ftpSettings'
    TabOrder = 2
    object edthost: TEdit
      Left = 24
      Top = 16
      Width = 121
      Height = 21
      TabOrder = 0
      Text = 'ftp.saueem.com'
    end
    object edtuser: TEdit
      Left = 24
      Top = 40
      Width = 121
      Height = 21
      TabOrder = 1
      Text = 'burhan@saueem.com'
    end
    object edtpass: TEdit
      Left = 24
      Top = 64
      Width = 121
      Height = 21
      TabOrder = 2
      Text = 'qweqwe12!'
    end
    object btnftpkaydet: TButton
      Left = 160
      Top = 24
      Width = 57
      Height = 65
      Caption = 'Save'
      TabOrder = 3
    end
    object edtfolder: TEdit
      Left = 24
      Top = 88
      Width = 121
      Height = 21
      TabOrder = 4
      Text = 'burhan'
    end
  end
  object IdFTP: TIdFTP
    OnStatus = IdFTPStatus
    MaxLineAction = maException
    ReadTimeout = 0
    OnWork = IdFTPWork
    OnWorkBegin = IdFTPWorkBegin
    OnWorkEnd = IdFTPWorkEnd
    ProxySettings.ProxyType = fpcmNone
    ProxySettings.Port = 0
    Left = 208
    Top = 24
  end
end
