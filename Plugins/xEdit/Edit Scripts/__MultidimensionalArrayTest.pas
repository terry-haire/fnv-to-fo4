unit __MultidimensionalArrayTest;

interface
implementation
uses xEditAPI, Classes, SysUtils, StrUtils, Windows; //Remove before use in xEdit

function Initialize: integer;
var
  i : Integer;
  j : Integer;
  oSLArray : array of TStringList;
  oSL : TStringList;
  Signatures: TStringList;

begin
  oSL := TStringList.Create;
  oSL.LoadFromFile(ProgramPath + 'data\' + 'GunRunnersArsenal.esm_LoadOrder_01_GRUP_TXST_0.csv');
  SetLength(oSLArray, oSL.Count);
  for i := 0 to oSL.Count - 1 do begin
    oSLArray[i] := TStringList.Create;
    oSLArray[i].Delimiter := ';';
    oSLArray[i].StrictDelimiter := true;
    oSLArray[i].DelimitedText := oSL[i];
    for j := 0 to oSLArray[i].Count-1 do begin
      AddMessage(oSLArray[i].Strings[j] );
    end; {for j}
  end; {for i}
end;

function Process(e: IInterface): integer;
begin
	Result := 0;	
end;

function Finalize: integer;
begin
	Result := 0;
end;

end.