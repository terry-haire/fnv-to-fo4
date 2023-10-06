
fileIn "havokCloth/boneCollidableTools/hvkBoneCollidableTools_Customizable.ms"

--
-- UPDATE UI
--


function hvkBoneCollidableBoneTools_UpdateUI =
(
	local selected =  $selection as Array
	
	local oneOrMoreSelected = selected.count>0
	
	local allCollidables = oneOrMoreSelected
	local allProxies = oneOrMoreSelected
	local allBoneProxies = oneOrMoreSelected
	local allChainProxies = oneOrMoreSelected
	local allCanBeBoneProxies = oneOrMoreSelected

	for selObj in selected while (allCollidables or allCanBeBoneProxies or allProxies) do
	(
		local isCollidable = hvkCloth_isClothCollidable selObj
		local isBoneProxy = isCollidable and (hvkBoneCollidableTools_isBoneProxy selObj)
		local isChainProxy = isCollidable and (hvkBoneCollidableTools_isChainProxy selObj)
		
		allCollidables = allCollidables and isCollidable
		
		allBoneProxies = allBoneProxies and isBoneProxy
		
		allChainProxies = allChainProxies and isChainProxy
				
		allProxies = allProxies and (isBoneProxy or isChainProxy)

		allCanBeBoneProxies = allCanBeBoneProxies and (hvkBoneCollidableTools_canCreateBoneProxyFrom selObj)
	)	
	
	local oneProxyOnly = allProxies and (selected.count == 1)

	local oneBoneOnly = allCanBeBoneProxies and (selected.count == 1)

	local canCreateChain = hvkBoneCollidableTools_canCreateChainProxyFrom selected
	
	-- Enable / Disable properties for creating single proxies
	hvkBoneCollidableBoneTools.btnCapsule.enabled = allCanBeBoneProxies or allBoneProxies
	
	-- Enable / disable properties for creating multiple proxies
	hvkBoneCollidableBoneTools.btnCapsuleChain.enabled = canCreateChain or allChainProxies
	
	-- Disable the group box if all buttons are disabled
	hvkBoneCollidableBoneTools.grpCreateBone.enabled = hvkBoneCollidableBoneTools.btnCapsule.enabled or hvkBoneCollidableBoneTools.btnCapsuleChain.enabled
	
	-- Change the label depending on whether we create or replace
	if (allProxies) then
	(
		hvkBoneCollidableBoneTools.grpCreateBone.caption = "Replace Proxy Collidable"
	)
	else
	(
		hvkBoneCollidableBoneTools.grpCreateBone.caption = "Create Proxy Collidable"
	)

	-- Add/Remove association
	hvkBoneCollidableBoneTools.btnUseCustomSingle.enabled = oneBoneOnly
	hvkBoneCollidableBoneTools.btnUseCustomChain.enabled = canCreateChain
	hvkBoneCollidableBoneTools.btnRemoveAssociation.enabled = oneProxyOnly

	hvkBoneCollidableBoneTools.btnAlignPivots.enabled = allProxies
	hvkBoneCollidableBoneTools.btnAlignObjects.enabled = allProxies
	hvkBoneCollidableBoneTools.btnSelectDrivingBone.enabled = allProxies
	hvkBoneCollidableBoneTools.grpAssociatedBones.enabled = allProxies
	hvkBoneCollidableBoneTools.lblAssociatedBonesValue.enabled = allProxies

	if (oneProxyOnly) then
	(
	
		if (allBoneProxies) then -- single bone
		(			
			hvkBoneCollidableBoneTools.grpAssociatedBones.caption = "Associated Bone:"
			local associated = hvkBoneCollidableTools_getAssociatedBone selected[1]
			if (undefined == associated) then
			(
				hvkBoneCollidableBoneTools.lblAssociatedBonesValue.caption = "<none>"
			)
			else
			(
				hvkBoneCollidableBoneTools.lblAssociatedBonesValue.caption = associated.name
			)
		)
		else -- chain
		(
			hvkBoneCollidableBoneTools.grpAssociatedBones.caption = "Associated Chain:"
			local chain = hvkBoneCollidableTools_getAssociatedChain selected[1]
			if (undefined == chain) then
			(
				hvkBoneCollidableBoneTools.lblAssociatedBonesValue.caption = "<none>"
			)
			else
			(
				-- the button shows the text "start - end"
				labText = chain[1].name + " - " + chain[2].name
				hvkBoneCollidableBoneTools.lblAssociatedBonesValue.caption = labText
			)
		)			
	)
	else
	(
		if (allProxies) then 
		(
			hvkBoneCollidableBoneTools.grpAssociatedBones.caption = "Associated Bone(s):"
			hvkBoneCollidableBoneTools.lblAssociatedBonesValue.caption = "<multiple selected>"
		)
		else
		(
			hvkBoneCollidableBoneTools.grpAssociatedBones.caption = "Associated Bone(s):"
			hvkBoneCollidableBoneTools.lblAssociatedBonesValue.caption = "<none>"
		)
	)
)

-- 
-- EVENTS
--

function hvkBoneCollidableBoneTools_SelectDrivingBone_Pressed =
(
	undo "Select Driving Bone(s)" on
	(
		local newSelection = #()
		
		selected = selection as Array
		for selObj in selected do
		(
			drivingBone = hvkBoneCollidableTools_GetAssociatedBone selObj

			if (drivingBone != undefined) then
			(
				append newSelection drivingBone
			)
			else
			(
				-- try if it's a chain
				startEnd = hvkBoneCollidableTools_getAssociatedChain selObj
				
				if (startEnd != undefined) then
				(
					chainBones = hvkBoneCollidableTools_getBonesInChain startEnd[1] startEnd[2]

					join newSelection chainBones
				)
			)
		)
		
		select newSelection
		
	)
)

function hvkBoneCollidableBoneTools_AlignPivots_Pressed =
(
	undo "Havok Align Pivots" on
	(
		selected = hvkBoneCollidableTools_reorderParentFirst (selection as Array)

		for selObj in selected do
		(
			drivingBone = hvkBoneCollidableTools_getAssociatedBoneOrStartChain selObj

			if (drivingBone != undefined) then
			(
				hvkCommon_AlignPivotTo selObj drivingBone true -- (true means "dont affect children")
			)

		)
	)
)

function hvkBoneCollidableBoneTools_AlignObjects_Pressed =
(
	undo "Havok Align Objects" on
	(
		selected = hvkBoneCollidableTools_reorderParentFirst (selection as Array)
		
		for selObj in selected do
		(
			drivingBone = hvkBoneCollidableTools_GetAssociatedBoneOrStartChain selObj

			if (drivingBone != undefined) then
			(
				hvkCommon_AlignObjectTo selObj drivingBone false -- (false means "affect children")
			)

		)
	)
)

-- 
-- Add all the collidables in the scene, selected, only added if their name begins with 'Collidable', they have a cloth modifier, and they have a bone association
function hvkBoneCollidableBoneTools_GetCollidablesInScene  =
(
	-- Select all the collidable objects
	collidableObjects = $Collidable* as array
	
	validCollidableObjects = #()
	
	for collidableProxy in collidableObjects do
	(
		hasClothCollidable = hvkCloth_isClothCollidable collidableProxy
		
		if (hasClothCollidable) then
		(	
			collidableBone = hvkBoneCollidableTools_getAssociatedBone collidableProxy
			
			if (collidableBone != undefined) then
			(
				append validCollidableObjects collidableProxy		
			)
			else
			(
				chainStartEndCollidableBones = hvkBoneCollidableTools_getAssociatedChain collidableProxy
				
				if (chainStartEndCollidableBones != undefined) then
				(
					append validCollidableObjects collidableProxy
				)
			)
		)
	)
	
	return validCollidableObjects
)

--
-- Auto parent collidable objects function
--
function hvkBoneCollidableBoneTools_autoParentCollidable newProxy =
(
	if(newProxy != undefined)then
	(
		drivingBone = undefined
		
		-- need to check if the newProxy was created for a chain of bones
		chainStartEndDrivingBones = hvkBoneCollidableTools_getAssociatedChain newProxy 
		
		if ( undefined == chainStartEndDrivingBones ) then
		(
			drivingBone = hvkBoneCollidableTools_getAssociatedBone newProxy
		)
		else
		(
			drivingBone = chainStartEndDrivingBones[1]
		)
		
		
		if (drivingBone != undefined) then
		(
			-- Select all the collidable objects
			collidableObjects = hvkBoneCollidableBoneTools_GetCollidablesInScene ()
			
			-- one to one mapping collidableObjects to associatedBones 
			associatedBones = #()
			(
				-- go through all the collidables and store its corresponding bone
				for collidableProxy in collidableObjects do
				(
					collidableBone = hvkBoneCollidableTools_getAssociatedBone collidableProxy
						
					if (collidableBone == undefined) then 
					(
						chainStartEndCollidableBones = hvkBoneCollidableTools_getAssociatedChain collidableProxy
						-- Should only really care about the end bone of the chain as that will be the closet ancestor
						-- but using the first bone in the chain makes it easier for the finding children collidables
						append associatedBones chainStartEndCollidableBones[1]
						
					)
					else
					(
						append associatedBones collidableBone				
					)
				)
			)
			
			-- find the closest ancestor collidable
			(
				ancestorCollidableFound = false
				
				parentBone = drivingBone.parent
				while ( ( parentBone != undefined) AND (ancestorCollidableFound == false) ) do
				(
					idx = findItem associatedBones parentBone 
					
					if( idx > 0) then
					(
						associatedCollidable = collidableObjects[idx]
						newProxy.parent = associatedCollidable
						ancestorCollidableFound = true
					)
					parentBone = parentBone.parent
				)
			)
			
			-- find the closest children collidables
			(
				childBonesToParent = #()
			
				-- first add the driving bone's children or the chain bone's children
				if (undefined != chainStartEndDrivingBones) then
				(
					chainBones = hvkBoneCollidableTools_getBonesInChain chainStartEndDrivingBones[1] chainStartEndDrivingBones[2]
					
					-- for the all of the bones in the chain
					for i in 1 to chainBones.count do
					(
						-- add their children
						for j in 1 to chainBones[i].children.count do
						(
							-- make sure we are not adding any bones already on the list
							boneIdx = findItem childBonesToParent chainBones[i].children[j]
							
							if (boneIdx == 0) then
							(
								append childBonesToParent chainBones[i].children[j]
							)
						)
					)
				)
				else
				(
					for i in 1 to drivingBone.children.count do
					(
						append childBonesToParent drivingBone.children[i]
					)
				)
				
				
				-- keep on checknig the children in the array until there is no more to check
				while (childBonesToParent.count > 0) do
				(
					-- make a copy of the current set of bone as will be removing elements from the original and adding new elements
					currentChildrenBones = #()
					currentChildrenBones = deepcopy childBonesToParent
					
					-- used to keep track of any bones removed which is needed as this will result in the changing of array indices
					numChildrenRemoved = 0
					
					-- look at the current set of bones in the array
					for i in 1 to currentChildrenBones.count do
					(
						childBone = currentChildrenBones[i]
						
						-- remove the item from the original array
						deleteItem childBonesToParent (i - numChildrenRemoved) 
						numChildrenRemoved = numChildrenRemoved + 1
						
						-- check if the bone we have removed has a collidable
						idx = findItem associatedBones childBone
						
						if (idx > 0) then
						(
							-- if it does, make the newProxy it's parent
							associatedCollidable = collidableObjects[idx]
							associatedCollidable.parent = newProxy
						)
						else
						(
							-- childBone doesn't have a collidable but his children could have collidables, so append them to the original array
							for j in 1 to childBone.children.count do 
							(
								-- make sure we are not adding any bones already on the list, could happen as a result of chain capsules
								boneIdx = findItem childBonesToParent childBone.children[j]
							
								if (boneIdx == 0) then
								(
									append childBonesToParent childBone.children[j]
								)
							)
						)	
					)
				) -- end of while loop, no more children to check
			) -- finished finding the closest children collidables
		) -- driving bone is not undefined
	) -- newProxy is not undefined
)

--
-- CREATE CAPSULE BUTTON
--

-- Generic, called by both Capsule
function hvkBoneCollidableBoneTools_createBoneProxy proxyCreationFunc =
(
	selected = selection as Array
	newNodes = #()
	
	for selObj in selected do
	(
		drivingBone = hvkBoneCollidableTools_getAssociatedBone selObj
		
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
				hvkBoneCollidableTools_makeCollidable newProxy
					
				hvkBoneCollidableTools_AssociateBone newProxy selObj

				-- Rename the proxy
				hvkBoneCollidableCustomizable_renameNewBoneProxy newProxy selObj
				
				if (hvkGlobal_freezeCollidableAssociatedBone) then
				(
					freeze selObj
				)

				append newNodes newProxy
			)
		)
	)

	-- auto parent any new collidables created 
	if(hvkGlobal_autoParentCollidableOnCreation)then
	(
		for i in 1 to newNodes.count do
		(
			hvkBoneCollidableBoneTools_autoParentCollidable newNodes[i]
		)
	)
	
	-- Switch the selection to the new guys
	if newNodes.count>0 then select newNodes
)



-- CREATE CAPSULE BONE PROXY
function hvkBoneCollidableBoneTools_createCapsule_Pressed =
(
	undo "Havok Create Capsule Bone Proxy" on
	(
		hvkBoneCollidableBoneTools_createBoneProxy hvkBoneCollidableBoneTools_createBoundingCapsule
	)
)

--
-- CREATE CAPSULE CHAIN BUTTON
--


-- Generic, called by both capsule
function hvkBoneCollidableBoneTools_createChainProxy proxyCreationFunc = 
(
	newNodes = #()

	selected = selection as Array
	
	if (selected.count<1) then return()
	
	local replaceMode = (undefined != hvkBoneCollidableTools_getAssociatedChain selected[1])
	
	if (replaceMode) then
	(
		for proxy in selected do
		(
			startEnd = hvkBoneCollidableTools_getAssociatedChain proxy
			
			if (startEnd != undefined) then
			(
				allBones = hvkBoneCollidableTools_getBonesInChain startEnd[1] startEnd[2]
				
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

					append newNodes newProxy
				)
			)
		)
	)
	else -- create new proxy chain
	(
		startEnd = hvkBoneCollidableTools_getStartAndEndOfChainFrom selected
		if (startEnd != undefined ) then
		(
			newProxy = proxyCreationFunc selected startEnd[1]
			
			if (undefined != newProxy) then
			(
				hvkBoneCollidableTools_makeCollidable newProxy updateSelection:false
				
				hvkBoneCollidableTools_AssociateChain newProxy startEnd[1] startEnd[2]
				
				-- Rename the proxy
				hvkBoneCollidableCustomizable_renameNewChainProxy newProxy startEnd[1] startEnd[2]
				
				if (hvkGlobal_freezeCollidableAssociatedBone) then
				(
					freeze selected
				)
				
				append newNodes newProxy
			) 
				
		)
	)
	
	-- auto parent any new collidables created 
	if(hvkGlobal_autoParentCollidableOnCreation)then
	(
		for i in 1 to newNodes.count do
		(
			hvkBoneCollidableBoneTools_autoParentCollidable newNodes[i]
		)
	)
	
	-- Switch the selection to the new guys
	if newNodes.count>0 then select newNodes
)	

-- CREATE CAPSULE CHAIN PROXY
function hvkBoneCollidableBoneTools_createCapsuleChain_Pressed = 
(
	undo "Create Capsule Chain Proxy" on
	(
		hvkBoneCollidableBoneTools_createChainProxy hvkBoneCollidableBoneTools_createBoundingCapsule
	)
)

--
-- ASSOCIATE WITH CUSTOM PROXY
--

function hvkBoneCollidableBoneTools_UseCustomSingle_Pressed =
(
	local selected = $selection as Array
	if (selected.count!=1) then return()

	function isProxyCandidate obj =
	(
		if (undefined != hvkBoneCollidableTools_getAssociatedBones obj) then return false

		return hvkCloth_canCreateClothCollidable obj
		
	)
	
	local proxy = selectByName title:"Select Proxy" filter:isProxyCandidate single:true
	
	if (proxy==undefined) or (proxy==#escape) then return()
	
	-- Single Bone

	-- We use a try/catch block since associating bones with proxies may fail (circular references)
	try
	(		
		undo "Associate Bone with Custom Proxy" on
		(
			hvkBoneCollidableTools_makeCollidable proxy updateSelection:false
			
			hvkBoneCollidableTools_AssociateBone proxy selected[1]

			hvkCommon_AlignPivotTo proxy selected[1] true -- (true means "dont affect children")

			-- Rename the proxy
			hvkBoneCollidableCustomizable_renameNewBoneProxy proxy selected[1]
		
			-- auto parent new collidable created 
			if(hvkGlobal_autoParentCollidableOnCreation)then
			(
				hvkBoneCollidableBoneTools_autoParentCollidable proxy
			)
				
			select proxy
			
			if (hvkGlobal_freezeCollidableAssociatedBone) then
			(
				freeze selected
			)
		)
	)
	catch
	(
		-- max undoes automatically
	)	
)

function hvkBoneCollidableBoneTools_UseCustomChain_Pressed =
(
	local selected = $selection as Array
	if (selected.count<2) then return()

	function isProxyCandidate obj =
	(
		if (undefined != hvkBoneCollidableTools_getAssociatedBones obj) then return false
		
		return true
	)
	
	local proxy = selectByName title:"Select Proxy" filter:isProxyCandidate single:true
	
	if (proxy==undefined) or (proxy==#escape) then return()
	
	-- Chain
	startEnd = hvkBoneCollidableTools_getStartAndEndOfChainFrom selected

	if (startEnd == undefined) then return()
	
	-- We use a try/catch block since associating bones with proxies may fail (circular references)
	try
	(
		undo "Associated Chain with Custom Proxy" on
		(
			hvkBoneCollidableTools_makeCollidable proxy updateSelection:false
			
			hvkBoneCollidableTools_AssociateChain proxy startEnd[1] startEnd[2]

			hvkCommon_AlignPivotTo proxy selected[1] true -- (true means "dont affect children")
			
			-- Rename the proxy
			hvkBoneCollidableCustomizable_renameNewChainProxy proxy startEnd[1] startEnd[2]
			
			-- auto parent new collidable created 
			if(hvkGlobal_autoParentCollidableOnCreation)then
			(
				hvkBoneCollidableBoneTools_autoParentCollidable proxy
			)
			
			select proxy
			
			if (hvkGlobal_freezeCollidableAssociatedBone) then
			(
				freeze selected
			)
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

function hvkBoneCollidableBoneTools_RemoveAssociation_Pressed =
(
	undo "Remove Proxy Association" on
	(
		local selected = $selection as Array
		
		for proxy in selected do
		(			
			local associated = hvkBoneCollidableTools_getAssociatedBones proxy

			-- Unfreeze the bone if the association is removed			
			if (hvkGlobal_freezeCollidableAssociatedBone) then
			(
				unfreeze associated
			)
			
			hvkBoneCollidableTools_removeProxyCAs proxy
		)
				
		hvkBoneCollidableBoneTools_updateUI()
	)
)

--
-- ROLLOUT OPEN
--

function hvkBoneCollidableBoneTools_OpenRollout =
(
	hvkBoneCollidableBoneTools_UpdateUI()
	
	callbacks.addScript #selectionSetChanged "hvkBoneCollidableBoneTools_SelectionUpdatedCallback()" id:#HAVOK_BONE_TOOLS
	callbacks.addScript #sceneUndo "hvkBoneCollidableBoneTools_UndoRedoCallback()" id:#HAVOK_BONE_TOOLS
	callbacks.addScript #sceneRedo "hvkBoneCollidableBoneTools_UndoRedoCallback()" id:#HAVOK_BONE_TOOLS
)

function hvkBoneCollidableBoneTools_CloseRollout =
(
	callbacks.removeScripts id:#HAVOK_BONE_TOOLS
)


--
-- CALLBACKS
--

function hvkBoneCollidableBoneTools_SelectionUpdatedCallback =
(
	hvkBoneCollidableBoneTools_UpdateUI()
)

function hvkBoneCollidableBoneTools_UndoRedoCallback =
(
	hvkBoneCollidableBoneTools_UpdateUI()
)
