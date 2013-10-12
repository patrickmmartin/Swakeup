unit WinError;

interface
uses
  SysUtils
  ;
type
  EOSError = class (Exception)
  public
    constructor CreateLastError(const Operation : string);
  end;

implementation

constructor EOSError.CreateLastError(const Operation : string);
begin
  inherited Create(Operation + #13#10 + SysErrorMessage(GetLastError));
end;


end.
