for i := 0 to (slAcre.count div 39) do
begin
		Result := 0;
		kwda := wbCopyElementToFile(e, ToFile, True, False);
		// use square brackets [] on formid to prevent Excel from treating them as a numbers
		//SetLoadOrderFormID(e, slAcre[i * 39 - 39]);
		//SetLoadOrderFormID(LastElement(GetContainer(e)), slWeap[s]);
		(SetElementEditValues(kwda, 'Record Header\Record Flags\Deleted', 																				slAcre[i * 39 - 38]));
		(SetElementEditValues(kwda, 'Record Header\Record Flags\Ignored', 																				slAcre[i * 39 - 38]));
		(SetElementEditValues(kwda, 'Record Header\Record Flags\Compressed', 																				slAcre[i * 39 - 38]));
		(SetElementEditValues(kwda, 'EDID', 																											slAcre[i * 39 - 37]));
		(SetElementEditValues(kwda, 'NAME', 																											slAcre[i * 39 - 36]));
		(SetElementEditValues(kwda, 'XEZN', 																											slAcre[i * 39 - 35]));
		(SetElementEditValues(kwda, 'XRGD', 																											slAcre[i * 39 - 35]));
		(SetElementEditValues(kwda, 'XRGB', 																										slAcre[i * 39 - 34]));
		(SetElementEditValues(kwda, 'XLCM', 																										slAcre[i * 39 - 34]));
		(SetElementEditValues(kwda, 'Ownership\XOWN', 																										slAcre[i * 39 - 34]));
		(SetElementEditValues(kwda, 'Ownership\XRNK', 																										slAcre[i * 39 - 34]));
		(SetElementEditValues(kwda, 'XMRC', 																										slAcre[i * 39 - 34]));
		(SetElementEditValues(kwda, 'XCNT', 																										slAcre[i * 39 - 34]));
		(SetElementEditValues(kwda, 'XRDS', 																										slAcre[i * 39 - 34]));
		(SetElementEditValues(kwda, 'XHLP', 																										slAcre[i * 39 - 34]));
		(SetElementEditValues(kwda, 'XLKR', 																										slAcre[i * 39 - 34]));
		(SetElementEditValues(kwda, 'XCLP\Link Start Color\Red', 																										slAcre[i * 39 - 34]));
		(SetElementEditValues(kwda, 'XCLP\Link Start Color\Green', 																										slAcre[i * 39 - 34]));
		(SetElementEditValues(kwda, 'XCLP\Link Start Color\Blue', 																										slAcre[i * 39 - 34]));
		(SetElementEditValues(kwda, 'XCLP\Link End Color\Red', 																										slAcre[i * 39 - 34]));
		(SetElementEditValues(kwda, 'XCLP\Link End Color\Green', 																										slAcre[i * 39 - 34]));
		(SetElementEditValues(kwda, 'XCLP\Link End Color\Blue', 																										slAcre[i * 39 - 34]));
		(SetElementEditValues(kwda, 'Activate Parents\XADP\Parent Activate Only', 																										slAcre[i * 39 - 34]));
		slValues 		:= TStringList.Create;
		slValues.Delimiter := ';';
		slValues := slAcre[i * 39 - ]
		// slValues[0] = number of elements
		// slValues[1] = Element with said number
		// slValues ex = [2;Element;ElementWithinElement;Value;]
		if slValues[0] <> '0' then
		begin
			if not ElementExists(e, 'Activate Parents') then
				Add(e, 'Activate Parents', True);
			subkwda := ElementByPath(e, slValues[1]);
			//if not Assigned(subkwda) then
			//	subkwda := Add(e, slValues[1], True);
			l := (((slValues.Count - 2) div 2) div StrToInt(slValues[0]) - 1) //values per element -1 for index
			for j := 1 {0 is the count, 1 is the element} to StrToInt(slValues[0]) {StrToInt(slValues[0])} do
			begin
				ElementAssign(subkwda, HighInteger, nil, False);
				for k := 0 to l do
				begin
					// j * 2 = first path
					SetElementEditValues((ElementByIndex(subkwda, (j - 1)), slValues[j * 2 + k * 2 + 1]), slValues[j * 2 + k * 2]);
				end;
			end;
		end;
		if not ElementExists(e, 'KSIZ') then
			Add(e, 'KSIZ', True);
		SetElementNativeValues(e, 'KSIZ', ElementCount(kwda));
		kwda := ElementBySignature(e, 'KWDA');
		if not Assigned(kwda) then
			kwda := Add(e, 'KWDA', True);
		(SetElementEditValues(kwda, 'XATO', 																										slAcre[i * 39 - 34]));
		(SetElementEditValues(kwda, 'XESP\Reference', 																										slAcre[i * 39 - 34]));
		(SetElementEditValues(kwda, 'XESP\Flags\Set Enable State to Opposite of Parent', 																										slAcre[i * 39 - 34]));
		(SetElementEditValues(kwda, 'XESP\Flags\Pop In', 																										slAcre[i * 39 - 34]));
		(SetElementEditValues(kwda, 'XEMI', 																										slAcre[i * 39 - 34]));
		(SetElementEditValues(kwda, 'XMBR', 																										slAcre[i * 39 - 34]));
		(SetElementEditValues(kwda, 'XIBS', 																										slAcre[i * 39 - 34]));
		(SetElementEditValues(kwda, 'XSCL', 																										slAcre[i * 39 - 34]));
		(SetElementEditValues(kwda, 'DATA\Position\X', 																										slAcre[i * 39 - 34]));
		(SetElementEditValues(kwda, 'DATA\Position\Y', 																										slAcre[i * 39 - 34]));
		(SetElementEditValues(kwda, 'DATA\Position\Z', 																										slAcre[i * 39 - 34]));
		(SetElementEditValues(kwda, 'DATA\Rotation\X', 																										slAcre[i * 39 - 34]));
		(SetElementEditValues(kwda, 'DATA\Rotation\Y', 																										slAcre[i * 39 - 34]));
		(SetElementEditValues(kwda, 'DATA\Rotation\Z', 																										slAcre[i * 39 - 34]));
		SetLoadOrderFormID(kwda, slAcre[i * 39 - 39]);
end;
end.