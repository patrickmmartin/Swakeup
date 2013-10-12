unit NameUtils;

interface

function GetIPFromHost (const HostName : string; var IPaddr : string; var WSAErr: string): Boolean;

implementation

uses
   Winsock,
   SysUtils
   ;


function GetIPFromHost (const HostName : string; var IPaddr : string; var WSAErr: string): Boolean;
var
  HEnt: pHostEnt;
  WSAData: TWSAData;
  i: Integer;
begin
  Result := False;
  if WSAStartup($0101, WSAData) <> 0 then begin
    WSAErr := 'Winsock is not responding."';
    Exit;
  end;
  IPaddr := '';
  begin
    HEnt := GetHostByName(PAnsiChar(HostName));
    for i := 0 to HEnt^.h_length - 1 do
     IPaddr :=
      Concat(IPaddr,
      IntToStr(Ord(HEnt^.h_addr_list^[i])) + '.');
    SetLength(IPaddr, Length(IPaddr) - 1);
    Result := True;
  end;
  WSACleanup;
end;

end.
