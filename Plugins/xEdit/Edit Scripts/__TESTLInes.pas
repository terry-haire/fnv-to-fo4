unit __TESTLInes;

interface
implementation
uses xEditAPI, Classes, SysUtils, StrUtils, Windows; //Remove before use in xEdit

var
sl_paths: TStringList;

procedure OverlayCell(wrld: IInterface; rec2: IInterface);
var
  blockidx, subblockidx, cellidx: integer;
  wrldgrup, block, subblock, cell: IInterface;
  x, y, x1, y1: real;
begin
  wrldgrup := ChildGroup(wrld);
  // traverse Blocks
  for blockidx := 2 to Pred(ElementCount(wrldgrup)) do begin
    block := ElementByIndex(wrldgrup, blockidx);
    AddMessage('ADDING ' + Path(block));
    AddMessage('TO ' + Path(rec2));
    wbCopyElementToFile(block, GetFile(rec2), True, False);
    ElementAssign(rec2, MaxInt, block, False);
    // traverse SubBlocks
    for subblockidx := 0 to Pred(ElementCount(block)) do begin
      subblock := ElementByIndex(block, subblockidx);
      wbCopyElementToFile(subblock, GetFile(rec2), True, False);
    end;
  end;
end;

procedure AddBlocks(ToFile: IInterface);
var
  blockidx, subblockidx, cellidx: integer;
  wrldgrup, block, subblock, cell, rec: IInterface;
  x, y, x1, y1: real;
begin
  rec := FileByLoadOrder(0); // Should Always be Fallout4.esm
  rec := GroupBySignature(rec, 'WRLD');
  rec := MainRecordByEditorID(rec, 'Commonwealth');
  wrldgrup := ChildGroup(rec);
  // traverse Blocks
  for blockidx := 2 to Pred(ElementCount(wrldgrup)) do begin
  // Missing -1, 8
    block := ElementByIndex(wrldgrup, blockidx);
    AddMessage('ADDING ' + Path(block));
    AddMessage('TO ' + Path(ToFile));
    wbCopyElementToFile(block, ToFile, True, False);
    // traverse SubBlocks
    for subblockidx := 0 to Pred(ElementCount(block)) do begin
      subblock := ElementByIndex(block, subblockidx);
      wbCopyElementToFile(subblock, ToFile, True, False);
    end;
  end;
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
      Result := Path(elementcur) + #13#10 + Result;
      Exit;
    end;
		if ElementCount(elementcur) > 0 then Result := CheckForErrors(elementcur);
	end;
end;

procedure RemoveRecords(rec: IInterface);
var
i: Integer;
rec2: IInterface;
begin
  for i := (ElementCount(rec) - 1) downto 0 do
  begin
    rec2 := ElementByIndex(rec, i);
//    AddMessage(Path(rec2));
    if ((Signature(rec2) = 'CELL')
    OR (Signature(rec2) = 'REFR')
    OR (Signature(rec2) = 'LAND')
    OR (Signature(rec2) = 'ACHR')
    OR (Signature(rec2) = 'ACRE')
    OR (Signature(rec2) = 'NAVM')
    OR (Signature(rec2) = 'PGRE'))
    then Remove(rec2);
    if ElementCount(rec2) > 0 then RemoveRecords(rec2);
  end;
end;

procedure ElementWhiteList(rec: IInterface);
var
i, j: Integer;
sName: String;
begin
  for i := (ElementCount(rec) - 1) downto 0 do
  begin
    sName := Name(ElementByIndex(rec, i));
    for j := 0 to sl_paths.Count do
      if j = sl_paths.Count then
        sl_paths.Add(sName)
      else if sName = sl_paths[j] then
        Break;
  end;
end;


function Initialize: integer;
var
slstr, sltrf1, slstr2, sltrf2: TStringList;
i, k: Integer;
rec, rec2: IInterface;
begin
//  rec := FileByLoadOrder(1);
//  rec := GroupBySignature(rec, 'WRLD');
//  RemoveRecords(rec);
  sl_paths := TStringList.Create;
	Result := 0;
end;

function Process(e: IInterface): integer;
var
slstr, sltrf1, slstr2, sltrf2: TStringList;
i, k: Integer;
rec, rec2: IInterface;
begin
	Result := 0;
//  slstr := TStringList.Create;
//  slstr.Delimiter := ';';
//  slstr.StrictDelimiter := True;
//  slstr.DelimitedText := ('RNAM');
//  for i := 0 to (slstr.Count - 1) do
//  begin
//    for k := 11 to 20 do
//    begin
//      AddMessage('' + slstr[i] + '\Data #' + IntToStr(k) + '\Value');
//    end;
//  end;
//  rec := RecordByFormID(GetFile(e), $0116D745, True);
//  AddMessage(Signature(rec));
//  if Signature(rec) = 'CELL' then SetElementEditValues(e, 'Record Header\Form Version', '41');
//  AddMessage(FullPath(e));

  /// 3993
//  if Signature(e) = 'REFR' then
//  begin

//    rec := ElementByPath(e, 'XOWN\Owner');
//    if Assigned(rec) then
//      if GetEditValue(rec) = 'NULL - Null Reference [00000000]' then
//        Remove(GetContainer(rec));

//  if ((Signature(e) <> 'CELL')
//  AND (Signature(e) <> 'REFR')
//  ) then
//    Remove(e);

//  AddMessage(IntToStr($000800));
//  AddMessage(IntToStr('$' + Copy(IntToHex(FixedFormID(e), 8), 3, 6)));
//  AddMessage(IntToHex(FormID(e), 8));
//  AddMessage(IntToHex(GetLoadOrderFormID(e), 8));
//  AddMessage(IntToStr($1206D8));

////////////////////////////////////////////////////////////////////////////////
  if StrToInt('$' + Copy(IntToHex(FixedFormID(e), 8), 3, 6)) < 2048 then Remove(e);
  if StrToInt('$' + Copy(IntToHex(FixedFormID(LinksTo(ElementByPath(e, 'NAME'))), 8), 3, 6)) < 2048 then
    SetElementEditValues(e, 'NAME', ('00' + Copy(IntToHex(FixedFormID(LinksTo(ElementByPath(e, 'NAME'))), 8), 3, 6)));
  if GetElementEditValues(e, 'NAME') = 'NULL - Null Reference [00000000]' then Remove(e);

  if GetElementEditValues(e, 'Patrol') <> '' then
    AddMessage(GetElementEditValues(e, 'Patrol'));
//  if Signature(e) = 'REFR' then ElementWhiteList(e);

//  if Signature(e) = 'REFR' then
//    for i := (ElementCount(e) - 1) downto 0 do
//      if ((Name(ElementByIndex(e, i)) <> 'DATA - Position/Rotation')
//      AND (Name(ElementByIndex(e, i)) <> 'XPRM - Primitive')
//      AND (Name(ElementByIndex(e, i)) <> 'NAME - Base')
//      AND (Name(ElementByIndex(e, i)) <> 'Record Header')
//      AND (Name(ElementByIndex(e, i)) <> 'Cell')
//      AND (Name(ElementByIndex(e, i)) <> 'XEMI - Emittance')
//      AND (Name(ElementByIndex(e, i)) <> 'XSCL - Scale')
//      AND (Name(ElementByIndex(e, i)) <> 'XRDS - Radius')
//      AND (Name(ElementByIndex(e, i)) <> 'XOWN - Owner')
//      AND (Name(ElementByIndex(e, i)) <> 'XIS2 - Ignored by Sandbox')
//      AND (Name(ElementByIndex(e, i)) <> 'EDID - Editor ID')
//      AND (Name(ElementByIndex(e, i)) <> 'XMBO - Bound Half Extents')
//      AND (Name(ElementByIndex(e, i)) <> 'XLOC - Lock Data')
//      AND (Name(ElementByIndex(e, i)) <> 'ONAM - Open by Default')
//      AND (Name(ElementByIndex(e, i)) <> 'XACT - Action Flag')
//      ) then
//        Remove(ElementByIndex(e,i));
////////////////////////////////////////////////////////////////////////////////
//    AddMessage(Name(ReferencedByIndex(e, 0)));
//  end;
//  begin
//    AddMessage(IntToStr(GetLoadOrderFormID(e)));
//    AddMessage(IntToStr(FormId(e)));
//  end;
    //SetLoadOrderFormID(e, 3993);
//  AddMessage(Name(rec));
//  rec := GetFile(rec);
//  rec := GroupBySignature(rec, 'WRLD');
//  for i := 0 to (ElementCount(rec) - 1) do
//  begin
//    AddMessage(Path(ElementByIndex(rec, i)));
//    AddMessage(Name(ElementByIndex(rec, i)));
//    Add(ElementByIndex(rec, i), 'GRUP World Children of Lucky38World "Lucky 38" [WRLD:0116D714]', True);
//  end;


//  sltrf1 := TStringList.Create;
//  sltrf2 := TStringList.Create;
//  sltrf1.LoadFromFile(Programpath + 'ElementConverions\_IMAD_OldValues.txt');
//  sltrf2.LoadFromFile(ProgramPath + 'ElementConverions\_IMAD_NewValues.txt');
//  slstr := TStringList.Create;
//  slstr.Delimiter := '|';
//  slstr.StrictDelimiter := True;
//  slstr2 := TStringList.Create;
//  slstr2.Delimiter := '|';
//  slstr2.StrictDelimiter := True;
////  for i := 0 to (sltrf1.Count - 1) do
////  begin
////    slstr.DelimitedText := sltrf1[i];
////    slstr2.DelimitedText := sltrf2[i];
////    for k := 1 to 32 do
////    begin
////      AddMessage(slstr[0] + IntToStr(k) + slstr[1] + ';;;;;;;;;' + slstr2[0] + IntToStr(k) + slstr2[1]);
////    end;
////  end;
//  for k := 1 to 32 do
//  begin
//    for i := 0 to (sltrf1.Count - 1) do
//    begin
//      slstr.DelimitedText := sltrf1[i];
//      slstr2.DelimitedText := sltrf2[i];
//      AddMessage(slstr[0] + IntToStr(k) + slstr[1] + ';;;;;;;;;' + slstr2[0] + IntToStr(k) + slstr2[1]);
//    end;
//  end;
//  AddMessage('pokemon');
//  AddMessage(StringReplace('pokemon', 'oke', '', [rfIgnoreCase]));
//  rec := ElementByPath(e, 'Magic Effect Data\DATA\Actor Value');
//  for i := 0 to 100 do
//  begin
//    SetEditValue(rec, IntToStr(i));
//    AddMessage(GetEditValue(rec));
//  end;
//  AddMessage(Name(e));
//  AddMessage(GetElementEditValues(e, 'PSDT\Month'));
//  i := StrToInt('5 + 5');
//  Expres
//  for i := 0 to 1000 do
//  begin
//    SetElementEditValues(e, 'Conditions\Condition\CTDA\Function', IntToStr(i));
//    AddMessage(GetElementEditValues(e, 'Conditions\Condition\CTDA\Function'));
//  end;
//  AddMessage(GetElementEditValues(e, 'NAM0'));
//  SetToDefault(e);
//  if ((Signature(e) = 'REFR') AND (AnsiPos('[SOUN:', GetElementEditValues(e, 'NAME')) <> 0)) then
//    AddMessage(GetElementEditValues(e, 'NAME'));
//  AddMessage(GetElementEditValues(e, 'Record Header\Record Flags'));
//  rec := ElementByPath(e, 'NAM8');
//  AddMessage(Check(rec));
//  AddMessage(CheckForErrors(e));
  //AddMessage(Name(LinksTo(ElementByPath(e, 'SNAM'))));
  //AddMessage(Name(ElementByPath(e, 'Model\MODS\Alternate Texture')));
//  if Signature(e) = 'CELL' then AddMessage(Path(GetContainer(e)));
//  if ElementCount(ElementByPath(e, 'Model\MODS')) > 1 then AddMessage(Name(e));
//    rec := ElementByPath(e, 'Region Data Entries\Region Data Entry');
//    for i := 0 to 20 do
//      AddMessage(Path(ElementAssign(rec, i, Nil, False)) + ';' + IntToStr(i));
//  wbCopyElementToFile(e, FileByLoadOrder(1), True, False);
//  if Signature(e) <> 'WRLD' then Remove(e);

//  AddMessage(IntToStr(GetLoadOrder(GetFile(e))));
//  AddMessage(IntToStr(StrToInt('$02')));

//  rec2 := ElementByPath(e, 'Layers\Alpha Layer');
////  AddMessage(Path(rec));
//  rec := ElementByPath(e, 'Layers');
//  Add(rec, 'Alpha Layer',  True);
//  ElementAssign(rec, MaxInt, rec2, False);
//  GetEditValue(rec2);
//  if Assigned(ElementByPath(e, 'Layers\Alpha Layer')) then
//    AddMessage(Name(e));
//  if Signature(e) = 'DIAL' then
//    AddMessage(Name(e));
//  AddMessage(Path(ElementByIndex(ElementByPath(e, 'Conditions\Condition'), 1)));
//  AddMessage(IntToStr(IndexOf(GetFile(e), e)));
//  AddMessage(GetElementEditValues(e, 'Stages\Stage\Log Entries\Log Entry\Embedded Script\SCTX'));
end;

function Finalize: integer;
var
i: Integer;
begin
  for i := 0 to (sl_paths.Count - 1) do
    AddMessage(sl_paths[i]);
	Result := 0;
end;

end.
