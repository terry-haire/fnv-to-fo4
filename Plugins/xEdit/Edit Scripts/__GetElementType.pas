unit __GetElementType;

interface
implementation
uses xEditAPI, Classes, SysUtils, StrUtils, Windows; //Remove before use in xEdit

function Initialize: integer;
begin
	Result := 0;
end;

function Process(e: IInterface): integer;
var
rec, rec2: IInterface;

begin
//	AddMessage(IntToStr(ElementType(ElementByPath(e, 'Record Header\Record Flags'))));
//	AddMessage(IntToStr(ElementType(ElementByPath(e, 'DATA'))));
	AddMessage(FlagValues(ElementByPath(e, 'DATA')));
	AddMessage(FlagValues(ElementByPath(e, 'Record Header\Record Flags')));
  Add(e, 'CELL', True);
  if Signature(e) = 'CELL' then rec := e;
  rec2 := RecordByFormID(FileByLoadOrder(1), $0016D714, True);
  AddMessage(Signature(rec));
  AddMessage(Signature(rec2));


	Result := 0;	
end;

function Finalize: integer;
begin
	Result := 0;
end;

end.