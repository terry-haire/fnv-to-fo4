function hvkVertexPaintingTools_CreateVertexPaintingOnChannel theNode channelID channelName = 
(
	select theNode

	-- create a VertexPaint modifier 
	vpMod = VertexPaint ()
	
	-- color by vertex (0 is by face)
	vpMod.colorBy = 1	
	-- set the map channel
	vpMod.mapChannel = channelID
	-- set object properties 
	theNode.showVertexColors = on
	theNode.vertexColorType = 5
	theNode.vertexColorMapChannel = channelID
	
	-- add the vertex paint modifier
	addModifier theNode vpMod
	-- set the mod as the active one
	hvkCommon_selectModifier vpMod 
	
	vpMod.name = hvkVertexPaintingTools_FormatModifierNameFromChannelName channelName
	
	return vpMod
)

function hvkVertexPaintingTools_FormatModifierNameFromChannelName channelName = 
(
	local modName = "VP_" + channelName
	return modName
)

function hvkVertexPaintingTools_GetVertexPaintModWithChannel theNode channelID = 
(
	for theMod in theNode.modifiers do
	(
		if (classOf theMod == VertexPaint and theMod.mapChannel == channelID ) do
		(
			return theMod
		)
	)

	return undefined
)

function hvkVertexPaintingTools_GetHavokExportChannelModWithChannelAndName theNode channelID channelExportName = 
(
	for theMod in theNode.modifiers do
	(
		if ( classOf theMod == Havok_Export_Channel and theMod.channelID == channelID and theMod.channelExportName == channelExportName ) do
		(
			return theMod
		)
	)

	return undefined
)

function hvkVertexPaintingTools_GetAllHavokExportChannelModifiersWithChannel theNode channelID = 
(
	local res = #()
	for theMod in theNode.modifiers do
	(
		if ( classOf theMod == Havok_Export_Channel and theMod.channelID == channelID ) do
		(
			res = append res theMod
		)
	)

	return res
)

function hvkVertexPaintingTools_RemoveMappingClearMod theNode channelID = 
(	
	for theMod in theNode.modifiers do
	(
		if (classOf theMod == UVW_Mapping_Clear and theMod.mapID == channelID ) do
		(
			deleteModifier theNode theMod
		)
	)
)

function hvkVertexPaintingTools_FindFreeChannelID node = 
(
	-- look for a suitable ID to create the channel, starting from 10
	channelID = 9 -- wiil be +1
	channelFound = false;

	while ( not channelFound and channelID < 100 ) do
	(
		channelID += 1 
		-- check for the first unsupported channel
		channelFound = ( not meshop.getMapSupport node.mesh channelID ) 
	) 
	
	if( channelID == 100 ) do channelID = -1
	return channelID
)

function hvkVertexPaintingTools_CreateAndPaintParticleChannel channelName =
(
	
	-- look for a suitable ID to create the channel, starting from 10
	local channelID = hvkVertexPaintingTools_FindFreeChannelID selection[1]

	-- check if there's already a suitable modifier, otherwise create it
	if ( channelID > -1 ) do
	(
		local vpModifier = hvkVertexPaintingTools_GetVertexPaintModWithChannel selection[1] channelID
		local hasModifier = ( vpModifier != undefined )
		-- has it already the right modifier?
		if ( not hasModifier ) then 
		(
			-- create a modifier
			vpModifier = hvkVertexPaintingTools_CreateVertexPaintingOnChannel selection[1] channelID channelName 
			
			-- add a corresponding export channel
			hvkVertexPaintingTools_addExportChannel channelName channelID
		)
		
		-- rename channel
		channelInfo.NameChannel $ 3 channelID channelName
	
		hvkCommon_selectModifier vpModifier
		(VertexPaintTool()).curPaintMode = 1
	)
	
	return channelID
)

function hvkVertexPaintingTools_GetAllPropertiesStrings theNode =
(
	if ( theNode == undefined )	do return ""
	
	--  get properties
	local nodeProperties = getUserPropBuffer theNode 
	-- separate by carriage return and new line
	local strings = filterString nodeProperties "\r\n"
	
	return strings
)

function hvkVertexPaintingTools_GetPropertyValueFromString propString = 
(
	local result = undefined
	
	local separator = " = "
	local idx = findString propString separator 
	if ( idx != undefined ) then 
	(
		local len = propString.count
		result = substring propString ( idx + separator.count ) ( len - 1 )
	)
	else
	(
		result = undefined
	)
	
	return result
)

function hvkVertexPaintingTools_GetAllPropertiesValuesFromStrings strings = 
(
	result = #()
	for i=1 to strings.count do
	(
		local val = hvkVertexPaintingTools_GetPropertyValueFromString strings[i]
		result = append result val
	)
	return result
)

function hvkVertexSelectionTools_GetChannelIDFromPropString propString = 
(
	local pieces = filterString propString " = "
	if ( pieces.count > 0 ) do
	(
		pieces = filterString pieces[1] ":"
		if ( pieces.count > 1 ) do 
		(
			return pieces[2]
		)
	)
	
	return undefined
)

-- Get name and ID for all vertex channels of the node. names and IDs arrays are passed by reference
function hvkVertexPaintingTools_GetAllChannels theNode &channelNames &channelIDs = 
(
	local strings = hvkVertexPaintingTools_GetAllPropertiesStrings theNode
	
	channelNames = #()
	channelIDs = #()
	
	for propString in strings do 
	(
		if ( matchPattern propString pattern:"MapChannel:*" == true ) do
		(
			local channelName = hvkVertexPaintingTools_GetPropertyValueFromString propString
			local channelID = hvkVertexSelectionTools_GetChannelIDFromPropString propString
			
			if ( ( channelName != undefined and channelName.count > 0 ) and channelID != undefined ) do
			(
				channelNames = append channelNames channelName 
				channelIDs = append channelIDs channelID
			)
		)
	)
	
	return channelNames.count
)

-- returns the ID of the channel if theNode has a channel with the specified name, -1 otherwise
function hvkVertexPaintingTools_GetChannelIDWithUserPropName theNode propName = 
(
	propertiesList = getUserPropBuffer theNode
	patt = "*MapChannel:* = " + propName + "*"
	
	if ( matchPattern propertiesList pattern:patt == true ) then
	(
		-- look for the channel ID, don't know when to stop, 99 by now
		for i=1 to 99 do
		(
			patt = "*MapChannel:" + i as string + " = " + propName + "*"
			if ( matchPattern propertiesList pattern:patt == true ) then return i
		)
	)
	return -1
)

-- returns the name of the channel if theNode has a channel with the specified ID, undefined otherwise
function hvkVertexPaintingTools_GetChannelNameWithUserPropID theNode channelID = 
(
	if ( theNode != undefined ) do
	(
		local strings = hvkVertexPaintingTools_GetAllPropertiesStrings theNode
		
		local channelIDStr = channelID as String
		
		for propString in strings do 
		(
			local searchPatt = "MapChannel:" + channelIDStr + " = *"

			if ( matchPattern propString pattern:searchPatt == true ) do
			(
				local channelName = hvkVertexPaintingTools_GetPropertyValueFromString propString
			
				return channelName
			)
		)
	)
	
	return undefined
)


function hvkVertexPaintingTools_MakeUserPropString propKeys propValues = 
(
	local propertiesBuffer = ""
	
	if ( propKeys.count != propValues.count ) do return undefined 
	
	for i=1 to propKeys.count do
	(
		if ( propKeys[i] != "" ) do
		(
			-- add the key
			propertiesBuffer = propertiesBuffer + propKeys[i] 
			-- if the value is not empty or undefined add the value
			if ( propValues[i] != "" and propValues[i] != undefined ) do 
			( 
				propertiesBuffer = propertiesBuffer + " = " + propValues[i]
			)
			-- add a line
			propertiesBuffer = propertiesBuffer + "\r\n"
		)
	)
	return propertiesBuffer
)


function hvkVertexPaintingTools_FormatChannelTypePropKey channelID = 
(
	return "VPChannelType:" + channelID as String
)

function hvkVertexPaintingTools_FormatRescaleChannelPropKey channelID = 
(
	return "VPRescaleChannel:" + channelID as String
)

function hvkVertexPaintingTools_FormatRescaleChannelMaxPropKey channelID = 
(
	return "VPRescaleChannelMax:" + channelID as String
)

function hvkVertexPaintingTools_FormatRescaleChannelMinPropKey channelID = 
(
	return "VPRescaleChannelMin:" + channelID as String
)

function hvkVertexPaintingTools_SetDialogChannelType value = 
(
	for i=1 to hvkVertexPaintingTools.channelType.items.count do
	(
		if ( hvkVertexPaintingTools.channelType.items[i] == value ) do
		(
			hvkVertexPaintingTools.channelType.selection = i
		)
	)
)

function hvkVertexPaintingTools_GetChannelTypeDefaultValue = 
( 
	return "float"
)

function hvkVertexPaintingTools_GetUseRescaleDefaultValue = 
( 
	return false
)

function hvkVertexPaintingTools_GetRescaleMinDefaultValue = 
( 
	return 0.0
)

function hvkVertexPaintingTools_GetRescaleMaxDefaultValue = 
( 
	return 1.0
)


function hvkVertexPaintingTools_RenameUserPropertiesForChannel theNode oldChannelName newChannelName = 
(
	-- get all the user prop entries and values
	local strings = hvkVertexPaintingTools_GetAllPropertiesStrings theNode
	local values = hvkVertexPaintingTools_GetAllPropertiesValuesFromStrings strings
	
	separator = " = "
	for i = 1 to strings.count do 
	(
		-- find all user props of this channel
		local idx = findString strings[i] separator
		local sKey = substring strings[i] 1 ( idx - 1 )
		local pieces = filterString sKey ":"
		-- strings will now have the keys
		if ( pieces[2] == oldChannelName ) then
		(
			-- and change channel name
			pieces[2] = newChannelName
			strings[i] = pieces[1] + ":" + pieces[2]
		)
		else 
		(
			strings[i] = sKey
		)
		
	)
	-- set the new buffer
	local newUserPropBuffer = hvkVertexPaintingTools_MakeUserPropString strings values
	setUserPropBuffer theNode newUserPropBuffer
)

function hvkVertexPaintingTools_RemoveUserPropertiesForChannel theNode channelID = 
(
	-- get all the user prop entries and values
	local strings = hvkVertexPaintingTools_GetAllPropertiesStrings theNode
	local values = hvkVertexPaintingTools_GetAllPropertiesValuesFromStrings strings
	
	local separator = " = "
	for i = 1 to strings.count do 
	(
		-- try to split the string using the separator
		local idx = findString strings[i] separator
		if ( idx != undefined ) do
		(
			-- we have a "key = value" pair 
			local sKey = substring strings[i] 1 ( idx - 1 )
			local pieces = filterString sKey ":"
			-- check that the key is of the form MapChannel:ID and the ID is the one we are looking for
			if ( ( pieces.count == 2 ) and ( pieces[1] == "MapChannel" and ( pieces[2] as Integer == channelID ) ) ) then
			(
				-- set the key and the value as empty, MakeUserPropString will remove them
				strings[i] = ""
				values[i] = ""
			)
			else 
			(
				-- just keep the key to rebuild the user prop string
				strings[i] = sKey
			)
		)
	)
	-- set the new buffer
	local newUserPropBuffer = hvkVertexPaintingTools_MakeUserPropString strings values
	setUserPropBuffer theNode newUserPropBuffer
)


function hvkVertexPaintingTools_GetChannelListEntryString channelName channelID =
(
	local str = channelName + " : " + channelID as String;
	return str
)

function hvkVertexPaintingTools_GetChannelNameFromListEntryString entryString = 
(
	entryString = (filterString entryString "*")[1]
	local pieces = filterString entryString ":"
	
	return trimRight ( trimLeft pieces[1] )
)

function hvkVertexPaintingTools_GetChannelIDFromListEntryString entryString =
(
	entryString = (filterString entryString "*")[1]
	local pieces = filterString entryString ":"

	return pieces[ pieces.count ] as Integer
)


global g_lastChannelCreated_Name = ""
global g_lastChannelCreated_ID = -1 

function hvkVertexPaintingTools_SelectLastCreatedEntry =
(
	-- select the last created channel, if any
	if ( g_lastChannelCreated_Name != "" and g_lastChannelCreated_ID > -1 ) do 
	(	
		local notFound = true
		for i = 1 to hvkVertexPaintingTools.vertexChannels.items.count while notFound do 
		(
			local entry = hvkVertexPaintingTools_GetChannelNameFromListEntryString  hvkVertexPaintingTools.vertexChannels.items[i]
			if ( entry == g_lastChannelCreated_Name) do
			(
				hvkVertexPaintingTools.vertexChannels.selection = i
				notFound = false
			)
		)	
		g_lastChannelCreated_Name = ""
		g_lastChannelCreated_ID = -1
	)
)

function _getTrailingInteger theString &intValue = 
(
	local len = theString.count
	local asInt = -1
	local idx = len 
	
	while ( ( idx > 0 ) and ( asInt != undefined ) ) do
	( 
		local subS = substring theString idx (len - idx + 1)
		if( subS[1] != "f" and subS[1] != "m" and subS[1] != "s" and subS[1] != "t" ) then
		(
			asInt = subS as integer
		)
		else 
		(
			asInt = undefined 
		)
		if ( asInt != undefined ) do 
		(
			idx -= 1
		)
	)
	idx += 1
	 
	local subS = substring theString idx ( len - idx + 1 )
	if ( subS != "" ) then 
	(
		intValue = ( subS as integer )
	)
	else 
	(
		intvalue = -1
	)	
	return idx
)

function hvkVertexPaintingTools_getExportChannelNameFromEntry entryName = 
(
	local res = entryName
	if ( ( findString res "*" ) == 1 ) then
	(
		res = ( filterString res "*" )[1]	
	)
	
	return res
)

function hvkVertexPaintingTools_getSelectedExportChannelName = 
(
	local exportChannelName = hvkVertexPaintingTools.havokExportChannels.selected
	
	return hvkVertexPaintingTools_getExportChannelNameFromEntry exportChannelName
)	

function hvkVertexPaintingTools_FindSuitableExportChannelName namesList originalName = 
(
	local newName = copy originalName
	
	local idx = findItem namesList newName
	while ( idx != 0 ) do 
	(
		local trailingInt
		local pos = _getTrailingInteger newName &trailingInt
		if( trailingInt != -1 ) then 
		(
			-- ends with an int, get the substring up the int and prepare to append
			newname  = substring newname 1 (pos-1)
			trailingInt += 1 
		)
		else
		( 
			-- ends with char, will append a 2
			trailingInt = 2
		)
		append newName ( trailingInt as String )
		
		idx = findItem namesList newName
	)
	return newName
)

function hvkVertexPaintingTools_ValidateExportChannelName namesListOrig &nameToValidate askUserForRename:false = 
(
	local theNode = $selection[1]
	local renamed = false
	local namesList = #()
	
	for name in namesListOrig do 
	(
		namesList = append namesList ( hvkVertexPaintingTools_getExportChannelNameFromEntry name )
	)
	
	local idx = findItem namesList nameToValidate
	while ( idx != 0 ) do
	(
		-- the name is already in the list, we have to either change it or discard it
		
		if ( askUserForRename ) then
		( 
			local queryString = "Channel name " + nameToValidate + " already present. Rename it?"
			if ( queryBox queryString ) then 
			(
				nameToValidate = hvkCloth_openRenameDialogAndGetString nameToValidate title:"Rename"
				renamed = true
				-- check again		
				idx = findItem namesList nameToValidate
			)
			else
			(
				idx = 0
			)
		)
		else 
		(
			nameToValidate = hvkVertexPaintingTools_FindSuitableExportChannelName namesList nameToValidate
			idx = 0
		)
	)
	
	return renamed  
)

function hvkVertexPaintingTools_GetAndValidateAllExportChannelsForPaintChannel theNode channelID = 
(
	local exportNames = #()
	
	for theMod in theNode.modifiers do
	(
		if (classOf theMod == Havok_Export_Channel and theMod.channelID == channelID ) do
		(
			local exportChannName = theMod.channelExportName
			local validated = exportChannName
	 		
			local expChMod = theMod
	 		if( hvkVertexPaintingTools_ValidateExportChannelName exportNames &validated askUserForRename:true ) do
			(
				expChMod.channelExportName = validated
				exportChannName = validated
			)
			if ( expChMod.activeDisplay and expChMod.channelType == 1 ) then  
			(
				exportChannName = "*" + exportChannName
			)
			
			if ( exportChannName != undefined ) do 
			(
				exportNames = append exportNames exportChannName
			)
		)
	)
	
	return exportNames
) 

		
function hvkVertexPaintingTools_findExportChannelModifierFromToolSelection = 
(
	local selected =  $selection as Array
	local justOneSelected = selected.count==1
	local isAChannelSelected = ( hvkVertexPaintingTools.vertexChannels.selection != 0 )	
	local isExportChannelSelected = ( hvkVertexPaintingTools.havokExportChannels.selection != 0 )	
	
	if ( justOneSelected and isAChannelSelected and isExportChannelSelected ) do
	(
		local exportChannelName = hvkVertexPaintingTools_getSelectedExportChannelName()
		
		local channelID = ( hvkVertexPaintingTools_GetChannelIDFromListEntryString hvkVertexPaintingTools.vertexChannels.selected )

		local expChMod = hvkVertexPaintingTools_GetHavokExportChannelModWithChannelAndName selected[1] channelID exportChannelName
		return expChMod
	)
	
	return undefined
)
