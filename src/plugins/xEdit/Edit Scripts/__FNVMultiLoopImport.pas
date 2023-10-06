unit __FNVMultiLoopImport;

var
NPCList: TStringList;

function Recursive(e: IInterface; i: integer; slstring: String): String;
var
j: integer;
begin
	j := i;
	if i < (ElementCount(e)-1) then
	for i := j to (ElementCount(e)-1) do 
	begin 
		//AddMessage('Element Count is ' + IntToStr(ElementCount(e)));
		//AddMessage('i = ' + IntToStr(i));
		//AddMessage(path(ElementByIndex(e, i)));
		slstring := (slstring + ';' + path(ElementByIndex(e, i)) + ';' + IntToStr(ElementCount(ElementByIndex(e, i))) + ';' + GetEditValue(ElementByIndex(e, i)));
		//AddMessage(slstring);
		//AddMessage(GetEditValue(ElementByIndex(e, i)));
		if ElementCount((ElementByIndex(e, i))) > 0 then slstring := (Recursive(ElementByIndex(e, i), 0, slstring));
	end;
	Result := slstring;
end;

//Recursive(e, true);
function Initialize: integer;
begin
	NPCList := 		TStringList.Create;
	slstring := 	TStringList.Create;
end;
	
function Process(e: IInterface): integer;
var
i, j{, k}: integer;
slstring, filename: String;
begin
	NPCList.LoadFromFile(filename);
	filename := (ProgramPath + 'data\' + '1');
	AddMessage('Loading NPC list from ' + filename);
	slstring.Delimiter := ';';
	slstring.StrictDelimiter := true;
	for i := 0 to NPCList.Count do
	begin
		slstring.DelimitedText := NPCList[i];
		if Signature(e) = copy(slstring[1], 1, 4);  then for j := 0 to slstring.Count do
		begin
			
		end;
	end;
end;

function Finalize: integer;
begin
	NPCList.Free;
	slstring.Free;
end;

end.