unit ServerInfo;

interface

uses
  Windows, SysUtils;

type

  TCurrentAndUpTime = record
    Current : TDateTime;
    UpTime : TDateTime;
  end;

  TServerStats = class
  public
    function GetUpTime(const MachineName : string) : TDateTime;
    function GetCurrentTime(const MachineName : string) : TDateTime;
    function GetCurrentAndUpTime(const MachineName : string) : TCurrentAndUpTime;
  end;

function ServerStats : TServerStats;


implementation

var
  _ServerStats : TServerStats = nil;

function ServerStats : TServerStats;
begin
 if not Assigned(_ServerStats) then
   _ServerStats := TServerStats.Create;
  Result := _ServerStats;  
end;

type

  PTimeOfDayInfo = ^TTimeOfDayInfo;
  TTimeOfDayInfo = packed record
    tod_elapsedt: DWORD;
    tod_msecs: DWORD;
    tod_hours: DWORD;
    tod_mins: DWORD;
    tod_secs: DWORD;
    tod_hunds: DWORD;
    tod_timezone: Longint;
    tod_tinterval: DWORD;
    tod_day: DWORD;
    tod_month: DWORD;
    tod_year: DWORD;
    tod_weekday: DWORD;
  end;

  NET_API_STATUS = DWORD;

function NetRemoteTOD(UncServerName: LPCWSTR; BufferPtr: PBYTE): NET_API_STATUS; stdcall;
  external 'netapi32.dll' Name 'NetRemoteTOD';

function NetApiBufferFree(Buffer: Pointer): NET_API_STATUS; stdcall;
  external 'netapi32.dll' Name 'NetApiBufferFree';

function TServerStats.GetUpTime(const MachineName : string) : TDateTime;
begin
  Result := GetCurrentAndUpTime(MachineName).UpTime;
end;

function TServerStats.GetCurrentTime(const MachineName : string) : TDateTime;
begin
  Result := GetCurrentAndUpTime(MachineName).Current;
end;

function TServerStats.GetCurrentAndUpTime(const MachineName : string) : TCurrentAndUpTime;
const
  NERR_Success = 0;
var
  TimeOfDayInfo: PTimeOfDayInfo;
  ServerName: array[0..255] of WideChar;
  dwRetValue, dwSecs: DWORD;
  GMTTime: TSystemTime;
  ts: TTimeStamp;
begin
  StringToWideChar(MachineName, @ServerName, SizeOf(ServerName));
  dwRetValue := NetRemoteTOD(@ServerName, PBYTE(@TimeOfDayInfo));
  if dwRetValue <> NERR_Success then
    raise Exception.Create(SysErrorMessage(dwRetValue));
  with TimeOfDayInfo^ do
  begin
    FillChar(GMTTime, SizeOf(GMTTime), 0);
    with GMTTime do
    begin
      wYear := tod_year;
      wMonth := tod_month;
      wDayOfWeek := tod_weekday;
      wDay := tod_day;
      wHour := tod_hours;
      wMinute := tod_mins;
      wSecond := tod_secs;
      wMilliseconds := tod_hunds;
    end;
    Result.Current := SystemTimeToDateTime(GMTTime);
    if tod_timezone <> -1 then
      Result.Current := Result.Current + ((1 / 24 / 60) * -tod_timezone);
    dwSecs := tod_msecs div 1000;
    if dwSecs >= SecsPerDay then
      dwSecs := dwSecs mod SecsPerDay;
    ts.Time := dwSecs * 1000;
    ts.Date := DateDelta;
    Result.UpTime := TimeStampToDateTime(ts);
  end;
  NetApiBufferFree(TimeOfDayInfo);
end;

end.
