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
  Header in 'Header.pas',
  Unit1 in 'blocks\Unit1.pas';

function processFile(bytes: TBytes; bytes2: TBytes): TBytes;
var
nif, nif2: TNif;
sBytes: String;
bytePattern, b2: TBytes;
template: TBlock;
begin
  nif := TNif.Create(bytes);
  nif2 := TNif.Create(bytes2);

  // Dummy node (Hopefully nothing has all the these flags)
  sBytes := 'FF FF FF FF 00 00 00 00 FF FF FF FF FF FF FF FF'
         + ' 00 00 00 00 00 00 00 00 00 00 00 00 00 00 80 3F'
         + ' 00 00 00 00 00 00 00 00 00 00 00 00 00 00 80 3F'
         + ' 00 00 00 00 00 00 00 00 00 00 00 00 00 00 80 3F'
         + ' 00 00 80 3F 00 00 00 00 FF FF FF FF 00 00 00 00'
         + ' 00 00 00 00';
  bytePattern := StringToByteArray(sBytes);
  b2 := [$06, $00, $00, $00, $4E, $69, $4E, $6F, $64, $65];
  template := TBlock.Create(bytePattern, b2, 130);

  // NiTriStripsData
  sBytes := '0F 00 00 00 4E 69 54 72 69 53 74 72 69 70 73 44 61 74 61';
  bytePattern := StringToByteArray(sBytes);
  nif.ReplaceTypeByTemplate(bytePattern, template, False, True);
  nif.RemoveType(bytePattern);
//  nif.ReplaceBlock(11, template);
  // NiAlphaProperty
  sBytes := '0F 00 00 00 4E 69 41 6C 70 68 61 50 72 6F 70 65 72 74 79';
  bytePattern := StringToByteArray(sBytes);
  nif.ReplaceTypeByTemplate(bytePattern, template, False, True);
  nif.RemoveType(bytePattern);
  // NiMaterialProperty
  sBytes := '12 00 00 00 4E 69 4D 61 74 65 72 69 61 6C 50 72 6F 70 65 72 74 79';
  bytePattern := StringToByteArray(sBytes);
  nif.ReplaceTypeByTemplate(bytePattern, template, False, True);
  nif.RemoveType(bytePattern);
  // BSShaderTextureSet
  sBytes := '12 00 00 00 42 53 53 68 61 64 65 72 54 65 78 74 75 72 65 53 65 74';
  bytePattern := StringToByteArray(sBytes);
  nif.ReplaceTypeByTemplate(bytePattern, template, False, True);
  nif.RemoveType(bytePattern);
  // BSShaderPPLightingProperty
  sBytes := '1A 00 00 00 42 53 53 68 61 64 65 72 50 50 4C 69 67 68 74 69 6E 67 50 72 6F 70 65 72 74 79';
  bytePattern := StringToByteArray(sBytes);
  nif.ReplaceTypeByTemplate(bytePattern, template, True, True);
  nif.RemoveType(bytePattern);
  // NiTriStrips
  sBytes := '0B 00 00 00 4E 69 54 72 69 53 74 72 69 70 73';
  bytePattern := StringToByteArray(sBytes);
  nif.ReplaceTypeByTemplate(bytePattern, template, True, True);
  nif.RemoveType(bytePattern);

//  nif.ReplaceBlockWithBranch(6, nif2.getBranch(2));


  // NiMaterialProperty

//  bytePattern := [$12, $00, $00, $00, $4E, $69, $4D, $61, $74, $65, $72, $69, $61, $6C, $50, $72, $6F, $70, $65, $72, $74, $79];

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

  Result := nif.getData;
end;

procedure convertFiles(slFiles: TStringList);
var
pathSource,
pathExports,
pathDestination,
newPath,
srcPath,
pathExportFile:String;

slDel, slSourceFiles: TStringList;

INI: TIniFile;

bytes, bytes2: TBytes;

i: Integer;
begin
  INI := TINIFile.Create('C:\Users\' + GetEnvironmentVariable('USERNAME') + '\OneDrive\Projects\FNV_to_FO4\Profiles\' + GetEnvironmentVariable('COMPUTERNAME') + '\FNV_to_FO4.ini');

  pathSource                      := INI.ReadString('USERPATHS', 'FNVExtracted', '') + 'meshes';
  pathExports                     := INI.ReadString('USERPATHS', 'FNVConverted', '') + 'meshes\new_vegas';
  pathDestination                 := INI.ReadString('USERPATHS', 'FNVConverted', '') + 'meshes\patched';

  for pathExportFile in slFiles do
  begin
    Writeln('Processing ' + pathExportFile);
    bytes := TFile.ReadAllBytes(pathExportFile);
    srcPath := StringReplace(pathExportFile, pathSource, pathExports, [rfIgnoreCase]);
    Writeln(srcPath);
    bytes2 := TFile.ReadAllBytes(srcPath);
    bytes := processFile(bytes, bytes2);
    newPath := StringReplace(pathExportFile, pathSource, pathDestination, [rfIgnoreCase]);
    Writeln(newPath);
    readln;

    if ForceDirectories(ExtractFilePath(newPath))then
      TFile.WriteAllBytes(newPath, bytes)
    else
    begin
      writeln('Create directory Failed!');
    end;
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
