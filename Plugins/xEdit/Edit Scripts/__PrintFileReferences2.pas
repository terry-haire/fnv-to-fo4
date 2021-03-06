unit __PrintFileReferences2;

interface
implementation
uses xEditAPI, Classes, SysUtils, StrUtils, Windows; //Remove before use in xEdit

var
sl_paths: TStringList;

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

procedure ElementWhiteList(rec: IInterface);
var
i, j: Integer;
sName: String;
begin
  for i := (ElementCount(rec) - 1) downto 0 do
  begin
    sName := Name(ElementByIndex(rec, i));
    if ((AnsiPos('File', sName) <> 0) OR (AnsiPos('file', sName) <> 0)) then
    begin
//      sName := Copy(formatelementpath(Path(ElementByIndex(rec, i))), 6, MaxInt);
      sName := formatelementpath(Path(ElementByIndex(rec, i)));
      for j := 0 to sl_paths.Count do
        if j = sl_paths.Count then
          sl_paths.Add(sName)
        else if sName = sl_paths[j] then
          Break;
    end;
    if ElementCount(ElementByIndex(rec, i)) > 0 then ElementWhiteList(ElementByIndex(rec, i));
  end;
end;

function Initialize: integer;
begin
  sl_paths := TStringList.Create;
	Result := 0;
end;

function Process(e: IInterface): integer;
begin
  ElementWhiteList(e);
	Result := 0;
end;

function Finalize: integer;
var
i: Integer;

begin
  for i := 0 to (sl_paths.Count - 1) do
    AddMessage(sl_paths[i]);
  sl_paths.Free;
	Result := 0;
end;

end.
