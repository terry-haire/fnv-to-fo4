
fileIn "havokPhysics/ragdolltools/hvkTools_Customizable.ms"

--
-- UPDATE UI
--

function hvkBoneTools_UpdateBonePropertiesValues =
(
	local selected =  $selection as Array

	-- This function is only called from UpdateUI, and we can safely assume there is at least one bone selected 
	
	local sameMass = true
	local commonMass = hvkTools_GetRBMass selected[1]
	local sameRestitution = true
	local commonRestitution = hvkTools_GetRBRestitution selected[1]
	local sameFriction = true
	local commonFriction = hvkTools_GetRBFriction selected[1]
	
	for selObj in selected while (sameMass or sameRestitution or sameFriction) do
	(
		sameMass = sameMass and ( (hvkTools_GetRBMass selObj) == commonMass )
		sameRestitution = sameRestitution and ( (hvkTools_GetRBRestitution selObj) == commonRestitution)
		sameFriction = sameFriction and ( (hvkTools_GetRBFriction selObj) == commonFriction)		
	)
	
	if (sameMass) then 
	(
		hvkBoneTools.spnMass.value = commonMass
	)
	else 
	(
		hvkBoneTools.spnMass.indeterminate = true 
	)
	
	if (sameRestitution) then 
	(
		hvkBoneTools.spnRestitution.value = commonRestitution
	)
	else
	(
		hvkBoneTools.spnRestitution.indeterminate = true
	)

	if (sameFriction) then 
	(
		hvkBoneTools.spnFriction.value = commonFriction
	)
	else
	(
		hvkBoneTools.spnFriction.indeterminate = true
	)

)

function hvkBoneTools_UpdateUI =
(
	local selected =  $selection as Array
	
	local oneOrMoreSelected = selected.count>0
	
	local allRigidBodies = oneOrMoreSelected
	local allProxies = oneOrMoreSelected
	local allBoneProxies = oneOrMoreSelected
	local allChainProxies = oneOrMoreSelected
	local allCanBeBoneProxies = oneOrMoreSelected

	for selObj in selected while (allRigidBodies or allCanBeBoneProxies or allProxies) do
	(
		local isRigidBody = hvkPhysics_isRigidBody selObj
		local isBoneProxy = isRigidBody and (hvkTools_isBoneProxy selObj)
		local isChainProxy = isRigidBody and (hvkTools_isChainProxy selObj)
		
		allRigidBodies = allRigidBodies and isRigidBody
		
		allBoneProxies = allBoneProxies and isBoneProxy
		
		allChainProxies = allChainProxies and isChainProxy
				
		allProxies = allProxies and (isBoneProxy or isChainProxy)

		allCanBeBoneProxies = allCanBeBoneProxies and (hvkTools_canCreateBoneProxyFrom selObj)
	)	
	
	local oneProxyOnly = allProxies and (selected.count == 1)

	local oneRBOnly = allRigidBodies and (selected.count == 1)

	local oneBoneOnly = allCanBeBoneProxies and (selected.count == 1)

	local canCreateChain = hvkTools_canCreateChainProxyFrom selected
	
	-- Enable / Disable properties for creating single proxies
	hvkBoneTools.btnCapsule.enabled = allCanBeBoneProxies or allBoneProxies
	hvkBoneTools.btnBox.enabled = allCanBeBoneProxies or allBoneProxies
	
	-- Enable / disable properties for creating multiple proxies
	hvkBoneTools.btnCapsuleChain.enabled = canCreateChain or allChainProxies
	hvkBoneTools.btnBoxChain.enabled = canCreateChain or allChainProxies

	-- Disable the group box if all buttons are disabled
	hvkBoneTools.grpCreateBone.enabled = hvkBoneTools.btnCapsule.enabled or hvkBoneTools.btnCapsuleChain.enabled
	
	-- Change the label depending on whether we create or replace
	if (allProxies) then
	(
		hvkBoneTools.grpCreateBone.caption = "Replace Proxy RB"
	)
	else
	(
		hvkBoneTools.grpCreateBone.caption = "Create Proxy RB"
	)

	-- Add/Remove association
	hvkBoneTools.btnUseCustomSingle.enabled = oneBoneOnly
	hvkBoneTools.btnUseCustomChain.enabled = canCreateChain
	hvkBoneTools.btnRemoveAssociation.enabled = oneProxyOnly

	-- Enable / Disable properties for editing rigid bodies
	hvkBoneTools.grpBoneProperties.enabled = allRigidBodies
	hvkBoneTools.spnMass.enabled = allRigidBodies
	hvkBoneTools.spnFriction.enabled = allRigidBodies
	hvkBoneTools.spnRestitution.enabled = allRigidBodies
	hvkBoneTools.btnOpenRBModifier.enabled = oneRBOnly
	hvkBoneTools.btnAddTerminal.enabled = allRigidBodies
	
	hvkBoneTools.btnAlignPivots.enabled = allProxies
	hvkBoneTools.btnAlignObjects.enabled = allProxies
	hvkBoneTools.btnSelectDrivingBone.enabled = allProxies
	hvkBoneTools.grpAssociatedBones.enabled = allProxies
	hvkBoneTools.lblAssociatedBonesValue.enabled = allProxies

	if (oneProxyOnly) then
	(
	
		if (allBoneProxies) then -- single bone
		(			
			hvkBoneTools.grpAssociatedBones.caption = "Associated Bone:"
			local associated = hvkTools_getAssociatedBone selected[1]
			if (undefined == associated) then
			(
				hvkBoneTools.lblAssociatedBonesValue.caption = "<none>"
			)
			else
			(
				hvkBoneTools.lblAssociatedBonesValue.caption = associated.name
			)
		)
		else -- chain
		(
			hvkBoneTools.grpAssociatedBones.caption = "Associated Chain:"
			local chain = hvkTools_getAssociatedChain selected[1]
			if (undefined == chain) then
			(
				hvkBoneTools.lblAssociatedBonesValue.caption = "<none>"
			)
			else
			(
				-- the button shows the text "start - end"
				labText = chain[1].name + " - " + chain[2].name
				hvkBoneTools.lblAssociatedBonesValue.caption = labText
			)
		)			
	)
	else
	(
		if (allProxies) then 
		(
			hvkBoneTools.grpAssociatedBones.caption = "Associated Bone(s):"
			hvkBoneTools.lblAssociatedBonesValue.caption = "<multiple selected>"
		)
		else
		(
			hvkBoneTools.grpAssociatedBones.caption = "Associated Bone(s):"
			hvkBoneTools.lblAssociatedBonesValue.caption = "<none>"
		)
	)

	
	if (allRigidBodies) then
	(
		hvkBoneTools_UpdateBonePropertiesValues()
	)
)

-- 
-- EVENTS
--

function hvkBoneTools_SelectDrivingBone_Pressed =
(
	undo "Select Driving Bone(s)" on
	(
		local newSelection = #()
		
		selected = selection as Array
		for selObj in selected do
		(
			drivingBone = hvkTools_GetAssociatedBone selObj

			if (drivingBone != undefined) then
			(
				append newSelection drivingBone
			)
			else
			(
				-- try if it's a chain
				startEnd = hvkTools_getAssociatedChain selObj
				
				if (startEnd != undefined) then
				(
					chainBones = hvkTools_getBonesInChain startEnd[1] startEnd[2]

					join newSelection chainBones
				)
			)
		)
		
		select newSelection
		
	)
)

function hvkBoneTools_AlignPivots_Pressed =
(
	undo "Havok Align Pivots" on
	(
		selected = hvkTools_reorderParentFirst (selection as Array)

		for selObj in selected do
		(
			drivingBone = hvkTools_getAssociatedBoneOrStartChain selObj

			if (drivingBone != undefined) then
			(
				hvkCommon_AlignPivotTo selObj drivingBone true -- (true means "dont affect children")
			)

		)
	)
)

function hvkBoneTools_AlignObjects_Pressed =
(
	undo "Havok Align Objects" on
	(
		selected = hvkTools_reorderParentFirst (selection as Array)
		
		for selObj in selected do
		(
			drivingBone = hvkTools_GetAssociatedBoneOrStartChain selObj

			if (drivingBone != undefined) then
			(
				hvkCommon_AlignObjectTo selObj drivingBone false -- (false means "affect children")
			)

		)
	)
)

--
-- CREATE CAPSULE / BOX BUTTON
--

-- Generic, called by both Capsule and Box
function hvkBoneTools_createBoneProxy proxyCreationFunc =
(
	selected = selection as Array
	newNodes = #()
	
	for selObj in selected do
	(
		drivingBone = hvkTools_getAssociatedBone selObj
		
		-- Replacing proxy
		if (drivingBone!=undefined) then
		(
			-- take the havok modifiers, name and color from the original object
			havokModifiers = hvkCommon_getHavokModifiers selObj
			proxyName = selObj.name
			proxyColor = selObj.wirecolor
			
			-- delete the current proxy
			delete selObj

			-- create new proxy
			newProxy = proxyCreationFunc #(drivingBone) drivingBone
			
			-- reapply modifiers, name and color
			hvkCommon_applyHavokModifiers newProxy havokModifiers
			newProxy.name = proxyName
			newProxy.wirecolor = proxyColor
			
			-- override shapeType though
			hvkPhysics_setBestShapeTypeOnNode newProxy
			
			append newNodes newProxy
			
		)
		else -- new proxy
		(
			newProxy = proxyCreationFunc #(selObj) selObj

			if (undefined != newProxy) then
			(
				hvkTools_MakeRigidBody newProxy

				hvkTools_AssociateBone newProxy selObj

				-- Rename the proxy
				hvkCustomizable_renameNewBoneProxy newProxy selObj
				
				if (hvkGlobal_freezeAssociatedBone) then
				(
					freeze selObj
				)

				append newNodes newProxy
			)
		)
	)

	-- Switch the selection to the new guys
	if newNodes.count>0 then select newNodes
)

-- CREATE CAPSULE BONE PROXY
function hvkBoneTools_createCapsule_Pressed =
(
	undo "Havok Create Capsule Bone Proxy" on
	(
		hvkBoneTools_createBoneProxy hvkBoneTools_createBoundingCapsule
	)
)

-- CREATE CAPSULE BONE PROXY
function hvkBoneTools_createBox_Pressed =
(
	undo "Havok Create Box Bone Proxy" on
	(
		hvkBoneTools_createBoneProxy hvkBoneTools_createBoundingBox
	)
)

--
-- CREATE CAPSULE / BOX  CHAIN BUTTON
--


-- Generic, called by both capsule and box
function hvkBoneTools_createChainProxy proxyCreationFunc = 
(
	newNodes = #()

	selected = selection as Array
	
	if (selected.count<1) then return()
	
	local replaceMode = (undefined != hvkTools_getAssociatedChain selected[1])
	
	if (replaceMode) then
	(
		for proxy in selected do
		(
			startEnd = hvkTools_getAssociatedChain proxy
			
			if (startEnd != undefined) then
			(
				allBones = hvkTools_getBonesInChain startEnd[1] startEnd[2]
				
				if (allBones.count>=2) then
				(
					havokModifiers = hvkCommon_getHavokModifiers proxy
					proxyName = proxy.name
					proxyColor = proxy.wirecolor
					
					-- delete the current proxy
					delete proxy
					
					-- create new one
					newProxy = proxyCreationFunc allBones startEnd[1]
					
					-- reapply modifiers, name and color
					hvkCommon_applyHavokModifiers newProxy havokModifiers
					newProxy.name = proxyName
					newProxy.wirecolor = proxyColor

					-- override shapeType though
					hvkPhysics_setBestShapeTypeOnNode newProxy
					
					append newNodes newProxy
				)
			)
		)
	)
	else -- create new proxy chain
	(
		startEnd = hvkTools_getStartAndEndOfChainFrom selected
		if (startEnd != undefined ) then
		(
			newProxy = proxyCreationFunc selected startEnd[1]
			
			if (undefined != newProxy) then
			(
				hvkTools_MakeRigidBody newProxy updateSelection:false
				
				hvkTools_AssociateChain newProxy startEnd[1] startEnd[2]
				
				-- Rename the proxy
				hvkCustomizable_renameNewChainProxy newProxy startEnd[1] startEnd[2]
				
				if (hvkGlobal_freezeAssociatedBone) then
				(
					freeze selected
				)
				
				append newNodes newProxy
			) 
				
		)
	)
	
	-- Switch the selection to the new guys
	if newNodes.count>0 then select newNodes
)	

-- CREATE CAPSULE CHAIN PROXY
function hvkBoneTools_createCapsuleChain_Pressed = 
(
	undo "Create Capsule Chain Proxy" on
	(
		hvkBoneTools_createChainProxy hvkBoneTools_createBoundingCapsule
	)
)

-- CREATE BOX CHAIN PROXY
function hvkBoneTools_createBoxChain_Pressed =
(
	undo "Create Box Chain Proxy" on
	(
		hvkBoneTools_createChainProxy hvkBoneTools_createBoundingBox
	)
)

--
-- ASSOCIATE WITH CUSTOM PROXY
--

function hvkBoneTools_UseCustomSingle_Pressed =
(
	local selected = $selection as Array
	if (selected.count!=1) then return()

	function isProxyCandidate obj =
	(
		if (undefined != hvkTools_getAssociatedBones obj) then return false

		-- Use same check as "create rigid body"
		return hvkPhysics_canCreateShape obj
		
	)
	
	local proxy = selectByName title:"Select Proxy" filter:isProxyCandidate single:true
	
	if (proxy==undefined) or (proxy==#escape) then return()
	
	-- Single Bone

	-- We use a try/catch block since associating bones with proxies may fail (circular references)
	try
	(		
		undo "Associate Bone with Custom Proxy" on
		(
			hvkTools_MakeRigidBody proxy updateSelection:false

			hvkTools_AssociateBone proxy selected[1]

			hvkCommon_AlignPivotTo proxy selected[1] true -- (true means "dont affect children")

			-- Rename the proxy
			hvkCustomizable_renameNewBoneProxy proxy selected[1]
			
			if (hvkGlobal_freezeAssociatedBone) then
			(
				freeze selected
			)

			select proxy
		)
	)
	catch
	(
		-- max undoes automatically
	)	
)

function hvkBoneTools_UseCustomChain_Pressed =
(
	local selected = $selection as Array
	if (selected.count<2) then return()

	function isProxyCandidate obj =
	(
		if (undefined != hvkTools_getAssociatedBones obj) then return false
		
		return true
	)
	
	local proxy = selectByName title:"Select Proxy" filter:isProxyCandidate single:true
	
	if (proxy==undefined) or (proxy==#escape) then return()
	
	-- Chain
	startEnd = hvkTools_getStartAndEndOfChainFrom selected

	if (startEnd == undefined) then return()
	
	-- We use a try/catch block since associating bones with proxies may fail (circular references)
	try
	(
		undo "Associated Chain with Custom Proxy" on
		(
			hvkTools_MakeRigidBody proxy updateSelection:false
			
			hvkTools_AssociateChain proxy startEnd[1] startEnd[2]

			hvkCommon_AlignPivotTo proxy selected[1] true -- (true means "dont affect children")
			
			-- Rename the proxy
			hvkCustomizable_renameNewChainProxy proxy startEnd[1] startEnd[2]
			
			if (hvkGlobal_freezeAssociatedBone) then
			(
				freeze selected
			)

			select proxy
		)				
	)
	catch
	(
		-- max undoes automatically
	)
)

--
-- REMOVE PROXY->BONE ASSOCIATION
--

function hvkBoneTools_RemoveAssociation_Pressed =
(
	undo "Remove Proxy Association" on
	(
		local selected = $selection as Array
		
		for proxy in selected do
		(			
			local associated = hvkTools_getAssociatedBones proxy

			-- Unfreeze the bone if the association is removed			
			if (hvkGlobal_freezeAssociatedBone) then
			(
				unfreeze associated
			)
			
			hvkTools_removeProxyCAs proxy
		)
				
		hvkBoneTools_updateUI()
	)
)

--
-- Mass, Friction, Restitution changed
--

function hvkBoneTools_Mass_Changed =
(
	undo "Havok Change Bone Mass" on
	(
		local theMass = hvkBoneTools.spnMass.value
		
		selected = selection as Array
		for selObj in selected do
		(
			hvkTools_setRBMass selObj theMass
		)
	)
)

function hvkBoneTools_Restitution_Changed =
(
	undo "Havok Change Bone Restitution" on
	(
		local theRestitution = hvkBoneTools.spnRestitution.value
		
		selected = selection as Array
		for selObj in selected do
		(
			hvkTools_setRBRestitution selObj theRestitution
		)
	)
)

function hvkBoneTools_Friction_Changed =
(
	undo "Havok Change Bone Friction" on
	(
		local theFriction = hvkBoneTools.spnFriction.value
		
		selected = selection as Array
		for selObj in selected do
		(
			hvkTools_setRBFriction selObj theFriction
		)
	)
)

function hvkBoneTools_OpenRBModifier_Pressed =
(
	undo "Havok Open RB Modifier" on
	(
		rbModifier = hvkPhysics_getRigidBodyModifier $selection[1]
		
		if (rbModifier!=undefined) then
		(
			hvkCommon_selectModifier rbModifier
		)
		
	)
)

function hvkBoneTools_AddTerminal_Pressed =
(
	undo "Havok Add Terminal" on
	(
		selected = selection as Array
		
		newTerminals = #()
		for selObj in selected do
		(
			append newTerminals (hvkBoneTools_addTerminal selObj)
		)
		
		if (newTerminals.count > 0) then
		(
			select newTerminals
		)
	)
)

--
-- ROLLOUT OPEN
--

function hvkBoneTools_OpenRollout =
(
	hvkBoneTools_UpdateUI()
	
	callbacks.addScript #selectionSetChanged "hvkBoneTools_SelectionUpdatedCallback()" id:#HAVOK_BONE_TOOLS
	callbacks.addScript #sceneUndo "hvkBoneTools_UndoRedoCallback()" id:#HAVOK_BONE_TOOLS
	callbacks.addScript #sceneRedo "hvkBoneTools_UndoRedoCallback()" id:#HAVOK_BONE_TOOLS
)

function hvkBoneTools_CloseRollout =
(
	callbacks.removeScripts id:#HAVOK_BONE_TOOLS
)


--
-- CALLBACKS
--

function hvkBoneTools_SelectionUpdatedCallback =
(
	hvkBoneTools_UpdateUI()
)

function hvkBoneTools_UndoRedoCallback =
(
	hvkBoneTools_UpdateUI()
)
