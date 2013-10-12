object dmMain: TdmMain
  OldCreateOrder = False
  Left = 214
  Top = 203
  Height = 244
  Width = 391
  object alMain: TActionList
    Images = dmResource.imlMain
    Left = 56
    Top = 16
    object actFileExit: TFileExit
      Category = 'File'
      Caption = 'E&xit'
      Hint = 'Exit|Quits the application'
      ImageIndex = 12
    end
    object actHelpAbout: TAction
      Category = 'Help'
      Caption = 'About'
      Hint = 'About this application.'
      ImageIndex = 13
    end
    object actAddMachine: TAction
      Category = 'List'
      Caption = 'Add Machine'
      Hint = 'Add|Add a machine to the list.'
      ImageIndex = 3
    end
    object actDeleteMachine: TAction
      Category = 'List'
      Caption = 'Delete Machine'
      Hint = 'Delete|Delete a machine from th.e list'
      ImageIndex = 6
    end
    object actSearchMachines: TAction
      Category = 'List'
      Caption = 'Search for Machines'
      Hint = 'Search|Search for local machines.'
      ImageIndex = 13
      OnExecute = actSearchMachinesExecute
    end
    object actStartMachine: TAction
      Category = 'Machine'
      Caption = 'Start Machine'
      Enabled = False
      Hint = 'Start|Power on the machine.'
      ImageIndex = 10
      OnExecute = actStartMachineExecute
    end
    object actShutdownMachine: TAction
      Category = 'Machine'
      Caption = 'Shutdown Machine'
      Enabled = False
      Hint = 'Shutdown|Power off the machine.'
      ImageIndex = 11
      OnExecute = actShutdownMachineExecute
    end
    object actLoadMachines: TAction
      Category = 'List'
      Caption = 'Load Machines'
      Hint = 'Load|Load Machine list from file.'
      ImageIndex = 5
      OnExecute = actLoadMachinesExecute
    end
    object actScanMachines: TAction
      Category = 'List'
      Caption = 'Scan Machines'
      Hint = 'Scan|Scan Machine List'
      ImageIndex = 2
      OnExecute = actScanMachinesExecute
    end
    object actScanMachine: TAction
      Category = 'Machine'
      Caption = 'Scan Machine'
      Enabled = False
      Hint = 'Scan|Scan Machine'
      ImageIndex = 2
      OnExecute = actScanMachineExecute
    end
  end
  object aeMain: TApplicationEvents
    OnHint = aeMainHint
    Left = 8
    Top = 16
  end
end
