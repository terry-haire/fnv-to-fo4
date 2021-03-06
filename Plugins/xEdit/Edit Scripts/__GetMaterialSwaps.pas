unit __GetMaterialSwaps;


interface
implementation
uses xEditAPI, Classes, SysUtils, StrUtils, Windows; //Remove before use in xEdit

var
slvalues, slNifs, sl3DNames: TStringList;

{
Paths

Female biped model\MO3S\Alternate Texture\New Texture
Male biped model\MODS\Alternate Texture\New Texture
Male biped model\MODS\Alternate Texture\New Texture
Male world model\MO2S\Alternate Texture\New Texture
Model\MODS\Alternate Texture\New Texture
}

procedure Recursive(e: IInterface);
var
i: integer;
ielement, _TXST: IInterface;
s: String;
begin
	for i := 0 to (ElementCount(e)-1) do
	begin
		ielement := ElementByIndex(e, i);
    if Name(ielement) = 'Alternate Texture' then
    begin
      if Assigned(ElementByPath(ielement, '3D Name')) then
      begin
        s := GetEditValue(ElementByIndex(GetContainer(GetContainer(ielement)), 0));
        if LastDelimiter('.', s) <> (Length(s) - 3) then s := '';
        slNifs.Add(s);
        _TXST := LinksTo(ElementByPath(ielement, 'New Texture'));
        s := s + ';' + GetElementEditValues(_TXST, 'EDID')
        + ';' + GetElementEditValues(ielement, '3D Name')
        + ';' + GetElementEditValues(_TXST, 'Textures (RGB/A)\TX00')
        + ';' + GetElementEditValues(_TXST, 'Textures (RGB/A)\TX01')
        + ';' + GetElementEditValues(_TXST, 'Textures (RGB/A)\TX02')
        + ';' + GetElementEditValues(_TXST, 'Textures (RGB/A)\TX03')
        + ';' + GetElementEditValues(_TXST, 'Textures (RGB/A)\TX04')
        + ';' + GetElementEditValues(_TXST, 'Textures (RGB/A)\TX05') + ';';
        if Assigned(ElementByPath(_TXST, 'DNAM\No Specular Map')) then
          s := s + 'No Specular Map';
        slvalues.Add(s);
        sl3DNames.Add(GetElementEditValues(ielement, '3D Name'));
      end;
    end;
		if ElementCount(ielement) > 0 then Recursive(ielement);
	end;
end;

function Initialize: integer;
begin
  slvalues := TStringList.Create;
  slNifs := TStringList.Create;
  sl3DNames := TStringList.Create;
  Result := 0;
end;

function Process(e: IInterface): integer;
begin
  Recursive(e);
	Result := 0;
end;

function Finalize: integer;
var
i: Integer;
begin
  for i := 0 to (slvalues.Count - 1) do
    AddMessage(slvalues[i]);
  slvalues.SaveToFile(ProgramPath + 'ElementConverions\MaterialSwaps.csv');
  slNifs.SaveToFile(ProgramPath + 'ElementConverions\MaterialSwapsNifs.csv');
  sl3DNames.SaveToFile(ProgramPath + 'ElementConverions\MaterialSwaps3Names.csv');
  slvalues.Free;
  slNifs.Free;
  sl3DNames.Free;
	Result := 0;
end;

end.