unit NetInfo;

interface

uses
  Windows     { TNetResource }
  ;

type

  TResourceEvent = procedure (const Name, Comment : string) of object;
  TEnumProgressEvent = procedure (const Items, Count : Integer) of object;

  TNetEnumerator = class
  private
    FOnContainer: TResourceEvent;
    FOnServer: TResourceEvent;
    FOnProgress: TEnumProgressEvent;
    procedure HandleEntry(const NetResource: TNetResource);
    function NetEnumerate(const NetResource: PNetResource ;
                           var ResourcesEnumerated, ResourcesToEnumerate : Cardinal): boolean;
    procedure HandleError(const ErrorCode: DWORD; const Func: string);

    procedure DoContainer(const NetResource: TNetResource);
    procedure DoServer(const NetResource: TNetResource);
    procedure DoProgress(const ResourcesEnumerated, ResourcesToEnumerate : Cardinal);
  public
    procedure Enumerate;
    property OnContainer : TResourceEvent read FOnContainer write FOnContainer;
    property OnServer : TResourceEvent read FOnServer write FOnServer;
    property OnProgress : TEnumProgressEvent read FOnProgress write FOnProgress;
  end;

implementation

uses
  SysUtils         { SysErrorMessage }
  ;

resourcestring
  sWNetGetLastErrorFailedFmt = 'WNetGetLastError failed; error %ld.';
  sWNetFailedFmt  = '%s failed with code %ld; %s."';

type
  PNetResourceArray = ^TNetResourceArray;
  TNetResourceArray = array[0..32767] of TNetResource;

function ResourceDisplay(const DisplayType : DWORD) : string;
begin
  case DisplayType of

    RESOURCEDISPLAYTYPE_SERVER :
      Result := 'RESOURCEDISPLAYTYPE_SERVER';
    RESOURCEDISPLAYTYPE_GENERIC :
      Result := 'RESOURCEDISPLAYTYPE_GENERIC';
    RESOURCEDISPLAYTYPE_DOMAIN :
      Result := 'RESOURCEDISPLAYTYPE_DOMAIN';
    RESOURCEDISPLAYTYPE_SHARE :
      Result := 'RESOURCEDISPLAYTYPE_SHARE';
    RESOURCEDISPLAYTYPE_FILE :
      Result := 'RESOURCEDISPLAYTYPE_FILE';
    RESOURCEDISPLAYTYPE_GROUP :
      Result := 'RESOURCEDISPLAYTYPE_GROUP';
    RESOURCEDISPLAYTYPE_NETWORK :
      Result := 'RESOURCEDISPLAYTYPE_NETWORK';
    RESOURCEDISPLAYTYPE_ROOT :
      Result := 'RESOURCEDISPLAYTYPE_ROOT';
    RESOURCEDISPLAYTYPE_SHAREADMIN :
      Result := 'RESOURCEDISPLAYTYPE_SHAREADMIN';
    RESOURCEDISPLAYTYPE_DIRECTORY :
      Result := 'RESOURCEDISPLAYTYPE_DIRECTORY';
    RESOURCEDISPLAYTYPE_TREE :
      Result := 'RESOURCEDISPLAYTYPE_TREE';
    RESOURCEDISPLAYTYPE_NDSCONTAINER :
      Result := 'RESOURCEDISPLAYTYPE_NDSCONTAINER';
    else
      Result := 'unknown: ' + IntToStr(DisplayType);
 end;

end;

procedure TNetEnumerator.HandleEntry(const NetResource : TNetResource);
begin

  OutputDebugString(PChar(ResourceDisplay(NetResource.dwDisplayType)));

  case NetResource.dwDisplayType of

    RESOURCEDISPLAYTYPE_SERVER :
      DoServer(NetResource);

    RESOURCEDISPLAYTYPE_GENERIC,
    RESOURCEDISPLAYTYPE_DOMAIN,
    RESOURCEDISPLAYTYPE_SHARE,
    RESOURCEDISPLAYTYPE_FILE,
    RESOURCEDISPLAYTYPE_GROUP,
    RESOURCEDISPLAYTYPE_NETWORK,
    RESOURCEDISPLAYTYPE_ROOT,
    RESOURCEDISPLAYTYPE_SHAREADMIN,
    RESOURCEDISPLAYTYPE_DIRECTORY,
    RESOURCEDISPLAYTYPE_TREE,
    RESOURCEDISPLAYTYPE_NDSCONTAINER :
      DoContainer(NetResource);

  end;
end;

function TNetEnumerator.NetEnumerate(const NetResource : PNetResource ;
                                   var ResourcesEnumerated, ResourcesToEnumerate : Cardinal): boolean;
var
  dwResult, ResultEnum : DWORD;
  hEnum : THandle;
  cbBuffer : DWORD;      // 16K is a good size
  cEntries : DWORD; // enumerate all possible entries
  PNetRes : PNetResourceArray ;     // pointer to enumerated structures
  i : DWORD;
begin

  cbBuffer := 16384;      // 16K is a good size
  cEntries := $FFFFFFFF; // enumerate all possible entries

   if not Assigned(NetResource) then
   begin
     ResourcesEnumerated := 0;
     ResourcesToEnumerate := 1;
   end;

   DoProgress(ResourcesEnumerated, ResourcesToEnumerate);

   Inc(ResourcesEnumerated);

   dwResult := WNetOpenEnum(RESOURCE_GLOBALNET,
                            RESOURCETYPE_ANY,
                            0,                 // enumerate all resources
                            NetResource,       // NULL first time this function is called
                            hEnum);            // handle to resource

    if ( (dwResult <> NO_ERROR )) then
    begin
        HandleError(dwResult, 'WNetOpenEnum');
    end;
    
    repeat

      GetMem(PNetRes, 16384);

      ResultEnum := WNetEnumResource(hEnum, // resource handle
                    cEntries,               // defined locally as 0xFFFFFFFF
                    PNetRes,                // LPNETRESOURCE
                    cbBuffer);              // buffer size

      if (ResultEnum = NO_ERROR) then
      begin
          Inc(ResourcesToEnumerate, cEntries);
          for i := 0 to cEntries - 1 do
          begin
            HandleEntry(PNetRes[i]);
           if ( (RESOURCEUSAGE_CONTAINER = (PNetRes[i].dwUsage and RESOURCEUSAGE_CONTAINER))
                  and not (PNetRes[i].dwDisplayType = RESOURCEDISPLAYTYPE_SERVER) ) then
          begin

            NetEnumerate(@(PNetRes[i]), ResourcesEnumerated, ResourcesToEnumerate);
          end;
        end;
      end
      else if (ResultEnum <> ERROR_NO_MORE_ITEMS) then
      begin
          HandleError(ResultEnum, 'WNetEnumResource');
          break;
      end;
      Dispose(PNetRes);
    until (ResultEnum = ERROR_NO_MORE_ITEMS);

    dwResult := WNetCloseEnum(hEnum);

    if (dwResult <> NO_ERROR) then
    begin
        HandleError(dwResult, 'WNetCloseEnum');
    end;

    Result := TRUE;

end;

procedure TNetEnumerator.HandleError(const ErrorCode: DWORD; const Func: string);
var
  WNetResult, LastError : DWORD;
  Description, Provider : array[0..256] of char;
  MessageStr : string;
  Index : integer;
begin

    if (ErrorCode <> ERROR_EXTENDED_ERROR) then
    begin
      MessageStr := SysErrorMessage(ErrorCode) + '.';
    end
    else
    begin
      WNetResult := WNetGetLastError(LastError,
                                     Description,  sizeof(Description),
                                     Provider, sizeof(Provider));

        if(WNetResult <> NO_ERROR) then
        begin
          MessageStr := Format(sWNetGetLastErrorFailedFmt, [WNetResult]);
        end;

      MessageStr := Format(sWNetFailedFmt, [Provider, LastError, Description]);
    end;

  Index := Pos(MessageStr, #13#10);
  while (Index > 0) do
  begin
    Delete(MessageStr, Index, 2);
    Insert(' ', MessageStr, Index);
    Index := Pos(MessageStr, #13#10);
  end;


  { TODO : implement this }
  // AddMessage(MessageStr, MessageSeverity);

end;

procedure TNetEnumerator.Enumerate;
var
  ComputerName : array[0..MAX_COMPUTERNAME_LENGTH] of Char;
  dwSize : DWORD;
  ResourcesEnumerated, ResourcesToEnumerate : Cardinal;
begin

  ResourcesEnumerated := 0;
  ResourcesToEnumerate := 0;

  NetEnumerate(nil, ResourcesEnumerated, ResourcesToEnumerate);
  
end;


procedure TNetEnumerator.DoContainer(const NetResource: TNetResource);
var
  ObjectName : string;
begin
  if Assigned(FonContainer) then
  begin
    if Assigned(NetResource.lpRemoteName) then
      ObjectName := NetResource.lpRemoteName
    else
      ObjectName := NetResource.lpProvider;
      FOnContainer(ObjectName, NetResource.lpComment);
  end;
end;

procedure TNetEnumerator.DoServer(const NetResource: TNetResource);
var
 ServerName : string;
begin
  if Assigned(FonServer) then
  begin
    ServerName := NetResource.lpRemoteName;

    if (Pos('\\', ServerName) = 1) then
      Delete(ServerName, 1, 2);

    FOnServer(ServerName, NetResource.lpComment);
  end;
end;

procedure TNetEnumerator.DoProgress(const ResourcesEnumerated,
  ResourcesToEnumerate: Cardinal);
begin
  if Assigned(fOnProgress) then
    FOnProgress(ResourcesEnumerated, ResourcesToEnumerate);
end;

end.

