unit __FNVImportFuctionsTextv2;

//Current Method for Importing data

interface
implementation
uses xEditAPI, Classes, SysUtils, StrUtils, Windows; //Remove before use in xEdit

var
slPathsLookup, slTemporaryDelimited, slEntryLength, slShortLookup, slShortLookupPos,
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
/// Columns
NPCList, slstring, slstringformatted, slformids, slloadorders, slprocessedtypes, slReferences, slfailed, slfilelist, slrecordconversions, slelementconversions, slelementconversionsresult, slelementpaths, slelementvalues, slelementintegers, slTreeCorrection, slFileExtensions: TStringList;
previousrec: IInterface;
debugmode, ExitAfterFail, SaveOnExit: Boolean;

function OccurrencesOfChar(const S: string; const C: char): integer;
var
  i: Integer;
begin
  result := 0;
  for i := 1 to Length(S) do
    if S[i] = C then
      inc(result);
end;

procedure AddElementData(StartingRow: Integer; EndingRow: Integer; elementvaluestring: String; elementinteger: String);
var
k: Integer;
NewPath, NewVal, NewIndex, IsFlag: String;
begin
  NewVal := elementvaluestring;
  for k := StartingRow to EndingRow do
  begin
    if slNewPathorOrder[k] <> '' then
    begin
      if NewPath <> '' then
      begin
        slstringformatted.Add(NewPath);
//        if NewVal = '' then
//          NewVal := elementvaluestring;
        slstringformatted.Add(NewVal);
        if NewIndex = '' then
          NewIndex := elementinteger;
        slstringformatted.Add(NewIndex);
        if IsFlag = '' then
          IsFlag := 'FALSE';
        slstringformatted.Add(IsFlag);
      end;
      NewPath := slNewPathorOrder[k];
    end;
    if slReplaceAnyVal[k] = 'TRUE' then
      NewVal := slNewVal[k];
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
      ) then
      begin
        NewPath := StringReplace(NewPath, '#0', ('#' + elementinteger), [rfIgnoreCase]);
        elementinteger := IntToStr(MaxInt);
//        AddMessage(NewIndex);
        if NewIndex <> '' then
        begin
          if NewIndex = '-2' then
            NewPath := ''
        end
        else
          NewIndex := IntToStr(MaxInt);
//        AddMessage(NewPath);
      end;
    end;
  end;
  slstringformatted.Add(NewPath);
//  if NewVal = '' then
//    NewVal := elementvaluestring;
  slstringformatted.Add(NewVal);
  if NewIndex = '' then
    NewIndex := elementinteger;
  slstringformatted.Add(NewIndex);
  if IsFlag = '' then
    IsFlag := 'FALSE';
  slstringformatted.Add(IsFlag);
//  AddMessage(slstringformatted[(slstringformatted.Count - 4)]);
//  AddMessage(slstringformatted[(slstringformatted.Count - 3)]);
//  AddMessage(slstringformatted[(slstringformatted.Count - 2)]);
//  AddMessage(slstringformatted[(slstringformatted.Count - 1)]);
//  AddMessage(NewIndex);
end;

function Build_slstring(elementpathstring: String; elementvaluestring: String; elementinteger: String): TStringList;
var
i, j, StartingRow, EndingRow: Integer;
begin
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
  slstringformatted.Add(elementpathstring);
  slstringformatted.Add(elementvaluestring);
  slstringformatted.Add(elementinteger);
  slstringformatted.Add('FALSE');
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

procedure ConvertElement(j: integer; slFinalConversion: TStringList; slFinalConversionLookUp: TStringList);
var
slelementconversionsdelimited: TStringList;
i: integer;
elementpathstring, elementvaluestring, elementinteger, elementisflag: String;
begin
	elementpathstring := copy(slstring[(j * 3)], 8, MaxInt);
	elementvaluestring := slstring[(j * 3 + 1)];
	elementinteger := slstring[(j * 3 + 2)];
	elementpathstring := formatelementpath(elementpathstring);
	elementvaluestring := stringreplace(elementvaluestring, '\r\n', #13#10, [rfReplaceAll]);
	elementvaluestring := stringreplace(elementvaluestring, '\comment\', ';', [rfReplaceAll]);
  elementvaluestring := stringreplace(elementvaluestring, '|CITATION|', '"', [rfReplaceAll]);
	elementpathstring := stringreplace(elementpathstring, '\comment\', ';', [rfReplaceAll]);
  elementpathstring := stringreplace(elementpathstring, '|CITATION|', '"', [rfReplaceAll]);
  elementisflag := 'FALSE';
	slelementconversionsresult.Clear;
	for i := 1 to (slFinalConversionLookup.Count - 1) do
	begin
		if elementpathstring = slFinalConversionLookup[i] then
		begin
    	slelementconversionsdelimited := TStringList.Create;
    	slelementconversionsdelimited.Delimiter := ';';
    	slelementconversionsdelimited.StrictDelimiter := true;
	  	slelementconversionsdelimited.DelimitedText := slFinalConversion[i];
			slelementconversionsresult.Add(slelementconversionsdelimited[2]);
      if slelementconversionsresult.Count <> 1 then
        AddMessage('ERROR: ConvertElement Count 1');
			if slelementconversionsdelimited.Count > 6 then
			begin
				for j := 6 to (((slelementconversionsdelimited.Count - 6) div 2) + 5) do
				begin
					if elementvaluestring = slelementconversionsdelimited[(j * 2) - 6] then
          begin
            slelementconversionsresult.Add(slelementconversionsdelimited[(j * 2) - 5]);
            Break;
          end;
				end;
        if slelementconversionsdelimited[4] = 'TRUE' then
        begin
          if slelementconversionsresult.Count < 2 then slelementconversionsresult.Add(slelementconversionsdelimited[7]);
        end;
				if slelementconversionsresult.Count <> 2 then slelementconversionsresult.Add(elementvaluestring);
			end
			else slelementconversionsresult.Add(elementvaluestring);
      if slelementconversionsresult.Count <> 2 then
        AddMessage('ERROR: ConvertElement Count 2');
			if slelementconversionsdelimited[3] <> '-1' then
      begin
        slelementconversionsresult.Add(slelementconversionsdelimited[3])
      end
			else
      begin
        slelementconversionsresult.Add(elementinteger);
      end;
      if slelementconversionsresult.Count <> 3 then
        AddMessage('ERROR: ConvertElement Count 3');
      if slelementconversionsdelimited[5] = 'TRUE' then slelementconversionsresult.Add('TRUE')
      else slelementconversionsresult.Add('FALSE');
      if slelementconversionsresult.Count <> 4 then
        AddMessage('ERROR: ConvertElement Count 4');
	    slelementconversionsdelimited.Free;
      Break;
		end;
	end;
  if slelementconversionsresult.Count <> 4 then
  begin
  	slelementconversionsresult.Add(elementpathstring);
  	slelementconversionsresult.Add(elementvaluestring);
  	slelementconversionsresult.Add(elementinteger);
    slelementconversionsresult.Add(elementisflag);
  end;
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

////////////////////////////////////////////////////////////////////////////////
///  Procedure for correcting the record tree
////////////////////////////////////////////////////////////////////////////////
procedure CorrectTree(elementpathstring: String; elementvaluestring: String; elementinteger: String);
var
slTreeCorrectionDelimited: TStringList;
i, j, l: Integer;
behind: Boolean;
begin
  slTreeCorrectionDelimited := TStringList.Create;
  slTreeCorrectionDelimited.Delimiter := ';';
	slTreeCorrectionDelimited.StrictDelimiter := true;
  for i := 1 to ((slTreeCorrection.Count div 2) - 1) do
  begin
    if slTreeCorrection[(i * 2)] = elementpathstring then
    begin
      slTreeCorrectionDelimited.DelimitedText := slTreeCorrection[(i * 2 + 1)];
//      for j := 0 to (slTreeCorrectionDelimited.Count - 1) do
//        if slTreeCorrectionDelimited[j] = elementpathstring then
//          k := j;
      j := 2;
      if slTreeCorrectionDelimited[0] <> '' then
      begin
        slstringformatted[(slstringformatted.Count - 3)] := slTreeCorrectionDelimited[0];
      end;
      if slTreeCorrectionDelimited[1] <> '' then
      begin
        //slstringformatted.Delete(slstringformatted.Count - 2);
        slstringformatted[(slstringformatted.Count - 2)] := slTreeCorrectionDelimited[1];
      end;
      behind := True;
      while j < slTreeCorrectionDelimited.Count do
      begin
        if slTreeCorrectionDelimited[j] = elementpathstring then
        begin
          behind := False;
          j := j + 1;
          if j = slTreeCorrectionDelimited.Count then Exit;
        end;

        ////////////////////////////////////////////////////////////////////////
        ///  element path
        ////////////////////////////////////////////////////////////////////////
//        AddMessage('Path is ' + slTreeCorrectionDelimited[j]);
        if behind then
          slstringformatted.Insert((slstringformatted.Count - 4), slTreeCorrectionDelimited[j])
        else
          slstringformatted.Add(slTreeCorrectionDelimited[j]);
        j := j + 2;
        if (slstringformatted.Count + 3) mod 4 <> 0 then
        begin
          AddMessage('ERROR: CorrectTree Path');
        end;

        ////////////////////////////////////////////////////////////////////////
        ///  element value
        ////////////////////////////////////////////////////////////////////////
//        AddMessage('Value is ' + slTreeCorrectionDelimited[j]);
        if slTreeCorrectionDelimited[j] = '' then
        begin
          if behind then
            slstringformatted.Insert((slstringformatted.Count - 4), elementvaluestring)
          else
            slstringformatted.Add(elementvaluestring);
          j := j + 2;
        end
        else
        begin
          for l := 0 to (StrToInt(slTreeCorrectionDelimited[j]) - 1) do
          begin
            if slTreeCorrectionDelimited[(j + 1 + l *2)] = elementvaluestring then
            begin
              if behind then
                slstringformatted.Insert((slstringformatted.Count - 4), slTreeCorrectionDelimited[(j + 2 + l *2)])
              else
                slstringformatted.Add(slTreeCorrectionDelimited[(j + 2 + l *2)]);
            end
            else if slTreeCorrectionDelimited[(j + 1 + l *2)] = '' then
            begin
              if behind then
                slstringformatted.Insert((slstringformatted.Count - 4), slTreeCorrectionDelimited[(j + 2 + l *2)])
              else
                slstringformatted.Add(slTreeCorrectionDelimited[(j + 2 + l *2)]);
            end;
          end;
          j := (j + 2 + 2 * StrToInt(slTreeCorrectionDelimited[j]));
        end;
        if (slstringformatted.Count + 2) mod 4 <> 0 then
        begin
          AddMessage('ERROR: CorrectTree Value');
        end;

        ////////////////////////////////////////////////////////////////////////
        ///  element index
        ////////////////////////////////////////////////////////////////////////
//        AddMessage('Index is ' + slTreeCorrectionDelimited[j]);
        if slTreeCorrectionDelimited[j] = '' then
        begin
          if behind then
            slstringformatted.Insert((slstringformatted.Count - 4), elementinteger)
          else
            slstringformatted.Add(elementvaluestring);
          j := j + 1;
        end
        else
        begin
          for l := 0 to (StrToInt(slTreeCorrectionDelimited[j]) - 1) do
          begin
            if slTreeCorrectionDelimited[(j + 1 + l *2)] = elementinteger then
            begin
              if behind then
                slstringformatted.Insert((slstringformatted.Count - 4), slTreeCorrectionDelimited[(j + 2 + l *2)])
              else
                slstringformatted.Add(slTreeCorrectionDelimited[(j + 2 + l *2)]);
            end
            else if slTreeCorrectionDelimited[(j + 1 + l *2)] = '' then
            begin
              if behind then
                slstringformatted.Insert((slstringformatted.Count - 4), slTreeCorrectionDelimited[(j + 2 + l *2)])
              else
                slstringformatted.Add(slTreeCorrectionDelimited[(j + 2 + l *2)]);
            end;
          end;
          j := (j + 1 + 2 * StrToInt(slTreeCorrectionDelimited[j]));
        end;
        if (slstringformatted.Count + 1) mod 4 <> 0 then
        begin
          AddMessage('ERROR: CorrectTree Integer');
        end;

        ////////////////////////////////////////////////////////////////////////
        ///  element flag
        ////////////////////////////////////////////////////////////////////////
        ///  Need To Add Functionality
        if behind then
          slstringformatted.Insert((slstringformatted.Count - 4), 'FALSE')
        else
          slstringformatted.Add('FALSE');
        j := j + 2;
        if (slstringformatted.Count) mod 4 <> 0 then
        begin
          AddMessage('ERROR: CorrectTree flag');
        end;
//        AddMessage('...');
//        for l := (slstringformatted.Count - 6) to (slstringformatted.Count - 1) do
//          AddMessage(slstringformatted[l]);
//        AddMessage('...');
      end;
    end;
  end;
end;


{
procedure CreatePathLookupList();
var
i: integer;
slelementconversionsdelimited: TStringList;
begin
	slelementconversionsdelimited := TStringList.Create;
	slelementconversionsdelimited.Delimiter := ';';
	slelementconversionsdelimited.StrictDelimiter := true;
	for i := 1 to (slFinalConversion.Count - 1) do
	begin
		slelementconversionsdelimited.DelimitedText := slFinalConversion[i];
		slelementpaths.Add(slelementconversionsdelimited[0]);
	end;
	slelementconversionsdelimited.Free;
	//for i := 1 to (slelementpaths.Count - 1) do
	//	AddMessage(slelementpaths[i]);
end;
}

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
///  INITIALIZE
///  WRLD / CELL / REFR
////////////////////////////////////////////////////////////////////////////////

function Initialize: integer;
var
///  s is for temporary strings
///  k is for temporary loops
i, j, k, l, m, LastSingleValueIndex: integer;
elementpathstring, filename, fileloadorder, originalloadorder, elementvaluestring, newfilename, elementinteger, elementisflag, recordpath, _Signature, _ConversionFile, lookuppath: String;
rec, ToFile: IInterface;
slFinalConversion, slFinalConversionLookUp, slSigConverion, slContinueFrom, slTempDelimited, sl, sl2: TStringList;
display_progress, FirstFileLoop: Boolean;
begin
  AddMessage('Initializing...');
  //////////////////////////////////////////////////////////////////////////////
  ///  Method 2
  //////////////////////////////////////////////////////////////////////////////
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
  slstringformatted := TStringList.Create;
  slTemporaryDelimited := TStringList.Create;

  //////////////////////////////////////////////////////////////////////////////
  ///  Create Lists
  //////////////////////////////////////////////////////////////////////////////
	slformids := 	TStringList.Create;
	NPCList := 		TStringList.Create;
	slstring := 	TStringList.Create;
	slloadorders := TStringList.Create;
	slprocessedtypes := TStringList.Create;
	slReferences := TStringList.Create;
	slfailed := TStringList.Create;
	slfilelist := TStringList.Create;
	slfilelist.LoadFromFile(ProgramPath + 'data\' + '_filelist.csv');
  SortFileList;
	slrecordconversions := TStringList.Create;
	slrecordconversions.LoadFromFile(ProgramPath + 'ElementConverions\' + '__RecordConversions.csv');
	slelementconversions := TStringList.Create;
	slelementconversions.LoadFromFile(ProgramPath + 'ElementConverions\' + '__ElementConversions.csv');
	slelementconversionsresult := TStringList.Create;
	slelementpaths := TStringList.Create;
	slelementvalues := TStringList.Create;
	slelementintegers := TStringList.Create;
	slstringformatted := TStringList.Create;
  slFinalConversion := TStringList.Create;
  slFinalConversionLookUp := TStringList.Create;
  slTempDelimited := TStringList.Create;
  slSigConverion := TStringList.Create;
  slTreeCorrection := TStringList.Create;
  slTreeCorrection.LoadFromFile(ProgramPath + 'ElementConverions\' + '__TreeCorrection.csv');
  slContinueFrom := TStringList.Create;
  slContinueFrom.Delimiter := ';';
	slContinueFrom.StrictDelimiter := true;
  slFileExtensions := TStringList.Create;
  slFileExtensions.LoadFromFile(ProgramPath + 'ElementConverions\' + '__FileExtensions.csv');
  slShortLookup := TStringList.Create;
  slShortLookupPos := TStringList.Create;

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
          lookuppath := slPathsLookup[(slPathsLookup.Count - 1)];
          if AnsiPos('\', lookuppath) <> 0 then
            lookuppath := Copy(lookuppath, 1, (AnsiPos('\', lookuppath) - 1));
          for j := 0 to slShortLookup.Count do
          begin
            if j = slShortLookup.Count then
            begin
              slShortLookup.Add(lookuppath);
              slShortLookupPos.Add(IntToStr(slPathsLookup.Count - 1));
            end
            else
            if lookuppath = slShortLookup[j] then
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

//    AddMessage('.........');
//    AddMessage(_Signature);
//    AddMessage('.........');
//    for k := 0 to (slShortLookup.Count - 1) do
//    begin
//      AddMessage(slShortLookup[k]);
//    end;
//    AddMessage('.........');
//    for k := 0 to (slPathsLookup.Count - 1) do
//    begin
//      AddMessage(slPathsLookup[k]);
//    end;

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
      fileloadorder := IntToHex(GetLoadOrder(ToFile), 2);

      //////////////////////////////////////////////////////////////////////////
      ///  Create slstring and Data that doesnt require conversion
      //////////////////////////////////////////////////////////////////////////
			slstring.DelimitedText := Copy(NPCList[i], 6, MaxInt);
			slstringformatted.Clear;
			slstringformatted.Add(slstring[0]);
			slstringformatted.Add(slstring[1]);
			slstringformatted.Add(slstring[2]);

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
          ) then
          begin
            elementinteger := Copy(elementpathstring, (LastDelimiter('#', elementpathstring) + 1), MaxInt);
            if AnsiPos('\', elementinteger) <> 0 then
              elementinteger := Copy(elementinteger, 1, (AnsiPos('\', elementinteger) - 1));
            elementpathstring := StringReplace(elementpathstring, ('#' + elementinteger), '#0', [rfIgnoreCase]);
          end;
        end;

        ////////////////////////////////////////////////////////////////////////
        ///  File Reference
        ////////////////////////////////////////////////////////////////////////
        if LastDelimiter('.', elementvaluestring) <> 0 then
        begin
          for k := 0 to (slFileExtensions.Count - 1) do
          begin
            if LowerCase(Copy(elementvaluestring, LastDelimiter('.', elementvaluestring), MaxInt)) = slFileExtensions[k] then
            begin
              if slFileExtensions[k] = '.mp3' then
                elementvaluestring := Copy(elementvaluestring, 1, (LastDelimiter('.', elementvaluestring) - 1)) + '.xwm';
              if slFileExtensions[k] = '.kf' then
                elementvaluestring := Copy(elementvaluestring, 1, (LastDelimiter('.', elementvaluestring) - 1)) + '.hkx';
              if slFileExtensions[k] = '.egt' then
                elementvaluestring := Copy(elementvaluestring, 1, (LastDelimiter('.', elementvaluestring) - 1)) + '.ssf';
              if slFileExtensions[k] = '.psa' then
                elementvaluestring := Copy(elementvaluestring, 1, (LastDelimiter('.', elementvaluestring) - 1)) + '.hkx'; // Death pose
              // Missing speedtree (.spt)
              elementvaluestring := 'new_vegas\' + elementvaluestring;
            end;
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
			if copy((IntToHex(StrToInt(slstring[0]), 8)), 1, 2) = originalloadorder then
        rec := RecordByFormID(ToFile, StrToInt('$' + fileloadorder + copy((IntToHex(StrToInt(slstring[0]), 8)), 3, 6)), True) // Fallout4.esm LAND Record
			else
			begin
				for k := 0 to ((slloadorders.Count) div 3 - 1) do
				if fileloadorder = slloadorders[(k * 3)] then
          rec := RecordByFormID(ToFile, StrToInt('$' + slloadorders[(k * 3 + 2)] + copy((IntToHex(StrToInt(slstring[0]), 8)), 3, 6)), True); // Fallout4.esm LAND Record
			end;
      if GetFileName(GetFile(rec)) <> GetFileName(ToFile) then
      begin
        AddMessage('FATAL ERROR: Rec selected in wrong file');
        Result := 1;
        Exit;
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

      if ((slstringformatted.Count - 3) mod 4) <> 0 then
      begin
        AddMessage('Wrong Count in slstringformatted');
        Result := 1;
        Exit;
      end;

			for j := 1 to ((slstringformatted.Count - 3 {skip loadorderformid and refcount and fullpath}) div 4) do
			begin
				elementpathstring := slstringformatted[(j * 4 - 1)];
				elementvaluestring := slstringformatted[(j * 4 + 0)];
				elementinteger := (slstringformatted[(j * 4 + 1)]);
        elementisflag := (slstringformatted[(j * 4 + 2)]);
      	elementvaluestring := stringreplace(elementvaluestring, '\r\n', #13#10, [rfReplaceAll]);
      	elementvaluestring := stringreplace(elementvaluestring, '\comment\', ';', [rfReplaceAll]);
      	elementvaluestring := stringreplace(elementvaluestring, '|CITATION|', '"', [rfReplaceAll]);


        ////////////////////////////////////////////////////////////////////////
        ///  Caravan card list
        if AnsiPos('[CCRD:', elementvaluestring) <> 0 then
        begin
          if elementpathstring = 'Leveled List Entries\Leveled List Entry\LVLO\Reference' then
            Break;
        end;
//				AddMessage(elementpathstring);
//  			AddMessage(elementvaluestring);
//        AddMessage(elementinteger);
//        AddMessage(elementisflag);
//        2147483647

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
				if (elementpathstring <> '') then
				begin
					Result := CreateElement(rec, originalloadorder, fileloadorder, elementpathstring, elementvaluestring, StrToInt(elementinteger), elementisflag);
          if Result = 1 then Exit;
				end;
			end;
//		  AddMessage(Name(rec));
      if ExitFile then
      begin
        AddMessage('Exiting because __EXIT.csv is true');
        Result := 1;
        Exit;
      end;
		end;
	end;
  slFinalConversion.Free;
  slFinalConversionLookUp.Free;
  slTempDelimited.Free;
  slSigConverion.Free;
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
  slFailedReferences := AddMissingReferences(slReferences);
  if slFailedReferences.Count > 0 then
  begin
    AddMessage('WARNING: One or more References Still Need to be Added');
    slFailedReferences.SaveToFile(ProgramPath + 'data\' + '__FailedReferences.csv');
  end;
  slFailedReferences.Free;
	//for i:= 0 to (slstringformatted.Count - 1) do
	//AddMessage(slstringformatted[i]);
  slloadorders.Free;
	NPCList.Free;
	slstring.Free;
	slformids.Free;
	slprocessedtypes.Free;
	slReferences.Free;
	slfailed.Free;
	slfilelist.Free;
	slrecordconversions.Free;
	slelementconversions.Free;
	slelementconversionsresult.Free;
	slelementpaths.Free;
	slelementvalues.Free;
	slelementintegers.Free;
	slstringformatted.Free;
  slTreeCorrection.Free;
	//elementvaluestring.Free;
	//elementpathstring.Free;
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
  slPathsLookup.Free;
  slTemporaryDelimited.Free;
  slEntryLength.Free;
  slFileExtensions.Free;
  slShortLookup.Free;
  slShortLookupPos.Free;
  Result := 0;
end;

end.