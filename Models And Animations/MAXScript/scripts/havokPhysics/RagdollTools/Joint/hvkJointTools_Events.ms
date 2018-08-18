
fileIn "havokPhysics/ragdollTools/hvkTools_Customizable.ms"

--
-- UI UPDATE METHOD (not an event, but called mainly by events)
--

function hvkJointTools_updateUI =
(
	local selected =  $selection as Array
		
	oneJointSelected = (selected.count == 1) and (hvkJointTools_findConstraintModifier selected[1] != undefined)

	canMakeJoint = (selected.count == 2) and (hvkJointTools_canCreateConstraint selected[1] selected[2])

	local templateSelected = (hvkJointTools.ddlJointType.items.count >= 1)
	
	hvkJointTools.ddlJointType.enabled = templateSelected 
	hvkJointTools.btnCreateJoint.enabled = canMakeJoint and templateSelected
	hvkJointTools.btnReplaceJoint.enabled = oneJointSelected and templateSelected
	hvkJointTools.btnSaveAs.enabled = oneJointSelected
	hvkJointTools.btnRemoveTemplate.enabled = templateSelected
	
	hvkJointTools.grpTemplates.enabled = templateSelected
	
	hvkJointTools.btnCopyJoint.enabled = oneJointSelected
	hvkJointTools.btnPasteJoint.enabled = (canMakeJoint or oneJointSelected) and (hvkGlobal_constraintClipboard != undefined)
	
	hvkJointTools.grpClipboard.enabled = hvkJointTools.btnCopyJoint.enabled or hvkJointTools.btnPasteJoint.enabled
	
	if (hvkGlobal_constraintClipboard != undefined) then
	(
		hvkJointTools.lblClipboardContents.caption = (hvkGlobal_constraintClipboard.modifierType as string)
		hvkJointTools.lblClipboardContents.enabled = true
	)
	else
	(
		hvkJointTools.lblClipboardContents.caption = "Nothing Stored"
		hvkJointTools.lblClipboardContents.enabled = false
	)
		
)

--
-- EVENTS
--

function hvkJointTools_RemoveTemplate_Pressed =
(
	local templateName = hvkJointTools.ddlJointType.selected
	local filename = hvkGlobal_templatesFolder + "/"+templatename+".txt"

	local willDelete = queryBox ("Are you sure you want to remove the template \""+templateName+"\" ?") title:"Remove Template" beep:true

	if (willDelete) then
	(
		local success = deleteFile filename
		if not success then
		(
			messageBox ("File \""+filename+"\" could not be deleted") title:"Remove Template" beep:true
		)
		
		hvkJointTools_updateDropDown()		
		hvkJointTools_updateUI()
	)
		
)

function hvkJointTools_SaveAs_Pressed =
(
	local selected =  $selection as Array
	if (selected.count != 1) then return()
		
	local constraintMod = hvkJointTools_findConstraintModifier selected[1]
	
	if (constraintMod == undefined) then return()	
	
	local template = hvkJointTools_getTemplateFromModifier constraintMod
	
	if (template != undefined) then
	(
		hvkJointTools_saveTemplate template
		
		hvkJointTools_updateDropDown()
	)
	
)

function hvkJointTools_CreateJoint_Pressed =
(
	undo "Havok Create Joint" on
	(
		local selected = $selection as Array
		if (selected.count != 2) then return()

		local parentChild = hvkJointTools_orderParentChild selected[1] selected[2] true

		if (undefined == parentChild) then 
		(
			-- Ok, we ask the user for help
			messageBox ("Please parent "+selected[1].name+" and "+selected[2].name+" to each other first")
			
			return()
		)

		local parentNode = parentChild[1]
		local childNode = parentChild[2]

		local template = hvkJointTools_getSelectedTemplate()

		if (template != undefined) then
		(
			constraintMod = hvkJointTools_createConstraintFromTemplate template parentNode childNode
			
			if (constraintMod != undefined) then
			( 
				local templateName = hvkJointTools.ddlJointType.selected
				
				hvkCustomizable_renameNewJoint constraintMod templateName
			
				hvkCommon_selectModifier constraintMod
			)
		)
	)
)

function hvkJointTools_ReplaceJoint_Pressed =
(
	undo "Havok Replace Joint" on
	(
		local selected =  $selection as Array
		if (selected.count != 1) then return()

		local template = hvkJointTools_getSelectedTemplate()
		if (undefined == template) then return()

		childNode = selected[1]
		
		local currentConstraintMod = hvkJointTools_findConstraintModifier childNode
		if (currentConstraintMod == undefined) then return()
		
		parentNode = currentConstraintMod.parent		
		if (parentNode == undefined) then return()
		
		-- ok, we have everything now
		newConstraintMod = hvkJointTools_createConstraintFromTemplate template parentNode childNode
		
		if (newConstraintMod != undefined) then
		( 
			-- Remove the old one
			deleteModifier childNode currentConstraintMod
			
			local templateName = hvkJointTools.ddlJointType.selected
			
			hvkCustomizable_renameNewJoint newConstraintMod templateName
		
			hvkCommon_selectModifier newConstraintMod
		)		
	)
)

function hvkJointTools_CopyJoint_Pressed =
(
	local selected = $selection as Array
	if (selected.count !=1) then return()

	local constraintMod = hvkJointTools_findConstraintModifier selected[1]
	
	if (constraintMod == undefined) then return()	
	
	local template = hvkJointTools_getTemplateFromModifier constraintMod
	
	if (template != undefined) then
	(
		hvkGlobal_constraintClipboard = template
		
		-- update the ui since we can now paste
		hvkJointTools_updateUI()
	)	
)

function hvkJointTools_PasteJoint_Pressed = 
(
	if (hvkGlobal_constraintClipboard == undefined) then return()

	local selected = $selection as array
		
	if (selected.count == 1) then
	(
		-- Paste = Replace current joint
		undo "Havok Paste&Replace Joint" on
		(
			childNode = selected[1]

			local currentConstraintMod = hvkJointTools_findConstraintModifier childNode
			if (currentConstraintMod == undefined) then return()
			
			parentNode = currentConstraintMod.parent		
			if (parentNode == undefined) then return()
			
			-- ok, we have everything now
			local theTemplate = hvkGlobal_constraintClipboard
			newConstraintMod = hvkJointTools_createConstraintFromTemplate theTemplate parentNode childNode
			
			if (newConstraintMod != undefined) then
			( 
				-- Remove the old one
				deleteModifier childNode currentConstraintMod
							
				hvkCommon_selectModifier newConstraintMod
			)		
		)		
	)
	
	if (selected.count == 2) then
	(
		-- Paste == create new joint
		undo "Havok Paste New Joint" on
		(
			local parentChild = hvkJointTools_orderParentChild selected[1] selected[2] true

			if (undefined == parentChild) then 
			(
				-- Ok, we ask the user for help
				messageBox ("Please parent "+selected[1].name+" and "+selected[2].name+" to each other first")
				
				return()
			)

			local parentNode = parentChild[1]
			local childNode = parentChild[2]

			local theTemplate = hvkGlobal_constraintClipboard

			constraintMod = hvkJointTools_createConstraintFromTemplate theTemplate parentNode childNode
			
			if (constraintMod != undefined) then
			( 			
				hvkCommon_selectModifier constraintMod
			)
			
		)
	)
	
)

function hvkJointTools_OpenRollout =
(
	hvkJointTools_updateDropDown()

	hvkJointTools_updateUI()

	callbacks.addScript #selectionSetChanged "hvkJointTools_SelectionUpdatedCallback()" id:#HAVOK_JOINT_TOOLS
)

function hvkJointTools_CloseRollout =
(
	callbacks.removeScripts id:#HAVOK_JOINT_TOOLS
)

--
-- CALLBACKS
--

function hvkJointTools_SelectionUpdatedCallback =
(
	hvkJointTools_updateUI()
)

