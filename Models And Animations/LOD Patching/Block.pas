unit Block;

interface

uses
  System.SysUtils,
  Types,
  Value;

type
  TBlock = class
  private
    position    : Integer;
    blockType   : TBytes;
    values      : Array of TValue;
  public
    { Public declarations }
    constructor Create;                                    overload;
    constructor Create(bytePattern: TBytes);               overload;
    constructor Create(pos: Integer; bytePattern: TBytes); overload;
    constructor Create(b: TBytes; name: TBytes); overload;
  // Externally accessible and inspectable fields and methods
  published
    // Note that properties must use different names to local defs
    property getPosition  : Integer
      read   position;
    function getSize(): Integer;
    procedure Add(bytePattern: TBytes);
    procedure Insert(bytePattern: TBytes; position: Integer);
    procedure Remove(position: Integer; amount: Integer);
    procedure Append(bytePattern: TBytes; pos: Integer; count: Integer; name: String; subIndex: Integer);
    procedure AppendRef(bytePattern: TBytes; pos: Integer; count: Integer; name: String; subIndex: Integer; hasCount: Boolean);
    procedure AppendRefCount(bytePattern: TBytes; pos: Integer; count: Integer; name: String; subIndex: Integer; ref: String);
    procedure RemoveReference(index: Integer);
    function getData(): TBytes;
    procedure addBSFadeNode();
  end;

implementation

uses
  aobFunctions;

{ Create empty block. }
constructor TBlock.Create;
begin
  self.position := 0;
end;

{ Create block from byte pattern }
constructor TBlock.Create(bytePattern: TBytes);
begin
  self.position := 0;
  SetLength(self.values, 1);
  self.values[0] := TValue.Create(bytePattern);
end;

{ Create block from byte pattern and its type. }
constructor TBlock.Create(b: TBytes; name: TBytes);
begin
  self.position := 0;
  self.blockType := name;
  SetLength(self.values, 1);
  self.values[0] := TValue.Create(b);

  // BSFadeNode
  self.addBSFadeNode;
end;

constructor TBlock.Create(pos: Integer; bytePattern: TBytes);
begin
  self.position := pos;
  SetLength(self.values, 1);
  self.values[0] := TValue.Create(bytePattern);
end;

{##############################################################################}

procedure TBlock.addBSFadeNode();
var
i, j, k: Integer;
b: TBytes;
ref: String;
begin
  b := self.values[0].getValue;
  if compareBytePattern(self.blockType, [$0A, $00, $00, $00, $42, $53, $46, $61, $64, $65, $4E, $6F, $64, $65]) then
  begin

    i := 0;
    SetLength(self.values, 0);

    Inc(i, 4);
    // Name (little endian int32)
    self.Append(b, 0, i, 'Name', 0);

    // Num Extra Data List little endian int32
    ref := 'Extra Data List';
    self.AppendRefCount(b, i, 4, 'Num Extra Data List', 0, ref);
    k := littleEndian(self.values[Length(self.values) - 1].getValue, 0, 4);
    Inc(i, 4);
    // Extra Data List (ref)
    for j := 0 to k - 1 do
    begin
      self.AppendRef(b, i, 4, ref, j, True);
      Inc(i, 4);
    end;

    // Controller (ref)
    self.AppendRef(b, i, 4, 'Controller', 0, False);
    Inc(i, 4);

    // Flags
    self.Append(b, i, 4, 'Flags', 0);
    Inc(i, 4);

    // Transform
    self.Append(b, i, $34, 'Transform', 0);
    Inc(i, $34);

    // Num Properties
    ref := 'Property';
    self.AppendRefCount(b, i, 4, 'Num Properties', 0, ref);
    k := littleEndian(self.values[Length(self.values) - 1].getValue, 0, 4);
    Inc(i, 4);
    // Properties (ref)
    for j := 0 to k - 1 do
    begin
      self.AppendRef(b, i, 4, ref, j, True);
      Inc(i, 4);
    end;

    // Collision object (ref)
    self.AppendRef(b, i, 4, 'Collision object', 0, False);
    Inc(i, 4);

    // Num Children
    ref := 'Child';
    self.AppendRefCount(b, i, 4, 'Num Children', 0, ref);
    k := littleEndian(self.values[Length(self.values) - 1].getValue, 0, 4);
    Inc(i, 4);
    // Children (ref)
    for j := 0 to k - 1 do
    begin
      self.AppendRef(b, i, 4, ref, j, True);
      Inc(i, 4);
    end;

    // Num Effects
    ref := 'Effect';
    self.AppendRefCount(b, i, 4, 'Num Effects', 0, ref);
    k := littleEndian(self.values[Length(self.values) - 1].getValue, 0, 4);
    Inc(i, 4);
    // Effects (ref)
    for j := 0 to k - 1 do
    begin
      self.AppendRef(b, i, 4, ref, j, True);
      Inc(i, 4);
    end;

    writeln('HERE');
    readln;
  end;
end;

procedure TBlock.Append(bytePattern: TBytes; pos: Integer; count: Integer; name: String; subIndex: Integer);
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

procedure TBlock.AppendRef(bytePattern: TBytes; pos: Integer; count: Integer; name: String; subIndex: Integer; hasCount: Boolean);
var
i: Integer;
begin
  i := Length(self.values);
  SetLength(self.values, i +  1);
  self.values[i] := TValue.Create(Copy(bytePattern, pos, count), name, subIndex, True, hasCount);
  Writeln(self.values[i].getName);
//  printBytePattern(self.values[i].getValue);
  printBytePatternAsArray(self.values[i].getValue);
end;

procedure TBlock.AppendRefCount(bytePattern: TBytes; pos: Integer; count: Integer; name: String; subIndex: Integer; ref: String);
var
i: Integer;
begin
  i := Length(self.values);
  SetLength(self.values, i +  1);
  self.values[i] := TValue.Create(Copy(bytePattern, pos, count), name, subIndex, ref);
  Writeln(self.values[i].getName);
//  printBytePattern(self.values[i].getValue);
  printBytePatternAsArray(self.values[i].getValue);
end;

procedure TBlock.Add(bytePattern: TBytes);
begin
  self.values[0] := TValue.Create(addBytePattern(self.values[0].getValue, bytePattern));
end;

procedure TBlock.Insert(bytePattern: TBytes; position: Integer);
begin
  self.values[0] := TValue.Create(insertBytePattern(self.values[0].getValue, bytePattern, position));
end;

procedure TBlock.Remove(position: Integer; amount: Integer);
begin
  self.values[0] := TValue.Create(removeBytePattern(self.values[0].getValue, position, amount));
end;

function TBlock.getSize(): Integer;
var
i: Integer;
begin
  Result := 0;
  for i := 0 to Length(self.values) - 1 do
  begin
    Result := Result + Length(self.values[i].getValue);
  end;
end;

function TBlock.getData(): TBytes;
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

procedure TBlock.RemoveReference(index: Integer);
var
i, counter, refCount: Integer;
val: TValue;
refName: String;
begin
  refName := '';
  counter := 0;

  for i := Length(self.values) - 1 downto 0 do
  begin
    val := self.values[i];
    if val.getRef then
    begin
      if littleEndian(val.getValue, 0, 4) = index then
      begin
        if val.getHasCount then
        begin
          Delete(self.values, i, 1);
          if val.getName <> refName then
          begin
            counter := 0;
            refName := val.getName;
          end;
          Inc(counter);
        end
        else
        begin
          self.values[i].setValue([$FF, $FF, $FF, $FF]);
          counter := 0;
          refName := '';
        end;
      end;
    end
    else if Length(val.getRefCount) > 0 then
    begin
      if refName = val.getRefCount then
      begin
        refCount := littleEndian(val.getValue, 0, 4);
        Dec(refCount, counter);
        self.values[i].setValue(littleEndianToByteArray(refCount, 4));
      end;
    end
    else
    begin
      counter := 0;
      refName := '';
    end;
  end;
end;

end.