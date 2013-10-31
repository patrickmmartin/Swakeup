unit MainF;

interface


uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, Menus, ToolWin, ImgList;

type
  TfrmMain = class(TForm)
    lvMachines: TListView;
    mnuMain: TMainMenu;
    mnuFile: TMenuItem;
    mnuFileExit: TMenuItem;
    mnuHelp: TMenuItem;
    mnuHelpAbout: TMenuItem;
    pmnuMachines: TPopupMenu;
    pmnuShutdownMachine: TMenuItem;
    mnuList: TMenuItem;
    mnuSearchMachines: TMenuItem;
    mnuMachine: TMenuItem;
    mnuStartMachine: TMenuItem;
    mnuShutdownMachine: TMenuItem;
    mnuLoadMachines: TMenuItem;
    pmnuStartMachine: TMenuItem;
    sbMain: TStatusBar;
    ToolBar1: TToolBar;
    tbStopMachine: TToolButton;
    tbStart: TToolButton;
    tbLoadMachines: TToolButton;
    tbSearch: TToolButton;
    sepPowerList: TToolButton;
    mnuScanMachines: TMenuItem;
    mnuScanMachine: TMenuItem;
    tbScanMachines: TToolButton;
    tbScaMachines: TToolButton;
    pmnuScanMachine: TMenuItem;
    tbSaveMachines: TToolButton;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

  
implementation

uses
  XPMenu,
  MainDM,
  CommCtrl,
  ResourceDM;

{$R *.dfm}

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  { basic visual setup }
  lvMachines.Clear;
  with TXPMenu.Create(self) do
  begin
    XPContainers := [];
    XPControls := [xcMainMenu, xcPopupMenu];
    Active := true;
  end;

  { let the datamodule handler assign the rest }
  dmMain.MainFormCreate(self);

end;


end.

