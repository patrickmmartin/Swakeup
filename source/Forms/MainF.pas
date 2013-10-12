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
    mnuAddMachine: TMenuItem;
    mnuDeleteMachine: TMenuItem;
    mnuSearchMachines: TMenuItem;
    mnuMachine: TMenuItem;
    mnuStartMachine: TMenuItem;
    mnuShutdownMachine: TMenuItem;
    mnuLoadMachines: TMenuItem;
    pmnuStartMachine: TMenuItem;
    sbMain: TStatusBar;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    sepPowerList: TToolButton;
    mnuScanMachines: TMenuItem;
    mnuScanMachine: TMenuItem;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    pmnuScanMachine: TMenuItem;
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

