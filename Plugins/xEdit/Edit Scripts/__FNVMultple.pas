unit __FNVMultiple;

{
PatrolData1(e)
}
function PatrolData1(e: IInterface): String;
var
  i: integer;
  kwda: IInterface;
begin
	//Result := TStringList.Create;
	kwda := ElementByPath(e, 'Patrol Data\Embedded Script\Local Variables'); //Patrol Data 1
	Result := (IntToStr(ElementCount(kwda)));
	Result := Result + ';Patrol Data\Embedded Script\Local Variables';
	if ElementCount(kwda) <> 0 then
	for i := 0 to ElementCount(kwda) - 1 do
	begin
		Result := (Result 
		+ ';SLSD\Index;' + (GetElementEditValues(ElementByIndex(kwda, i), 'SLSD\Index'))
		+ ';SLSD\Flags\IsLongOrShort;' + (GetElementEditValues(ElementByIndex(kwda, i), 'SLSD\Flags\IsLongOrShort'))
		+ ';SCVR;' + (GetElementEditValues(ElementByIndex(kwda, i), 'SCVR')));
	end;
end;

{
PatrolData2(e)
}
function PatrolData2(e: IInterface): String;
var
  i: integer;
  kwda: IInterface;
begin
	//Result := TStringList.Create;
	kwda := ElementByPath(e, 'Patrol Data\Embedded Script\References'); //PatrolData2
	Result := (IntToStr(ElementCount(kwda)));
	Result := Result + ';Patrol Data\Embedded Script\References';
	if ElementCount(kwda) <> 0 then
	for i := 0 to ElementCount(kwda) - 1 do Result := (Result + ';Patrol Data\Embedded Script\References;' + (GetEditValue(ElementByIndex(kwda, i))));
end;

{
ReflectedRefractedBy(e)
}
function ReflectedRefractedBy(e: IInterface): String;
var
  i: integer;
  kwda: IInterface;
begin
	//Result := TStringList.Create;
	kwda := ElementByPath(e, 'Reflected/Refracted By'); //Reflected/Refracted By
	Result := (IntToStr(ElementCount(kwda)));
	Result := Result + ';Reflected/Refracted By';
	if ElementCount(kwda) <> 0 then
	for i := 0 to ElementCount(kwda) - 1 do
	begin
		Result := (Result
		+ ';Reference;' + (GetElementEditValues(ElementByIndex(kwda, i), 'Reference'))
		+ ';Type\Reflection;' + (GetElementEditValues(ElementByIndex(kwda, i), 'Type\Reflection'))
		+ ';Type\Refraction;' + (GetElementEditValues(ElementByIndex(kwda, i), 'Type\Refraction')));
	end;
end;

{
LitWater(e)
}
function LitWater(e: IInterface): String;
var
  i: integer;
  kwda: IInterface;
begin
	//Result := TStringList.Create;
	kwda := ElementByPath(e, 'Lit Water'); //LitWater
	Result := (IntToStr(ElementCount(kwda)));
	Result := Result + ';Lit Water';
	if ElementCount(kwda) <> 0 then
	for i := 0 to ElementCount(kwda) - 1 do Result := (Result + ';Lit Water;' + (GetEditValue(ElementByIndex(kwda, i))));
end;

{
LinkedDecals(e)
}
function LinkedDecals(e: IInterface): String;
var
  i: integer;
  kwda: IInterface;
begin
	//Result := TStringList.Create;
	kwda := ElementByPath(e, 'Linked Decals'); //Linked Decals
	Result := (IntToStr(ElementCount(kwda)));
	Result := Result + ';Linked Decals';
	if ElementCount(kwda) <> 0 then
	for i := 0 to ElementCount(kwda) - 1 do
	begin
		Result := (Result 
		+ ';Reference;' + (GetElementEditValues(ElementByIndex(kwda, i), 'Reference'))
		+ ';Unknown;' + (GetElementEditValues(ElementByIndex(kwda, i), 'Unknown')));
	end;
end;

{
ActivateParents(e)
}
function ActivateParents(e: IInterface): String;
var
  i: integer;
  kwda: IInterface;
begin
	//Result := TStringList.Create;
	kwda := ElementByPath(e, 'Activate Parents\Activate Parent Refs'); //ActivateParents
	Result := (IntToStr(ElementCount(kwda)));
	Result := Result + ';Activate Parents\Activate Parent Refs';
	if ElementCount(kwda) <> 0 then
	for i := 0 to ElementCount(kwda) - 1 do
	begin
		Result := (Result 
		+ ';Reference;' + (GetElementEditValues(ElementByIndex(kwda, i), 'Reference'))
		+ ';Delay;' + (GetElementEditValues(ElementByIndex(kwda, i), 'Delay')));
	end;
end;

{
RoomData(e)
}
function RoomData(e: IInterface): String;
var
  i: integer;
  kwda: IInterface;
begin
	//Result := TStringList.Create;
			kwda := ElementByPath(e, 'Room Data\Linked Rooms'); //RoomData
	Result := (IntToStr(ElementCount(kwda)));
	Result := Result + ';Room Data\Linked Rooms';
	if ElementCount(kwda) <> 0 then
	for i := 0 to ElementCount(kwda) - 1 do Result := (Result + ';Room Data\Linked Rooms;' + (GetEditValue(ElementByIndex(kwda, i))));
end;

{
NVPDDoors(e)
}
function NVPDDoors(e: IInterface): String;
var
  i: integer;
  kwda: IInterface;
begin
	//Result := TStringList.Create;
			kwda := ElementByPath(e, 'NVDP'); //NVPDDoors
	Result := (IntToStr(ElementCount(kwda)));
	Result := Result + ';NVDP';
	if ElementCount(kwda) <> 0 then
	for i := 0 to ElementCount(kwda) - 1 do
	begin
		Result := (Result 
		+ ';Reference;' + (GetElementEditValues(ElementByIndex(kwda, i), 'Reference'))
		+ ';Triangle;' + (GetElementEditValues(ElementByIndex(kwda, i), 'Triangle')));
	end;
end;

{
NVEXExtCon(e)
}
function NVEXExtCon(e: IInterface): String;
var
  i: integer;
  kwda: IInterface;
begin
	//Result := TStringList.Create;
			kwda := ElementByPath(e, 'NVEX'); //NVEXExtCon
	Result := (IntToStr(ElementCount(kwda)));
	Result := Result + ';NVEX';
	if ElementCount(kwda) <> 0 then
	for i := 0 to ElementCount(kwda) - 1 do
	begin
		Result := (Result 
		+ ';Unknown;' + (GetElementEditValues(ElementByIndex(kwda, i), 'Unknown'))
		+ ';Navigation Mesh;' + (GetElementEditValues(ElementByIndex(kwda, i), 'Navigation Mesh'))
		+ ';Triangle;' + (GetElementEditValues(ElementByIndex(kwda, i), 'Triangle')));
	end;
end;

{
LANDLayers(e)
}
function LANDLayers(e: IInterface): String;
var
  i: integer;
  kwda: IInterface;
begin
	//Result := TStringList.Create;
			kwda := ElementByPath(e, 'Layers'); //LANDLayers
	Result := (IntToStr(ElementCount(kwda)));
	Result := Result + ';Layers';
	if ElementCount(kwda) <> 0 then
	for i := 0 to ElementCount(kwda) - 1 do
	begin
		Result := (Result 
		+ ';BTXT\Texture;' + (GetElementEditValues(ElementByIndex(kwda, i), 'BTXT\Texture'))
		+ ';BTXT\Quadrant;' + (GetElementEditValues(ElementByIndex(kwda, i), 'BTXT\Quadrant'))
		+ ';BTXT\Layer;' + (GetElementEditValues(ElementByIndex(kwda, i), 'BTXT\Layer'))
		+ ';VTXT;' + (GetElementEditValues(ElementByIndex(kwda, i), 'VTXT')));
	end;
end;

{
LandVTEX(e)
}
function LandVTEX(e: IInterface): String;
var
  i: integer;
  kwda: IInterface;
begin
	//Result := TStringList.Create;
			kwda := ElementByPath(e, 'VTEX'); //LandVTEX
	Result := (IntToStr(ElementCount(kwda)));
	Result := Result + ';VTEX';
	if ElementCount(kwda) <> 0 then
	for i := 0 to ElementCount(kwda) - 1 do Result := (Result + ';VTEX;' + (GetEditValue(ElementByIndex(kwda, i))));
end;

{
SwappedImpacts(e)
}
function SwappedImpacts(e: IInterface): String;
var
  i: integer;
  kwda: IInterface;
begin
	//Result := TStringList.Create;
			kwda := ElementByPath(e, 'Swapped Impacts'); //SwappedImpacts
	Result := (IntToStr(ElementCount(kwda)));
	Result := Result + ';Swapped Impacts';
	if ElementCount(kwda) <> 0 then
	for i := 0 to ElementCount(kwda) - 1 do
	begin
		Result := (Result 
		+ ';Material Type;' + (GetElementEditValues(ElementByIndex(kwda, i), 'Material Type'))
		+ ';Old;' + (GetElementEditValues(ElementByIndex(kwda, i), 'Old'))
		+ ';New;' + (GetElementEditValues(ElementByIndex(kwda, i), 'New')));
	end;
end;

{
CELLRegions(e)
}
function CELLRegions(e: IInterface): String;
var
  i: integer;
  kwda: IInterface;
begin
	//Result := TStringList.Create;
			kwda := ElementByPath(e, 'XCLR'); //CELLRegions
	Result := (IntToStr(ElementCount(kwda)));
	Result := Result + ';XCLR';
	if ElementCount(kwda) <> 0 then
	for i := 0 to ElementCount(kwda) - 1 do Result := (Result + ';XCLR;' + (GetEditValue(ElementByIndex(kwda, i))));
end;

{
function Process(e: IInterface): integer;
var
  i: integer;
  kwda: IInterface;
begin
	kwda := ElementByPath(e, 'Patrol Data\Embedded Script\Local Variables'); //Patrol Data 1
	if ElementCount(kwda) <> 0 then
	for i := 0 to ElementCount(kwda) - 1 do
	begin
		AddMessage(GetElementEditValues(ElementByIndex(kwda, i), 'SLSD\Index'));
		AddMessage(GetElementEditValues(ElementByIndex(kwda, i), 'SLSD\Flags\IsLongOrShort'));
		AddMessage(GetElementEditValues(ElementByIndex(kwda, i), 'SCVR'));
	end;
	
	kwda := ElementByPath(e, 'Patrol Data\Embedded Script\References'); //Patrol Data 2
	if ElementCount(kwda) <> 0 then
	for i := 0 to ElementCount(kwda) - 1 do AddMessage(GetEditValue(ElementByIndex(kwda, i)));
	
	kwda := ElementByPath(e, 'Reflected/Refracted By'); //Reflected/Refracted By
	if ElementCount(kwda) <> 0 then
	for i := 0 to ElementCount(kwda) - 1 do
	begin
		AddMessage(GetElementEditValues(ElementByIndex(kwda, i), 'Reference'));
		AddMessage(GetElementEditValues(ElementByIndex(kwda, i), 'Type\Reflection'));
		AddMessage(GetElementEditValues(ElementByIndex(kwda, i), 'Type\Refraction'));
	end;
	
	kwda := ElementByPath(e, 'Lit Water'); //Lit Water
	if ElementCount(kwda) <> 0 then
	for i := 0 to ElementCount(kwda) - 1 do AddMessage(GetEditValue(ElementByIndex(kwda, i)));
	
	kwda := ElementByPath(e, 'Linked Decals'); //Linked Decals
	if ElementCount(kwda) <> 0 then
	for i := 0 to ElementCount(kwda) - 1 do
	begin
		AddMessage(GetElementEditValues(ElementByIndex(kwda, i), 'Reference'));
		AddMessage(GetElementEditValues(ElementByIndex(kwda, i), 'Unknown'));
	end;
	
	kwda := ElementByPath(e, 'Activate Parents\Activate Parent Refs'); //Activate Parents
	if ElementCount(kwda) <> 0 then
	for i := 0 to ElementCount(kwda) - 1 do
	begin
		AddMessage(GetElementEditValues(ElementByIndex(kwda, i), 'Reference'));
		AddMessage(GetElementEditValues(ElementByIndex(kwda, i), 'Delay'));
	end;
	
	kwda := ElementByPath(e, 'Room Data\Linked Rooms'); //Room Data
	if ElementCount(kwda) <> 0 then
	for i := 0 to ElementCount(kwda) - 1 do AddMessage(GetEditValue(ElementByIndex(kwda, i)));
end;
}
end.