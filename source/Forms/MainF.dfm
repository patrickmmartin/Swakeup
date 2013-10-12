object frmMain: TfrmMain
  Left = 177
  Top = 143
  Width = 628
  Height = 475
  Caption = 'Net Controller'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = mnuMain
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lvMachines: TListView
    Left = 0
    Top = 29
    Width = 620
    Height = 381
    Align = alClient
    Columns = <
      item
        Caption = 'Name'
        MinWidth = 100
        Width = 100
      end
      item
        Caption = 'MAC'
        MinWidth = 120
        Width = 120
      end
      item
        AutoSize = True
        Caption = 'Comment'
        MinWidth = 80
      end
      item
        Caption = 'Status'
      end
      item
        Caption = 'Up Time'
        MinWidth = 80
        Width = 80
      end
      item
        Caption = 'Current Time'
        MinWidth = 120
        Width = 120
      end>
    ColumnClick = False
    ReadOnly = True
    RowSelect = True
    PopupMenu = pmnuMachines
    SmallImages = dmResource.imlServers
    TabOrder = 0
    ViewStyle = vsReport
  end
  object sbMain: TStatusBar
    Left = 0
    Top = 410
    Width = 620
    Height = 19
    Panels = <
      item
        Width = 240
      end
      item
        Width = 50
      end>
    SimplePanel = False
  end
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 620
    Height = 29
    ButtonHeight = 23
    DisabledImages = dmResource.imlMainDisabled
    HotImages = dmResource.imlMainHot
    Images = dmResource.imlMain
    TabOrder = 2
    object ToolButton8: TToolButton
      Left = 0
      Top = 2
      Action = dmMain.actScanMachine
    end
    object ToolButton2: TToolButton
      Left = 23
      Top = 2
      Action = dmMain.actStartMachine
    end
    object ToolButton1: TToolButton
      Left = 46
      Top = 2
      Action = dmMain.actShutdownMachine
    end
    object sepPowerList: TToolButton
      Left = 69
      Top = 2
      Width = 8
      Caption = 'sepPowerList'
      ImageIndex = 6
      Style = tbsSeparator
    end
    object ToolButton5: TToolButton
      Left = 77
      Top = 2
      Action = dmMain.actAddMachine
    end
    object ToolButton6: TToolButton
      Left = 100
      Top = 2
      Action = dmMain.actDeleteMachine
    end
    object ToolButton4: TToolButton
      Left = 123
      Top = 2
      Action = dmMain.actSearchMachines
    end
    object ToolButton3: TToolButton
      Left = 146
      Top = 2
      Action = dmMain.actLoadMachines
    end
    object ToolButton7: TToolButton
      Left = 169
      Top = 2
      Action = dmMain.actScanMachines
    end
  end
  object mnuMain: TMainMenu
    Images = dmResource.imlMain
    Left = 56
    Top = 280
    object mnuFile: TMenuItem
      Caption = 'File'
      object mnuFileExit: TMenuItem
        Action = dmMain.actFileExit
      end
    end
    object mnuList: TMenuItem
      Caption = 'List'
      object mnuAddMachine: TMenuItem
        Action = dmMain.actAddMachine
      end
      object mnuDeleteMachine: TMenuItem
        Action = dmMain.actDeleteMachine
      end
      object mnuSearchMachines: TMenuItem
        Action = dmMain.actSearchMachines
      end
      object mnuLoadMachines: TMenuItem
        Action = dmMain.actLoadMachines
      end
      object mnuScanMachines: TMenuItem
        Action = dmMain.actScanMachines
      end
    end
    object mnuMachine: TMenuItem
      Caption = 'Machine'
      object mnuScanMachine: TMenuItem
        Action = dmMain.actScanMachine
      end
      object mnuStartMachine: TMenuItem
        Action = dmMain.actStartMachine
      end
      object mnuShutdownMachine: TMenuItem
        Action = dmMain.actShutdownMachine
      end
    end
    object mnuHelp: TMenuItem
      Caption = 'Help'
      object mnuHelpAbout: TMenuItem
        Action = dmMain.actHelpAbout
      end
    end
  end
  object pmnuMachines: TPopupMenu
    Images = dmResource.imlMain
    Left = 104
    Top = 280
    object pmnuScanMachine: TMenuItem
      Action = dmMain.actScanMachine
    end
    object pmnuStartMachine: TMenuItem
      Action = dmMain.actStartMachine
    end
    object pmnuShutdownMachine: TMenuItem
      Action = dmMain.actShutdownMachine
    end
  end
end
