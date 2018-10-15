unit Nif;

interface

uses
  System.SysUtils,
  Types,
  Header,
  Block;

type
  TNif = class
  private
    header: THeader;
    blocks: Array of TBlock;
  public
    constructor Create(bytePattern: TBytes);
  published
    procedure Remove(blockIndex: Integer);
    procedure RemoveType(typePattern: TBytes);
    function getData(): TBytes;
    procedure UpdateBlockSizes();
  end;

implementation

constructor TNif.Create(bytePattern: TBytes);
var
i, pos, blockSize, blockCount: Integer;
begin
  self.header := THeader.Create(bytePattern);
  pos := header.getLength;
  blockCount := header.getIntNumBlocks;
  SetLength(self.blocks, blockCount);
  for i := 0 to blockCount - 1 do
  begin
    blockSize := header.getBlockSize(i);
    self.blocks[i] := TBlock.Create(Copy(bytePattern, pos, blockSize), self.header.getTypeOfBlock(i));
    Inc(pos, blockSize);
  end;
end;

procedure TNif.RemoveType(typePattern: TBytes);
var
indexes: TIntegerDynArray;
i: Integer;
block: TBlock;
begin
  indexes := self.header.removeBlockType(typePattern);
  for i := Length(indexes) - 1 downto 0 do
  begin
    Writeln('Removing block at index: ' + IntToStr(indexes[i]));
    self.Remove(indexes[i]);
  end;
end;

procedure TNif.Remove(blockIndex: Integer);
var
block: TBlock;
begin
  self.header.removeBlock(blockIndex);
  Delete(self.blocks, blockIndex, 1);
  for block in self.blocks do
    block.RemoveReference(blockIndex);
  Writeln('Update block size');
  self.UpdateBlockSizes;
end;

procedure TNif.UpdateBlockSizes();
var
i, size: Integer;
begin
  for i := 0 to Length(self.blocks) - 1 do
  begin
    size := self.blocks[i].getSize;
    self.header.setBlockSize(i, size);
    Writeln(IntToStr(i));
  end;
    Writeln('here');
    readln;
end;

function TNif.getData(): TBytes;
var
block: TBlock;
i, len: Integer;
b: TBytes;
begin
  Result := self.header.getData;
  i := Length(Result);
  for block in self.blocks do
  begin
    b := block.getData;
    len := Length(b);
    SetLength(Result, i + len);
    Move(b[0], Result[i], len);
    Inc(i, len);
  end;
end;

end.