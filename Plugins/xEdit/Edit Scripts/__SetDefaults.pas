unit __SetDefaults;

interface
implementation
uses xEditAPI, Classes, SysUtils, StrUtils, Windows; //Remove before use in xEdit


function Initialize: integer;
var
slstr, sltrf1, slstr2, sltrf2: TStringList;
i, k: Integer;
rec, rec2: IInterface;
begin
//  rec := FileByLoadOrder(1);
//  rec := GroupBySignature(rec, 'WRLD');
//  RemoveRecords(rec);
	Result := 0;
end;

function Process(e: IInterface): integer;
var
slstr, sltrf1, slstr2, sltrf2: TStringList;
i, k: Integer;
rec, rec2: IInterface;
begin
  SetToDefault(e);
	Result := 0;
end;

function Finalize: integer;
begin
	Result := 0;
end;

end.
