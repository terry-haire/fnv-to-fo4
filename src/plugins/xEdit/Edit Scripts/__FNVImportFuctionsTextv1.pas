unit __FNVMultiLoopImporttest;

var
NPCList, slstring, slformids, slloadorders, slprocessedtypes, slReferences, slfailed, slarraytracker: TStringList;
unproccesed: boolean;
previousrec: IInterface;

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
	if elementpathstring = 'Destructible\DEST\Count' then elementpathstring := 'Destructible\DEST\DEST Count';
	if elementpathstring = 'Destructible\DEST\Unused' then elementpathstring := 'Destructible\DEST\Unknown';
	if ansipos('(0x', elementpathstring) <> 0 then elementpathstring := copy(elementpathstring, 1, (ansipos('(0x', elementpathstring) - 2));
	if elementpathstring = 'Destructible\Stages\Stage\DSTD\Damage Stage' then elementpathstring := 'Destructible\Stages\Stage\DSTD\Model Damage Stage';
	if elementpathstring = 'Record Header\Record Flags\Obstacle / No AI Acquire' then elementpathstring := 'Record Header\Record Flags\Obstacle';
	if elementpathstring = 'Record Header\Record Flags\Random Anim Start / High Priority LOD'  then elementpathstring :=  'Record Header\Record Flags\Random Anim Start';
	if elementpathstring = 'Record Header\Record Flags\Child Can Use / Refracted by Auto Water' then elementpathstring := 'Record Header\Record Flags\Child Can Use';
	if elementpathstring = 'XATO' then elementpathstring := 'ATTX';
	if elementpathstring = 'ETYP' then elementpathstring := '';
	if elementpathstring = 'ENIT\Flags?' then elementpathstring := 'ENIT\Flags';
	if elementpathstring = 'ENIT\Flags?\No Auto-Calc (Unused)' then elementpathstring := 'ENIT\Flags\No Auto-Calc';
	if elementpathstring = 'ENIT\Flags?\Food Item' then elementpathstring := 'ENIT\Flags\Food Item';
	if elementpathstring = 'Effects\Effect\EFIT\Type' then elementpathstring := '';
	if elementpathstring = 'Effects\Effect\EFIT\Actor Value' then elementpathstring := '';
	if elementpathstring = 'Effects\Effect\Conditions\CTDA\Function' then elementpathstring := 'Effects\Effect\Conditions\Condition\CTDA\Function';
	if elementpathstring = 'Effects\Effect\Conditions\CTDA' then elementpathstring := 'Effects\Effect\Conditions\Condition';
	//if elementpathstring = 'Effects\Effect\Conditions\CTDA' then elementpathstring := 'Effects\Effect\Conditions\Condition\CTDA';
	if elementpathstring = 'Effects\Effect\Conditions\CTDA\Parameter #1' then elementpathstring := 'Effects\Effect\Conditions\Condition\CIS1';
	if elementpathstring = 'Effects\Effect\Conditions\CTDA\Parameter #2' then elementpathstring := 'Effects\Effect\Conditions\Condition\CIS2';
	if elementpathstring = 'Effects\Effect\Conditions\CTDA\Run On' then elementpathstring := 'Effects\Effect\Conditions\Condition\CTDA\Run On';
	if elementpathstring = 'Effects\Effect\Conditions\CTDA\Reference' then elementpathstring := 'Effects\Effect\Conditions\Condition\CTDA\Reference';
	if elementpathstring = 'Effects\Effect\Conditions\CTDA\Comparison Value' then elementpathstring := 'Effects\Effect\Conditions\Condition\CTDA\Comparison Value';
	if elementpathstring = 'Effects\Effect\Conditions\CTDA\Unused' then elementpathstring := '';
	if elementpathstring = 'Effects\Effect\Conditions\CTDA\Type' then elementpathstring := 'Effects\Effect\Conditions\Condition\CTDA\Type';
	if elementpathstring = 'Template' then elementpathstring := 'Template';
	if elementpathstring = 'Template' then elementpathstring := 'Template';
	if elementpathstring = 'Icon\ICON' then elementpathstring := 'ICON';
	if elementpathstring = 'ENIT\Withdrawal Effect' then elementpathstring := 'ENIT\Addiction';
	if elementpathstring = 'ENIT\Unused' then elementpathstring := '';
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
begin
	unproccesed := True;
	if slprocessedtypes.Count > 0 then for k := 0 to (slprocessedtypes.Count - 1) do
	begin
		if slprocessedtypes[k] = Signature(e) then unproccesed := False;
	end;
	if unproccesed then 
	begin
		slprocessedtypes.Add(Signature(e));
		//filename := 'FalloutNV.esm_LoadOrder_00_GRUP_WRLD_0 - Copy.csv';
		filename := 'DeadMoney.esm_LoadOrder_01_GRUP_ALCH_0 - Copy.csv';
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
			AddMessage(copy(slstring[2], 1, 4));
			if Signature(e) = copy(slstring[2], 1, 4) then 
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
				//AddMessage('FormID is ' + copy((IntToHex(slstring[0], 8)), 3, 6));
				if copy((IntToHex(slstring[0], 8)), 1, 2) = originalloadorder then SetLoadOrderFormID(rec, StrToInt('$' + fileloadorder + copy((IntToHex(slstring[0], 8)), 3, 6)))
				else
				begin
					for k := 0 to ((slloadorders.Count) div 3 - 1) do
					if fileloadorder = slloadorders[(k * 3)] then SetLoadOrderFormID(rec, StrToInt('$' + slloadorders[(k * 3 + 2)] + copy((IntToHex(slstring[0], 8)), 3, 6)));
				end;
				{
				begin
					for k := 0 to (FileCount - 1) do
					if ((GetFileName(FileByIndex(k)) <> 'Fallout4.Hardcoded.keep.this.with.the.exe.and.otherwise.ignore.it.I.really.mean.it.dat') AND (GetFileName(FileByIndex(k)) <> 'Fallout4.esm')) then
					begin
						SetLoadOrderFormID(rec, StrToInt('$' + fileloadorder + copy((IntToHex(slstring[0], 8)), 3, 6)))
						slformids.Add(IntToHex(GetLoadOrderFormID(rec)) + ';' + IntToHex(slstring[0], 8));
					end;
				end;
				}
				slarraytracker.Clear;
				for j := 1 to ((slstring.Count - 2 {skip loadorderformid and refcount}) div 3) do
				begin
					elementpathstring := copy(slstring[(j * 3 - 1)], 8, MaxInt);
					elementvaluestring := slstring[(j * 3)];
					elementvaluestring := stringreplace(elementvaluestring, '\r\n', #13#10, [rfReplaceAll]);
					elementvaluestring := stringreplace(elementvaluestring, '\comment\', ';', [rfReplaceAll]);
					elementinteger := StrToInt(slstring[(j * 3 + 1)]);
					//if ansipos('\', elementpathstring) = 0 then //no tree
					//if slstring[(j * 3 + 2)] = '0' then //not multiple
					begin
						//if elementpathstring = 'DATA - Position/Rotation \ Rotation \ Z' then 
						elementpathstring := formatelementpath(elementpathstring);
						if ansipos('Record Flags\NavMesh Generation', elementpathstring) <> 0 then
						begin
							elementpathstring := elementpathstring + copy(slstring[(j * 3 - 1)], (ansipos('NavMesh Generation', slstring[(j * 3 - 1)]) + 18), MaxInt);
							if ansipos('(0x', elementpathstring) <> 0 then elementpathstring := copy(elementpathstring, 1, (ansipos('(0x', elementpathstring) - 2));
						end;
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
						
							if elementpathstring = 'Effects\Effect' then AddMessage('Effect...................................................................');
							AddMessage(Path(previousrec));
							subrec := ElementByPath(rec, elementpathstring);
							if not Assigned(subrec) then
								subrec := Add(rec, elementpathstring, True);
							//if ((IndexOf(GetContainer(subrec), subrec) <> elementinteger) OR (not Assigned(subrec))) then
							begin
								//if ansipos('Effects\Effect\Conditions\Condition\CTDA', elementpathstring) <> 0 then 
								//begin 
								//AddMessage('Yes');
								//previousrec := ElementByPath(previousrec, 'CTDA');
								//end;
								containerpathstring := elementpathstring;
								containerpathstring := copy(containerpathstring, 1, (LastDelimiter('\', containerpathstring) - 1));
								subrec_container := previousrec;
								//if ((ansipos(formatelementpath(Copy(Path(subrec_container), 8, MaxInt)), elementpathstring)) <> 0) AND (Length(formatelementpath(Copy(Path(subrec_container), 8, MaxInt))) < Length(elementpathstring)) then
								//subrec_container := ElementByPath(subrec_container, Copy(elementpathstring, (Length(formatelementpath(Copy(Path(subrec_container), 8, MaxInt))) + 1), MaxInt));
								//if (ansipos(elementpathstring, formatelementpath(Copy(Path(subrec_container), 8, MaxInt))) <> 0) then
								if (ansipos(containerpathstring, formatelementpath(Copy(Path(subrec_container), 8, MaxInt))) <> 0) then
								begin
									//While (ansipos(elementpathstring, formatelementpath(Copy(Path(subrec_container), 8, MaxInt))) <> 0) do
									//	subrec_container := GetContainer(subrec_container);
									While (containerpathstring <> formatelementpath(Copy(Path(subrec_container), 8, MaxInt))) do
										subrec_container := GetContainer(subrec_container);
									if not Assigned(subrec) then subrec := ElementByIndex(subrec_container, elementinteger);
									if ((IndexOf(GetContainer(subrec), subrec) <> elementinteger) OR (not Assigned(subrec))) then subrec := ElementAssign(subrec_container, elementinteger, nil, False)
									else subrec := ElementByIndex(subrec_container, elementinteger);
								end
								else 
								begin
									AddMessage('Different Tree');
									AddMessage(elementpathstring);
									AddMessage(formatelementpath(Copy(Path(subrec_container), 8, MaxInt)));
									//While (containerpathstring <> formatelementpath(Copy(Path(subrec_container), 8, MaxInt))) do
									//	subrec_container := GetContainer(subrec_container);
									//While (ansipos(containerpathstring, formatelementpath(Copy(Path(subrec_container), 8, MaxInt))) <> 0) do
									//	subrec_container := GetContainer(subrec_container);
									//subrec := ElementAssign(subrec_container, elementinteger, nil, False);
								end;
							end;
							if Assigned(subrec) then
								if elementpathstring <> formatelementpath(Copy(Path(subrec), 8, MaxInt)) then AddMessage('subrec got assigned to wrong path');
							if not Assigned(subrec) then AddMessage('FAILED');
							if Path(subrec) <> '' then previousrec := subrec;
							
							//if elementpathstring = 'Effects\Effect' then AddMessage('Effect...................................................................');
							//subrec := ElementByPath(rec, elementpathstring);
							//if not Assigned(subrec) then
							//	subrec := Add(rec, elementpathstring, True);
							//if ((IndexOf(GetContainer(subrec), subrec) <> elementinteger) OR (elementpathstring = 'Effects\Effect')) then
							//begin
							//	containerpathstring := elementpathstring;
							//	containerpathstring := copy(containerpathstring, 1, (LastDelimiter('\', containerpathstring) - 1));
							//	subrec_container := rec;
							//	for k := 0 to (OccurrencesOfChar(containerpathstring, '\')) do
							//	begin
							//		for l := 0 to (IndexOf(subrec_container, LastElement(subrec_container))) do
							//		begin
							//			if formatelementpath(Copy(Path(ElementByIndex(subrec_container, l)), 8, MaxInt)) = Copy(containerpathstring, 1, OccurrenceOfChar(containerpathstring, '\', k)) then subrec_container := ElementByIndex(subrec_container, l);
							//			if formatelementpath(Copy(Path(ElementByIndex(subrec_container, l)), 8, MaxInt)) = containerpathstring then subrec_container := ElementByIndex(subrec_container, l);
							//			AddMessage(formatelementpath(Copy(Path(ElementByIndex(subrec_container, l)), 8, MaxInt)));
							//			AddMessage(Copy(containerpathstring, 1, OccurrenceOfChar(containerpathstring, '\', k)));
							//		end;
							//	end;
							//	AddMessage('Done');
							//	AddMessage('subrec_container Path is ' + Path(subrec_container));
							//	AddMessage('containerpathstring is ' + containerpathstring);
							//	if ((not Assigned(ElementByIndex(subrec_container, elementinteger))) AND (subrec_container <> rec)) then subrec := ElementAssign(subrec_container, elementinteger, nil, False)
							//	else AddMessage('Element Already Assigned');
							//	if containerpathstring <> formatelementpath(Copy(Path(subrec_container), 8, MaxInt)) then AddMessage('NO MATCH');
							//	
							//	//for k := 0 to (ElementCount(GetContainer(subrec)) - 1) do
							//	//if 
							//	//if ElementByIndex(GetContainer(subrec), elementinteger)
							//	
							//end;
							//if not Assigned(subrec) then AddMessage('FAILED');
							//previousrec := subrec;
							
							////if ansipos('-', elementpathstring) = 6 AND ansipos('\', elementpathstring) <> 0 then copy(elementpathstring, 1, 4);
							//subrec := ElementByPath(rec, elementpathstring);
							//if not Assigned(subrec) then
							//	subrec := Add(rec, elementpathstring, True);
							//if (((not Assigned(subrec)) AND (ansipos('\', elementpathstring) <> 0)) OR (ElementType(subrec) = 5)) then
							//begin // Get Container Path and Assign
							//	containerpathstring := elementpathstring;
							//	containerpathstring := copy(containerpathstring, 1, (LastDelimiter('\', containerpathstring) - 1));
							//	subrec_container := ElementByPath(rec, containerpathstring);								
							//	AddMessage('Getting Container');
							//	for k := 0 to (OccurrencesOfChar(formatelementpath(Copy(Path(previousrec), 8, MaxInt)), '\') - 1) do
							//	begin
							//		if containerpathstring = formatelementpath(Copy(Path(previousrec), 8, MaxInt)) then 
							//		begin
							//			subrec_container := previousrec;
							//			AddMessage('MATCH');
							//		end
							//		else previousrec := GetContainer(previousrec);
							//		AddMessage(containerpathstring);
							//		AddMessage(formatelementpath(Copy(Path(previousrec), 8, MaxInt)))
							//	end;
							//	{
							//	subrec_container := rec;
							//	for k := 0 to (OccurrencesOfChar(containerpathstring, '\') - 1) do
							//	begin
							//		for l := 0 to (ElementCount(subrec_container) - 1) do
							//		begin
							//			if formatelementpath(Copy(Path(ElementByIndex(subrec_container, l)), 8, MaxInt)) = Copy(containerpathstring, 1, OccurrenceOfChar(containerpathstring, '\', k)) then subrec_container := ElementByIndex(subrec_container, l);
							//			AddMessage(formatelementpath(Copy(Path(ElementByIndex(subrec_container, l)), 8, MaxInt)));
							//			AddMessage(Copy(containerpathstring, 1, OccurrenceOfChar(containerpathstring, '\', k)));
							//		end;
							//	end;
							//	}
							//	//if formatelementpath(Copy(Path(subrec_container), 8, MaxInt)) = containerpathstring then 
							//	AddMessage('Element Path String is ' + elementpathstring);
							//	AddMessage(IntToStr(ElementCount(subrec_container)));
							//	subrec := ElementAssign(subrec_container, elementinteger, nil, False);
							//	AddMessage(IntToStr(ElementCount(subrec_container)));
							//	if Assigned(subrec) then 
							//	begin
							//		firstarrayitem := true;
							//	end;
							//	if not Assigned(subrec) then AddMessage('ERROR: Element ' + elementpathstring + ' Could not be Created');
							//	if firstarrayitem then AddMessage('First Array Item..............................');
							//	if formatelementpath(copy(path(subrec), 8, MaxInt)) <> elementpathstring then 
							//	begin
							//		AddMessage('ERROR: ' + formatelementpath(copy(path(subrec), 8, MaxInt)) + ' Does not equal the original ' + elementpathstring);
							//		slfailed.Add(slstring[0] + elementpathstring);
							//		subrec := Nil;
							//	end;
							//	//if IndexOf(LastElement(ElementByPath(rec, elementpathstring))) > (ElementCount(ElementByPath(e, elementpathstring)) + 1);
							//end;
							////if ((Assigned(subrec)) AND (ElementType(GetContainer(subrec)) = 5) AND (not firstarrayitem)) then
							////begin
							////	AddMessage('True');
							////	subrec := ElementAssign(GetContainer(subrec), ElementCount(GetContainer(subrec)), nil, False);
							////	arraysubrec := subrec;
							////	AddMessage(IntToStr(IndexOf(GetContainer(subrec), subrec)));
							////end;
							//
							//if firstarrayitem then AddMessage('First Array Item..............................');
							
							if not Assigned(subrec) then 
							begin
								AddMessage('FAILED');
								AddMessage(elementpathstring);
								if elementpathstring <> 'SCRI' then slfailed.Add(slstring[0] + elementpathstring); // formid + elementpathstring
							end;
							//AddMessage(ElementType(rec));
							//AddMessage(elementpathstring);
							//AddMessage(slstring[(j * 3 + 3)]);
							
							if ((ansipos('[', elementvaluestring) <> 0) AND (ansipos('[', elementvaluestring) = (ansipos(']', elementvaluestring)) - 14)) then 
							//if (copy(elementvaluestring, (ansipos(']', elementvaluestring) - 8), 2) = fileloadorder)
							begin
								//elementvaluestring := copy(elementvaluestring, (ansipos(']', elementvaluestring) - 6), 6);
								if copy(elementvaluestring, (ansipos(']', elementvaluestring) - 8), 2) = originalloadorder then elementvaluestring := fileloadorder + elementvaluestring
								else
								begin
									for k := 0 to ((slloadorders.Count) div 3 - 1) do
									if copy(elementvaluestring, (ansipos(']', elementvaluestring) - 8), 2) = slloadorders[(k * 3)] then elementvaluestring := (slloadorders[(k * 3 + 2)] + copy(elementvaluestring, (ansipos(']', elementvaluestring) - 6), 6));
								end;
								slReferences.Add(elementvaluestring);
								AddMessage('Reference');
								Continue;
								
								
								{
								for k := 0 to (FileCount - 1) do
								if ((GetFileName(FileByIndex(k)) <> 'Fallout4.Hardcoded.keep.this.with.the.exe.and.otherwise.ignore.it.I.really.mean.it.dat') AND (GetFileName(FileByIndex(k)) <> 'Fallout4.esm')) then
								begin
									referencedrec := RecordByFormID(FileByIndex(k), StrToInt('$' + elementvaluestring), True);
									if referencedrec <> Nil then 
									begin
										AddMessage('not nil');
										AddMessage(Path(RecordByFormID(GetFile(rec), FixedFormID(rec), True)));
										elementvaluestring := fileloadorder + elementvaluestring;
										AddMessage(elementvaluestring);
									end
									else 
									begin
										slformids.Add(slstring[0] + ';' + slstring[1] + ';' + elementpathstring + ';' + elementvaluestring);
									end;
								end;
								//if copy(elementvaluestring, (ansipos(']', elementvaluestring) - 8), 8) = slformids[1] then
								//elementvaluestring := (slformids[0]);
								}
							end;
							
							if elementvaluestring = 'Portal Box' then elementvaluestring := '1';
							if elementvaluestring = 'Subject (0)' then elementvaluestring := '0';
							if elementvaluestring = 'IsHardcore' then elementvaluestring := '0';
							
							if Assigned(arraysubrec) then
							begin
								if Path(arraysubrec) = copy(Path(subrec), 1, Length(Path(arraysubrec))) then
								begin
									if ((not firstarrayitem) AND (IsEditable(subrec))) then
									begin
										SetElementEditValues(arraysubrec, formatelementpath(copy(Path(subrec), (Length(Path(arraysubrec)) + 4), MaxInt)),  elementvaluestring);
										AddMessage(formatelementpath(copy(Path(subrec), (Length(Path(arraysubrec)) + 4), MaxInt)));
										//while CanMoveDown(arraysubrec) do MoveDown(arraysubrec);
									end;
								end
								else arraysubrec := Nil;
							end;
							if (firstarrayitem AND (IsEditable(subrec))) then 
							begin
								SetEditValue(subrec, elementvaluestring);
								firstarrayitem := false;
							end;
							if ((not Assigned(arraysubrec)) 
							AND (elementpathstring <> 'NAME') 
							AND (elementpathstring <> 'XEMI') 
							AND (not firstarrayitem) 
							AND (IsEditable(subrec)) 
							AND (elementvaluestring <> '')
							) 
							then SetEditValue(subrec, elementvaluestring);
							//previousrec := subrec;
							//if ElementCount(GetContainer(ElementByPath(rec, elementpathstring))) > 0 //IndexOf((GetContainer(ElementByPath(rec, elementpathstring))), (ElementByPath(rec, elementpathstring))) 
						end;
					end;
				end;
			end;
		end;
	end;
end;

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
	//elementvaluestring.Free;
	//elementpathstring.Free;
end;

end.