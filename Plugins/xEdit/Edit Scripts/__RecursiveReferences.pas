unit __RecursiveReferences;

interface
implementation
uses xEditAPI, Classes, SysUtils, StrUtils, Windows; //Remove before use in xEdit

var
slReferences, slLookup, slDel: TStringList;

procedure RecursiveReferences(e: IInterface; _signature: String);
var
i, j, k, l: integer;
ielement: IInterface;
valuestr: String;
begin
	for i := 0 to (ElementCount(e)-1) do
	begin
		ielement := ElementByIndex(e, i);
    valuestr := GetEditValue(ielement);
    j := (LastDelimiter('[', valuestr));
    if j > 0 then
    begin
      if (valuestr[j + 5] = ':') AND (valuestr[j + 14] = ']') then
      begin
//          AddMessage(valuestr[j + 15]);
        for k := 0 to (slReferences.Count - 1) do
        begin
          slDel.DelimitedText := slReferences[k];
          if slDel[0] = _signature then
          begin
            for l := 0 to (slDel.Count) do
            begin
              if l = slDel.Count then
                slReferences[k] := slReferences[k] + ';' + Copy(valuestr, (j + 1), 4)
              else if slDel[l] = Copy(valuestr, (j + 1), 4) then
                Break;
            end;
          end;
        end;
      end;
    end;
		if ElementCount(ielement) > 0 then RecursiveReferences(ielement, _signature);
	end;
end;

function Initialize: integer;
begin
  slReferences := TStringList.Create;
  slLookup := TStringList.Create;
  slLookup.Add('Signature');
  slReferences.Add('Signature');
  slDel := TStringList.Create;
  slDel.Delimiter := ';';
  slDel.StrictDelimiter := True;
	Result := 0;
end;

function Process(e: IInterface): integer;
var
_signature: String;
i: Integer;
begin
  _signature := Signature(e);
  for i := 0 to slLookup.Count do
  begin
    if i = slLookup.Count then
    begin
      slLookup.Add(_signature);
      slReferences.Add(_signature);
    end
    else if slLookup[i] = _signature then
      Break;
  end;
  RecursiveReferences(e, _signature);
	Result := 0;
end;

function Finalize: integer;
var
i, k, l, m, Counter, TopCount, BottomCount, MaxCount: Integer;
slLoaded, slLoadedDel: TStringList;
_Signature, filename: String;

begin
  for i := 0 to (slReferences.Count - 1) do
  begin
    AddMessage(slReferences[i]);
  end;
  filename := '__ReferenceOrder.csv';
  filename := ProgramPath + 'ElementConverions\' + filename;
  if slReferences.Count > 1 then
  begin
    AddMessage('Saving ' + filename);
    slReferences.SaveToFile(filename);
  end;
  slReferences.Free;
  slLookup.Free;
  slDel.Free;
  if not FileExists(filename) then
  begin
    AddMessage('File not Found');
    Result := 1;
    Exit;
  end;
  slLoaded := TStringList.Create;
  slLoaded.LoadFromFile(filename);
  slLoadedDel := TStringList.Create;
  slLoadedDel.Delimiter := ';';
  slLoadedDel.StrictDelimiter := True;
  MaxCount := 0;
  for i := 1 to (slLoaded.Count - 1) do
  begin
    slLoadedDel.DelimitedText := slLoaded[i];
    if MaxCount < slLoadedDel.Count then
      MaxCount := slLoaded.Count;
  end;
  for k := MaxCount downto 1 do
  begin
    for i := 1 to (slLoaded.Count - 1) do
    begin
      slLoadedDel.DelimitedText := slLoaded[i];
      if slLoadedDel.Count = k then
        slLoaded.Move(i, 1);
    end;
  end;
  AddMessage('..................................');
  for i := 0 to (slLoaded.Count - 1) do
    AddMessage(slLoaded[i]);
  AddMessage('..................................');

  TopCount := 1;
  for i := 1 to (slLoaded.Count - 1) do
  begin
    slLoadedDel.DelimitedText := slLoaded[i];
    if slLoadedDel.Count = 1 then
    begin
      slLoaded.Move(i, 1);
      Inc(TopCount);
    end;
  end;

  for i := TopCount to (slLoaded.Count - 1) do
  begin
    slLoadedDel.DelimitedText := slLoaded[i];
    if slLoadedDel.Count = 2 then
    begin
      _Signature := slLoadedDel[1];
      for k := 1 to (TopCount - 1) do
      begin
        slLoadedDel.DelimitedText := slLoaded[k];
        if slLoadedDel[0] = _Signature then
        begin
          slLoaded.Move(i, TopCount);
          Inc(TopCount);
        end;
      end;
    end;
  end;

  BottomCount := (slLoaded.Count - 1);
  for i := (slLoaded.Count - 1) downto TopCount do
  begin
    Counter := 0;
    slLoadedDel.DelimitedText := slLoaded[i];
    _Signature := slLoadedDel[0];
    for k := TopCount to (slLoaded.Count - 1) do
    begin
      slLoadedDel.DelimitedText := slLoaded[k];
      for l := 0 to (slLoadedDel.Count - 1) do
      begin
        if slLoadedDel[l] = _Signature then
        begin
          Inc(Counter);
        end;
      end;
    end;
    if Counter = 1 then
    begin
      slLoaded.Move(i, (slLoaded.Count - 1));
      Dec(BottomCount);
    end;
  end;

  AddMessage('Processing');

  for m := 50  downto 1 do
  begin
    for i := BottomCount downto TopCount do
    begin
      slLoadedDel.DelimitedText := slLoaded[i];
      _Signature := slLoadedDel[0];
      for k := TopCount to BottomCount do
      begin
        slLoadedDel.DelimitedText := slLoaded[k];
        for l := 1 to (slLoadedDel.Count - 1) do
        begin
          if slLoadedDel[l] = _Signature then
          begin
            if i > k then slLoaded.Move(k, (i + 1));
          end;
        end;
      end;
    end;
    if m mod 5 = 0 then AddMessage('...');
  end;

//  AddMessage('..................................');
//  for i := 0 to (slLoaded.Count - 1) do
//    AddMessage(slLoaded[i]);
//  AddMessage('..................................');
//
//  for i := 1 to (slLoaded.Count - 1) do
//  begin
//    slLoadedDel.DelimitedText := slLoaded[i];
//    _Signature := slLoadedDel[0];
//    for k := (slLoaded.Count - 1) downto i do
//    begin
//      slLoadedDel.DelimitedText := slLoaded[k];
//      if slLoadedDel.Count = 1 then Continue;
//      for l := 1 to (slLoadedDel.Count - 1) do
//      begin
//        if slLoadedDel[l] = _Signature then
//          if i + 1 <> slLoaded.Count then
//            slLoaded.Move(k, (i + 1));
//      end;
//    end;
//  end;
//  for i := 0 to (slLoaded.Count - 1) do
//    AddMessage(slLoaded[i]);
  filename := '__ReferenceOrderSorted.csv';
  filename := ProgramPath + 'ElementConverions\' + filename;
  if slLoaded.Count > 1 then
  begin
    slLoaded.Delete(0);
    AddMessage('Saving ' + filename);
    slLoaded.SaveToFile(filename);
  end;
  slLoaded.Free;
  slLoadedDel.Free;
	Result := 0;
end;

end.