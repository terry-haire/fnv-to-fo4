{
  New script template, only shows processed records
  Assigning any nonzero value to Result will terminate script
}
unit __ObjectsInCell;

interface
implementation
uses xEditAPI, Classes, SysUtils, StrUtils, Windows;

// Called before processing
// You can remove it if script doesn't require initialization code
function Initialize: integer;
begin
  Result := 0;
end;

// called for every record selected in xEdit
function Process(e: IInterface): integer;
var
rContainer, rPosition: IInterface;
x, y, cellX, cellY: real;
begin
  Result := 0;

  cellX := -19;
  cellY := -2;

  cellX := cellX * 4096;
  cellY := cellY * 4096;

  // comment this out if you don't want those messages
//  AddMessage('Processing: ' + FullPath(e));

  // processing code goes here
  rContainer := ElementByPath(e, 'DATA');
  rPosition := ElementByPath(rContainer, 'Position');

  x := StrToFloat(getElementEditValues(rPosition, 'X'));
  y := StrToFloat(getElementEditValues(rPosition, 'Y'));

  if (x >= cellX) and (x < cellX + 4096) and (y >= cellY) and (y < cellY + 4096) then
  begin
    AddMessage(IntToHex(FormID(e), 8));
  end;
end;

// Called after processing
// You can remove it if script doesn't require finalization code
function Finalize: integer;
begin
  Result := 0;
end;

end.

