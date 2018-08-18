unit __FNVMultiLoop;

///  Creates List per GRUP

interface
implementation
uses xEditAPI, __FNVMultiLoopFunctions, Classes, SysUtils, StrUtils, Windows; //Remove before use in xEdit

var
NPCList, slfilelist: TStringList;
k: integer;
rec: IInterface;
loadordername, grupname: String;

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

//Recursive(e, true);
function Initialize: integer;
begin
	NPCList := TStringList.Create;
	slfilelist := TStringList.Create;
	k := 1;
  Result := 0;
end;
	
function Process(e: IInterface): integer;
var
slstring: String;
begin
	// Compare to previous record
	if (Assigned(rec) AND ((copy(FullPath(e), (ansipos('GRUP', FullPath(e)) + 10), 4)) <> grupname) AND (NPCList.Count > 0)) then k := savelist(rec, 0, grupname);
	if (Assigned(rec) AND (loadordername <> GetFileName(e))) then 
	begin
		AddMessage('Went To Different File');
		if NPCList.Count > 0 then savelist(rec, k, grupname);
		rec := Nil;
		loadordername := GetFileName(e);
	end;
	// Compare to previous record
	slstring := (IntToStr(GetLoadOrderFormID(e)) + ';' + IntToStr(ReferencedByCount(e)) + ';' + FullPath(e));
	rec := e;
	loadordername := GetFileName(rec);
	grupname := (copy(FullPath(rec), (ansipos('GRUP', FullPath(rec)) + 10), 4));
	if Signature(e) <> 'NAVI' then NPCList.Add(Recursive2(e, slstring)) else
	begin
		NPCList.Add(IntToStr(GetLoadOrderFormID(e)));
		NPCList.Add(IntToStr(ReferencedByCount(e)));
		NPCList.Add(FullPath(e));
		AddMessage('Yes');
		RecursiveNAVI(e, NPCList);
		k := savelist(rec, k, grupname);
	end;
	if NPCList.Count > 4999 then k := savelist(rec, k, grupname);
  Result := 0;
end;

function Finalize: integer;
begin
	if NPCList.Count > 0 then savelist(rec, k, grupname);
	NPCList.Free;
	slfilelist.SaveToFile(ProgramPath + 'data\' + '_filelist.csv');
	slfilelist.Free;
	rec := Nil;
  Result := 0;
end;

end.