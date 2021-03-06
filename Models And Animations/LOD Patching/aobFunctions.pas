unit aobFunctions;

interface

uses
  System.SysUtils,
  System.IOUtils,
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
  IniFiles;

function GetFiles2(const Path: String): TStringList;
function MyGetFiles(const Path, Masks: string): TStringList;
function GetLODPaths(const Path: String): TStringList;
function GetWorldSpaces(const Path: String): TStringList;
function StringToByteArray(const pattern: String): TBytes;
function GetAOBPos(Pattern: TBytes; Data: TBytes): Integer;
procedure printBytePattern(Pattern: TBytes);
procedure printBytePatternAsArray(Pattern: TBytes);
function littleEndian(Pattern: TBytes; pos: Integer): Integer; Overload;
function littleEndian(Pattern: TBytes; pos: Integer; count: Integer): Integer; Overload;
function littleEndianToByteArray(value: Integer): TBytes; Overload;
function littleEndianToByteArray(value: Integer; count: Integer): TBytes; Overload;
function addBytePattern(bytePattern: TBytes; newBytePattern: TBytes): TBytes;
function insertBytePattern(bytePattern: TBytes; newBytePattern: TBytes; position: Integer): TBytes;
function removeBytePattern(bytePattern: TBytes; position: Integer; amount: Integer): TBytes;
function compareBytePattern(b1: TBytes; b2: TBytes): Boolean;
function getUnsignedInt(Pattern: TBytes): Integer;
function String2Hex(const Buffer: Ansistring): string;

implementation


function GetFiles2(const Path: String): TStringList;
var
  i     : Integer;
  PathArray : TStringDynArray;

begin
  // Get the current folder
  Result := TStringList.Create;
  Writeln('Project Files in : ' + Path + ' :');
  Writeln;

  // Get all project files in this folder
  PathArray := System.IOUtils.TDirectory.GetFiles(Path, '*.BTR');
  for i := 0 to (Length(PathArray) - 1) do
    Result.Add(PathArray[i]);
end;

function MyGetFiles(const Path, Masks: string): TStringList;
var
  MaskArray, PathArray: TStringDynArray;
  Predicate: TDirectory.TFilterPredicate;
  i: Integer;
//  SearchOption: TSearchOption;
begin
  Result := TStringList.Create;
  MaskArray := SplitString(Masks, ';');
//  SearchOption := TSearchOption.soAllDirectories;
  Predicate :=
    function(const Path: string; const SearchRec: TSearchRec): Boolean
    var
      Mask: string;
    begin
      for Mask in MaskArray do
        if MatchesMask(SearchRec.Name, Mask) then
          exit(True);
      exit(False);
    end;
  PathArray := TDirectory.GetFiles(Path, Predicate);
  for i := 0 to (Length(PathArray) - 1) do
    Result.Add(PathArray[i]);
end;

function GetLODPaths(const Path: String): TStringList;
var
i: Integer;
PathArray: TStringDynArray;
begin
  Result := TStringList.Create;
  PathArray := TDirectory.GetDirectories(Path);
  for i := 0 to (Length(PathArray) - 1) do
  begin
    Result.AddStrings(MyGetFiles((PathArray[i] + '\'), '*.nif'));
    if DirectoryExists(PathArray[i]+ '\blocks\') then
      Result.AddStrings(MyGetFiles((PathArray[i]+ '\blocks\'), '*nif'));
  end;
end;

function GetWorldSpaces(const Path: String): TStringList;
var
i: Integer;
PathArray: TStringDynArray;
begin
  Result := TStringList.Create;
  PathArray := TDirectory.GetDirectories(Path);
  for i := 0 to (Length(PathArray) - 1) do
    Result.Add(Copy(PathArray[i], (Length(Path) + 1), MaxInt));
end;

function StringToByteArray(const pattern: String): TBytes;
var
  slAOB: TStringList;
  i: Integer;
begin

      slAOB := TStringList.Create;
      slAOB.Delimiter := ' ';
      slAOB.StrictDelimiter := True;
      slAOB.DelimitedText := pattern;
      SetLength(Result, slAOB.Count);
      for i := 0 to (slAOB.Count - 1) do
        Result[i] := StrToInt('$' + slAOB[i]);
end;


// Finds first occurence of byte array
function GetAOBPos(Pattern: TBytes; Data: TBytes): Integer;
var
bMatch: Boolean;
i, j: Integer;
begin
  Result := 0;
  for i := 0 to (Length(Data) - 1) do
  begin
    if Pattern[0] = Data[i] then
    begin
      bMatch := True;
      for j := i to (Length(Pattern) - 1 + i) do
      begin
        if Pattern[j - i] <> Data[j] then bMatch := False;
      end;
      if bMatch then
      begin
        Result := i;
        Exit;
      end;
    end;
  end;
end;

procedure printBytePattern(Pattern: TBytes);
var
i: Integer;
s: String;
begin
  s := '';
  for i := 0 to (Length(Pattern) - 1) do
  begin
    s := s + IntToHex(Pattern[i], 2) + ' ';
  end;
  writeln(s);
end;

procedure printBytePatternAsArray(Pattern: TBytes);
var
i: Integer;
s: String;
begin
  s := '';
  for i := 0 to (Length(Pattern) - 1) do
  begin
    s := s + '$' + IntToHex(Pattern[i], 2) + ', ';
  end;
  Delete(s, Length(s) - 1, 2);
  writeln(s);
end;

// Get little endian value from a position in a pattern.
function littleEndian(Pattern: TBytes; pos: Integer): Integer;
var
i: Integer;
s: String;
begin
  s := '';
  for i := 0 to 3 do
  begin
    s := IntToHex(Pattern[pos + i], 2) + s;
  end;
  s := '$' + s;
  Result := StrToInt(s);
end;

// Get little endian value from a position in a pattern.
function littleEndian(Pattern: TBytes; pos: Integer; count: Integer): Integer;
var
i: Integer;
s: String;
begin
  s := '';
  Writeln(IntToStr(Length(Pattern)));
  for i := 0 to (count - 1) do
  begin
    s := IntToHex(Pattern[pos + i], 2) + s;
  end;
  s := '$' + s;
  Result := StrToInt(s);
end;

function littleEndianToByteArray(value: Integer): TBytes;
var
s: String;
begin
  s := (IntToHex(value, 8));
  s := s + Copy(s, 7, 2);
  s := s + ' ' + Copy(s, 5, 2);
  s := s + ' ' + Copy(s, 3, 2);
  s := s + ' ' + Copy(s, 1, 2);
  s := Copy(s, 9, 11);
  Result := StringToByteArray(s);
end;

function littleEndianToByteArray(value: Integer; count: Integer): TBytes;
var
i: Integer;
s, s2: String;
begin
  SetLength(Result, count);
  s := (IntToHex(value, 2 * count));
  s2 := '';
  for i := 0 to count - 1 do
  begin
    s2 := Copy(s, i * 2 + 1, 2) + ' ' + s2;
  end;
  Delete(s2, Length(s2), 1);
  Result := StringToByteArray(s2);
end;

function addBytePattern(bytePattern: TBytes; newBytePattern: TBytes): TBytes;
var
pos: Integer;
begin
  pos := Length(bytePattern);
  SetLength(bytePattern, pos + Length(newBytePattern));
  Move(newBytePattern[0], bytePattern[pos], Length(newBytePattern));
  Result := bytePattern;
end;

function insertBytePattern(bytePattern: TBytes; newBytePattern: TBytes; position: Integer): TBytes;
var
len1, len2: Integer;
begin
  len1 := Length(bytePattern);
  len2 := Length(newBytePattern);
  SetLength(bytePattern, len1 + len2);
  Move(bytePattern[position], bytePattern[position + len2], len1 - position);
  Result := bytePattern;
end;

function removeBytePattern(bytePattern: TBytes; position: Integer; amount: Integer): TBytes;
var
len1, len2: Integer;
begin
  len1 := position + amount;
  len2 := Length(bytePattern);
  Move(bytePattern[len1], bytePattern[position], len2 - len1);
  SetLength(bytePattern, len2 - amount);
  Result := bytePattern;
end;

function compareBytePattern(b1: TBytes; b2: TBytes): Boolean;
var
i, len: Integer;
begin
  Result := True;
  len := Length(b1);
  if len = Length(b2) then
  begin
    for i := 0 to len - 1 do
      if b1[i] <> b2[i] then
      begin
        Result := False;
        exit;
      end;
  end
  else
    Result := False;
end;

function getUnsignedInt(Pattern: TBytes): Integer;
var
b: TBytes;
s: String;
i: Integer;
begin
  s := '$';
  b := Pattern;
  for i in b do
    s := s + IntToHex(i, 2);
  Result := StrToInt(s);
end;

function String2Hex(const Buffer: Ansistring): string;
begin
  SetLength(result, 2*Length(Buffer));
  BinToHex(@Buffer[1], PWideChar(@result[1]), Length(Buffer));
end;

end.
