unit ServersF;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, ImgList, StdCtrls, ComCtrls, ExtCtrls, Buttons, Menus, ToolWin;

type
  TfrmServers = class(TForm)
    imgServer: TImage;
    pnlPages: TPanel;
    lvServers: TListView;
    tmrLocate: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure tmrLocateTimer(Sender: TObject);
    procedure LocateAll(Sender: TObject);
  private
    procedure AddServer(RemoteName, Comment : string);
    procedure DoContainer(const Name, Comment : string);
    procedure DoServer(const Name, Comment : string);
    procedure DoProgress(const Items, Count : Integer);
    procedure StatusMessage(const Msg : string);
  public
    EndPoint, Address : string;
  end;

var
  frmServers: TfrmServers;

implementation

uses
  NetInfo, XPMenu, MainDM, ResourceDM, MACUtils, NameUtils;

{$R *.dfm}

resourcestring
  sLocalMachine = 'local machine';
  sFoundServerFmt = 'found server [%s]';
  sEnumeratingContainerFmt = 'enumerating container [%s]';

{ TfrmServers }

procedure TfrmServers.StatusMessage(const Msg : string);
begin
  //
end;

procedure TfrmServers.AddServer(RemoteName, Comment: string);
var
  found : boolean;
  ListItem : TListItem;
  i: integer;
  IPAddress, WSAErr : string;
begin

  i := 0;
  found := false;
  while (i < lvServers.Items.Count) and not found do
  begin
    ListItem := lvServers.Items[i];
    if (ListItem.Caption = RemoteName) then
      found := true;
    Inc(i);  
  end;

  if not found then
  begin
     ListItem := lvServers.Items.Add();
     ListItem.Caption := RemoteName;
     ListItem.SubItems.Clear();
     ListItem.SubItems.Add(Comment);
     ListItem.ImageIndex := 0;
     //
     if (GetIPFromHost(RemoteName, IPAddress, WSAErr)) then
     ListItem.SubItems.Add(GetRemoteMacAddress(IPAddress));
   end;

end;

procedure TfrmServers.LocateAll(Sender: TObject);
var
  WN : TNetEnumerator;
begin

  Screen.Cursor := crHourGlass;
  WN := TNetEnumerator.Create;
  try

    WN.OnContainer := DoContainer;
    WN.OnServer := DoServer;
    WN.OnProgress := DoProgress;
    WN.Enumerate;

  finally
    Screen.Cursor := crDefault;
    WN.Free;
  end;

end;

procedure TfrmServers.DoContainer(const Name, Comment: string);
begin
  StatusMessage(Format(sEnumeratingContainerFmt, [Name]));
end;

procedure TfrmServers.DoProgress(const Items, Count: Integer);
begin
//  if Count <> 0 then
//    pbServers.Position := Trunc(pbServers.Max * (Items / Count));
end;

procedure TfrmServers.DoServer(const Name, Comment: string);
begin
  StatusMessage(Format(sFoundServerFmt, [Name]));
  AddServer(Name, Comment);
end;

procedure TfrmServers.tmrLocateTimer(Sender: TObject);
begin
  tmrLocate.Enabled := false;
  LocateAll(Sender);
end;

procedure TfrmServers.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F5 then
    LocateAll(Sender);
end;

procedure TfrmServers.FormCreate(Sender: TObject);
begin
  lvServers.Clear;
end;

end.
