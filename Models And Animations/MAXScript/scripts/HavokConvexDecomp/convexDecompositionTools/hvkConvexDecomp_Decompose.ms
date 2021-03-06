--Auto generated by Visual MAXScript editor. Don't overwrite.

fileIn "havokConvexDecomp/ConvexDecompositionTools/hvkConvexDecomp_Common.ms"
fileIn "havokConvexDecomp/ConvexDecompositionTools/hvkConvexDecomp_Combine.ms"
fileIn "havokConvexDecomp/ConvexDecompositionTools/hvkConvexDecomp_Common.ms"

global \
hvkConvexDecomp_Decompose_OpenRollout,
hvkConvexDecomp_Decompose_CloseRollout,
hvkConvexDecomp_Decompose_SelectionUpdatedCallback,
hvkConvexDecomp_Decompose_UndoRedoCallback,
hvkConvexDecomp_Decompose_UpdateUI,
hvkConvexDecomp_Decompose_Pressed,
hvkConvexDecomp_Decompose_CanDecompose,
hvkConvexDecomp_Decompose_GetOverlapPasses,
hvkConvexDecomp_Decompose_GetOctreeDepth,
hvkConvexDecomp_Decompose_GetTolerance,
hvkConvexDecomp_Decompose_CanClearAttribs,
hvkConvexDecomp_Decompose_ClearDecompositionAttribs,
hvkConvexDecomp_DecomposeAdv_GetMethod,
hvkConvexDecomp_DecomposeAdv_GetReduceMethod,
hvkConvexDecomp_DecomposeAdv_GetWrapIterations,
hvkConvexDecomp_DecomposeAdv_GetWrapConcavity


rollout hvkConvexDecomp_Decompose "Decompose mesh" width:194 height:165
(
	button btnDecompose "Decompose" pos:[9,106] width:175 height:23 toolTip:"Carry out convex decomposition"
	checkbox chkSeparateNodes "Process elements independently" pos:[9,5] width:175 height:18 checked:true toolTip:"Carry out decomposition on each mesh separately"
	label lblTolerance "Tolerance:" pos:[9,26] width:57 height:19
	editText edtTolerance "" pos:[90,27] width:94 height:17
	button btnClearAttribs "Clear Decomposition Attributes" pos:[9,135] width:175 height:23 toolTip:"Clear all attributes storing decomposition data"
	dropDownList ddlReduce "" pos:[94,51] width:92 height:21 items:#("don't reduce", "fastest", "medium", "best")
	label lblReduce "Reduce overlaps" pos:[9,53] width:83 height:17
	dropDownList ddlOctree "" pos:[94,78] width:92 height:21 items:#("don't fix", "fastest", "medium", "best")
	label lblOctree "Fix open meshes" pos:[9,80] width:82 height:17	

	on hvkConvexDecomp_Decompose open do
		hvkConvexDecomp_Decompose_OpenRollout()
	on hvkConvexDecomp_Decompose close do
		hvkConvexDecomp_Decompose_CloseRollout()
	on btnDecompose pressed do
		hvkConvexDecomp_Decompose_Pressed()
	on btnClearAttribs pressed do
		hvkConvexDecomp_Decompose_ClearDecompositionAttribs()	
)

rollout hvkConvexDecomp_DecomposeAdv "Advanced"
(
	dropDownList ddlPrimaryMethod "Method:" items:#("SURFACE", "SOLID", "WRAP")
	dropDownList ddlReduceMethod "Reduce Method:" items:#("DISABLE", "LOCAL", "GLOBAL") selection:2
	editText edtWrapIterations "WRAP Iterations:" text:"2"
	editText edtWrapConcavity "WRAP concavity:" text:"0.01"
	checkbox chkAddShapeModifier "Add Shape modifier to pieces" width:175 height:18 checked:false toolTip:"Add a shape modifier to each newly created piece."
)

function hvkConvexDecomp_DecomposeAdv_GetMethod =
(
	local text = hvkConvexDecomp_DecomposeAdv.ddlPrimaryMethod.selected

	if text == "SURFACE" then
	(
		return 0;
	)
	else if text == "SOLID" then
	(
		return 1;
	)
	else if text == "WRAP" then
	(
		return 2;
	)
	else
	(
		return 1;
	)	
)

function hvkConvexDecomp_DecomposeAdv_GetReduceMethod =
(
	local text = hvkConvexDecomp_DecomposeAdv.ddlReduceMethod.selected

	if text == "DISABLE" then
	(
		return 0;
	)
	else if text == "LOCAL" then
	(
		return 1;
	)
	else if text == "GLOBAL" then
	(
		return 2;
	)
	else
	(
		return 1;
	)	
)

function hvkConvexDecomp_DecomposeAdv_GetWrapIterations =
(
	local intVal = hvkConvexDecomp_DecomposeAdv.edtWrapIterations.text as integer
	if (undefined == intVal) then
	(
		intVal = 0
		hvkConvexDecomp_DecomposeAdv.edtWrapIterations.text = "0"
	)
	if (intVal < 0) then
	(
		intVal = 0
		hvkConvexDecomp_DecomposeAdv.edtWrapIterations.text = "0"
	)
	if (intVal > 12) then
	(
		intVal = 12
		hvkConvexDecomp_DecomposeAdv.edtWrapIterations.text = "12"
	)
	return intVal
)

function hvkConvexDecomp_DecomposeAdv_GetWrapConcavity =
(
	local floatVal = hvkConvexDecomp_DecomposeAdv.edtWrapConcavity.text as float
	if (undefined == floatVal) then
	(
		floatVal = 0
		hvkConvexDecomp_DecomposeAdv.edtWrapConcavity.text = "0.0"
	)
	if (floatVal < 0) then
	(
		floatVal = 0
		hvkConvexDecomp_DecomposeAdv.edtWrapConcavity.text = "0.0"
	)
	return floatVal
)

function hvkConvexDecomp_Decompose_OpenRollout =
(
	if (undefined == hkConvexDecompUtility) then
	(
		hvkConvexDecomp_Decompose.btnDecompose.enabled = false
	)
	else
	(
		hvkConvexDecomp_Decompose.edtTolerance.text = "0.0"

		hvkConvexDecomp_Decompose_UpdateUI()

		callbacks.addScript #selectionSetChanged "hvkConvexDecomp_Decompose_SelectionUpdatedCallback()" id:#HAVOK_CD_DEC
		callbacks.addScript #sceneUndo "hvkConvexDecomp_Decompose_UndoRedoCallback()" id:#HAVOK_CD_DEC
		callbacks.addScript #sceneRedo "hvkConvexDecomp_Decompose_UndoRedoCallback()" id:#HAVOK_CD_DEC
	)
)

function hvkConvexDecomp_Decompose_CloseRollout =
(
	callbacks.removeScripts id:#HAVOK_CD_DEC
)

function hvkConvexDecomp_Decompose_SelectionUpdatedCallback =
(
	hvkConvexDecomp_Decompose_UpdateUI()
)

function hvkConvexDecomp_Decompose_UndoRedoCallback =
(
	hvkConvexDecomp_Decompose_UpdateUI()
)

function hvkConvexDecomp_Decompose_UpdateUI =
(
	local canDecompose = hvkConvexDecomp_Decompose_CanDecompose()

	hvkConvexDecomp_Decompose.btnDecompose.enabled = canDecompose
	
	local canClearAttribs = hvkConvexDecomp_Decompose_CanClearAttribs()

	hvkConvexDecomp_Decompose.btnClearAttribs.enabled = canClearAttribs	
)

function hvkConvexDecomp_Decompose_Pressed =
(
	local inputNodes = $selection as Array
	local inputMeshes = hvkConvexDecomp_removeCamerasFromArray inputNodes
	local outputNodes = #()

	local detachNodes = hvkConvexDecomp_Decompose.chkSeparateNodes.checked
	local singleOut = false
	local hideMesh = hvkConvexDecomp_View.chkHideOriginalMesh.checked

	local guardTolerance = hvkConvexDecomp_Decompose_GetTolerance()
	if (undefined == guardTolerance) then
	(
		guardTolerance = 0 as float
	)

	local reduceOverlapSteps = hvkConvexDecomp_Decompose_GetOverlapPasses()
	local octreeDepth = hvkConvexDecomp_Decompose_GetOctreeDepth()
	
	local method = hvkConvexDecomp_DecomposeAdv_GetMethod()
	local reduceMethod = hvkConvexDecomp_DecomposeAdv_GetReduceMethod()
	local witerations = hvkConvexDecomp_DecomposeAdv_GetWrapIterations()
	local wconcavity = hvkConvexDecomp_DecomposeAdv_GetWrapConcavity()

	hvkConvexDecomp_Combine_Flag_DontUpdate = 1

	local status
	undo "Decompose shape" on
	(
		status = hkConvexDecompUtility.createDecomposition &inputMeshes &outputNodes detachNodes singleOut guardTolerance hideMesh reduceOverlapSteps octreeDepth method reduceMethod witerations wconcavity

		if (status == true) then
		(
			local origMesh = hvkConvexDecomp_GetGroupHead inputMeshes
			if (origMesh == undefined) then
			(
				status = false
			)
			else
			(
				status = hvkConvexDecomp_ConnectNewNodes origMesh &outputNodes
				if (true == status) then
				(
					local groupName = origMesh.name + "__hkConvDecGroup"
					groupName = uniqueName groupName
					group outputNodes name:groupName
					setGroupOpen outputNodes[1].parent true
					hide outputNodes[1].parent

					status = hvkConvexDecomp_ConnectGroupHead origMesh outputNodes[1].parent
					if (true == status) then
					(
						status = hvkConvexDecomp_SetHullTransforms origMesh outputNodes
						if (true == status) then
						(
							select outputNodes
						)
					)
					
					if ( hvkConvexDecomp_DecomposeAdv.chkAddShapeModifier.checked == true ) then
					(
						for node in outputNodes do
						(
							hvkPhysics_createShape node
						)
					)
				)
			)
		)
	)

	redrawViews()

	hvkConvexDecomp_Combine_Flag_DontUpdate = 0
	hvkConvexDecomp_Combine_UpdateUI()

	return status
)

function hvkConvexDecomp_Decompose_CanDecompose = 
(
	local selectedMeshes = $selection as Array
	selectedMeshes = hvkConvexDecomp_removeCamerasFromArray selectedMeshes
	if (undefined == selectedMeshes or
		0 == selectedMeshes.count) then
	(
		return false
	)

	local nSelected = selectedMeshes.count as integer

	if nSelected == 1 then
	(
		local node = selectedMeshes[1]
		if (not canConvertTo node Editable_mesh) then
		(
			return false
		)
		if (undefined != custAttributes.get node hvkConvexDecomp_IsDecomposedCAdef or
			undefined != custAttributes.get node hvkConvexDecomp_OrigMeshCAdef) then
		(
			return false
		)
		return true
	)
	else
	(
		local node = hvkConvexDecomp_GetGroupHead selectedMeshes
		if (undfined == node or not isGroupHead node) then
		(
			return false
		)

		if (undefined != custAttributes.get node hvkConvexDecomp_IsDecomposedCAdef or
			undefined != custAttributes.get node hvkConvexDecomp_OrigMeshCAdef) then
		(
			return false
		)

		local stack = #()
		append stack node
		local nGroupNodes = 0

		while (0 != stack.count) do
		(
			local children = stack[stack.count].children
			deleteItem stack stack.count
			nGroupNodes+=1

			for child in children do
			(
				if (isGroupHead child) then
				(
					append stack child
				)
				else
				(
					if (canConvertTo child Editable_mesh) then 
					(
						if (undefined != custAttributes.get node hvkConvexDecomp_IsDecomposedCAdef or
							undefined != custAttributes.get node hvkConvexDecomp_OrigMeshCAdef) then
						(
							return false
						)
						nGroupNodes+=1
					)
				)
			)
			--node has been popped from stack
		)

		if (nGroupNodes == nSelected) then
		(
			return true
		)
		return false
	)
)

function hvkConvexDecomp_Decompose_GetOverlapPasses =
(
	local text = hvkConvexDecomp_Decompose.ddlReduce.selected

	if text == "fastest" then
	(
		return 2;
	)
	else if text == "medium" then
	(
		return 4;
	)
	else if text == "best" then
	(
		return 6;
	)
	else
	(
		return 0;
	)	
)

function hvkConvexDecomp_Decompose_GetOctreeDepth =
(
	local text = hvkConvexDecomp_Decompose.ddlOctree.selected

	if text == "fastest" then
	(
		return 2;
	)
	else if text == "medium" then
	(
		return 4;
	)
	else if text == "best" then
	(
		return 7;
	)
	else
	(
		return 0;
	)	
)

function hvkConvexDecomp_Decompose_GetTolerance =
(
	local floatVal = hvkConvexDecomp_Decompose.edtTolerance.text as float
	
	if (undefined == floatVal) then
	(
		hvkConvexDecomp_Decompose.edtTolerance.text = "0.0"
		return 0 as float
	)
	else
	(
		if (floatVal < 0) then
		(
			floatVal = 0
			hvkConvexDecomp_Decompose.edtTolerance.text = "0.0"
		)
		return floatVal
	)
)

function hvkConvexDecomp_Decompose_CanClearAttribs = 
(
	local selectedNodes = $selection as Array
	local selectedMeshes = hvkConvexDecomp_GetSelectedMeshes selectedNodes
	if (undefined == selectedMeshes or 0 == selectedMeshes.count) then
	(
		return false
	)
	
	return true
)

function hvkConvexDecomp_Decompose_ClearDecompositionAttribs =
(
	local selectedNodes = $selection as Array
	local selectedMeshes = hvkConvexDecomp_GetSelectedMeshes selectedNodes 
	if (0 == selectedMeshes.count) then
	(
		return false
	)
	
	for mesh in selectedMeshes do
	(
		hvkConvexDecomp_HideOriginalMesh mesh false		
		
		local groupHeadCA = custAttributes.get mesh hvkConvexDecomp_ConvexHullGroupCAdef
		if (undefined != groupHeadCA) then
		(
			local groupHead = groupHeadCA.groupHead
			if (undefined != groupHead) then
			(
				unhide groupHead.children
				
				for child in groupHead.children do
				(
					--Attributes per hull
					custAttributes.delete child hvkConvexDecomp_OrigMeshCAdef
					custAttributes.delete child hvkConvexDecomp_TransformCAdef					
				)	
				
				--Group head
				custAttributes.delete groupHead hvkConvexDecomp_ExplodeCAdef				
			)
		)
		
		--Original mesh attributes
		custAttributes.delete mesh hvkConvexDecomp_IsDecomposedCAdef					
		custAttributes.delete mesh hvkConvexDecomp_ConvexHullGroupCAdef
		custAttributes.delete mesh hvkConvexDecomp_OrigMeshScaleCAdef
	)
)









