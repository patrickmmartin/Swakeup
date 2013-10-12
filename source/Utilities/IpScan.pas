unit IPScan;

interface

uses
  Windows,
  SysUtils,
  WinSock,
  Icmp,
  NB30;

const
  MAX_THREAD_COUNT = 16; { the recommended limit is 16 active threads per
                           process on single processor systems. }

type
  PNBStat = ^TNBStat;
  TNBStat = packed record
    AdapterStatus: TAdapterStatus;
    NameBuffer: array[0..254] of TNameBuffer;
  end;

  PNBInfo = ^TNBInfo;
  TNBInfo = packed record
    ComputerName: string[NCBNAMSZ];
    GroupName: string[NCBNAMSZ];
    MacAddress: string[17];
  end;

var
  StartAddress, EndAddress, CurrentAddress: Longint;
  dwTimeOut: DWORD = 1000;
  WSAData: TWSAData;
  LanaEnum: TLanaEnum;
  hIcmp: THandle;
  Params: array[0..MAX_THREAD_COUNT - 1] of Longint;
  Handles: array[0..MAX_THREAD_COUNT - 1] of THandle;
  CSect: TRTLCriticalSection;
  i, j: Integer;
  ThreadID: DWORD;

implementation

function GetLana(var LanaEnum: TLanaEnum): Boolean;
var
  NCB: TNCB;
begin
  FillChar(LanaEnum, SizeOf(LanaEnum), 0);
  FillChar(NCB, SizeOf(NCB), 0);
  with NCB do
  begin
    ncb_command := Char(NCBENUM);
    ncb_buffer := PChar(@LanaEnum);
    ncb_length := SizeOf(TLanaEnum);
    Netbios(@NCB);
    Result := (ncb_retcode = Char(NRC_GOODRET)) and (Byte(LanaEnum.length) > 0);
  end;
end;

function NBReset(const LanaNum: Char): Boolean;
var
  NCB: TNCB;
begin
  FillChar(NCB, SizeOf(NCB), 0);
  with NCB do
  begin
    ncb_command := Char(NCBRESET);
    ncb_lana_num := LanaNum;
    Netbios(@NCB);
    Result := (ncb_retcode = Char(NRC_GOODRET));
  end;
end;

function GetNetBiosInfo(const LanaNum: Char; const IpAddress: string;
  var NBInfo: TNBInfo): Boolean;
var
  NCB: TNCB;
  NBStat: TNBStat;
  i: Integer;
begin
  FillChar(NCB, SizeOf(TNCB), 0);
  FillChar(NBStat, SizeOf(TNBStat), 0);
  with NCB do
  begin
    ncb_command := Char(NCBASTAT);
    ncb_buffer := PChar(@NBStat);
    ncb_length := SizeOf(TNBStat);
    StrCopy(ncb_callname, PChar(IpAddress));
    ncb_lana_num := LanaNum;
    NetBios(@NCB);
    Result := ncb_retcode = Char(NRC_GOODRET);
    with NBStat, NBInfo do
      if Result then
      begin
        for i := 0 to AdapterStatus.name_count - 1 do
          if (NameBuffer[i].Name[15] = #0) then
          begin
            case NameBuffer[i].name_flags of
              Char(UNIQUE_NAME + REGISTERED):
                ComputerName := Trim(NameBuffer[i].Name);
              Char(GROUP_NAME + REGISTERED):
                GroupName := Trim(NameBuffer[i].Name);
            end;
            if (ComputerName <> '') and (GroupName <> '') then
              Break;
          end;
        MacAddress := Format('%2.2x-%2.2x-%2.2x-%2.2x-%2.2x-%2.2x', [
                             Byte(AdapterStatus.adapter_address[0]),
                             Byte(AdapterStatus.adapter_address[1]),
                             Byte(AdapterStatus.adapter_address[2]),
                             Byte(AdapterStatus.adapter_address[3]),
                             Byte(AdapterStatus.adapter_address[4]),
                             Byte(AdapterStatus.adapter_address[5])]);
      end
      else
      begin
        ComputerName := '?';
        GroupName := '?';
        MacAddress := '?-?-?-?-?-?';
      end;
  end;
end;

function Ping(IpAddress: DWORD): Boolean;
const
  BUFFER_SIZE  = 32;
var
  dwRetVal: DWORD;
  PingBuffer: Pointer;
  pIpe: PIcmpEchoReply;
begin
  GetMem(pIpe, SizeOf(TICMPEchoReply) + BUFFER_SIZE);
  try
    GetMem(PingBuffer, BUFFER_SIZE);
    try
      FillChar(PingBuffer^, BUFFER_SIZE, $AA);
      pIpe^.Data := PingBuffer;
      dwRetVal := IcmpSendEcho(hIcmp, IpAddress, PingBuffer, BUFFER_SIZE, nil,
                               pIpe, SizeOf(TICMPEchoReply) + BUFFER_SIZE, dwTimeOut);
      Result := dwRetVal <> 0;
    finally
      FreeMem(PingBuffer);
    end;
  finally
    FreeMem(pIpe);
  end;
end;

function Execute(P: Pointer): Integer;
var
  HostByteOrder: DWORD;
  IpAddress: string;
  i: Integer;
  NBInfo: TNBInfo;
begin
  HostByteOrder := ntohl(PDWORD(P)^);
  if Ping(HostByteOrder) then
  begin
    IpAddress := Format('%d.%d.%d.%d', [HostByteOrder and $FF,
                                       (HostByteOrder shr 8) and $FF,
                                       (HostByteOrder shr 16) and $FF,
                                       (HostByteOrder shr 24) and $FF]);
    for i := 0 to Byte(LanaEnum.length) - 1 do
    begin
      FillChar(NBInfo, SizeOf(NBInfo), 0);
      if GetNetBiosInfo(LanaEnum.lana[i], IpAddress, NBInfo) then
        Break;
    end;
    EnterCriticalSection(CSect);
    try
      Writeln(Format('%-16s%-16s%-16s%-17s', [IpAddress,
                                              NBInfo.ComputerName,
                                              NBInfo.GroupName,
                                              NBInfo.MacAddress]));
    finally
      LeaveCriticalSection(CSect);
    end;
  end;
  Result := 0;
end;

begin

  (*
  if (ParamCount < 2) or (ParamCount > 4) then
  begin
    Writeln(#13#10'Displays network information: IP Address, Computer Name, Group, MAC Address.'#13#10#13#10 +
      'Usage: ipscan startIP endIP [-w timeout]'#13#10#13#10 +
      '-w timeout  Interval in milliseconds to wait for each ICMP echo reply.'#13#10 +
      '            The default is 1000.'#13#10#13#10 +
      'Example: ipscan 167.33.34.1 167.33.34.254 -w 3000'#13#10#13#10 +
      'This program is freeware.'#13#10 +
      'Author: Vadim Crits'#13#10);
    Halt;
  end;
  StartAddress := htonl(inet_addr(PChar(ParamStr(1))));
  if (StartAddress = INADDR_NONE) or (Pos('.', ParamStr(1)) = 0) then
  begin
    Writeln(#13#10'Invalid startIP.');
    Halt;
  end;
  EndAddress := htonl(inet_addr(PChar(ParamStr(2))));
  if (EndAddress = INADDR_NONE) or (Pos('.', ParamStr(2)) = 0) then
  begin
    Writeln(#13#10'Invalid endIP.');
    Halt;
  end;
  if StartAddress > EndAddress then
  begin
    Writeln(#13#10'startIP cannot be greater than endIP.');
    Halt;
  end;
  if (ParamCount > 2) then
    if FindCmdLineSwitch('w', ['-'], True) then
      try
        if StrToInt(ParamStr(4)) > 0 then
          dwTimeOut := StrToInt(ParamStr(4))
        else
          Abort;
      except
        Writeln(#13#10'Invalid timeout value.');
        Halt;
      end
    else
    begin
      Writeln(#13#10'Invalid command line switch.');
      Halt;
    end;
  if WSAStartup($0101, WSAData) <> 0 then
  begin
    Writeln(#13#10'Could not initialize Winsock.');
    Halt;
  end;
  if not GetLana(LanaEnum) then
  begin
    Writeln(#13#10'Problem with network adapter.');
    Halt;
  end;
  if Win32Platform = VER_PLATFORM_WIN32_NT then
    for i := 0 to Byte(LanaEnum.length) - 1 do
      if not NBReset(LanaEnum.lana[i]) then
      begin
        Writeln(#13#10'Reset Lana error.');
        Halt;
      end;
  hIcmp := IcmpCreateFile;
  if hIcmp = INVALID_HANDLE_VALUE then
  begin
    Writeln(#13#10'Could not initialize icmp.dll.');
    Halt;
  end;
  Writeln;
  Writeln(Format('%-16s%-16s%-16s%-17s', ['IP Address', 'Computer Name',
                                          'Group', 'MAC Address']));
  Writeln(Format('%s %s %s %s', ['===============', '===============',
                                 '===============', '=================']));
  i := 0;
  CurrentAddress := StartAddress;
  FillChar(Params, SizeOf(Params), 0);
  FillChar(Handles, SizeOf(Handles), 0);
  InitializeCriticalSection(CSect);
  try
    while True do
    begin
      Params[i] := CurrentAddress;
      Handles[i] := BeginThread(nil, 0, Execute, @Params[i], 0, ThreadID);
      Inc(i);
      if (i = MAX_THREAD_COUNT) or (CurrentAddress = EndAddress) then
      begin
        WaitForMultipleObjects(i, @Handles, True, INFINITE);
        for j := 0 to i - 1 do
          CloseHandle(Handles[j]);
        FillChar(Params, SizeOf(Params), 0);
        FillChar(Handles, SizeOf(Handles), 0);
        i := 0;
      end;
      if CurrentAddress = EndAddress then
        Break
      else
        Inc(CurrentAddress);
    end;
  finally
    DeleteCriticalSection(CSect);
    IcmpCloseHandle(hIcmp);
    WSACleanup;
  end;
  *)
end.
