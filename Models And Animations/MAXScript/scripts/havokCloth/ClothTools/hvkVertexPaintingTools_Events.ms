
filein "hvkVertexPaintingTools_Utils.ms"

function hvkVertexPaintingTools_CloseRollout = 
(
	callbacks.removeScripts id:#HAVOK_VERTEXPAINT_TOOLS
)


function hvkVertexPaintingTools_UpdateUI =
(
	local selected =  $selection as Array
	local justOneSelected = selected.count==1
	
	-- clear channels' list
	hvkVertexPaintingTools.vertexChannels.items = #()
	
	if( justOneSelected ) do 
	(
		local vertexChannelsNames
		local vertexChannelsIDs
		
		-- note: passing by reference
		local numChannels = hvkVertexPaintingTools_GetAllChannels selected[1] &vertexChannelsNames &vertexChannelsIDs

		-- and put sets of currently selected mesh
		for i = 1 to vertexChannelsNames.count do 
		(
			-- each entry is of the form "ChannelName : ChannelID"
			local entryString = hvkVertexPaintingTools_GetChannelListEntryString vertexChannelsNames[i] vertexChannelsIDs[i]
			hvkVertexPaintingTools.vertexChannels.items = append hvkVertexPaintingTools.vertexChannels.items ( entryString )
		) 
		-- sort list
		hvkVertexPaintingTools.vertexChannels.items = sort hvkVertexPaintingTools.vertexChannels.items
	)
	hvkVertexPaintingTools_SelectLastCreatedEntry()
	local isAChannelSelected = ( hvkVertexPaintingTools.vertexChannels.selection != 0 )
	
	
	-- enable/disable buttons
	hvkVertexPaintingTools.newChannel.enabled = justOneSelected
	hvkVertexPaintingTools.paintOnChannel.enabled = isAChannelSelected
	hvkVertexPaintingTools.renameChannel.enabled = isAChannelSelected
	hvkVertexPaintingTools.removeChannel.enabled = isAChannelSelected
	
	-- Export Channels -----------------------------------
	
	-- populate export channels list
	hvkVertexPaintingTools.havokExportChannels.items = #()
	
	if ( isAChannelSelected ) do
	(
		local selectedChannID = hvkVertexPaintingTools_GetChannelIDFromListEntryString hvkVertexPaintingTools.vertexChannels.selected
		-- get the list of associated export channels	
	    hvkVertexPaintingTools.havokExportChannels.items = hvkVertexPaintingTools_GetAndValidateAllExportChannelsForPaintChannel selected[1] selectedChannID
	) 
	
	-- prepend a '*' to each vertex channel name that has at least one export channel that's being displayed
	local vertexChannels = hvkVertexPaintingTools.vertexChannels.items as Array
	for vci = 1 to vertexChannels.count do 
	(
		local channID = hvkVertexPaintingTools_GetChannelIDFromListEntryString vertexChannels[vci]
		-- get the list of associated export channels	
	    local exportedChannels = hvkVertexPaintingTools_GetAndValidateAllExportChannelsForPaintChannel selected[1] channID
	    
		local notFound = true
	    for eci = 1 to exportedChannels.count while notFound  do 
	    (
			if ( findString exportedChannels[eci] "*" == 1 ) do
			(
				notFound = false
			)
	    )
	    if not notFound do 
	    (
			vertexChannels[vci] = "*" + vertexChannels[vci]
	    )
	)
	-- replace vertex channel names
	hvkVertexPaintingTools.vertexChannels.items = vertexChannels 
	
	
	local isExportChannelSelected = ( hvkVertexPaintingTools.havokExportChannels.selection != 0 )
	-- enable/disable export channel controls
	hvkVertexPaintingTools.newExportChannel.enabled = isAChannelSelected
	hvkVertexPaintingTools.renameExportChannel.enabled = isExportChannelSelected
	hvkVertexPaintingTools.editExportChannel.enabled = isExportChannelSelected
	hvkVertexPaintingTools.removeExportChannel.enabled = isExportChannelSelected
	hvkVertexPaintingTools.toggleDisplay.enabled = isExportChannelSelected
)

function hvkVertexPaintingTools_Refresh = 
(
	hvkVertexPaintingTools_UpdateUI()
)

function hvkVertexPaintingTools_AddChannelTypePropToNode theNode channelID = 
( 
	local propKey = hvkVertexPaintingTools_FormatChannelTypePropKey channelID
	setUserProp theNode propKey (hvkVertexPaintingTools_GetChannelTypeDefaultValue()) 
)

function hvkVertexPaintingTools_AddRescalePropsToNode theNode channelID = 
( 
	-- use rescale
	local propKey = hvkVertexPaintingTools_FormatRescaleChannelPropKey channelID 
	setUserProp theNode propKey (hvkVertexPaintingTools_GetUseRescaleDefaultValue())
	
	-- rescale min
	propKey = hvkVertexPaintingTools_FormatRescaleChannelMinPropKey channelID 
	setUserProp theNode propKey (hvkVertexPaintingTools_GetRescaleMinDefaultValue())
	
	-- rescale max
	propKey = hvkVertexPaintingTools_FormatRescaleChannelMaxPropKey channelID 
	setUserProp theNode propKey (hvkVertexPaintingTools_GetRescaleMaxDefaultValue())
)

function hvkVertexPaintingTools_CreateNewChannel = 
(
	local selected =  $selection as Array
	local justOneSelected = selected.count==1
	
	if ( justOneSelected ) do
	(
		-- get the name
		local newName = hvkCloth_openRenameDialogAndGetString "" title:"New Channel"
		
		if ( newName != undefined ) do
		(
			local theNode = selection[1]
			-- add the channel, property and modifier, then activate painting tool
			local channelID = hvkVertexPaintingTools_CreateAndPaintParticleChannel newName
			if ( channelID > -1 ) do 
			(
				hvkVertexPaintingTools.havokExportChannels.items = #()
			
				g_lastChannelCreated_Name = copy newName
				g_lastChannelCreated_ID = channelID
				hvkVertexPaintingTools_SelectLastCreatedEntry()
					
				-- activate painting
				hvkVertexPaintingTools_PaintCurrentChannel()
			)
		)
	)
	hvkVertexPaintingTools_Refresh()
)

function hvkVertexPaintingTools_PaintChannel theNode channelID channelName = 
(
	if ( channelID > -1 ) do
	(
		local vpModifier = hvkVertexPaintingTools_GetVertexPaintModWithChannel theNode channelID
		if ( vpModifier != undefined ) then
		(
			hvkCommon_selectModifier vpModifier
			(VertexPaintTool()).curPaintMode = 1
		)
		else
		(
			-- create a modifier
			vpModifier = hvkVertexPaintingTools_CreateVertexPaintingOnChannel theNode channelID channelName 
		)
	)
	hvkVertexPaintingTools_Refresh()
	
	return vpModifier
)


function hvkVertexPaintingTools_PaintCurrentChannel = 
(
	local selected = $selection as Array
	local justOneSelected = selected.count==1
	local isAChannelSelected = ( hvkVertexPaintingTools.vertexChannels.selection != 0 )
	
	if ( justOneSelected and isAChannelSelected ) do
	(
		local theNode = selection[1]
		local channelID = ( hvkVertexPaintingTools_GetChannelIDFromListEntryString hvkVertexPaintingTools.vertexChannels.selected )
		local channelName = hvkVertexPaintingTools_GetChannelNameFromListEntryString hvkVertexPaintingTools.vertexChannels.selected
		
		hvkVertexPaintingTools_PaintChannel theNode channelID channelName
	)
)

function hvkVertexPaintingTools_RenameChannel = 
(
	local selected = $selection as Array
	local justOneSelected = selected.count==1
	local isAChannelSelected = ( hvkVertexPaintingTools.vertexChannels.selection != 0 )
	
	if ( justOneSelected and isAChannelSelected ) do
	(
		local oldChannelName = ( hvkVertexPaintingTools_GetChannelNameFromListEntryString hvkVertexPaintingTools.vertexChannels.selected )
		local newChannelName = hvkCloth_openRenameDialogAndGetString oldChannelName title:"Rename Channel"
		
		if ( newChannelName != undefined ) do
		(
			local theNode = selection[1]
			local channelID = ( hvkVertexPaintingTools_GetChannelIDFromListEntryString hvkVertexPaintingTools.vertexChannels.selected )
			if ( channelID > -1 ) do
			(
				-- rename the channel
				channelInfo.NameChannel theNode 3 channelID newChannelName
				local vpModifier = hvkVertexPaintingTools_GetVertexPaintModWithChannel theNode channelID
				if ( vpModifier != undefined ) do
				(
					-- rename the modifier only if it wasn't renamed by the user
					if ( vpModifier.name == hvkVertexPaintingTools_FormatModifierNameFromChannelName oldChannelName ) do
					(
						vpModifier.name = hvkVertexPaintingTools_FormatModifierNameFromChannelName newChannelName
					)
				)
			)
		)
	)
	hvkVertexPaintingTools_Refresh()
)



function hvkVertexPaintingTools_RemoveChannel = 
(
	local selected = $selection as Array
	local justOneSelected = selected.count==1
	local isAChannelSelected = ( hvkVertexPaintingTools.vertexChannels.selection != 0 )
	
	if ( justOneSelected and isAChannelSelected ) do
	(
		local okToDelete = queryBox ("Are you sure you want to delete the channel?") title:"Delete Vertex Channel"				
		if( okToDelete ) do
		(
			local theNode = selection[1]
			local channelID = ( hvkVertexPaintingTools_GetChannelIDFromListEntryString hvkVertexPaintingTools.vertexChannels.selected )
			if ( channelID > -1 ) do
			(
				undo "Havok Remove Vertex Channel" on
				(
					hvkVertexPaintingTools_RemoveUserPropertiesForChannel theNode channelID
					channelInfo.ClearChannel theNode channelID
					hvkVertexPaintingTools_RemoveMappingClearMod theNode channelID
					-- empty selection in the list
					hvkVertexPaintingTools.vertexChannels.selection = 0
						
					-- remove all export channels of this channel
					local mods = hvkVertexPaintingTools_GetAllHavokExportChannelModifiersWithChannel theNode channelID
					for aMod in mods do 
					(
						deleteModifier theNode aMod
					)
						
					-- remove the vertex paint modifier, if any
					vpModifier = hvkVertexPaintingTools_GetVertexPaintModWithChannel theNode channelID
					if ( vpModifier != undefined ) do
					(
						deleteModifier theNode vpModifier
					)
				)
			)
		)
	)
	hvkVertexPaintingTools_Refresh()   
)

function hvkVertexPaintingTools_SetChannelType = 
(
	local selected =  $selection as Array
	local justOneSelected = selected.count==1
	local isAChannelSelected = ( hvkVertexPaintingTools.vertexChannels.selection != 0 )	
	
	if ( justOneSelected and isAChannelSelected ) do
	(
		local channelID = ( hvkVertexPaintingTools_GetChannelIDFromListEntryString hvkVertexPaintingTools.vertexChannels.selected )
		local propKey = hvkVertexPaintingTools_FormatChannelTypePropKey channelID
		setUserProp selected[1] propKey hvkVertexPaintingTools.channelType.selected
	)
	hvkVertexPaintingTools_Refresh()
)

function hvkVertexPaintingTools_SetChannelRescale = 
(
	local selected =  $selection as Array
	local justOneSelected = selected.count==1
	local isAChannelSelected = ( hvkVertexPaintingTools.vertexChannels.selection != 0 )	
	
	if ( justOneSelected and isAChannelSelected ) do
	(
		local activate = hvkVertexPaintingTools.activateRescale.checked
		local channelID = ( hvkVertexPaintingTools_GetChannelIDFromListEntryString hvkVertexPaintingTools.vertexChannels.selected )
		
		local propKey = hvkVertexPaintingTools_FormatRescaleChannelPropKey channelID 
		setUserProp selected[1] propKey activate
	)
	hvkVertexPaintingTools_Refresh()
)

function hvkVertexPaintingTools_ChangeChannelRescaleValue propFormatFunction value = 
(
	local selected =  $selection as Array
	local justOneSelected = selected.count==1
	local isAChannelSelected = ( hvkVertexPaintingTools.vertexChannels.selection != 0 )	
	
	if ( justOneSelected and isAChannelSelected ) do
	(
		local activate = hvkVertexPaintingTools.activateRescale.checked 
		if ( activate ) do 
		(
			local channelID = ( hvkVertexPaintingTools_GetChannelIDFromListEntryString hvkVertexPaintingTools.vertexChannels.selected )
		
			local propKey = propFormatFunction channelID 
			setUserProp selected[1] propKey value
		)
	)
	hvkVertexPaintingTools_Refresh() 
)

function hvkVertexPaintingTools_ChangeChannelRescaleMinValue = 
(
	hvkVertexPaintingTools_ChangeChannelRescaleValue hvkVertexPaintingTools_FormatRescaleChannelMinPropKey hvkVertexPaintingTools.spinnerRescaleMin.value
) 

function hvkVertexPaintingTools_ChangeChannelRescaleMaxValue = 
(	
	hvkVertexPaintingTools_ChangeChannelRescaleValue hvkVertexPaintingTools_FormatRescaleChannelMaxPropKey hvkVertexPaintingTools.spinnerRescaleMax.value
)  

function hvkVertexPaintingTools_addExportChannel channelName channelID = 
(
	local selected =  $selection as Array
	local justOneSelected = selected.count==1
	
	if ( justOneSelected ) do
	(
		local expChannelName = copy channelName

		hvkVertexPaintingTools_ValidateExportChannelName hvkVertexPaintingTools.havokExportChannels.items &expChannelName
		if ( expChannelName != undefined ) do
		(
			hvkCloth_createExportChannel selected[1] channelID channelName expChannelName
		)
	)
)

function hvkVertexPaintingTools_addExportChannelFromCurrentSelection = 
(
	local selected =  $selection as Array
	local justOneSelected = selected.count==1
	local isAChannelSelected = ( hvkVertexPaintingTools.vertexChannels.selection != 0 )	 
	
	if ( justOneSelected and isAChannelSelected ) do
	(
		local channelID = ( hvkVertexPaintingTools_GetChannelIDFromListEntryString hvkVertexPaintingTools.vertexChannels.selected )
		local channelName = ( hvkVertexPaintingTools_GetChannelNameFromListEntryString hvkVertexPaintingTools.vertexChannels.selected )

		hvkVertexPaintingTools_addExportChannel channelName channelID
	)
)

function hvkVertexPaintingTools_renameExportChannel = 
(
	local expChMod = hvkVertexPaintingTools_findExportChannelModifierFromToolSelection()
		
	if ( expChMod != undefined ) do
	(
		local exportChannelName = hvkVertexPaintingTools_getSelectedExportChannelName()
		local channelID = ( hvkVertexPaintingTools_GetChannelIDFromListEntryString hvkVertexPaintingTools.vertexChannels.selected )

		local newName = hvkCloth_openRenameDialogAndGetString exportChannelName title:"Rename Channel"
		
		if ( newName != undefined and newName != exportChannelName ) do 
		(
			hvkVertexPaintingTools_ValidateExportChannelName hvkVertexPaintingTools.havokExportChannels.items &newName askUserForRename:true
			expChMod.channelExportName = newName
		)
	)
	hvkVertexPaintingTools_Refresh()
)

function hvkVertexPaintingTools_editExportChannel = 
(
	local theMod = hvkVertexPaintingTools_findExportChannelModifierFromToolSelection()
	
	if ( theMod != undefined ) do hvkCommon_selectModifier theMod
)


function hvkVertexPaintingTools_removeExportChannel = 
(
	local theMod = hvkVertexPaintingTools_findExportChannelModifierFromToolSelection()
	
	if ( theMod != undefined ) do 
	(
		undo "Havok Remove Export Channel" on
		(
			deleteModifier $selection[1] theMod
			hvkVertexPaintingTools_Refresh()
		)
	)
)

function hvkVertexPaintingTools_toggleDisplayOfExportChannel = 
(
	local theMod = hvkVertexPaintingTools_findExportChannelModifierFromToolSelection()
	
	if ( theMod != undefined ) do 
	(
		theMod.activeDisplay = not theMod.activeDisplay
	)
	hvkVertexPaintingTools_UpdateUI()
)

--
-- CALLBACKS
--

function hvkVertexPaintingTools_SelectionUpdatedCallback =
(
	hvkVertexPaintingTools_UpdateUI()
)

function hvkVertexPaintingTools_UndoRedoCallback =
(
	hvkVertexPaintingTools_UpdateUI()
)

function hvkVertexPaintingTools_NodeRenamedCallback = 
(
	hvkVertexPaintingTools_UpdateUI()
)

function hvkVertexPaintingTools_NamedSelSetChangeCallback = 
(
	hvkVertexPaintingTools_UpdateUI()
)

function hvkVertexPaintingTools_ModPanelChangeCallback = 
(
	hvkVertexPaintingTools_UpdateUI()
)

function hvkVertexPaintingTools_GenPropChangeCallback = 
(
	hvkVertexPaintingTools_UpdateUI()
)

function hvkVertexPaintingTools_OpenRollout = 
(
	hvkVertexPaintingTools_UpdateUI()
	
	callbacks.addScript #selectionSetChanged "hvkVertexPaintingTools_SelectionUpdatedCallback()" id:#HAVOK_VERTEXPAINT_TOOLS
	callbacks.addScript #modPanelSelChanged "hvkVertexPaintingTools_SelectionUpdatedCallback()" id:#HAVOK_VERTEXPAINT_TOOLS	
	callbacks.addScript #sceneUndo "hvkVertexPaintingTools_UndoRedoCallback()" id:#HAVOK_VERTEXPAINT_TOOLS
	callbacks.addScript #sceneRedo "hvkVertexPaintingTools_UndoRedoCallback()" id:#HAVOK_VERTEXPAINT_TOOLS
	callbacks.addScript #nodeRenamed "hvkVertexPaintingTools_NodeRenamedCallback()" id:#HAVOK_VERTEXPAINT_TOOLS
	callbacks.addScript #modPanelObjPostChange "hvkVertexPaintingTools_ModPanelChangeCallback()" id:#HAVOK_VERTEXPAINT_TOOLS	
	callbacks.addScript #postNodeGeneralPropChanged "hvkVertexPaintingTools_GenPropChangeCallback()" id:#HAVOK_VERTEXPAINT_TOOLS	
	callbacks.addScript #postNodeUserPropChanged "hvkVertexPaintingTools_GenPropChangeCallback()" id:#HAVOK_VERTEXPAINT_TOOLS	
)
