unit Machines;

interface

type
  TMachine = record
    Name, MAC : string;
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
    if StringList.Count <> 2 then
      raise Exception.CreateFmt('Unexpected no of entries (%d) expected 2', [StringList.Count]);
     Result.Name := StringList[0];
     Result.MAC := StringList[1];
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

      for i := 0 to MachineList.Count - 1 do
      try
        TempMachines[i] := ParseMachineEntry(MachineList[i]);
      except
        on E : Exception do
          raise Exception.CreateFmt('Failed to read machine on line %d'#13#10'%s', [i, E.Message]);
      end;

      { if all kosher }
      FMachines := TempMachines;
  finally
    MachineList.Free;
  end;

end;

procedure TMachineManager.WriteMachines;
begin
  {todo implement }
end;

end.
