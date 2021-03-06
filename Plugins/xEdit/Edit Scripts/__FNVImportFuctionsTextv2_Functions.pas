////////////////////////////////////////////////////////////////////////////////
/// Fast but inflexible and complex
////////////////////////////////////////////////////////////////////////////////

unit __FNVImportFuctionsTextv2_Functions;

interface
implementation
uses xEditAPI, Classes, SysUtils, StrUtils, Windows; //Remove before use in xEdit

var
slPathsLookup, slTemporaryDelimited, slEntryLength, slstringformatted,
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
slIsFlag
/// Columns
: TStringList;

//function SetIndex(OldIndex: String; NewIndex: String): String;

procedure AddElementData(StartingRow: Integer; EndingRow: Integer; elementvaluestring: String; elementinteger: String);
var
k: Integer;
NewPath, NewVal, NewIndex, IsFlag: String;
begin
  for k := StartingRow to EndingRow do
  begin
    if slNewPathorOrder[k] <> '' then
    begin
      if NewPath <> '' then
      begin
        slstringformatted.Add(NewPath);
        slstringformatted.Add(NewVal);
        slstringformatted.Add(NewIndex);
        slstringformatted.Add(IsFlag);
      end;
      NewPath := slNewPathorOrder[k];
    end;
    if slReplaceAnyVal[k] = 'TRUE' then
      NewVal := slNewVal[k];
    if slReplaceAnyIndex[k] = 'TRUE' then
    begin
      NewIndex := slNewIndex[k];
      IsFlag := slIsFlag[k];
    end;
    if elementvaluestring = slOldVal[k] then
      NewVal := slNewVal[k];
    if elementinteger = slOldIndex[k] then
    begin
      NewIndex := slNewIndex[k];
      IsFlag := slIsFlag[k];
    end;
  end;
  slstringformatted.Add(NewPath);
  slstringformatted.Add(NewVal);
  slstringformatted.Add(NewIndex);
  slstringformatted.Add(IsFlag);
end;

function Build_slstring(elementpathstring: String; elementvaluestring: String; elementinteger: String): TStringList;
var
i, k, StartingRow, EndingRow: Integer;
begin
  Result := TStringList.Create;
  for i := 0 to (slPathsLookup.Count - 1) do
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
      if slNewPathorOrder[StartingRow] = '' then Continue;
      if slNewRec[StartingRow] <> '1' then
      begin
        AddElementData(StartingRow, EndingRow, elementvaluestring, elementinteger);
      end;
    end;
  end;
end;

function Initialize: integer;
var
sl, sl2
: TStringList;
//ColumnPos: array[1..13] of Integer;
i, j, LastSingleValueIndex: Integer;

begin
  LastSingleValueIndex := 5;
  slSingleValues := TStringList.Create;
  slSingleValues.Add('slSingleValues');
  slNewRec := TStringList.Create;
  slNewRec.Add('slNewRec');
  slNewRecSig := TStringList.Create;
  slNewRecSig.Add('slNewRecSig');
  slSingleRec := TStringList.Create;
  slSingleRec.Add('slSingleRec');
  slOldNewValMatch := TStringList.Create;
  slOldNewValMatch.Add('slOldNewValMatch');
  slNewPathorOrder := TStringList.Create;
  slNewPathorOrder.Add('slNewPathorOrder');
  slOldVal := TStringList.Create;
  slOldVal.Add('slOldVal');
  slNewVal := TStringList.Create;
  slNewVal.Add('slNewVal');
  slOldIndex := TStringList.Create;
  slOldIndex.Add('slOldIndex');
  slNewIndex := TStringList.Create;
  slNewIndex.Add('slNewIndex');
  slReplaceAnyVal := TStringList.Create;
  slReplaceAnyVal.Add('slReplaceAnyVal');
  slReplaceAnyIndex := TStringList.Create;
  slReplaceAnyIndex.Add('slReplaceAnyIndex');
  slIsFlag := TStringList.Create;
  slIsFlag.Add('slIsFlag');
  sl := TStringList.Create;
  sl2 := TStringList.Create;
  slPathsLookup := TStringList.Create;
  slEntryLength := TStringList.Create;
  slstringformatted := TStringList.Create;
  slTemporaryDelimited := TStringList.Create;
  sl.LoadFromFile(ProgramPath + 'ElementConverions\Proto\' + '__ElementConversions.csv');
  sl2.LoadFromFile(ProgramPath + 'ElementConverions\Proto\' + '__ElementConversions.csv');
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
    slIsFlag.Add(slTemporaryDelimited[(StrToInt(slIsFlag[1]))]);
  end;
	Result := 0;
end;

function Process(e: IInterface): integer;
begin
	Result := 0;
end;

function Finalize: integer;
begin
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
  slIsFlag.Free;
  slPathsLookup.Free;
  slTemporaryDelimited.Free;
  slEntryLength.Free;
  slstringformatted.Free;
	Result := 0;
end;

end.