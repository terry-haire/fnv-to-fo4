unit __FNVImportFuctionsTextv2;

//Current Method for Importing data

interface
implementation
uses xEditAPI, Classes, SysUtils, StrUtils, Windows; //Remove before use in xEdit

var
/// Lookup Lists
slPathsLookup,
slTemporaryDelimited,
slEntryLength,
slShortLookup,
slShortLookupPos,

/// Columns
slSingleValues,
slNewRec,
slNewRecSig,
slSingleRec,
slOldNewValMatch,
slNewPathorOrder,
slOldVal,
slNewVal,
slOldIndex,
slNewIndex,
slReplaceAnyVal,
slReplaceAnyIndex,
slIsFlag,

/// Converted Data
sl_Paths,
sl_Values,
sl_Integer,
sl_Flag,
sl_NewRec,

/// Sources
NPCList,
slstring,
slfilelist,

/// Logs
slloadorders,
slReferences,
slfailed,
slrecordconversions,
slFileExtensions: TStringList;

previousrec, previousrec2: IInterface;
debugmode, ExitAfterFail, SaveOnExit, OverwriteRecs: Boolean;
iAliasCounter: Integer;

function GetNewRecEDID(const rec: IInterface; const elementnewrec: String): String;
begin
  Result := GetFileName(GetFile(rec));
  Result := Copy(Result, 1, (LastDelimiter('.', Result) - 1)) + '_';
  Result := Result + elementnewrec + '_' + Copy(IntToHex(FormID(rec), 8), 3, 6);
  Result := Result + '_' + EditorID(rec);
end;

function OccurrencesOfChar(const S: string; const C: char): integer;
var
  i: Integer;
begin
  result := 0;
  for i := 1 to Length(S) do
    if S[i] = C then
      inc(result);
end;

function AddAlias(const rec: IInterface; const val: String): String;
var
rContainer, rAlias, rRef: IInterface;
s: String;
begin
  /// ElementValueString needs to be formatted to formid
  rContainer := ElementByPath(rec, 'Aliases');
  rRef := RecordByFormID(GetFile(rec), StrToInt('$' + val), True);
  if Assigned(rContainer) then
    rAlias := ElementAssign(rContainer, MaxInt, Nil, False)
  else
  begin
    rContainer := Add(rec, 'Aliases', True);
    rAlias := ElementByIndex(rContainer, 0);
  end;
  if Assigned(rAlias) then
  begin
    SetEditValue(Add(rAlias, 'ALST', True), IntToStr(iAliasCounter));
    if Assigned(rRef) then
    begin
      if GetFileName(GetFile(rRef)) = GetFileName(GetFile(rec)) then
      begin
        /// Set Target May have to change element path
        s := Signature(rRef);
        SetEditValue(Add(rAlias, 'ALFR', True), val);
      end;
    end;
  end;
  Result := IntToStr(iAliasCounter);
  Inc(iAliasCounter);
end;

procedure AddElementData(StartingRow: Integer; EndingRow: Integer; elementvaluestring: String; elementinteger: String);
var
k, l: Integer;
NewPath, NewVal, NewIndex, NewRec, IsFlag: String;
begin
  NewVal := elementvaluestring;
  for k := StartingRow to EndingRow do
  begin
    if slNewPathorOrder[k] <> '' then
    begin
      if NewPath <> '' then
      begin
        sl_Paths.Add(NewPath);
//        if NewVal = '' then
//          NewVal := elementvaluestring;
        sl_Values.Add(NewVal);
        if NewIndex = '' then
          NewIndex := elementinteger;
        sl_Integer.Add(NewIndex);
        if IsFlag = '' then
          IsFlag := 'FALSE';
        sl_Flag.Add(IsFlag);
        sl_NewRec.Add(NewRec);
//        NewPath := '';
        //NewVal := elementvaluestring;
//        NewRec := '';
//        IsFlag := '';
      end;
      NewPath := slNewPathorOrder[k];
    end;
    if slReplaceAnyVal[k] = 'TRUE' then
      NewVal := slNewVal[k];
    if slOldVal[k] = 'File' then
      if slNewVal[k] = 'File' then
      begin
        NewVal := elementvaluestring;
        if AnsiPos('.', elementvaluestring) <> 0 then
          for l := 0 to (slFileExtensions.Count - 1) do
          begin
            if LowerCase(Copy(elementvaluestring, LastDelimiter('.', elementvaluestring), MaxInt)) = slFileExtensions[l] then
            begin
              if slFileExtensions[l] = '.mp3' then
                NewVal := Copy(elementvaluestring, 1, (LastDelimiter('.', elementvaluestring) - 1)) + '.xwm';
              if slFileExtensions[l] = '.kf' then
                NewVal := Copy(elementvaluestring, 1, (LastDelimiter('.', elementvaluestring) - 1)) + '.hkx';
              if slFileExtensions[l] = '.egt' then
                NewVal := Copy(elementvaluestring, 1, (LastDelimiter('.', elementvaluestring) - 1)) + '.ssf';
              if slFileExtensions[l] = '.psa' then
                NewVal := Copy(elementvaluestring, 1, (LastDelimiter('.', elementvaluestring) - 1)) + '.hkx'; // Death pose
              // Missing speedtree (.spt)
            end;
          end;
        NewVal := 'new_vegas\' + NewVal;
      end;
    if elementvaluestring = slOldVal[k] then
      NewVal := slNewVal[k];
    if elementinteger = slOldIndex[k] then
    begin
      NewIndex := slNewIndex[k];
    end;
    if slNewIndex[k] <> '' then
    begin
      if slReplaceAnyIndex[k] <> 'TRUE' then
        NewIndex := slNewIndex[k];
    end;
    if slIsFlag[k] = 'TRUE' then
    begin
      IsFlag := 'TRUE';
    end;
    NewRec := slNewRec[k];
    if AnsiPos('#0', NewPath) <> 0 then
    begin
      if ((OccurrencesOfChar(NewPath, '#') = 1)
      AND (AnsiPos('Parameter #', NewPath) = 0)
      AND (AnsiPos('Attribute #', NewPath) = 0)
      AND (AnsiPos('Skill #', NewPath) = 0)
      AND (AnsiPos('Voice #', NewPath) = 0)
      AND (AnsiPos('Default Hair Style #', NewPath) = 0)
      AND (AnsiPos('Default Hair Color #', NewPath) = 0)
      AND (AnsiPos('ANAM\Related Camera Path #', NewPath) = 0)
      AND (AnsiPos('DATA\Particle Shader - Initial Velocity #', NewPath) = 0)
      AND (AnsiPos('DATA\Particle Shader - Acceleration #', NewPath) = 0)
      AND (AnsiPos('ANAM\Related Idle Animation #', NewPath) = 0)
      AND (AnsiPos('XORD\Plane #', NewPath) = 0)
      AND (AnsiPos('XPOD\References #', NewPath) = 0)
      AND (AnsiPos('NAM0\Type #', NewPath) = 0)
      ) then
      begin
        NewPath := StringReplace(NewPath, '#0', ('#' + elementinteger), [rfIgnoreCase]);
        elementinteger := IntToStr(MaxInt);
        if NewIndex <> '' then
        begin
          if NewIndex = '-2' then
            NewPath := '';
        end
        else
          NewIndex := IntToStr(MaxInt);
      end;
    end;
  end;
  sl_Paths.Add(NewPath);
//  if NewVal = '' then
//    NewVal := elementvaluestring;
  sl_Values.Add(NewVal);
  if NewIndex = '' then
    NewIndex := elementinteger;
  sl_Integer.Add(NewIndex);
  if IsFlag = '' then
    IsFlag := 'FALSE';
  sl_Flag.Add(IsFlag);
  sl_NewRec.Add(NewRec);
end;

function Build_slstring(elementpathstring: String; elementvaluestring: String; elementinteger: String): TStringList;
var
i, j, StartingRow, EndingRow: Integer;
begin
//      if elementpathstring = 'Parent\PNAM\Use Map Data' then
//      begin
//        AddMessage(elementpathstring);
//        for i := 0 to (slShortLookup.Count - 1) do
//          AddMessage(slShortLookup[i]);
//      end;
  Result := TStringList.Create;
  j := -1;
  for i := 0 to (slShortLookup.Count - 1) do
    if AnsiPos(slShortLookup[i], elementpathstring) <> 0 then
    begin
      j := StrToInt(slShortLookupPos[i]);
      Break;
    end;
  if j <> -1 then
  for i := j to (slPathsLookup.Count - 1) do
  begin
    if slPathsLookup[i] = elementpathstring then
    begin
      StartingRow := StrToInt(slEntryLength[i]);
      if i < (slPathsLookup.Count - 1) then
        EndingRow := (StrToInt(slEntryLength[(i + 1)]) - 1)
      else
        EndingRow := (slNewRec.Count - 1);
      //////////////////////////////////////////////////////////////////////////
      ///  Empty New Path
      //////////////////////////////////////////////////////////////////////////
//      AddMessage(IntToStr(slNewPathorOrder.Count));
      if StartingRow > (slNewPathorOrder.Count - 1) then
        Exit;
      if slNewPathorOrder[StartingRow] = '' then
      begin
        if i = (slPathsLookup.Count - 1) then
          Exit
        else
        begin
          elementpathstring := '';
          Continue;
        end;
      end;
      if slNewRec[StartingRow] <> '1' then
      begin
        AddElementData(StartingRow, EndingRow, elementvaluestring, elementinteger);
      end;
      Exit;
    end;
  end;
  sl_Paths.Add(elementpathstring);
  sl_Values.Add(elementvaluestring);
  sl_Integer.Add(elementinteger);
  sl_Flag.Add('FALSE');
  sl_NewRec.Add('');
end;

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

function CheckForErrors(element: IInterface): String;
var
i: Integer;
elementcur: IInterface;
begin
	for i := 0 to (ElementCount(element)-1) do
	begin
    elementcur := ElementByIndex(element, i);
    Result := Check(elementcur);
    if Result <> '' then
    begin
      if AnsiPos('Record Header', Path(elementcur)) = 0 then
      begin
        Result := formatelementpath(Path(elementcur)) + #13#10 + Result;
        Exit;
      end;
    end;
		if ElementCount(elementcur) > 0 then Result := CheckForErrors(elementcur);
	end;
end;

function ExitSequence(const _rec: IInterface; const _cont: IInterface; const _formid: String; const _path: String; const _value: String; const _integer: String; const _flag: String): Integer;
begin
	AddMessage('FAILED');
  AddMessage('PATH     : ' + _path);
  AddMessage('VALUE    : ' + _value);
  AddMessage('INTEGER  : ' + _integer);
  AddMessage('ISFLAG   : ' + _flag);
  if Assigned(_cont) then AddMessage('CONTPATH : ' + Copy(formatelementpath(Path(_cont)), 6, MaxInt))
  else AddMessage('Container not Assigned');
  if Assigned(_rec) then AddMessage(Name(_rec))
  else AddMessage('Record not Assigned');
	slfailed.Add(_formid + ';' + _integer + ';' + _path); // formid + elementpathstring
  if (SaveOnExit AND ExitAfterFail) then
  begin
    slReferences.SaveToFile(ProgramPath + 'data\' + '__ReferenceList.csv');
	  slfailed.SaveToFile(ProgramPath + 'data\' + '__FailedList.csv');
	  slloadorders.SaveToFile(ProgramPath + 'data\' + '__Loadorders.csv');
  end;
  if ExitAfterFail then Result := 1
  else Result := 0;
end;

function RetrieveIndexPath(s: String): String;
var
i: Integer;
begin
  i := ansipos(']\[', s);
  if i <> 0 then s := Copy(s, (i + 3), MaxInt);
  i := ansipos('\[', s);
  if i <> 0 then
  begin
    i := ansipos('\[', s);
    if ((i <> 0) AND (i < AnsiPos(']', s))) then
      s := Copy(s, 1, LastDelimiter(';', s)) + Copy(s, (i + 2), MaxInt);
    i := ansipos('\[', s);
    if ((i <> 0) AND (i > AnsiPos(']', s))) then
    begin
      s := Copy(s, 1, (AnsiPos(']', s) - 1)) + ';' + Copy(s, ansipos('\[', s), MaxInt);
      s := RetrieveIndexPath(s);
    end
    else s := Copy(s, 1, (AnsiPos(']', s) - 1));
  end;
  if AnsiPos(']', s) <> 0 then s := Copy(s, 1, (AnsiPos(']', s) - 1));
  if s = '' then
  begin
    AddMessage('Warning: RetrieveIndexPath returned nothing');
    s := '0'
  end;
  Result := s;
end;

/// Before ElementPathstring check
//function CreateElementCTDA(

procedure CreateElementQuick1(const rec: IInterface; const elementpathstring: String; const elementvaluestring: String);
var
subrec: IInterface;
begin
  subrec := Add(rec, elementpathstring, True);
  try
    SetEditValue(subrec, elementvaluestring);
  except
    On E :Exception do
    begin
      if Copy(E.Message, 12, MaxInt) <> '< Error: Could not be resolved >' then
      begin
        AddMessage(Copy(E.Message, 12, MaxInt));
        SetEditValue(subrec, elementvaluestring);
        Exit;
      end;
    end;
  end;
  previousrec := subrec;
end;

////////////////////////////////////////////////////////////////////////////////
///  Procedure for Creating and modifying Elements
////////////////////////////////////////////////////////////////////////////////
function CreateElement(rec: IInterface; originalloadorder: String; fileloadorder: String; elementpathstring: String; elementvaluestring: String; elementinteger: integer; elementisflag: String): Integer;
var
subrec, subrec_container: IInterface;
containerpathstring: String;
k: integer;
begin
  Result := 0;

  //////////////////////////////////////////////////////////////////////////////
  ///  Temp solution for snam
  //////////////////////////////////////////////////////////////////////////////
  if elementpathstring = 'SNAM' then
    if elementvaluestring = '' then
      elementpathstring := '';

  //////////////////////////////////////////////////////////////////////////////
  ///  Temp solution for CREA RNAM
  //////////////////////////////////////////////////////////////////////////////
  if elementpathstring = 'RNAM' then
    if Signature(rec) = 'NPC_' then
    begin
		  if Length(elementvaluestring) <> 8 then
        elementpathstring := '';
    end;

  if Signature(rec) = 'REGN' then
    if elementpathstring = 'WNAM' then
      if elementvaluestring = '' then
        elementpathstring := '';

  if Signature(rec) = 'WATR' then
    if elementpathstring = 'TNAM' then
      if elementvaluestring = '' then
        elementpathstring := '';

  //////////////////////////////////////////////////////////////////////////////
  ///  Temp Solution for Conditions
  //////////////////////////////////////////////////////////////////////////////
  if AnsiPos('Conditions\Condition\CTDA\', elementpathstring) <> 0 then
  begin
    if ((Name(previousrec) = 'Effects') OR (Name(previousrec) = 'Conditions')) then
      elementpathstring := '';
    if not Assigned(previousrec) then elementpathstring := '';
    if Name(previousrec) = 'CTDA - ' then
      subrec_container := previousrec;
    if Name(GetContainer(previousrec)) = 'CTDA - ' then
      subrec_container := GetContainer(previousrec);
    if Assigned(subrec_container) then
    begin
      if GetElementEditValues(subrec_container, 'Function') = 'GetWantBlocking' then
      begin
        if Copy(elementpathstring, (LastDelimiter('\', elementpathstring) + 1), MaxInt) = 'Parameter #1' then
          elementpathstring := '';
        if Copy(elementpathstring, (LastDelimiter('\', elementpathstring) + 1), MaxInt) = 'Parameter #2' then
          elementpathstring := '';
      end;
      if GetElementEditValues(subrec_container, 'Function') = 'HasPerk' then
        if Copy(elementpathstring, (LastDelimiter('\', elementpathstring) + 1), MaxInt) = 'Parameter #1' then
          elementinteger := 5;
      if GetElementEditValues(subrec_container, 'Function') = 'HasPerk' then
        if Copy(elementpathstring, (LastDelimiter('\', elementpathstring) + 1), MaxInt) = 'Parameter #2' then
          elementpathstring := '';
      if GetElementEditValues(subrec_container, 'Function') = 'GetIsID' then
        if Copy(elementpathstring, (LastDelimiter('\', elementpathstring) + 1), MaxInt) = 'Parameter #1' then
          elementinteger := 5;
      if GetElementEditValues(subrec_container, 'Function') = 'GetIsID' then
        if Copy(elementpathstring, (LastDelimiter('\', elementpathstring) + 1), MaxInt) = 'Parameter #2' then
          elementinteger := 6;
      if GetElementEditValues(subrec_container, 'Function') = 'GetIsReference' then
        if Copy(elementpathstring, (LastDelimiter('\', elementpathstring) + 1), MaxInt) = 'Parameter #1' then
          elementinteger := 5;
      if GetElementEditValues(subrec_container, 'Function') = 'GetIsReference' then
        if Copy(elementpathstring, (LastDelimiter('\', elementpathstring) + 1), MaxInt) = 'Parameter #2' then
          elementinteger := 6;
      if GetElementEditValues(subrec_container, 'Function') = 'GetItemCount' then
        if Copy(elementpathstring, (LastDelimiter('\', elementpathstring) + 1), MaxInt) = 'Parameter #1' then
          elementinteger := 5;
      if GetElementEditValues(subrec_container, 'Function') = 'GetItemCount' then
        if Copy(elementpathstring, (LastDelimiter('\', elementpathstring) + 1), MaxInt) = 'Parameter #2' then
          elementinteger := 6;
      if GetElementEditValues(subrec_container, 'Function') = 'GetVATSValue' then
        if Copy(elementpathstring, (LastDelimiter('\', elementpathstring) + 1), MaxInt) = 'Parameter #1' then
          elementpathstring := '';
      if GetElementEditValues(subrec_container, 'Function') = 'GetVATSValue' then
        if Copy(elementpathstring, (LastDelimiter('\', elementpathstring) + 1), MaxInt) = 'Parameter #2' then
          elementpathstring := '';
      if GetElementEditValues(subrec_container, 'Function') = 'GetWantBlocking' then
        if Copy(elementpathstring, (LastDelimiter('\', elementpathstring) + 1), MaxInt) = 'Comparison Value' then
        begin
          try
            StrToInt(elementvaluestring);
          except
            elementvaluestring := '';
          end;
        end;
      if GetElementEditValues(subrec_container, 'Function') = 'GetVMQuestVariable' then
        if Copy(elementpathstring, (LastDelimiter('\', elementpathstring) + 1), MaxInt) = 'Parameter #1' then
        begin
          elementinteger := 5;
          if elementvaluestring = 'NULL - Null Reference [00000000]' then
          begin
            elementpathstring := '';
            SetElementEditValues(subrec_container, 'Function', 'GetWantBlocking');
          end;
        end;
      if GetElementEditValues(subrec_container, 'Function') = 'GetVMQuestVariable' then
        if Copy(elementpathstring, (LastDelimiter('\', elementpathstring) + 1), MaxInt) = 'Parameter #2' then
        begin
          elementpathstring := '';
          elementinteger := 6;
        end;
      if GetElementEditValues(subrec_container, 'Function') = 'GetInCell' then
        if Copy(elementpathstring, (LastDelimiter('\', elementpathstring) + 1), MaxInt) = 'Parameter #1' then
        begin
          elementinteger := 5;
          if elementvaluestring = 'NULL - Null Reference [00000000]' then elementvaluestring := 'aaaMarkers "Marker Cell" [CELL:F4058955]';
        end;
      if GetElementEditValues(subrec_container, 'Function') = 'GetInCell' then
        if Copy(elementpathstring, (LastDelimiter('\', elementpathstring) + 1), MaxInt) = 'Parameter #2' then
          elementinteger := 6;
      if GetElementEditValues(subrec_container, 'Function') = 'GetDead' then
        if Copy(elementpathstring, (LastDelimiter('\', elementpathstring) + 1), MaxInt) = 'Parameter #1' then
          elementinteger := 5;
      if GetElementEditValues(subrec_container, 'Function') = 'GetDead' then
        if Copy(elementpathstring, (LastDelimiter('\', elementpathstring) + 1), MaxInt) = 'Parameter #2' then
          elementinteger := 6;
      if GetElementEditValues(subrec_container, 'Function') = 'GetLocked' then
        if Copy(elementpathstring, (LastDelimiter('\', elementpathstring) + 1), MaxInt) = 'Parameter #1' then
          elementinteger := 5;
      if GetElementEditValues(subrec_container, 'Function') = 'GetLocked' then
        if Copy(elementpathstring, (LastDelimiter('\', elementpathstring) + 1), MaxInt) = 'Parameter #2' then
          elementinteger := 6;
      if GetElementEditValues(subrec_container, 'Function') = 'GetDisabled' then
        if Copy(elementpathstring, (LastDelimiter('\', elementpathstring) + 1), MaxInt) = 'Parameter #1' then
          elementinteger := 5;
      if GetElementEditValues(subrec_container, 'Function') = 'GetDisabled' then
        if Copy(elementpathstring, (LastDelimiter('\', elementpathstring) + 1), MaxInt) = 'Parameter #2' then
          elementinteger := 6;
      if GetElementEditValues(subrec_container, 'Function') = 'GetInWorldspace' then
        if Copy(elementpathstring, (LastDelimiter('\', elementpathstring) + 1), MaxInt) = 'Parameter #1' then
        begin
          elementinteger := 5;
          if elementvaluestring = 'NULL - Null Reference [00000000]' then
          begin
            elementpathstring := '';
            SetElementEditValues(subrec_container, 'Function', 'GetWantBlocking');
          end;
        end;
      if GetElementEditValues(subrec_container, 'Function') = 'GetInWorldspace' then
        if Copy(elementpathstring, (LastDelimiter('\', elementpathstring) + 1), MaxInt) = 'Parameter #2' then
        begin
          elementpathstring := '';
          elementinteger := 6;
        end;
      if GetElementEditValues(subrec_container, 'Function') = 'GetUnconscious' then
        if Copy(elementpathstring, (LastDelimiter('\', elementpathstring) + 1), MaxInt) = 'Parameter #1' then
          elementinteger := 5;
      if GetElementEditValues(subrec_container, 'Function') = 'GetUnconscious' then
        if Copy(elementpathstring, (LastDelimiter('\', elementpathstring) + 1), MaxInt) = 'Parameter #2' then
          elementinteger := 6;
      if GetElementEditValues(subrec_container, 'Function') = 'GetDeadCount' then
        if Copy(elementpathstring, (LastDelimiter('\', elementpathstring) + 1), MaxInt) = 'Parameter #1' then
        begin
          elementinteger := 5;
          if elementvaluestring = 'NULL - Null Reference [00000000]' then
          begin
            elementpathstring := '';
            SetElementEditValues(subrec_container, 'Function', 'GetWantBlocking');
          end;
        end;
      if GetElementEditValues(subrec_container, 'Function') = 'GetDeadCount' then
        if Copy(elementpathstring, (LastDelimiter('\', elementpathstring) + 1), MaxInt) = 'Parameter #2' then
        begin
          elementpathstring := '';
          elementinteger := 6;
        end;
      if GetElementEditValues(subrec_container, 'Function') = 'GetObjectiveCompleted' then
        if Copy(elementpathstring, (LastDelimiter('\', elementpathstring) + 1), MaxInt) = 'Parameter #1' then
          elementinteger := 5;
      if GetElementEditValues(subrec_container, 'Function') = 'GetObjectiveCompleted' then
        if Copy(elementpathstring, (LastDelimiter('\', elementpathstring) + 1), MaxInt) = 'Parameter #2' then
        begin
          elementvaluestring := '';
          elementinteger := 6;
        end;
      if GetElementEditValues(subrec_container, 'Function') = 'GetObjectiveDisplayed' then
        if Copy(elementpathstring, (LastDelimiter('\', elementpathstring) + 1), MaxInt) = 'Parameter #1' then
          elementinteger := 5;
      if GetElementEditValues(subrec_container, 'Function') = 'GetObjectiveDisplayed' then
        if Copy(elementpathstring, (LastDelimiter('\', elementpathstring) + 1), MaxInt) = 'Parameter #2' then
        begin
          elementvaluestring := '';
          elementinteger := 6;
        end;
      if GetElementEditValues(subrec_container, 'Function') = 'GetDestructionStage' then
        if Copy(elementpathstring, (LastDelimiter('\', elementpathstring) + 1), MaxInt) = 'Parameter #1' then
          elementinteger := 5;
      if GetElementEditValues(subrec_container, 'Function') = 'GetDestructionStage' then
        if Copy(elementpathstring, (LastDelimiter('\', elementpathstring) + 1), MaxInt) = 'Parameter #2' then
          elementinteger := 6;
      if GetElementEditValues(subrec_container, 'Function') = 'GetPos' then
        if Copy(elementpathstring, (LastDelimiter('\', elementpathstring) + 1), MaxInt) = 'Parameter #1' then
          elementinteger := 5;
      if GetElementEditValues(subrec_container, 'Function') = 'GetPos' then
        if Copy(elementpathstring, (LastDelimiter('\', elementpathstring) + 1), MaxInt) = 'Parameter #2' then
          elementinteger := 6;
      if GetElementEditValues(subrec_container, 'Function') = 'GetGlobalValue' then
        if Copy(elementpathstring, (LastDelimiter('\', elementpathstring) + 1), MaxInt) = 'Parameter #1' then
          elementinteger := 5;
      if GetElementEditValues(subrec_container, 'Function') = 'GetGlobalValue' then
        if Copy(elementpathstring, (LastDelimiter('\', elementpathstring) + 1), MaxInt) = 'Parameter #2' then
          elementinteger := 6;
      if GetElementEditValues(subrec_container, 'Function') = 'GetIsCreatureType' then
        if Copy(elementpathstring, (LastDelimiter('\', elementpathstring) + 1), MaxInt) = 'Parameter #1' then
        begin
          elementvaluestring := '';
          elementinteger := 5;
        end;
      if GetElementEditValues(subrec_container, 'Function') = 'GetIsCreatureType' then
        if Copy(elementpathstring, (LastDelimiter('\', elementpathstring) + 1), MaxInt) = 'Parameter #2' then
          elementinteger := 6;
      if GetElementEditValues(subrec_container, 'Function') = 'GetEquipped' then
        if Copy(elementpathstring, (LastDelimiter('\', elementpathstring) + 1), MaxInt) = 'Parameter #1' then
          elementinteger := 5;
      if GetElementEditValues(subrec_container, 'Function') = 'GetEquipped' then
        if Copy(elementpathstring, (LastDelimiter('\', elementpathstring) + 1), MaxInt) = 'Parameter #2' then
          elementinteger := 6;
      if GetElementEditValues(subrec_container, 'Function') = 'GetValue' then
        if Copy(elementpathstring, (LastDelimiter('\', elementpathstring) + 1), MaxInt) = 'Parameter #1' then
        begin
          elementvaluestring := '';
          elementinteger := 5;
        end;
      if GetElementEditValues(subrec_container, 'Function') = 'GetValue' then
        if Copy(elementpathstring, (LastDelimiter('\', elementpathstring) + 1), MaxInt) = 'Parameter #2' then
          elementinteger := 6;
      if GetElementEditValues(subrec_container, 'Function') = 'IsInCombat' then
        if Copy(elementpathstring, (LastDelimiter('\', elementpathstring) + 1), MaxInt) = 'Parameter #1' then
        begin
          elementvaluestring := '';
          elementinteger := 5;
        end;
      if GetElementEditValues(subrec_container, 'Function') = 'IsInCombat' then
        if Copy(elementpathstring, (LastDelimiter('\', elementpathstring) + 1), MaxInt) = 'Parameter #2' then
          elementinteger := 6;
      if GetElementEditValues(subrec_container, 'Function') = 'GetIsUsedItemType' then
        if Copy(elementpathstring, (LastDelimiter('\', elementpathstring) + 1), MaxInt) = 'Parameter #1' then
          elementinteger := 5;
      if GetElementEditValues(subrec_container, 'Function') = 'GetIsUsedItemType' then
        if Copy(elementpathstring, (LastDelimiter('\', elementpathstring) + 1), MaxInt) = 'Parameter #2' then
          elementinteger := 6;
      if GetElementEditValues(subrec_container, 'Function') = 'GetStage' then
        if Copy(elementpathstring, (LastDelimiter('\', elementpathstring) + 1), MaxInt) = 'Parameter #1' then
        begin
          elementinteger := 5;
          if elementvaluestring = 'NULL - Null Reference [00000000]' then
          begin
            elementpathstring := '';
            SetElementEditValues(subrec_container, 'Function', 'GetWantBlocking');
          end;
        end;
      if GetElementEditValues(subrec_container, 'Function') = 'GetStage' then
        if Copy(elementpathstring, (LastDelimiter('\', elementpathstring) + 1), MaxInt) = 'Parameter #2' then
        begin
          elementpathstring := '';
          elementinteger := 6;
        end;
      if GetElementEditValues(subrec_container, 'Function') = 'GetQuestRunning' then
        if Copy(elementpathstring, (LastDelimiter('\', elementpathstring) + 1), MaxInt) = 'Parameter #1' then
        begin
          elementinteger := 5;
          if elementvaluestring = 'NULL - Null Reference [00000000]' then
          begin
            elementpathstring := '';
            SetElementEditValues(subrec_container, 'Function', 'GetWantBlocking');
          end;
        end;
      if GetElementEditValues(subrec_container, 'Function') = 'GetQuestRunning' then
        if Copy(elementpathstring, (LastDelimiter('\', elementpathstring) + 1), MaxInt) = 'Parameter #2' then
        begin
          elementpathstring := '';
          elementinteger := 6;
        end;
      if GetElementEditValues(subrec_container, 'Function') = 'GetQuestCompleted' then
        if Copy(elementpathstring, (LastDelimiter('\', elementpathstring) + 1), MaxInt) = 'Parameter #1' then
        begin
          elementinteger := 5;
          if elementvaluestring = 'NULL - Null Reference [00000000]' then
          begin
            elementpathstring := '';
            SetElementEditValues(subrec_container, 'Function', 'GetWantBlocking');
          end;
        end;
      if GetElementEditValues(subrec_container, 'Function') = 'GetQuestCompleted' then
        if Copy(elementpathstring, (LastDelimiter('\', elementpathstring) + 1), MaxInt) = 'Parameter #2' then
        begin
          elementpathstring := '';
          elementinteger := 6;
        end;
      if GetElementEditValues(subrec_container, 'Function') = 'GetFactionReaction' then
        if Copy(elementpathstring, (LastDelimiter('\', elementpathstring) + 1), MaxInt) = 'Parameter #1' then
        begin
          elementinteger := 5;
          if elementvaluestring = 'NULL - Null Reference [00000000]' then
          begin
            elementpathstring := '';
            SetElementEditValues(subrec_container, 'Function', 'GetWantBlocking');
          end;
        end;
      if GetElementEditValues(subrec_container, 'Function') = 'GetFactionReaction' then
        if Copy(elementpathstring, (LastDelimiter('\', elementpathstring) + 1), MaxInt) = 'Parameter #2' then
        begin
          elementinteger := 6;
          if elementvaluestring = 'NULL - Null Reference [00000000]' then
          begin
            elementpathstring := '';
            SetElementEditValues(subrec_container, 'Function', 'GetWantBlocking');
          end;
        end;
      if GetElementEditValues(subrec_container, 'Function') = 'GetStageDone' then
        if Copy(elementpathstring, (LastDelimiter('\', elementpathstring) + 1), MaxInt) = 'Parameter #1' then
        begin
          elementinteger := 5;
          if elementvaluestring = 'NULL - Null Reference [00000000]' then
          begin
            elementpathstring := '';
            SetElementEditValues(subrec_container, 'Function', 'GetWantBlocking');
          end;
        end;
      if GetElementEditValues(subrec_container, 'Function') = 'GetStageDone' then
        if Copy(elementpathstring, (LastDelimiter('\', elementpathstring) + 1), MaxInt) = 'Parameter #2' then
          elementinteger := 6;
          if elementvaluestring = '0 <Warning: Could not resolve Parameter 1>' then
            elementpathstring := '';
      if GetElementEditValues(subrec_container, 'Function') = 'GetFactionReaction' then
        if Copy(elementpathstring, (LastDelimiter('\', elementpathstring) + 1), MaxInt) = 'Parameter #1' then
        begin
          elementvaluestring := '';
          elementinteger := 5;
        end;
      if GetElementEditValues(subrec_container, 'Function') = 'GetFactionReaction' then
        if Copy(elementpathstring, (LastDelimiter('\', elementpathstring) + 1), MaxInt) = 'Parameter #2' then
        begin
          elementvaluestring := '';
          elementinteger := 6;
        end;
      if GetElementEditValues(subrec_container, 'Function') = 'IsWeaponSkillType' then
        if Copy(elementpathstring, (LastDelimiter('\', elementpathstring) + 1), MaxInt) = 'Parameter #1' then
        begin
          elementvaluestring := '';
          elementinteger := 5;
        end;
      if GetElementEditValues(subrec_container, 'Function') = 'IsWeaponSkillType' then
        if Copy(elementpathstring, (LastDelimiter('\', elementpathstring) + 1), MaxInt) = 'Parameter #2' then
        begin
          elementvaluestring := '';
          elementinteger := 6;
        end;
      if GetElementEditValues(subrec_container, 'Function') = 'GetPermanentValue' then
        if Copy(elementpathstring, (LastDelimiter('\', elementpathstring) + 1), MaxInt) = 'Parameter #1' then
        begin
          elementinteger := 5;
          if elementvaluestring = 'Strength'      then elementvaluestring := 'Strength "Strength" [AVIF:F40002C2]';
          if elementvaluestring = 'Perception'    then elementvaluestring := 'Perception "Perception" [AVIF:F40002C3]';
          if elementvaluestring = 'Endurance'     then elementvaluestring := 'Endurance "Endurance" [AVIF:F40002C4]';
          if elementvaluestring = 'Charisma'      then elementvaluestring := 'Charisma "Charisma" [AVIF:F40002C5]';
          if elementvaluestring = 'Intelligence'  then elementvaluestring := 'Intelligence "Intelligence" [AVIF:F40002C6]';
          if elementvaluestring = 'Agility'       then elementvaluestring := 'Agility "Agility" [AVIF:F40002C7]';
          if elementvaluestring = 'Luck'          then elementvaluestring := 'Luck "Luck" [AVIF:F40002C8]';
          if elementvaluestring = 'Survival'      then elementvaluestring := '';
          if elementvaluestring = 'Explosives'    then elementvaluestring := '';
          if elementvaluestring = 'Sneak'         then elementvaluestring := '';
          if elementvaluestring = 'Science'      then elementvaluestring := '';
          if elementvaluestring = 'Melee Weapons'      then elementvaluestring := '';
          if elementvaluestring = 'Unarmed'      then elementvaluestring := '';
          if elementvaluestring = 'Energy Weapons'      then elementvaluestring := '';
          if elementvaluestring = 'Guns'      then elementvaluestring := '';
          if elementvaluestring = 'Lockpick'      then elementvaluestring := '';
          if elementvaluestring = 'Medicine'      then elementvaluestring := '';
          if elementvaluestring = 'Speech'      then elementvaluestring := '';
          if elementvaluestring = 'Barter'      then elementvaluestring := '';
          if elementvaluestring = 'Repair'      then elementvaluestring := '';
          if elementvaluestring = 'Survival'      then elementvaluestring := '';
          if elementvaluestring = 'Survival'      then elementvaluestring := '';
          if elementvaluestring = 'Survival'      then elementvaluestring := '';
          if elementvaluestring = 'Survival'      then elementvaluestring := '';
          if elementvaluestring = 'Survival'      then elementvaluestring := '';
          if elementvaluestring = 'Survival'      then elementvaluestring := '';
          if elementvaluestring = 'Survival'      then elementvaluestring := '';
          if elementvaluestring = 'Survival'      then elementvaluestring := '';
          if elementvaluestring = 'Survival'      then elementvaluestring := '';
          if elementvaluestring = 'Survival'      then elementvaluestring := '';
        end;
      if GetElementEditValues(subrec_container, 'Function') = 'GetPermanentValue' then
        if Copy(elementpathstring, (LastDelimiter('\', elementpathstring) + 1), MaxInt) = 'Parameter #2' then
          elementinteger := 6;
      if GetElementEditValues(subrec_container, 'Function') = 'GetIsObjectType' then
        if Copy(elementpathstring, (LastDelimiter('\', elementpathstring) + 1), MaxInt) = 'Parameter #1' then
        begin
          elementinteger := 5;
          if elementvaluestring = 'NPC' then elementvaluestring := 'Actor';
        end;
      if GetElementEditValues(subrec_container, 'Function') = 'GetIsObjectType' then
        if Copy(elementpathstring, (LastDelimiter('\', elementpathstring) + 1), MaxInt) = 'Parameter #2' then
          elementinteger := 6;
      if GetElementEditValues(subrec_container, 'Function') = 'IsInList' then
        if Copy(elementpathstring, (LastDelimiter('\', elementpathstring) + 1), MaxInt) = 'Parameter #1' then
          elementinteger := 5;
      if GetElementEditValues(subrec_container, 'Function') = 'IsInList' then
        if Copy(elementpathstring, (LastDelimiter('\', elementpathstring) + 1), MaxInt) = 'Parameter #2' then
          elementinteger := 6;
      subrec_container := Nil;
    end;
  end;

	if elementpathstring <> '' then
	begin
    //TEMPORARY
//    if ((Signature(rec) = 'ACTI') AND (elementpathstring = 'Record Header\Record Flags\Persistent')) then Exit;
//    if ((Signature(rec) = 'AMMO') AND (elementpathstring = 'ICON')) then Exit;
//    if ((Signature(rec) = 'AVIF') AND (elementpathstring = 'ICON')) then Exit;
    //TEMPORARY
		//AddMessage(Path(previousrec));
		//AddMessage(IntToStr(elementinteger));

    ////////////////////////////////////////////////////////////////////////////
    ///  Subrec Creation / Selection
    ////////////////////////////////////////////////////////////////////////////
		subrec := ElementByPath(rec, elementpathstring);
		if not Assigned(subrec) then
			subrec := Add(rec, elementpathstring, True);
		begin
			containerpathstring := elementpathstring;
			containerpathstring := copy(containerpathstring, 1, (LastDelimiter('\', containerpathstring) - 1));
			subrec_container := previousrec;
			if (ansipos(containerpathstring, formatelementpath(Copy(Path(subrec_container), 8, MaxInt))) <> 0) then
			begin
				While (containerpathstring <> formatelementpath(Copy(Path(subrec_container), 8, MaxInt))) do
					subrec_container := GetContainer(subrec_container);
				if not Assigned(subrec) then subrec := ElementByIndex(subrec_container, elementinteger);
				if ((IndexOf(GetContainer(subrec), subrec) <> elementinteger)
				OR (not Assigned(subrec)) 
//				OR (elementpathstring = 'Effects\Effect\Conditions\Condition\CIS1')
//				OR (elementpathstring = 'Effects\Effect\Conditions\Condition\CIS2')
				OR (elementpathstring = 'Effects\Effect\Conditions')
        OR (elementpathstring = 'Conditions')
//        OR (elementpathstring = 'Conditions\Condition\CIS1')
//        OR (elementpathstring = 'Conditions\Condition\CIS2')
        OR (elementpathstring = 'Stages\Stage\Log Entries')
        OR (elementpathstring = 'Stages\Stage\Log Entries\Log Entry\Conditions')
        OR (elementpathstring = 'Objectives\Objective\Targets\Target\Conditions')
        OR (elementpathstring = 'Menu Buttons\Menu Button\Conditions')
        OR (elementpathstring = 'Ranks\Rank\MNAM')
        OR (elementpathstring = 'Ranks\Rank\FNAM')
        OR (elementpathstring = 'Ranks\Rank\INAM')
        OR (elementpathstring = 'Leveled List Entries\Leveled List Entry\COED')
        OR (elementpathstring = 'Effects\Effect\Perk Conditions')
        OR (elementpathstring = 'Effects\Effect\Perk Conditions\Perk Condition\PRKC')
        OR (elementpathstring = 'Effects\Effect\Function Parameters\EPFT')
        OR (elementpathstring = 'Textures (RGB/A)\TX03')
        OR (elementpathstring = 'Items\Item\COED')
        OR (elementpathstring = 'Material Substitutions\Substitution\SNAM')
        OR (elementpathstring = 'Body Data\Male Body Data\Parts\Part\Model')
        OR (elementpathstring = 'Body Data\Male Body Data\Parts\Part\Model\MODT')
        OR (elementpathstring = 'Body Data\Female Body Data\Parts\Part\Model')
        OR (elementpathstring = 'Body Data\Female Body Data\Parts\Part\Model\MODT')



//        OR (elementpathstring = 'Stages\Stage\Log Entries\Log Entry\Conditions\Condition\CIS1')
//        OR (elementpathstring = 'Stages\Stage\Log Entries\Log Entry\Conditions\Condition\CIS2')
				) then
        begin
//          AddMessage(Path(subrec_container));
//          AddMessage(elementpathstring);
//          AddMessage(IntToStr(elementinteger));
          try
            subrec := ElementAssign(subrec_container, elementinteger, nil, False);
          except
            AddMessage('EXCEPTION in ElementAssign: Try MaxInt (2147483647) as elementinteger');
            Result := ExitSequence(rec, subrec_container, slstring[0], elementpathstring, elementvaluestring, IntToStr(elementinteger), elementisflag);
            Exit;
          end;
        end
				else subrec := ElementByIndex(subrec_container, elementinteger);
//        AddMessage(Path(subrec));
			end
			else 
			begin
				//AddMessage(elementpathstring);
				//AddMessage(formatelementpath(Copy(Path(subrec_container), 8, MaxInt)));
			end;
		end;

    ////////////////////////////////////////////////////////////////////////////
    ///  Check if value is valid
    ////////////////////////////////////////////////////////////////////////////
//    if ((AnsiPos('Flags\', elementpathstring) <> 0)
//    AND (LastDelimiter('\', elementpathstring) = (AnsiPos('Flags\', elementpathstring) + 5))
//    AND Assigned(subrec_container)) then
//    if FlagValues(subrec_container) <> '' then
    if elementisflag = 'TRUE' then
    begin
//      AddMessage(GetElementEditValues(rec, 'Record Header\Record Flags'));
      if elementinteger = 0 then
      begin
        AddMessage('Warning Flags Integer is 0. Fix in corrosponding elementconversions file.');
        Result := ExitSequence(rec, subrec_container, slstring[0], elementpathstring, elementvaluestring, IntToStr(elementinteger), elementisflag);
        Exit;
      end;
//      AddMessage('STARTING');
//      AddMessage(Path(subrec_container));
//      if LastDelimiter('0123456789', elementvaluestring)
      //if AnsiPos('1', GetEditValue(subrec_container)) <> 0 then
//      AddMessage(IntToStr(Length(elementvaluestring)));
//      AddMessage(elementpathstring);
      elementvaluestring := GetEditValue(subrec_container);
//      AddMessage('START');
//      AddMessage(elementvaluestring);
//      AddMessage(IntToStr(elementinteger));
//      AddMessage(GetElementEditValues(rec, 'Record Header\Record Flags'));
      if Length(elementvaluestring) < elementinteger then
      begin
        if elementinteger - Length(elementvaluestring) <> 1 then
        begin
//          AddMessage('HERE1');
          for k := Length(elementvaluestring) to (elementinteger - 2) do
            elementvaluestring := elementvaluestring + '0';
          elementvaluestring := elementvaluestring + '1';
        end
        else
        elementvaluestring := elementvaluestring + '1';
      end
      else
      begin
//        AddMessage('HERE2');
//        AddMessage(elementvaluestring);
        Insert('1', elementvaluestring, elementinteger);
        Delete(elementvaluestring, (elementinteger + 1), 1);
//        AddMessage('INTO');
//        AddMessage(elementvaluestring);
      end;
      try
        SetEditValue(subrec_container, elementvaluestring);
      except
        AddMessage('SUBREC_CONTAINER NOT EDITABLE');
        Result := ExitSequence(rec, subrec_container, slstring[0], elementpathstring, elementvaluestring, IntToStr(elementinteger), elementisflag);
        Exit;
      end;
      //AddMessage('ETYKOK');
      //if Assigned(subrec_container) then AddMessage('Assigned');
      //AddMessage(path(subrec_container));
      //Add(subrec_container, 'Ignored', True);
      //SetEditValue(subrec_container, '000001');
      //Exit;
      elementvaluestring := '';
      subrec := ElementByPath(subrec_container, Copy(elementpathstring, (LastDelimiter('\', elementpathstring) + 1), MaxInt));
//      AddMessage(GetElementEditValues(rec, 'Record Header\Record Flags'));
    end;

    ////////////////////////////////////////////////////////////////////////////
    ///  Temporary solution for Alpha Layers
    ////////////////////////////////////////////////////////////////////////////
    if elementpathstring = 'Layers\Alpha Layer' then
    begin
      Remove(subrec);
      subrec := RecordByFormID(FileByIndex(0), $000138DE, True); // Fallout4.esm LAND Record
      subrec := ElementByPath(subrec, 'Layers\Alpha Layer');
      subrec := ElementAssign(subrec_container, elementinteger, subrec, False);
    end;

    ////////////////////////////////////////////////////////////////////////////
    ///  Temporary Solution for XMRC may not be neeeded
    ////////////////////////////////////////////////////////////////////////////
//    if elementpathstring = 'XMRC' then
//    begin
//      if Signature(rec) = 'ACHR' then
//      begin
//        ElementAssign()
//      end;
//    end;
//    AddMessage(Path(subrec));
//    if Path(subrec) = 'REGN \ Region Data Entries \ Region Data Entry \ RDMO - Music' then
//    begin
//      AddMessage('YES');
//      if elementpathstring = 'Region Data Entries\Region Data Entry\RDWT' then
//      begin
//        Remove(subrec);
//        subrec := RecordByFormID(FileByIndex(0), $000138DE, True); // Fallout4.esm LAND Record
//        subrec := ElementByPath(subrec, 'Layers\Alpha Layer');
//        subrec := ElementAssign(subrec_container, elementinteger, subrec, False);
//        SetElementEditValues(subrec_container, 'RDAT\Type', 'Weather');
//        AddMessage(GetElementEditValues(subrec_container, 'RDAT\Type'));
//      end;
//    end;
//      elementpathstring := 'Region Data Entries\Region Data Entry\RDMO';
    if elementpathstring = 'Region Areas\Region Area\RPLD' then
    begin
      if not Assigned(subrec) then subrec := Add(subrec_container, 'RPLD', True);
    end;
    if AnsiPos('Region Areas\Region Area\RPLD\Point #', elementpathstring) <> 0 then
    begin
//      AddMessage(Path(subrec));
//      AddMessage(Path(previousrec));
//      AddMessage(Path(subrec));
      if LastDelimiter('#', elementpathstring) > LastDelimiter('\', elementpathstring) then
      begin
        if (ElementCount(subrec_container) - 1) < StrToInt(Copy(elementpathstring, (LastDelimiter('#', elementpathstring) + 1), MaxInt)) then
          for k := (ElementCount(subrec_container) - 1) to (StrToInt(Copy(elementpathstring, (LastDelimiter('#', elementpathstring) + 1), MaxInt))) do
          begin
            subrec := ElementAssign(subrec_container, MaxInt, Nil, False);
          end;
        if (ElementCount(subrec_container) - 1) > StrToInt(Copy(elementpathstring, (LastDelimiter('#', elementpathstring) + 1), MaxInt)) then
        begin
          Remove(subrec);
          subrec := ElementByIndex(subrec_container, (StrToInt(Copy(elementpathstring, (LastDelimiter('#', elementpathstring) + 1), MaxInt))));
        end;
      end;
    end;

    ////////////////////////////////////////////////////////////////////////////
    ///  Temporary Solution for XATO
    ////////////////////////////////////////////////////////////////////////////
    if elementpathstring = 'ATTX' then
    begin
      if Signature(rec) = 'ACHR' then
      begin
        subrec := LinksTo(ElementByPath(rec, 'NAME'));
        subrec := Add(subrec, 'ATTX', True);
      end;
    end;

    ////////////////////////////////////////////////////////////////////////////
    ///  Check if subrecord is at expected path
    ////////////////////////////////////////////////////////////////////////////
		if Assigned(subrec) then
			if elementpathstring <> formatelementpath(Copy(Path(subrec), 8, MaxInt)) then
			begin
				if formatelementpath(Copy(Path(subrec), 8, MaxInt)) <> 'Record Header\Record Flags\NavMesh Generation' then
				begin 
					AddMessage('subrec ' + elementpathstring + ' got assigned to wrong path ' + formatelementpath(Copy(Path(subrec), 8, MaxInt)));
          Result := ExitSequence(rec, subrec_container, slstring[0], elementpathstring, elementvaluestring, IntToStr(elementinteger), elementisflag);
          Exit;
					//subrec := ElementByPath(subrec_container, Copy(elementpathstring, (LastDelimiter('\', elementpathstring) + 1), MaxInt));
				end;
			end;

//    AddMessage(Path(subrec_container));

    ////////////////////////////////////////////////////////////////////////////
    ///  Check if subrecord exists
    ////////////////////////////////////////////////////////////////////////////
		if not Assigned(subrec) then 
		begin
			//AddMessage(elementpathstring + ' not assigned');
			if Assigned(subrec_container) then
			begin
				if IndexOf(subrec_container, LastElement(subrec_container)) > 0 then
				for k := 0 to IndexOf(subrec_container, LastElement(subrec_container)) do
					if formatelementpath(Copy(Path(ElementByIndex(subrec_container, k)), 8, MaxInt)) = elementpathstring then subrec := ElementByIndex(subrec_container, k);
			end;
			if not Assigned(subrec) then
			begin
        AddMessage('Failed to Assign Record');
        Result := ExitSequence(rec, subrec_container, slstring[0], elementpathstring, elementvaluestring, IntToStr(elementinteger), elementisflag);
        Exit;
				//Halt;
			end;
		end;
		if Path(subrec) <> '' then previousrec := subrec;

    ////////////////////////////////////////////////////////////////////////////
    ///  Check for reference
    ////////////////////////////////////////////////////////////////////////////
		if ((ansipos('[', elementvaluestring) <> 0) AND (ansipos('[', elementvaluestring) = (ansipos(']', elementvaluestring)) - 14)) then
		begin
			if copy(elementvaluestring, (ansipos(']', elementvaluestring) - 8), 2) = originalloadorder then
      begin
        elementvaluestring := fileloadorder + Copy(elementvaluestring, (ansipos(']', elementvaluestring) - 6), 6);
      end
			else if copy(elementvaluestring, (ansipos(']', elementvaluestring) - 8), 2) = 'F4' then // Fallout 4 Reference
      begin
        elementvaluestring := '00' + Copy(elementvaluestring, (ansipos(']', elementvaluestring) - 6), 6);
      end
      else
			begin
				for k := 0 to ((slloadorders.Count) div 3 - 1) do
        begin
          if copy(elementvaluestring, (ansipos(']', elementvaluestring) - 8), 2) = slloadorders[(k * 3)] then
            elementvaluestring := (slloadorders[(k * 3 + 2)] + copy(elementvaluestring, (ansipos(']', elementvaluestring) - 6), 6));
        end;
			end;
      if Length(elementvaluestring) <> 8 then
      begin
        AddMessage('ERROR2: ' + elementvaluestring);
        AddMessage('Original LoadOrder: ' + originalloadorder);
        AddMessage('Missing Master');
        Result := 1;
        Exit;
      end;
      if not Assigned(RecordByFormID(
        FileByLoadOrder(StrToInt('$' + Copy(elementvaluestring, 1, 2))),
        StrToInt('$' + elementvaluestring),
        True))
      then
      begin
			  //AddMessage('Reference');
			  slReferences.Add(elementvaluestring + ';' + IntToStr(GetLoadOrderFormID(rec)) + ';' + IntToStr(GetLoadOrder(GetFile(rec))) + ';' + GetFileName(rec) + ';' + Name(subrec) + ';' + RetrieveIndexPath(PathName(subrec)));
			  Exit;
      end
      else if StrToInt('$' + Copy(elementvaluestring, 1, 2))
        <>
        GetLoadOrder(GetFile(RecordByFormID(
        FileByLoadOrder(StrToInt('$' + Copy(elementvaluestring, 1, 2))),
        StrToInt('$' + elementvaluestring),
        True))) then
        begin
		  	  //AddMessage('Reference');
		  	  slReferences.Add(elementvaluestring + ';' + IntToStr(GetLoadOrderFormID(rec)) + ';' + IntToStr(GetLoadOrder(GetFile(rec))) + ';' + GetFileName(rec) + ';' + Name(subrec) + ';' + RetrieveIndexPath(PathName(subrec)));
		  	  Exit;
        end;
		end;

    ////////////////////////////////////////////////////////////////////////////
    ///  QUST Targets / Aliases
    ////////////////////////////////////////////////////////////////////////////
    if Signature(rec) = 'QUST' then
      if elementpathstring = 'Objectives\Objective\Targets\Target\QSTA\Alias' then
        elementvaluestring := AddAlias(rec, elementvaluestring);

    ////////////////////////////////////////////////////////////////////////////
    ///  Temporary Solution for XTEL references
    ////////////////////////////////////////////////////////////////////////////
    if elementpathstring = 'XTEL\Door' then
    begin
      if not GetIsPersistent(RecordByFormID(GetFile(rec), StrToInt('$' + elementvaluestring) , True)) then
      begin
        if GetFileName(GetFile(RecordByFormID(GetFile(rec), StrToInt('$' + elementvaluestring) , True))) <>
        GetFileName(GetFile(rec)) then
        begin
          AddMessage('XTEL\Door reference not in file');
          Result := 1;
          Exit;
        end;
        SetIsPersistent((RecordByFormID(GetFile(rec), StrToInt('$' + elementvaluestring) , True)), True);
      end;
    end;

    ////////////////////////////////////////////////////////////////////////////
    ///  Temp Solution for persistent records
    ////////////////////////////////////////////////////////////////////////////
    if elementpathstring = 'Record Header\Record Flags' then
    begin
      if GetIsPersistent(rec) then
        elementvaluestring := '00000000001'
    end;

    ////////////////////////////////////////////////////////////////////////////
    ///  Temp Solution for Floats
    ////////////////////////////////////////////////////////////////////////////
    if elementpathstring = 'FNAM\Armor Rating' then
      elementvaluestring := Copy(elementvaluestring, 1, (AnsiPos('.', elementvaluestring) - 1));
    if elementpathstring = 'DAMA\Resistance\Value' then
      elementvaluestring := Copy(elementvaluestring, 1, (AnsiPos('.', elementvaluestring) - 1));

    ////////////////////////////////////////////////////////////////////////////
    ///  Temp Solution for AMMO
    ///  AMMO must be assigned after MISC
    ////////////////////////////////////////////////////////////////////////////
    if elementpathstring = 'NAM1' then
    begin
      if Signature(rec) = 'AMMO' then
      begin
        if ((elementvaluestring <> 'NULL - Null Reference [00000000]') AND (elementvaluestring <> '')) then
          elementvaluestring := GetElementEditValues(

            /// Misc Record
            RecordByFormID
            (
              FileByLoadOrder(StrToInt('$' + Copy(elementvaluestring, 1, 2))),
              StrToInt('$' + elementvaluestring),
              True
            )

            /// Casing Model Path
            ,'Model\MODL')
        else
          elementvaluestring := '';
      end;
    end;

    ////////////////////////////////////////////////////////////////////////////
    ///  Assign Value
    ////////////////////////////////////////////////////////////////////////////
		//if elementvaluestring = 'Portal Box' then elementvaluestring := '1';
		//if elementvaluestring = 'Subject (0)' then elementvaluestring := '0';
		if ((IsEditable(subrec)) 
		AND (elementvaluestring <> '')
		) 
		then
    try
      SetEditValue(subrec, elementvaluestring);
    except
      AddMessage('Failed to set Edit Value');
      Result := ExitSequence(rec, subrec_container, slstring[0], elementpathstring, elementvaluestring, IntToStr(elementinteger), elementisflag);
      Exit;
    end;
	end;
end;

function ConvertSignature(S: String; slrecordconversions: TStringList): String;
var
slrecordconversiondelimited: TStringList;
i: integer;
begin
	Result := '';
	slrecordconversiondelimited := TStringList.Create;
	slrecordconversiondelimited.Delimiter := ';';
	slrecordconversiondelimited.StrictDelimiter := true;
	for i := 1 to (slrecordconversions.Count - 1) do
	begin
		slrecordconversiondelimited.DelimitedText := slrecordconversions[i];
		if S = slrecordconversiondelimited[0] then Result := slrecordconversiondelimited[1];
	end;
	slrecordconversiondelimited.Free;
end;

function OccurrencesOfElement(const S: string; const C: char): integer;
var
  i: Integer;
begin
  result := 0;
  for i := 1 to Length(S) do
    if S[i] = C then
      inc(result);
end;

function ExitFile(): Boolean;
var
slfile: TStringList;
begin
  result := False;
  slfile := TStringList.Create;
  try
    slfile.LoadFromFile(ProgramPath + '\ElementConverions\__EXIT.csv');
  except
    AddMessage('__EXIT.csv could not be loaded');
    Result := True;
    Exit;
  end;
  if slfile[0] = '1' then Result := True;
  slfile.Free;
end;

////////////////////////////////////////////////////////////////////////////////
///  Procedure that Adds References from slReferences
////////////////////////////////////////////////////////////////////////////////

function AddMissingReferences(slReferences: TStringList): TStringList;
var
ToFile, rec: IInterface;
slLookup: TStringList;
i, j: Integer;
begin
  Result := TStringList.Create;
  slLookup := TStringList.Create;
	slLookup.Delimiter := ';';
	slLookup.StrictDelimiter := true;
  for i := 0 to (slReferences.Count - 1) do
  begin
    slLookup.DelimitedText := slReferences[i];
    ToFile := FileByLoadOrder(StrToInt(slLookup[2]));
    if GetFileName(ToFile) <> slLookup[3] then
    begin
      AddMessage('ERROR: File Mismatch');
      Result.Add(slReferences[i]);
      Continue;
      //Exit;
    end;
    rec := RecordByFormID(ToFile, StrToInt(slLookup[1]), True);
    for j := 5 to (slLookup.Count - 1) do
    begin
      rec := ElementByIndex(rec, StrToInt(slLookup[j]));
    end;
    if Name(rec) <> slLookup[4] then
    begin
      AddMessage('ERROR: Name Mismatch ' + Name(rec) + ' AND ' + slLookup[4] + ' IN ' + Name(ContainingMainRecord(rec)));
      Result.Add(slReferences[i]);
      Continue;
      //Exit;
    end;
    if not Assigned(RecordByFormID(ToFile, StrToInt('$' + Copy(slLookup[0], 1, 8)), True)) then
    begin
      AddMessage('ERROR: The Referenced Record Does Not Exist');
      Result.Add(slReferences[i]);
      Continue;
    end;
    try
      SetEditValue(rec, slLookup[0]);
    except
      On E :Exception do
      begin
        AddMessage(E.Message);
        AddMessage('ERROR: Value not set');
        Result.Add(slReferences[i]);
        Continue;
      end;
    end;
  end;
end;

////////////////////////////////////////////////////////////////////////////////
/// Sort FileList
////////////////////////////////////////////////////////////////////////////////

procedure SortFileList();
var
i, j: Integer;
SortOrderList, SortedList: TStringList;
begin
  SortOrderList := TStringList.Create;
  SortedList := TStringList.Create;
  SortOrderList.LoadFromFile(ProgramPath + 'ElementConverions\' + '__RecordOrder.csv');
  for j := 0 to (SortOrderList.Count - 1) do
//  for j := (SortOrderList.Count - 1) downto 0 do
  begin
//    for i := (slfilelist.Count - 1) downto 0 do
//    i := (slfilelist.Count - 1);
//    while(i > -1) do
    for i := 0 to (slfilelist.Count - 1) do
    begin
      if SortOrderList[j] = Copy(slfilelist[i], (LastDelimiter('_', slfilelist[i]) - 4), 4) then
//      if AnsiPos(('SIG_' + SortOrderList[j]), slfilelist[i]) <> 0 then
      begin
//        AddMessage('SIG_' + SortOrderList[j]);
//        AddMessage(slfilelist[i]);

//        slfilelist.Insert(0, slfilelist[i]);
//        slfilelist.Delete(i + 1);
        SortedList.Add(slfilelist[i]);

//        AddMessage(SortOrderList[j]);
//        AddMessage(slfilelist[i]);
//        AddMessage(IntToStr(LastDelimiter(('SIG_' + SortOrderList[j]), slfilelist[i])));
//        AddMessage(slfilelist[0]);
      end;
//      else
//        i := i - 1;
    end;
  end;
//  for i := 0 to (SortedList.Count - 1) do
//  begin
//    AddMessage(SortedList[i]);
//  end;
//  AddMessage(IntToStr(RPos(('SIG_' + 'TES4'), 'FalloutNV.esm_LoadOrder_00_GRUP_WRLD_SIG_PGRE_40.csv')));
  slfilelist.Clear;
  slfilelist.AddStrings(SortedList);
  SortedList.Free;
  SortOrderList.Free;
//    AddMessage('....................');
//  for i := 0 to (slfilelist.Count - 1) do
//  begin
//    AddMessage(slfilelist[i]);
//  end;
end;

////////////////////////////////////////////////////////////////////////////////
/// Clean LVLN
////////////////////////////////////////////////////////////////////////////////
procedure CleanLVLN(const rec: IInterface);
var
rContainer, rLLE: IInterface;
i: Integer;

begin
  rContainer := ElementByPath(rec, 'Leveled List Entries');
  for i := (ElementCount(rContainer) - 1) downto 0 do
  begin
    rLLE := ElementByIndex(rContainer, i);
    if GetElementEditValues(rLLE, 'LVLO\Reference') = 'NULL - Null Reference [00000000]' then
    begin
      if ElementCount(rContainer) = 1 then
        Remove(rContainer)
      else
        Remove(rLLE);
    end;
  end;
end;

////////////////////////////////////////////////////////////////////////////////
/// Clean IPDS
////////////////////////////////////////////////////////////////////////////////
procedure CleanIPDS(const rec: IInterface);
var
rContainer, rPNAM: IInterface;
i: Integer;

begin
  rContainer := ElementByPath(rec, 'Data');
  for i := (ElementCount(rContainer) - 1) downto 0 do
  begin
    rPNAM := ElementByIndex(rContainer, i);
    if GetEditValue(ElementByIndex(rPNAM, 1)) = 'NULL - Null Reference [00000000]' then
    begin
      if ElementCount(rContainer) = 1 then
        Remove(rContainer)
      else
        Remove(rPNAM);
    end;
  end;
end;

////////////////////////////////////////////////////////////////////////////////
/// Clean Conditions
////////////////////////////////////////////////////////////////////////////////
procedure CleanConditionsHelper(const rec: IInterface; const sl: TStringList; const index: Integer);
var
rContainer, r: IInterface;
j, k: Integer;
path, path2: String;
begin
  if index < sl.Count then
    path := sl[index];
  if (index + 1) < sl.Count then
    path2 := sl[(index + 1)];
  rContainer := rec; /// First time rec path should be sl[0] as should index
  if Assigned(rContainer) then
  begin
    if path = 'Conditions' then
    for j := (ElementCount(rContainer) - 1) downto 0 do
    begin
      r := ElementByIndex(rContainer, j);
      r := ElementByPath(r, 'CTDA\Function');
      if Assigned(r) then
      begin
        if GetEditValue(r) = 'GetWantBlocking' then
        begin
          /// Removal code here
          r := ElementByIndex(rContainer, j); /// Condition
          if ElementCount(rContainer) = 1 then
          begin
            if sl.Count = 1 then
              Remove(rContainer) /// If only a conditions record remove it
            else
            begin
              k := (sl.Count - 2); /// Path before conditions
              while (formatelementpath(Name(rContainer)) <> sl[0]) do
              begin
                r           := GetContainer(r);
                rContainer  := GetContainer(rContainer);
                if formatelementpath(Name(rContainer)) = sl[k] then
                begin
                  if ElementCount(rContainer) > 1 then
                  begin
                    Remove(r);
                    Exit;
                  end
                  else if k = 0 then Remove(rContainer);
                  k := k - 1;
                end;
              end;
            end;
          end
          else
            Remove(r); /// Remove Condition
        end;
      end;
    end
    else
    for j := (ElementCount(rContainer) - 1) downto 0 do
    begin
      r := ElementByIndex(rContainer, j);
      r := ElementByPath(r, path2);
      if Assigned(r) then
        if (index + 1) < sl.Count then
          CleanConditionsHelper(r, sl, (index + 1));
    end;
  end;
end;

procedure CleanConditions2(const rec: IInterface);
var
sl: TStringList;
s: String;
begin
  sl := TStringList.Create;
  sl.Delimiter := ';';
  sl.StrictDelimiter := True;
  s := Signature(rec);

  if
  (  (s = 'CPTH')
  OR (s = 'IDLE')
  OR (s = 'PACK')
  OR (s = 'PERK')
  OR (s = 'QUST')
  OR (s = 'RCPE')
  ) then
  begin
    sl.DelimitedText := 'Conditions';
    CleanConditionsHelper(ElementByPath(rec, sl[0]), sl, 0);
  end;

  if
  (
     (s = 'ALCH')
  OR (s = 'SPEL')
  OR (s = 'ENCH')
  OR (s = 'PERK')
  OR (s = 'INGR')
  ) then
  begin
    sl.DelimitedText := 'Effects;Conditions';
    CleanConditionsHelper(ElementByPath(rec, sl[0]), sl, 0);
  end;

  if s = 'QUST' then
  begin
    sl.DelimitedText := 'Stages;Log Entries;Conditions';
    CleanConditionsHelper(ElementByPath(rec, sl[0]), sl, 0);
    sl.DelimitedText := 'Objectives;Targets;Conditions';
    CleanConditionsHelper(ElementByPath(rec, sl[0]), sl, 0);
  end;

  if s = 'MESG' then
  begin
    sl.DelimitedText := 'Menu Buttons;Conditions';
    CleanConditionsHelper(ElementByPath(rec, sl[0]), sl, 0);
  end;

  if s = 'MESG' then
  begin
    sl.DelimitedText := 'Effects;Perk Conditions;Conditions';
    CleanConditionsHelper(ElementByPath(rec, sl[0]), sl, 0);
  end;


end;

////////////////////////////////////////////////////////////////////////////////
///  INITIALIZE
///  WRLD / CELL / REFR
////////////////////////////////////////////////////////////////////////////////

function Initialize: integer;
var
///  s is for temporary strings
///  k is for temporary loops
i, j, k, l, m, LastSingleValueIndex: integer;

elementpathstring,
filename,
fileloadorder,
originalloadorder,
elementvaluestring,
newfilename,
elementinteger,
elementisflag,
recordpath,
_Signature,
_ConversionFile,
elementnewrec,
s: String;

rec, newrec, ToFile, OriginRec1, OriginRec2: IInterface;

slContinueFrom, sl, sl2: TStringList;

display_progress, FirstFileLoop: Boolean;
begin
  AddMessage('Initializing...');
  //////////////////////////////////////////////////////////////////////////////
  ///  Method 2
  //////////////////////////////////////////////////////////////////////////////
  iAliasCounter := 1;
  LastSingleValueIndex := 5;
  slSingleValues := TStringList.Create;
  slNewRec := TStringList.Create;
  slNewRecSig := TStringList.Create;
  slSingleRec := TStringList.Create;
  slOldNewValMatch := TStringList.Create;
  slNewPathorOrder := TStringList.Create;
  slOldVal := TStringList.Create;
  slNewVal := TStringList.Create;
  slOldIndex := TStringList.Create;
  slNewIndex := TStringList.Create;
  slReplaceAnyVal := TStringList.Create;
  slReplaceAnyIndex := TStringList.Create;
  slIsFlag := TStringList.Create;
  sl := TStringList.Create;
  sl2 := TStringList.Create;
  slPathsLookup := TStringList.Create;
  slEntryLength := TStringList.Create;
  slTemporaryDelimited := TStringList.Create;

  //////////////////////////////////////////////////////////////////////////////
  ///  Create Lists
  //////////////////////////////////////////////////////////////////////////////
	NPCList := 		TStringList.Create;
	slstring := 	TStringList.Create;
	slloadorders := TStringList.Create;
	slReferences := TStringList.Create;
	slfailed := TStringList.Create;
	slfilelist := TStringList.Create;
	slfilelist.LoadFromFile(ProgramPath + 'data\' + '_filelist.csv');
  SortFileList;
	slrecordconversions := TStringList.Create;
	slrecordconversions.LoadFromFile(ProgramPath + 'ElementConverions\' + '__RecordConversions.csv');
  slContinueFrom := TStringList.Create;
  slContinueFrom.Delimiter := ';';
	slContinueFrom.StrictDelimiter := true;
  slFileExtensions := TStringList.Create;
  slFileExtensions.LoadFromFile(ProgramPath + 'ElementConverions\' + '__FileExtensions.csv');
  slShortLookup := TStringList.Create;
  slShortLookupPos := TStringList.Create;

  sl_Paths := TStringList.Create;
  sl_Values := TStringList.Create;
  sl_Integer := TStringList.Create;
  sl_Flag := TStringList.Create;
  sl_NewRec := TStringList.Create;

  //////////////////////////////////////////////////////////////////////////////
  ///  Debug Options
  //////////////////////////////////////////////////////////////////////////////
  if FileExists(ProgramPath + 'data\__ContinueFrom.csv') then
  begin
    slContinueFrom.LoadFromFile(ProgramPath + 'data\__ContinueFrom.csv');
    if slContinueFrom.Count > 0 then
    begin
      slContinueFrom.DelimitedText := slContinueFrom[0];
    end;
  end;
  debugmode := True;
  display_progress := True;
  FirstFileLoop := True;
  ExitAfterFail := True;
  SaveOnExit := True;
  OverwriteRecs := True;

  if debugmode then
  begin
    if slContinueFrom.Count > 0 then
    begin
      for k := 0 to (slfilelist.Count - 1) do
      begin
        if slContinueFrom[0] = slfilelist[k] then
        begin
          for l := 0 to (k - 1) do
            slfilelist.Delete(0);
          Break;
        end;
      end;
    end;
  end;

  if SaveOnExit then
  begin
    if FileExists(ProgramPath + 'data\' + '__FailedList.csv') then
      slfailed.LoadFromFile(ProgramPath + 'data\' + '__FailedList.csv');
    if FileExists(ProgramPath + 'data\' + '__ReferenceList.csv') then
      slReferences.LoadFromFile(ProgramPath + 'data\' + '__ReferenceList.csv');
    if FileExists(ProgramPath + 'data\' + '__Loadorders.csv') then
      slloadorders.LoadFromFile(ProgramPath + 'data\' + '__Loadorders.csv');
  end;

	//CreatePathLookupList();

  //////////////////////////////////////////////////////////////////////////////
  ///  Start Import
  //////////////////////////////////////////////////////////////////////////////
  AddMessage('Creating Records...');
  if slContinueFrom.Count <> 0 then
  begin
    AddMessage('Skipped Because slContinuefrom count is not 0');
  end
  else
  for l := 0 to (slfilelist.Count - 1) do
	begin
    ////////////////////////////////////////////////////////////////////////////
    ///  Initialize
    ////////////////////////////////////////////////////////////////////////////
		filename := slfilelist[l];
		NPCList.LoadFromFile(ProgramPath + 'data\' + filename);
    if debugmode AND FirstFileLoop then
    begin
      if slContinueFrom.Count > 0 then
      begin
        NPCList.LoadFromFile(ProgramPath + 'data\' + slContinueFrom[0]);
        for k := 0 to (StrToInt(slContinueFrom[1]) - 1) do
          NPCList.Delete(0);
        if slContinueFrom.Count = 4 then
        begin
          if Assigned(RecordByFormID(FileByLoadOrder(StrToInt(slContinueFrom[3])), StrToInt(slContinueFrom[2]), True)) then
          begin
//            Remove(RecordByFormID(FileByLoadOrder(StrToInt(slContinueFrom[3])), StrToInt(slContinueFrom[2]), True));
            SetToDefault(RecordByFormID(FileByLoadOrder(StrToInt(slContinueFrom[3])), StrToInt(slContinueFrom[2]), True));
          end;
        end;
        FirstFileLoop := False;
      end;
    end;

		originalloadorder := copy(filename, (ansipos('LoadOrder_', filename) + 10), 2);
		newfilename := copy(filename, 1, (ansipos('_LoadOrder', filename) - 1));

    ////////////////////////////////////////////////////////////////////////////
    ///  Create File
    ////////////////////////////////////////////////////////////////////////////
		for k := 0 to (FileCount - 1) do
		if GetFileName(FileByIndex(k)) = newfilename then
		begin
			ToFile := FileByIndex(k);
		end;
		if not Assigned(ToFile) then ToFile := AddNewFileName(newfilename);
		AddMasterIfMissing(ToFile, 'Fallout4.esm');
		if (ansipos('.esm', newfilename) <> 0) then SetIsESM(ToFile, True);

    ////////////////////////////////////////////////////////////////////////////
    ///  Create slstring List
    ////////////////////////////////////////////////////////////////////////////
		slstring.Delimiter := ';';
		slstring.StrictDelimiter := true;

    //////////////////////////////////////////////////////////////////////////
    ///  Create Element Conversion List and Set _Signature
    //////////////////////////////////////////////////////////////////////////
    _Signature := Copy(filename, (LastDelimiter('_', filename) - 4), 4);
    _Signature := ConvertSignature(_Signature, slrecordconversions);
    if _Signature = '' then
    begin
      Continue;
    end;

    ////////////////////////////////////////////////////////////////////////////
    ///  Debug Options
    ////////////////////////////////////////////////////////////////////////////
    if not debugmode then
    begin
      if NPCList.Count > 49 then m := 50
      else
        m := NPCList.Count - 1;
    end
    else m := (NPCList.Count - 1);

    ////////////////////////////////////////////////////////////////////////////
    ///  NPCList MAIN Loop START
    ////////////////////////////////////////////////////////////////////////////
		if NPCList.Count > 0 then for i := 0 to m do
		begin
      //////////////////////////////////////////////////////////////////////////
      ///  Create Record
      //////////////////////////////////////////////////////////////////////////
			slstring.DelimitedText := Copy(NPCList[i], 6, MaxInt);
      fileloadorder := IntToHex(GetLoadOrder(ToFile), 2);
      recordpath := slstring[2];
      if ansipos('GRUP Top ', recordpath) <> 0 then
        recordpath := copy(recordpath, (ansipos('GRUP Top "', recordpath) + 10), MaxInt)
      else recordpath := '';
      if recordpath <> '' then
      begin
        rec := Add(ToFile, _Signature, True); // Top GRUP
        rec := Add(rec, _Signature, True);
        if not Assigned(rec) then // If part of subgrup
        begin
          if ansipos('[CELL:', recordpath) <> 0 then
            recordpath := copy(recordpath, (ansipos('[CELL:', recordpath) + 6), 8)
          else if ansipos('[WRLD:', recordpath) <> 0 then
            recordpath := copy(recordpath, (ansipos('[WRLD:', recordpath) + 6), 8)
          else if ansipos('[DIAL:', recordpath) <> 0 then
            recordpath := copy(recordpath, (ansipos('[DIAL:', recordpath) + 6), 8)
          else if ansipos('[QUST:', recordpath) <> 0 then
            recordpath := copy(recordpath, (ansipos('[QUST:', recordpath) + 6), 8)
          else
          begin
            AddMessage('ERROR: Could not find match');
            Result := 1;
            Exit;
          end;
			    if copy(recordpath, 1, 2) = originalloadorder then
          begin
            rec := RecordByFormID(ToFile, StrToInt('$' + fileloadorder + copy(recordpath, 3, 6)), True);
            if Assigned(rec) then
            begin
              if GetFile(rec) <> ToFile then
              begin
                AddMessage('ERROR: rec in wrong file');
                Result := 1;
                Exit;
              end;
            end;
          end
          else
		    	begin
		    		for k := 0 to ((slloadorders.Count) div 3 - 1) do
		    		if fileloadorder = slloadorders[(k * 3)] then
            begin
              if Assigned(rec) then
              begin
                rec := RecordByFormID(ToFile, StrToInt('$' + slloadorders[(k * 3 + 2)] + copy(recordpath, 3, 6)), True);
                if GetFile(rec) <> ToFile then
                begin
                  AddMessage('ERROR: rec in wrong file Using FOR LOOP');
                  Result := 1;
                  Exit;
                end;
              end;
            end;
		    	end;
          rec := Add(rec, _Signature, True);
        end;
      end
      else rec := Add(ToFile, _Signature, True);
      if not Assigned(rec) then
      begin
        if _Signature = 'TES4' then
        begin
          AddMessage('YES');
          rec := RecordByIndex(ToFile, 0);
//          Result := 0;
          Continue;
        end;
        if not Assigned(rec) then
        begin
          AddMessage('ERROR: Record Not Assigned');
          AddMessage(_Signature);
          AddMessage(recordpath);
          AddMessage(filename);
          Result := 1;
          Exit;
        end;
      end;
      if slstring[3] = 'CELL \ Worldspace' then // Heuristic
      begin
        Remove(rec);
        if Copy(slstring[4], (LastDelimiter(']', slstring[4]) - 8), 2) = originalloadorder then
          rec := RecordByFormID(ToFile, StrToInt('$' + fileloadorder + Copy(slstring[4], (LastDelimiter(']', slstring[4]) - 6), 6)), True)
        else
	   		begin
	   			for k := 0 to ((slloadorders.Count) div 3 - 1) do
          begin
            if Copy(slstring[4], (LastDelimiter(']', slstring[4]) - 8), 2) = slloadorders[(k * 3)] then
              elementvaluestring := slloadorders[(k * 3 + 2)] + Copy(slstring[4], (LastDelimiter(']', slstring[4]) - 6), 6);
          end;
	   		end;
        if Signature(rec) <> 'WRLD' then
        begin
          AddMessage('Mismatch in For WRLD');
          Result := 1;
          Exit;
        end;
        rec := Add(rec, 'CELL', True);
      end;

      //////////////////////////////////////////////////////////////////////////
      ///  Temporary solution for Effect Shaders
      //////////////////////////////////////////////////////////////////////////
      if Signature(rec) = 'EFSH' then
      begin
        Remove(rec);
        rec := RecordByFormID(FileByIndex(0), $00036902, True); // Fallout4.esm EFSH Record
        rec := wbCopyElementToFile(rec, ToFile, False, True);
      end;

      //////////////////////////////////////////////////////////////////////////
      ///  Set FormID
      //////////////////////////////////////////////////////////////////////////
			if (slloadorders.Count = 0) then
			begin
				slloadorders.Add(originalloadorder);
				slloadorders.Add(newfilename);
				slloadorders.Add(fileloadorder);
			end;
			if (slloadorders[((slloadorders.Count) - 3)] <> originalloadorder) then
			begin
				slloadorders.Add(originalloadorder);
				slloadorders.Add(newfilename);
				slloadorders.Add(fileloadorder);
			end;
			if copy((IntToHex(StrToInt(slstring[0]), 8)), 1, 2) = originalloadorder then
      try
        SetLoadOrderFormID(rec, StrToInt('$' + fileloadorder + copy((IntToHex(StrToInt(slstring[0]), 8)), 3, 6)))
      except
        On E :Exception do
        begin
          AddMessage(E.Message);
          Remove(rec);
          Result := 1;
          Exit;
        end;
      end
			else
			begin
				for k := 0 to ((slloadorders.Count) div 3 - 1) do
				if fileloadorder = slloadorders[(k * 3)] then
        try
          SetLoadOrderFormID(rec, StrToInt('$' + slloadorders[(k * 3 + 2)] + copy((IntToHex(StrToInt(slstring[0]), 8)), 3, 6)));
        except
          On E :Exception do
          begin
            AddMessage(E.Message);
            Remove(rec);
            Result := 1;
            Exit;
          end;
        end;
			end;
      if ExitFile then
      begin
        AddMessage('Exiting because __EXIT.csv is true');
        Result := 1;
        Exit;
      end;
    end;
    AddMessage('Processed ' + IntToStr(l) + ' Lists...');
  end;

  //////////////////////////////////////////////////////////////////////////////
  ///  Setup next Loop
  //////////////////////////////////////////////////////////////////////////////
  FirstFileLoop := True;
  slstring.Delimiter := ';';
  slstring.StrictDelimiter := True;

  AddMessage('Assigning Values...');
  for l := 0 to (slfilelist.Count - 1) do
	begin
    ////////////////////////////////////////////////////////////////////////////
    ///  Initialize
    ////////////////////////////////////////////////////////////////////////////
		filename := slfilelist[l];
		NPCList.LoadFromFile(ProgramPath + 'data\' + filename);
//    if debugmode AND FirstFileLoop then
//    begin
//      if slContinueFrom.Count > 0 then
//      begin
//        NPCList.LoadFromFile(ProgramPath + 'data\' + slContinueFrom[0]);
//        for k := 0 to (StrToInt(slContinueFrom[1]) - 1) do
//          NPCList.Delete(0);
//        FirstFileLoop := False;
//      end;
//    end;
    if debugmode AND FirstFileLoop then
    begin
      if slContinueFrom.Count > 0 then
      begin
        NPCList.LoadFromFile(ProgramPath + 'data\' + slContinueFrom[0]);
        for k := 0 to (StrToInt(slContinueFrom[1]) - 1) do
          NPCList.Delete(0);
        if slContinueFrom.Count = 4 then
        begin
          if Assigned(RecordByFormID(FileByLoadOrder(StrToInt(slContinueFrom[3])), StrToInt(slContinueFrom[2]), True)) then
          begin
//            Remove(RecordByFormID(FileByLoadOrder(StrToInt(slContinueFrom[3])), StrToInt(slContinueFrom[2]), True));
            SetToDefault(RecordByFormID(FileByLoadOrder(StrToInt(slContinueFrom[3])), StrToInt(slContinueFrom[2]), True));
          end;
        end;
        FirstFileLoop := False;
      end;
    end;

		originalloadorder := copy(filename, (ansipos('LoadOrder_', filename) + 10), 2);
		newfilename := copy(filename, 1, (ansipos('_LoadOrder', filename) - 1));

    ////////////////////////////////////////////////////////////////////////////
    ///  Get File
    ////////////////////////////////////////////////////////////////////////////
		for k := 0 to (FileCount - 1) do
	  	if GetFileName(FileByIndex(k)) = newfilename then
	  	begin
	  		ToFile := FileByIndex(k);
	  	end;
    if not Assigned(ToFile) then
	  	for k := 0 to (FileCount - 1) do
	    	if Copy(GetFileName(FileByIndex(k)), 1, (Length(GetFileName(FileByIndex(k))) - 3)) = Copy(newfilename, 1, (Length(newfilename) - 3)) then
	    	begin
	    		ToFile := FileByIndex(k);
	    	end;

    if not Assigned(ToFile) then
    begin
      Result := 1;
      AddMessage('File ' + newfilename + ' Not Found');
      Exit;
    end;

    //////////////////////////////////////////////////////////////////////////
    ///  Create Element Conversion List and Set _Signature
    //////////////////////////////////////////////////////////////////////////
    _Signature := Copy(filename, (LastDelimiter('_', filename) - 4), 4);
    _Signature := ConvertSignature(_Signature, slrecordconversions);
    if _Signature = '' then
    begin
      Continue;
    end;
    if _Signature <> _ConversionFile then
    begin
      _ConversionFile := _Signature;
      slPathsLookup.Clear;
      slEntryLength.Clear;
      slShortLookup.Clear;
      slShortLookupPos.Clear;

      slSingleValues.Clear;
      slNewRec.Clear;
      slNewRecSig.Clear;
      slSingleRec.Clear;
      slOldNewValMatch.Clear;
      slNewPathorOrder.Clear;
      slOldVal.Clear;
      slNewVal.Clear;
      slOldIndex.Clear;
      slNewIndex.Clear;
      slReplaceAnyVal.Clear;
      slReplaceAnyIndex.Clear;
      slIsFlag.Clear;
      sl.Clear;
      sl2.Clear;
      slSingleValues.Add('slSingleValues');
      slNewRec.Add('slNewRec');
      slNewRecSig.Add('slNewRecSig');
      slSingleRec.Add('slSingleRec');
      slOldNewValMatch.Add('slOldNewValMatch');
      slNewPathorOrder.Add('slNewPathorOrder');
      slOldVal.Add('slOldVal');
      slNewVal.Add('slNewVal');
      slOldIndex.Add('slOldIndex');
      slNewIndex.Add('slNewIndex');
      slReplaceAnyVal.Add('slReplaceAnyVal');
      slReplaceAnyIndex.Add('slReplaceAnyIndex');
      slIsFlag.Add('slIsFlag');
      sl.LoadFromFile(ProgramPath + 'ElementConverions\Proto\' + '__ElementConversions.csv');
      sl2.LoadFromFile(ProgramPath + 'ElementConverions\Proto\' + _Signature + '.csv');
      if sl2.Count > 3 then /// Skip Notes, Column identifiers and column notes
      begin
        sl2.Delete(0);
        sl2.Delete(0);
        sl2.Delete(0);
        sl.AddStrings(sl2);
      end;
      slTemporaryDelimited.Clear;
      slTemporaryDelimited.Delimiter := ';';
      slTemporaryDelimited.StrictDelimiter := True;
      slTemporaryDelimited.DelimitedText := sl[1];  /// Column Identifiers
      for i := 1 to (slTemporaryDelimited.Count - 1) do /// Skip Notes
      begin
        if slTemporaryDelimited[i] = slNewRec[0] then
        	slNewRec.Add(IntToStr(i));
        if slTemporaryDelimited[i] = slNewRecSig[0] then
        	slNewRecSig.Add(IntToStr(i));
        if slTemporaryDelimited[i] = slSingleRec[0] then
        	slSingleRec.Add(IntToStr(i));
        if slTemporaryDelimited[i] = slOldNewValMatch[0] then
        	slOldNewValMatch.Add(IntToStr(i));
        if slTemporaryDelimited[i] = slNewPathorOrder[0] then
        	slNewPathorOrder.Add(IntToStr(i));
        if slTemporaryDelimited[i] = slNewVal[0] then
        	slNewVal.Add(IntToStr(i));
        if slTemporaryDelimited[i] = slOldVal[0] then
        	slOldVal.Add(IntToStr(i));
        if slTemporaryDelimited[i] = slOldIndex[0] then
        	slOldIndex.Add(IntToStr(i));
        if slTemporaryDelimited[i] = slNewIndex[0] then
        	slNewIndex.Add(IntToStr(i));
        if slTemporaryDelimited[i] = slReplaceAnyVal[0] then
        	slReplaceAnyVal.Add(IntToStr(i));
        if slTemporaryDelimited[i] = slReplaceAnyIndex[0] then
        	slReplaceAnyIndex.Add(IntToStr(i));
        if slTemporaryDelimited[i] = slIsFlag[0] then
        	slIsFlag.Add(IntToStr(i));

      end;
      for i := 3 to (sl.Count - 1) do /// Skip Notes, Column identifiers and column notes
      begin
        slTemporaryDelimited.DelimitedText := sl[i];
        if slTemporaryDelimited[1] <> '' then
        begin
          slPathsLookup.Add(slTemporaryDelimited[1]);
          slEntryLength.Add(IntToStr(i - 1));
          for j := 2 to LastSingleValueIndex do
          begin
            slSingleValues.Add(slTemporaryDelimited[j]);
          end;
          s := slPathsLookup[(slPathsLookup.Count - 1)];
          if AnsiPos('\', s) <> 0 then
            s := Copy(s, 1, (AnsiPos('\', s) - 1));
          for j := 0 to slShortLookup.Count do
          begin
            if j = slShortLookup.Count then
            begin
              slShortLookup.Add(s);
              slShortLookupPos.Add(IntToStr(slPathsLookup.Count - 1));
            end
            else
            if s = slShortLookup[j] then
              Break;
          end;
        end;
        slNewRec.Add(slTemporaryDelimited[StrToInt(slNewRec[1])]);
        slNewRecSig.Add(slTemporaryDelimited[StrToInt(slNewRecSig[1])]);
        slSingleRec.Add(slTemporaryDelimited[StrToInt(slSingleRec[1])]);
        slOldNewValMatch.Add(slTemporaryDelimited[StrToInt(slOldNewValMatch[1])]);
        slNewPathorOrder.Add(slTemporaryDelimited[StrToInt(slNewPathorOrder[1])]);
        slOldVal.Add(slTemporaryDelimited[StrToInt(slOldVal[1])]);
        slNewVal.Add(slTemporaryDelimited[StrToInt(slNewVal[1])]);
        slOldIndex.Add(slTemporaryDelimited[StrToInt(slOldIndex[1])]);
        slNewIndex.Add(slTemporaryDelimited[StrToInt(slNewIndex[1])]);
        slReplaceAnyVal.Add(slTemporaryDelimited[StrToInt(slReplaceAnyVal[1])]);
        slReplaceAnyIndex.Add(slTemporaryDelimited[StrToInt(slReplaceAnyVal[1])]);
        slIsFlag.Add(slTemporaryDelimited[StrToInt(slIsFlag[1])]);
      end;
    end;

    ////////////////////////////////////////////////////////////////////////////
    ///  Debug Options
    ////////////////////////////////////////////////////////////////////////////
    if not debugmode then
    begin
      if NPCList.Count > 49 then m := 50
      else
        m := NPCList.Count - 1;
    end
    else m := (NPCList.Count - 1);

    fileloadorder := IntToHex(GetLoadOrder(ToFile), 2);

    ////////////////////////////////////////////////////////////////////////////
    ///  NPCList MAIN Loop START
    ////////////////////////////////////////////////////////////////////////////
		if NPCList.Count > 0 then for i := 0 to m do
		begin

      //////////////////////////////////////////////////////////////////////////
      ///  Create slstring and Data that doesnt require conversion
      //////////////////////////////////////////////////////////////////////////
			slstring.DelimitedText := Copy(NPCList[i], 6, MaxInt);
      sl_Paths.Clear;
      sl_Values.Clear;
      sl_Integer.Clear;
      sl_Flag.Clear;
      sl_NewRec.Clear;

      //////////////////////////////////////////////////////////////////////////
      ///  Convert Element Data For Fallout 4
      //////////////////////////////////////////////////////////////////////////
			j := 1;
			while j < (((slstring.Count - 3 {skip loadorderformid and refcount and fullpath}) div 3) + 1) do
			begin
      	elementpathstring := copy(slstring[(j * 3)], 8, MaxInt);
      	elementvaluestring := slstring[(j * 3 + 1)];
      	elementinteger := slstring[(j * 3 + 2)];
      	elementpathstring := formatelementpath(elementpathstring);
      	elementvaluestring := stringreplace(elementvaluestring, '\r\n', #13#10, [rfReplaceAll]);
      	elementvaluestring := stringreplace(elementvaluestring, '\comment\', ';', [rfReplaceAll]);
      	elementvaluestring := stringreplace(elementvaluestring, '|CITATION|', '"', [rfReplaceAll]);

        ////////////////////////////////////////////////////////////////////////
        ///  Numbered Array
        ////////////////////////////////////////////////////////////////////////
        if AnsiPos('#', elementpathstring) <> 0 then
        begin
          if ((OccurrencesOfChar(elementpathstring, '#') = 1)
          AND (AnsiPos('Parameter #', elementpathstring) = 0)
          AND (AnsiPos('Attribute #', elementpathstring) = 0)
          AND (AnsiPos('Skill #', elementpathstring) = 0)
          AND (AnsiPos('Voice #', elementpathstring) = 0)
          AND (AnsiPos('Default Hair Style #', elementpathstring) = 0)
          AND (AnsiPos('Default Hair Color #', elementpathstring) = 0)
          AND (AnsiPos('ANAM\Related Camera Path #', elementpathstring) = 0)
          AND (AnsiPos('DATA\Particle Shader - Initial Velocity #', elementpathstring) = 0)
          AND (AnsiPos('DATA\Particle Shader - Acceleration #', elementpathstring) = 0)
          AND (AnsiPos('ANAM\Related Idle Animation #', elementpathstring) = 0)
          AND (AnsiPos('XORD\Plane #', elementpathstring) = 0)
          AND (AnsiPos('XPOD\Room #', elementpathstring) = 0)
          AND (AnsiPos('NAM0\Type #', elementpathstring) = 0)
          ) then
          begin
            elementinteger := Copy(elementpathstring, (LastDelimiter('#', elementpathstring) + 1), MaxInt);
            if AnsiPos('\', elementinteger) <> 0 then
              elementinteger := Copy(elementinteger, 1, (AnsiPos('\', elementinteger) - 1));
            elementpathstring := StringReplace(elementpathstring, ('#' + elementinteger), '#0', [rfIgnoreCase]);
          end;
        end;

        ////////////////////////////////////////////////////////////////////////
        ///  Convert
        ////////////////////////////////////////////////////////////////////////
        Build_slstring(elementpathstring, elementvaluestring, elementinteger);
				Inc(j);
			end;

      //////////////////////////////////////////////////////////////////////////
      ///  Get Record
      //////////////////////////////////////////////////////////////////////////
//      AddMessage(slstring[0]);
//      AddMessage(fileloadorder);
//      AddMessage(GetFileName(ToFile));
//      AddMessage(IntToHex(StrToInt(slstring[0]), 8));
      if StrToInt('$' + Copy(IntToHex(StrToInt(slstring[0]), 8), 3, 6)) < 2048 then // Editor Reference
        Continue;
			if copy((IntToHex(StrToInt(slstring[0]), 8)), 1, 2) = originalloadorder then
      begin
//        AddMessage('$' + fileloadorder + copy((IntToHex(StrToInt(slstring[0]), 8)), 3, 6));
        rec := RecordByFormID(ToFile, StrToInt('$' + fileloadorder + copy((IntToHex(StrToInt(slstring[0]), 8)), 3, 6)), True); // Fallout4.esm LAND Record
      end
			else
			begin
				for k := 0 to ((slloadorders.Count) div 3 - 1) do
				if fileloadorder = slloadorders[(k * 3)] then
          rec := RecordByFormID(ToFile, StrToInt('$' + slloadorders[(k * 3 + 2)] + copy((IntToHex(StrToInt(slstring[0]), 8)), 3, 6)), True); // Fallout4.esm LAND Record
			end;
      if GetFileName(GetFile(rec)) <> GetFileName(ToFile) then
      begin
        AddMessage(fileloadorder);
        AddMessage(originalloadorder);
        AddMessage(GetFileName(GetFile(rec)));
        AddMessage(GetFileName(ToFile));
        AddMessage(copy((IntToHex(StrToInt(slstring[0]), 8)), 3, 6));
        AddMessage(Name(rec));
        AddMessage('FATAL ERROR: Rec selected in wrong file');
        Result := 1;
        Exit;
      end;

      if OverwriteRecs then
      begin
        k := FormID(rec);
        newrec := GetContainer(rec);
        Remove(rec);
        rec := Add(newrec, _Signature, True);
        newrec := Nil;
        SetLoadOrderFormID(rec, k);
        if not Assigned(rec) then
        begin
          AddMessage('ERROR: Overwrite Failed');
          Result := 1;
          Exit;
        end;
      end;

      //////////////////////////////////////////////////////////////////////////
      ///  slstring SUBLOOP START
      ///  Process slstring List
      //////////////////////////////////////////////////////////////////////////
      if display_progress then
      begin
        if slContinueFrom.Count <> 0 then
        begin
          if filename = slContinueFrom[0] then
          begin
            AddMessage(filename + ';' + IntToStr(i + StrToInt(slContinueFrom[1])) + ';' + IntToStr(FormID(rec)) + ';' + IntToStr(GetLoadOrder(GetFile(rec))))
          end
          else
            AddMessage(filename + ';' + IntToStr(i) + ';' + IntToStr(FormID(rec)) + ';' + IntToStr(GetLoadOrder(GetFile(rec))));
        end
        else
          AddMessage(filename + ';' + IntToStr(i) + ';' + IntToStr(FormID(rec)) + ';' + IntToStr(GetLoadOrder(GetFile(rec))));
//        AddMessage(IntToStr(NPCList.Count - i - 1) + ' to go');
      end;

//      for j := 0 to (slShortLookup.Count - 1) do
//        AddMessage(slShortLookup[j]);
      if _Signature = 'REFR' then
      begin
        for j := 0 to (sl_Paths.Count - 1) do
		  	begin
		  		elementpathstring := sl_Paths[j];
		  		elementvaluestring := sl_Values[j];
		  		elementinteger := sl_Integer[j];
          elementisflag := sl_Flag[j];
          elementnewrec := sl_NewRec[j];
          k := AnsiPos('[', elementvaluestring);
          if k <> 0 then
          begin
            if AnsiPos(']', elementvaluestring) = (k + 14) then
            begin
              elementvaluestring := Copy(elementvaluestring, (k + 6), 8);
		        	if copy(elementvaluestring, 1, 2) = originalloadorder then
              begin
                elementvaluestring := fileloadorder + Copy(elementvaluestring, 3, 6);
              end
		        	else if copy(elementvaluestring, 1, 2) = 'F4' then // Fallout 4 Reference
              begin
                elementvaluestring := '00' + Copy(elementvaluestring, 3, 6);
              end
              else
		        	begin
		        		for k := 0 to ((slloadorders.Count) div 3 - 1) do
                begin
                  if copy(elementvaluestring, 1, 2) = slloadorders[(k * 3)] then
                    elementvaluestring := (slloadorders[(k * 3 + 2)] + Copy(elementvaluestring, 3, 6));
                end;
		        	end;
            end;
          end;
          if Length(elementpathstring) = 4 then
          begin
            CreateElementQuick1(rec, elementpathstring, elementvaluestring);
          end
          else
          begin
            Result := CreateElement(rec, originalloadorder, fileloadorder, elementpathstring, elementvaluestring, StrToInt(elementinteger), elementisflag);
            if Result = 1 then Exit;
          end;
        end;
      end
      else
      begin
        for j := 0 to (sl_Paths.Count - 1) do
		  	begin
		  		elementpathstring := sl_Paths[j];
		  		elementvaluestring := sl_Values[j];
		  		elementinteger := sl_Integer[j];
          elementisflag := sl_Flag[j];
          elementnewrec := sl_NewRec[j];
//        	elementvaluestring := stringreplace(elementvaluestring, '\r\n', #13#10, [rfReplaceAll]);
//        	elementvaluestring := stringreplace(elementvaluestring, '\comment\', ';', [rfReplaceAll]);
//        	elementvaluestring := stringreplace(elementvaluestring, '|CITATION|', '"', [rfReplaceAll]);


          ////////////////////////////////////////////////////////////////////////
          ///  Caravan card list
          ////////////////////////////////////////////////////////////////////////
          if AnsiPos('[CCRD:', elementvaluestring) <> 0 then
          begin
            if elementpathstring = 'Leveled List Entries\Leveled List Entry\LVLO\Reference' then
              Break;
          end;
//	  			AddMessage('######################');
//	  			AddMessage(elementpathstring);
//    			AddMessage(elementvaluestring);
//          AddMessage(elementinteger);
//          AddMessage(elementisflag);
//          AddMessage(elementnewrec);
//          2147483647

          try
            StrToInt(elementinteger);
          except
            AddMessage('elementinteger is not a number');
            AddMessage('PATH    : ' + elementpathstring);
            AddMessage('VALUE   : ' + elementvaluestring);
            AddMessage('INTEGER : ' + elementinteger);
            AddMessage('ISFLAG  : ' + elementisflag);
            Result := 1;
            Exit;
          end;

          if elementnewrec <> '' then
          begin
            slTemporaryDelimited.Clear;
            slTemporaryDelimited.Delimiter := '\';
            slTemporaryDelimited.StrictDelimiter := True;
            slTemporaryDelimited.DelimitedText := elementnewrec;  /// Column Identifiers
            if slTemporaryDelimited.Count > 1 then
            begin
              OriginRec1 := rec;
              if Assigned(newrec) then OriginRec2 := previousrec2
              else
              OriginRec2 := previousrec;
              for k := 0 to slTemporaryDelimited.Count - 2 do
              begin
                elementnewrec := slTemporaryDelimited[k];
                s := GetNewRecEDID(rec, elementnewrec);
                rec := MainRecordByEditorID(Add(ToFile, Copy(elementnewrec, 1, 4), True), s);
              end;
              elementnewrec := slTemporaryDelimited[(slTemporaryDelimited.Count - 1)];
              if elementnewrec <> 'Return' then
              begin
                AddMessage(Signature(newrec));
                s := GetNewRecEDID(rec, elementnewrec);
                newrec := MainRecordByEditorID(Add(ToFile, Copy(elementnewrec, 1, 4), True), s);
              end;
            end;
          end;

//          AddMessage('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
//          AddMessage(Signature(rec));
//          AddMessage(Signature(newrec));
//          AddMessage(elementnewrec);
//          AddMessage('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');


          ////////////////////////////////////////////////////////////////////////
          ///  Assign elements
          ////////////////////////////////////////////////////////////////////////
          Result := 0;
          if elementpathstring <> '' then
          begin
            if Assigned(newrec) then
            begin
              if ((Copy(elementnewrec, 1, 4) <> Signature(newrec))
              AND (elementnewrec <> 'Return')) then
              begin
                newrec := Nil;
                previousrec := previousrec2;
              end;
            end;
          end;

          if elementnewrec <> '' then
          begin
            if elementnewrec <> 'Return' then
            begin
              if not Assigned(newrec) then previousrec2 := previousrec;
//              if AnsiPos('Female world model', elementpathstring) = 1 then s := s + '_4';
//              AddMessage('Name of prev rec is ' + Path(previousrec));
              s := GetNewRecEDID(rec, elementnewrec);
              newrec := MainRecordByEditorID(Add(ToFile, Copy(elementnewrec, 1, 4), True), s);
              if not Assigned(newrec) then
              begin
                newrec := MasterOrSelf(rec);
//                if GetFileName(GetFile(newrec)) <> GetFileName(GetFile(rec))
                newrec := Add(ToFile, Copy(elementnewrec, 1, 4), True); // Top GRUP
                newrec := Add(newrec, Copy(elementnewrec, 1, 4), True);
                Add(newrec, 'EDID', True);
                SetElementEditValues(newrec, 'EDID', s);
              end;
//              AddMessage(s);
              if AnsiPos('MSWP', elementnewrec) = 1 then
              begin
                if elementpathstring = 'Material Substitutions\Substitution\BNAM' then
                begin
                  s := GetEditValue(ElementByIndex(GetContainer(previousrec2), 0));
                  s := Copy(s, 1, Length(s) - 4) + '\'; // new_vegas\ should already have been added in MODL
//                  if AnsiPos('new_vegas\', s) <> 1 then // new_vegas\ should already have been added in MODL
//                    s := 'new_vegas\' + Copy(s, 1, Length(s) - 4) + '\';
                  s := StringReplace(s, '\\', '\', [rfReplaceAll]);
                  elementvaluestring := s + stringreplace(elementvaluestring, ':', '#', [rfReplaceAll]) + '.BGSM';
                end;
                if elementpathstring = 'Material Substitutions\Substitution\SNAM' then
                begin
                  elementvaluestring := 'new_vegas\MSWP\' + Copy(elementvaluestring, 1, (LastDelimiter('[', elementvaluestring) - 2)) + '.BGSM';
                end;
              end;
              if elementpathstring <> 'Return' then
		  			    Result := CreateElement(newrec, originalloadorder, fileloadorder, elementpathstring, elementvaluestring, StrToInt(elementinteger), elementisflag);
              if Result = 1 then Exit;
            end
            else
            begin
              elementvaluestring := IntToHex(FormID(newrec), 8);
              if ((AnsiPos('Return', elementpathstring) <> 1) AND (elementpathstring <> '')) then
		  			  begin
                Result := CreateElement(rec, originalloadorder, fileloadorder, elementpathstring, elementvaluestring, StrToInt(elementinteger), elementisflag);
                if Result = 1 then Exit;
              end;
            end;
//            newrec := rec;
          end
		  		else if (elementpathstring <> '') then
          begin
		  			  Result := CreateElement(rec, originalloadorder, fileloadorder, elementpathstring, elementvaluestring, StrToInt(elementinteger), elementisflag);
              if Result = 1 then Exit;
          end;

          if Assigned(OriginRec1) then
          begin
            rec := OriginRec1;
            if Assigned(newrec) then previousrec2 := OriginRec2
            else previousrec := OriginRec2;
            OriginRec1 := Nil;
            OriginRec2 := Nil;
          end;
		  	end;

        if Assigned(newrec) then
        begin
          newrec := Nil;
          previousrec := previousrec2;
        end;

        if Signature(rec) = 'IDLM' then
          if ElementCount(ElementByPath(rec, 'IDLA')) = 1 then
            if GetEditValue(ElementByPath(rec, 'IDLA\Animation #0')) = 'NULL - Null Reference [00000000]' then
              Remove(ElementByPath(rec, 'IDLA'));

        if Signature(rec) = 'LTEX' then
          if GetElementEditValues(rec, 'TNAM') = 'NULL - Null Reference [00000000]' then
            Remove(ElementByPath(rec, 'TNAM'));

        if Signature(rec) = 'LVLN' then
          CleanLVLN(rec);

        if Signature(rec) = 'IPDS' then
          CleanIPDS(rec);

        if Signature(rec) = 'MGEF' then
          if GetElementEditValues(rec, 'Magic Effect Data\DATA\Actor Value') = 'FFFF - None Reference [FFFFFFFF]' then
            SetElementEditValues(rec, 'Magic Effect Data\DATA\Actor Value', '00000000');

        if Signature(rec) = 'SPEL' then
          if Assigned(ElementByPath(rec, 'Effects')) then
            if ElementCount(ElementByPath(rec, 'Effects')) = 1 then
              if GetElementEditValues(rec, 'Effects\Effect\EFID') = 'NULL - Null Reference [00000000]' then
                SetElementEditValues(rec, 'Effects\Effect\EFID', 'AshPileOnDeathEffect "Ash Pile On Death" [MGEF:001A692F]');

        if Signature(rec) = 'WRLD' then
          if GetElementEditValues(rec, 'ZNAM') = 'NULL - Null Reference [00000000]' then
            Remove(ElementByPath(rec, 'ZNAM'));

        /// Music
        if Signature(rec) = 'CELL' then
          if GetElementEditValues(rec, 'XCMO') = 'NULL - Null Reference [00000000]' then
            Remove(ElementByPath(rec, 'XCMO'));

        CleanConditions2(rec);

        iAliasCounter := 1;

        if CheckForErrors(rec) <> '' then
        begin
          AddMessage(Name(rec));
          AddMessage(CheckForErrors(rec));
          Result := 1;
          Exit;
        end;

//	  	  AddMessage(Name(rec));

        if ExitFile then
        begin
          AddMessage('Exiting because __EXIT.csv is true');
          Result := 1;
          Exit;
        end;
		  end;
    end;
	end;
  slContinueFrom.Free;
  Result := 0;
end;

////////////////////////////////////////////////////////////////////////////////
//PROCESS
////////////////////////////////////////////////////////////////////////////////
//function Process(e: IInterface): integer;

function Finalize: integer;
//var i: integer;
var
slFailedReferences: TStringList;
//i: integer;
begin
  AddMessage('Finalizing...');
  slReferences.SaveToFile(ProgramPath + 'data\' + '__ReferenceList.csv');
	slfailed.SaveToFile(ProgramPath + 'data\' + '__FailedList.csv');
	slloadorders.SaveToFile(ProgramPath + 'data\' + '__Loadorders.csv');
  slFailedReferences := TStringList.Create;
//  slFailedReferences := AddMissingReferences(slReferences);
  if slFailedReferences.Count > 0 then
  begin
    AddMessage('WARNING: One or more References Still Need to be Added');
    slFailedReferences.SaveToFile(ProgramPath + 'data\' + '__FailedReferences.csv');
  end;
	/// Lookup Lists
	slPathsLookup.Free;
	slTemporaryDelimited.Free;
	slEntryLength.Free;
	slShortLookup.Free;
	slShortLookupPos.Free;

	/// Columns
	slSingleValues.Free;
	slNewRec.Free;
	slNewRecSig.Free;
	slSingleRec.Free;
	slOldNewValMatch.Free;
	slNewPathorOrder.Free;
	slOldVal.Free;
	slNewVal.Free;
	slOldIndex.Free;
	slNewIndex.Free;
	slReplaceAnyVal.Free;
	slReplaceAnyIndex.Free;
	slIsFlag.Free;

	/// Converted Data
	sl_Paths.Free;
	sl_Values.Free;
	sl_Integer.Free;
	sl_Flag.Free;
	sl_NewRec.Free;

	/// Sources
	NPCList.Free;
	slstring.Free;
	slfilelist.Free;

	/// Logs
	slloadorders.Free;
	slReferences.Free;
	slfailed.Free;
	slrecordconversions.Free;
	slFileExtensions.Free;
  Result := 0;
end;

end.