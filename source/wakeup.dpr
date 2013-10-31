program wakeup;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  SysUtils,
  LanWake in 'Utilities\LanWake.pas';

procedure Usage(const ReasonStr: string);
var
  UsageStr: string;
begin

  { TODO : sort out the error codes policy }
  UsageStr :=   ReasonStr + #13#10 +
                'usage: '#13#10 +
                ExtractFileName(ParamStr(0)) + ' macaddress [port] [ipaddress]'#13#10 +
                'will send the magic packet to the specified IP address '#13#10 +
                'the port 9 will be used as the default port'#13#10 +
                'the broadcast address (255.255.255.255) will be used as the default'#13#10 +
                'return codes: 0 if functions successful, -1 for invalid arguments, non-zero otherwise.'#13#10 +
                'the error code may be a WSA code';

  WriteLn(UsageStr);

end;

procedure InvalidArgs(const ReasonStr: string);
begin

  WriteLn(ReasonStr);

end;

procedure Error(const ReasonStr: string);
begin

  WriteLn(ReasonStr);

end;

var
  port : Word;
  MacAddress, IPAddress : string;
begin

  if (ParamCount < 1) then
  begin
    Usage('one argument is required.');
    ExitCode := -1;
    Exit;
  end;

  MacAddress := ParamStr(1);
  port := StrToIntDef(ParamStr(2), 9);
  IPAddress := ParamStr(3);

  if not CheckMAC(MacAddress) then
  begin
    InvalidArgs('MAC address not in the format "01#23#45#67#89#ab"'#13#10 +
                'any single char separator is accepted.' );
    ExitCode := -1;
    Exit;
  end;

  if (IPAddress = '') then
    IPAddress := '255.255.255.255';

  { TODO : this should return an error code, ideally }
  try
    SendMagicPacket(MacAddress, IPAddress, Port);
  except
    Error('error in sending');
    ExitCode := -1;
    Exit;
  end

end.
