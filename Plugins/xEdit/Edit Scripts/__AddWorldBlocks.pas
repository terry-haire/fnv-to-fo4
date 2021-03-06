unit __AddWorldBlocks;

interface
implementation
uses xEditAPI, Classes, SysUtils, StrUtils, Windows; //Remove before use in xEdit


function GetCellFromWorldspace(Worldspace: IInterface; GridX, GridY: integer): IInterface;
var
  blockidx, subblockidx, cellidx: integer;
  wrldgrup, block, subblock, cell: IInterface;
  Grid, GridBlock, GridSubBlock: TwbGridCell;
  LabelBlock, LabelSubBlock: Cardinal;
begin
//  Grid := wbGridCell(GridX, GridY);
  GridSubBlock := wbSubBlockFromGridCell(Grid);
  LabelSubBlock := wbGridCellToGroupLabel(GridSubBlock);
  GridBlock := wbBlockFromSubBlock(GridSubBlock);
  LabelBlock := wbGridCellToGroupLabel(GridBlock);

  wrldgrup := ChildGroup(Worldspace);
  // iterate over Exterior Blocks
  for blockidx := 0 to Pred(ElementCount(wrldgrup)) do begin
    block := ElementByIndex(wrldgrup, blockidx);
    if GroupLabel(block) <> LabelBlock then Continue;
    // iterate over SubBlocks
    for subblockidx := 0 to Pred(ElementCount(block)) do begin
      subblock := ElementByIndex(block, subblockidx);
      if GroupLabel(subblock) <> LabelSubBlock then Continue;
      // iterate over Cells
      for cellidx := 0 to Pred(ElementCount(subblock)) do begin
        cell := ElementByIndex(subblock, cellidx);
        if (Signature(cell) <> 'CELL') or GetIsPersistent(cell) then Continue;
//        if (GetElementNativeValues(cell, 'XCLC\X') = Grid.x) and (GetElementNativeValues(cell, 'XCLC\Y') = Grid.y) then begin
          AddMessage('Yes');
          Result := cell;
          Exit;
        end;
      end;
      Break;
    end;
//    Break;
  end;
//end;

procedure OverlayCell(ToFile: IInterface);
var
  blockidx, subblockidx, cellidx: integer;
  wrldgrup, block, subblock, cell, rec: IInterface;
  x, y, x1, y1: real;
begin
  rec := FileByLoadOrder(0); // Should Always be Fallout4.esm
  rec := GroupBySignature(rec, 'WRLD');
  rec := MainRecordByEditorID(rec, 'Commonwealth');
  wrldgrup := ChildGroup(rec);
  // traverse Blocks
  for blockidx := 2 to Pred(ElementCount(wrldgrup)) do begin
  // Missing -1, 8
    AddMessage('');
    block := ElementByIndex(wrldgrup, blockidx);
//    AddMessage('ADDING ' + Path(block));
//    AddMessage('TO ' + Path(ToFile));
    wbCopyElementToFile(block, ToFile, True, False);
    // traverse SubBlocks
    for subblockidx := 0 to Pred(ElementCount(block)) do begin
      subblock := ElementByIndex(block, subblockidx);
      wbCopyElementToFile(subblock, ToFile, True, False);
    end;
  end;
end;

procedure ChangeLoadorder(rec: IInterface; loadorder: Integer);
begin
  SetLoadOrderFormID(rec, StrToInt('$' + IntToHex(1, 2) + Copy(IntToHex(GetLoadOrderFormID(rec), 8), 3, 6)));
end;

procedure CopyBlocks();
var
wrld, rec, rec2, rec3, rec4: IInterface;
i, j, k, l, loadorder: Integer;
begin
  loadorder := 1;
  wrld := FileByLoadOrder(loadorder);
  wrld := GroupBySignature(wrld, 'WRLD');
  for i := 0 to (ElementCount(wrld) - 1) do
  begin
    rec := ElementByIndex(wrld, i);
    AddMessage(Signature(rec));
    if Signature(rec) = 'WRLD' then
    begin
      ChangeLoadorder(rec, loadorder);
      SetToDefault(rec);
//      AddMessage(IntToHex(GetLoadOrder(rec), 8), 3, 6);
    end;
    if Signature(rec) = 'GRUP' then
    for j := 0 to (ElementCount(rec) - 1) do
    begin
      rec2 := ElementByIndex(rec, j);
      if Signature(rec2) = 'CELL' then Remove(rec2)
      else
      for k := 0 to (ElementCount(rec2) - 1) do
      begin
        rec3 := ElementByIndex(rec2, k);
        for l := 1 to (ElementCount(rec3) - 1) do
        begin
          rec4 := ElementByIndex(rec3, l);
          if l = 0 then
          begin
            SetToDefault(rec4);
            ChangeLoadorder(rec4, loadorder);
          end
          else
          begin
            Remove(ChildGroup(rec4));
            Remove(rec4);
          end;
        end;
      end;
    end;
  end;
end;

procedure CopyBlocks2(e: IInterface);
var
rec: IInterface;
lastpath: String;
i: Integer;
begin
  if ((Signature(e) = 'CELL') OR (Signature(e) = 'WRLD')) then
  begin
    if lastpath <> FullPath(GetContainer(e)) then
    begin
      lastpath := FullPath(GetContainer(e));
      rec := wbCopyElementToFile(e, FileByLoadOrder(1), False, False);
      if Signature(rec) = 'WRLD' then
      for i := 0 to (ElementCount(rec) - 1) do
        Remove(ChildrenOf(rec));
//      if ElementCount(GetContainer(rec)) > 0 then Remove(rec);
      ChangeLoadorder(rec, 1);
      SetToDefault(rec);
    end;
  end;
end;

procedure GetGridData(e: IInterface);
var
c: TwbGridCell;
begin
  c := wbPositionToGridCell(GetPosition(e));
//  c.X := 10;
//  AddMessage(IntToStr(c));
end;

procedure CreateCells3();
var
rec, rec2: IInterface;
i: Integer;
begin
  rec := FileByLoadOrder(1);
  rec := GroupBySignature(rec, 'WRLD');
  for i := 0 to (ElementCount(rec) - 1) do
  begin
    rec2 := ElementByIndex(rec, i);
//    if Signature(rec2) <> 'WRLD' then
    begin
      AddMessage(Name(rec2));
//      Add(rec2, 'CELL', True);
    end;
    AddMessage(IntToStr(i) + #9 + Signature(rec2));

  end;
end;


function Initialize: integer;
var
slstr, sltrf1, slstr2, sltrf2: TStringList;
i, j, k, l, loadorder: Integer;
ToFile, rec, rec2, rec3, rec4, wrld: IInterface;
start: Boolean;
begin
//  CreateCells3();
	Result := 0;
end;

function Process(e: IInterface): integer;
var
slstr, sltrf1, slstr2, sltrf2: TStringList;
i, j, k: Integer;
rec, wrld, rec2, Grid, ToFile: IInterface;
c: TwbGridCell;
lastpath: String;
begin
  rec := Add(e, 'CELL', True);
  SetElementEditValues(rec, 'XCLC\X', '3');
  SetElementEditValues(rec, 'XCLC\Y', '3');
	Result := 0;
end;

function Finalize: integer;
begin
	Result := 0;
end;

end.
