unit __TEMPLATE;

function Initialize: integer;
begin
	Result := 0;
end;

function Process(e: IInterface): integer;
begin
	//Add(e, 'MODL', True);
	AddMessage(IntToStr(ElementCount(ElementByPath(e, 'Record Header\Record Flags'))));
	AddMessage(IntToStr(GetEditValue(ElementByPath(e, 'Record Header\Record Flags'))));
	//ElementAssign(ElementByPath(e, 'PRPS'), 2147483647, Nil, False);
	AddMessage(IntToStr(HighInteger));
	//Add(e, 'PRPS\Property', True);
	//AddMessage(Signature(ElementByPath(e, 'Model\MODL')));
	//AddMessage(DisplayName(ElementByPath(e, 'Model\MODL')));
	//AddMessage(Path(ElementByPath(e, 'Model\MODL')));
	//AddMessage(PathName(ElementByPath(e, 'Model\MODL')));
	//AddMessage(FullPath(ElementByPath(e, 'Model\MODL')));
	//AddMessage(Name(ElementByPath(e, 'Model\MODL')));
	//AddMessage(BaseName(ElementByPath(e, 'Model\MODL')));
	//AddMessage(ShortName(ElementByPath(e, 'Model\MODL')));
	Result := 0;	
end;

function Finalize: integer;
begin
	Result := 0;
end;

end.