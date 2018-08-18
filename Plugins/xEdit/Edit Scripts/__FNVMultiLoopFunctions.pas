unit __FNVMultiLoopFunctions;

interface
uses xEditAPI, Classes, SysUtils, StrUtils, Windows; //Remove before use in xEdit

function Recursive2(e: IInterface; slstring: String): String;
function RecursiveNAVI(e: IInterface; NPCList: TStringList): TStringList;

implementation

function Recursive2(e: IInterface; slstring: String): String;
var
i: integer;
ielement: IInterface;
begin
	for i := 0 to (ElementCount(e)-1) do
	begin
		ielement := ElementByIndex(e, i);
		slstring := (slstring
//    stringreplace(
//     ,'"', '|CITATION|', [rfReplaceAll])
    + ';' + stringreplace(stringreplace(stringreplace(path(ielement), #13#10, '\r\n', [rfReplaceAll]), ';' , '\comment\', [rfReplaceAll]) ,'"', '|CITATION|', [rfReplaceAll])
    + ';' + stringreplace(stringreplace(stringreplace(GetEditValue(ielement), #13#10, '\r\n', [rfReplaceAll]), ';' , '\comment\', [rfReplaceAll]) ,'"', '|CITATION|', [rfReplaceAll])
    + ';' + IntToStr(i));
		if ElementCount(ielement) > 0 then slstring := (Recursive2(ielement, slstring));
	end;
	Result := slstring;
end;

function RecursiveNAVI(e: IInterface; NPCList: TStringList): TStringList;
var
i: integer;
ielement: IInterface;
begin
	for i := 0 to (ElementCount(e)-1) do
	begin
		ielement := ElementByIndex(e, i);
		NPCList.Add(path(ielement));
		NPCList.Add(GetEditValue(ielement));
		if ElementCount(ielement) > 0 then NPCList := (RecursiveNAVI(ielement, NPCList));
	end;
	Result := NPCList;
end;

end.
