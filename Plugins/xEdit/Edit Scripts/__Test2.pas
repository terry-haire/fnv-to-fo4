unit __TEMPLATE;

function GRUPTreeCreate(testring: String; sltree: TStringList): TStringList;
begin
	Result := TStringList.Create;
	Result := sltree;
	if ansipos('GRUP Top "', testring) <> 0 then 
	begin
		testring := copy(testring, (ansipos('GRUP Top "', testring) + 10), MaxInt);
		sltree.Add(copy(testring, 1, 4));
	end;
	if ansipos('GRUP', testring) <> 0 then
	begin
		testring := copy(testring, ansipos('GRUP', testring), MaxInt);
		if ((ansipos('[', testring) <> 0) AND (ansipos(']', testring) = (ansipos('[', testring) + 14))) then
		begin
			testring := copy(testring, (ansipos('[', testring) + 6), MaxInt);
			sltree.Add(copy(testring, 1, 8));
			Result := GRUPTreeCreate(testring, sltree);
		end
		else if ansipos('[', testring) <> 0	then
		begin
			testring := copy(testring, (ansipos(']', testring) + 1), MaxInt);
			Result := GRUPTreeCreate(testring, sltree);
		end;
	end;
end;

function Initialize: integer;
var
sltree: TStringList;
testring: String;
i: Integer;
ToFile: IInterface;

begin
	sltree := TStringList.Create;
	testring := '\ [00] Fallout4.esm \ [56] GRUP Top "WRLD" \ [1] GRUP World Children of Commonwealth "Commonwealth" [WRLD:0000003C] \ [12] GRUP Exterior Cell Block -2, 1 \ [0] GRUP Exterior Cell Sub-Block -8, 4 \ [21] GRUP Cell Children of [CELL:00016079] (in Commonwealth "Commonwealth" [WRLD:0000003C] at 37,-58) \ [0] GRUP Cell Temporary Children of [CELL:00016079] (in Commonwealth "Commonwealth" [WRLD:0000003C] at 37,-58) \ [0] [LAND:00017298]';
	sltree := GRUPTreeCreate(testring, sltree);
	//for i := 0 to sltree.Count - 1 do
	//	AddMessage(sltree[i]);
	ToFile := FileByIndex(2);
	AddMessage(sltree[(sltree.Count - 1)]);
	AddMessage(copy(sltree[(sltree.Count -1)], 1, 8));
	AddMessage(Name(ToFile));
	//ToFile := RecordByFormID(ToFile, StrToInt('$' + copy(sltree[(sltree.Count -1)], 1, 8)), True);
	ToFile := RecordByFormID(ToFile, StrToInt('$001079E9'), True);
	if Assigned(ToFile) then AddMessage('Assigned');
	AddMessage(Name(ToFile));
	AddMessage(Name(GetFile(ToFile)));
	AddMessage(IntToStr(GetLoadOrder(FileByIndex(2))));
	AddMessage(IntToHex(GetLoadOrder(FileByIndex(2)), 2));
	Result := 0;
end;

function Process(e: IInterface): integer;
var
k: IInterface;
begin
	Result := 0;	
end;

function Finalize: integer;
begin
	Result := 0;
end;

end.