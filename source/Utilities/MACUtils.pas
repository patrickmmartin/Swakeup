unit MACUtils;

interface

function GetRemoteMacAddress(const IP: AnsiString): string;

implementation

uses
  Windows, { DWORD }
  Winsock  {inet_addr }
  ;

function GetRemoteMacAddress(const IP: AnsiString): string;
// implements http://msdn.microsoft.com/en-us/library/aa366358(VS.85).aspx
type
  TSendARP = function(DestIp: DWORD; srcIP: DWORD; pMacAddr: pointer; PhyAddrLen: Pointer): DWORD; stdcall;
const
  HexChars: array[0..15] of AnsiChar = '0123456789ABCDEF';
var dwRemoteIP: DWORD;
    PhyAddrLen: Longword;
    pMacAddr : array [0..7] of byte;
    I: integer;
    SendARPLibHandle: THandle;
    SendARP: TSendARP;
begin
  result := '';
  SendARPLibHandle := LoadLibrary('iphlpapi.dll');
  if SendARPLibHandle<>0 then
  try
    SendARP := GetProcAddress(SendARPLibHandle,'SendARP');
    if @SendARP=nil then
      exit; // we are not under 2K or later
    dwremoteIP := inet_addr(pointer(IP));
    if dwremoteIP<>0 then begin
      PhyAddrLen := 8;
      if SendARP(dwremoteIP, 0, @pMacAddr, @PhyAddrLen)=NO_ERROR then begin
        if PhyAddrLen=6 then
        begin
          for i := 0 to 5 do
          begin
            if (i <> 0) then
              Result := Result + '-';

            Result := Result + HexChars[pMacAddr[i] shr 4];
            Result := Result + HexChars[pMacAddr[i] and $F];
          end;
        end;
      end;
    end;
  finally
    FreeLibrary(SendARPLibHandle);
  end;
end;
end.
