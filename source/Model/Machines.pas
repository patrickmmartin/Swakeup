unit Machines;

interface

type
  TMachine = record
    Name, MAC, Comment : string;
  end;

  TMachines = array of TMachine;

  TMachineManager = class
  private
    FConfigFile : string;
    FMachines : TMachines;
    procedure SetMachines(const Value : TMachines);
    function GetMachines : TMachines;
  public
    procedure ReadMachines;
    procedure WriteMachines;
    procedure ClearMachines;
    procedure AddMachine(const Name, MAC, Comment : string);
    property Machines : TMachines read GetMachines write SetMachines;
    property ConfigFile : string read FConfigFile write FConfigFile;
  end;

  function MachineManager : TMachineManager;

implementation

uses
  Classes,    { TStringList }
  Forms,      { Application }
  SysUtils    { ExtractFilePath  }
  ;

var

  _MachineManager : TMachineManager = nil;

function MachineManager : TMachineManager;
begin
  if not Assigned(_MachineManager) then
    _MachineManager := TMachineManager.Create;
  Result := _MachineManager;
end;


procedure TMachineManager.SetMachines(const Value : TMachines);
begin
  FMachines := Value;
end;

function TMachineManager.GetMachines : TMachines;
begin
  Result := FMachines;
end;

function ParseMachineEntry(const Line : string) : TMachine;
var
  StringList : TStringList;
begin
  StringList := TStringList.Create;
  try
    StringList.CommaText := Line;
    if StringList.Count < 2 then
      raise Exception.CreateFmt('Unexpected no of entries (%d) expected 2 or more', [StringList.Count]);
     Result.Name := StringList[0];
     Result.MAC := StringList[1];
     if (StringList.Count > 2) then
       Result.Comment := StringList[2];
  finally
    StringList.Free;
  end;

end;

procedure TMachineManager.ReadMachines;
var
  MachineList : TStringList;
  TempMachines : TMachines;
  i : integer;
  hostsfilename : string;
begin
  hostsfilename := ExtractFilePath(Application.ExeName) + FConfigFile;
  if not (FileExists(hostsfilename))
    then Exit;

  MachineList := TStringList.Create;
  try
    MachineList.LoadFromFile(hostsfilename);
    SetLength(TempMachines, MachineList.Count);

      { TODO : this could handle files with invalid lines }
    for i := 0 to MachineList.Count - 1 do
      TempMachines[i] := ParseMachineEntry(MachineList[i]);

      { if all kosher }
    FMachines := TempMachines;
  finally
    MachineList.Free;
  end;

end;

procedure TMachineManager.WriteMachines;
var
  MachineList, FieldList : TStringList;
  i : integer;
  hostsfilename : string;
begin
  hostsfilename := ExtractFilePath(Application.ExeName) + FConfigFile;
  MachineList := TStringList.Create;
  try
    FieldList := TStringList.Create;
    try
      for i := 0 to Length(FMachines) - 1 do
      begin
        FieldList.Clear;
        FieldList.Add(FMachines[i].Name);
        FieldList.Add(FMachines[i].MAC);
        FieldList.Add(FMachines[i].Comment);
        MachineList.Add(FieldList.CommaText);
      end;

      MachineList.SaveToFile(hostsfilename);

      finally
        FieldList.Free;
      end;

  finally
    MachineList.Free;
  end;
end;

procedure TMachineManager.ClearMachines;
begin
  SetLength(FMachines, 0);
end;

procedure TMachineManager.AddMachine(const Name, MAC, Comment: string);
var
  i : integer;
  found : boolean;
begin

  found := false;
  { to avoid duplicates when the MAC address is blank
    https://github.com/patrickmmartin/Swakeup/issues/22 }
    if MAC = '' then
      exit;

  for i := 0 to Length(FMachines) - 1 do
  begin
    { a match is on the MAC address }
    if (FMachines[i].MAC = MAC) then
    begin
      FMachines[i].Name := Name;
      FMachines[i].Comment := Comment;
      Found := true;
      break;
    end;
  end;

  if not found then
  begin
    i := Length(FMachines);
    SetLength(FMachines, i + 1);
    FMachines[i].MAC := MAC;
    FMachines[i].Name := Name;
    FMachines[i].Comment := Comment;
  end;


end;

end.
