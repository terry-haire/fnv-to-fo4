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
    version     : Integer;
  protected
    values      : Array of TValue;
  public
    { Public declarations }
    constructor Create;                                             overload;
    constructor Create(bytePattern: TBytes);                        overload;
    constructor Create(pos: Integer; bytePattern: TBytes);          overload;
    constructor Create(b: TBytes; name: TBytes; version: Integer);  overload;
  // Externally accessible and inspectable fields and methods
  published
    // Note that properties must use different names to local defs
    property getPosition  : Integer
      read   position;
    property getBlockType : TBytes
      read blockType;
    function getSize(): Integer;
    procedure Add(bytePattern: TBytes);
//    procedure Insert(bytePattern: TBytes; position: Integer);
    procedure Remove(position: Integer; amount: Integer);
    function findValue(name: String;  subIndex: Integer): Integer;
    procedure Append(bytePattern: TBytes; pos: Integer; count: Integer; name: String; subIndex: Integer);
    procedure AppendRef(bytePattern: TBytes; pos: Integer; count: Integer; name: String; subIndex: Integer; hasCount: Boolean);
    // Need append string procedure
    procedure AppendPrnRef(bytePattern: TBytes; pos: Integer; count: Integer; name: String; subIndex: Integer; hasCount: Boolean);
    procedure AppendRefCount(bytePattern: TBytes; pos: Integer; count: Integer; name: String; subIndex: Integer; ref: String);
    procedure RemoveReference(index: Integer);
    procedure UpdateReference(index: Integer);
    procedure RenumberReference(references: TIntegerDynArray; index: Integer);
    procedure AddRefs(refs: TIntegerDynArray; counterName: String; valName: String);
    function getReferences(): TIntegerDynArray;
    function getData(): TBytes;
    procedure addBSFadeNode();
    procedure addBSTriShape();
    procedure addNiTriStrips();
    procedure addNiNode();
    procedure addBSShaderPPLightingProperty();
    procedure setRef(ref: Integer; name: String; subIndex: Integer);
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
constructor TBlock.Create(b: TBytes; name: TBytes; version: Integer);
begin
  self.position := 0;
  self.blockType := name;
  SetLength(self.values, 1);
  self.values[0] := TValue.Create(b);
  self.version := version;

  // BSFadeNode
  self.addBSFadeNode;

  // BSTriShape
  self.addBSTriShape;

  // NiTriStrips
  addNiTriStrips;

  // NiNode
  addNiNode;

  // BSShaderPPLightingProperty
  addBSShaderPPLightingProperty;
end;

constructor TBlock.Create(pos: Integer; bytePattern: TBytes);
begin
  self.position := pos;
  SetLength(self.values, 1);
  self.values[0] := TValue.Create(bytePattern);
end;

{##############################################################################}

function TBlock.findValue(name: String;  subIndex: Integer): Integer;
var
i: Integer;
begin
  i := 0;
  while(self.values[i].getName <> name) do
    Inc(i);
  i := i + subIndex;
  Result := i;
end;

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

    if self.version <> 4 then
    begin
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

    if self.version <> 4 then
    begin
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
    end;
  end;
end;

procedure TBlock.addBSTriShape();
var
i, j, k: Integer;
b: TBytes;
ref: String;
begin
  b := self.values[0].getValue;

  if compareBytePattern(self.blockType, [$0A, $00, $00, $00, $42, $53, $54, $72, $69, $53, $68, $61, $70, $65]) then
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

    // Fake num properties
    self.Append([$00, $00, $00, $00], 0, 4, 'Num Properties', 0);

    // Collision object (ref)
    self.AppendRef(b, i, 4, 'Collision object', 0, False);
    Inc(i, 4);

    // Bounding Sphere
    self.Append(b, i, 16, 'Bounding Sphere', 0);
    Inc(i, 16);

    // Skin (ref)
    self.AppendRef(b, i, 4, 'Skin', 0, False);
    Inc(i, 4);

    // BSProperties (ref)
    self.AppendRef(b, i, 4, 'BS Property', 0, False);
    self.AppendRef(b, i, 4, 'BS Property', 1, False);
    Inc(i, 8);

    // VF
    self.Append(b, i, 8, 'VF', 0);
    Inc(i, 8);

    // Num Triangles
    self.Append(b, i, 4, 'Num Triangles', 0);
    Inc(i, 4);

//    // Num Triangles FNV
//    self.Append(b, i, 2, 'Num Triangles', 0);
//    Inc(i, 4);

    // Num Vertices
    self.Append(b, i, 4, 'Num Vertices', 0);
    Inc(i, 4);

//    // Num Vertices FNV
//    self.Append(b, i, 2, 'Num Vertices', 0);
//    Inc(i, 4);

    // Vertex data
    self.Append(b, i, Length(b) - i, 'Vertex Data', 0);
  end;
end;

procedure TBlock.addNiTriStrips();
var
i, j, k: Integer;
b: TBytes;
ref: String;
begin
  //0B 00 00 00 4E 69 54 72 69 53 74 72 69 70 73
  b := self.values[0].getValue;

  if compareBytePattern(self.blockType, [$0B, $00, $00, $00, $4E, $69, $54, $72, $69, $53, $74, $72, $69, $70, $73]) then
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

    // Data
    self.AppendRef(b, i, 4, 'Data', 0, False);
    Inc(i, 4);

    // Skin (ref)
    self.AppendRef(b, i, 4, 'Skin', 0, False);
    Inc(i, 4);

    // Num Materials (Needs work to successfully process)
    ref := 'Material';
    self.AppendRefCount(b, i, 4, 'Num Materials', 0, ref);
    k := littleEndian(self.values[Length(self.values) - 1].getValue, 0, 4);
    Inc(i, 4);
    // Material name
    for j := 0 to k - 1 do
    begin
      self.AppendRef(b, i, 4, ref, j, True);
      Inc(i, 4);
    end;
    // Material extra data
    for j := 0 to k - 1 do
    begin
      self.AppendRef(b, i, 4, ref, j, True);
      Inc(i, 4);
    end;

    // Active Material (int)
    self.Append(b, i, 4, 'Active Material', 0);
    Inc(i, 4);

    // Dirty flag (bool)
    self.Append(b, i, 1, 'Active Material', 0);
    Inc(i, 1);

  end;
end;

procedure TBlock.addNiNode();
var
i, j, k: Integer;
b: TBytes;
ref: String;
begin
  b := self.values[0].getValue;
  if compareBytePattern(self.blockType, [$06, $00, $00, $00, $4E, $69, $4E, $6F, $64, $65]) then
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

    if self.version <> 4 then
    begin
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

    if self.version <> 4 then
    begin
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
    end;
  end;
end;

procedure TBlock.addBSShaderPPLightingProperty();
var
i, j, k: Integer;
b: TBytes;
ref: String;
begin
  b := self.values[0].getValue;
  if compareBytePattern(self.blockType, [$1A, $00, $00, $00, $42, $53, $53, $68, $61, $64, $65, $72, $50, $50, $4C, $69, $67, $68, $74, $69, $6E, $67, $50, $72, $6F, $70, $65, $72, $74, $79]) then
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

    // Shader data
    self.Append(b, i, $16, 'Shader Data', 0);
    Inc(i, $16);

    // Texture Set (ref)
    self.AppendRef(b, i, 4, 'Texture Set', 0, False);
    Inc(i, 4);

    // More Shader data
    self.Append(b, i, $10, 'More Shader Data', 0);
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

{ Append parent ref. }
procedure TBlock.AppendPrnRef(bytePattern: TBytes; pos: Integer; count: Integer; name: String; subIndex: Integer; hasCount: Boolean);
var
i: Integer;
begin
  i := Length(self.values);
  SetLength(self.values, i +  1);
  self.values[i] := TValue.Create(Copy(bytePattern, pos, count), name, subIndex, True, hasCount);
  self.values[i].setPrnRef;

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

//procedure TBlock.Insert(bytePattern: TBytes; position: Integer);
//begin
//  self.values[0] := TValue.Create(insertBytePattern(self.values[0].getValue, bytePattern, position));
//end;

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

procedure TBlock.UpdateReference(index: Integer);
var
i, j: Integer;
val: TValue;
newVal: TBytes;
begin
  for i := Length(self.values) - 1 downto 0 do
  begin
    val := self.values[i];
    if val.getRef then
    begin
      if compareBytePattern(val.getValue, [$FF, $FF, $FF, $FF]) then
        Continue;

      j := littleEndian(val.getValue, 0, 4);
      if j >= index then
      begin
        Inc(j);
        newVal := littleEndianToByteArray(j, 4);
        self.values[i].setValue(newVal);
      end;
    end;
  end;
end;

function TBlock.getReferences(): TIntegerDynArray;
var
val: TValue;
begin
  for val in self.values do
    if val.getRef then
      if not val.getPrnRef then
        if compareBytePattern(val.getValue, [$FF, $FF, $FF, $FF]) = False then
          Insert(littleEndian(val.getValue, 0, 4), Result, Length(Result));
end;

procedure TBlock.RenumberReference(references: TIntegerDynArray; index: Integer);
var
i, j: Integer;
val: TValue;
begin
  for i := 0 to Length(references) - 1 do
    for val in self.values do
      if val.getRef then
        if compareBytePattern(val.getValue, [$FF, $FF, $FF, $FF]) = False then
          if littleEndian(val.getValue, 0, 4) = references[i] then
            val.setValue(littleEndianToByteArray(i + index, 4));
end;

procedure TBlock.AddRefs(refs: TIntegerDynArray; counterName: String; valName: String);
var
i, startIndex, refCount, refCounterIndex: Integer;
ref: TBytes;
refCounter: TValue;
hasCount: Boolean;
begin
  if counterName <> '' then
  begin
    refCounterIndex := self.findValue(counterName, 0);
    refCounter := self.values[refCounterIndex];
    refCount := littleEndian(refCounter.getValue, 0, 4);
    hasCount := True;
  end;
  for i := 0 to Length(refs) - 1 do
  begin
    ref := littleEndianToByteArray(refs[i], 4);
    printBytePattern(ref);
    // Insert
    Insert(TValue.Create(ref, valName, i + refCount, True, hasCount), self.values, refCounterIndex + 1 + i + refCount);
  end;
  refCount := refCount + Length(refs);
  Writeln(IntToStr(Length(refs)));
  Writeln(IntToStr(refCount));
  Writeln(IntToStr(refCount - Length(refs)));
  Writeln(IntToStr(Length(self.values)));
  for i := 0 to Length(self.values) - 1 do
    Writeln(self.values[i].getName);
  refCounter.setValue(littleEndianToByteArray(refCount, 4));
end;

procedure TBlock.setRef(ref: Integer; name: String; subIndex: Integer);
var
i: Integer;
b: TBytes;
begin
  i := self.findValue(name, subIndex);
  if ref = -1 then
    b := [$FF, $FF, $FF, $FF]
  else
    b := littleEndianToByteArray(ref);
  self.values[i].setValue(b);
end;

end.
