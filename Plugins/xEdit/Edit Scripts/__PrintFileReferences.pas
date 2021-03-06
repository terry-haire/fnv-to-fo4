unit __PrintFileReferences;

interface
implementation
uses xEditAPI, Classes, SysUtils, StrUtils, Windows; //Remove before use in xEdit

var
slReferences, slExtensions: TStringList;

function formatelementpath(elementpathstring: String): String;
var
pos1, pos2: integer;
originalpath: String;
begin
  originalpath := elementpathstring;
	if ((ansipos(' - ', elementpathstring) <> 0) AND (ansipos('\', elementpathstring) <> 0)) then
	begin
		pos1 := ansipos(' - ', elementpathstring);
		pos2 := ansipos('\', copy(elementpathstring, pos1, MaxInt));
		if pos2 = 0 then elementpathstring := copy(elementpathstring, 1, (pos1 - 1))
		else elementpathstring := copy(elementpathstring, 1, (pos1 - 1)) + copy(elementpathstring, (pos1 + pos2 - 1),  MaxInt);
		formatelementpath(elementpathstring);
	end
	else
	if ((ansipos(' - ', elementpathstring) <> 0) AND (ansipos('\', elementpathstring) = 0)) then
	begin
		elementpathstring := copy(elementpathstring, 1, (ansipos(' - ', elementpathstring) - 1));
		formatelementpath(elementpathstring);
	end;
	elementpathstring := stringreplace(elementpathstring, ' \ ', '\', [rfReplaceAll]);
	elementpathstring := stringreplace(elementpathstring, '\ ', '\', [rfReplaceAll]);
//	elementpathstring := stringreplace(elementpathstring, 'Destructable', 'Destructible', [rfReplaceAll]);
	if ansipos('Record Flags\NavMesh Generation', elementpathstring) <> 0 then
	begin
		elementpathstring := elementpathstring + copy(originalpath, (ansipos('NavMesh Generation', originalpath) + 18), MaxInt);
		if ansipos('(0x', elementpathstring) <> 0 then elementpathstring := copy(elementpathstring, 1, (ansipos('(0x', elementpathstring) - 2));
	end;
	if ansipos('(0x', elementpathstring) <> 0 then elementpathstring := copy(elementpathstring, 1, (ansipos('(0x', elementpathstring) - 2));
  if ansipos('NVEX\Connection #', elementpathstring) <> 0 then elementpathstring := '';
  if ansipos('NVDP\Door #', elementpathstring) <> 0 then elementpathstring := '';
	Result := elementpathstring;

end;

procedure RecursiveReferences(e: IInterface);
var
i, j: integer;
ielement: IInterface;
valuestr: String;
begin
	for i := 0 to (ElementCount(e)-1) do
	begin
		ielement := ElementByIndex(e, i);
    valuestr := GetEditValue(ielement);
    if ((Length(valuestr) > 4) AND (LastDelimiter('.', valuestr) <> 0)) then
    for j := 0 to (slExtensions.Count - 1) do
    begin
      if Copy(valuestr, (Length(valuestr) - Length(slExtensions[j]) + 1), MaxInt) = slExtensions[j] then
      begin
        slReferences.Add(formatelementpath(Path(ielement)) + ';' + valuestr);
        Break;
      end;
    end;
		if ElementCount(ielement) > 0 then RecursiveReferences(ielement);
	end;
end;

function Initialize: integer;
begin
  slReferences := TStringList.Create;
  slExtensions := TStringList.Create;
  slExtensions.LoadFromFile(ProgramPath + 'ElementConverions\' + '__FileExtensions.csv');
	Result := 0;
end;

function Process(e: IInterface): integer;
begin
  RecursiveReferences(e);
	Result := 0;
end;

function Finalize: integer;
var
filename: String;

begin
  filename := '__FileReferenceList.csv';
  filename := ProgramPath + 'ElementConverions\' + filename;
  if slReferences.Count > 1 then
  begin
    AddMessage('Saving ' + filename);
    slReferences.SaveToFile(filename);
  end;
  slReferences.Free;
  slExtensions.Free;
	Result := 0;
end;

end.
