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
    slWeap.Add('Header;FormID;EditorID;Model;Transform');
  end;
end;


function Process(e: IInterface): integer;
var
ToFile: IInterface;
begin
		Result := 0;
		// use square brackets [] on formid to prevent Excel from treating them as a numbers
		if GetElementEditValues(e, 'Model\MODL') = '' then Exit;
		slWeap.Add(GetElementEditValues(e, 'Model\MODL'));
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
    dlgSave.FileName := 'modelsonly.csv';
    if dlgSave.Execute then
      slWeap.SaveToFile(dlgSave.FileName);
    dlgSave.Free;
  end;

  slWeap.Free;
 end;

end.