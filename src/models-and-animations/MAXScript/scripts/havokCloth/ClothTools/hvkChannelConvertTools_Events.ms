filein "hvkChannelConvertTools_ChannelToBmpDialog.ms"

global g_lastLoadedTexture = ""
global g_lastSavedTexture = ""


function hvkChannelConvertTools_convertChannelToTexture = 
(
	if ( selection.count == 1 and convertChannelToTextureDialog != undefined ) do
	(
		local theNode = selection[1];
		-- input
		local channelID = convertChannelToTextureDialog.channelIDSpinner.value
		
		-- output
		local textureOutputPath = convertChannelToTextureDialog.filePath.text
		if ( textureOutputPath != "" ) do
		( 
			-- options
			local uvwChannID = convertChannelToTextureDialog.uvwChannelIDSpinner.value
			local texXSize = convertChannelToTextureDialog.textureSizeX.value
			local texYSize = convertChannelToTextureDialog.textureSizeY.value
			
			-- flatten uvs if requested
			if ( convertChannelToTextureDialog.unwrapUVWCheckbox.checked ) do
			(
				hvkChannelConvert_addUnwrapUVWModifierToNodeAndFlatten theNode uvwChannID 
			)
		
			local displayImage = convertChannelToTextureDialog.showImage.checked
			-- convert
			hvkChannelConvert_renderVertexColorsToTexture theNode channelID textureOutputPath uvwChannelID:uvwChannID xSize:texXSize ySize:texYSize showImage:displayImage
		
			g_lastSavedTexture = textureOutputPath
		)
	)
)

function hvkChannelConvertTools_convertTextureToChannel = 
(
	if ( selection.count == 1 ) do
	(
		local channelID = convertTextureToChannelDialog.channelIDSpinner.value
		local channelName = convertTextureToChannelDialog.channelName.text
	
		local vpMod = undefined
		
		if ( convertTextureToChannelDialog.modifierUseDropDown.selected == "Use currently selected" ) then
		(
			-- the user wants to reuse the currently selected modifier
			local currentObj = modPanel.getCurrentObject()
			if ( classof currentObj == VertexPaint ) do
			(
				-- it's a vertex paint modifier, we can use it
				vpMod = currentObj
			)	
		) 
		else if ( convertTextureToChannelDialog.modifierUseDropDown.selected == "Create new" ) then
		(
			-- the user wants to create a new Vertex Paint modifier
			
			-- if the channel has no name ask for one
			if ( channelName == "" ) do 
			(
				channelName = hvkCloth_openRenameDialogAndGetString "" title:"Type a name for the new channel"
			)
			
			if ( channelName != undefined ) do
			(
				-- create a Vertex Paint modifier 
				vpMod = hvkVertexPaintingTools_CreateVertexPaintingOnChannel selection[1] channelID channelName		
				
				-- rename channel
				channelInfo.NameChannel $ 3 channelID channelName
	
				hvkCommon_selectModifier vpMod
				(VertexPaintTool()).curPaintMode = 1
			)
		)
		
		-- if vpMod is undefined we will not proceed, as we don't want to rely on the utility default behaviour
		if ( vpMod != undefined ) do 
		(
			-- load a texture if requested		
			if ( convertTextureToChannelDialog.loadImageCheckbox.checked ) do
			(
				local filePath = convertTextureToChannelDialog.filePath.text
				if ( filePath != "" ) do 
				(
					g_lastLoadedTexture = filePath
					
					-- setup the material that we'll use for rendering 
					-- create a standard material
					local tmpMaterial = StandardMaterial()
							
					-- enable diffuse map and create the bitmap texture
					tmpMaterial.diffuseMapEnable = on
					tmpMaterial.diffuseMap = Bitmaptexture fileName:filePath
					
					-- set self illumination to max to avoid shadows
					tmpMaterial.selfIllumAmount = 100
							
					-- assign the material to the object
					selection[1].material = tmpMaterial
							
					-- make sure the material is showing
					showTextureMap tmpMaterial true 	
				)
			)
			
			---- make sure the settings are correct 
			---- HACK : because of a bug in 3ds Max ( logged as Change Request number 116896 ) we need to apply the
			---- colors two times, the first one using "color by face" and the second using "color by vertex" method
			-- set channel
			vpMod.mapChannel = channelID 
			-- color by face 
			vpMod.colorBy = 0    
			-- use diffuse, no lighting
			vpMod.lightingModel = 2 
			-- use texture mapping
			vpMod.useMaps = true	
			-- disable radiosity
			vpMod.useRadiosity = false
			-- disable shadows
			vpMod.castShadows = false
			
			-- first pass ( see note above )
			hkConversionUtilGUP.assignVertexColors selection[1] vpMod channelID false
			
			-- color by vertex
			vpMod.colorBy = 1   
			-- second pass ( see note above )
			hkConversionUtilGUP.assignVertexColors selection[1] vpMod channelID true
			
			-- assign an undefined mateiral to the object so that the colors will be immediatly visible
			selection[1].material = undefined
		)
	) 
)


function _browseForTextureLoad oldPath =  
(
	-- define the allowed file types
	local typesStr = ".png|*.png|.bmp|*.bmp|.jpg|*.jpg|.tga|*.tga|All|*.*"
	-- open browse dialog
	local filePath = getOpenFileName caption:"Open A Test File:" filename:oldPath types:typesStr

	return filePath
)

function _browseForTextureSave oldPath =  
(
	-- define the allowed file types
	local typesStr = ".png|*.png|.bmp|*.bmp|.jpg|*.jpg|.tga|*.tga|All|*.*"
	-- open browse dialog
	local filePath = getSaveFileName caption:"Open A Test File:" filename:oldPath types:typesStr

	return filePath
)

function hvkChannelConvertTools_ChannelToTexture_browseForFile = 
(
	if ( convertChannelToTextureDialog != undefined ) do
	(
		-- open browse dialog
		local filePath = _browseForTextureSave convertChannelToTextureDialog.filePath.text 
		if ( filePath != undefined ) do 
		(
			convertChannelToTextureDialog.filePath.text = filePath
		)
	)
	hvkChannelConvertTools_UpdateChannelToTextureDialog()
)

function hvkChannelConvertTools_TextureToChannel_browseForFile = 
(
	if ( convertTextureToChannelDialog != undefined ) do
	(
		-- open browse dialog
		local filePath = _browseForTextureLoad convertTextureToChannelDialog.filePath.text
		if ( filePath != undefined ) do 
		(
			convertTextureToChannelDialog.filePath.text = filePath
		)
		hvkChannelConvertTools_UpdateTextureToChannelDialog()
	)
)

function hvkChannelConvertTools_SelectionToChannel_convertSelectionToChannel = 
(
	if ( selection.count == 1 ) do 
	(
		local selected = selection[1]
		local channelID = convertSelectionToChannelDialog.channelIDSpinner.value
		local channelName = convertSelectionToChannelDialog.channelName.text
		
		-- if the channel is not already supported enable painting on it
		-- local channelOk = meshop.getMapSupport selection[1].mesh channelID
		local theVPMod = hvkVertexPaintingTools_GetVertexPaintModWithChannel selected channelID
		local modOk = ( theVPMod != undefined )
		local channelOk = ( channelName != undefined and channelName != "" )
		
		-- if we don't have a name ask for one
		if ( not channelOk ) do 
		(
			-- ask for a name
			channelName = hvkCloth_openRenameDialogAndGetString channelName title:"Create new channel"
			channelOk = ( channelName != undefined and channelName != "" )
		)
		
		-- save current selected object in the mod panel
		local selectMod = modPanel.getCurrentObject()
		
		-- if we don't have a vertex paint modifier create one
		if ( not modOk ) do 
		(
			-- if we got a valid name enable painting
			if ( channelOk ) do 
			(
				theVPMod = hvkVertexPaintingTools_PaintChannel selected channelID channelName
				-- name channel
				channelInfo.NameChannel $ 3 channelID channelName
				
				modOk = ( theVPMod != undefined )
			)
		)
		
		-- restore the select modifier, if any
		if ( selectMod != undefined ) do 
		(
			modPanel.setCurrentObject selectMod
		)
		
		if ( channelOk and modOk ) do 
		(
			local selectedValue = convertSelectionToChannelDialog.selectedValue.value 
			local unselectedValue = convertSelectionToChannelDialog.unselectedValue.value
			hvkSelectionTools_convertCurrentVertexSelectionToVertexChannel theVPMod channelID selectedValue unselectedValue
			
			hvkVertexPaintingTools_UpdateUI()
			hvkChannelConvertTools_UpdateSelectionToColorsDialog()
		)
	)   
)


-- UI update

function _getChannelNameFromID channelID = 
(
	local channelName = hvkVertexPaintingTools_GetChannelNameWithUserPropID selection[1] channelID
	if ( channelName == undefined ) then 
	(
		channelName = ""
	)
	return channelName
)

function hvkChannelConvertTools_ChannelToTexture_updateChannelName = 
(
	if ( selection.count == 1 and convertChannelToTextureDialog != undefined  and convertChannelToTextureDialog.open ) do
	(
		local channelID = convertChannelToTextureDialog.channelIDSpinner.value
		convertChannelToTextureDialog.channelName.text = _getChannelNameFromID channelID 
	)
)

function hvkChannelConvertTools_ChannelToTexture_updateUVWChannelName = 
(
	if ( selection.count == 1 and convertChannelToTextureDialog != undefined and convertChannelToTextureDialog.open ) do
	(
		local channelID = convertChannelToTextureDialog.uvwChannelIDSpinner.value
		convertChannelToTextureDialog.uvwChannelName.text = _getChannelNameFromID channelID 
	)
)

function hvkChannelConvertTools_TextureToChannel_updateChannelName = 
(
	if ( selection.count == 1 and convertTextureToChannelDialog != undefined and convertTextureToChannelDialog.open ) do
	(
		local channelID = convertTextureToChannelDialog.channelIDSpinner.value
		convertTextureToChannelDialog.channelName.text = _getChannelNameFromID channelID 
	)
)

function hvkChannelConvertTools_SelectionToChannel_updateChannelName = 
(
	if ( selection.count == 1 and convertSelectionToChannelDialog != undefined and convertSelectionToChannelDialog.open ) do
	(
		local channelID = convertSelectionToChannelDialog.channelIDSpinner.value
		convertSelectionToChannelDialog.channelName.text = _getChannelNameFromID channelID 
	)
)

function hvkChannelConvertTools_ChannelToSelection_updateChannelName = 
(
	if ( selection.count == 1 and convertChannelToSelectionDialog != undefined and convertChannelToSelectionDialog.open ) do
	(
		local channelID = convertChannelToSelectionDialog.channelIDSpinner.value
		convertChannelToSelectionDialog.channelName.text = _getChannelNameFromID channelID 
	)
)

function hvkChannelConvertTools_UpdateChannelToTextureDialog = 
(
	if ( convertChannelToTextureDialog != undefined and convertChannelToTextureDialog.open ) do 
	(
		hvkChannelConvertTools_ChannelToTexture_updateChannelName()	
		hvkChannelConvertTools_ChannelToTexture_updateUVWChannelName()
		
		local pathSelected = convertChannelToTextureDialog.filePath.text != "" 
		if ( not pathSelected ) do
		(
			convertChannelToTextureDialog.filePath.text = g_lastSavedTexture
		)
		
		convertChannelToTextureDialog.convertButton.enabled = pathSelected
	)
)

function hvkChannelConvertTools_UpdateTextureToChannelDialog = 
(
	if ( convertTextureToChannelDialog != undefined and convertTextureToChannelDialog.open ) do 
	(
		hvkChannelConvertTools_TextureToChannel_updateChannelName()	
		
		local loadFromFile = convertTextureToChannelDialog.loadImageCheckbox.checked 
		convertTextureToChannelDialog.filePath.enabled = loadFromFile
		local fileSelected = convertTextureToChannelDialog.filePath.text != ""
		if ( not fileSelected ) do 
		(
			-- see if we have a last loaded texture
			convertTextureToChannelDialog.filePath.text = g_lastLoadedTexture
		)
		
		local reuseModifier = convertTextureToChannelDialog.modifierUseDropDown.selected == "Use currently selected"
		
		local currObj = modPanel.getCurrentObject()
		local suitableModifierSelected = classof currObj == VertexPaint
		
		local fileOk = not loadFromFile or ( loadFromFile and fileSelected ) 
		local modifierOk = ( not reuseModifier ) or ( reuseModifier and suitableModifierSelected )
		
		local loadImage = convertTextureToChannelDialog.loadImageCheckbox.checked
		local loadImageOk = not loadImage or ( loadImage and convertTextureToChannelDialog.filePath.text != "" )
		
		convertTextureToChannelDialog.convertButton.enabled = selection.count == 1 and fileOK and modifierOk and loadImageOk
	)
)
 

function hvkChannelConvertTools_UpdateSelectionToColorsDialog = 
(
	if ( convertSelectionToChannelDialog != undefined and convertSelectionToChannelDialog.open ) do
	(
		-- 
		hvkChannelConvertTools_SelectionToChannel_updateChannelName()	
	
		local vertexMode = ( subObjectLevel == 1 )

		-- enable the buttons only if we are in vertex selection sub object level
		convertSelectionToChannelDialog.convertButton.enabled = vertexMode
	)
)


function hvkChannelConvertTools_UpdateColorsToSelectionDialog = 
(
	if ( convertChannelToSelectionDialog != undefined and convertChannelToSelectionDialog.open ) do
	(
		-- 
		hvkChannelConvertTools_ChannelToSelection_updateChannelName()	
		local channelOK = convertChannelToSelectionDialog.channelName.text != ""
	
		local vertexMode = ( subObjectLevel == 1 )
		
		-- enable selection name textbox only if "name" checkboc is checked
		convertChannelToSelectionDialog.selectionName.enabled = convertChannelToSelectionDialog.saveAsNamedCheckbox.checked
		local nameOK = not convertChannelToSelectionDialog.selectionName.enabled or ( convertChannelToSelectionDialog.selectionName.text != "" )
		
		-- enable the buttons only if we are in vertex selection sub object level
		convertChannelToSelectionDialog.convertButton.enabled = vertexMode and channelOK and nameOK
	)
)

function hvkChannelConvertTools_ChannelToSelection_convertChannelToSelection = 
(
	if ( selection.count == 1 ) do 
	(
		local selected = selection[1]
	
		local channelID = convertChannelToSelectionDialog.channelIDSpinner.value
		
		-- threshold value, vertex color >= threshold will select the vertex
		local thresholdValue = convertChannelToSelectionDialog.thresholdSpinner.value 
		
		-- invert the effect of the threshold
		local invertSel = convertChannelToSelectionDialog.invertCheckbox.checked
		
		-- get the name for the selection, if any
		local selectionName = ""
		if ( convertChannelToSelectionDialog.saveAsNamedCheckbox.checked ) do 
		(
			selectionName = convertChannelToSelectionDialog.selectionName.text
		)
		
		-- get the vertex paint modifier
		local theVPMod = hvkVertexPaintingTools_GetVertexPaintModWithChannel selected channelID
		
		-- perform selection
		hvkSelectionTools_convertVertexChannelToVertexSelection theVPMod thresholdValue invertSel selectionName
		
		-- update UI
		hvkSelectionTools_UpdateVertexSelectionUI()
	)
)

function hvkChannelConvertTools_UpdateRolloutUI = 
(
	local vertexMode = ( subObjectLevel == 1 )

	-- enable the buttons only if we are in vertex selection sub object level
	hvkChannelConvertTools.convertSelectionToColorsButton.enabled = vertexMode
	hvkChannelConvertTools.convertColorsToSelectionButton.enabled = vertexMode
	
	-- update potentially open dialogs
	hvkChannelConvertTools_UpdateChannelToTextureDialog()
	hvkChannelConvertTools_UpdateTextureToChannelDialog()
	hvkChannelConvertTools_UpdateSelectionToColorsDialog()
	hvkChannelConvertTools_UpdateColorsToSelectionDialog()
)


-- ROLLOUT OPEN

function hvkChannelConvertTools_OpenChannelToBmp = 
(
	CreateDialog convertChannelToTextureDialog modal:false
)

function hvkChannelConvertTools_OpenTextureToChannel = 
(
	CreateDialog convertTextureToChannelDialog modal:false
)

function hvkChannelConvertTools_openSelectionToChannelDialog = 
(
	CreateDialog convertSelectionToChannelDialog modal:false
)

function hvkChannelConvertTools_openChannelToSelectionDialog = 
(
	CreateDialog convertChannelToSelectionDialog modal:false
)



function hvkChannelConvertTools_OpenRollout = 
(
	hvkChannelConvertTools_UpdateRolloutUI()

	callbacks.addScript #selectionSetChanged "hvkChannelConvertTools_UpdateRolloutUI()" id:#HAVOK_SELECTION_TOOLS
	callbacks.addScript #sceneUndo "hvkChannelConvertTools_UpdateRolloutUI()" id:#HAVOK_SELECTION_TOOLS
	callbacks.addScript #sceneRedo "hvkChannelConvertTools_UpdateRolloutUI()" id:#HAVOK_SELECTION_TOOLS
	callbacks.addScript #modPanelSelChanged "hvkChannelConvertTools_UpdateRolloutUI()" id:#HAVOK_VERTEXPAINT_TOOLS	
	callbacks.addScript #modPanelObjPostChange "hvkChannelConvertTools_UpdateRolloutUI()" id:#HAVOK_SELECTION_TOOLS	
	callbacks.addScript #ModPanelSubObjectLevelChanged "hvkChannelConvertTools_UpdateRolloutUI()" id:#HAVOK_SELECTION_TOOLS	
)

function hvkChannelConvertTools_CloseRollout = 
(
	callbacks.removeScripts id:#HAVOK_SELECTION_TOOLS
)