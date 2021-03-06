unit __PrintUniqueValue;


interface
implementation
uses xEditAPI, Classes, SysUtils, StrUtils, Windows; //Remove before use in xEdit

var
slvalues: TStringList;
elementpath: String;
boolrecursive: Boolean;

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
	elementpathstring := stringreplace(elementpathstring, 'Destructable', 'Destructible', [rfReplaceAll]);
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

procedure Recursive(e: IInterface);
var
i, j: integer;
ielement: IInterface;
begin
	for i := 0 to (ElementCount(e)-1) do
	begin
		ielement := ElementByIndex(e, i);
    if Copy(formatelementpath(Path(ielement)), 6, MaxInt) = elementpath then
    for j := 0 to slvalues.Count do
    begin
      if j = slvalues.Count then
        slvalues.Add(GetEditValue(ielement));
      if slvalues[j] = GetEditValue(ielement) then
        Break;
    end;
		if ElementCount(ielement) > 0 then Recursive(ielement);
	end;
end;

function Initialize: integer;
begin
  slvalues := TStringList.Create;
  elementpath := 'Textures (RGB/A)\TX05';
  boolrecursive := False;
	Result := 0;
end;

function Process(e: IInterface): integer;
var
j: Integer;
begin
  if boolrecursive then
  begin
    Recursive(e);
  end
  else
    for j := 0 to slvalues.Count do
    begin
      if j = slvalues.Count then
        slvalues.Add(GetElementEditValues(e, elementpath));
      if slvalues[j] = GetElementEditValues(e, elementpath) then
        Break;
    end;
	Result := 0;
end;

function Finalize: integer;
var
i: Integer;
begin
  for i := 0 to (slvalues.Count - 1) do
    AddMessage(slvalues[i]);
//  for i := 0 to (slvalues.Count - 1) do
//    AddMessage(IntToStr(StrToInt(slvalues[i]) * 60));
  slvalues.Free;
	Result := 0;
end;

end.