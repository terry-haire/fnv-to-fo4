unit __TEMPLATE;

function Initialize: integer;
begin
	Result := 0;
end;

function Process(e: IInterface): integer;
var
k: IInterface;
i: Integer;
begin
	Result := 0;	
	k := ElementByPath(e, 'ANAM');
	for i := 0 to 50 do
	begin
		SetEditValue(k, IntToStr(i));
		AddMessage(GetEditValue(k));
		AddMessage(IntToStr(i));
	end;
end;

function Finalize: integer;
begin
	Result := 0;
end;

end.