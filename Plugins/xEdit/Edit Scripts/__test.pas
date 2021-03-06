unit __test;

interface
implementation
//uses xEditAPI, Classes, SysUtils, StrUtils, Windows;

var
NPCList: TStringList;
ToFile: IInterface;

function NewArrayElement(rec: IInterface; path: String): IInterface;
var
  a: IInterface;
begin
  a := ElementByPath(rec, path);
  if Assigned(a) then begin
    Result := ElementAssign(a, HighInteger, nil, false);
  end
  else begin
    a := Add(rec, path, true);
    Result := ElementByIndex(a, 0);
  end;
end;

procedure AddLeveledListEntry(rec: IInterface; level: Integer;
  reference: IInterface; count: Integer);
var
  entry: IInterface;
begin
  entry := NewArrayElement(rec, 'Leveled List Entries');
  SetElementNativeValues(entry, 'LVLO\Level', level);
  SetElementNativeValues(entry, 'LVLO\Reference', GetLoadOrderFormID(reference));
  SetElementNativeValues(entry, 'LVLO\Count', count);
end;

function Recursive(e: IInterface; i: integer; slstring: String): String;
var
j: integer;
ielement: IInterface;
begin
	j := i;
	//if i < (ElementCount(e)-1) then
		AddMessage(IntToStr(i));
	for i := 0 to (ElementCount(e)-1) do 
	begin 
		ielement := ElementByIndex(e, i);
		AddMessage(Path(ielement));
		AddMessage(IntToStr(ElementCount(ielement)));
		AddMessage(GetEditValue(ielement));
		if ansipos(#13#10, GetEditValue(ielement)) = 0 then
		slstring := (slstring + ';' + path(ielement){ + ';' + IntToStr(ElementCount(ielement))} + ';' + GetEditValue(ielement))
		else slstring := (slstring + ';' + path(ielement){ + ';' + IntToStr(ElementCount(ielement))} + ';' + stringreplace(GetEditValue(ielement), #13#10, '\r\n', [rfReplaceAll]));
		if ElementCount(ielement) > 0 then 
		begin
			slstring := (Recursive(ielement, 0, slstring));
			AddMessage('oke');
		end;
	end;
	Result := slstring;
end;

function Initialize: integer;
begin
	//NPCList := TStringList.Create;
	//ToFile := AddNewFileName('records.esp');
	////AddMasterIfMissing(ToFile, 'Fallout4.esm');
	//AddMasterIfMissing(ToFile, 'FalloutNV.esm');
end;

function Process(e: IInterface): integer;
var
i: Integer;
kwda, k: IInterface;
teststring: String;
begin
//GetContainerElementByPath(e, 'Record Header\FormID')
//Add(e, 'Activate Parents\Activate Parent Refs', True);

//ElementAssign((ElementByPath(e, 'Activate Parents\Activate Parent Refs')), HighInteger, nil, False);

			//Add(FileByIndex(3), 'STAT', True);
			//Add((GroupBySignature(FileByIndex(3), 'STAT')), 'STAT', True);
			Add(Add(FileByIndex(2), 'WRLD', True), 'WRLD', True);
			Add(e, 'GRUP', True);
			k := FileByIndex(2);
			//AddMessage(IntToStr(ElementCount(k)));
			AddMessage(Signature(k));
			k := ElementByIndex(k, 55);
			//AddMessage(IntToStr(ElementCount(k)));
			AddMessage(Signature(k));
			//AddMessage((FullPath(ElementByIndex(k, 0))));
			//AddMessage((FullPath(ElementByIndex(k, 1))));
			//AddMessage((FullPath(ElementByIndex(k, 2))));
			//AddMessage((FullPath(ElementByIndex(k, 3))));
			k := ElementByIndex(k, 1);
			//AddMessage(IntToStr(ElementCount(k)));
			//k := ElementByIndex(k, 18);
			//AddMessage(FullPath(k));
			AddMessage(Signature(k));
			k := ElementByIndex(k, 1);
			AddMessage(Signature(k));
			
			
			//teststring := ' \ [01] DeadMoney.esm \ [30] GRUP Top "STAT" \ [727] NVDLC01OffRmLightHangingFlicker01 [STAT:01013B29]';
			// Retrieve FullPath
			//if ansipos('GRUP Top ', teststring) <> 0 then teststring := copy(teststring, (ansipos('GRUP Top "', teststring) + 10), 4);
			// Get top group name
			//AddMessage(teststring);
			
			
			//if Assigned(ElementByPath(FileByIndex(2), 'Static')) then AddMessage('TRUE');
			//if Assigned(ElementByIndex(FileByIndex(2), 1)) then AddMessage('TRUE');
			//AddMessage(FullPath(ElementByIndex(FileByIndex(2), 1)));
			//AddMessage(FullPath(ElementByIndex(e, 1)));
			//AddMessage(IntToStr(ElementCount(FileByIndex(2))));
			//AddMessage(FullPath(e));
			
			//ElementAssign(ElementByPath(FileByIndex(3), 'STAT'), HighInteger, Nil, False);
			//ElementAssign(GroupBySignature(FileByIndex(3), 'STAT'), HighInteger, Nil, False);
			
			//if not Assigned(ElementByPath(FileByIndex(3), 'Static')) then  AddMessage('no');
			//if not Assigned(GroupBySignature(FileByIndex(3), 'STAT')) then  AddMessage('no');
			//if Assigned(GroupBySignature(FileByIndex(3), 'STAT')) then  AddMessage('YES');
			//Add(ElementByIndex(ElementByPath(e, 'Destructible\Stages'), 0), 'Stage\Model', True);
			//ElementByIndex(ElementByPath(e, 'Destructible\Stages'), 0);
			//ElementAssign(ElementByIndex(ElementByPath(e, 'Destructible\Stages'), 0), 2, nil, False);
			//Add(e, 'Effects\Effect\Conditions\Condition', True);
			//ElementAssign(ElementByIndex(ElementByPath(e, 'Effects'), 2), 2, Nil, False);
			//for i := 0 to 1000 do
			//begin
			//	SetElementEditValues(e, 'Effects\Effect\Conditions\Condition\CTDA\Function', IntToStr(i));
			//	if GetElementEditValues(e, 'Effects\Effect\Conditions\Condition\CTDA\Function') <> IntToStr(i) then AddMessage(IntToStr(i) + ';' + GetElementEditValues(e, 'Effects\Effect\Conditions\Condition\CTDA\Function'));
			//end;
			//for i := 0 to 1000 do
			//begin
			//	SetElementEditValues(e, 'Effects\Effect\Conditions\CTDA\Function', IntToStr(i));
			//	if GetElementEditValues(e, 'Effects\Effect\Conditions\CTDA\Function') <> IntToStr(i) then AddMessage(IntToStr(i) + ';' + GetElementEditValues(e, 'Effects\Effect\Conditions\CTDA\Function'));
			//end;
			//
			//ElementAssign(ElementByPath(e, 'Effects'), 4, Nil, False);
			//AddMessage(Path(ElementByPath(ElementByIndex(e, 10), 'Effect')));
			//SetElementEditValues(e, 'ENIT\Addiction Chance', '1');
			//e := ElementByPath(e, 'ENIT\Addiction Chance');
			//AddMessage(Path(e));
			////slW := TList.Create;
			////slW.Add(ElementByPath(e, 'Activate Parents'));
			////AddMessage(slW[0]);
			//AddMessage('Adding...');
			//k := Add(e, 'Activate Parents\Activate Parent Refs', True);
			//if not Assigned(k) then AddMessage('no');
			//AddMessage('Adding...');
			//k := Add(e, 'XSPC', True);
			//if not Assigned(k) then AddMessage('no');
			//kwda := ElementByPath(e, 'Activate Parents\Activate Parent Refs');
			//kwda := RemoveElement(ElementByPath(e, 'Activate Parents'), kwda);
			//InsertElement(ElementByPath(e, 'Activate Parents'), 1, kwda);
			////k := Add(e, 'Power Grid', True);
			//NewArrayElement(Add(e, 'Activate Parents\Activate Parent Refs', True), 'Activate Parents\Activate Parent Refs');
			//Activate Parents\Activate Parent Refs 5
			//BuildRef(e);
			//if FileExists('E:\SteamLibrary\steamapps\common\Fallout 4\Data\FalloutNV.esm') then
			//AddMessage('Yes');
			//AddMessage(FullPathToFilename('FalloutNV.esm'));
			//ElementAssign(GetContainer(e), HighInteger, Nil, False);
			//AddMessage(Path(GetContainer(e)));
			////AddMessage(GetFileName(FileByIndex[3]));
			////ElementByPath(GetFile(e), 'File Header');
			//Add(GroupBySignature(FileByIndex[3], 'File Header'), 'Master Files', True);
			//AddMessage(GetEditValue(ElementByPath(e, 'Script (Begin)\Embedded Script\SCTX')));
			//AddMessage(GetEditValue(ElementByPath(e, 'DESC')));
			//AddMessage(IntToStr(ansipos(#13#10, GetEditValue(ElementByPath(e, 'DESC')))));
			//AddMessage('I want this string to'+#13#10+'use two lines.');
			//AddMessage(IntToStr(ElementCount(ElementByPath(e, 'Master Files'))));
			//AddMessage(IntToStr(ElementCount(ElementByPath(e, 'Master Files\Master File'))));
			//AddMessage(GetEditValue(ElementByPath(e, 'Master Files\Master File\MAST')));
			//AddMessage(GetEditValue(ElementByIndex(ElementByPath(e, 'Master Files\Master File'), 1)));
			//Recursive(e, 0, '');
			//for i := 0 to (NPCList.Count - 1) do if Signature(e) = NPCList[i] then Exit;
			//NPCList.Add(Signature(e));
			//if Signature(e) <> 'TES4' then wbCopyElementToFile(e, ToFile, False, False);
			//AddMessage(stringreplace(GetEditValue(ElementByPath(e, 'DESC')), #13#10, '\r\n', [rfReplaceAll]));
			//Add(ElementByPath(FileByIndex[3], 'File Header'), 'Master Files',True);
			//AddMessage(ProgramPath);
			//AddMessage(FullPath(e));
			//if Signature(e) <> 'NAVI' then AddMessage('Not NAVI');
			//if RecordByFormID(GetFile(e), FixedFormID(e), True) <> Nil then 
			//begin
			//AddMessage('not nil');
			//AddMessage(Path(RecordByFormID(GetFile(e), FixedFormID(e), True)));
			//end;
			//for i := 0 to (FileCount - 1) do AddMessage(GetFileName(FileByIndex(i))); 
			////AddMessage(IntToStr(GetLoadOrder(e)));
			////AddMessage(Name(e));
			//AddMessage(IntToHex(GetLoadOrder(GetFile(e)), 2));
			//AddMessage(Copy(IntToHex(GetLoadOrderFormID(GetFile(e)), 8), 1, 2));
			//AddNewFileName('epaelfrpl.esm');
			//
			////AddMessage(copy(FullPath(e), (ansipos('GRUP', FullPath(e)) + 10), 4));
			////AddMessage(copy(copy(FullPath(e), (ansipos('GRUP', FullPath(e)) + 10), MaxInt), 1, (ansipos('\', copy(FullPath(e), (ansipos('GRUP', FullPath(e)) + 10), MaxInt)) - 3)));
			//
			//ElementAssign(ElementByPath(e, 'Destructible\Stages\Stage'), 3, nil, False);
			//AddMessage(IntToStr(IndexOf(ElementByPath(e, 'Activate Parents'), LastElement(ElementByPath(e, 'Activate Parents')))));
			//AddMessage(IntToStr(ElementType(ElementByPath(e, 'Activate Parents\Activate Parent Refs'))));
			//AddMessage(Copy(IntToHex(GetLoadOrderFormID(e), 8), 1, 2));
			//AddMessage(IntToStr(ReferencedByCount(e)));
			////AddMessage(GetLoadOrder(e));
			//ElementByIndex(k, 1);
			//Add(k, 'Connections', True);
			//k := ElementAssign(kwda, HighInteger, nil, False);
			//Add(ElementByPath(e, 'Activate Parents'), 'Activate Parent Refs', True);
			//if not Assigned(kwda) then AddMessage('no');
			//kwda := ElementByPath(e, 'Activate Parents\Activate Parent Refs');
			////ClearElementState(ElementByPath(e, 'Activate Parents\Activate Parent Refs'), esModified);
			//AddMessage(IntToStr(GetElementState(ElementByPath(e, 'Activate Parents\Activate Parent Refs'),esModified)));
			////kwda.ElementStates;
			////k := ElementAssign(kwda, HighInteger, nil, False);
			//AddMessage(IntToStr(GetElementState(ElementByPath(e, 'Activate Parents'), 2)));
			//AddMessage(IntToStr(GetElementState(ElementByPath(e, 'Activate Parents'), 3)));
			//AddMessage(IntToStr(GetElementState(ElementByPath(e, 'Activate Parents'), 4)));
			//AddMessage(IntToStr(GetElementState(ElementByPath(e, 'Activate Parents'), 5)));
			//AddMessage(IntToStr(GetElementState(ElementByPath(e, 'Activate Parents'), 6)));
			//AddMessage(IntToStr(GetElementState(ElementByPath(e, 'Activate Parents'), 7)));
			//AddMessage(IntToStr(GetElementState(ElementByPath(e, 'Activate Parents'), 8)));
			//AddMessage(IntToStr(GetElementState(ElementByPath(e, 'Activate Parents'), 9)));
			//AddMessage(IntToStr(GetElementState(ElementByPath(e, 'Activate Parents'), 10)));
			//AddMessage(IntToStr(GetElementState(ElementByPath(e, 'Activate Parents'), 11)));
			//AddMessage(IntToStr(GetElementState(ElementByPath(e, 'Activate Parents'), 12)));
			//AddMessage(IntToStr(ElementCount(ElementByPath(e, 'Activate Parents\Activate Parent Refs'))));
			//AddMessage(IntToStr(ContainerStates(ElementByPath(e, 'Activate Parents'))));
			//ContainerStates(ElementByPath(e, 'Activate Parents')) := False;
			//AddMessage(IntToStr(ContainerStates(ElementByPath(e, 'Activate Parents\Activate Parent Refs'))));
			//AddMessage(Name(ElementByPath(e, 'Activate Parents\Activate Parent Refs')));
			//AddMessage(IntToStr(ElementType(ElementByPath(e, 'Activate Parents'))));
			//SetElementState(ElementByPath(e, 'Activate Parents\Activate Parent Refs'), 71);
			//AddMessage(GetEditValue(ElementByPath(e, 'Activate Parents\Activate Parent Refs')));
			//SetToDefault(ElementByPath(e, 'Activate Parents\Activate Parent Refs'));
			////ElementCount(ElementByPath(e, 'Activate Parents\Activate Parent Refs')) := 1;
//AddMessage((GetElementEditValues(e, 'Activate Parents\Activate Parent Refs\XAPR\Delay')));
end;

function Finalize: integer;
var i: integer;
begin
	//for i := 0 to (NPCList.Count - 1) do AddMessage(NPCList[i]);
end;
end.