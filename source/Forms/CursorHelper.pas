unit CursorHelper;

{ general eye candy unit }

interface

uses
  Controls  { TCursor }
  ;


type
  IWaitCursor = interface
    { only need release cursor in this interface }
    procedure ReleaseCursor;
  end;

  TWaitCursor = class(TInterfacedObject, IWaitCursor)
  private
    FCursor : TCursor;
    { hide the parameterless constructor }
    constructor Create;
  public
    constructor CreateCursor(ACursor : TCursor);
    destructor Destroy; override;
    procedure ReleaseCursor;
    property Cursor : TCursor read FCursor;
  end;

  function WaitCursor(ACursor : TCursor) : IWaitCursor;
  function HourGlass : IWaitCursor;
  function AppStart : IWaitCursor;

implementation

uses
  Forms  { Screen}
  ;

function WaitCursor(ACursor : TCursor) : IWaitCursor;
begin
  Result := TWaitCursor.CreateCursor(ACursor);
end;

function HourGlass : IWaitCursor;
begin
  Result := WaitCursor(crHourGlass)
end;

function AppStart : IWaitCursor;
begin
  Result := WaitCursor(crAppStart)
end;

{ TWaitCursor }

constructor TWaitCursor.Create;
begin
  inherited;
end;

constructor TWaitCursor.CreateCursor(ACursor: TCursor);
begin
  Create;
  FCursor := crDefault;
  Screen.Cursor := ACursor;
end;

destructor TWaitCursor.Destroy;
begin
  ReleaseCursor;
  inherited;
end;

procedure TWaitCursor.ReleaseCursor;
begin
  Screen.Cursor := FCursor;
end;

end.
