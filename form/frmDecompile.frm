inherited FormDecompile: TFormDecompile
  Height = 169
  Width = 463
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Decompile'
  ClientHeight = 169
  ClientWidth = 463
  Position = poMainFormCenter
  object pnlApkfile: TPanel[0]
    Left = 0
    Height = 42
    Top = 0
    Width = 463
    Align = alTop
    BevelOuter = bvNone
    ClientHeight = 42
    ClientWidth = 463
    TabOrder = 0
    object lblApkFile: TLabel
      Left = 8
      Height = 26
      Top = 8
      Width = 90
      Align = alLeft
      AutoSize = False
      BorderSpacing.Around = 8
      Caption = 'APK File'
      Layout = tlCenter
      ParentColor = False
    end
    object edtApkPath: TEdit
      Left = 106
      Height = 26
      Top = 8
      Width = 301
      Align = alClient
      BorderSpacing.Around = 8
      TabOrder = 0
    end
    object btnApkPath: TBitBtn
      Left = 415
      Height = 26
      Top = 8
      Width = 40
      Align = alRight
      BorderSpacing.Around = 8
      Caption = '...'
      OnClick = btnApkPathClick
      TabOrder = 1
    end
  end
  object pnlOutputPath: TPanel[1]
    Left = 0
    Height = 42
    Top = 42
    Width = 463
    Align = alTop
    BevelOuter = bvNone
    ClientHeight = 42
    ClientWidth = 463
    TabOrder = 1
    object lblOutputPath: TLabel
      Left = 8
      Height = 26
      Top = 8
      Width = 90
      Align = alLeft
      AutoSize = False
      BorderSpacing.Around = 8
      Caption = 'Output Path'
      Layout = tlCenter
      ParentColor = False
    end
    object edtOutputPath: TEdit
      Left = 106
      Height = 26
      Top = 8
      Width = 301
      Align = alClient
      BorderSpacing.Around = 8
      TabOrder = 0
    end
    object btnOutputPath: TBitBtn
      Left = 415
      Height = 26
      Top = 8
      Width = 40
      Align = alRight
      BorderSpacing.Around = 8
      Caption = '...'
      OnClick = btnOutputPathClick
      TabOrder = 1
    end
  end
  object pnlOptions: TPanel[2]
    Left = 0
    Height = 42
    Top = 84
    Width = 463
    Align = alTop
    BevelOuter = bvNone
    ClientHeight = 42
    ClientWidth = 463
    TabOrder = 2
    object chkNoRes: TCheckBox
      Left = 106
      Height = 42
      Top = 0
      Width = 112
      Align = alLeft
      BorderSpacing.Left = 106
      Caption = 'No Resource'
      TabOrder = 0
    end
    object chkNoSrc: TCheckBox
      Left = 234
      Height = 42
      Top = 0
      Width = 134
      Align = alLeft
      BorderSpacing.Left = 16
      Caption = 'No Source Code'
      TabOrder = 1
    end
  end
  object pnlButtons: TPanel[3]
    Left = 0
    Height = 42
    Top = 126
    Width = 463
    Align = alTop
    BevelOuter = bvNone
    ClientHeight = 42
    ClientWidth = 463
    TabOrder = 3
    object btnOK: TBitBtn
      Left = 380
      Height = 26
      Top = 8
      Width = 75
      Align = alRight
      BorderSpacing.Around = 8
      Caption = 'OK'
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
    object btnCanel: TBitBtn
      Left = 297
      Height = 26
      Top = 8
      Width = 75
      Align = alRight
      BorderSpacing.Around = 8
      Cancel = True
      Caption = 'Canel'
      ModalResult = 2
      TabOrder = 1
    end
  end
end
