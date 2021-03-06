unit __FNVMultiLoop3;

///  Current Method for Acquiring data for use with importer
///  Creates List per Amount And sorts
///  Can move the sorting function into the savelist function to speed up
///  WIP

interface
implementation
uses xEditAPI, __FNVMultiLoopFunctions, __FNVConversionFunctions, Classes, SysUtils, StrUtils, Windows; //Remove before use in xEdit

var
NPCList,
slfilelist,
slSignatures,
slGrups,
slvalues,
slNifs,
sl3DNames,
slReferences,
slExtensions: TStringList;
k: integer;
rec: IInterface;
loadordername, grupname: String;

function Recursive(e: IInterface; slstring: String): String;
var
i, j: integer;
ielement, _TXST: IInterface;
s, valuestr: String;
begin
	for i := 0 to (ElementCount(e)-1) do
	begin

    ////////////////////////////////////////////////////////////////////////////
    ///  All Data
    ////////////////////////////////////////////////////////////////////////////
		ielement := ElementByIndex(e, i);
		slstring := (slstring
//    stringreplace(
//     ,'"', '|CITATION|', [rfReplaceAll])
    + ';' + stringreplace(stringreplace(stringreplace(path(ielement), #13#10, '\r\n', [rfReplaceAll]), ';' , '\comment\', [rfReplaceAll]) ,'"', '|CITATION|', [rfReplaceAll])
    + ';' + stringreplace(stringreplace(stringreplace(GetEditValue(ielement), #13#10, '\r\n', [rfReplaceAll]), ';' , '\comment\', [rfReplaceAll]) ,'"', '|CITATION|', [rfReplaceAll])
    + ';' + IntToStr(i));

    ////////////////////////////////////////////////////////////////////////////
    ///  Material Swap
    ////////////////////////////////////////////////////////////////////////////
    if Name(ielement) = 'Alternate Texture' then
    begin
      if Assigned(ElementByPath(ielement, '3D Name')) then
      begin
        s := GetEditValue(ElementByIndex(GetContainer(GetContainer(ielement)), 0));
        if LastDelimiter('.', s) <> (Length(s) - 3) then s := '';
        slNifs.Add(s);
        _TXST := LinksTo(ElementByPath(ielement, 'New Texture'));
        s := s + ';' + GetElementEditValues(_TXST, 'EDID')
        + ';' + GetElementEditValues(ielement, '3D Name')
        + ';' + GetElementEditValues(_TXST, 'Textures (RGB/A)\TX00')
        + ';' + GetElementEditValues(_TXST, 'Textures (RGB/A)\TX01')
        + ';' + GetElementEditValues(_TXST, 'Textures (RGB/A)\TX02')
        + ';' + GetElementEditValues(_TXST, 'Textures (RGB/A)\TX03')
        + ';' + GetElementEditValues(_TXST, 'Textures (RGB/A)\TX04')
        + ';' + GetElementEditValues(_TXST, 'Textures (RGB/A)\TX05') + ';';
        if Assigned(ElementByPath(_TXST, 'DNAM\No Specular Map')) then
          s := s + 'No Specular Map';
        slvalues.Add(s);
        sl3DNames.Add(GetElementEditValues(ielement, '3D Name'));
      end;
    end;

    ////////////////////////////////////////////////////////////////////////////
    ///  File Reference
    ////////////////////////////////////////////////////////////////////////////
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

    ////////////////////////////////////////////////////////////////////////////
    ///  Exit Condition
    ////////////////////////////////////////////////////////////////////////////
		if ElementCount(ielement) > 0 then slstring := (Recursive(ielement, slstring));
	end;
	Result := slstring;
end;

function savelist2(rec: IInterface; k: integer; grupname: String): integer;
var
filename: String;
begin
	filename := (ProgramPath + 'data\unsorted\' + GetFileName(rec) + '_LoadOrder_' + IntToHex(GetLoadOrder(GetFile(rec)), 2) + '_' + IntToStr(k) + '.csv');
	AddMessage('Saving list to ' + filename);
	NPCList.SaveToFile(filename);
	NPCList.Clear;
	slfilelist.Add(stringreplace(filename, (ProgramPath + 'data\unsorted\'), '', [rfReplaceAll]));
	Result := k + 1;
end;

function Initialize: integer;
begin
	NPCList := TStringList.Create;
	slfilelist := TStringList.Create;
  slSignatures := TStringList.Create;
  slGrups := TStringList.Create;
  slvalues := TStringList.Create;
  slNifs := TStringList.Create;
  sl3DNames := TStringList.Create;
  slReferences := TStringList.Create;
  slExtensions := TStringList.Create;
  slExtensions.LoadFromFile(ProgramPath + 'ElementConverions\' + '__FileExtensions.csv');
	k := 0;
  Result := 0;
end;
	
function Process(e: IInterface): integer;
var
slstring: String;
begin
	// Compare to previous record
  if (Assigned(rec) AND (loadordername <> GetFileName(e))) then
	begin
		if NPCList.Count > 0 then k := savelist2(rec, k, grupname);
    k := 0;
		rec := Nil;
		loadordername := GetFileName(e);
		AddMessage('Went To Different File');
	end;
	// Compare to previous record            stringreplace(stringreplace(FullPath(e), #13#10, '\r\n', [rfReplaceAll]), ';' , '\comment\', [rfReplaceAll])
	slstring := (Signature(e) + ';' + IntToStr(GetLoadOrderFormID(e)) + ';' + IntToStr(ReferencedByCount(e)) + ';' + stringreplace(stringreplace(stringreplace(FullPath(e), #13#10, '\r\n', [rfReplaceAll]), ';' , '\comment\', [rfReplaceAll]) ,'"', '|CITATION|', [rfReplaceAll]));
	rec := e;
	loadordername := GetFileName(rec);
  if ansipos('GRUP', FullPath(rec)) <> 0 then	grupname := (copy(FullPath(rec), (ansipos('GRUP', FullPath(rec)) + 19), 4))
  else grupname := Signature(rec);
  slSignatures.Add(Signature(rec));
  slGrups.Add(grupname);
	if Signature(e) <> 'NAVI' then NPCList.Add(Recursive(e, slstring)) else
	begin
    if NPCList.Count > 0 then k := savelist2(rec, k, grupname);
    NPCList.Add(Signature(e));
		NPCList.Add(IntToStr(GetLoadOrderFormID(e)));
		NPCList.Add(IntToStr(ReferencedByCount(e)));
		NPCList.Add(FullPath(e));
		RecursiveNAVI(e, NPCList);
		k := savelist2(rec, k, grupname);
	end;
	if NPCList.Count > 4999 then k := savelist2(rec, k, grupname);
  Result := 0;
end;

function Finalize: integer;
var
i, j: Integer;
_Signature, _Grupname, filename: String;
slSorted, slfilelist2, slstring: TStringList;

begin

  //////////////////////////////////////////////////////////////////////////////
  ///  Save Lists
  //////////////////////////////////////////////////////////////////////////////
  if slvalues.Count > 0 then
  begin
    AddMessage('Saving ' + ProgramPath + 'ElementConverions\MaterialSwaps.csv');
    slvalues.SaveToFile(ProgramPath + 'ElementConverions\MaterialSwaps.csv');
    AddMessage('Saving ' + ProgramPath + 'ElementConverions\MaterialSwapsNifs.csv');
    slNifs.SaveToFile(ProgramPath + 'ElementConverions\MaterialSwapsNifs.csv');
    AddMessage('Saving ' + ProgramPath + 'ElementConverions\MaterialSwaps3Names.csv');
    sl3DNames.SaveToFile(ProgramPath + 'ElementConverions\MaterialSwaps3Names.csv');
  end;
  if slReferences.Count > 1 then
  begin
    AddMessage('Saving ' + ProgramPath + 'ElementConverions\' + '__FileReferenceList.csv');
    slReferences.SaveToFile(ProgramPath + 'ElementConverions\' + '__FileReferenceList.csv');
  end;

  //////////////////////////////////////////////////////////////////////////////
  ///  Free Lists
  //////////////////////////////////////////////////////////////////////////////
  slvalues.Free;
  slNifs.Free;
  sl3DNames.Free;
  slReferences.Free;
  slExtensions.Free;


	if NPCList.Count > 0 then k := savelist2(rec, k, grupname);
	rec := Nil;
	NPCList.Clear;
  slSorted := TStringList.Create;
  slfilelist2 := TStringList.Create;
  slstring := TStringList.Create;
  slstring.Delimiter := ';';
  slstring.StrictDelimiter := True;

  //////////////////////////////////////////////////////////////////////////////
  ///  Sort by Signature
  //////////////////////////////////////////////////////////////////////////////
  i := 0;
  while (i < slfilelist.Count) do
  begin
    if NPCList.Count = 0 then
      NPCList.LoadFromFile(ProgramPath + 'data\unsorted\' + slfilelist[i]);

    slstring.DelimitedText := NPCList[0];

    if slstring.Count = 0 then
    begin
      AddMessage('0 count slstring in ' + slfilelist[i]);
      Result := 0;
      Exit;
    end;

    if slstring.Count = 1 then
    begin
      if slstring[0] = 'NAVI' then
      begin
        _Signature := 'NAVI';
        _Grupname := 'NAVI';
        slSorted.AddStrings(NPCList);
        NPCList.Clear;
        slstring.Clear;
      end;
    end;
    if slstring.Count > 0 then
    begin
      _Signature := slstring[0];
      if ansipos('GRUP', slstring[3]) <> 0 then	_Grupname := (copy(slstring[3], (ansipos('GRUP', slstring[3]) + 19), 4))
      else _Grupname := _Signature;
    end;
    j := 0;
    while(j < NPCList.Count) do
    begin
      slstring.DelimitedText := NPCList[j];
      if ((_Signature <> '') AND (_Signature = slstring[0])) then
      begin
        if slSignatures.Count < NPCList.Count then AddMessage('ERROR1');
        slSorted.Add(NPCList[j]);
        NPCList.Delete(j);
      end
      else if _Signature = '' then
      begin
        AddMessage('ERROR: Empty _Signature String');
        Result := 0;
        Exit;
      end
      else j := (j + 1);
    end;
    filename := (Copy(slfilelist[i], 1, LastDelimiter('_', slfilelist[i]))
    + 'GRUP_'
    + _Grupname
    + '_SIG_'
    + _Signature
    + '_'
    + IntToStr(i)
    + '.csv');
    slSorted.SaveToFile(ProgramPath + 'data\' + filename);
    AddMessage('SAVED: ' + filename);
    slSorted.Clear;
    slfilelist2.Add(filename);
    if NPCList.Count = 0 then i := (i + 1);
  end;

	NPCList.Free;
	slfilelist2.SaveToFile(ProgramPath + 'data\' + '_filelist.csv');
	slfilelist.Free;
  slSignatures.Free;
  slGrups.Free;
  slSorted.Free;
  slfilelist2.Free;
  Result := 0;
end;

end.