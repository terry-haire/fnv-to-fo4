unit __PrintElementOccurence;


interface
implementation
uses xEditAPI, Classes, SysUtils, StrUtils, Windows; //Remove before use in xEdit

var
slvalues: TStringList;
elementpath: String;

function Initialize: integer;
begin
  slvalues := TStringList.Create;
  elementpath := 'DATA\Unused';
	Result := 0;
end;

function Process(e: IInterface): integer;
var
i: Integer;
begin
  if Assigned(ElementByPath(e, elementpath)) then
  begin
    for i := 0 to slvalues.Count do
    begin
      if i = slvalues.Count then
        slvalues.Add(Signature(e));
      if slvalues[i] = Signature(e) then
        Break;
    end;
  end;
	Result := 0;
end;

function Finalize: integer;
var
i: Integer;
begin
  AddMessage(elementpath);
  for i := 0 to (slvalues.Count - 1) do
    AddMessage(slvalues[i]);
//  for i := 0 to (slvalues.Count - 1) do
//    AddMessage(IntToStr(StrToInt(slvalues[i]) * 60));
  slvalues.Free;
	Result := 0;
end;

end.