program NifMultiboundPatcher;

{$APPTYPE CONSOLE}

{$R *.res}

//uses
//  System.SysUtils, System.IOUtils, Vcl.Forms, Vcl.Dialogs, System.Classes;

uses
  System.SysUtils,
  System.IOUtils,
  System.UITypes,
  Winapi.Windows,
  Winapi.Messages,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  StrUtils,
  Types,
  Masks,
  IniFiles,
  aobFunctions in 'aobFunctions.pas';

type
  TForm1 = class(TForm)
    Button1: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
iLastPatternPos: Integer;

//implementation
//
//{$R *.dfm}

function ReplaceBytePattern(Data: TBytes; OldPattern: TBytes; NewPattern: TBytes; bFirstOnly: Boolean): TBytes;
var
i, j: Integer;
bMatch: Boolean;
begin
  Result := Data;
  for i := 0 to (Length(Data) - Length(OldPattern)) do
  begin
    if OldPattern[0] = Data[i] then
    begin
      bMatch := True;
      for j := i to (Length(OldPattern) - 1 + i) do
      begin
        if OldPattern[j - i] <> Data[j] then bMatch := False;
      end;
      if bMatch then
      begin
        Writeln('Match found at position: ' + IntToStr(i));
        SetLength(Result, (Length(Data) + (Length(NewPattern) - Length(OldPattern))));
        Move(Data[0], Result[0], (i + 1));
        Move(NewPattern[0], Result[i], Length(NewPattern));
        Move(Data[i + Length(OldPattern)], Result[i + Length(NewPattern)], (Length(Data) - i - Length(OldPattern)));
        iLastPatternPos := i;
        if bFirstOnly then Break;
      end;
    end;
  end;
end;

var
//Dllx: TBytes;
Data:ARRAY [0..27] OF Byte = ($00,$43,$00,$3A,$00,$5C,$00,$4D,$00,$53,$00,$31,$00,$30,$00,$30,$00,$34,$00,$36,$00,$2E,$00,$64,$00,$6C,$00,$6C);
Pattern:ARRAY [0..1] OF Byte = ($00,$30);
b, baSource, bytePattern, newbytePattern, bNew: TBytes;
i, j, OldSize, NewSize, vertCount : integer;
bConvert, bAddVertData: Boolean;

INI: TINIFile;

pBSMultiBoundNode,
pBSMultiBoundOBB,
pBSMulitBoundAABB,
pMultiBoundData,
pNameLand,
pNameLandCorrected,
pChunkDataOld,
pChunkDataNew,
PathRootSource,
PathRootDest,
PathSource,
PathDest,
sourceFile,
sBytes,
filename,
s,
fileType: String;

slFiles, slSourceFiles, slWorldSpaces, slDel: TStringList;
iMultiBoundDataPos, pos, pos2: Integer;
openDialog : topendialog;
self: TComponent;
//byteArray  : array of Byte;

begin
  try
    begin

      slFiles := TStringList.Create;
      slSourceFiles := TStringList.Create;
      slWorldSpaces := TStringList.Create;
      bConvert := False;

      case MessageDlg('Process Source?', mtConfirmation, [mbOK, mbCancel], 0) of
        mrOk:
          begin
          // Write code here for pressing button OK
            bConvert := True;
          end;
        mrCancel:
          begin
          // Write code here for pressing button Cancel
            begin
              // Create the open dialog object - assign to our open dialog variable
              openDialog := TOpenDialog.Create(self);

              // Set up the starting directory to be the current one
              openDialog.InitialDir := GetCurrentDir;

              // Allow multiple files to be selected - of any type
              openDialog.Options := [ofAllowMultiSelect];

              // Display the open file dialog
              if not openDialog.Execute
              then ShowMessage('Open file was cancelled')
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
            bConvert := False;
          end;
      end;

      { TODO -oUser -cConsole Main : Insert code here }
      if bConvert then
      begin
        INI := TINIFile.Create('C:\Users\' + GetEnvironmentVariable('USERNAME') + '\OneDrive\Projects\FNV_to_FO4\Profiles\' + GetEnvironmentVariable('COMPUTERNAME') + '\FNV_to_FO4.ini');
        PathRootSource := 'D:\Games\Fallout New Vegas\FNVExtracted\Data\';
        PathRootDest := 'D:\Games\Fallout New Vegas\FNVFo4 Converted\Data\';
        PathRootSource := INI.ReadString('USERPATHS', 'FNVExtracted', '');
        PathRootDest := INI.ReadString('USERPATHS', 'FNVConverted', '');
        PathSource := PathRootSource + 'meshes\landscape\lod\';
        slSourceFiles.LoadFromFile(PathRootDest + 'Meshes\Terrain\LODList.csv');
        slDel := TStringList.Create;
        slDel.Delimiter := ';';
        slDel.StrictDelimiter := True;

        Readln;
        for i := 0 to (slSourceFiles.Count - 1) do
        begin
          slDel.DelimitedText := slSourceFiles[i];
          if slDel.Count = 2 then
          begin
            slSourceFiles[i] := slDel[0];
            slFiles.Add(slDel[1]);
          end;
        end;
//        slSourceFiles := GetLODPaths(PathSource);
//        slWorldSpaces := GetWorldSpaces(PathSource);
////        slFiles := MyGetFiles(PathSource, '*.BTR;*.BTO');
//        for i := 0 to (slWorldSpaces.Count - 1) do
//          Writeln(slWorldSpaces[i]);
//        for i := 0 to (slSourceFiles.Count - 1) do
//          Writeln(slSourceFiles[i]);
////        Writeln(PathSource);
      end
      else
      begin
        PathRootSource := '';
        PathDest := 'C:\Temp\Bytes';
      end;

      pNameLand := '4C 61 6E 64 3A 30';
      pNameLandCorrected := '4C 61 6E 64';
      pBSMultiBoundNode := '42 53 4D 75 6C 74 69 42 6F 75 6E 64 4E 6F 64 65';
      pBSMultiBoundOBB := '0F 00 00 00 42 53 4D 75 6C 74 69 42 6F 75 6E 64 4F 42 42 00 00 01 00 02 00 03 00 04 00 05 00';
      pBSMulitBoundAABB := '10 00 00 00 42 53 4D 75 6C 74 69 42 6F 75 6E 64 41 41 42 42 00 00 01 00 02 00 03 00 04 00 05 00';
      pMultiBoundData :=
           '00 00 00 46' // Pos X
        + ' 00 00 00 46' // Pos Y
        + ' 00 80 BF 44' // Pos Z
        + ' 00 00 00 46' // Extent X
        + ' 00 00 00 46' // Extent Y
        + ' 00 00 05 44' // Extent Z
        + ' 01 00 00 00' //
        + ' 00 00 00 00' // All values Little Endian
      ;
      pChunkDataOld := '3C 00 00 00 04 00 00 00 57';
      pChunkDataNew := '18 00 00 00 04 00 00 00 57';

      for i := 0 to (slFiles.Count - 1) do
      begin
        filename := slFiles[i];
        if filename <> '' then
        begin
          Writeln('Processing ' + filename);
          fileType := Copy(filename, (Length(filename) - 3), 4);

          b := TFile.ReadAllBytes(filename);

          bytePattern := StringToByteArray(pBSMultiBoundOBB);
          newbytePattern := StringToByteArray(pBSMulitBoundAABB);
          b := ReplaceBytePattern(b, bytePattern, newbytePattern, True);

          if fileType = '.BTR' then
          begin
            newbytePattern := [$18];
            Move(newbytePattern[0], b[iLastPatternPos + $34], Length(newbytePattern));
            newbytePattern := [$04];
            Move(newbytePattern[0], b[iLastPatternPos + $49], Length(newbytePattern));

            bytePattern := StringToByteArray(pNameLand);
            newbytePattern := StringToByteArray(pNameLandCorrected);

            // Access violation sometimes
//            Writeln('HERE');
            b := ReplaceBytePattern(b, bytePattern, newbytePattern, True);
//            Readln;

            bytePattern := StringToByteArray(pChunkDataOld);
            newbytePattern := StringToByteArray(pChunkDataNew);
            b := ReplaceBytePattern(b, bytePattern, newbytePattern, True);
          end
          else
          begin
            // .BTO
            newbytePattern := [$18];
            Move(newbytePattern[0], b[iLastPatternPos + $3A], Length(newbytePattern));

            newbytePattern := [$03];
            Move(newbytePattern[0], b[iLastPatternPos + $3E], Length(newbytePattern));

            newbytePattern := [$03];
            Move(newbytePattern[0], b[iLastPatternPos + $42], Length(newbytePattern));

//            newbytePattern := [$03];
//            Move(newbytePattern[0], b[iLastPatternPos + $51], Length(newbytePattern));
            Writeln('pos = ' + IntToStr(iLastPatternPos + $51));

            sBytes := '0D 00 00 00 46 61 64 65 4E 6F 64 65 20 41 6E 69'
                   + ' 6D 05 00 00 00 6F 62 6A 3A 30 00 00 00 00';
            bytePattern := StringToByteArray(sBytes);
            sBytes := '00 00 00 00 02 00 00 00 3A 32';
            newbytePattern := StringToByteArray(sBytes);
            b := ReplaceBytePattern(b, bytePattern, newbytePattern, True);

            sBytes := '0F 41 0F 42 0F 42 0F 41 0F 43 0F 44 0F 45 0F 46'
                   + ' 0F 46 0F 45 0F 47 0F 48 0F 49 0F 4A 0F 4A 0F 49'
                   + ' 0F 4B 0F 4C 0F 4D 0F 4E 0F 4E 0F 4D 0F 4F 0F 50'
                   + ' 0F 51 0F 52 0F 52 0F 51 0F 53 0F 00 00 00 00 03';
            bytePattern := StringToByteArray(sBytes);
            sBytes := '0F 41 0F 42 0F 42 0F 41 0F 43 0F 44 0F 45 0F 46'
                   + ' 0F 46 0F 45 0F 47 0F 48 0F 49 0F 4A 0F 4A 0F 49'
                   + ' 0F 4B 0F 4C 0F 4D 0F 4E 0F 4E 0F 4D 0F 4F 0F 50'
                   + ' 0F 51 0F 52 0F 52 0F 51 0F 53 0F 00 00 00 00 01';
            newbytePattern := StringToByteArray(sBytes);
            b := ReplaceBytePattern(b, bytePattern, newbytePattern, True);

            sBytes := '3F FF FF FF FF 01 00 00 00 02 00 00 00 05 00 00'
                   + ' 00 00 00 00 00 02';
            bytePattern := StringToByteArray(sBytes);
            sBytes := '3F FF FF FF FF 01 00 00 00 02 00 00 00 05 00 00'
                   + ' 00 00 00 00 00 00';
            newbytePattern := StringToByteArray(sBytes);
            b := ReplaceBytePattern(b, bytePattern, newbytePattern, True);

//            Delete(b, b[iLastPatternPos + $51], $16);
//            Delete(b, b[350], 22);
//
//            // NiNode "obj" string
//            sBytes := '';
//            bytePattern := StringToByteArray(pNameLand);
//            newbytePattern := StringToByteArray(pNameLandCorrected);
//            b := ReplaceBytePattern(b, bytePattern, newbytePattern, True);
//
//            // BSSubIndexTriShape name
//            sBytes := '';
//            bytePattern := StringToByteArray(pNameLand);
//            newbytePattern := StringToByteArray(pNameLandCorrected);
//            b := ReplaceBytePattern(b, bytePattern, newbytePattern, True);
          end;

          newbytePattern := StringToByteArray(pMultiBoundData);
          if slSourceFiles.Count = slFiles.Count then
          begin
            sourceFile := slSourceFiles[i];
            baSource := TFile.ReadAllBytes(sourceFile);

            // Move Source Multibound data to byte pattern
            Move(baSource[Length(baSource) - Length(newbytePattern)], newbytePattern[0], (Length(newbytePattern)));

            if fileType = '.BTR' then
            begin
//              s := '';
//              for j := 0 to (Length(newbytePattern) - 1) do
//                s := s + ' ' + (IntToHex(newbytePattern[j], 2));
//              Writeln(s);

              // pos x = 8096, pos y = 8096
              sBytes := '00 00 00 46 00 00 00 46';
              bytePattern := StringToByteArray(sBytes);
              Move(bytePattern[0], newbytePattern[0], 8);

              // extent x = 8096, extent y = 8096
              sBytes := '00 00 00 46 00 00 00 46';
              bytePattern := StringToByteArray(sBytes);
              Move(bytePattern[0], newbytePattern[12], 8);
            end;

            PathDest := filename.Insert(Length(PathRootDest), 'PatchedLOD\');
            Writeln(PathDest);
            ForceDirectories(ExtractFilePath(PathDest));
//            readln;
          end;
          iMultiBoundDataPos := (Length(b) - 68);
          if iMultiBoundDataPos > 0 then
          begin
            Writeln(IntToStr(Length(newbytePattern)));
            Writeln(IntToStr(Length(b)));
            Move(newbytePattern[0], b[iMultiBoundDataPos], Length(newbytePattern));
            Delete(b, (iMultiBoundDataPos + Length(newbytePattern)), MaxInt);
            Writeln(IntToStr(Length(b)));
          end;

          if fileType = '.BTR' then
          begin
            // Vertex Data Block Size
            // Multibound AABB
            sBytes := '42 53 4D 75 6C 74 69 42 6F 75 6E 64 41 41 42 42';
            bytePattern := StringToByteArray(sBytes);
            pos := GetAOBPos(bytePattern, b);

            // Vert Count
            s := IntToHex(b[pos + $11D], 2);
            s := IntToHex(b[pos + $11D + 1], 2) + s;
            s := '$' + s;
            vertCount := StrToInt(s);
            writeln(IntToStr(vertCount));

            // Vertex Flags
            bAddVertData := True;
            if b[pos + $116] = $30 then
             bAddVertData := False;

            if pos > 0 then pos := pos + $20;
            s := '';
            sBytes := '';
            SetLength(bytePattern, 4);
            Writeln(IntToStr(Length(bytePattern)));
            Move(b[pos], bytePattern[0], 4);
            Writeln(IntToStr(Length(bytePattern)));
            for j := 0 to 3 do
            begin
              s := IntToHex(b[pos + j], 2) + s;
            end;
            writeln(s);
            s := '$' + s;
            OldSize := StrToInt(s);
            NewSize := OldSize + vertCount*4;
            sBytes := (IntToHex(NewSize, 8));
            sBytes := sBytes + Copy(sBytes, 7, 2);
            sBytes := sBytes + ' ' + Copy(sBytes, 5, 2);
            sBytes := sBytes + ' ' + Copy(sBytes, 3, 2);
            sBytes := sBytes + ' ' + Copy(sBytes, 1, 2);
            sBytes := Copy(sBytes, 9, 11);
            newbytePattern := StringToByteArray(sBytes);
            Writeln(IntToStr(Length(bytePattern)));
            Writeln(IntToStr(Length(newbytePattern)));
            if bAddVertData = True then
              b := ReplaceBytePattern(b, bytePattern, newbytePattern, False);
            writeln(IntToStr(NewSize));


//            31540
//            Move(New Size, b[pos], 4);


            // Vertex Data
            sBytes := '02 00 00 00 00 10 00 00 75 14 00 00 69 12 06 0E 01 00 00';
            bytePattern := StringToByteArray(sBytes);
            pos := GetAOBPos(bytePattern, b);
            sBytes := '02 00 00 00 00 30 00 00 75 14 00 00 69 12 06 0E 01 00 00';
            newbytePattern := StringToByteArray(sBytes);
            b := ReplaceBytePattern(b, bytePattern, newbytePattern, True);
            pos := pos + Length(bytePattern);
//            bNew :=

            if bAddVertData = True then
            begin
              SetLength(bNew, (Length(b) + vertCount*4));
              Move(b[0], bNew[0], (pos));
              Move(b[pos + vertCount*8], bNew[pos + vertCount*12], (Length(b) - (pos + vertCount*8)));
              sBytes := '00 00 00 00';
              bytePattern := StringToByteArray(sBytes);
              SetLength(newbytePattern, 12);
              writeln(IntToStr((vertCount - 1)));
              for j := 0 to (vertCount - 1) do
              begin
//                writeln(IntToStr(pos + j * 8));
                Move(b[pos + j * 8], newbytePattern[0], 8);
                Move(bytePattern[0], newbytePattern[8], 4);
                Move(newbytePattern[0], bNew[pos + j * 12], Length(newbytePattern));
              end;
              SetLength(b, Length(bNew));
              Move(bNew[0], b[0], Length(bNew));
            end;

            // Shader Data
            sBytes := '00 00 00 00 02 00 00 00 00 00 00 00 FF FF FF FF'
                   + ' 00 10 40 80 01 00 00 00 00 00 00 00 00 00 00 00'
                   + ' 00 00 80 3F 00 00 80 3F 03 00 00 00 00 00 00 00'
                   + ' 00 00 00 00 00 00 00 00 00 00 80 3F 02 00 00 00'
                   + ' 00 00 00 00 00 00 80 3F 00 00 00 00'

                   // Glossiness
                   + ' CD CC CC 3D'

                   + ' 00 00 80 3F 00 00 80 3F 00 00 80 3F 00 00 80 3F'
                   + ' 00 00 00 00 FF FF 7F 7F 00 00 00 00 00 00 00 3F'
                   + ' 00 00 A0 40 00 00 80 BF 00 00 80 BF 00 00 80';
            bytePattern := StringToByteArray(sBytes);
            sBytes := '12 00 00 00 02 00 00 00 00 00 00 00 FF FF FF FF'
                   + ' 00 10 40 80 03 00 00 00 00 00 00 00 00 00 00 00'
                   + ' 00 00 80 3F 00 00 80 3F 03 00 00 00 00 00 00 00'
                   + ' 00 00 00 00 00 00 00 00 00 00 80 3F 02 00 00 00'
                   + ' 00 00 00 00 00 00 80 3F 00 00 00 00'

                   // Glossiness
                   + ' 00 00 00 00'

                   + ' 00 00 80 3F 00 00 80 3F 00 00 80 3F 00 00 80 3F'
                   + ' 00 00 00 00 FF FF 7F 7F 00 00 00 00 00 00 80 3F'
                   + ' 00 00 A0 40 00 00 80 BF 00 00 80 BF 00 00 80';
            newbytePattern := StringToByteArray(sBytes);
            b := ReplaceBytePattern(b, bytePattern, newbytePattern, True);

            // MultiboundAABB String
            sBytes := '42 53 4D 75 6C 74 69 42 6F 75 6E 64 41 41 42 42';
            bytePattern := StringToByteArray(sBytes);
            pos := GetAOBPos(bytePattern, b);
            bytePattern := StringToByteArray('05');
            Move(bytePattern[0], b[pos + $38], Length(bytePattern));
            //Unknown Int
            bytePattern := StringToByteArray('01');
            Move(bytePattern[0], b[pos + $A9], Length(bytePattern));
            bytePattern := StringToByteArray('0E');
            Move(bytePattern[0], b[pos + $B9], Length(bytePattern));
            bytePattern := StringToByteArray('40');
            Move(bytePattern[0], b[pos + $F0], Length(bytePattern));
            bytePattern := StringToByteArray('03 02');
            Move(bytePattern[0], b[pos + 273], Length(bytePattern));

            // Scale
            bytePattern := StringToByteArray('00 00 80 3F');
            Move(bytePattern[0], b[pos + $ED], Length(bytePattern));
          end
          else
          begin
            // BSFadeNode to NiNode
            sBytes := '0A 00 00 00 42 53 46 61 64 65 4E 6F 64 65';
            bytePattern := StringToByteArray(sBytes);
            sBytes := '06 00 00 00 4E 69 4E 6F 64 65';
            newbytePattern := StringToByteArray(sBytes);
            b := ReplaceBytePattern(b, bytePattern, newbytePattern, True);
//            pos := GetAOBPos(bytePattern, b);

            // Shader Data
            // FSF2 LOD Objects flag
            // String pointer
            sBytes := '03 00 00 00 00 00 00 00 FF FF FF FF 01 00 40 80'
                   + ' 01 00 00 00 00 00 00 00 00 00 00 00 00 00 80 3F'
                   + ' 00 00 80 3F 04 00 00 00 00 00 00 00 00 00 00 00'
                   + ' 00 00 00 00 00 00 80 3F 03';
            bytePattern := StringToByteArray(sBytes);
            sBytes := '01 00 00 00 00 00 00 00 FF FF FF FF 01 00 40 80'
                   + ' 05 00 00 00 00 00 00 00 00 00 00 00 00 00 80 3F'
                   + ' 00 00 80 3F 04 00 00 00 00 00 00 00 00 00 00 00'
                   + ' 00 00 00 00 00 00 80 3F 01';
            newbytePattern := StringToByteArray(sBytes);
            b := ReplaceBytePattern(b, bytePattern, newbytePattern, True);

            // NiNode Flags
            sBytes := 'FF FF FF FF 0E 40 00 20 00';
            bytePattern := StringToByteArray(sBytes);
            sBytes := 'FF FF FF FF 0E 00 00 00 00';
            newbytePattern := StringToByteArray(sBytes);
            b := ReplaceBytePattern(b, bytePattern, newbytePattern, True);

            // BSMultiboundNode
            // Flags
            // Unknown Int
            sBytes := 'FF FF FF FF 0E 00 00 20 00 00 00 00 00 00 00 00'
                   + ' 00 00 00 00 00 00 80 3F 00 00 00 00 00 00 00 00'
                   + ' 00 00 00 00 00 00 80 3F 00 00 00 00 00 00 00 00'
                   + ' 00 00 00 00 00 00 80 3F 00 00 80 3F FF FF FF FF'
                   + ' 01 00 00 00 02 00 00 00 05 00 00 00 00';
            bytePattern := StringToByteArray(sBytes);
            sBytes := 'FF FF FF FF 0E 00 00 00 00 00 00 00 00 00 00 00'
                   + ' 00 00 00 00 00 00 80 3F 00 00 00 00 00 00 00 00'
                   + ' 00 00 00 00 00 00 80 3F 00 00 00 00 00 00 00 00'
                   + ' 00 00 00 00 00 00 80 3F 00 00 80 3F FF FF FF FF'
                   + ' 01 00 00 00 02 00 00 00 05 00 00 00 01';
            newbytePattern := StringToByteArray(sBytes);
            b := ReplaceBytePattern(b, bytePattern, newbytePattern, True);

            // TriShape Flags
            sBytes := 'FF FF FF FF 18 00 00 00';
            bytePattern := StringToByteArray(sBytes);
            sBytes := 'FF FF FF FF 0E 00 00 00';
            newbytePattern := StringToByteArray(sBytes);
            b := ReplaceBytePattern(b, bytePattern, newbytePattern, True);

            // Convert to BSSubindexTriShape
            sBytes := '0A 00 00 00 42 53 54 72 69 53 68 61 70 65';
            bytePattern := StringToByteArray(sBytes);
            sBytes := '12 00 00 00 42 53 53 75 62 49 6E 64 65 78 54 72 69 53 68 61 70 65';
            newbytePattern := StringToByteArray(sBytes);
            b := ReplaceBytePattern(b, bytePattern, newbytePattern, True);

            // Multibound AABB
            sBytes := '42 53 4D 75 6C 74 69 42 6F 75 6E 64 41 41 42 42';
            bytePattern := StringToByteArray(sBytes);
            pos := GetAOBPos(bytePattern, b);
            pos := pos + $26;

            // BlockSize
            s := '';
            for j := 0 to 3 do
            begin
              s := IntToHex(b[pos + j], 2) + s;
            end;
            writeln(IntToStr(pos));
            writeln(s);
            s := '$' + s;
            OldSize := StrToInt(s);
            NewSize := OldSize + 12;
            sBytes := (IntToHex(NewSize, 8));
            sBytes := sBytes + Copy(sBytes, 7, 2);
            sBytes := sBytes + ' ' + Copy(sBytes, 5, 2);
            sBytes := sBytes + ' ' + Copy(sBytes, 3, 2);
            sBytes := sBytes + ' ' + Copy(sBytes, 1, 2);
            sBytes := Copy(sBytes, 9, 11);
            writeln(sBytes);
            newbytePattern := StringToByteArray(sBytes);
            Move(newbytePattern[0], b[pos], Length(newbytePattern));

            // BSSubindexTriShape Data
            sBytes := '01 00 00 00 00 00 00 00 FF FF FF FF 01 00 40 80';
            bytePattern := StringToByteArray(sBytes);
            sBytes := '00 00 00 00 00 00 00 00 00 00 00 00 01 00 00 00'
                   + ' 00 00 00 00 FF FF FF FF 01 00 40 80';
            newbytePattern := StringToByteArray(sBytes);
            b := ReplaceBytePattern(b, bytePattern, newbytePattern, True);

            // Multibound AABB pos
            sBytes := '42 53 4D 75 6C 74 69 42 6F 75 6E 64 41 41 42 42';
            bytePattern := StringToByteArray(sBytes);
            pos := GetAOBPos(bytePattern, b);
            pos := pos + $171 - 6;

            // BlockSize
            s := '';
            for j := 0 to 3 do
            begin
              s := IntToHex(b[pos + j], 2) + s;
            end;
            writeln(IntToStr(pos));
            writeln(s);
            s := '$' + s;
            OldSize := StrToInt(s);
            NewSize := OldSize*2;
            sBytes := (IntToHex(NewSize, 8));
            sBytes := sBytes + Copy(sBytes, 7, 2);
            sBytes := sBytes + ' ' + Copy(sBytes, 5, 2);
            sBytes := sBytes + ' ' + Copy(sBytes, 3, 2);
            sBytes := sBytes + ' ' + Copy(sBytes, 1, 2);
            sBytes := Copy(sBytes, 9, 11);
            writeln(sBytes);
            newbytePattern := StringToByteArray(sBytes);
            // Num Primitives Pos
            sBytes := '00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00'
                   + ' 01 00 00 00 00 00 00 00 FF FF FF FF 01 00 40 80';
            bytePattern := StringToByteArray(sBytes);
            pos := GetAOBPos(bytePattern, b);
            Move(newbytePattern[0], b[pos], Length(newbytePattern));




            // Segments.
            // New Block size is oldsize + 16 * number of segments.
            newbytePattern := StringToByteArray('10 00 00 00');
            Writeln('#####################################');
            Writeln(IntToStr(littleEndian(newbytePattern, 0)));
            if Length(baSource) <> 0 then
            begin
              sBytes := '01 00 00 00 02 00 00 00 FF FF FF FF 04 00 00 00'
                     + ' FF FF FF FF 00 00 00 00 00 00 00 00 00';
              bytePattern := StringToByteArray(sBytes);
              pos2 := GetAOBPos(bytePattern, baSource);
              // Number of segments (int32).
              pos2 := pos2 + Length(bytePattern);
              Move(baSource[pos2], newbytePattern[0], 4);
              NewSize := littleEndian(newbytePattern, 0);
              SetLength(bytePattern, 16 * NewSize);
              pos2 := pos2 + 4;
              for j := 0 to (NewSize - 1) do
              begin
                // Unknown Byte (1 byte)
                // Index (4 bytes)
                // Num Tris in Segment (4 bytes)

                // Start Index
                // Num Primitives
                // Parent Array Index
                // Num Sub Segments
                Move(baSource[pos2 + 9 * j + 1], bytePattern[16 * j], 4);
                Move(baSource[pos2 + 9 * j + 5], bytePattern[16 * j + 4], 4);
                Move(StringToByteArray('FF FF FF FF')[0], bytePattern[16 * j + 8], 4);
                Move(StringToByteArray('00 00 00 00')[0], bytePattern[16 * j + 12], 4);
              end;
            end;
            // Num Segments
            pos := pos + 4;
            Move(newbytePattern[0], b[pos], Length(newbytePattern));
            // Total Segments
            pos := pos + 4;
            Move(newbytePattern[0], b[pos], Length(newbytePattern));

            // Adjust file length to fit segments.
            pos := pos + 4;
            NewSize := 16 * littleEndian(newbytePattern, 0);
            SetLength(b, (Length(b) + NewSize));
            pos2 := pos + NewSize;
            Move(b[pos], b[pos2], (Length(b) - pos2));

            // Segment
            if Length(baSource) = 0 then
            begin
              sBytes := '00 00 00 00'  // Start Index
                     + ' 00 00 00 00'  // Num Primitives
                     + ' FF FF FF FF'  // Parent Array Index
                     + ' 00 00 00 00'; // Num Sub Segments
              newbytePattern := StringToByteArray(sBytes);
              j := pos;
              while (j < pos2) do
              begin
                Move(newbytePattern[0], b[j], Length(newbytePattern));
                j := j + 16;
              end;
            end
            else
            begin
              Move(bytePattern[0], b[pos], Length(bytePattern));
            end;

            // TriShape Block Size pos.
            sBytes := '42 53 4D 75 6C 74 69 42 6F 75 6E 64 41 41 42 42';
            bytePattern := StringToByteArray(sBytes);
            pos := GetAOBPos(bytePattern, b);
            pos := pos + $26;
            OldSize := littleEndian(b, pos);
            NewSize := NewSize - 16;
            Writeln(IntToStr(OldSize));
            Writeln(IntToStr(NewSize + OldSize));
            newbytePattern := littleEndianToByteArray(NewSize + OldSize);
            Move(newbytePattern[0], b[pos], Length(newbytePattern));




            // Multibound AABB
            sBytes := '42 53 4D 75 6C 74 69 42 6F 75 6E 64 41 41 42 42';
            bytePattern := StringToByteArray(sBytes);
            pos := GetAOBPos(bytePattern, b);
            pos := pos + $26;

            // BlockSize
            s := '';
            for j := 0 to 3 do
            begin
              s := IntToHex(b[pos + j], 2) + s;
            end;
            writeln(IntToStr(pos));
            writeln(s);
            s := '$' + s;
            OldSize := StrToInt(s);
            NewSize := OldSize + 16;
            sBytes := (IntToHex(NewSize, 8));
            sBytes := sBytes + Copy(sBytes, 7, 2);
            sBytes := sBytes + ' ' + Copy(sBytes, 5, 2);
            sBytes := sBytes + ' ' + Copy(sBytes, 3, 2);
            sBytes := sBytes + ' ' + Copy(sBytes, 1, 2);
            sBytes := Copy(sBytes, 9, 11);
            writeln(sBytes);
            newbytePattern := StringToByteArray(sBytes);
            Move(newbytePattern[0], b[pos], Length(newbytePattern));

            // Multibound AABB
            sBytes := '42 53 4D 75 6C 74 69 42 6F 75 6E 64 41 41 42 42';
            bytePattern := StringToByteArray(sBytes);
            pos := GetAOBPos(bytePattern, b);
            pos := pos + $171 - 6;


            sBytes := '00 00 00 00 00 00 00 00 00 00 00 00 01 00 00 00'
                   + ' 00 00 00 00 FF FF FF FF 01 00 40 80';
            bytePattern := StringToByteArray(sBytes);
            sBytes := '01 00 00 00 01 00 00 00 00 00 00 00'
                   + ' ' + IntToHex(b[pos + 0], 2)
                   + ' ' + IntToHex(b[pos + 1], 2)
                   + ' ' + IntToHex(b[pos + 2], 2)
                   + ' ' + IntToHex(b[pos + 3], 2)
                   + ' FF FF FF FF 00 00 00 00 00 00 00 00 01 00 00 00'
                   + ' 00 00 00 00 FF FF FF FF 01 00 40 80';
            newbytePattern := StringToByteArray(sBytes);
            b := ReplaceBytePattern(b, bytePattern, newbytePattern, True);


            // Alpha Property


            // Num blocks (unsigned int32)
            pos := $30;
            NewSize := littleEndian(b, pos) + 1;
            newbytePattern := littleEndianToByteArray(NewSize);
            Move(newbytePattern[0], b[pos], 4);


            // Num block types. (unsigned int 16);

            // Multibound AABB pos.
            sBytes := '42 53 4D 75 6C 74 69 42 6F 75 6E 64 41 41 42 42';
            bytePattern := StringToByteArray(sBytes);
            pos := GetAOBPos(bytePattern, b);
            pos2 := pos;

            pos := pos - $7D;
            SetLength(newbytePattern, 2);
            sBytes := '$' + IntToStr(b[pos]) + IntToStr(b[pos + 1]);
            NewSize := StrToInt(sBytes);
            OldSize := NewSize;
            NewSize := NewSize + 1;
            sBytes := IntToHex(NewSize, 4);
            sBytes.Insert(2, ' ');
            Writeln(sBytes);
            newbytePattern := StringToByteArray(sBytes);
            Move(newbytePattern[0], b[pos], Length(newbytePattern));


            // Block type (sized string).
            pos := pos2 + $10;
            sBytes := '0F 00 00 00 4E 69 41 6C 70 68 61 50 72 6F 70 65 72 74 79';
            newbytePattern := StringToByteArray(sBytes);
            NewSize := $13;
            SetLength(b, Length(b) + NewSize);
            Move(b[pos], b[pos + NewSize], Length(b) - (pos + NewSize));
            Move(newbytePattern[0], b[pos], Length(newbytePattern));


            // Block type index (signed int16).
            // Only patch the last byte.
            pos := pos2 + $30;
            NewSize := $2;
            SetLength(b, Length(b) + NewSize);
            Move(b[pos], b[pos + NewSize], Length(b) - (pos + NewSize));
            sBytes := '00 ' + IntToHex(OldSize, 2);
            newbytePattern := StringToByteArray(sBytes);
            Move(newbytePattern[0], b[pos], Length(newbytePattern));


            // Block Size (unsigned int32).
            pos := pos2 + $4C;
            NewSize := $4;
            SetLength(b, Length(b) + NewSize);
            Move(b[pos], b[pos + NewSize], Length(b) - (pos + NewSize));
            sBytes := '00 00 00 0F';
            newbytePattern := StringToByteArray(sBytes);
            Move(newbytePattern[0], b[pos], Length(newbytePattern));


            // NiAlphaProperty
            pos := Length(b) - $8;
            sBytes := 'FF FF FF FF 00 00 00 00 FF FF FF FF EC 12 80 01 00 00 00 00 00 00 00';
            newbytePattern := StringToByteArray(sBytes);
            SetLength(b, pos + Length(newbytePattern));
            Move(newbytePattern[0], b[pos], Length(newbytePattern));


            // TriShape BS Properties.
            pos := pos2 + 376;
            Writeln(IntToStr(pos));
            sBytes := '07 00 00 00';
            newbytePattern := StringToByteArray(sBytes);
            Move(newbytePattern[0], b[pos], Length(newbytePattern));

          end;

          // Write file
          if slSourceFiles.Count > 0 then
          begin
            TFile.WriteAllBytes(PathDest, b)
          end
          else
            TFile.WriteAllBytes((PathDest + '_' + IntToStr(i) + '.nif'), b);
          Writeln(PathDest);
        end;
      end;
      Writeln('Done');
      Readln;
    end;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
