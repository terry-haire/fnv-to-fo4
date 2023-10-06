unit __FNVMultiLoopImporttest;

var
NPCList, slstring, slstringformatted, slformids, slloadorders, slprocessedtypes, slReferences, slfailed, slarraytracker, slfilelist, slrecordconversions, slelementconversions, slelementconversionsresult, slelementpaths, slelementvalues, slelementintegers: TStringList;
unproccesed: boolean;
previousrec: IInterface;

procedure CreateElement(rec: IInterface; originalloadorder: String; fileloadorder: String; elementpathstring: String; elementvaluestring: String; elementinteger: integer);
var
subrec, subrec_container: IInterface;
containerpathstring: String;
k: integer;
begin 
	if elementpathstring <> '' then
	begin
		//AddMessage(Path(previousrec));
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
				if ((IndexOf(GetContainer(subrec), subrec) <> elementinteger) OR (not Assigned(subrec))) then subrec := ElementAssign(subrec_container, elementinteger, nil, False)
				else subrec := ElementByIndex(subrec_container, elementinteger);
			end
			else 
			begin
				//AddMessage('Different Tree');
				//AddMessage(elementpathstring);
				//AddMessage(formatelementpath(Copy(Path(subrec_container), 8, MaxInt)));
			end;
		end;
		if Assigned(subrec) then
			if elementpathstring <> formatelementpath(Copy(Path(subrec), 8, MaxInt)) then 
			begin
				if formatelementpath(Copy(Path(subrec), 8, MaxInt)) <> 'Record Header\Record Flags\NavMesh Generation' then
				begin 
					AddMessage('subrec ' + elementpathstring + ' got assigned to wrong path' + formatelementpath(Copy(Path(subrec), 8, MaxInt)));
					subrec := ElementByPath(subrec_container, Copy(elementpathstring, (LastDelimiter('\', elementpathstring) + 1), MaxInt));
				end;
			end;
		if Path(subrec) <> '' then previousrec := subrec;
		
		if not Assigned(subrec) then 
		begin
			for k := 0 to IndexOf(subrec_container, LastElement(subrec_container)) do
				if formatelementpath(Copy(Path(ElementByIndex(subrec_container, k)), 8, MaxInt)) = elementpathstring then subrec := ElementByIndex(subrec_container, k);
			//subrec := ElementByPath(rec, elementpathstring);
			if not Assigned(subrec) then
			begin
				AddMessage('FAILED');
				AddMessage(elementpathstring);
				if elementpathstring <> 'SCRI' then slfailed.Add(slstring[0] + elementpathstring); // formid + elementpathstring
				//Halt;
			end;
		end;
		
		if ((ansipos('[', elementvaluestring) <> 0) AND (ansipos('[', elementvaluestring) = (ansipos(']', elementvaluestring)) - 14)) then 
		begin
			if copy(elementvaluestring, (ansipos(']', elementvaluestring) - 8), 2) = originalloadorder then elementvaluestring := fileloadorder + elementvaluestring
			else
			begin
				for k := 0 to ((slloadorders.Count) div 3 - 1) do
				if copy(elementvaluestring, (ansipos(']', elementvaluestring) - 8), 2) = slloadorders[(k * 3)] then elementvaluestring := (slloadorders[(k * 3 + 2)] + copy(elementvaluestring, (ansipos(']', elementvaluestring) - 6), 6));
			end;
			slReferences.Add(elementvaluestring);
			//AddMessage('Reference');
			Exit;
		end;
		if elementvaluestring = 'Portal Box' then elementvaluestring := '1';
		if elementvaluestring = 'Subject (0)' then elementvaluestring := '0';
		if elementvaluestring = 'IsHardcore' then elementvaluestring := '0';
		if ((elementpathstring <> 'NAME') 
		AND (elementpathstring <> 'XEMI') 
		AND (IsEditable(subrec)) 
		AND (elementvaluestring <> '')
		) 
		then SetEditValue(subrec, elementvaluestring);
	end;
end;

procedure CreatePathLookupList();
var
i: integer;
slelementconversionsdelimited: TStringList;
begin
	slelementconversionsdelimited := TStringList.Create;
	slelementconversionsdelimited.Delimiter := ';';
	slelementconversionsdelimited.StrictDelimiter := true;
	for i := 1 to (slelementconversions.Count - 1) do
	begin
		slelementconversionsdelimited.DelimitedText := slelementconversions[i];
		slelementpaths.Add(slelementconversionsdelimited[0]);
	end;
	slelementconversionsdelimited.Free;
	//for i := 1 to (slelementpaths.Count - 1) do
	//	AddMessage(slelementpaths[i]);
end;


procedure ConvertElement(elementpathstring: String; elementvaluestring: String; elementinteger: Integer);
var
slelementconversionsdelimited: TStringList;
i: integer;
begin
	slelementconversionsresult.Clear;
	slelementconversionsresult.Add(elementpathstring);
	slelementconversionsresult.Add(elementvaluestring);
	slelementconversionsresult.Add(IntToStr(elementinteger));
	slelementconversionsdelimited := TStringList.Create;
	slelementconversionsdelimited.Delimiter := ';';
	slelementconversionsdelimited.StrictDelimiter := true;
	for i := 0 to (slelementconversions.Count - 1) do
	begin
		slelementconversionsdelimited.DelimitedText := slelementconversions[i];
			//if elementpathstring = 'Icon' then AddMessage('Icon Found');
			//AddMessage(slelementconversionsdelimited[0]);
		if elementpathstring = slelementconversionsdelimited[0] then 
		begin
			slelementconversionsresult.Clear;
			slelementconversionsresult.Add(slelementconversionsdelimited[1]);
			if slelementconversionsdelimited.Count > 3 then for j := 3 to (((slelementconversionsdelimited.Count - 3) div 2) + 2) do
			begin
				if elementvaluestring = slelementconversionsdelimited[(j * 2) - 3] then slelementconversionsresult.Add(slelementconversionsdelimited[(j * 2) - 2]);
			end
			else slelementconversionsresult.Add(elementvaluestring);
			if slelementconversionsdelimited[2] <> '-1' then slelementconversionsresult.Add(slelementconversionsdelimited[2])
			else slelementconversionsresult.Add(IntToStr(elementinteger));
		end;
	end;
	slelementconversionsdelimited.Free;
end;


{
procedure ConvertElement(elementpathstring: String; elementvaluestring: String; elementinteger: Integer);
var
slelementconversionsdelimited: TStringList;
i: integer;
begin
	slelementconversionsresult.Clear;
	slelementconversionsresult.Add(elementpathstring);
	slelementconversionsresult.Add(elementvaluestring);
	slelementconversionsresult.Add(IntToStr(elementinteger));
	for i := 0 to (slelementpaths.Count - 1) do
	begin
		if elementpathstring = slelementpaths[i] then 
		begin
			slelementconversionsdelimited := TStringList.Create;
			slelementconversionsdelimited.Delimiter := ';';
			slelementconversionsdelimited.StrictDelimiter := true;
			slelementconversionsdelimited.DelimitedText := slelementconversions[i];
			slelementconversionsresult.Clear;
			slelementconversionsresult.Add(slelementconversionsdelimited[1]);
			if slelementconversionsdelimited.Count > 3 then for j := 3 to (((slelementconversionsdelimited.Count - 3) div 2) + 2) do
			begin
				if elementvaluestring = slelementconversionsdelimited[(j * 2) - 3] then slelementconversionsresult.Add(slelementconversionsdelimited[(j * 2) - 2]);
			end
			else slelementconversionsresult.Add(elementvaluestring);
			if slelementconversionsdelimited[2] <> '-1' then slelementconversionsresult.Add(slelementconversionsdelimited[2])
			else slelementconversionsresult.Add(IntToStr(elementinteger));
			slelementconversionsdelimited.Free;
		end;
	end;
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

function OccurrencesOfChar(const S: string; const C: char): integer;
var
  i: Integer;
begin
  result := 0;
  for i := 1 to Length(S) do
    if S[i] = C then
      inc(result);
end;

function OccurrenceOfChar(const S: string; const C: char; number: integer): integer;
var
  i, j: Integer;
begin
  j := 0;
  for i := 1 to Length(S) do
  begin
    if S[i] = C then
      inc(j);
	if j = (number + 1) then
	begin
	  result := (i - 1);
	  Exit;
	end;
  end;
end;

function correctinteger(elementinteger: integer; elementpathstring: String): integer;
begin
	Result := elementinteger;
	if elementpathstring = 'Destructible\Stages' then Result := (elementinteger + 1);
	if elementpathstring = 'Destructible\Stages\Stage\Model' then Result := (elementinteger + 1);
end;

function formatelementpath(elementpathstring: TStringList): String;
var
pos1, pos2: integer;
begin
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
	Result := elementpathstring;
	
end;

function Initialize: integer;
begin
	slformids := 	TStringList.Create;
	NPCList := 		TStringList.Create;
	slstring := 	TStringList.Create;
	slloadorders := TStringList.Create;
	slprocessedtypes := TStringList.Create;
	slReferences := TStringList.Create;
	slfailed := TStringList.Create;
	slarraytracker := TStringList.Create;
	slfilelist := TStringList.Create;
	slfilelist.LoadFromFile(ProgramPath + 'data\' + '_filelist.csv');
	slrecordconversions := TStringList.Create;
	slrecordconversions.LoadFromFile(ProgramPath + 'ElementConverions\' + '__RecordConversions.csv');
	slelementconversions := TStringList.Create;
	slelementconversions.LoadFromFile(ProgramPath + 'ElementConverions\' + '__ElementConversions.csv');
	slelementconversionsresult := TStringList.Create;
	slelementpaths := TStringList.Create;
	slelementvalues := TStringList.Create;
	slelementintegers := TStringList.Create;
	slstringformatted := TStringList.Create;
	CreatePathLookupList();
	NPCList.Add('1217104;0;REFR \ Cell;CampForlornHope03 "Camp Forlorn Hope Jail" [CELL:00121483];REFR \ Record Header;;REFR \ Record Header \ Signature;REFR;REFR \ Record Header \ Data Size;40;REFR \ Record Header \ Record Flags;0000000000000000000000000000000000000000000000000000000000000000;REFR \ Record Header \ FormID;[REFR:00129250] (places LLamp01 [STAT:0001F35D] in GRUP Cell Temporary Children of CampForlornHope03 "Camp Forlorn Hope Jail" [CELL:00121483]);REFR \ Record Header \ Version Control Master FormID;1201428;REFR \ Record Header \ Form Version;15;REFR \ Record Header \ Version Control Info 2;0;REFR \ NAME - Base;LLamp01 [STAT:0001F35D];REFR \ DATA - Position/Rotation;;REFR \ DATA - Position/Rotation \ Position;;REFR \ DATA - Position/Rotation \ Position \ X;-628.677673;REFR \ DATA - Position/Rotation \ Position \ Y;248.457870;REFR \ DATA - Position/Rotation \ Position \ Z;6278.249023;REFR \ DATA - Position/Rotation \ Rotation;;REFR \ DATA - Position/Rotation \ Rotation \ X;0.0000;REFR \ DATA - Position/Rotation \ Rotation \ Y;0.0000;REFR \ DATA - Position/Rotation \ Rotation \ Z;270.0001');
	NPCList.Add('1217105;0;REFR \ Cell;CampForlornHope03 "Camp Forlorn Hope Jail" [CELL:00121483];REFR \ Record Header;;REFR \ Record Header \ Signature;REFR;REFR \ Record Header \ Data Size;60;REFR \ Record Header \ Record Flags;0000000000000000000000000000000000000000000000000000000000000000;REFR \ Record Header \ FormID;[REFR:00129251] (places BasementLightKickerWarm [LIGH:000695C5] in GRUP Cell Temporary Children of CampForlornHope03 "Camp Forlorn Hope Jail" [CELL:00121483]);REFR \ Record Header \ Version Control Master FormID;1201428;REFR \ Record Header \ Form Version;15;REFR \ Record Header \ Version Control Info 2;0;REFR \ NAME - Base;BasementLightKickerWarm [LIGH:000695C5];REFR \ XRDS - Radius;221.741638;REFR \ XEMI - Emittance;DemoMetroLight1024 [LIGH:0001E83C];REFR \ DATA - Position/Rotation;;REFR \ DATA - Position/Rotation \ Position;;REFR \ DATA - Position/Rotation \ Position \ X;-744.698059;REFR \ DATA - Position/Rotation \ Position \ Y;440.455170;REFR \ DATA - Position/Rotation \ Position \ Z;6356.648438;REFR \ DATA - Position/Rotation \ Rotation;;REFR \ DATA - Position/Rotation \ Rotation \ X;0.0000;REFR \ DATA - Position/Rotation \ Rotation \ Y;0.0000;REFR \ DATA - Position/Rotation \ Rotation \ Z;0.0000');
	NPCList.Add('1217106;0;REFR \ Cell;CampForlornHope03 "Camp Forlorn Hope Jail" [CELL:00121483];REFR \ Record Header;;REFR \ Record Header \ Signature;REFR;REFR \ Record Header \ Data Size;60;REFR \ Record Header \ Record Flags;0000000000000000000000000000000000000000000000000000000000000000;REFR \ Record Header \ FormID;[REFR:00129252] (places IndFXLightRaysStrtThin01 [STAT:0005B14C] in GRUP Cell Temporary Children of CampForlornHope03 "Camp Forlorn Hope Jail" [CELL:00121483]);REFR \ Record Header \ Version Control Master FormID;4283159;REFR \ Record Header \ Form Version;15;REFR \ Record Header \ Version Control Info 2;1;REFR \ NAME - Base;IndFXLightRaysStrtThin01 [STAT:0005B14C];REFR \ XEMI - Emittance;NVInteriorRegion [REGN:00169BD1];REFR \ XSCL - Scale;0.450000;REFR \ DATA - Position/Rotation;;REFR \ DATA - Position/Rotation \ Position;;REFR \ DATA - Position/Rotation \ Position \ X;-830.084717;REFR \ DATA - Position/Rotation \ Position \ Y;400.873962;REFR \ DATA - Position/Rotation \ Position \ Z;6664.604004;REFR \ DATA - Position/Rotation \ Rotation;;REFR \ DATA - Position/Rotation \ Rotation \ X;358.0148;REFR \ DATA - Position/Rotation \ Rotation \ Y;316.7395;REFR \ DATA - Position/Rotation \ Rotation \ Z;16.9238');
end;

{
XPRM\Type
None (0)
Box (1)
Sphere (2)
Plane (3)
Line (4)
Ellipsoid (5)
}

function Process(e: IInterface): integer;
var
i, j, k, l, elementinteger: integer;
elementpathstring, containerpathstring, filename, fileloadorder, originalloadorder, elementvaluestring, newfilename: String; 
rec, subrec, subrec_container, arraysubrec, referencedrec, ToFile: IInterface;
firstarrayitem: boolean;

//begin
//for l := 0 to (slfilelist.Count - 1) do
begin
	unproccesed := True;
	if slprocessedtypes.Count > 0 then for k := 0 to (slprocessedtypes.Count - 1) do
	begin
		if slprocessedtypes[k] = Signature(e) then unproccesed := False;
	end;
	if unproccesed then 
	begin
		slprocessedtypes.Add(Signature(e));
		//filename := slfilelist[l];
		filename := 'DeadMoney.esm_LoadOrder_01_GRUP_ALCH_0.csv';
		NPCList.LoadFromFile(ProgramPath + 'data\' + filename);
		originalloadorder := copy(filename, (ansipos('LoadOrder_', filename) + 10), 2);
		newfilename := copy(filename, 1, (ansipos('_LoadOrder', filename) - 1));
		for k := 0 to (FileCount - 1) do
		if GetFileName(FileByIndex(k)) = newfilename then
		begin
			ToFile := FileByIndex(k);
		end;
		if not Assigned(ToFile) then ToFile := AddNewFileName(newfilename);
		AddMasterIfMissing(ToFile, 'Fallout4.esm');
		if (ansipos('.esm', newfilename) <> 0) then SetIsESM(ToFile, True);
		slstring.Delimiter := ';';
		slstring.StrictDelimiter := true;
		if NPCList.Count > 0 then for i := 0 to (NPCList.Count -1) do
		begin
			slstring.DelimitedText := NPCList[i];
			slstringformatted.Clear;
			slstringformatted.Add(slstring[0]);
			slstringformatted.Add(slstring[1]);
			j := 1;
			while j < (((slstring.Count - 2 {skip loadorderformid and refcount}) div 3) + 1) do
			begin
				elementpathstring := copy(slstring[(j * 3 - 1)], 8, MaxInt);
				elementvaluestring := slstring[(j * 3)];
				elementinteger := StrToInt(slstring[(j * 3 + 1)]);
				elementpathstring := formatelementpath(elementpathstring);
				if ansipos('Record Flags\NavMesh Generation', elementpathstring) <> 0 then
				begin
					elementpathstring := elementpathstring + copy(slstring[(j * 3 - 1)], (ansipos('NavMesh Generation', slstring[(j * 3 - 1)]) + 18), MaxInt);
					if ansipos('(0x', elementpathstring) <> 0 then elementpathstring := copy(elementpathstring, 1, (ansipos('(0x', elementpathstring) - 2));
				end;
				if ansipos('(0x', elementpathstring) <> 0 then elementpathstring := copy(elementpathstring, 1, (ansipos('(0x', elementpathstring) - 2));
				ConvertElement(elementpathstring, elementvaluestring, elementinteger);
				elementpathstring := slelementconversionsresult[0];
				elementvaluestring := slelementconversionsresult[1];
				elementinteger := slelementconversionsresult[2];
				elementvaluestring := stringreplace(elementvaluestring, '\r\n', #13#10, [rfReplaceAll]);
				elementvaluestring := stringreplace(elementvaluestring, '\comment\', ';', [rfReplaceAll]);
				//if elementpathstring = 'Effects\Effect\Conditions\Condition\CIS2' then
				//begin
				//	if slstring
				//end;
				slstringformatted.Add(elementpathstring);
				slstringformatted.Add(elementvaluestring);
				slstringformatted.Add(elementinteger);
				Inc(j);
			end;
			//for j := 1 to ((slstring.Count - 2 {skip loadorderformid and refcount}) div 3) do
			//begin
			//	elementpathstring := copy(slstring[(j * 3 - 1)], 8, MaxInt);
			//	elementvaluestring := slstring[(j * 3)];
			//	elementinteger := StrToInt(slstring[(j * 3 + 1)]);
			//	elementpathstring := formatelementpath(elementpathstring);
			//	if ansipos('Record Flags\NavMesh Generation', elementpathstring) <> 0 then
			//	begin
			//		elementpathstring := elementpathstring + copy(slstring[(j * 3 - 1)], (ansipos('NavMesh Generation', slstring[(j * 3 - 1)]) + 18), MaxInt);
			//		if ansipos('(0x', elementpathstring) <> 0 then elementpathstring := copy(elementpathstring, 1, (ansipos('(0x', elementpathstring) - 2));
			//	end;
			//	if ansipos('(0x', elementpathstring) <> 0 then elementpathstring := copy(elementpathstring, 1, (ansipos('(0x', elementpathstring) - 2));
			//	ConvertElement(elementpathstring, elementvaluestring, elementinteger);
			//	elementpathstring := slelementconversionsresult[0];
			//	elementvaluestring := slelementconversionsresult[1];
			//	elementinteger := slelementconversionsresult[2];
			//	elementvaluestring := stringreplace(elementvaluestring, '\r\n', #13#10, [rfReplaceAll]);
			//	elementvaluestring := stringreplace(elementvaluestring, '\comment\', ';', [rfReplaceAll]);
			//	slstringformatted.Add(elementpathstring);
			//	slstringformatted.Add(elementvaluestring);
			//	slstringformatted.Add(elementinteger);
			//end;
			AddMessage(copy(slstring[2], 1, 4));
			if Signature(e) = ConvertSignature(copy(slstring[2], 1, 4), slrecordconversions) then 
			//if Signature(e) = copy(slstring[2], 1, 4) then 
			begin
				rec := wbCopyElementToFile(e, ToFile, True, False);
				fileloadorder := Copy(IntToHex(GetLoadOrderFormID(rec), 8), 1, 2);
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
				if copy((IntToHex(slstringformatted[0], 8)), 1, 2) = originalloadorder then SetLoadOrderFormID(rec, StrToInt('$' + fileloadorder + copy((IntToHex(slstringformatted[0], 8)), 3, 6)))
				else
				begin
					for k := 0 to ((slloadorders.Count) div 3 - 1) do
					if fileloadorder = slloadorders[(k * 3)] then SetLoadOrderFormID(rec, StrToInt('$' + slloadorders[(k * 3 + 2)] + copy((IntToHex(slstringformatted[0], 8)), 3, 6)));
				end;
				slarraytracker.Clear;
				for j := 1 to ((slstringformatted.Count - 2 {skip loadorderformid and refcount}) div 3) do
				begin
					elementpathstring := slstringformatted[(j * 3 - 1)]; 
					elementvaluestring := slstringformatted[(j * 3)]; 
					elementinteger := StrToInt(slstringformatted[(j * 3 + 1)]); 
					begin
						//if elementpathstring = 'DATA - Position/Rotation \ Rotation \ Z' then 
						elementinteger := correctinteger(elementinteger, elementpathstring);
						//AddMessage(elementpathstring);
						if ((elementpathstring <> 'Cell') 
						//AND (elementpathstring <> 'NAME') 
						AND (elementpathstring <> '') 
						AND (elementpathstring <> 'Record Header\Data Size') 
						AND (elementpathstring <> 'Record Header\FormID') 
						AND (elementpathstring <> 'Record Header\Form Version')
						AND (elementpathstring <> 'Record Header\Version Control Master FormID')
						AND (elementpathstring <> 'Record Header\Version Control Info 2')) then
						begin 
							if elementpathstring = 'Effects\Effect\Conditions\CTDA' then 
							begin
								CreateElement(rec, originalloadorder, fileloadorder, 'Effects\Effect\Conditions\Condition', elementvaluestring, elementinteger);
								elementpathstring := 'Effects\Effect\Conditions\Condition\CTDA';
								elementvaluestring := '';
								elementinteger := 0;
							end;
							if Path(previousrec) = 'ALCH \ Effects \ Effect \ Conditions \ Condition \ CIS2 - Parameter #2' then
							begin
								previousrec := ElementByIndex(ElementByIndex(GetContainer(previousrec), 0), 3);
							end;
							CreateElement(rec, originalloadorder, fileloadorder, elementpathstring, elementvaluestring, elementinteger);
						end;
					end;
				end;
			end;
		end;
	end;
end;
//end;

function Finalize: integer;
begin
	NPCList.Free;
	slstring.Free;
	slformids.Free;
	slprocessedtypes.Free;
	slReferences.Free;
	slfailed.SaveToFile(ProgramPath + 'data\' + '__FailedList.csv');
	slfailed.Free;
	slarraytracker.Free;
	slfilelist.Free;
	slrecordconversions.Free;
	slelementconversions.Free;
	slelementconversionsresult.Free;
	slelementpaths.Free;
	slelementvalues.Free;
	slelementintegers.Free;
	slstringformatted.Free;
	//elementvaluestring.Free;
	//elementpathstring.Free;
end;

end.