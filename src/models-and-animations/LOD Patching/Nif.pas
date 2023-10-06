unit Nif;

interface

uses
  System.SysUtils,
  Types,
  Generics.Collections,
  Header,
  Value,
  Block;

type
  TBranch = Array of TBlock;

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
    procedure ReplaceType(typePattern: TBytes; newTypePattern: TBytes; other: TNif);
    procedure ReplaceTypeByTemplate(typePattern: TBytes; block: TBlock; keepChildren: Boolean; giveName: Boolean);
    function getTypeCount(typePattern: TBytes): Integer;
    procedure ReplaceBlock(blockIndex: Integer; newBlock: TBlock);
    procedure ReplaceBlockWithBranch(blockIndex: Integer; branch: TBranch);
    procedure InsertBlock(blockIndex: Integer; newBlock: TBlock);
    function getBranch(rootIndex: Integer): TBranch;
    function getBranchHelper(rootIndex: Integer): TIntegerDynArray;
    function getData(): TBytes;
    procedure UpdateBlockSizes();
  end;

function renumberBranch(branch: TBranch; rootIndex: Integer): TBranch;

implementation

uses
  aobFunctions;

constructor TNif.Create(bytePattern: TBytes);
var
i, pos, blockSize, blockCount, version: Integer;
begin
  self.header := THeader.Create(bytePattern);
  version := self.header.getVersion;
  pos := header.getLength;
  blockCount := header.getIntNumBlocks;
  SetLength(self.blocks, blockCount);
  for i := 0 to blockCount - 1 do
  begin
    blockSize := header.getBlockSize(i);
    self.blocks[i] := TBlock.Create(Copy(bytePattern, pos, blockSize), self.header.getTypeOfBlock(i), version);
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

function TNif.getTypeCount(typePattern: TBytes): Integer;
var
block: TBlock;
begin
  Result := 0;
  for block in self.blocks do
    if compareBytePattern(block.getBlockType, typePattern) then
      Inc(Result);
end;

procedure TNif.ReplaceType(typePattern: TBytes; newTypePattern: TBytes; other: TNif);
var
i, j: Integer;
begin
  j := 0;
  if self.getTypeCount(typePattern) = other.getTypeCount(newTypePattern) then
  begin
    for i := 0 to Length(self.blocks) - 1 do
    begin
      if compareBytePattern(self.blocks[i].getBlockType, typePattern) then
      begin
        while(compareBytePattern(other.blocks[j].getBlockType, newTypePattern) = False) do
        begin
          Inc(j);
        end;
        self.ReplaceBlock(i, other.blocks[i]);

        Inc(j);
      end;
    end;
    self.header.removeBlockType(typePattern);
  end;
end;

procedure TNif.ReplaceTypeByTemplate(typePattern: TBytes; block: TBlock; keepChildren: Boolean; giveName: Boolean);
var
i, j, temp: Integer;
refs, newRefs: TIntegerDynArray;
blockCopy: TBlock;
name: String;
begin
  for i := 0 to Length(self.blocks) - 1 do
    if compareBytePattern(self.blocks[i].getBlockType, typePattern) then
    begin
      refs := self.blocks[i].getReferences;
      self.ReplaceBlock(i, block);
      blockCopy := TBlock.Create(block.getData, block.getBlockType, 130);
      self.blocks[i] := blockCopy;
      if keepChildren then
      begin
        TArray.Sort<Integer>(refs);
        self.blocks[i].AddRefs(refs, 'Num Children', 'Child');
        self.UpdateBlockSizes;
      end;
      if giveName then
      begin
        name := ':' + IntToStr(i);
        Writeln(name);
        j := self.header.addString(name);
        Writeln('j is ' + IntToStr(j));
        self.blocks[i].setRef(j, 'Name', 0);
      end;
    end;
//  self.header.removeBlockType(typePattern);
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

procedure TNif.InsertBlock(blockIndex: Integer; newBlock: TBlock);
var
block: TBlock;
begin
  for block in self.blocks do
    block.UpdateReference(blockIndex);
  self.header.insertBlock(blockIndex, newBlock);
  Insert(newBlock, self.blocks, blockIndex);
  Writeln('Update block size');
  self.UpdateBlockSizes;
end;

procedure TNif.ReplaceBlock(blockIndex: Integer; newBlock: TBlock);
begin
  self.header.removeBlock(blockIndex);
  Delete(self.blocks, blockIndex, 1);

  self.header.insertBlock(blockIndex, newBlock);
  Insert(newBlock, self.blocks, blockIndex);

  Writeln('Update block size');
  self.UpdateBlockSizes;
end;

procedure TNif.ReplaceBlockWithBranch(blockIndex: Integer; branch: TBranch);
var
i: Integer;
block: TBlock;
blockType: TBytes;
begin
  blockType := self.blocks[blockIndex].getBlockType;
  self.header.removeBlock(blockIndex);
  Delete(self.blocks, blockIndex, 1);

  branch := renumberBranch(branch, blockIndex);
  for i := Length(branch) - 1 downto 0 do
  begin
    self.header.insertBlock(blockIndex, branch[i]);
    Insert(branch[i], self.blocks, blockIndex);
  end;
//  self.RemoveType(blockType);

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
  // EOF
  Result := addBytePattern(Result, [$01, $00, $00, $00, $00, $00, $00, $00]);
end;

function TNif.getBranch(rootIndex: Integer): TBranch;
var
i, refIndex: Integer;
block: TBlock;
refArray: TIntegerDynArray;
begin

  refArray := self.getBranchHelper(rootIndex);
  Insert(rootIndex, refArray, 0);
  TArray.Sort<Integer>(refArray);
  // Remove Duplicates.
  for i := Length(refArray) - 1 downto 1 do
  begin
    if refArray[i] = refArray[i - 1] then
      Delete(refArray, i, 1);
  end;

  SetLength(Result, 0);
  for i := 0 to Length(refArray) - 1 do
  begin
    refIndex := refArray[i];
    block := self.blocks[refIndex];
    block.RenumberReference(refArray, 0);
    Insert(block, Result, Length(Result));
  end;

end;

function TNif.getBranchHelper(rootIndex: Integer): TIntegerDynArray;
var
i: Integer;
block: TBlock;
refArray: TIntegerDynArray;
begin
  block := self.blocks[rootIndex];
  refArray := block.getReferences;
  for i in refArray do
    Insert(self.getBranchHelper(i), Result, Length(Result));
end;

function renumberBranch(branch: TBranch; rootIndex: Integer): TBranch;
var
i: Integer;
refArray: TIntegerDynArray;
block: TBlock;
begin
  SetLength(refArray, Length(branch));
  for i := 0 to Length(branch) - 1 do
    refArray[i] := i;
  for block in branch do
    block.RenumberReference(refArray, rootIndex);
  Result := branch;
end;

end.
