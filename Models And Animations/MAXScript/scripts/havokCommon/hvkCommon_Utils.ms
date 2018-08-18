
-- MAKES SURE A MODIFIER IS SELECTED AND SHOWN IN THE MODIFY PANEL

function hvkCommon_selectModifier theModifier =
(
	setCommandPanelTaskMode mode:#modify
	modPanel.setCurrentObject theModifier			
)

-- Returns true if nodeA is a descendant of nodeB in the node hierarchy
function hvkCommon_isDescendantOf nodeA nodeB =
(
	local nodeAParent = nodeA.parent
	
	while (nodeAParent != undefined) do
	(
		if (nodeB == nodeAParent) then return true
		
		nodeAParent = nodeAParent.parent
	)
	
	return false
)


-- INSPECTION (GET) METHODS    

function hvkCommon_getModifierOfType theNode theType =
(
	for modif in theNode.modifiers do
	(
		if (classOf modif == theType) then
		(
			return modif
		)
	)
	
	return undefined
)

function hvkCommon_haveSameClass o className =
(
	return (o.classID[1] == className.classID[1]) and (o.classID[2] == className.classID[2])
)

global hvkCommonListOfHavokModifierTypes = #()

function registerHavokModifiers mods =
(
	hvkCommonListOfHavokModifierTypes = hvkCommonListOfHavokModifierTypes + mods
)

function hvkCommon_getHavokModifierTypes = 
(
	return hvkCommonListOfHavokModifierTypes
)

function hvkCommon_getHavokModifiers theNode =
(
	local havokModifierTypes = hvkCommon_getHavokModifierTypes()
	
	havokModifiers = #()
	
	for i=theNode.modifiers.count to 1 by -1 do
	(
		local theModifier = theNode.modifiers[i]
		if (findItem havokModifierTypes (classOf theModifier)) != 0 then
		(
			append havokModifiers theModifier
		)
	)

	return havokModifiers
)

function hvkCommon_applyHavokModifiers theNode havokModifiers =
(
	for mod in havokModifiers do
	(
		addModifier theNode mod
	)
)


-- REMOVAL METHODS

function hvkCommon_removeModifiersOfType theNode theType =
(
	for i=theNode.modifiers.count to 1 by -1 do
	(
		local theModifier = theNode.modifiers[i]
		if (classOf theModifier) == theType then
		(
			deleteModifier theNode i
		)
	)
)

function hvkCommon_removeModifiersOfTypes theNode theTypes =
(
	
	for i=theNode.modifiers.count to 1 by -1 do
	(
		local theModifier = theNode.modifiers[i]
		if (findItem theTypes (classOf theModifier)) != 0 then
		(
			deleteModifier theNode i
		)
	)
)

mapped function hvkCommon_removeHavokModifiers theNode =
(
	local havokModifierTypes = hvkCommon_getHavokModifierTypes()
	
	hvkCommon_removeModifiersOfTypes theNode havokModifierTypes
)

mapped function hvkCommon_removeHavokData theNode =
(
	-- Remove havok modifiers
	hvkCommon_removeHavokModifiers theNode
)



--
-- REMOVE SCALE : Given a transform, it removes the scale and skew components
--
function hvkCommon_removeScale transformIn =
(
	res = transformIn.rotationpart as Matrix3
	res.translation = transformIn.translation
	
	return res
)

--
-- ALIGN PIVOT TO : Aligns the pivot point of a proxyNode to drivingBone
--
function hvkCommon_AlignPivotTo proxyNode drivingBone dontAffectChildren=
(
	-- We want the node transforms of ragdollBone to match the one from drivingBone
	-- but keeping its object transform
	
	-- Store children transform so we can restore them
	if (dontAffectChildren) then
	(
		local previousTransforms = #()
		for child in proxyNode.children do
		(
			append previousTransforms child.transform
		)
	)
	
	-- Store the current object transform
	local rbObjTM = proxyNode.objectTransform

	-- Match the pivots
	proxyNode.transform = hvkCommon_removeScale drivingBone.transform

	-- We can't set object transform, but we can set offset transform, and we know that ObjectTM = OffsetTM * NodeTM 
	-- so OffsetTM = ObjectTM * inv(NodeTM)
	local invNodeTM = Inverse proxyNode.transform
	local offsetTM = rbObjTM * invNodeTM
	
	-- The object transform is set component by component
	proxyNode.objectOffsetRot = offsetTM.rotation
	proxyNode.objectOffsetPos = offsetTM.position
	proxyNode.objectOffsetScale = offsetTM.scale

	-- Restore children transforms	
	if (dontAffectChildren) then
	(
		local i = 1
		for child in proxyNode.children do
		(
			child.transform = previousTransforms[i]
			i += 1
		)
	)
)

--
-- ALIGN OBJECT TO : Aligns the proxyNode to drivingBone
--
function hvkCommon_AlignObjectTo proxyNode drivingBone dontAffectChildren=
(
	-- We want the node transforms of ragdollBone to match the one from drivingBone
	-- but keeping its object transform
	
	-- Store children transform so we can restore them
	if (dontAffectChildren) then
	(
		local previousTransforms = #()
		for child in proxyNode.children do
		(
			append previousTransforms child.transform
		)
	)
	
	proxyNode.transform = hvkCommon_removeScale drivingBone.transform
	
	-- Restore children transforms	
	if (dontAffectChildren) then
	(
		local i = 1
		for child in proxyNode.children do
		(
			child.transform = previousTransforms[i]
			i += 1
		)
	)
)
