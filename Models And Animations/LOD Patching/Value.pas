unit Value;

interface

uses
  System.SysUtils;

type
  TValue = class
  private
    offset      : Integer;
    length      : Integer;
    value       : TBytes;
    subIndex    : Integer;
    name        : String;
    ref         : Boolean;
    parentRef   : Boolean;
    hasCount    : Boolean;
    refCount    : String;
  public
    constructor Create(bytePattern: TBytes); Overload;
    constructor Create(pos: Integer; bytePattern: TBytes); Overload;
    constructor Create(pos: Integer; length: Integer); Overload;
    constructor Create(bytePattern: TBytes; name: String); Overload;
    constructor Create(bytePattern: TBytes; name: String; subIndex: Integer); Overload;
    constructor Create(bytePattern: TBytes; name: String; subIndex: Integer; isRef: Boolean; hasCount: Boolean); Overload;
    constructor Create(bytePattern: TBytes; name: String; subIndex: Integer; ref: String); Overload;
  published
    property getValue: TBytes
      read value;
    property getName: String
      read name;
    property getSubIndex: Integer
      read subIndex;
    property getRef: Boolean
      read ref;
    property getRefCount: String
      read refCount;
    property getHasCount: Boolean
      read hasCount;
    property getPrnRef : Boolean
      read parentRef;
    procedure setValue(b: TBytes);
    procedure setSubIndex(newIndex: Integer);
    procedure setPrnRef();
  end;

implementation

uses
  aobFunctions;

constructor TValue.Create(bytePattern: TBytes);
begin
  self.value := bytePattern;
  self.offset := 0;
end;

constructor TValue.Create(pos: Integer; bytePattern: TBytes);
begin
  self.offset := pos;
  self.value := bytePattern;
end;

constructor TValue.Create(pos: Integer; length: Integer);
begin
  self.offset := pos;
  self.length := length;
end;

constructor TValue.Create(bytePattern: TBytes; name: String);
begin
  self.value := bytePattern;
  self.name := name;
  self.subIndex := 0;
end;

constructor TValue.Create(bytePattern: TBytes; name: String; subIndex: Integer);
begin
  self.value := bytePattern;
  self.name := name;
  self.subIndex := subIndex;
end;

constructor TValue.Create(bytePattern: TBytes; name: String; subIndex: Integer; isRef: Boolean; hasCount: Boolean);
begin
  self.value := bytePattern;
  self.name := name;
  self.subIndex := subIndex;
  self.ref := isRef;
  self.hasCount := hasCount;
end;

constructor TValue.Create(bytePattern: TBytes; name: String; subIndex: Integer; ref: String);
begin
  self.value := bytePattern;
  self.name := name;
  self.subIndex := subIndex;
  self.refCount := ref;
end;

procedure TValue.setValue(b: TBytes);
begin
  self.value := b;
end;

procedure TValue.setSubIndex(newIndex: Integer);
begin
  Writeln('Old Index: ' + IntToStr(self.getSubIndex));
  Writeln('New Index: ' + IntToStr(newIndex));
  self.subIndex := newIndex;
end;

procedure TValue.setPrnRef();
begin
  self.parentRef := True;
end;

end.
