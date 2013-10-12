unit ResourceDM;

interface

uses
  SysUtils,
  Classes,
  ImgList,
  Controls
  ;

type
  TdmResource = class(TDataModule)
    imlMain: TImageList;
    imlServers: TImageList;
    imlMainHot: TImageList;
    imlMainDisabled: TImageList;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dmResource: TdmResource;

implementation

uses
  Windows,  { LoadLibrary}
  CommCtrl  { ImageList_AddIcon }
  ;

{$R *.dfm}

procedure TdmResource.DataModuleCreate(Sender: TObject);
var
  Shell32H : THandle;
begin
  imlServers.Clear;
  { todo set up for the proper system metrics }
  Shell32H := LoadLibrary('shell32.dll');
  if Shell32H > 31 then
  begin
    ImageList_AddIcon(imlServers.Handle, LoadIcon(Shell32H, MakeIntResource(16)));
  end;
  FreeLibrary(Shell32H);
end;

end.
