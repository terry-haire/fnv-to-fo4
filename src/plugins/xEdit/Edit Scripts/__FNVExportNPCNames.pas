unit UserScript;

var
  //String List---------------------------------------------------------------------------------------------------------------------------------
  slWeap
  : TStringList;
  DoExport: boolean;
function Initialize: integer;
var
  i: integer;
  // strings list with weapons data
begin
  Result := 0;
  slWeap 		:= TStringList.Create;
  begin
    // Export: add columns headers line
    slWeap.Add('Type;Name;FormID;Value;Weight;Damage;Speed;NPCs Use Ammo;CRDT\Damage;%Multi\Damage;VNAM');
  end;
end;


function Process(e: IInterface): integer;
var
ToFile: IInterface;
begin
		Result := 0;
		// use square brackets [] on formid to prevent Excel from treating them as a numbers
		if GetElementEditValues(e, 'ACBS\Flags\Female') = '1' then
		slWeap.Add(GetElementEditValues(e, 'FULL')
		+ ';'  + GetElementEditValues(e, 'EDID')
		+ ';'  + GetElementEditValues(e, 'RNAM')
		+ ';'  + 'Female')
		else
		slWeap.Add(GetElementEditValues(e, 'FULL')
		+ ';'  + GetElementEditValues(e, 'EDID')
		+ ';'  + GetElementEditValues(e, 'RNAM')
		+ ';'  + 'Male');
end;
	

function Finalize: integer;
var
  dlgSave: TSaveDialog;
begin
  Result := 0;
  
  if not Assigned(slWeap) then
    Exit;
    
  // save export file only if we have any data besides header line
  begin
    // ask for file to export to
    dlgSave := TSaveDialog.Create(nil);
    dlgSave.Options := dlgSave.Options + [ofOverwritePrompt];
    dlgSave.Filter := 'Spreadsheet files (*.csv)|*.csv';
    dlgSave.InitialDir := ProgramPath;
    dlgSave.FileName := 'weapons.csv';
    if dlgSave.Execute then
      slWeap.SaveToFile(dlgSave.FileName);
    dlgSave.Free;
  end;

  slWeap.Free;
 end;

end.