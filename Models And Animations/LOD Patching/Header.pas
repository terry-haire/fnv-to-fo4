unit Header;

interface

uses
  System.SysUtils,
  Types,
  Block,
  Value;

type
  THeader = class(TBlock)
  private
    { Private declarations }
    values : Array of TValue;
  public
    { Public declarations }
    constructor Create(nif: TBytes);
  // Externally accessible and inspectable fields and methods
  published
    function getIntNumBlocks(): Integer;
    function getIntNumBlockTypes(): Integer;
    function getBlockSize(index: Integer): Integer;
    procedure setBlockSize(index: Integer; newSize: Integer);
    function getIntNumStrings(): Integer;
    procedure removeBlock(index: Integer);
    procedure setIntNumBlocks(value: Integer);
    function getData(): TBytes;
//    procedure Append(value: TValue); overload;
//    procedure Append(bytePattern: TBytes; pos: Integer; count: Integer; name: String; subIndex: Integer); overload;
    function findValue(name: String;  subIndex: Integer): Integer;
    function getLength(): Integer;
    function removeBlockType(blockType: TBytes): TIntegerDynArray;
    procedure setIntNumBlockType(value: Integer);
    function getTypeOfBlock(index: Integer): TBytes;
    procedure Append(bytePattern: TBytes; pos: Integer; count: Integer; name: String; subIndex: Integer);
    // Note that properties must use different names to local defs
  end;

implementation

uses
  aobFunctions;

// Source: NifSkope
constructor THeader.Create(nif: TBytes);
var
i, j, k, len: Integer;
begin
  i := 0;

  // Header String
//  repeat
//    Inc(i);
//  until nif[i] = $0A;
  while (nif[i] <> $0A) do
    Inc(i);
  Inc(i);
  self.Append(nif, 0, i, 'Header String', 0);

  // Version as little endian
  self.Append(nif, i, 4, 'Version', 0);
  Inc(i, 4);

  // Endian Type
  self.Append(nif, i, 1, 'Endian Type', 0);
  Inc(i);

  // User Version
  self.Append(nif, i, 4, 'User Version', 0);
  Inc(i, 4);

  // Num Blocks
  self.Append(nif, i, 4, 'Num Blocks', 0);
  Inc(i, 4);

  // User Version 2
  self.Append(nif, i, 4, 'User Version 2', 0);
  Inc(i, 4);

  // Creator ShortString
  self.Append(nif, i, nif[i] + 1, 'Creator', 0);
  Inc(i, nif[i] + 1);

  // Export Info 1
  self.Append(nif, i, nif[i] + 1, 'Export Info 1', 0);
  Inc(i, nif[i] + 1);

  // Export Info 2
  self.Append(nif, i, nif[i] + 1, 'Export Info 2', 0);
  Inc(i, nif[i] + 1);

  // Num block types unsigned int16
  self.Append(nif, i, 2, 'Num Block Types', 0);
  Inc(i, 2);

  // Block Types
  k := self.getIntNumBlockTypes;
  for j := 0 to k - 1 do
  begin
    // The length of the string plus the length of length value.
    len := littleEndian(Copy(nif, i, 4), 0, 4) + 4;
    self.Append(nif, i, len, 'Block Type', j);
    Inc(i, len);
  end;
  // End
//  self.Append(nif, i, 1, 'Block Type', k);
//  Inc(i);

  // Block Type Index (uint16)
  k := self.getIntNumBlocks;
  for j := 0 to k - 1 do
  begin
    self.Append(nif, i, 2, 'Block Type Index', j);
    Inc(i, 2);
  end;
  // End
//  self.Append(nif, i, 1, 'Block Type Index', k);
//  Inc(i);

  // Block Sizes (little endian int32)
  k := self.getIntNumBlocks;
  for j := 0 to k - 1 do
  begin
    self.Append(nif, i, 4, 'Block Size', j);
    Inc(i, 4);
  end;

  // Num Strings (little endian int32)
  self.Append(nif, i, 4, 'Num Strings', 0);
  Inc(i, 4);

  // Max String Length (little endian int32)
  self.Append(nif, i, 4, 'Max String Length', 0);
  Inc(i, 4);

  // Strings
  k := self.getIntNumStrings;
  for j := 0 to k - 1 do
  begin
    // The length of the string plus the length of length value.
    len := littleEndian(Copy(nif, i, 4), 0, 4) + 4;
    self.Append(nif, i, len, 'String', j);
    Inc(i, len);
  end;

  // Unknown int32
  self.Append(nif, i, 4, 'Unknown Int32', 0);

  // End
end;

{##############################################################################}

function THeader.findValue(name: String;  subIndex: Integer): Integer;
var
i: Integer;
begin
  i := 0;
  while(self.values[i].getName <> name) do
    Inc(i);
  i := i + subIndex;
  Result := i;
end;

function THeader.getIntNumBlocks(): Integer;
var
val: TValue;
begin
  val := self.values[self.findValue('Num Blocks', 0)];
  Result := littleEndian(val.getValue, 0, 4);
end;

function THeader.getIntNumBlockTypes(): Integer;
var
val: TValue;
begin
  val := self.values[self.findValue('Num Block Types', 0)];
  printBytePattern(val.getValue);
  Result := littleEndian(val.getValue, 0, 2);
end;

procedure THeader.setIntNumBlockType(value: Integer);
var
b: TBytes;
begin
  b := littleEndianToByteArray(value, 2);
  self.values[self.findValue('Num Block Types', 0)] :=
      TValue.Create(b, 'Num Block Types', 0);
end;

function THeader.getIntNumStrings(): Integer;
var
val: TValue;
begin
  val := self.values[self.findValue('Num Strings', 0)];
  Result := littleEndian(val.getValue, 0, 4);
end;

procedure THeader.setIntNumBlocks(value: Integer);
var
b: TBytes;
begin
  b := littleEndianToByteArray(value, 4);
  self.values[self.findValue('Num Blocks', 0)] :=
      TValue.Create(b, 'Num Blocks', 0);
end;

function THeader.getBlockSize(index: Integer): Integer;
var
val: TValue;
begin
  Writeln(IntToStr(index));
  val := self.values[self.findValue('Block Size', index)];
  Result := littleEndian(val.getValue, 0, 4);
end;

procedure THeader.setBlockSize(index: Integer; newSize: Integer);
var
b: TBytes;
begin
  b := littleEndianToByteArray(newSize, 4);
  self.values[self.findValue('Block Size', index)].setValue(b);
end;

function THeader.getData(): TBytes;
var
len, pos: Integer;
val: TValue;
b: TBytes;
begin
  SetLength(Result, 0);
  pos := 0;
  for val in self.values do
  begin
    b := val.getValue;
    len := Length(b);
    SetLength(Result, Length(Result) + len);
    Move(b[0], Result[pos], len);
    Inc(pos, len);
  end;
end;

function THeader.getLength(): Integer;
begin
  Result := Length(self.getData);
end;

procedure THeader.Append(bytePattern: TBytes; pos: Integer; count: Integer; name: String; subIndex: Integer);
var
i: Integer;
begin
  i := Length(self.values);
  SetLength(self.values, i +  1);
  self.values[i] := TValue.Create(Copy(bytePattern, pos, count), name, subIndex);
  Writeln(self.values[i].getName);
//  printBytePattern(self.values[i].getValue);
  printBytePatternAsArray(self.values[i].getValue);
end;

function THeader.getTypeOfBlock(index: Integer): TBytes;
var
i, j, index2: Integer;
b: TBytes;
begin
  i := self.findValue('Block Type Index', 0);
  j := self.findValue('Block Type', 0);
  b := self.values[i + index].getValue;
  index2 := littleEndian(b, 0, 2);
  Result := self.values[j + index2].getValue;
end;

// TODO: Remove block type from heaeder if it is no longer needed.
// TODO: Remove data from header.
procedure THeader.removeBlock(index: Integer);
var
i, j, k, numBlocks: Integer;
begin
  numBlocks := self.getIntNumBlocks;

  i := self.findValue('Block Size', 0);
  k := i + index;
  Delete(self.values, k, 1);
  for j := 0 to numBlocks - 2 do
    self.values[i + j].setSubIndex(j);


  i := self.findValue('Block Type Index', 0);
  k := i + index;
  Delete(self.values, k, 1);
  for j := 0 to numBlocks - 2 do
    self.values[i + j].setSubIndex(j);

  Dec(numBlocks, 1);

  self.setIntNumBlocks(numBlocks);
end;

function THeader.removeBlockType(blockType: TBytes): TIntegerDynArray;
var
i, typeIndex, typeCount, pos, numBlocks, counter, j, k: Integer;
bFound: Boolean;
begin
  bFound := False;
  typeCount := self.getIntNumBlockTypes;
  j := 0;
  for i := 0 to typeCount - 1 do
  begin
    typeIndex := self.findValue('Block Type', i);
    if compareBytePattern(self.values[typeIndex].getValue, blockType) then
    begin
      j := i;
      Delete(self.values, typeIndex, 1);
      bFound := True;
      Break;
    end;
  end;
  if not bFound then
  begin
    writeln('Not Found');
    readln;
    exit;
  end;


  numBlocks := self.getIntNumBlocks;
  pos := self.findValue('Block Type Index', 0);
  counter := 0;
  bFound := False;
  for i := pos + numBlocks - 1 downto pos do
  begin
    k := littleEndian(self.values[i].getValue, 0, 2);

    if compareBytePattern(self.values[i].getValue, littleEndianToByteArray(j, 2)) then
    begin
      Inc(counter);
      SetLength(Result, counter);
      Result[counter - 1] := i - pos;
      bFound := True;
    end
    else if k > j then
    begin
      self.values[i].setValue(littleEndianToByteArray(k - 1, 2));
    end;
  end;

  if not bFound then
  begin
    writeln('Index not Found');
    readln;
    exit;
  end;

  Dec(typeCount, 1);
  self.setIntNumBlockType(typeCount);
end;

end.