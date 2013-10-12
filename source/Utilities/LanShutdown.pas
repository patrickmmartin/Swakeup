unit LanShutdown;

interface

procedure RemoteShutdown(const ComputerName, ShutdownMessage : string ;
                         const Timeout : Cardinal ;
                         const Force, Reboot : Boolean);

implementation

uses
  Windows,    {  }
  SysUtils    { Exception }
  , WinError;

const

  SE_SHUTDOWN_NAME = 'SeShutdownPrivilege';
  SE_REMOTE_SHUTDOWN_NAME = 'SeRemoteShutdownPrivilege';

var
  hToken: THandle;
  TokenPrivileges: TTokenPrivileges;
  RetuurnLength: DWORD = 0;

procedure EnablePrivileges(const ComputerName : string);
var
  PrivilegeName: PChar;
  LocalComputerName : array[0..32] of char;
  LocalComputerNameLen : DWORD;
begin
  if not OpenProcessToken(GetCurrentProcess,
                          TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, hToken) then
    raise EOsError.Create('OpenProcessToken failed');

  LocalComputerNameLen := 32;
  GetComputerName(LocalComputerName, LocalComputerNameLen);

  if AnsiSameText(ComputerName, LocalComputerName) then
    PrivilegeName := SE_SHUTDOWN_NAME
  else
    PrivilegeName := SE_REMOTE_SHUTDOWN_NAME;
  if not LookupPrivilegeValue(PChar(ComputerName), PrivilegeName,
                              TokenPrivileges.Privileges[0].Luid) then
    raise EOsError.Create('LookupPrivilegeValue failed');
  TokenPrivileges.PrivilegeCount := 1;
  TokenPrivileges.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;
  AdjustTokenPrivileges(hToken, False, TokenPrivileges, 0, nil, RetuurnLength);
  if GetLastError <> ERROR_SUCCESS then
    raise EOsError.Create('AdjustTokenPrivileges failed');
end;

procedure DisablePrivileges;
begin
  TokenPrivileges.Privileges[0].Attributes := 0;
  AdjustTokenPrivileges(hToken, False, TokenPrivileges, 0, nil, RetuurnLength);
  if GetLastError <> ERROR_SUCCESS then
    raise EOsError.Create('AdjustTokenPrivileges failed');
end;

procedure RemoteShutdown(const ComputerName, ShutdownMessage : string ;
                         const Timeout : Cardinal ;
                         const Force, Reboot : Boolean);
begin
  EnablePrivileges(ComputerName);
  try
    if not InitiateSystemShutdown(PChar(ComputerName),
                                  PChar(ShutdownMessage),
                                  Timeout,
                                  Force,
                                  Reboot) then
      raise Exception.Create('Problem in initiating shutdown :' + SysErrorMessage(GetLastError));
  finally
    DisablePrivileges;
  end;
end;

end.
