unit COMUtils;

interface

function GetDispatchFromMoniker(Value: string): OleVariant;

implementation

uses
  ComObj,
  ActiveX,
  Variants
  ;


function GetDispatchFromMoniker(Value: string): OleVariant;
var
  pDisp:      IDispatch;
  pmk:        IMoniker;
  pbc:        IBindCtx;
  cbEaten:    LongInt;
begin

// Resource protection
   // Try to access the object using a moniker
   if (CreateBindCtx(0, pbc) = S_OK) then
   begin
      if (MkParseDisplayName(pbc, StringToOleStr(Value), cbEaten, pmk) = S_OK) then
      begin
         // Attempt to bind the moniker
         if (BindMoniker(pmk, 0, IDispatch, pDisp) = S_OK) then
            // Return the IDispatch
            result:=pDisp
         else
            // Return unassigned
            result:=Unassigned;
         // Release refcounts
      end
      else
         // Return unassigned
         result:=Unassigned;
      // Release refcounts
   end
   else
      // Return unassigned
      result:=Unassigned;
end;

initialization
  OleCheck(CoInitialize(nil));

finalization
 CoUninitialize;

end.
