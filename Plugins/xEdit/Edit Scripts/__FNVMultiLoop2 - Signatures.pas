unit __FNVMultiLoop;

var
NPCList, slfilelist: TStringList;
k: integer;
rec: IInterface;
loadordername, grupname: String;

{ Not Used
function filerename(filename, grupname: String; j: integer): String;
var
j: integer;
begin
	if FileExists(filename) then
	begin
		//filename:= (copy(filename, 1, LastDelimiter('_', filename)) + IntToStr(1 + StrToInt(copy(filename, (LastDelimiter('_', filename) + 1), (LastDelimiter('.csv', filename) - LastDelimiter('_', filename) - 1))));
		j := j + 1;
		filename := (ProgramPath + 'data\' + GetFileName(rec) + '_' + grupname + '_' + IntToStr(j) + '.csv');
		AddMessage(filename);
		filename := filerename(filename, grupname, j);
		Result := filename;
	end;
	//else Result := filename;
end;
}

function savelist(rec: IInterface; k: integer; grupname: String): integer;
var
filename: String;
begin
	k := 0;
	filename := (ProgramPath + 'data\' + GetFileName(rec) + '_' + 'LoadOrder_' + IntToHex(GetLoadOrder(GetFile(rec)), 2) + '_' + 'GRUP' + '_' + grupname + '_' + '0' + '.csv');
	//filename := filerename(filename, grupname, 0);
	while FileExists(filename) do
	begin
		k := k + 1;
		filename := (ProgramPath + 'data\' + GetFileName(rec) + '_' + 'LoadOrder_' + IntToHex(GetLoadOrder(GetFile(rec)), 2) + '_' + 'GRUP' + '_' + grupname + '_' + IntToStr(k) + '.csv');
	end;
	AddMessage('Saving list to ' + filename);
	slfilelist.Add(stringreplace(filename, (ProgramPath + 'data\'), '', [rfReplaceAll]));
	NPCList.SaveToFile(filename);
	NPCList.Clear;
	Result := k + 1;
end;

//function Recursive(e: IInterface; i: integer; slstring: String): String;
//var
//j: integer;
//begin
//	j := i;
//	if i < (ElementCount(e)-1) then
//	for i := j to (ElementCount(e)-1) do 
//	begin 
//		//AddMessage('Element Count is ' + IntToStr(ElementCount(e)));
//		//AddMessage('i = ' + IntToStr(i));
//		//AddMessage(path(ElementByIndex(e, i)));
//		if Signature((ElementByIndex(e, i))) <> 'SCTX' then
//		slstring := (slstring + ';' + path(ElementByIndex(e, i)){ + ';' + IntToStr(ElementCount(ElementByIndex(e, i)))} + ';' + GetEditValue(ElementByIndex(e, i)));
//		//AddMessage(slstring);
//		//AddMessage(GetEditValue(ElementByIndex(e, i)));
//		if ElementCount((ElementByIndex(e, i))) > 0 then slstring := (Recursive(ElementByIndex(e, i), 0, slstring));
//	end;
//	Result := slstring;
//end;

function Recursive(e: IInterface; slstring: String): String;
var
i: integer;
ielement: IInterface;
begin
	for i := 0 to (ElementCount(e)-1) do 
	begin 
		ielement := ElementByIndex(e, i);
		if ansipos(#13#10, GetEditValue(ielement)) = 0 then
		slstring := (slstring + ';' + path(ielement){ + ';' + IntToStr(ElementCount(ielement))} + ';' + GetEditValue(ielement))
		else slstring := (slstring + ';' + path(ielement){ + ';' + IntToStr(ElementCount(ielement))} + ';' + stringreplace(stringreplace(GetEditValue(ielement), #13#10, '\r\n', [rfReplaceAll]), ';' , '\comment\', [rfReplaceAll]));
		if ElementCount(ielement) > 0 then slstring := (Recursive(ielement, slstring));
	end;
	Result := slstring;
end;

function RecursiveNAVI(e: IInterface; NPCList: TStringList): TStringList;
var
i: integer;
ielement: IInterface;
begin
	for i := 0 to (ElementCount(e)-1) do 
	begin 
		ielement := ElementByIndex(e, i);
		NPCList.Add(path(ielement));
		NPCList.Add(GetEditValue(ielement));
		if ElementCount(ielement) > 0 then NPCList := (RecursiveNAVI(ielement, NPCList));
	end;
	Result := NPCList;
end;

//Recursive(e, true);
function Initialize: integer;
begin
	NPCList := TStringList.Create;
	slfilelist := TStringList.Create;
	k := 1
end;
	
function Process(e: IInterface): integer;
var
i, j{, k}: integer;
slstring: String;
begin
	// Compare to previous record
	if (Assigned(rec) AND (Signature(e) <> grupname) AND (NPCList.Count > 0)) then k := savelist(rec, 0, grupname);
	if (Assigned(rec) AND (loadordername <> GetFileName(e))) then 
	begin
		AddMessage('Went To Different File');
		if NPCList.Count > 0 then savelist(rec, k, grupname);
		rec := Nil;
		loadordername := GetFileName(e);
	end;
	// Compare to previous record
	slstring := (IntToStr(GetLoadOrderFormID(e)) + ';' + IntToStr(ReferencedByCount(e)));
	rec := e;
	loadordername := GetFileName(rec);
	grupname := Signature(rec);
	if Signature(e) <> 'NAVI' then NPCList.Add(Recursive(e, slstring)) else
	begin
		NPCList.Add(IntToStr(GetLoadOrderFormID(e)));
		NPCList.Add(IntToStr(ReferencedByCount(e)));
		AddMessage('Yes');
		RecursiveNAVI(e, NPCList);
		k := savelist(rec, k, grupname);
	end;
	if NPCList.Count > 4999 then k := savelist(rec, k, grupname);
end;

function Finalize: integer;
begin
	if NPCList.Count > 0 then savelist(rec, k, grupname);
	NPCList.Free;
	slfilelist.SaveToFile(ProgramPath + 'data\' + '_filelist.csv');
	slfilelist.Free;
	rec := Nil;
end;

end.