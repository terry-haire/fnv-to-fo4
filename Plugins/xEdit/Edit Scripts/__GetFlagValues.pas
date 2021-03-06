unit __GetFlagValues;

// Select All in flags to use

interface
implementation
uses xEditAPI, Classes, SysUtils, StrUtils, Windows; //Remove before use in xEdit

function Initialize: integer;
begin
	Result := 0;
end;

function Process(e: IInterface): integer;
var
rec: IInterface;
i: integer;
elementvaluestring, pathstring: String;
begin
	pathstring := 'FNAM';
	pathstring := 'BMDT\General Flags';
  pathstring := 'DNAM\Data (old format)\Flags';
  pathstring := 'DATA\Flags 2';
  pathstring := 'Magic Effect Data\DATA\Flags';
  pathstring := 'ACBS\Flags';
  pathstring := 'PKDT\Interrupt Flags';
	pathstring := 'Region Data Entries\Region Data Entry\RDSA\Sound\Flags';
	pathstring := 'SPIT\Flags';
	pathstring := 'DODT\Flags';
	pathstring := 'DNAM';
	pathstring := 'FNAM';
  pathstring := 'DNAM\Flags';
  pathstring := 'DATA\Flags';
	pathstring := 'Record Header\Record Flags';
	pathstring := 'BOD2\First Person Flags';

	Result := 0;
//	if Signature(e) = 'ACTI' then
	begin
		//AddMessage(GetElementEditValues(e, 'DATA'));
		rec := ElementByPath(e, pathstring);
		AddMessage(GetEditValue(rec));
		elementvaluestring := '';
		for i := 0 to Length(GetEditValue(rec)) - 1 do
			Insert('0', elementvaluestring, 0);
		for i := 0 to Length(GetEditValue(rec)) do
		begin
			Insert('1', elementvaluestring, i);
			Delete(elementvaluestring, (i + 1), 1);
			SetEditValue(rec, elementvaluestring);
      if Copy(Path(ElementByIndex(rec, 0)), (LastDelimiter('\', Path(ElementByIndex(rec, 0))) + 2), MaxInt) <> '' then
        AddMessage(IntToStr(i) + #9 + pathstring + '\' + Copy(Path(ElementByIndex(rec, 0)), (LastDelimiter('\', Path(ElementByIndex(rec, 0))) + 2), MaxInt))
      else AddMessage('');
			Insert('0', elementvaluestring, i);
			Delete(elementvaluestring, (i + 1), 1);
		end;
        //Insert('1', elementvaluestring, elementinteger);
        //Delete(elementvaluestring, (elementinteger + 1), 1);
	end;
end;

function Finalize: integer;
begin
	Result := 0;
end;

end.