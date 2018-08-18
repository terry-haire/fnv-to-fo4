global \
hvkSelectionTools_OpenRollout,
hvkSelectionTools_CloseRollout,
hvkSelectionTools_SaveVertexSelectionAs,
hvkSelectionTools_SaveTriangleSelectionAs,
hvkSelectionTools_SaveEdgeSelectionAs,
hvkSelectionTools_SaveVertexSelection,
hvkSelectionTools_SaveTriangleSelection,
hvkSelectionTools_SaveEdgeSelection,
hvkSelectionTools_CreateSelection,
hvkSelectionTools_Refresh,
hvkSelectionTools_RenameVertexSelection,
hvkSelectionTools_RenameTriangleSelection,
hvkSelectionTools_RenameEdgeSelection,
hvkSelectionTools_DeleteVertexSelection,
hvkSelectionTools_DeleteTriangleSelection,
hvkSelectionTools_DeleteEdgeSelection,
hvkSelectionTools_LoadVertexSelection,
hvkSelectionTools_LoadTriangleSelection,
hvkSelectionTools_LoadEdgeSelection,
hvkVertexPaintingTools_OpenRollout,
hvkVertexPaintingTools_CloseRollout,
hvkVertexPaintingTools_Refresh,
hvkVertexPaintingTools_GetAllChannels,
hvkVertexPaintingTools_CreateNewChannel,
hvkVertexPaintingTools_PaintChannel,
hvkVertexPaintingTools_PaintCurrentChannel,
hvkVertexPaintingTools_RenameChannel,
hvkVertexPaintingTools_RemoveChannel,
hvkVertexPaintingTools_SetChannelType,
hvkVertexPaintingTools_SetChannelRescale, 
hvkVertexPaintingTools_ChangeChannelRescaleMinValue,
hvkVertexPaintingTools_ChangeChannelRescaleMaxValue,
hvkVertexPaintingTools_addExportChannel,
hvkVertexPaintingTools_addExportChannelFromCurrentSelection,
hvkVertexPaintingTools_renameExportChannel,
hvkVertexPaintingTools_editExportChannel,
hvkVertexPaintingTools_removeExportChannel,
hvkVertexPaintingTools_toggleDisplayOfExportChannel,
hvkSelectionTools_convertCurrentVertexSelectionToVertexChannel,
hvkSelectionTools_convertVertexChannelToVertexSelection,
hvkChannelConvert_addUnwrapUVWModifierToNodeAndFlatten,
hvkChannelConvert_renderVertexColorsToTexture,
hvkChannelConvertTools_convertChannelToTexture,
hvkChannelConvertTools_ChannelToTexture_updateChannelName,
hvkChannelConvertTools_ChannelToTexture_updateUVWChannelName,
hvkChannelConvertTools_ChannelToTexture_browseForFile,
hvkChannelConvertTools_OpenRollout,
hvkChannelConvertTools_CloseRollout,
hvkChannelConvertTools_OpenChannelToBmp,
hvkChannelConvertTools_OpenTextureToChannel,
hvkChannelConvertTools_openSelectionToChannelDialog,
hvkChannelConvertTools_openChannelToSelectionDialog,
hvkChannelConvertTools_SelectionToChannel_updateChannelName,
hvkChannelConvertTools_SelectionToChannel_convertSelectionToChannel,
hvkChannelConvertTools_ChannelToSelection_updateChannelName,
hvkChannelConvertTools_ChannelToSelection_convertChannelToSelection,
hvkChannelConvertTools_convertTextureToChannel,
hvkChannelConvertTools_TextureToChannel_updateChannelName,
hvkChannelConvertTools_TextureToChannel_browseForFile,
hvkChannelConvertTools_UpdateChannelToTextureDialog,
hvkChannelConvertTools_UpdateTextureToChannelDialog,
hvkChannelConvertTools_UpdateSelectionToColorsDialog,
hvkChannelConvertTools_UpdateColorsToSelectionDialog,
hvkChannelConvertTools_UpdateRolloutUI,
hvkCloth_openRenameDialogAndGetString
  
   
filein "hvkSelectionTools_VerticesRollout.ms"
filein "hvkSelectionTools_TrianglesRollout.ms"
filein "hvkSelectionTools_EdgesRollout.ms"
filein "hvkSelectionTools_Events.ms"
filein "hvkVertexPaintingTools_Utils.ms"
filein "hvkVertexPaintingTools_Rollout.ms"
filein "hvkVertexPaintingTools_Events.ms"
filein "hvkChannelConvertTools_ConvertRollout.ms"
filein "hvkChannelConvertTools_ChannelToBmpDialog.ms"
filein "hvkChannelConvertTools_TextureToChannelDialog.ms"
filein "hvkChannelConvertTools_SelectionToChannelDialog.ms"
filein "hvkChannelConvertTools_ChannelToSelectionDialog.ms"
filein "hvkChannelConvertTools_Utils.ms"
filein "hvkChannelConvertTools_Events.ms" 
filein "hvkRenameDialog.ms"  
   
global hvkCustomizable_makeMeshChannelToolDockable = true

function hvkCloth_openClothTools =  
(
	global hvkHavokClothToolFloater
	
	-- local totalHeight = hvkVertexSelectionTools.height + hvkTriangleSelectionTools.height + hvkVertexPaintingTools.height
	totalHeight = 828 -- totalHeight + 40
	 
	local totalWidth = 278
	if ( totalWidth < hvkVertexSelectionTools.width ) do totalWidth = hvkVertexSelectionTools.width
	if ( totalWidth < hvkTriangleSelectionTools.width ) do totalWidth = hvkTriangleSelectionTools.width
	if ( totalWidth < hvkVertexPaintingTools.width ) do totalWidth = hvkVertexPaintingTools.width
	if ( totalWidth < hvkEdgeSelectionTools.width ) do totalWidth = hvkEdgeSelectionTools.width
	totalWidth = totalWidth + 5

	if (hvkHavokClothToolFloater == undefined) or (not hvkHavokClothToolFloater.open) then
	(
		hvkHavokClothToolFloater = newRolloutFloater "Havok Mesh Channel Toolbox" totalWidth totalHeight
		
		if ( hvkCustomizable_makeMeshChannelToolDockable == true ) then
		(
			cui.RegisterDialogBar hvkHavokClothToolFloater style:#(#cui_dock_left, #cui_dock_right, #cui_floatable, #cui_handles, #cui_max_sized) minSize:[totalWidth+20,-1] maxSize:[totalWidth+20,-1]
		)

		addRollout hvkVertexSelectionTools hvkHavokClothToolFloater rolledUp:false
		addRollout hvkTriangleSelectionTools hvkHavokClothToolFloater rolledUp:false
		addRollout hvkEdgeSelectionTools hvkHavokClothToolFloater rolledUp:false
		addRollout hvkVertexPaintingTools hvkHavokClothToolFloater rolledUp:false		
		addRollout hvkChannelConvertTools hvkHavokClothToolFloater rolledUp:true
	) 
)


function hvkCloth_openRenameDialogAndGetString oldName title:"Untitled" = 
(
	gOldText = oldName
	gRolloutTitle = title
	CreateDialog selRenameRollout modal:true
	
	if ( gRenameRolloutOkPressed ) do 
	( 
		local newName = trimRight ( trimLeft ( selRenameRollout.renameEdit.text ) )
		-- discard empty names and names with spaces
		if ( newName != "" ) do 
		(
			return newName
		)
	)
	return undefined 
)