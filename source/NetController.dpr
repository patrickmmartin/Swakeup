program NetController;

uses
  Forms,
  NetInfo in 'Utilities\NetInfo.pas',
  XPMenu in 'Forms\XPMenu.pas',
  MainF in 'Forms\MainF.pas' {frmMain},
  LanWake in 'Utilities\LanWake.pas',
  LanShutdown in 'Utilities\LanShutdown.pas',
  WinError in 'Utilities\WinError.pas',
  Icmp in 'Imports\Icmp.pas',
  MainDM in 'DataModules\MainDM.pas' {dmMain: TDataModule},
  Machines in 'Model\Machines.pas',
  ServerInfo in 'Utilities\ServerInfo.pas',
  ResourceDM in 'DataModules\ResourceDM.pas' {dmResource: TDataModule},
  WMIUtils in 'Utilities\WMIUtils.pas',
  COMUtils in 'Utilities\COMUtils.pas',
  CursorHelper in 'Forms\CursorHelper.pas',
  MACUtils in 'Utilities\MACUtils.pas',
  NameUtils in 'Utilities\NameUtils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Net Controller';
  Application.CreateForm(TdmMain, dmMain);
  Application.CreateForm(TdmResource, dmResource);
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.

