unit __FindSignaturesandParentGroups;

var
slSignaturesandGRUPs: TStringList;

function Initialize: integer;
begin
	slSignaturesandGRUPs := TStringList.Create;
	slSignaturesandGRUPs.Add('Signature;GRUP');
end;

function Process(e: IInterface): integer;
var
i: integer;
begin
	for i := 0 to (slSignaturesandGRUPs.Count - 1) do
		if (Signature(e) + ';' + ShortName(GetContainer(e))) = slSignaturesandGRUPs[i] then Exit;
	slSignaturesandGRUPs.Add(Signature(e) + ';' + ShortName(GetContainer(e)));
	AddMessage(FullPath(e));
end;

function Finalize: integer;
var
i: integer;
begin
	for i := 0 to (slSignaturesandGRUPs.Count - 1) do
		AddMessage(slSignaturesandGRUPs[i]);
	slSignaturesandGRUPs.Free;
end;

end.