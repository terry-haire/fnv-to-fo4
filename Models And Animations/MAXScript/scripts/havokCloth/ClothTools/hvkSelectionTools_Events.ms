-- UTILS

function hvkSelectionTools_canCreateSelectionFromCurrent supportedSubObjLevels supportedTypes = 
(
	local selected =  $selection as Array
	local justOneSelected = selected.count==1
	
	-- if there is one object selected and subobject level is among the requested ones
	local canCreate = ( ( findItem supportedSubObjLevels subobjectLevel ) != 0 ) and justOneSelected 

	-- make sure the selection comes from a supported modifier. See HCL-934
	if ( canCreate ) do
	(
		local currObj = modPanel.getCurrentObject()
		canCreate = ( ( findItem supportedTypes (classof currObj) ) != 0 )
	)
	
	return canCreate
)

function hvkSelectionTools_canCreateVertexSelectionFromCurrent = 
(
	local supportedSubObjLev = #(1)
	local supportedTypes = #( Mesh_Select, Poly_Select, Edit_Mesh, Editable_mesh, Editable_Poly )
	
	return hvkSelectionTools_canCreateSelectionFromCurrent supportedSubObjLev supportedTypes
)

function hvkSelectionTools_canCreateTriangleSelectionFromCurrent = 
(
	local supportedSubObjLev = #(3, 4)
	local supportedTypes = #( Mesh_Select, Edit_Mesh, Editable_mesh )
	
	return hvkSelectionTools_canCreateSelectionFromCurrent supportedSubObjLev supportedTypes
)

function hvkSelectionTools_canCreateEdgeSelectionFromCurrent = 
(
	local supportedSubObjLev = #(2)
	local supportedTypes = #( Mesh_Select, Poly_Select, Edit_Mesh, Editable_mesh, Editable_Poly )
	
	return hvkSelectionTools_canCreateSelectionFromCurrent supportedSubObjLev supportedTypes
)

function hvkSelectionTools_IsVertexSetSelected = 
(
	return hvkVertexSelectionTools.selectionSets.selection != 0
)

function hvkSelectionTools_IsTriangleSetSelected = 
(
	return hvkTriangleSelectionTools.selectionSets.selection != 0
)

function hvkSelectionTools_IsEdgeSetSelected = 
(
	return hvkEdgeSelectionTools.selectionSets.selection != 0
)

function hvkSelectionTools_GetSelectedVertexSet = 
(
	return hvkVertexSelectionTools.selectionSets.selected
) 

function hvkSelectionTools_GetSelectedTriangleSet = 
(
	return hvkTriangleSelectionTools.selectionSets.selected
)

function hvkSelectionTools_GetSelectedEdgeSet = 
(
	return hvkEdgeSelectionTools.selectionSets.selected
)

--
-- UPDATE UI
--

global g_lastVertSelectionCreated = ""
global g_lastTriSelectionCreated = ""
global g_lastEdgeSelectionCreated = ""
 
function hvkSelectionTools_SelectLastCreatedSelection selList &selEntry =
(
	-- select the last created channel, if any
	if ( selEntry != "" ) do 
	(	
		local notFound = true
		for i = 1 to selList.items.count while notFound do 
		(
			if ( selList.items[i] == selEntry ) do
			(
				selList.selection = i
				notFound = false
			)
		)	
		selEntry = ""
	)
)

function  hvkSelectionTools_SelectLastCreatedVertexSelection =
(
	 hvkSelectionTools_SelectLastCreatedSelection hvkVertexSelectionTools.selectionSets &g_lastVertSelectionCreated
)

function  hvkSelectionTools_SelectLastCreatedTriangleSelection =
(
	 hvkSelectionTools_SelectLastCreatedSelection hvkTriangleSelectionTools.selectionSets &g_lastTriSelectionCreated
)

function  hvkSelectionTools_SelectLastCreatedEdgeSelection =
(
	 hvkSelectionTools_SelectLastCreatedSelection hvkEdgeSelectionTools.selectionSets &g_lastEdgeSelectionCreated
)

function hvkSelectionTools_UpdateSelectionUI selectionRollout getNamesFunction canCreateFunction refreshSelectionFunction =
(
	local selected =  $selection as Array
	local justOneSelected = selected.count==1
	
	-- clear selection sets list
	selectionRollout.selectionSets.items = #()
	
	if( justOneSelected ) do 
	(
		selectionNames = getNamesFunction selected[1]

		-- and put sets of currently selected mesh
		for name in selectionNames do
		(
			selectionRollout.selectionSets.items = append selectionRollout.selectionSets.items ( name )
		) 
		-- sort list
		selectionRollout.selectionSets.items = sort selectionRollout.selectionSets.items
	)
	
	refreshSelectionFunction()
	local isASetselected = ( selectionRollout.selectionSets.selection != 0 )
	
	-- enable/disable buttons
	selectionRollout.saveSelectionAs.enabled = canCreateFunction()
	selectionRollout.saveSelection.enabled = isASetselected and canCreateFunction()
	selectionRollout.deleteSelection.enabled = isASetselected
	selectionRollout.loadSelection.enabled = isASetselected
	selectionRollout.renameSelection.enabled = isASetselected  
)

function hvkSelectionTools_UpdateVertexSelectionUI =
(
	hvkSelectionTools_UpdateSelectionUI hvkVertexSelectionTools hkSelectionUtilGUP.getVertSelectionNames hvkSelectionTools_canCreateVertexSelectionFromCurrent  hvkSelectionTools_SelectLastCreatedVertexSelection
)

function hvkSelectionTools_UpdateTriangleSelectionUI =
(
	hvkSelectionTools_UpdateSelectionUI hvkTriangleSelectionTools hkSelectionUtilGUP.getFaceSelectionNames hvkSelectionTools_canCreateTriangleSelectionFromCurrent  hvkSelectionTools_SelectLastCreatedTriangleSelection
)

function hvkSelectionTools_UpdateEdgeSelectionUI =
(
	hvkSelectionTools_UpdateSelectionUI hvkEdgeSelectionTools hkSelectionUtilGUP.getEdgeSelectionNames hvkSelectionTools_canCreateEdgeSelectionFromCurrent  hvkSelectionTools_SelectLastCreatedEdgeSelection
)

function hvkSelectionTools_UpdateUI = 
(
	hvkSelectionTools_UpdateVertexSelectionUI()
	hvkSelectionTools_UpdateTriangleSelectionUI()
	hvkSelectionTools_UpdateEdgeSelectionUI()
)

function hvkSelectionTools_ForceReselect = 
(
	oldObj = modPanel.getCurrentObject()
	modPanel.setCurrentObject $.baseObject
	if( oldObj != undefined ) do modPanel.setCurrentObject oldObj
)

--
-- ROLLOUT OPEN
--

function hvkSelectionTools_OpenRollout = 
(
	hvkSelectionTools_UpdateUI()
	
	callbacks.addScript #selectionSetChanged "hvkSelectionTools_SelectionUpdatedCallback()" id:#HAVOK_SELECTION_TOOLS
	callbacks.addScript #sceneUndo "hvkSelectionTools_UndoRedoCallback()" id:#HAVOK_SELECTION_TOOLS
	callbacks.addScript #sceneRedo "hvkSelectionTools_UndoRedoCallback()" id:#HAVOK_SELECTION_TOOLS
	callbacks.addScript #nodeRenamed "hvkSelectionTools_NodeRenamedCallback()" id:#HAVOK_SELECTION_TOOLS
	callbacks.addScript #modPanelSelChanged "hvkSelectionTools_SelectionUpdatedCallback()" id:#HAVOK_VERTEXPAINT_TOOLS	
	callbacks.addScript #modPanelObjPostChange "hvkSelectionTools_ModPanelChangeCallback()" id:#HAVOK_SELECTION_TOOLS	
)

function hvkSelectionTools_CloseRollout = 
(
	callbacks.removeScripts id:#HAVOK_SELECTION_TOOLS
)

function hvkSelectionTools_CreateSelection selectionName =
(
	local selected =  $selection as Array
		
	local justOneSelected = selected.count==1
	if( justOneSelected ) do 
	(
		local theNode = selected[1]
		
		if ( selectionName != "" ) do
		(
			-- create a new named vertex selection from current selection
			hkSelectionUtilGUP.createNamedSelectionFromCurrent theNode selectionName
			if ( subobjectlevel == 1 ) then
			(
				g_lastVertSelectionCreated = copy selectionName			
			)
			else if ( subobjectlevel == 2 ) then
			(
				g_lastEdgeSelectionCreated = copy selectionName			
			)
			else if ( subobjectlevel == 3 ) do
			(
				g_lastTriSelectionCreated = copy selectionName
			)
		)
	)
	
	-- refresh UI
	hvkSelectionTools_Refresh()	
) 

function hvkSelectionTools_SaveSelectionAs canCreateFunction = 
(
	if ( canCreateFunction() ) do 
	(
		newName = hvkCloth_openRenameDialogAndGetString "" title:"Save Selection"
		if ( newName != undefined ) do 
		(
			undo "Havok Create Selection" on
			(
				hvkSelectionTools_CreateSelection newName
			)
		)
	)
)

function hvkSelectionTools_SaveVertexSelectionAs = 
(
	hvkSelectionTools_SaveSelectionAs hvkSelectionTools_canCreateVertexSelectionFromCurrent
)

function hvkSelectionTools_SaveTriangleSelectionAs = 
(
	hvkSelectionTools_SaveSelectionAs hvkSelectionTools_canCreateTriangleSelectionFromCurrent
)

function hvkSelectionTools_SaveEdgeSelectionAs = 
(
	hvkSelectionTools_SaveSelectionAs hvkSelectionTools_canCreateEdgeSelectionFromCurrent
)

function hvkSelectionTools_SaveSelection canCreateFunction getSelectedSetFunction overwriteFunction = 
(
	local selected =  $selection as Array
		
	local justOneSelected = selected.count==1
	
	if ( justOneSelected and canCreateFunction() ) do 
	(
		local theNode = selected[1]
		selectionName = getSelectedSetFunction()
		
		if ( selectionName != undefined ) do 
		(
			-- create a new named selection from current selection
			undo "Havok Overwrite Selection" on
			(
				overwriteFunction theNode selectionName
			)
		)
	)
)

function hvkSelectionTools_SaveVertexSelection = 
(
	hvkSelectionTools_SaveSelection hvkSelectionTools_canCreateVertexSelectionFromCurrent hvkSelectionTools_GetSelectedVertexSet hkSelectionUtilGUP.overwriteNamedVertSelectionFromCurrent
)

function hvkSelectionTools_SaveTriangleSelection = 
(
	hvkSelectionTools_SaveSelection hvkSelectionTools_canCreateTriangleSelectionFromCurrent hvkSelectionTools_GetSelectedTriangleSet hkSelectionUtilGUP.overwriteNamedFaceSelectionFromCurrent
)

function hvkSelectionTools_SaveEdgeSelection = 
(
	hvkSelectionTools_SaveSelection hvkSelectionTools_canCreateEdgeSelectionFromCurrent hvkSelectionTools_GetSelectedEdgeSet hkSelectionUtilGUP.overwriteNamedEdgeSelectionFromCurrent
)

function hvkSelectionTools_Refresh = 
(
	hvkSelectionTools_UpdateUI()
)

function hvkSelectionTools_RenameSelection isSetSelectedFunction getSelectedSetFunction renameSetFunction = 
(
	local isASetselected = isSetSelectedFunction()
	
	local selected =  $selection as Array
	local justOneNodeSelected = selected.count==1
	
	if ( justOneNodeSelected and isASetselected ) do
	(
		oldName = getSelectedSetFunction()
		newName = hvkCloth_openRenameDialogAndGetString oldName title:"Rename Selection"
		
		if ( newName != undefined ) do 
		(
			renameSetFunction selected[1] oldName newName 
		)
	)
	
	hvkSelectionTools_ForceReselect() -- Bug in Max, we don't see the updated name without this
	hvkSelectionTools_Refresh()
)

function hvkSelectionTools_RenameVertexSelection = 
(
	hvkSelectionTools_RenameSelection hvkSelectionTools_IsVertexSetSelected hvkSelectionTools_GetSelectedVertexSet hkSelectionUtilGUP.renameVertSelection 
)

function hvkSelectionTools_RenameTriangleSelection = 
(
	hvkSelectionTools_RenameSelection hvkSelectionTools_IsTriangleSetSelected hvkSelectionTools_GetSelectedTriangleSet hkSelectionUtilGUP.renameFaceSelection 
)

function hvkSelectionTools_RenameEdgeSelection = 
(
	hvkSelectionTools_RenameSelection hvkSelectionTools_IsEdgeSetSelected hvkSelectionTools_GetSelectedEdgeSet hkSelectionUtilGUP.renameEdgeSelection 
)

function hvkSelectionTools_DeleteSelection isSetSelectedFunction getSelectedSetFunction deleteSetFunction = 
(
	local isASetselected = isSetSelectedFunction()
	
	local selected =  $selection as Array
	local justOneNodeSelected = selected.count==1
	
	if ( justOneNodeSelected and isASetselected ) do
	(
		-- make sure the modify panel is selected 
		max modify mode
		
		name = getSelectedSetFunction()
		undo "Havok Remove Selection" on
		(
			deleteSetFunction selected[1] name 
		)
	)
	
	hvkSelectionTools_Refresh()
)

function hvkSelectionTools_DeleteVertexSelection = 
(
	hvkSelectionTools_DeleteSelection hvkSelectionTools_IsVertexSetSelected hvkSelectionTools_GetSelectedVertexSet hkSelectionUtilGUP.deleteVertSelection
	hvkVertexSelectionTools.selectionSets.selection = 0
)

function hvkSelectionTools_DeleteTriangleSelection = 
(
	hvkSelectionTools_DeleteSelection hvkSelectionTools_IsTriangleSetSelected hvkSelectionTools_GetSelectedTriangleSet hkSelectionUtilGUP.deleteFaceSelection
	hvkTriangleSelectionTools.selectionSets.selection = 0
)

function hvkSelectionTools_DeleteEdgeSelection = 
(
	hvkSelectionTools_DeleteSelection hvkSelectionTools_IsEdgeSetSelected hvkSelectionTools_GetSelectedEdgeSet hkSelectionUtilGUP.deleteEdgeSelection
	hvkEdgeSelectionTools.selectionSets.selection = 0
)

function hvkSelectionTools_LoadSelection isSetSelectedFunction getSelectedSetFunction loadSetFunction = 
(
	local isASetselected = isSetSelectedFunction()
	
	local selected =  $selection as Array
	local justOneNodeSelected = selected.count==1
	
	if ( justOneNodeSelected and isASetselected ) do
	(
	    max modify mode
	    
		name = getSelectedSetFunction()
		
		loadSetFunction selected[1] name 
	)
	
	hvkSelectionTools_Refresh()
)

function hvkSelectionTools_LoadVertexSelection = 
(
	hvkSelectionTools_LoadSelection hvkSelectionTools_IsVertexSetSelected hvkSelectionTools_GetSelectedVertexSet hkSelectionUtilGUP.loadVertSelection
)

function hvkSelectionTools_LoadTriangleSelection = 
(
	hvkSelectionTools_LoadSelection hvkSelectionTools_IsTriangleSetSelected hvkSelectionTools_GetSelectedTriangleSet hkSelectionUtilGUP.loadFaceSelection
)

function hvkSelectionTools_LoadEdgeSelection = 
(
	hvkSelectionTools_LoadSelection hvkSelectionTools_IsEdgeSetSelected hvkSelectionTools_GetSelectedEdgeSet hkSelectionUtilGUP.loadEdgeSelection
)

--
-- 

--

function hvkSelectionTools_SelectionUpdatedCallback =
(
	hvkSelectionTools_UpdateUI()
)

function hvkSelectionTools_UndoRedoCallback =
(
	hvkSelectionTools_UpdateUI()
)

function hvkSelectionTools_NodeRenamedCallback = 
(
	hvkSelectionTools_UpdateUI()
)

function hvkSelectionTools_NamedSelSetChangeCallback = 
(
	hvkSelectionTools_UpdateUI()
)

function hvkSelectionTools_ModPanelChangeCallback = 
(
	hvkSelectionTools_UpdateUI()
)
