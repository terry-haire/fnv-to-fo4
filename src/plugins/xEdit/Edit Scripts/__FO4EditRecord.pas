{
  "Copy as override" implemented via script.
  Can be used to copy only filtered results, which xEdit's internal function can't do.
}
unit CopyAsOverride;

var
  ToFile: IInterface;

function Process(e: IInterface): integer;
var
  i: integer;
  frm: TForm;
  clb: TCheckListBox;
begin
	SetElementEditValues(e, 'FULL', 'Bob');
end;

end.