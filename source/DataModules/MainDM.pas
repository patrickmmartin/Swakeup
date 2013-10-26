unit MainDM;

interface

uses
  SysUtils,
  Classes,
  AppEvnts,
  ActnList,
  StdActns,
  ImgList,
  Controls,
  ComCtrls,
  Machines

  ;

type
  TdmMain = class(TDataModule)
    alMain: TActionList;
    aeMain: TApplicationEvents;
    actFileExit: TFileExit;
    actHelpAbout: TAction;
    actAddMachine: TAction;
    actDeleteMachine: TAction;
    actSearchMachines: TAction;
    actStartMachine: TAction;
    actShutdownMachine: TAction;
    actLoadMachines: TAction;
    actScanMachines: TAction;
    actScanMachine: TAction;
    actSaveMachines: TAction;
    procedure MainFormCreate(Sender: TObject);
    procedure actScanMachinesExecute(Sender: TObject);
    procedure actScanMachineExecute(Sender: TObject);
    procedure aeMainHint(Sender: TObject);
    procedure actShutdownMachineExecute(Sender: TObject);
    procedure actStartMachineExecute(Sender: TObject);
    procedure actLoadMachinesExecute(Sender: TObject);
    procedure actSearchMachinesExecute(Sender: TObject);
    procedure actSaveMachinesExecute(Sender: TObject);
  private
    {  }
    procedure ViewMachines(const Machines : TMachines);
    procedure DoServer(const Name, Comment : string);
  public
    procedure MenuMachinesSetup(Sender: TObject);
    procedure MachinesSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
  end;

var
  dmMain: TdmMain;

implementation

uses
  MainF,
  LanWake,
  LanShutdown,
  Windows,
  ServerInfo,
  WMIUtils,
  ResourceDM,
  Variants,
  CursorHelper,
  Forms,
  NetInfo,
  NameUtils,
  MACUtils;

{$R *.dfm}

procedure TdmMain.actLoadMachinesExecute(Sender: TObject);
begin
  HourGlass;
  MachineManager.ConfigFile := 'defaulthosts.txt';
  MachineManager.ReadMachines;
  ViewMachines(MachineManager.Machines);
end;

procedure TdmMain.actStartMachineExecute(Sender: TObject);
begin
  { TODO : 
this could perhaps be more ideally the subnet broadcast address ? 
 - really depends on what's in the ini file }
  SendMagicPacket(frmMain.lvMachines.Selected.SubItems[0], '255.255.255.255', 9);
end;

procedure TdmMain.MenuMachinesSetup(Sender: TObject);
begin
  { TODO : was there supposed to be something in here? }
end;

procedure TdmMain.MachinesSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
begin

  { pass on }
  actScanMachine.Enabled := Selected and Assigned(Item);

  actStartMachine.Enabled := Selected and Assigned(Item) and (Item.SubItems[3] = '');

  actShutdownMachine.Enabled := Selected and Assigned(Item) and  (Item.SubItems[2] <> '');

end;


procedure TdmMain.actShutdownMachineExecute(Sender: TObject);
var
  ComputerName : array[0..32] of Char;
  UserName : array[0..256] of Char;
  Size : DWORD;
begin
  Size := sizeof(UserName) -1;
  GetUserName(UserName, Size);

  Size := sizeof(ComputerName) -1;
  GetComputerName(ComputerName, Size);

  PowerOffMachine(frmMain.lvMachines.Selected.Caption);

end;

procedure TdmMain.aeMainHint(Sender: TObject);
begin
  frmMain.sbMain.Panels[0].Text := Application.Hint;
end;

procedure TdmMain.actScanMachineExecute(Sender: TObject);
var
  Item : TListItem;
  MachineSystem : OleVariant;
begin
  if not Assigned(frmMain.lvMachines.Selected) then
    Exit;
  Item := frmMain.lvMachines.Selected;

  frmMain.sbMain.Panels[0].Text := 'Testing ' + Item.Caption;
  frmMain.sbMain.Refresh;
  Item.SubItems[2] := '';
  Item.SubItems[3] := '';
  Item.SubItems[4] := '';
  try
    try
      with ServerStats.GetCurrentAndUpTime(Item.Caption) do
      begin
        Item.SubItems[3] := FormatDateTime('hh mm', UpTime);
        Item.SubItems[4] := DateTimeToStr(Current);
      end;

        MachineSystem := GetMachineOS(Item.Caption, [wbemPrivilegeSystemEnvironment]);
        if not VarIsEmpty(MachineSystem) then
        begin
          Item.SubItems[2] := MachineSystem.Status;
        end;
    except
      {}
    end;
  finally
    frmMain.sbMain.Panels[0].Text := '';
  end;
end;

procedure TdmMain.actScanMachinesExecute(Sender: TObject);
var
  i : integer;
  Item : TListItem;
begin
  Item := frmMain.lvMachines.Selected;
  try
    for i := 0 to frmMain.lvMachines.Items.Count - 1 do
    begin
      frmMain.lvMachines.Selected := frmMain.lvMachines.Items[i];
      frmMain.lvMachines.Refresh;
      actScanMachine.Execute;
    end;
  finally
    frmMain.lvMachines.Selected := Item;
  end;
  frmMain.lvMachines.Selected := Item;
end;

procedure TdmMain.MainFormCreate(Sender: TObject);
begin
  frmMain.lvMachines.OnSelectItem := MachinesSelectItem;
  actLoadMachines.Execute;
end;

procedure TdmMain.ViewMachines(const Machines: TMachines);
var
  i : integer;
  Item : TListItem;
begin
  HourGlass;

  Item := frmMain.lvMachines.Items.Add();
  Item.ImageIndex := -1;
  while frmMain.lvMachines.Items.Count > 1 do
    frmMain.lvMachines.Items.Delete(0);

  for i := Low(Machines) to High(Machines) do
  begin
    with frmMain.lvMachines.Items.Insert(Item.Index) do
    begin
      ImageIndex := 0;
      StateIndex := 0;
      Caption := Machines[i].Name;
      SubItems.Text := Machines[i].MAC + #13#10#13#10#13#10#13#10#13#10#13#10;
      SubItems[1] := Machines[i].Comment;
      frmMain.lvMachines.Refresh;
    end;
  end;
  frmMain.lvMachines.Items.Delete(Item.Index);
end;



procedure TdmMain.actSearchMachinesExecute(Sender: TObject);
var
  WN : TNetEnumerator;
begin

  Screen.Cursor := crHourGlass;
  WN := TNetEnumerator.Create;
  try

    WN.OnContainer := nil;
    WN.OnServer := DoServer;
    WN.OnProgress := nil;
    WN.Enumerate;
    ViewMachines(MachineManager.Machines);

  finally
    Screen.Cursor := crDefault;
    WN.Free;
  end;

end;

procedure TdmMain.DoServer(const Name, Comment: string);
var
  IPAddress, MACAddress, WSAErr : string;
begin

  if (GetIPFromHost(Name, IPAddress, WSAErr)) then
    MACAddress := GetRemoteMacAddress(IPAddress);
   MachineManager.AddMachine(Name, MACAddress, Comment);

end;

procedure TdmMain.actSaveMachinesExecute(Sender: TObject);
begin
    MachineManager.WriteMachines;
end;

end.
