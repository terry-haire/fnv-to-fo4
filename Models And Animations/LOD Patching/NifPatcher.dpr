program NifPatcher;

{$APPTYPE CONSOLE}

{$R *.res}
uses
  System.SysUtils,
  System.IOUtils,
  Winapi.Windows,
  Winapi.Messages,
  System.Variants,
  System.Classes,
  System.UITypes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  StrUtils,
  Types,
  Masks,
  IniFiles,
  aobFunctions in 'aobFunctions.pas',
  Value in 'Value.pas',
  Block in 'Block.pas',
  Nif in 'Nif.pas',
  Header in 'Header.pas';

function processFile(bytes: TBytes): TBytes;
var
nif: TNif;
sBytes: String;
bytePattern: TBytes;
begin
  nif := TNif.Create(bytes);
  // NiTriStripsData
  sBytes := '0F 00 00 00 4E 69 54 72 69 53 74 72 69 70 73 44 61 74 61';
  bytePattern := StringToByteArray(sBytes);
  // NiMaterialProperty
  bytePattern := [$12, $00, $00, $00, $4E, $69, $4D, $61, $74, $65, $72, $69, $61, $6C, $50, $72, $6F, $70, $65, $72, $74, $79];
  // Need renumber blocks and their references
//  nif.Remove(195);
//  nif.Remove(194);
//  nif.Remove(193);

//  nif.Remove(11);
//  nif.Remove(10);
//  nif.Remove(9);
//  nif.Remove(8);
//  nif.Remove(7);
//  nif.Remove(6);

//  nif.Remove(192);
//  nif.Remove(191);

  nif.RemoveType(bytePattern);
  Result := nif.getData;
end;

procedure convertFiles(slFiles: TStringList);
var
pathSource,
pathDestination,
pathSourceRoot,
pathDestinationRoot,
newPath,
filePath:String;

slDel, slSourceFiles: TStringList;

INI: TIniFile;

bytes: TBytes;

i: Integer;
begin
  INI := TINIFile.Create('C:\Users\' + GetEnvironmentVariable('USERNAME') + '\OneDrive\Projects\FNV_to_FO4\Profiles\' + GetEnvironmentVariable('COMPUTERNAME') + '\FNV_to_FO4.ini');

  pathSource                      := 'D:\Games\Fallout New Vegas\FNVExtracted\Data\';
  pathDestination                 := 'D:\Games\Fallout New Vegas\FNVFo4 Converted\Data\';
  pathSourceRoot                  := INI.ReadString('USERPATHS', 'FNVExtracted', '');
  pathDestinationRoot             := INI.ReadString('USERPATHS', 'FNVConverted', '');

  if slFiles.Count = 0 then
  begin
    slSourceFiles := TStringList.Create;
    slSourceFiles.LoadFromFile(pathDestinationRoot + 'MeshList.csv');

    Readln;

    slDel := TStringList.Create;
    slDel.Delimiter := ';';
    slDel.StrictDelimiter := True;
    for i := 0 to (slSourceFiles.Count - 1) do
    begin
      slDel.DelimitedText := slSourceFiles[i];
      if slDel.Count = 2 then
      begin
        slSourceFiles[i] := slDel[0];
        slFiles.Add(slDel[1]);
      end;
    end;
  end;

  for filePath in slFiles do
  begin
    Writeln('Processing ' + filePath);
    bytes := TFile.ReadAllBytes(filePath);
    bytes := processFile(bytes);
    newPath := StringReplace(filePath, pathDestinationRoot, pathDestinationRoot + 'PatchedMeshed\', [rfIgnoreCase]);
    if newPath = filePath then
      newPath := 'C:\Temp\Bytes.nif';
    Writeln(newPath);
    readln;
    TFile.WriteAllBytes(newPath, bytes);
  end;
end;

var
bConvert: Boolean;
slFiles: TStringList;
openDialog : topendialog;
self: TComponent;
i: Integer;

begin
  try

    slFiles := TStringList.Create;
    bConvert := False;
    begin
      case MessageDlg('Process Source?', mtConfirmation, [mbOK, mbCancel], 0) of
        mrOk:
          begin
          // Write code here for pressing button OK
            bConvert := True;
          end;
        mrCancel:
          begin
          // Write code here for pressing button Cancel
            slFiles := TStringList.Create;

            // Create the open dialog object - assign to our open dialog variable
            openDialog := TOpenDialog.Create(self);

            // Set up the starting directory to be the current one
            openDialog.InitialDir := GetCurrentDir;

            // Allow multiple files to be selected - of any type
            openDialog.Options := [ofAllowMultiSelect];

            // Display the open file dialog
            if not openDialog.Execute then
              Writeln('Open file was cancelled')
            else
            begin
              // Display the selected file names
              for i := 0 to openDialog.Files.Count-1 do
                ShowMessage(openDialog.Files[i]);
            end;

            if openDialog.Files.Count > 0 then
              slFiles.AddStrings(openDialog.Files);

            // Free up the dialog
            openDialog.Free;
          end;
      end;
    end;

    if ((slFiles.Count > 0) or bConvert) then
    begin
      // Main
      convertFiles(slFiles);
    end
    else
      Writeln('No files to convert.');

    Writeln('Done');
    Readln;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.