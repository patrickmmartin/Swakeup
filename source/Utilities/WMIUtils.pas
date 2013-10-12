unit WMIUtils;

interface

type
  TWbemPrivilegeEnum
   =
  (
    wbemPrivilegeCreateToken, wbemPrivilegePrimaryToken,
    wbemPrivilegeLockMemory, wbemPrivilegeIncreaseQuota,
    wbemPrivilegeMachineAccount, wbemPrivilegeTcb,
    wbemPrivilegeSecurity, wbemPrivilegeTakeOwnership,
    wbemPrivilegeLoadDriver, wbemPrivilegeSystemProfile,
    wbemPrivilegeSystemtime, wbemPrivilegeProfileSingleProcess,
    wbemPrivilegeIncreaseBasePriority, wbemPrivilegeCreatePagefile,
    wbemPrivilegeCreatePermanent, wbemPrivilegeBackup,
    wbemPrivilegeRestore, wbemPrivilegeShutdown,
    wbemPrivilegeDebug, wbemPrivilegeAudit,
    wbemPrivilegeSystemEnvironment, wbemPrivilegeChangeNotify,
    wbemPrivilegeRemoteShutdown, wbemPrivilegeUndock,
    wbemPrivilegeSyncAgent, wbemPrivilegeEnableDelegation,
    wbemPrivilegeManageVolume  //  XP onwards
  );

  TWbemPrivilegeEnums = set of TWbemPrivilegeEnum;


function GetWMIInstance(const MachineName : string = '.' ; const Privileges : TWbemPrivilegeEnums = []): OleVariant;
function GetMachineOS(const MachineName : string = '.' ; const Privileges : TWbemPrivilegeEnums = []) : OleVariant;
procedure PowerOffMachine(const MachineName : string);


implementation

uses
  ActiveX,    { IEnumVariant }
  Variants,   { VarIsEmpty }
  COMUtils,
  SysUtils;

type
  TWin32Shutdown = (LogOff = 0, Shutdown = 1, Reboot = 2, Forced = 4, PowerOff = 8);

const

TWbemPrivilegeEnumStr : array[TWbemPrivilegeEnum] of string =
(
  'CreateToken',
  'PrimaryToken',
  'LockMemory',
  'IncreaseQuota',
  'MachineAccount',
  'Tcb',
  'Security',
  'TakeOwnership',
  'LoadDriver',
  'SystemProfile',
  'Systemtime',
  'ProfileSingleProcess',
  'IncreaseBasePriority',
  'CreatePagefile',
  'CreatePermanent',
  'Backup',
  'Restore',
  'Shutdown',
  'Debug',
  'Audit',
  'SystemEnvironment',
  'ChangeNotify',
  'RemoteShutdown',
  'Undock',
  'SyncAgent',
  'EnableDelegation',
  'ManageVolume'//  'XP onwards
);


function PrivilegeStringFromSet(const Privileges : TWbemPrivilegeEnums): string;
var
  Privilege : TWbemPrivilegeEnum;
begin
  Result := '';
  if (Privileges = []) then exit;

  Result := '(';
  for Privilege := Low(TWbemPrivilegeEnum) to High(TWbemPrivilegeEnum) do
  begin
     if (Privilege in Privileges) then
       Result := Result + TWbemPrivilegeEnumStr[Privilege] + ',';
  end;
  SetLength(Result, Length(Result) - 1);
  Result := Result + ')';

end;


const
  WMIMonikerFmt = 'winmgmts:{impersonationLevel=impersonate,%s}\\%s\root\cimv2';

function GetWMIInstance(const MachineName : string = '.' ; const Privileges : TWbemPrivilegeEnums = []): OleVariant;
begin
  Result := GetDispatchFromMoniker(Format(WMIMonikerFmt, [PrivilegeStringFromSet(Privileges), MachineName]));
end;

{ http://msdn.microsoft.com/library/default.asp?url=/library/en-us/wmisdk/wmi/win32_operatingsystem.asp }

function GetMachineOS(const MachineName : string = '.' ; const Privileges : TWbemPrivilegeEnums = []) : OleVariant;
var
  objWMIService : OleVariant;
  colOperatingSystems, objOperatingSystem : OleVariant;
  ObjectEnumerator : IEnumVariant;
  NumberItem : Cardinal;
begin

  objWMIService := GetWMIInstance(MachineName, Privileges);
  Result := UnAssigned;

  if not VarisEmpty(objWMIService) then
  begin
    colOperatingSystems := objWMIService.ExecQuery ('Select * from Win32_OperatingSystem');

    if Supports((colOperatingSystems._NewEnum), IEnumVariant, ObjectEnumerator) then
    begin
      while (ObjectEnumerator.Next(1, objOperatingSystem, NumberItem) = S_OK) do
      begin
        Result := objOperatingSystem;
      end;
    end;
  end;
end;


procedure PowerOffMachine(const MachineName : string);
var
  objOperatingSystem : OleVariant;
  RetVal: Cardinal;
begin

  objOperatingSystem := GetMachineOS(MachineName, [wbemPrivilegeShutdown]);
  RetVal := StrToInt(objOperatingSystem.Win32Shutdown(PowerOff, 0));
  if Failed(RetVal) then
      raise EOSError.Create(SysErrorMessage(RetVal));
end;


end.
