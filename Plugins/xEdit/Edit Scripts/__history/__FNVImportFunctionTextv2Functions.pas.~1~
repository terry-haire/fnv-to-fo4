unit __TEMPLATE;

interface
implementation
uses xEditAPI, Classes, SysUtils, StrUtils, Windows; //Remove before use in xEdit

function Initialize: integer;
begin
	Result := 0;
end;

function Process(e: IInterface): integer;
begin
	Result := 0;	
	if Signature(e) <> 'INFO' then AddMessage('SIG IS ' + Signature(e));
end;

function Finalize: integer;
begin
	Result := 0;
end;

end.