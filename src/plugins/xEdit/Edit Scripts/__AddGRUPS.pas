unit __AddGRUPS;

//function CreateRecord(k: IInterface; testring: String): IInterface;
//begin
//	k := Add(k, copy(testring, 1,4), True);
//	if ansipos('] \', testring) <> 0 then
//	begin
//		k := CreateRecord(k, copy(testring, (ansipos('] \', testring) - 
//	end;
//	Result := k;
//end;

function Initialize: integer;
begin
	Result := 0;
end;

function Process(e: IInterface): integer;
var
k: IInterface;
testring: String;

begin
	testring := '\ [00] Fallout4.esm \ [56] GRUP Top "WRLD" \ [1] GRUP World Children of Commonwealth "Commonwealth" [WRLD:0000003C] \ [12] GRUP Exterior Cell Block -2, 1 \ [0] GRUP Exterior Cell Sub-Block -8, 4 \ [21] GRUP Cell Children of [CELL:00016079] (in Commonwealth "Commonwealth" [WRLD:0000003C] at 37,-58) \ [0] GRUP Cell Temporary Children of [CELL:00016079] (in Commonwealth "Commonwealth" [WRLD:0000003C] at 37,-58) \ [0] [LAND:00017298]'
	if ansipos('GRUP Top "', testring) <> 0 then testring := copy(testring, (ansipos('GRUP Top "', testring) + 10), MaxInt);
	AddMessage(testring);
	k := GetFile(e);
	//k := CreateRecord(k, testring);
	k := Add(k, copy(testring, 1,4), True);
	if LastDelimiter('GRUP', testring) <> 0 then 
	begin
		testring := copy(testring, (LastDelimiter('GRUP', testring) + 4), MaxInt);
		testring := copy(testring, (ansipos('[', testring) + 1), 8);
		k := 
	end;
	Result := 0;
	AddMessage(FullPath(k));
	//k := ElementByIndex(k, 55);
	k := GroupBySignature(k, 'WRLD');
	AddMessage(FullPath(k));
	k := ElementByIndex(k, 0);
	AddMessage(IntToStr(GroupLabel(k)));
	AddMessage(IntToStr(GroupType(k)));
	AddMessage(FullPath(k));
	AddMessage(Signature(k));
	AddMessage(FullPath(e));
	//SetToDefault(k);
	//k := Add(k, 'Block -1,-1', True);
	k := Add(k, 'CELL', True); // That actually works but always adds new cell instead of selecting a cell
	k := Add(k, 'REFR', True); // Also Works
	//k := Add(k, 'WRLD', True);
	//k := ElementAssign(k, HighInteger, Nil, False);
	if Assigned(k) then AddMessage('True');
end;

function Finalize: integer;
begin
	Result := 0;
end;

end.