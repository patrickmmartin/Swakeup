unit LanWake;

interface

uses
  WinSock   { WinSock methods }
  ;

function CheckMAC(const MacAddress: string): Boolean;
function CheckIP(const IpAddress: string): Boolean;
function CheckPort(const Port: string): Boolean;

const
  PHYSADDR_LEN = 6;
type
  TMacAddress = array[0..PHYSADDR_LEN - 1] of Byte;

procedure SendMagicPacket(const MacAddress, IpAddress: string; Port: Word);

implementation

uses
  Windows,  { DWORD }
  SysUtils  { StrToInt }
  ;


function CheckMAC(const MacAddress: string): Boolean;
var
  i: Integer;
  P, Start: PChar;
  s: string;
begin
  Result := True;
  try
    P := PChar(MacAddress);
    i := 0;
    while P^ <> #0 do
    begin
      Start := P;
      while not (P^ in [#0, #45]) do Inc(P);
      SetString(s, Start, P - Start);
      StrToInt(HexDisplayPrefix + s);
      Inc(i);
      if P^ <> #0 then Inc(P);
    end;
    if i <> 6 then Abort;
  except
    Result := False;
  end;
end;

function CheckIP(const IpAddress: string): Boolean;
var
  i: Integer;
  P, Start: PChar;
  s: string;
begin
  Result := True;
  try
    i := 0;
    P := PChar(IpAddress);
    while P^ <> #0 do
    begin
      Start := P;
      while not (P^ in [#0, #46]) do Inc(P);
      SetString(s, Start, P - Start);
      if not (StrToInt(s) in [0..255]) then Abort;
      Inc(i);
      Inc(P);
      if P^ <> #0 then Inc(P);
    end;
    if i <> 4 then Abort;
  except
    Result := False;
  end;
end;

function CheckPort(const Port: string): Boolean;
var
  nPort: Integer;
begin
  Result := True;
  try
    nPort := StrToInt(Port);
    if (nPort < Low(Word)) or (nPort > High(Word)) then
      Abort;
  except
    Result := False;
  end;
end;  

const
  MAGICPACKET_LEN = 102;

procedure SendMagicPacketRaw(const MacAddr : TMacAddress;
                             const IP : integer;
                             const Port : Word);
  procedure CheckWinSockResult(ResultCode: Integer; const FuncName: string);
  var
    ErrorCode: Integer;
  begin
    if ResultCode <> 0 then
    begin
      ErrorCode := WSAGetLastError;
      raise Exception.CreateFmt('Winsock Error: %s, %d, %s',
        [SysErrorMessage(ErrorCode), ErrorCode, FuncName]);
    end;
  end;

var
  WSAData: TWSAData;
  Sock: TSocket;
  Addr: TSockAddr;
  OptVal: LongBool;
  RetVal: Integer;
  Position: DWORD;
  MagicData: array[0..MAGICPACKET_LEN - 1] of Byte;
begin
  CheckWinSockResult(WSAStartup($0101, WSAData), 'WSAStartup');
  try
    Sock := socket(PF_INET, SOCK_DGRAM, IPPROTO_IP);
    if Sock = INVALID_SOCKET then
      CheckWinSockResult(Sock, 'socket');
    Addr.sin_family := AF_INET;
    Addr.sin_port := htons(Port);
    Addr.sin_addr.S_addr := IP;
    if Addr.sin_addr.S_addr = INADDR_BROADCAST then
    begin
      OptVal := True;
      CheckWinSockResult(setsockopt(Sock, SOL_SOCKET, SO_BROADCAST,
                         PChar(@OptVal), SizeOf(OptVal)), 'setsockopt');
    end;
    FillChar(MagicData, SizeOf(MagicData), $FF);
    Position := PHYSADDR_LEN;
    while Position < SizeOf(MagicData) do
    begin
      Move(MacAddr, Pointer(DWORD(@MagicData) + Position)^, PHYSADDR_LEN);
      Inc(Position, PHYSADDR_LEN);
    end;
    RetVal := sendto(Sock, MagicData, SizeOf(MagicData), 0, Addr, SizeOf(Addr));
    if RetVal = SOCKET_ERROR then
      CheckWinSockResult(RetVal, 'sendto');
    CheckWinSockResult(closesocket(Sock), 'closesocket');
  finally
    CheckWinSockResult(WSACleanup, 'WSACleanup');
  end;
end;


procedure SendMagicPacket(const MacAddress, IpAddress: string; Port: Word);
var
  MacAddr : TMacAddress;
begin

  { TODO : perhaps there could some validation before passing on from this function... }

  MacAddr[0] := StrToInt(HexDisplayPrefix + Copy(MacAddress, 1, 2));
  MacAddr[1] := StrToInt(HexDisplayPrefix + Copy(MacAddress, 4, 2));
  MacAddr[2] := StrToInt(HexDisplayPrefix + Copy(MacAddress, 7, 2));
  MacAddr[3] := StrToInt(HexDisplayPrefix + Copy(MacAddress, 10, 2));
  MacAddr[4] := StrToInt(HexDisplayPrefix + Copy(MacAddress, 13, 2));
  MacAddr[5] := StrToInt(HexDisplayPrefix + Copy(MacAddress, 16, 2));

  SendMagicPacketRaw(MacAddr, inet_addr(PChar(IpAddress)), Port);

end;


end.
