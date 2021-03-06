unit __FNVMultiLoop;

var
NPCList, 
NPCListprev, 
slWRLD,
slCELL,
slREFR,
slACHR,
slACRE,
slLAND,
slNAVM,
slDIAL, 
slINFO, 
slfilelist: TStringList;

k: integer;

rec: IInterface;

nameslWRLD,
nameslCELL,
nameslREFR,
nameslACHR,
nameslACRE,
nameslLAND,
nameslNAVM,
nameslDIAL, 
nameslINFO, 
loadordername, 
grupname: String;

{ Not Used
function filerename(filename, grupname: String; j: integer): String;
var
j: integer;
begin
	if FileExists(filename) then
	begin
		//filename:= (copy(filename, 1, LastDelimiter('_', filename)) + IntToStr(1 + StrToInt(copy(filename, (LastDelimiter('_', filename) + 1), (LastDelimiter('.csv', filename) - LastDelimiter('_', filename) - 1))));
		j := j + 1;
		filename := (ProgramPath + 'data\' + GetFileName(rec) + '_' + grupname + '_' + IntToStr(j) + '.csv');
		AddMessage(filename);
		filename := filerename(filename, grupname, j);
		Result := filename;
	end;
	//else Result := filename;
end;
}

procedure MergeStrings(Dest, Source: TStrings) ; //order is wrong works
var j : integer;
begin
   for j := 0 to -1 + Source.Count do
     if Dest.IndexOf(Source[j]) = -1 then
       Dest.Add(Source[j]) ;
end;

procedure finalsavelist(finalfilenametosave: String; slListToSave: TStringList);
begin
		AddMessage('Saving list to ' + finalfilenametosave);
		if not FileExists(finalfilenametosave) then slfilelist.Add(stringreplace(finalfilenametosave, (ProgramPath + 'data\'), '', [rfReplaceAll]));
		slListToSave.SaveToFile(finalfilenametosave);
end;

function getfilenamestring(filename2: String): String;
var
i: integer;
newfilename: String;
begin
	i := 0;
	newfilename := (filename2 + '0.csv');
	while FileExists(newfilename) do
	begin
		i := i + 1;
		newfilename := (filename2 + IntToStr(i) + '.csv');
	end;
	Result := newfilename;
end;


function savelist(rec: IInterface; k: integer; grupname: String): integer;
var
i: integer;
filename, finalfilename, tempstring: String;
begin
	filename := (ProgramPath + 'data\' + GetFileName(rec) + '_' + 'LoadOrder_' + IntToHex(GetLoadOrder(GetFile(rec)), 2) + '_' + 'GRUP' + '_' + grupname + '_');
	finalfilename := (filename + '0.csv');
	//filename := filerename(filename, grupname, 0);
	finalfilename := getfilenamestring(filename);
	if grupname = 'DIAL' then
	begin
		if (slDIAL.Count + NPCList.Count) < 5001 then 
		begin
			MergeStrings(slDIAL, NPCList);
			Result := 0;
			nameslDIAL := filename;
			if ((k = 1) OR (k = 2)) then
			begin
				finalsavelist(finalfilename, slDIAL);
				slDIAL.Clear;
			end;
		end
		else
		begin
			nameslDIAL := filename;
			finalsavelist(getfilenamestring(filename), slDIAL);
			slDIAL.Clear;			
			MergeStrings(slDIAL, NPCList);
		end;		
	end
	else if grupname = 'INFO' then
	begin
		if (slINFO.Count + NPCList.Count) < 5001 then 
		begin
			MergeStrings(slINFO, NPCList);
			Result := 0;
			nameslINFO := filename;
			if ((k = 1) OR (k = 2)) then
			begin
				finalsavelist(finalfilename, slINFO);
				slINFO.Clear;
			end;
		end
		else
		begin
			nameslINFO := filename;
			finalsavelist(getfilenamestring(filename), slINFO);
			slINFO.Clear;			
			MergeStrings(slINFO, NPCList);
		end;		
	end
	else if grupname = 'WRLD' then
	begin
		if (slWRLD.Count + NPCList.Count) < 5001 then 
		begin
			MergeStrings(slWRLD, NPCList);
			Result := 0;
			nameslWRLD := filename;
			if ((k = 1) OR (k = 2)) then
			begin
				finalsavelist(finalfilename, slWRLD);
				slWRLD.Clear;
			end;
		end
		else
		begin
			nameslWRLD := filename;
			finalsavelist(getfilenamestring(filename), slWRLD);
			slWRLD.Clear;			
			MergeStrings(slWRLD, NPCList);
		end;		
	end
	else if grupname = 'CELL' then
	begin
		if (slCELL.Count + NPCList.Count) < 5001 then 
		begin
			MergeStrings(slCELL, NPCList);
			Result := 0;
			nameslCELL := filename;
			if ((k = 1) OR (k = 2)) then
			begin
				finalsavelist(finalfilename, slCELL);
				slCELL.Clear;
			end;
		end
		else
		begin
			nameslCELL := filename;
			finalsavelist(getfilenamestring(filename), slCELL);
			slCELL.Clear;			
			MergeStrings(slCELL, NPCList);
		end;		
	end
	else if grupname = 'REFR' then
	begin
		if (slREFR.Count + NPCList.Count) < 5001 then 
		begin
			MergeStrings(slREFR, NPCList);
			Result := 0;
			nameslREFR := filename;
			if ((k = 1) OR (k = 2)) then
			begin
				finalsavelist(finalfilename, slREFR);
				slREFR.Clear;
			end;
		end
		else
		begin
			nameslREFR := filename;
			finalsavelist(getfilenamestring(filename), slREFR);
			slREFR.Clear;			
			MergeStrings(slREFR, NPCList);
		end;		
	end
	else if grupname = 'ACHR' then
	begin
		if (slACHR.Count + NPCList.Count) < 5001 then 
		begin
			MergeStrings(slACHR, NPCList);
			Result := 0;
			nameslACHR := filename;
			if ((k = 1) OR (k = 2)) then
			begin
				finalsavelist(finalfilename, slACHR);
				slACHR.Clear;
			end;
		end
		else
		begin
			nameslACHR := filename;
			finalsavelist(getfilenamestring(filename), slACHR);
			slACHR.Clear;			
			MergeStrings(slACHR, NPCList);
		end;		
	end
	else if grupname = 'ACRE' then
	begin
		if (slACRE.Count + NPCList.Count) < 5001 then 
		begin
			MergeStrings(slACRE, NPCList);
			Result := 0;
			nameslACRE := filename;
			if ((k = 1) OR (k = 2)) then
			begin
				finalsavelist(finalfilename, slACRE);
				slACRE.Clear;
			end;
		end
		else
		begin
			nameslACRE := filename;
			finalsavelist(getfilenamestring(filename), slACRE);
			slACRE.Clear;			
			MergeStrings(slACRE, NPCList);
		end;		
	end
	else if grupname = 'LAND' then
	begin
		if (slLAND.Count + NPCList.Count) < 5001 then 
		begin
			MergeStrings(slLAND, NPCList);
			Result := 0;
			nameslLAND := filename;
			if ((k = 1) OR (k = 2)) then
			begin
				finalsavelist(finalfilename, slLAND);
				slLAND.Clear;
			end;
		end
		else
		begin
			nameslLAND := filename;
			finalsavelist(getfilenamestring(filename), slLAND);
			slLAND.Clear;			
			MergeStrings(slLAND, NPCList);
		end;		
	end
	else if grupname = 'NAVM' then
	begin
		if (slNAVM.Count + NPCList.Count) < 5001 then 
		begin
			MergeStrings(slNAVM, NPCList);
			Result := 0;
			nameslNAVM := filename;
			if ((k = 1) OR (k = 2)) then
			begin
				finalsavelist(finalfilename, slNAVM);
				slNAVM.Clear;
			end;
		end
		else
		begin
			nameslNAVM := filename;
			finalsavelist(getfilenamestring(filename), slNAVM);
			slNAVM.Clear;			
			MergeStrings(slNAVM, NPCList);
		end;		
	end
	else
	begin
		if FileExists(filename + IntToStr(i - 1) + '.csv') then 
		begin
			NPCListprev.LoadFromFile(filename + IntToStr(i - 1) + '.csv');
			if (NPCListprev.Count + NPCList.Count) < 5001 then
			begin
				MergeStrings(NPCList, NPCListprev);
				finalfilename := (filename + IntToStr(i - 1) + '.csv');
			end;
		end;
		finalsavelist(finalfilename, NPCList);
	end;
	if ((k = 1) OR (k = 2)) then begin
		if slDIAL.Count > 0 then finalsavelist(getfilenamestring(nameslDIAL), slDIAL);
		slDIAL.Clear;
		if slINFO.Count > 0 then finalsavelist(getfilenamestring(nameslINFO), slINFO);
		slINFO.Clear;
		if slWRLD.Count > 0 then finalsavelist(getfilenamestring(nameslWRLD), slWRLD);
		slWRLD.Clear;
		if slCELL.Count > 0 then finalsavelist(getfilenamestring(nameslCELL), slCELL);
		slCELL.Clear;
		if slREFR.Count > 0 then finalsavelist(getfilenamestring(nameslREFR), slREFR);
		slREFR.Clear;
		if slACHR.Count > 0 then finalsavelist(getfilenamestring(nameslACHR), slACHR);
		slACHR.Clear;
		if slACRE.Count > 0 then finalsavelist(getfilenamestring(nameslACRE), slACRE);
		slACRE.Clear;
		if slLAND.Count > 0 then finalsavelist(getfilenamestring(nameslLAND), slLAND);
		slLAND.Clear;
		if slNAVM.Count > 0 then finalsavelist(getfilenamestring(nameslNAVM), slNAVM);
		slNAVM.Clear;
	end;
		NPCList.Clear;
		NPCListprev.Clear;
end;

//function Recursive(e: IInterface; i: integer; slstring: String): String;
//var
//j: integer;
//begin
//	j := i;
//	if i < (ElementCount(e)-1) then
//	for i := j to (ElementCount(e)-1) do 
//	begin 
//		//AddMessage('Element Count is ' + IntToStr(ElementCount(e)));
//		//AddMessage('i = ' + IntToStr(i));
//		//AddMessage(path(ElementByIndex(e, i)));
//		if Signature((ElementByIndex(e, i))) <> 'SCTX' then
//		slstring := (slstring + ';' + path(ElementByIndex(e, i)){ + ';' + IntToStr(ElementCount(ElementByIndex(e, i)))} + ';' + GetEditValue(ElementByIndex(e, i)));
//		//AddMessage(slstring);
//		//AddMessage(GetEditValue(ElementByIndex(e, i)));
//		if ElementCount((ElementByIndex(e, i))) > 0 then slstring := (Recursive(ElementByIndex(e, i), 0, slstring));
//	end;
//	Result := slstring;
//end;

function Recursive(e: IInterface; slstring: String): String;
var
i: integer;
ielement: IInterface;
begin
	for i := 0 to (ElementCount(e)-1) do 
	begin 
		ielement := ElementByIndex(e, i);
		if ansipos(#13#10, GetEditValue(ielement)) = 0 then
		slstring := (slstring + ';' + path(ielement){ + ';' + IntToStr(ElementCount(ielement))} + ';' + GetEditValue(ielement) + ';' + IntToStr(i) + ';' + IntToStr((ElementType(ielement))))
		else slstring := (slstring + ';' + path(ielement){ + ';' + IntToStr(ElementCount(ielement))} + ';' + stringreplace(stringreplace(GetEditValue(ielement), #13#10, '\r\n', [rfReplaceAll]), ';' , '\comment\', [rfReplaceAll]) + ';' + IntToStr(i) + ';' + IntToStr((ElementType(ielement))));
		if ElementCount(ielement) > 0 then slstring := (Recursive(ielement, slstring));
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

//Recursive(e, true);
function Initialize: integer;
begin
	NPCList := TStringList.Create;
	NPCListprev := TStringList.Create;
	slWRLD := TStringList.Create;
	slCELL := TStringList.Create;
	slREFR := TStringList.Create;
	slACHR := TStringList.Create;
	slACRE := TStringList.Create;
	slLAND := TStringList.Create;
	slNAVM := TStringList.Create;
	slDIAL := TStringList.Create;
	slINFO := TStringList.Create;
	slfilelist := TStringList.Create;
	k := 1
end;
	
function Process(e: IInterface): integer;
var
i, j{, k}: integer;
slstring: String;
begin
	// Compare to previous record
	if (Assigned(rec) AND (Signature(e) <> grupname) AND (NPCList.Count > 0)) then savelist(rec, 0, grupname);
	if (Assigned(rec) AND (loadordername <> GetFileName(e))) then 
	begin
		AddMessage('Went To Different File');
		if NPCList.Count > 0 then savelist(rec, 1, grupname);
		rec := Nil;
		loadordername := GetFileName(e);
	end;
	// Compare to previous record
	slstring := (IntToStr(GetLoadOrderFormID(e)) + ';' + IntToStr(ReferencedByCount(e)));
	rec := e;
	loadordername := GetFileName(rec);
	grupname := Signature(rec);
	if Signature(e) <> 'NAVI' then NPCList.Add(Recursive(e, slstring)) else
	begin
		NPCList.Add(IntToStr(GetLoadOrderFormID(e)));
		NPCList.Add(IntToStr(ReferencedByCount(e)));
		AddMessage('Yes');
		RecursiveNAVI(e, NPCList);
		savelist(rec, 0, grupname);
	end;
	if NPCList.Count > 4999 then savelist(rec, 0, grupname);
end;

function Finalize: integer;
begin
	AddMessage('Finalizing......');
	if NPCList.Count > 0 then savelist(rec, 2, grupname);
	NPCList.Free;
	//NPCListprev.Free;
	slfilelist.SaveToFile(ProgramPath + 'data\' + '_filelist.csv');
	slfilelist.Free;
	rec := Nil;
end;

end.