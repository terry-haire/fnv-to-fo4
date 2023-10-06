unit __FNVMultiLoop3;

///  Creates List per Amount And sorts
///  WIP

interface
implementation
uses xEditAPI, __FNVMultiLoopFunctions, Classes, SysUtils, StrUtils, Windows; //Remove before use in xEdit

var
NPCList, slfilelist, slSignatures, slGrups: TStringList;
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

function savelist2(rec: IInterface; k: integer; grupname: String): integer;
var
filename: String;
begin
	filename := (ProgramPath + 'data\' + GetFileName(rec) + '_' + 'LoadOrder_' + IntToHex(GetLoadOrder(GetFile(rec)), 2) + '_' + IntToStr(k) + '.csv');
	AddMessage('Saving list to ' + filename);
	NPCList.SaveToFile(filename);
	NPCList.Clear;
	slfilelist.Add(stringreplace(filename, (ProgramPath + 'data\'), '', [rfReplaceAll]));
	Result := k + 1;
end;

function Initialize: integer;
begin
	NPCList := TStringList.Create;
	slfilelist := TStringList.Create;
  slSignatures := TStringList.Create;
  slGrups := TStringList.Create;
	k := 0;
  Result := 0;
end;
	
function Process(e: IInterface): integer;
var
slstring: String;
k: integer;
begin
	// Compare to previous record
//	if (Assigned(rec) AND ((copy(FullPath(e), (ansipos('GRUP', FullPath(e)) + 10), 4)) <> grupname) AND (NPCList.Count > 0)) then k := savelist(rec, 0, grupname);
	if (Assigned(rec) AND (loadordername <> GetFileName(e))) then 
	begin
		if NPCList.Count > 0 then k := savelist2(rec, k, grupname);
    k := 0;
		rec := Nil;
		loadordername := GetFileName(e);
		AddMessage('Went To Different File');
	end;
	// Compare to previous record
	slstring := (IntToStr(GetLoadOrderFormID(e)) + ';' + IntToStr(ReferencedByCount(e)) + ';' + FullPath(e));
	rec := e;
	loadordername := GetFileName(rec);
	grupname := (copy(FullPath(rec), (ansipos('GRUP', FullPath(rec)) + 10), 4));
  slSignatures.Add(Signature(rec));
  slGrups.Add(grupname);
	if Signature(e) <> 'NAVI' then NPCList.Add(Recursive(e, slstring)) else
	begin
		NPCList.Add(IntToStr(GetLoadOrderFormID(e)));
		NPCList.Add(IntToStr(ReferencedByCount(e)));
		NPCList.Add(FullPath(e));
		AddMessage('Yes');
		RecursiveNAVI(e, NPCList);
		k := savelist2(rec, k, grupname);
	end;
	if NPCList.Count > 4999 then k := savelist2(rec, k, grupname);
  Result := 0;
end;

function Finalize: integer;
var
i, j, k: Integer;
_Signature, _Grupname: String;
slSortedList, slFileList2: TStringList;

begin
	if NPCList.Count > 0 then k := savelist2(rec, k, grupname);
	rec := Nil;
	NPCList.Clear;
	slFileList2 := TStringList.Create;
	slSortedList := TStringList.Create;
  j := 0;
  k := 0;
  for i := 0 to (slfilelist.Count - 1) do
  begin
    slSortedList.Clear;
    NPCList.LoadFromFile(slfilelist[i]);
    while(j < (NPCList.Count - 1))  do
    begin
      _Signature := slSignatures[k];
      _Grupname := slGrups[k];
      slSortedList.Add(NPCList[j]);
    end;
  end;
	NPCList.Free;
	slfilelist.SaveToFile(ProgramPath + 'data\' + '_filelist.csv');
	slfilelist.Free;
  slSignatures.Free;
  slGrups.Free;
  Result := 0;
