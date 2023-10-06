-- Definition of the functions called from the UI

fileIn "havokPhysics/ragdollTools/hvkTools_Globals.ms"

--
-- UPDATE UI
--

function hvkOptions_updateUI =
(
	hvkOptions.spnScaleX.value = hvkGlobal_boneScaleX
	hvkOptions.spnScaleY.value = hvkGlobal_boneScaleY
	hvkOptions.spnScaleZ.value = hvkGlobal_boneScaleZ	

	hvkOptions.cbFreezeAssociated.checked = hvkGlobal_freezeAssociatedBone

	local theFolder = hvkGlobal_templatesFolder
	
	if theFolder.count > 30 then 
	(
		theFolder = "..."+ (substring theFolder (theFolder.count-27) -1)
	)
	
	hvkOptions.lblTemplatesFolder.text = theFolder
)


--
-- EVENTS
--

function hvkOptions_Options_Changed =
(
	-- Axis cannot be parallel
	if ( (hvkOptions.ddlMainAxis.selection - 1) / 2) == ( (hvkOptions.ddlBendAxis.selection - 1) / 2) then
	(
		MessageBox "Main Axis and Bend Axis cannot be parallel"
		-- Restore previous value
		hvkOptions_UpdateUI()
	)
	else
	(

		hvkGlobal_mainAxis = hvkOptions.ddlMainAxis.selection
		hvkGlobal_bendAxis = hvkOptions.ddlBendAxis.selection

		hvkGlobal_boneScaleX = hvkOptions.spnScaleX.value
		hvkGlobal_boneScaleY = hvkOptions.spnScaleY.value
		hvkGlobal_boneScaleZ = hvkOptions.spnScaleZ.value 

		hvkGlobal_freezeAssociatedBone = hvkOptions.cbFreezeAssociated.checked
	)	
)

function hvkOptions_ChangeTemplatesFolder_Pressed =
(
	local initialPath = hvkGlobal_templatesFolder+"/*.txt"
	filename = getOpenFileName caption:"Open new template folder and select any template" filename:initialPath types:"Templates (*.txt)|(*.txt)"
	
	if (undefined!=filename) then
	(
		hvkGlobal_templatesFolder = GetFilenamePath filename
		hvkOptions_UpdateUI()
		-- Refresh also joint tools
		hvkJointTools_updateDropDown()
		hvkJointTools_updateUI()
	)

)


function hvkOptions_OpenRollout =
(
	hvkOptions_updateUI()

	callbacks.addScript #filePostOpen "hvkOptions_FilePostOpenCallback()" id:#HAVOK_TOOLS_OPTIONS
)

function hvkOptions_CloseRollout =
(
	callbacks.removeScripts id:#HAVOK_TOOLS_OPTIONS

)
--
-- CALLBACKS
--

function hvkOptions_FilePostOpenCallback =
(
	hvkOptions_updateUI()
)

