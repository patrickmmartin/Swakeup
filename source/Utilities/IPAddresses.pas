unit IPAddresses;

interface

uses
  SysUtils,
  Classes
  ;

type
  EIPException = class (Exception);

procedure GetIPAddress(HostName : string ; var ResolvedName  : string  ; Addresses, Aliases : TStringList);
function GetHostFromAddress(IPAddr: string): string;

implementation

uses
  Winsock
  ;

resourcestring
  sUnknownWASErrorFmt = 'Unknown socket error %d';

function WSAErrorMessage(Code : integer) : string;
begin
  case Code of
    WSANOTINITIALISED : Result := 'A successful WSAStartup must occur before using this function.';
    WSAENETDOWN  : Result := 'The network subsystem has failed.';
    WSAHOST_NOT_FOUND  : Result := 'Authoritative Answer Host not found.';
    WSATRY_AGAIN  : Result := 'Non-Authoritative Host not found, or server failure.';
    WSANO_RECOVERY  : Result := 'Nonrecoverable error occurred.';
    WSANO_DATA  : Result := 'Valid name, no data record of requested type.';
    WSAEINPROGRESS  : Result := 'A blocking Windows Sockets 1.1 call is in progress, or the service provider is still processing a callback function.';
    WSAEFAULT  : Result := 'The name argument is not a valid part of the user address space.';
    WSAEINTR  : Result := 'The (blocking) call was canceled through WSACancelBlockingCall.';
  else
    Result := Format(sUnknownWASErrorFmt, [Code]);
  end; { case }
end;


function LookupName(const Name: string): TInAddr;
var
  HostEnt: PHostEnt;
  InAddr: TInAddr;
begin
  HostEnt := gethostbyname(PChar(Name));
  FillChar(InAddr, SizeOf(InAddr), 0);
  if HostEnt <> nil then
  begin
    with InAddr, HostEnt^ do
    begin
      S_un_b.s_b1 := h_addr^[0];
      S_un_b.s_b2 := h_addr^[1];
      S_un_b.s_b3 := h_addr^[2];
      S_un_b.s_b4 := h_addr^[3];
    end;
  end;
  Result := InAddr;
end;

  type
    TaPInAddr = array [0..10] of PInAddr;
    PaPInAddr = ^TaPInAddr;

procedure GetIPAddress(HostName : string ; var ResolvedName : string ;
                       Addresses, Aliases : TStringList);
var
  HEnt : PHostEnt;
  i : integer;
  pptr : PaPInAddr;
    GInitData : TWSADATA;
begin
  if (WSAStartup($101, GInitData) <> 0) then
    raise Exception.Create('Could not initialise Winsock.');
  try

    hent := GetHostbyname(PChar(HostName));
    if Assigned(hent) then
    begin
      Addresses.Clear();
      Aliases.Clear();

      pptr := PaPInAddr(hent^.h_addr_list);
      i := 0;
      while pptr^[I] <> nil do
      begin
        Addresses.Add(StrPas(inet_ntoa(pptr^[I]^)));
        Inc(I);
      end;

      pptr := PaPInAddr(hent^.h_aliases);
      i := 0;
      while pptr^[I] <> nil do
      begin
        Aliases.Add(StrPas(inet_ntoa(pptr^[I]^)));
        Inc(I);
      end;

      ResolvedName := hent.h_name;
    end
    else
      raise EIPException.Create(WSAErrorMessage(WSAGetLastError));
  finally
   WSACleanup;
  end;
end;


function GetHostFromAddress(IPAddr: string): string;
var
  SockAddrIn: TSockAddrIn;
  HostEnt: PHostEnt;
  WSAData: TWSAData;
begin
  WSAStartup($101, WSAData);
  SockAddrIn.sin_addr.s_addr:=inet_addr(PChar(IPAddr));
  HostEnt:= GetHostByAddr(@SockAddrIn.sin_addr.S_addr, 4, AF_INET);
  if HostEnt <> nil then
  begin
    Result := StrPas(Hostent^.h_name)
  end
  else
  begin
    Result:='';
  end;
end;


end.
