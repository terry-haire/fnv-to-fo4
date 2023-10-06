for i := 0 to (slWrld.count div 39) do
begin
		Result := 0;
		kwda := wbCopyElementToFile(e, ToFile, True, False)
		// use square brackets [] on formid to prevent Excel from treating them as a numbers
		//SetLoadOrderFormID(e, slWrld[i * 39 - 39]);
		//SetLoadOrderFormID(LastElement(GetContainer(e)), slWeap[s]);
		(SetElementEditValues(kwda, 'Record Header\Record Flags\Deleted', 																				slWrld[i * 39 - 38]));
		(SetElementEditValues(kwda, 'EDID', 																											slWrld[i * 39 - 37]));
		(SetElementEditValues(kwda, 'FULL', 																											slWrld[i * 39 - 36]));
		(SetElementEditValues(kwda, 'XEZN', 																											slWrld[i * 39 - 35]));
		(SetElementEditValues(kwda, 'Parent\WNAM', 																										slWrld[i * 39 - 34]));
		(SetElementEditValues(kwda, 'Parent\PNAM\Flags\Use Land Data', 																					slWrld[i * 39 - 33]));
		(SetElementEditValues(kwda, 'Parent\PNAM\Flags\Use LOD Data', 																					slWrld[i * 39 - 32]));
		if slWrld[i * 39 - 31] = '1' then val := '0'                                                                                                           
		(SetElementEditValues(kwda, 'Parent\PNAM\Flags\Don''t Use Map Data', 																			val));     
		(SetElementEditValues(kwda, 'Parent\PNAM\Flags\Use Water Data', 																				slWrld[i * 39 - 30]));
		(SetElementEditValues(kwda, 'Parent\PNAM\Flags\Use Climate Data', 																				slWrld[i * 39 - 29]));
		(SetElementEditValues(kwda, 'Parent\PNAM\Flags\Use Image Space Data (unused)', 																	slWrld[i * 39 - 28]));
		(SetElementEditValues(kwda, 'CNAM', 																											slWrld[i * 39 - 27]));
		(SetElementEditValues(kwda, 'NAM2', 																											slWrld[i * 39 - 26]));
		(SetElementEditValues(kwda, 'NAM3', 																											slWrld[i * 39 - 25]));
		(SetElementEditValues(kwda, 'NAM4', 																											slWrld[i * 39 - 24]));
		(SetElementEditValues(kwda, 'DNAM\Default Land Height', 																						slWrld[i * 39 - 23]));
		(SetElementEditValues(kwda, 'DNAM\Default Water Height',																						slWrld[i * 39 - 22]));
		(SetElementEditValues(kwda, 'ICON', 																											slWrld[i * 39 - 21]));
		(SetElementEditValues(kwda, 'MNAM\Usable Dimensions\X', 																						slWrld[i * 39 - 20]));
		(SetElementEditValues(kwda, 'MNAM\Usable Dimensions\Y', 																						slWrld[i * 39 - 19]));
		(SetElementEditValues(kwda, 'MNAM\Cell Coordinates\NW Cell\X', 																					slWrld[i * 39 - 18]));
		(SetElementEditValues(kwda, 'MNAM\Cell Coordinates\NW Cell\Y', 																					slWrld[i * 39 - 17]));
		(SetElementEditValues(kwda, 'MNAM\Cell Coordinates\SE Cell\X', 																					slWrld[i * 39 - 16]));
		(SetElementEditValues(kwda, 'MNAM\Cell Coordinates\SE Cell\Y', 																					slWrld[i * 39 - 15]));
		(SetElementEditValues(kwda, 'ONAM\World Map Scale', 																							slWrld[i * 39 - 14]));
		(SetElementEditValues(kwda, 'ONAM\Cell X Offset', 																								slWrld[i * 39 - 13]));
		(SetElementEditValues(kwda, 'ONAM\Cell Y Offset', 																								slWrld[i * 39 - 12]));
		(SetElementEditValues(kwda, 'ONAM\Cell Z Offset', 																								'0'));     
		(SetElementEditValues(kwda, 'DATA\Small World', 																								slWrld[i * 39 - 11]));
		(SetElementEditValues(kwda, 'DATA\Can''t Fast Travel', 																							slWrld[i * 39 - 10]));
		(SetElementEditValues(kwda, 'DATA\No LOD Water', 																								slWrld[i * 39 - 9]));
		(SetElementEditValues(kwda, 'Object Bounds\NAM0\X', 																							slWrld[i * 39 - 8]));
		(SetElementEditValues(kwda, 'Object Bounds\NAM0\Y', 																							slWrld[i * 39 - 7]));
		(SetElementEditValues(kwda, 'Object Bounds\NAM9\X', 																							slWrld[i * 39 - 6]));
		(SetElementEditValues(kwda, 'Object Bounds\NAM9\Y', 																							slWrld[i * 39 - 5]));
		(SetElementEditValues(kwda, 'ZNAM', 																											slWrld[i * 39 - 4]));
		(SetElementEditValues(kwda, 'NNAM', 																											slWrld[i * 39 - 3]));
		(SetElementEditValues(kwda, 'XWEM', 																											slWrld[i * 39 - 2]));
		(SetElementEditValues(kwda, 'OFST', 																											slWrld[i * 39 - 1]));
		SetLoadOrderFormID(kwda, slWrld[i * 39 - 39]);