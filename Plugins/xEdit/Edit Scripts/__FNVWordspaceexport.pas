unit UserScript;

uses __FNVMultple;

var
  //String List---------------------------------------------------------------------------------------------------------------------------------
  slWeap, slWrld, slRefr, slLand, slNavm, slAchr, slAcre
  : TStringList;
  DoExport: boolean;
function Initialize: integer;
var
  i: integer;
  // strings list with weapons data
begin
  Result := 0;
 slWeap	:= TStringList.Create;
 slWrld	:= TStringList.Create;
 slRefr	:= TStringList.Create;
 slLand	:= TStringList.Create;
 slNavm	:= TStringList.Create;
 slAchr	:= TStringList.Create;
 slAcre	:= TStringList.Create;
  //begin
  //  // Export: add columns headers line
  //  slWeap.Add('FormID;Worldspace;Record Header\Signature;Record Header\Record Flags\ESM;Record Header\Record Flags\<Unknown: 1>;Record Header\Record Flags\<Unknown: 2>;Record Header\Record Flags\Form initialized (Runtime only);Record Header\Record Flags\<Unknown: 4>;Record Header\Record Flags\Deleted;Record Header\Record Flags\Border Region / Has Tree LOD / Constant / Hidden From Local Map / Plugin Endian;Record Header\Record Flags\Turn Off Fire;Record Header\Record Flags\Inaccessible;Record Header\Record Flags\Casts shadows / On Local Map / Motion Blur;Record Header\Record Flags\Initially disabled;Record Header\Record Flags\Ignored;Record Header\Record Flags\No Voice Filter;Record Header\Record Flags\Cannot Save (Runtime only);Record Header\Record Flags\Random Anim Start / High Priority LOD;Record Header\Record Flags\Dangerous / Off limits (Interior cell) / Radio Station (Talking Activator);Record Header\Record Flags\Compressed;Record Header\Record Flags\Can''t wait / Platform Specific Texture / Dead;Record Header\Record Flags\Unknown 21;Record Header\Record Flags\Load Started (Runtime Only);Record Header\Record Flags\Unknown 23;Record Header\Record Flags\Unknown 24;Record Header\Record Flags\Destructible (Runtime only);Record Header\Record Flags\Obstacle / No AI Acquire;Record Header\Record Flags\NavMesh Generation - Filter;Record Header\Record Flags\NavMesh Generation - Bounding Box;Record Header\Record Flags\Non-Pipboy / Reflected by Auto Water;Record Header\Record Flags\Child Can Use / Refracted by Auto Water;Record Header\Record Flags\NavMesh Generation - Ground;Record Header\Record Flags\Multibound;Record Header\FormID;EDID;FULL;DATA\Is Interior Cell;DATA\Has Water;DATA\Invert Fast Travel behavior;DATA\No LOD Water;DATA\Public place;DATA\Hand Changed;DATA\Behave like exterior;XCLC\X;XCLC\Y;XCLC\Force Hide Land;XCLL;IMPF;Light Template\LTMP;Light Template\LNAM\Ambient Color;Light Template\LNAM\Directional Color;Light Template\LNAM\Fog Color;Light Template\LNAM\Fog Near;Light Template\LNAM\Fog Far;Light Template\LNAM\Directional Rotation;Light Template\LNAM\Directional Fade;Light Template\LNAM\Clip Distance;Light Template\LNAM\Fog Power;XCLW;XNAM;XLCR;XCIM;XEZN;XCCM;XCWT;Ownership;XCAS;XCMO');
	//slWrld.Add('FormID;Worldspace;Record Header\Signature;Record Header\Record Flags\ESM;Record Header\Record Flags\<Unknown: 1>;Record Header\Record Flags\<Unknown: 2>;Record Header\Record Flags\Form initialized (Runtime only);Record Header\Record Flags\<Unknown: 4>;Record Header\Record Flags\Deleted;Record Header\Record Flags\Border Region / Has Tree LOD / Constant / Hidden From Local Map / Plugin Endian;Record Header\Record Flags\Turn Off Fire;Record Header\Record Flags\Inaccessible;Record Header\Record Flags\Casts shadows / On Local Map / Motion Blur;Record Header\Record Flags\Initially disabled;Record Header\Record Flags\Ignored;Record Header\Record Flags\No Voice Filter;Record Header\Record Flags\Cannot Save (Runtime only);Record Header\Record Flags\Random Anim Start / High Priority LOD;Record Header\Record Flags\Dangerous / Off limits (Interior cell) / Radio Station (Talking Activator);Record Header\Record Flags\Compressed;Record Header\Record Flags\Can''t wait / Platform Specific Texture / Dead;Record Header\Record Flags\Unknown 21;Record Header\Record Flags\Load Started (Runtime Only);Record Header\Record Flags\Unknown 23;Record Header\Record Flags\Unknown 24;Record Header\Record Flags\Destructible (Runtime only);Record Header\Record Flags\Obstacle / No AI Acquire;Record Header\Record Flags\NavMesh Generation - Filter;Record Header\Record Flags\NavMesh Generation - Bounding Box;Record Header\Record Flags\Non-Pipboy / Reflected by Auto Water;Record Header\Record Flags\Child Can Use / Refracted by Auto Water;Record Header\Record Flags\NavMesh Generation - Ground;Record Header\Record Flags\Multibound;Record Header\FormID;EDID;FULL;DATA\Is Interior Cell;DATA\Has Water;DATA\Invert Fast Travel behavior;DATA\No LOD Water;DATA\Public place;DATA\Hand Changed;DATA\Behave like exterior;XCLC\X;XCLC\Y;XCLC\Force Hide Land;XCLL;IMPF;Light Template\LTMP;Light Template\LNAM\Ambient Color;Light Template\LNAM\Directional Color;Light Template\LNAM\Fog Color;Light Template\LNAM\Fog Near;Light Template\LNAM\Fog Far;Light Template\LNAM\Directional Rotation;Light Template\LNAM\Directional Fade;Light Template\LNAM\Clip Distance;Light Template\LNAM\Fog Power;XCLW;XNAM;XLCR;XCIM;XEZN;XCCM;XCWT;Ownership;XCAS;XCMO');
	//slRefr.add('FormID');
	//slLand.add('FormID');
	//slNavm.add('FormID');
	//slAchr.add('FormID');
	//slNavm.add('FormID');
	//slAcre.add('FormID');
  //end;
end;


function Process(e: IInterface): integer;
var
ToFile: IInterface;
begin
		if GetElementEditValues(e, 'Record Header\Signature') = 'ACRE' then //needs more work
	begin
		Result := 0;
		slAcre.Add(GetLoadOrderFormID(e));
		// use square brackets [] on formid to prevent Excel from treating them as a numbers
		//slAcre.Add('[' + IntToHex(FixedFormID(e), 8) + '];');
		//slAcre.Add(GetElementEditValues(e, 'Cell'));
		//slAcre.Add(GetElementEditValues(e, 'Record Header\Signature'));
		//slAcre.Add(GetElementEditValues(e, 'Record Header\Record Flags\ESM'));
		//slAcre.Add(GetElementEditValues(e, 'Record Header\Record Flags\<Unknown: 1>'));
		//slAcre.Add(GetElementEditValues(e, 'Record Header\Record Flags\<Unknown: 2>'));
		//slAcre.Add(GetElementEditValues(e, 'Record Header\Record Flags\Form initialized (Runtime only)'));
		//slAcre.Add(GetElementEditValues(e, 'Record Header\Record Flags\<Unknown: 4>'));
		slAcre.Add(GetElementEditValues(e, 'Record Header\Record Flags\Deleted'));
		//slAcre.Add(GetElementEditValues(e, 'Record Header\Record Flags\Border Region / Has Tree LOD / Constant / Hidden From Local Map / Plugin Endian'));
		//slAcre.Add(GetElementEditValues(e, 'Record Header\Record Flags\Turn Off Fire'));
		//slAcre.Add(GetElementEditValues(e, 'Record Header\Record Flags\Inaccessible'));
		//slAcre.Add(GetElementEditValues(e, 'Record Header\Record Flags\Casts shadows / On Local Map / Motion Blur'));
		//slAcre.Add(GetElementEditValues(e, 'Record Header\Record Flags\Initially disabled'));
		slAcre.Add(GetElementEditValues(e, 'Record Header\Record Flags\Ignored'));
		//slAcre.Add(GetElementEditValues(e, 'Record Header\Record Flags\No Voice Filter'));
		//slAcre.Add(GetElementEditValues(e, 'Record Header\Record Flags\Cannot Save (Runtime only)'));
		//slAcre.Add(GetElementEditValues(e, 'Record Header\Record Flags\Random Anim Start / High Priority LOD'));
		//slAcre.Add(GetElementEditValues(e, 'Record Header\Record Flags\Dangerous / Off limits (Interior cell) / Radio Station (Talking Activator)'));
		slAcre.Add(GetElementEditValues(e, 'Record Header\Record Flags\Compressed'));
		//slAcre.Add(GetElementEditValues(e, 'Record Header\Record Flags\Can''t wait / Platform Specific Texture / Dead'));
		//slAcre.Add(GetElementEditValues(e, 'Record Header\Record Flags\Unknown 21'));
		//slAcre.Add(GetElementEditValues(e, 'Record Header\Record Flags\Load Started (Runtime Only)'));
		//slAcre.Add(GetElementEditValues(e, 'Record Header\Record Flags\Unknown 23'));
		//slAcre.Add(GetElementEditValues(e, 'Record Header\Record Flags\Unknown 24'));
		//slAcre.Add(GetElementEditValues(e, 'Record Header\Record Flags\Destructible (Runtime only)'));
		//slAcre.Add(GetElementEditValues(e, 'Record Header\Record Flags\Obstacle / No AI Acquire'));
		//slAcre.Add(GetElementEditValues(e, 'Record Header\Record Flags\NavMesh Generation - Filter'));
		//slAcre.Add(GetElementEditValues(e, 'Record Header\Record Flags\NavMesh Generation - Bounding Box'));
		//slAcre.Add(GetElementEditValues(e, 'Record Header\Record Flags\Non-Pipboy / Reflected by Auto Water'));
		//slAcre.Add(GetElementEditValues(e, 'Record Header\Record Flags\Child Can Use / Refracted by Auto Water'));
		//slAcre.Add(GetElementEditValues(e, 'Record Header\Record Flags\NavMesh Generation - Ground'));
		//slAcre.Add(GetElementEditValues(e, 'Record Header\Record Flags\Multibound'));
		//slAcre.Add(GetElementEditValues(e, 'Record Header\FormID'));
		slAcre.Add(GetElementEditValues(e, 'EDID'));
		slAcre.Add(GetElementEditValues(e, 'NAME'));
		slAcre.Add(GetElementEditValues(e, 'XEZN'));
		slAcre.Add(GetElementEditValues(e, 'XRGD'));
		slAcre.Add(GetElementEditValues(e, 'XRGB'));
		//slAcre.Add(GetElementEditValues(e, 'Patrol Data\XPRD')); // Complex
		//slAcre.Add(GetElementEditValues(e, 'Patrol Data\XPPA'));
		//slAcre.Add(GetElementEditValues(e, 'Patrol Data\INAM'));
		//slAcre.Add(GetElementEditValues(e, 'Patrol Data\Embedded Script\SCHR\Refcount'));
		//slAcre.Add(GetElementEditValues(e, 'Patrol Data\Embedded Script\SCHR\CompiledSize'));
		//slAcre.Add(GetElementEditValues(e, 'Patrol Data\Embedded Script\SCHR\VariableCount'));
		//slAcre.Add(GetElementEditValues(e, 'Patrol Data\Embedded Script\SCHR\Type'));
		//slAcre.Add(GetElementEditValues(e, 'Patrol Data\Embedded Script\SCHR\Flags\Enabled'));
		//slAcre.Add(GetElementEditValues(e, 'Patrol Data\Embedded Script\SCDA'));
		//slAcre.Add(GetElementEditValues(e, 'Patrol Data\Embedded Script\SCTX'));
		//slAcre.Add(PatrolData1(e)); // multiple);
		//slAcre.Add(PatrolData2(e)); // multiple);
		//slAcre.Add(GetElementEditValues(e, 'Patrol Data\TNAM'));
		slAcre.Add(GetElementEditValues(e, 'XLCM'));
		slAcre.Add(GetElementEditValues(e, 'Ownership\XOWN'));
		slAcre.Add(GetElementEditValues(e, 'Ownership\XRNK'));
		slAcre.Add(GetElementEditValues(e, 'XMRC'));
		slAcre.Add(GetElementEditValues(e, 'XCNT'));
		slAcre.Add(GetElementEditValues(e, 'XRDS'));
		slAcre.Add(GetElementEditValues(e, 'XHLP'));
		slAcre.Add(LinkedDecals(e)); // multiple);
		slAcre.Add(GetElementEditValues(e, 'XLKR'));
		slAcre.Add(GetElementEditValues(e, 'XCLP\Link Start Color\Red'));
		slAcre.Add(GetElementEditValues(e, 'XCLP\Link Start Color\Green'));
		slAcre.Add(GetElementEditValues(e, 'XCLP\Link Start Color\Blue'));
		slAcre.Add(GetElementEditValues(e, 'XCLP\Link End Color\Red'));
		slAcre.Add(GetElementEditValues(e, 'XCLP\Link End Color\Green'));
		slAcre.Add(GetElementEditValues(e, 'XCLP\Link End Color\Blue'));
		slAcre.Add(GetElementEditValues(e, 'Activate Parents\XADP\Parent Activate Only'));
		slAcre.Add(ActivateParents(e)); // multiple);
		slAcre.Add(GetElementEditValues(e, 'XATO'));
		slAcre.Add(GetElementEditValues(e, 'XESP\Reference'));
		slAcre.Add(GetElementEditValues(e, 'XESP\Flags\Set Enable State to Opposite of Parent'));
		slAcre.Add(GetElementEditValues(e, 'XESP\Flags\Pop In'));
		slAcre.Add(GetElementEditValues(e, 'XEMI'));
		slAcre.Add(GetElementEditValues(e, 'XMBR'));
		slAcre.Add(GetElementEditValues(e, 'XIBS'));
		slAcre.Add(GetElementEditValues(e, 'XSCL'));
		slAcre.Add(GetElementEditValues(e, 'DATA\Position\X'));
		slAcre.Add(GetElementEditValues(e, 'DATA\Position\Y'));
		slAcre.Add(GetElementEditValues(e, 'DATA\Position\Z'));
		slAcre.Add(GetElementEditValues(e, 'DATA\Rotation\X'));
		slAcre.Add(GetElementEditValues(e, 'DATA\Rotation\Y'));
		slAcre.Add(GetElementEditValues(e, 'DATA\Rotation\Z'));
	end;
		if GetElementEditValues(e, 'Record Header\Signature') = 'ACHR' then
	begin
		Result := 0;
		// use square brackets [] on formid to prevent Excel from treating them as a numbers
		slAchr.Add(GetLoadOrderFormID(e));
		//slAchr.Add('[' + IntToHex(FixedFormID(e), 8) + '];');
		//slAchr.Add(GetElementEditValues(e, 'Cell'));
		//slAchr.Add(GetElementEditValues(e, 'Record Header\Signature'));
		//slAchr.Add(GetElementEditValues(e, 'Record Header\Record Flags\ESM'));
		//slAchr.Add(GetElementEditValues(e, 'Record Header\Record Flags\<Unknown: 1>'));
		//slAchr.Add(GetElementEditValues(e, 'Record Header\Record Flags\<Unknown: 2>'));
		//slAchr.Add(GetElementEditValues(e, 'Record Header\Record Flags\Form initialized (Runtime only)'));
		//slAchr.Add(GetElementEditValues(e, 'Record Header\Record Flags\<Unknown: 4>'));
		//slAchr.Add(GetElementEditValues(e, 'Record Header\Record Flags\Deleted'));
		//slAchr.Add(GetElementEditValues(e, 'Record Header\Record Flags\Border Region / Has Tree LOD / Constant / Hidden From Local Map / Plugin Endian'));
		//slAchr.Add(GetElementEditValues(e, 'Record Header\Record Flags\Turn Off Fire'));
		//slAchr.Add(GetElementEditValues(e, 'Record Header\Record Flags\Inaccessible'));
		//slAchr.Add(GetElementEditValues(e, 'Record Header\Record Flags\Casts shadows / On Local Map / Motion Blur'));
		//slAchr.Add(GetElementEditValues(e, 'Record Header\Record Flags\Initially disabled'));
		//slAchr.Add(GetElementEditValues(e, 'Record Header\Record Flags\Ignored'));
		//slAchr.Add(GetElementEditValues(e, 'Record Header\Record Flags\No Voice Filter'));
		//slAchr.Add(GetElementEditValues(e, 'Record Header\Record Flags\Cannot Save (Runtime only)'));
		//slAchr.Add(GetElementEditValues(e, 'Record Header\Record Flags\Random Anim Start / High Priority LOD'));
		//slAchr.Add(GetElementEditValues(e, 'Record Header\Record Flags\Dangerous / Off limits (Interior cell) / Radio Station (Talking Activator)'));
		//slAchr.Add(GetElementEditValues(e, 'Record Header\Record Flags\Compressed'));
		//slAchr.Add(GetElementEditValues(e, 'Record Header\Record Flags\Can''t wait / Platform Specific Texture / Dead'));
		//slAchr.Add(GetElementEditValues(e, 'Record Header\Record Flags\Unknown 21'));
		//slAchr.Add(GetElementEditValues(e, 'Record Header\Record Flags\Load Started (Runtime Only)'));
		//slAchr.Add(GetElementEditValues(e, 'Record Header\Record Flags\Unknown 23'));
		//slAchr.Add(GetElementEditValues(e, 'Record Header\Record Flags\Unknown 24'));
		//slAchr.Add(GetElementEditValues(e, 'Record Header\Record Flags\Destructible (Runtime only)'));
		//slAchr.Add(GetElementEditValues(e, 'Record Header\Record Flags\Obstacle / No AI Acquire'));
		//slAchr.Add(GetElementEditValues(e, 'Record Header\Record Flags\NavMesh Generation - Filter'));
		//slAchr.Add(GetElementEditValues(e, 'Record Header\Record Flags\NavMesh Generation - Bounding Box'));
		//slAchr.Add(GetElementEditValues(e, 'Record Header\Record Flags\Non-Pipboy / Reflected by Auto Water'));
		//slAchr.Add(GetElementEditValues(e, 'Record Header\Record Flags\Child Can Use / Refracted by Auto Water'));
		//slAchr.Add(GetElementEditValues(e, 'Record Header\Record Flags\NavMesh Generation - Ground'));
		//slAchr.Add(GetElementEditValues(e, 'Record Header\Record Flags\Multibound'));
		//slAchr.Add(GetElementEditValues(e, 'Record Header\FormID'));
		//slAchr.Add(GetElementEditValues(e, 'EDID'));
		//slAchr.Add(GetElementEditValues(e, 'NAME'));
		//slAchr.Add(GetElementEditValues(e, 'XRGD'));
		//slAchr.Add(GetElementEditValues(e, 'XRGB'));
		//slAchr.Add(GetElementEditValues(e, 'Patrol Data\XPRD'));
		//slAchr.Add(GetElementEditValues(e, 'Patrol Data\XPPA'));
		//slAchr.Add(GetElementEditValues(e, 'Patrol Data\INAM'));
		//slAchr.Add(GetElementEditValues(e, 'Patrol Data\Embedded Script\SCHR\Refcount'));
		//slAchr.Add(GetElementEditValues(e, 'Patrol Data\Embedded Script\SCHR\CompiledSize'));
		//slAchr.Add(GetElementEditValues(e, 'Patrol Data\Embedded Script\SCHR\VariableCount'));
		//slAchr.Add(GetElementEditValues(e, 'Patrol Data\Embedded Script\SCHR\Type'));
		//slAchr.Add(GetElementEditValues(e, 'Patrol Data\Embedded Script\SCHR\Flags\Enabled'));
		//slAchr.Add(GetElementEditValues(e, 'Patrol Data\Embedded Script\SCDA'));
		//slAchr.Add(GetElementEditValues(e, 'Patrol Data\Embedded Script\SCTX'));
		//slAchr.Add(PatrolData1(e)); // multiple);
		//slAchr.Add(PatrolData2(e)); // multiple);
		//slAchr.Add(GetElementEditValues(e, 'Patrol Data\TNAM'));
		//slAchr.Add(GetElementEditValues(e, 'XLCM'));
		//slAchr.Add(GetElementEditValues(e, 'XMRC'));
		//slAchr.Add(GetElementEditValues(e, 'XCNT'));
		//slAchr.Add(GetElementEditValues(e, 'XRDS'));
		//slAchr.Add(GetElementEditValues(e, 'XHLP'));
		//slAchr.Add(LinkedDecals(e)); // multiple);
		//slAchr.Add(GetElementEditValues(e, 'XLKR'));
		//slAchr.Add(GetElementEditValues(e, 'XCLP\Link Start Color\Red'));
		//slAchr.Add(GetElementEditValues(e, 'XCLP\Link Start Color\Green'));
		//slAchr.Add(GetElementEditValues(e, 'XCLP\Link Start Color\Blue'));
		//slAchr.Add(GetElementEditValues(e, 'XCLP\Link End Color\Red'));
		//slAchr.Add(GetElementEditValues(e, 'XCLP\Link End Color\Green'));
		//slAchr.Add(GetElementEditValues(e, 'XCLP\Link End Color\Blue'));
		//slAchr.Add(GetElementEditValues(e, 'Activate Parents\XADP\Parent Activate Only'));
		//slAchr.Add(ActivateParents(e)); // multiple);
		//slAchr.Add(GetElementEditValues(e, 'XATO'));
		//slAchr.Add(GetElementEditValues(e, 'XESP\Reference'));
		//slAchr.Add(GetElementEditValues(e, 'XESP\Flags\Set Enable State to Opposite of Parent'));
		//slAchr.Add(GetElementEditValues(e, 'XESP\Flags\Pop In'));
		//slAchr.Add(GetElementEditValues(e, 'XEMI'));
		//slAchr.Add(GetElementEditValues(e, 'XMBR'));
		//slAchr.Add(GetElementEditValues(e, 'XIBS'));
		//slAchr.Add(GetElementEditValues(e, 'XSCL'));
		//slAchr.Add(GetElementEditValues(e, 'DATA\Position\X'));
		//slAchr.Add(GetElementEditValues(e, 'DATA\Position\Y'));
		//slAchr.Add(GetElementEditValues(e, 'DATA\Position\Z'));
		//slAchr.Add(GetElementEditValues(e, 'DATA\Rotation\X'));
		//slAchr.Add(GetElementEditValues(e, 'DATA\Rotation\Y'));
		//slAchr.Add(GetElementEditValues(e, 'DATA\Rotation\Z'));
	end;
		if GetElementEditValues(e, 'Record Header\Signature') = 'NAVM' then
	begin
		Result := 0;
		// use square brackets [] on formid to prevent Excel from treating them as a numbers
		slNavm.Add(GetLoadOrderFormID(e));
		//slNavm.Add('[' + IntToHex(FixedFormID(e), 8) + '];');
		//slNavm.Add(GetElementEditValues(e, 'Cell'));
		//slNavm.Add(GetElementEditValues(e, 'Record Header\Signature'));
		//slNavm.Add(GetElementEditValues(e, 'Record Header\Record Flags\ESM'));
		//slNavm.Add(GetElementEditValues(e, 'Record Header\Record Flags\<Unknown: 1>'));
		//slNavm.Add(GetElementEditValues(e, 'Record Header\Record Flags\<Unknown: 2>'));
		//slNavm.Add(GetElementEditValues(e, 'Record Header\Record Flags\Form initialized (Runtime only)'));
		//slNavm.Add(GetElementEditValues(e, 'Record Header\Record Flags\<Unknown: 4>'));
		//slNavm.Add(GetElementEditValues(e, 'Record Header\Record Flags\Deleted'));
		//slNavm.Add(GetElementEditValues(e, 'Record Header\Record Flags\Border Region / Has Tree LOD / Constant / Hidden From Local Map / Plugin Endian'));
		//slNavm.Add(GetElementEditValues(e, 'Record Header\Record Flags\Turn Off Fire'));
		//slNavm.Add(GetElementEditValues(e, 'Record Header\Record Flags\Inaccessible'));
		//slNavm.Add(GetElementEditValues(e, 'Record Header\Record Flags\Casts shadows / On Local Map / Motion Blur'));
		//slNavm.Add(GetElementEditValues(e, 'Record Header\Record Flags\Initially disabled'));
		//slNavm.Add(GetElementEditValues(e, 'Record Header\Record Flags\Ignored'));
		//slNavm.Add(GetElementEditValues(e, 'Record Header\Record Flags\No Voice Filter'));
		//slNavm.Add(GetElementEditValues(e, 'Record Header\Record Flags\Cannot Save (Runtime only)'));
		//slNavm.Add(GetElementEditValues(e, 'Record Header\Record Flags\Random Anim Start / High Priority LOD'));
		//slNavm.Add(GetElementEditValues(e, 'Record Header\Record Flags\Dangerous / Off limits (Interior cell) / Radio Station (Talking Activator)'));
		//slNavm.Add(GetElementEditValues(e, 'Record Header\Record Flags\Compressed'));
		//slNavm.Add(GetElementEditValues(e, 'Record Header\Record Flags\Can''t wait / Platform Specific Texture / Dead'));
		//slNavm.Add(GetElementEditValues(e, 'Record Header\Record Flags\Unknown 21'));
		//slNavm.Add(GetElementEditValues(e, 'Record Header\Record Flags\Load Started (Runtime Only)'));
		//slNavm.Add(GetElementEditValues(e, 'Record Header\Record Flags\Unknown 23'));
		//slNavm.Add(GetElementEditValues(e, 'Record Header\Record Flags\Unknown 24'));
		//slNavm.Add(GetElementEditValues(e, 'Record Header\Record Flags\Destructible (Runtime only)'));
		//slNavm.Add(GetElementEditValues(e, 'Record Header\Record Flags\Obstacle / No AI Acquire'));
		//slNavm.Add(GetElementEditValues(e, 'Record Header\Record Flags\NavMesh Generation - Filter'));
		//slNavm.Add(GetElementEditValues(e, 'Record Header\Record Flags\NavMesh Generation - Bounding Box'));
		//slNavm.Add(GetElementEditValues(e, 'Record Header\Record Flags\Non-Pipboy / Reflected by Auto Water'));
		//slNavm.Add(GetElementEditValues(e, 'Record Header\Record Flags\Child Can Use / Refracted by Auto Water'));
		//slNavm.Add(GetElementEditValues(e, 'Record Header\Record Flags\NavMesh Generation - Ground'));
		//slNavm.Add(GetElementEditValues(e, 'Record Header\Record Flags\Multibound'));
		//slNavm.Add(GetElementEditValues(e, 'Record Header\FormID'));
		//slNavm.Add(GetElementEditValues(e, 'EDID'));
		//slNavm.Add(GetElementEditValues(e, 'NVER'));
		//slNavm.Add(GetElementEditValues(e, 'DATA\Cell'));
		//slNavm.Add(GetElementEditValues(e, 'DATA\Vertex Count'));
		//slNavm.Add(GetElementEditValues(e, 'DATA\Triangle Count'));
		//slNavm.Add(GetElementEditValues(e, 'DATA\External Connections Count'));
		//slNavm.Add(GetElementEditValues(e, 'DATA\NVCA Count'));
		//slNavm.Add(GetElementEditValues(e, 'DATA\Doors Count'));
		//slNavm.Add(GetElementEditValues(e, 'NVVX'));
		//slNavm.Add(GetElementEditValues(e, 'NVTR'));
		//slNavm.Add(GetElementEditValues(e, 'NVCA'));
		//slNavm.Add(NVPDDoors(e)); //multiple
		//slNavm.Add(GetElementEditValues(e, 'NVGD'));
		//slNavm.Add(NVEXExtCon(e)); // multiple);
	end;
		if GetElementEditValues(e, 'Record Header\Signature') = 'LAND' then
	begin
		Result := 0;
		// use square brackets [] on formid to prevent Excel from treating them as a numbers
		slLand.Add(GetLoadOrderFormID(e));
		//slLand.Add('[' + IntToHex(FixedFormID(e), 8) + '];');
		slLand.Add(GetElementEditValues(e, 'Cell'));
		slLand.Add(GetElementEditValues(e, 'Record Header\Signature'));
		//slLand.Add(GetElementEditValues(e, 'Record Header\Record Flags\ESM'));
		//slLand.Add(GetElementEditValues(e, 'Record Header\Record Flags\<Unknown: 1>'));
		//slLand.Add(GetElementEditValues(e, 'Record Header\Record Flags\<Unknown: 2>'));
		//slLand.Add(GetElementEditValues(e, 'Record Header\Record Flags\Form initialized (Runtime only)'));
		//slLand.Add(GetElementEditValues(e, 'Record Header\Record Flags\<Unknown: 4>'));
		slLand.Add(GetElementEditValues(e, 'Record Header\Record Flags\Deleted'));
		//slLand.Add(GetElementEditValues(e, 'Record Header\Record Flags\Border Region / Has Tree LOD / Constant / Hidden From Local Map / Plugin Endian'));
		//slLand.Add(GetElementEditValues(e, 'Record Header\Record Flags\Turn Off Fire'));
		//slLand.Add(GetElementEditValues(e, 'Record Header\Record Flags\Inaccessible'));
		//slLand.Add(GetElementEditValues(e, 'Record Header\Record Flags\Casts shadows / On Local Map / Motion Blur'));
		//slLand.Add(GetElementEditValues(e, 'Record Header\Record Flags\Initially disabled'));
		slLand.Add(GetElementEditValues(e, 'Record Header\Record Flags\Ignored'));
		//slLand.Add(GetElementEditValues(e, 'Record Header\Record Flags\No Voice Filter'));
		//slLand.Add(GetElementEditValues(e, 'Record Header\Record Flags\Cannot Save (Runtime only)'));
		//slLand.Add(GetElementEditValues(e, 'Record Header\Record Flags\Random Anim Start / High Priority LOD'));
		//slLand.Add(GetElementEditValues(e, 'Record Header\Record Flags\Dangerous / Off limits (Interior cell) / Radio Station (Talking Activator)'));
		slLand.Add(GetElementEditValues(e, 'Record Header\Record Flags\Compressed'));
		//slLand.Add(GetElementEditValues(e, 'Record Header\Record Flags\Can''t wait / Platform Specific Texture / Dead'));
		//slLand.Add(GetElementEditValues(e, 'Record Header\Record Flags\Unknown 21'));
		//slLand.Add(GetElementEditValues(e, 'Record Header\Record Flags\Load Started (Runtime Only)'));
		//slLand.Add(GetElementEditValues(e, 'Record Header\Record Flags\Unknown 23'));
		//slLand.Add(GetElementEditValues(e, 'Record Header\Record Flags\Unknown 24'));
		//slLand.Add(GetElementEditValues(e, 'Record Header\Record Flags\Destructible (Runtime only)'));
		//slLand.Add(GetElementEditValues(e, 'Record Header\Record Flags\Obstacle / No AI Acquire'));
		//slLand.Add(GetElementEditValues(e, 'Record Header\Record Flags\NavMesh Generation - Filter'));
		//slLand.Add(GetElementEditValues(e, 'Record Header\Record Flags\NavMesh Generation - Bounding Box'));
		//slLand.Add(GetElementEditValues(e, 'Record Header\Record Flags\Non-Pipboy / Reflected by Auto Water'));
		//slLand.Add(GetElementEditValues(e, 'Record Header\Record Flags\Child Can Use / Refracted by Auto Water'));
		//slLand.Add(GetElementEditValues(e, 'Record Header\Record Flags\NavMesh Generation - Ground'));
		//slLand.Add(GetElementEditValues(e, 'Record Header\Record Flags\Multibound'));
		//slLand.Add(GetElementEditValues(e, 'Record Header\FormID'));
		slLand.Add(GetElementEditValues(e, 'DATA'));
		slLand.Add(GetElementEditValues(e, 'VNML'));
		slLand.Add(GetElementEditValues(e, 'VHGT'));
		slLand.Add(GetElementEditValues(e, 'VCLR'));
		slLand.Add(LANDLayers(e)); // multiple everything except vtxt
		slLand.Add(LandVTEX(e)); // multiple
	end;
		if GetElementEditValues(e, 'Record Header\Signature') = 'WRLD' then
	begin
		Result := 0;
		// use square brackets [] on formid to prevent Excel from treating them as a numbers
		slWrld.Add(GetLoadOrderFormID(e));
		//slWrld.Add('[' + IntToHex(FixedFormID(e), 8) + '];');
		//slWrld.Add(GetElementEditValues(e, 'Record Header\Signature'));
		//slWrld.Add(GetElementEditValues(e, 'Record Header\Record Flags\ESM'));
		//slWrld.Add(GetElementEditValues(e, 'Record Header\Record Flags\<Unknown: 1>'));
		//slWrld.Add(GetElementEditValues(e, 'Record Header\Record Flags\<Unknown: 2>'));
		//slWrld.Add(GetElementEditValues(e, 'Record Header\Record Flags\Form initialized (Runtime only)'));
		//slWrld.Add(GetElementEditValues(e, 'Record Header\Record Flags\<Unknown: 4>'));
		slWrld.Add(GetElementEditValues(e, 'Record Header\Record Flags\Deleted'));
		//slWrld.Add(GetElementEditValues(e, 'Record Header\Record Flags\Border Region / Has Tree LOD / Constant / Hidden From Local Map / Plugin Endian'));
		//slWrld.Add(GetElementEditValues(e, 'Record Header\Record Flags\Turn Off Fire'));
		//slWrld.Add(GetElementEditValues(e, 'Record Header\Record Flags\Inaccessible'));
		//slWrld.Add(GetElementEditValues(e, 'Record Header\Record Flags\Casts shadows / On Local Map / Motion Blur'));
		//slWrld.Add(GetElementEditValues(e, 'Record Header\Record Flags\Initially disabled'));
		//slWrld.Add(GetElementEditValues(e, 'Record Header\Record Flags\Ignored'));
		//slWrld.Add(GetElementEditValues(e, 'Record Header\Record Flags\No Voice Filter'));
		//slWrld.Add(GetElementEditValues(e, 'Record Header\Record Flags\Cannot Save (Runtime only)'));
		//slWrld.Add(GetElementEditValues(e, 'Record Header\Record Flags\Random Anim Start / High Priority LOD'));
		//slWrld.Add(GetElementEditValues(e, 'Record Header\Record Flags\Dangerous / Off limits (Interior cell) / Radio Station (Talking Activator)'));
		//slWrld.Add(GetElementEditValues(e, 'Record Header\Record Flags\Compressed'));
		//slWrld.Add(GetElementEditValues(e, 'Record Header\Record Flags\Can''t wait / Platform Specific Texture / Dead'));
		//slWrld.Add(GetElementEditValues(e, 'Record Header\Record Flags\Unknown 21'));
		//slWrld.Add(GetElementEditValues(e, 'Record Header\Record Flags\Load Started (Runtime Only)'));
		//slWrld.Add(GetElementEditValues(e, 'Record Header\Record Flags\Unknown 23'));
		//slWrld.Add(GetElementEditValues(e, 'Record Header\Record Flags\Unknown 24'));
		//slWrld.Add(GetElementEditValues(e, 'Record Header\Record Flags\Destructible (Runtime only)'));
		//slWrld.Add(GetElementEditValues(e, 'Record Header\Record Flags\Obstacle / No AI Acquire'));
		//slWrld.Add(GetElementEditValues(e, 'Record Header\Record Flags\NavMesh Generation - Filter'));
		//slWrld.Add(GetElementEditValues(e, 'Record Header\Record Flags\NavMesh Generation - Bounding Box'));
		//slWrld.Add(GetElementEditValues(e, 'Record Header\Record Flags\Non-Pipboy / Reflected by Auto Water'));
		//slWrld.Add(GetElementEditValues(e, 'Record Header\Record Flags\Child Can Use / Refracted by Auto Water'));
		//slWrld.Add(GetElementEditValues(e, 'Record Header\Record Flags\NavMesh Generation - Ground'));
		//slWrld.Add(GetElementEditValues(e, 'Record Header\Record Flags\Multibound'));
		//slWrld.Add(GetElementEditValues(e, 'Record Header\FormID'));
		slWrld.Add(GetElementEditValues(e, 'EDID'));
		slWrld.Add(GetElementEditValues(e, 'FULL'));
		slWrld.Add(GetElementEditValues(e, 'XEZN'));
		slWrld.Add(GetElementEditValues(e, 'Parent\WNAM'));
		slWrld.Add(GetElementEditValues(e, 'Parent\PNAM\Use Land Data'));
		slWrld.Add(GetElementEditValues(e, 'Parent\PNAM\Use LOD Data'));
		slWrld.Add(GetElementEditValues(e, 'Parent\PNAM\Use Map Data'));
		slWrld.Add(GetElementEditValues(e, 'Parent\PNAM\Use Water Data'));
		slWrld.Add(GetElementEditValues(e, 'Parent\PNAM\Use Climate Data'));
		slWrld.Add(GetElementEditValues(e, 'Parent\PNAM\Use Image Space Data'));
		slWrld.Add(GetElementEditValues(e, 'CNAM'));
		slWrld.Add(GetElementEditValues(e, 'NAM2'));
		slWrld.Add(GetElementEditValues(e, 'NAM3'));
		slWrld.Add(GetElementEditValues(e, 'NAM4'));
		slWrld.Add(GetElementEditValues(e, 'DNAM\Default Land Height'));
		slWrld.Add(GetElementEditValues(e, 'DNAM\Default Water Height'));
		slWrld.Add(GetElementEditValues(e, 'Icon\Large Icon filename'));
		//slWrld.Add(GetElementEditValues(e, 'Icon\Small Icon filename'));
		slWrld.Add(GetElementEditValues(e, 'MNAM\Usable Dimensions\X'));
		slWrld.Add(GetElementEditValues(e, 'MNAM\Usable Dimensions\Y'));
		slWrld.Add(GetElementEditValues(e, 'MNAM\Cell Coordinates\NW Cell\X'));
		slWrld.Add(GetElementEditValues(e, 'MNAM\Cell Coordinates\NW Cell\Y'));
		slWrld.Add(GetElementEditValues(e, 'MNAM\Cell Coordinates\SE Cell\X'));
		slWrld.Add(GetElementEditValues(e, 'MNAM\Cell Coordinates\SE Cell\Y'));
		slWrld.Add(GetElementEditValues(e, 'ONAM\World Map Scale'));
		slWrld.Add(GetElementEditValues(e, 'ONAM\Cell X Offset'));
		slWrld.Add(GetElementEditValues(e, 'ONAM\Cell Y Offset'));
		//slWrld.Add(GetElementEditValues(e, 'INAM'));
		//slWrld.Add(GetElementEditValues(e, 'DATA\Needs Water Adjustment'));
		slWrld.Add(GetElementEditValues(e, 'DATA\Small World'));
		slWrld.Add(GetElementEditValues(e, 'DATA\Can''t Fast Travel'));
		//slWrld.Add(GetElementEditValues(e, 'DATA\<Unknown: 2>'));
		//slWrld.Add(GetElementEditValues(e, 'DATA\<Unknown: 3>'));
		slWrld.Add(GetElementEditValues(e, 'DATA\No LOD Water'));
		//slWrld.Add(GetElementEditValues(e, 'DATA\No LOD Noise'));
		//slWrld.Add(GetElementEditValues(e, 'DATA\Don''t Allow NPC Fall Damage'));
		//slWrld.Add(GetElementEditValues(e, 'DATA\Needs Water Adjustment'));
		slWrld.Add(GetElementEditValues(e, 'Object Bounds\NAM0\X'));
		slWrld.Add(GetElementEditValues(e, 'Object Bounds\NAM0\Y'));
		slWrld.Add(GetElementEditValues(e, 'Object Bounds\NAM9\X'));
		slWrld.Add(GetElementEditValues(e, 'Object Bounds\NAM9\Y'));
		slWrld.Add(GetElementEditValues(e, 'ZNAM'));
		slWrld.Add(GetElementEditValues(e, 'NNAM'));
		slWrld.Add(GetElementEditValues(e, 'XNAM'));
		//slWrld.Add(SwappedImpacts(e)); // multiple);
		//slWrld.Add(GetElementEditValues(e, 'Swapped Impacts\IMPS\Old'));
		//slWrld.Add(GetElementEditValues(e, 'Swapped Impacts\IMPS\New'));
		//slWrld.Add(GetElementEditValues(e, 'IMPF\Unknown #0 (ConcSolid)'));
		//slWrld.Add(GetElementEditValues(e, 'IMPF\Unknown #1 (ConcBroken)'));
		//slWrld.Add(GetElementEditValues(e, 'IMPF\Unknown #2 (MetalSolid)'));
		//slWrld.Add(GetElementEditValues(e, 'IMPF\Unknown #3 (MetalHollow)'));
		//slWrld.Add(GetElementEditValues(e, 'IMPF\Unknown #4 (MetalSheet)'));
		//slWrld.Add(GetElementEditValues(e, 'IMPF\Unknown #5 (Wood)'));
		//slWrld.Add(GetElementEditValues(e, 'IMPF\Unknown #6 (Sand)'));
		//slWrld.Add(GetElementEditValues(e, 'IMPF\Unknown #7 (Dirt)'));
		//slWrld.Add(GetElementEditValues(e, 'IMPF\Unknown #8 (Grass)'));
		//slWrld.Add(GetElementEditValues(e, 'IMPF\Unknown #9 (Water)'));
		slWrld.Add(GetElementEditValues(e, 'OFST'));
	end;
	if GetElementEditValues(e, 'Record Header\Signature') = 'REFR' then
	begin
		Result := 0;
		// use square brackets [] on formid to prevent Excel from treating them as a numbers
		slRefr.Add(GetLoadOrderFormID(e));
		slRefr.Add('[' + IntToHex(FixedFormID(e), 8) + '];');
		slRefr.Add(GetElementEditValues(e, 'Cell'));
		//slRefr.Add(GetElementEditValues(e, 'Record Header\Signature'));
		//slRefr.Add(GetElementEditValues(e, 'Record Header\Record Flags\ESM'));
		//slRefr.Add(GetElementEditValues(e, 'Record Header\Record Flags\<Unknown: 1>'));
		//slRefr.Add(GetElementEditValues(e, 'Record Header\Record Flags\<Unknown: 2>'));
		//slRefr.Add(GetElementEditValues(e, 'Record Header\Record Flags\Form initialized (Runtime only)'));
		//slRefr.Add(GetElementEditValues(e, 'Record Header\Record Flags\<Unknown: 4>'));
		slRefr.Add(GetElementEditValues(e, 'Record Header\Record Flags\Deleted'));
		//slRefr.Add(GetElementEditValues(e, 'Record Header\Record Flags\Border Region / Has Tree LOD / Constant / Hidden From Local Map / Plugin Endian'));
		//slRefr.Add(GetElementEditValues(e, 'Record Header\Record Flags\Turn Off Fire'));
		//slRefr.Add(GetElementEditValues(e, 'Record Header\Record Flags\Inaccessible'));
		//slRefr.Add(GetElementEditValues(e, 'Record Header\Record Flags\Casts shadows / On Local Map / Motion Blur'));
		slRefr.Add(GetElementEditValues(e, 'Record Header\Record Flags\Quest Item / Persistent reference')); // Persistent
		slRefr.Add(GetElementEditValues(e, 'Record Header\Record Flags\Initially disabled'));
		slRefr.Add(GetElementEditValues(e, 'Record Header\Record Flags\Ignored'));
		//slRefr.Add(GetElementEditValues(e, 'Record Header\Record Flags\No Voice Filter'));
		//slRefr.Add(GetElementEditValues(e, 'Record Header\Record Flags\Cannot Save (Runtime only)'));
		slRefr.Add(GetElementEditValues(e, 'Record Header\Record Flags\Visible when distant')); // Is Full LOD
		slRefr.Add(GetElementEditValues(e, 'Record Header\Record Flags\Random Anim Start / High Priority LOD')); // Is Full LOD
		//slRefr.Add(GetElementEditValues(e, 'Record Header\Record Flags\Dangerous / Off limits (Interior cell) / Radio Station (Talking Activator)'));
		//slRefr.Add(GetElementEditValues(e, 'Record Header\Record Flags\Compressed'));
		//slRefr.Add(GetElementEditValues(e, 'Record Header\Record Flags\Can''t wait / Platform Specific Texture / Dead'));
		//slRefr.Add(GetElementEditValues(e, 'Record Header\Record Flags\Unknown 21'));
		//slRefr.Add(GetElementEditValues(e, 'Record Header\Record Flags\Load Started (Runtime Only)'));
		//slRefr.Add(GetElementEditValues(e, 'Record Header\Record Flags\Unknown 23'));
		//slRefr.Add(GetElementEditValues(e, 'Record Header\Record Flags\Unknown 24'));
		//slRefr.Add(GetElementEditValues(e, 'Record Header\Record Flags\Destructible (Runtime only)'));
		slRefr.Add(GetElementEditValues(e, 'Record Header\Record Flags\Obstacle / No AI Acquire')); // No AI Acquire
		//slRefr.Add(GetElementEditValues(e, 'Record Header\Record Flags\NavMesh Generation - Filter'));
		//slRefr.Add(GetElementEditValues(e, 'Record Header\Record Flags\NavMesh Generation - Bounding Box'));
		slRefr.Add(GetElementEditValues(e, 'Record Header\Record Flags\Non-Pipboy / Reflected by Auto Water')); // Relected By Auto Water
		//slRefr.Add(GetElementEditValues(e, 'Record Header\Record Flags\Child Can Use / Refracted by Auto Water'));
		//slRefr.Add(GetElementEditValues(e, 'Record Header\Record Flags\NavMesh Generation - Ground'));
		slRefr.Add(GetElementEditValues(e, 'Record Header\Record Flags\Multibound'));
		//slRefr.Add(GetElementEditValues(e, 'Record Header\FormID'));
		slRefr.Add(GetElementEditValues(e, 'EDID'));
		slRefr.Add(GetElementEditValues(e, 'NAME'));
		slRefr.Add(GetElementEditValues(e, 'XEZN'));
		slRefr.Add(GetElementEditValues(e, 'XRGD'));
		slRefr.Add(GetElementEditValues(e, 'XRGB'));
		slRefr.Add(GetElementEditValues(e, 'XPRM\Bounds\X'));
		slRefr.Add(GetElementEditValues(e, 'XPRM\Bounds\Y'));
		slRefr.Add(GetElementEditValues(e, 'XPRM\Bounds\Z'));
		slRefr.Add(GetElementEditValues(e, 'XPRM\Color\Red'));
		slRefr.Add(GetElementEditValues(e, 'XPRM\Color\Green'));
		slRefr.Add(GetElementEditValues(e, 'XPRM\Color\Blue'));
		slRefr.Add(GetElementEditValues(e, 'XPRM\Unknown'));
		slRefr.Add(GetElementEditValues(e, 'XPRM\Type'));
		slRefr.Add(GetElementEditValues(e, 'XTRI'));
		slRefr.Add(GetElementEditValues(e, 'XMBP'));
		slRefr.Add(GetElementEditValues(e, 'XMBO\X'));
		slRefr.Add(GetElementEditValues(e, 'XMBO\Y'));
		slRefr.Add(GetElementEditValues(e, 'XMBO\Z'));
		slRefr.Add(GetElementEditValues(e, 'XTEL\Door'));
		slRefr.Add(GetElementEditValues(e, 'XTEL\Position/Rotation\Position\X'));
		slRefr.Add(GetElementEditValues(e, 'XTEL\Position/Rotation\Position\Y'));
		slRefr.Add(GetElementEditValues(e, 'XTEL\Position/Rotation\Position\Z'));
		slRefr.Add(GetElementEditValues(e, 'XTEL\Position/Rotation\Rotation\X'));
		slRefr.Add(GetElementEditValues(e, 'XTEL\Position/Rotation\Rotation\Y'));
		slRefr.Add(GetElementEditValues(e, 'XTEL\Position/Rotation\Rotation\Z'));
		slRefr.Add(GetElementEditValues(e, 'XTEL\Flags\No Alarm')); //no transition interior
		slRefr.Add(GetElementEditValues(e, 'Map Marker\XMRK'));
		slRefr.Add(GetElementEditValues(e, 'Map Marker\FNAM\Visible'));
		slRefr.Add(GetElementEditValues(e, 'Map Marker\FNAM\Can Travel To'));
		slRefr.Add(GetElementEditValues(e, 'Map Marker\FNAM\"Show All" Hidden'));
		slRefr.Add(GetElementEditValues(e, 'Map Marker\FULL'));
		slRefr.Add(GetElementEditValues(e, 'Map Marker\TNAM\Type'));
		//slRefr.Add(GetElementEditValues(e, 'Map Marker\WMI1')); // possibly xnrk
		//slRefr.Add(GetElementEditValues(e, 'Audio Data\MMRK'));
		//slRefr.Add(GetElementEditValues(e, 'Audio Data\FULL'));
		//slRefr.Add(GetElementEditValues(e, 'Audio Data\CNAM'));
		//slRefr.Add(GetElementEditValues(e, 'Audio Data\BNAM\Use Controller Values'));
		//slRefr.Add(GetElementEditValues(e, 'Audio Data\MNAM'));
		//slRefr.Add(GetElementEditValues(e, 'Audio Data\NNAM'));
		//slRefr.Add(GetElementEditValues(e, 'XSRF\Unknown 0'));
		//slRefr.Add(GetElementEditValues(e, 'XSRF\Imposter'));
		//slRefr.Add(GetElementEditValues(e, 'XSRF\Use Full Shader in LOD'));
		//slRefr.Add(GetElementEditValues(e, 'XSRD'));
		//slRefr.Add(GetElementEditValues(e, 'XTRG'));
		//slRefr.Add(GetElementEditValues(e, 'XLCM'));
		//slRefr.Add(GetElementEditValues(e, 'Patrol Data\XPRD')); Complex Patrol
		//slRefr.Add(GetElementEditValues(e, 'Patrol Data\XPPA'));
		//slRefr.Add(GetElementEditValues(e, 'Patrol Data\INAM'));
		//slRefr.Add(GetElementEditValues(e, 'Patrol Data\Embedded Script\SCHR\Refcount'));
		//slRefr.Add(GetElementEditValues(e, 'Patrol Data\Embedded Script\SCHR\CompiledSize'));
		//slRefr.Add(GetElementEditValues(e, 'Patrol Data\Embedded Script\SCHR\VariableCount'));
		//slRefr.Add(GetElementEditValues(e, 'Patrol Data\Embedded Script\SCHR\Type'));
		//slRefr.Add(GetElementEditValues(e, 'Patrol Data\Embedded Script\SCHR\Flags\Enabled'));
		//slRefr.Add(GetElementEditValues(e, 'Patrol Data\Embedded Script\SCDA'));
		//slRefr.Add(GetElementEditValues(e, 'Patrol Data\Embedded Script\SCTX'));
		//slRefr.Add(PatrolData1(e)); // multiple);
		//slRefr.Add(PatrolData2(e)); // multiple);
		//slRefr.Add(GetElementEditValues(e, 'Patrol Data\TNAM'));
		//slRefr.Add(GetElementEditValues(e, 'XRDO\Range Radius')); Complex
		//slRefr.Add(GetElementEditValues(e, 'XRDO\Broadcast Range Type'));
		//slRefr.Add(GetElementEditValues(e, 'XRDO\Static Percentage'));
		//slRefr.Add(GetElementEditValues(e, 'XRDO\Position Reference'));
		slRefr.Add(GetElementEditValues(e, 'Ownership\XOWN')); // XOWN/Owner
		//slRefr.Add(GetElementEditValues(e, 'Ownership\XRNK'));
		slRefr.Add(GetElementEditValues(e, 'XLOC\Level'));
		slRefr.Add(GetElementEditValues(e, 'XLOC\Key'));
		slRefr.Add(GetElementEditValues(e, 'XLOC\Flags\Leveled Lock'));
		slRefr.Add(GetElementEditValues(e, 'XLOC\Unknown'));
		slRefr.Add(GetElementEditValues(e, 'XCNT'));
		slRefr.Add(GetElementEditValues(e, 'XRDS'));
		//slRefr.Add(GetElementEditValues(e, 'XHLP')); // complex XHLT
		//slRefr.Add(GetElementEditValues(e, 'XRAD'));
		//slRefr.Add(GetElementEditValues(e, 'XCHG'));
		//slRefr.Add(GetElementEditValues(e, 'Ammo\XAMT'));
		slRefr.Add(GetElementEditValues(e, 'Ammo\XAMC')); // XAMC
		//slRefr.Add(ReflectedRefractedBy(e)); // multiple);
		//slRefr.Add(LitWater(e)); // multiple);
		//slRefr.Add(LinkedDecals(e)); // multiple);
		//slRefr.Add(GetElementEditValues(e, 'XLKR')); //Linked References/XLKR/Ref Complex or XATR
		//slRefr.Add(GetElementEditValues(e, 'XCLP\Link Start Color\Red'));
		//slRefr.Add(GetElementEditValues(e, 'XCLP\Link Start Color\Green'));
		//slRefr.Add(GetElementEditValues(e, 'XCLP\Link Start Color\Blue'));
		//slRefr.Add(GetElementEditValues(e, 'XCLP\Link End Color\Red'));
		//slRefr.Add(GetElementEditValues(e, 'XCLP\Link End Color\Green'));
		//slRefr.Add(GetElementEditValues(e, 'XCLP\Link End Color\Blue'));
		//slRefr.Add(GetElementEditValues(e, 'Activate Parents\XADP\Parent Activate Only')); Complex
		//slRefr.Add(ActivateParents(e)); // multiple);
		//slRefr.Add(GetElementEditValues(e, 'XATO')); Possibly XATP
		slRefr.Add(GetElementEditValues(e, 'XESP\Reference'));
		slRefr.Add(GetElementEditValues(e, 'XESP\Flags\Set Enable State to Opposite of Parent'));
		slRefr.Add(GetElementEditValues(e, 'XESP\Flags\Pop In'));
		slRefr.Add(GetElementEditValues(e, 'XEMI'));
		slRefr.Add(GetElementEditValues(e, 'XMBR'));
		slRefr.Add(GetElementEditValues(e, 'XACT\Use Default'));
		slRefr.Add(GetElementEditValues(e, 'XACT\Activate'));
		slRefr.Add(GetElementEditValues(e, 'XACT\Open'));
		slRefr.Add(GetElementEditValues(e, 'XACT\Open by Default'));
		slRefr.Add(GetElementEditValues(e, 'ONAM'));
		slRefr.Add(GetElementEditValues(e, 'XIBS')); // XIS2
		slRefr.Add(GetElementEditValues(e, 'XNDP\Navigation Mesh'));
		slRefr.Add(GetElementEditValues(e, 'XNDP\Teleport Marker Triangle'));
		//slRefr.Add(GetElementEditValues(e, 'XPOD\Room #0')); // complex
		//slRefr.Add(GetElementEditValues(e, 'XPOD\Room #1'));
		//slRefr.Add(GetElementEditValues(e, 'XPTL\Size\Width'));
		//slRefr.Add(GetElementEditValues(e, 'XPTL\Size\Height'));
		//slRefr.Add(GetElementEditValues(e, 'XPTL\Position\X'));
		//slRefr.Add(GetElementEditValues(e, 'XPTL\Position\Y'));
		//slRefr.Add(GetElementEditValues(e, 'XPTL\Position\Z'));
		//slRefr.Add(GetElementEditValues(e, 'XPTL\Rotation (Quaternion?)\q1'));
		//slRefr.Add(GetElementEditValues(e, 'XPTL\Rotation (Quaternion?)\q2'));
		//slRefr.Add(GetElementEditValues(e, 'XPTL\Rotation (Quaternion?)\q3'));
		//slRefr.Add(GetElementEditValues(e, 'XPTL\Rotation (Quaternion?)\q4'));
		//slRefr.Add(GetElementEditValues(e, 'XSED'));
		//slRefr.Add(GetElementEditValues(e, 'Room Data\XRMR\Linked Rooms Count')); // possibly Bound Data
		//slRefr.Add(GetElementEditValues(e, 'Room Data\XRMR\Unknown'));
		//slRefr.Add(RoomData(e)); // multiple);
		slRefr.Add(GetElementEditValues(e, 'XOCP\Size\Width'));
		slRefr.Add(GetElementEditValues(e, 'XOCP\Size\Height'));
		slRefr.Add(GetElementEditValues(e, 'XOCP\Position\X'));
		slRefr.Add(GetElementEditValues(e, 'XOCP\Position\Y'));
		slRefr.Add(GetElementEditValues(e, 'XOCP\Position\Z'));
		slRefr.Add(GetElementEditValues(e, 'XOCP\Rotation (Quaternion?)\q1'));
		slRefr.Add(GetElementEditValues(e, 'XOCP\Rotation (Quaternion?)\q2'));
		slRefr.Add(GetElementEditValues(e, 'XOCP\Rotation (Quaternion?)\q3'));
		slRefr.Add(GetElementEditValues(e, 'XOCP\Rotation (Quaternion?)\q4'));
		//slRefr.Add(GetElementEditValues(e, 'XORD\Plane #0 (Right)')); Exists but unknown effect
		//slRefr.Add(GetElementEditValues(e, 'XORD\Plane #1 (Left)'));
		//slRefr.Add(GetElementEditValues(e, 'XORD\Plane #2 (Bottom)'));
		//slRefr.Add(GetElementEditValues(e, 'XORD\Plane #3 (Top)'));
		slRefr.Add(GetElementEditValues(e, 'XLOD\Unknown #0'));
		slRefr.Add(GetElementEditValues(e, 'XLOD\Unknown #1'));
		slRefr.Add(GetElementEditValues(e, 'XLOD\Unknown #2'));
		slRefr.Add(GetElementEditValues(e, 'XSCL'));
		slRefr.Add(GetElementEditValues(e, 'DATA\Position\X'));
		slRefr.Add(GetElementEditValues(e, 'DATA\Position\Y'));
		slRefr.Add(GetElementEditValues(e, 'DATA\Position\Z'));
		slRefr.Add(GetElementEditValues(e, 'DATA\Rotation\X'));
		slRefr.Add(GetElementEditValues(e, 'DATA\Rotation\Y'));
		slRefr.Add(GetElementEditValues(e, 'DATA\Rotation\Z'));
	end;
		if GetElementEditValues(e, 'Record Header\Signature') = 'CELL' then
	begin
		Result := 0;
		// use square brackets [] on formid to prevent Excel from treating them as a numbers
		slWeap.Add(GetLoadOrderFormID(e));
		//slWeap.Add('[' + IntToHex(FixedFormID(e), 8) + '];');
		slWeap.Add(GetElementEditValues(e, 'Worldspace'));
		slRefr.Add(GetElementEditValues(e, 'Record Header\Record Flags\Deleted'));
		slRefr.Add(GetElementEditValues(e, 'Record Header\Record Flags\Quest Item / Persistent reference')); // Persistent
		slRefr.Add(GetElementEditValues(e, 'Record Header\Record Flags\Ignored'));
		slRefr.Add(GetElementEditValues(e, 'Record Header\Record Flags\Inaccessible')); // Off Limits // (Not Sure)
		slRefr.Add(GetElementEditValues(e, 'Record Header\Record Flags\Compressed'));
		slRefr.Add(GetElementEditValues(e, 'Record Header\Record Flags\Can''t wait / Platform Specific Texture / Dead')); // Can''t Wait
		slWeap.Add(GetElementEditValues(e, 'EDID'));
		slWeap.Add(GetElementEditValues(e, 'FULL'));
		slWeap.Add(GetElementEditValues(e, 'DATA\Is Interior Cell'));
		slWeap.Add(GetElementEditValues(e, 'DATA\Has Water'));
		slWeap.Add(GetElementEditValues(e, 'DATA\Invert Fast Travel behavior')); // Can''t Travel From Here
		slWeap.Add(GetElementEditValues(e, 'DATA\No LOD Water'));
		slWeap.Add(GetElementEditValues(e, 'DATA\Public place')); // Public Area
		slWeap.Add(GetElementEditValues(e, 'DATA\Hand Changed'));
		//slWeap.Add(GetElementEditValues(e, 'DATA\Behave like exterior'));
		slWeap.Add(GetElementEditValues(e, 'XCLC\X'));
		slWeap.Add(GetElementEditValues(e, 'XCLC\Y'));
		slWeap.Add(GetElementEditValues(e, 'XCLC\Force Hide Land\Quad 1'));
		slWeap.Add(GetElementEditValues(e, 'XCLC\Force Hide Land\Quad 2'));
		slWeap.Add(GetElementEditValues(e, 'XCLC\Force Hide Land\Quad 3'));
		slWeap.Add(GetElementEditValues(e, 'XCLC\Force Hide Land\Quad 4'));
		slWeap.Add(GetElementEditValues(e, 'XCLL\Ambient Color\Red'));
		slWeap.Add(GetElementEditValues(e, 'XCLL\Ambient Color\Green'));
		slWeap.Add(GetElementEditValues(e, 'XCLL\Ambient Color\Blue'));
		slWeap.Add(GetElementEditValues(e, 'XCLL\Directional Color\Red'));
		slWeap.Add(GetElementEditValues(e, 'XCLL\Directional Color\Green'));
		slWeap.Add(GetElementEditValues(e, 'XCLL\Directional Color\Blue'));
		slWeap.Add(GetElementEditValues(e, 'XCLL\Fog Color\Red'));  //XCLL\Fog Color Far[Color] // XCLL\Fog Color Near[Color] // XCLL\Fog Color High Near[Color] // XCLL\Fog Color High Far[Color]
		slWeap.Add(GetElementEditValues(e, 'XCLL\Fog Color\Green'));
		slWeap.Add(GetElementEditValues(e, 'XCLL\Fog Color\Blue'));
		slWeap.Add(GetElementEditValues(e, 'XCLL\Fog Near')); 
		slWeap.Add(GetElementEditValues(e, 'XCLL\Fog Far'));
		slWeap.Add(GetElementEditValues(e, 'XCLL\Directional Rotation XY'));
		slWeap.Add(GetElementEditValues(e, 'XCLL\Directional Rotation Z'));
		slWeap.Add(GetElementEditValues(e, 'XCLL\Directional Fade'));
		slWeap.Add(GetElementEditValues(e, 'XCLL\Fog Clip Dist')); // Fog Clip Distance
		slWeap.Add(GetElementEditValues(e, 'XCLL\Fog Power'));
		//slWeap.Add(GetElementEditValues(e, 'IMPF\Unknown #0 (ConcSolid)'));
		//slWeap.Add(GetElementEditValues(e, 'IMPF\Unknown #1 (ConcBroken)'));
		//slWeap.Add(GetElementEditValues(e, 'IMPF\Unknown #2 (MetalSolid)'));
		//slWeap.Add(GetElementEditValues(e, 'IMPF\Unknown #3 (MetalHollow)'));
		//slWeap.Add(GetElementEditValues(e, 'IMPF\Unknown #4 (MetalSheet)'));
		//slWeap.Add(GetElementEditValues(e, 'IMPF\Unknown #5 (Wood)'));
		//slWeap.Add(GetElementEditValues(e, 'IMPF\Unknown #6 (Sand)'));
		//slWeap.Add(GetElementEditValues(e, 'IMPF\Unknown #7 (Dirt)'));
		//slWeap.Add(GetElementEditValues(e, 'IMPF\Unknown #8 (Grass)'));
		//slWeap.Add(GetElementEditValues(e, 'IMPF\Unknown #9 (Water)'));
		slWeap.Add(GetElementEditValues(e, 'Light Template\LTMP')); // LTMP
		slWeap.Add(GetElementEditValues(e, 'Light Template\LNAM\Ambient Color'));
		//slWeap.Add(GetElementEditValues(e, 'Light Template\LNAM\Directional Color'));
		//slWeap.Add(GetElementEditValues(e, 'Light Template\LNAM\Fog Color'));
		//slWeap.Add(GetElementEditValues(e, 'Light Template\LNAM\Fog Near'));
		//slWeap.Add(GetElementEditValues(e, 'Light Template\LNAM\Fog Far'));
		//slWeap.Add(GetElementEditValues(e, 'Light Template\LNAM\Directional Rotation'));
		//slWeap.Add(GetElementEditValues(e, 'Light Template\LNAM\Directional Fade'));
		//slWeap.Add(GetElementEditValues(e, 'Light Template\LNAM\Clip Distance'));
		//slWeap.Add(GetElementEditValues(e, 'Light Template\LNAM\Fog Power'));
		slWeap.Add(GetElementEditValues(e, 'XCLW'));
		slWeap.Add(GetElementEditValues(e, 'XNAM')); // XWEM
		//slWeap.Add(CELLRegions(e)); //multiple); Complex
		slWeap.Add(GetElementEditValues(e, 'XCIM'));
		slWeap.Add(GetElementEditValues(e, 'XEZN'));
		slWeap.Add(GetElementEditValues(e, 'XCCM'));
		slWeap.Add(GetElementEditValues(e, 'XCWT'));
		slWeap.Add(GetElementEditValues(e, 'Ownership\XOWN')); // XOWN
		slWeap.Add(GetElementEditValues(e, 'Ownership\XRNK')); // XRNK
		slWeap.Add(GetElementEditValues(e, 'XCAS'));
		slWeap.Add(GetElementEditValues(e, 'XCMO'));
	end;
end;
	

function Finalize: integer;
var
  dlgSave: TSaveDialog;
begin
  Result := 0;
  
  if not Assigned(slWeap) then
    Exit;
    
  // save export file only if we have any data besides header line
  begin
    // ask for file to export to
    dlgSave := TSaveDialog.Create(nil);
    dlgSave.Options := dlgSave.Options + [ofOverwritePrompt];
    dlgSave.Filter := 'Spreadsheet files (*.csv)|*.csv';
    dlgSave.InitialDir := ProgramPath;
    dlgSave.FileName := 'worldspace.csv';
    if dlgSave.Execute then
      slWeap.SaveToFile(dlgSave.FileName);
    dlgSave.Free;
  end;
  begin
    // ask for file to export to
    dlgSave := TSaveDialog.Create(nil);
    dlgSave.Options := dlgSave.Options + [ofOverwritePrompt];
    dlgSave.Filter := 'Spreadsheet files (*.csv)|*.csv';
    dlgSave.InitialDir := ProgramPath;
    dlgSave.FileName := 'wrld.csv';
    if dlgSave.Execute then
      slWrld.SaveToFile(dlgSave.FileName);
    dlgSave.Free;
  end;
  begin
    // ask for file to export to
    dlgSave := TSaveDialog.Create(nil);
    dlgSave.Options := dlgSave.Options + [ofOverwritePrompt];
    dlgSave.Filter := 'Spreadsheet files (*.csv)|*.csv';
    dlgSave.InitialDir := ProgramPath;
    dlgSave.FileName := 'refr.csv';
    if dlgSave.Execute then
      slRefr.SaveToFile(dlgSave.FileName);
    dlgSave.Free;
  end;
  begin
    // ask for file to export to
    dlgSave := TSaveDialog.Create(nil);
    dlgSave.Options := dlgSave.Options + [ofOverwritePrompt];
    dlgSave.Filter := 'Spreadsheet files (*.csv)|*.csv';
    dlgSave.InitialDir := ProgramPath;
    dlgSave.FileName := 'land.csv';
    if dlgSave.Execute then
      slLand.SaveToFile(dlgSave.FileName);
    dlgSave.Free;
  end;
  begin
    // ask for file to export to
    dlgSave := TSaveDialog.Create(nil);
    dlgSave.Options := dlgSave.Options + [ofOverwritePrompt];
    dlgSave.Filter := 'Spreadsheet files (*.csv)|*.csv';
    dlgSave.InitialDir := ProgramPath;
    dlgSave.FileName := 'navm.csv';
    if dlgSave.Execute then
      slNavm.SaveToFile(dlgSave.FileName);
    dlgSave.Free;
  end;
  begin
    // ask for file to export to
    dlgSave := TSaveDialog.Create(nil);
    dlgSave.Options := dlgSave.Options + [ofOverwritePrompt];
    dlgSave.Filter := 'Spreadsheet files (*.csv)|*.csv';
    dlgSave.InitialDir := ProgramPath;
    dlgSave.FileName := 'achr.csv';
    if dlgSave.Execute then
      slAchr.SaveToFile(dlgSave.FileName);
    dlgSave.Free;
  end;
  begin
    // ask for file to export to
    dlgSave := TSaveDialog.Create(nil);
    dlgSave.Options := dlgSave.Options + [ofOverwritePrompt];
    dlgSave.Filter := 'Spreadsheet files (*.csv)|*.csv';
    dlgSave.InitialDir := ProgramPath;
    dlgSave.FileName := 'acre.csv';
    if dlgSave.Execute then
      slAcre.SaveToFile(dlgSave.FileName);
    dlgSave.Free;
  end;

  slWeap.Free;
  slWrld.Free;
  slRefr.Free;
  slLand.Free;
  slNavm.Free;
  slAchr.Free;
  slAcre.Free;
 end;

end.