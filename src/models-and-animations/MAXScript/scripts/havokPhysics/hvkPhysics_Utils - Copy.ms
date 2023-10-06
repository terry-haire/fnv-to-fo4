

function hvkPhysics_getRigidBodyModifier theNode =
(
	return hvkCommon_getModifierOfType theNode hkRigidBodyModifier
)

function hvkPhysics_getShapeModifier theNode =
(
	return hvkCommon_getModifierOfType theNode hkShapeModifier
)	

function hvkPhysics_getLocalFrameModifier theNode =
(
	return hvkCommon_getModifierOfType theNode hkLocalFrameModifier
)

function hvkPhysics_isRigidBody theNode =
(
	return ((hvkPhysics_getRigidBodyModifier theNode) != undefined)
)

function hvkPhysics_isShape theNode =
(
	return ((hvkPhysics_getShapeModifier theNode) != undefined)
)

function hvkPhysics_isLocalFrame theNode =
(
	return ((hvkPhysics_getLocalFrameModifier theNode) != undefined)
)

-- UTILITY METHODS



function hvkPhysics_getBestShapeTypeForNode theNode =
(
	-- 0 = Box, 1 = Sphere, 2 = Capsule, 3 = Cylinder, 4 = Hull, 5 = Mesh

	shapeType = 4 -- Convex hull by default

	if (hvkCommon_haveSameClass theNode Sphere) or (hvkCommon_haveSameClass theNode GeoSphere) then
	(
		shapeType = 1
	)
	else
	(
		if (hvkCommon_haveSameClass theNode Box) then
		(
			shapeType = 0
		)
		else
		(
			if (hvkCommon_haveSameClass theNode Capsule) then
			(
				shapeType = 2
			)
			else
			(
				if (hvkCommon_haveSameClass theNode Cylinder) then
				(
					shapeType = 3
				)
				else
				(
					if (hvkCommon_haveSameClass theNode TaperCapsule) then
					(
						shapeType = 2
					)
				)
			)
		)
	)

	return shapeType

)

function hvkPhysics_setBestShapeTypeOnNode theNode =
(
	shapeModifier = hvkCommon_getModifierOfType theNode hkShapeModifier
	
	if (shapeModifier!=undefined) then
	(
		shapeModifier.shapeType = hvkPhysics_getBestShapeTypeForNode theNode
	)
)


-- ABILITY (CAN) METHODS

function hvkPhysics_canCreateConstraintFromSelection =
(
	local numNodes = $selection.count
	if (numNodes<1 or numNodes>2) then return false
	
	if not hvkPhysics_isRigidBody $selection[1] then return false
	
	if ( (numNodes==2) and (not hvkPhysics_isRigidBody $selection[2])) then return false
	
	return true
)

function hvkPhysics_canCreateShape theNode =
(
	-- Only can create shapes from geometry
	if not (isKindOf theNode GeometryClass) then return false
	
	-- We cannot use biped bones
	if (classOf (theNode.controller) == BipSlave_Control) then return false
	
	return true
)

-- HAVOK MODIFIER TYPES

function hvkPhysics_getHavokConstraintModifierTypes = 
(
	return #(hkBallAndSocketConstraintModifier, hkHingeConstraintModifier, hkPrismaticConstraintModifier, hkRagdollConstraintModifier, hkStiffSpringConstraintModifier, hkWheelConstraintModifier, hkFixedConstraintModifier)
)

function hvkPhysics_getHavokPhysicsModifierTypes =
(
	local constraintTypes = hvkPhysics_getHavokConstraintModifierTypes ()
	local otherTypes = #(hkShapeModifier, hkRigidBodyModifier, hkLocalFrameModifier)
	
	return constraintTypes + otherTypes
)


-- CREATION METHODS

mapped function hvkPhysics_createShape theNode =
(
	if (hvkPhysics_isShape theNode) then return undefined
	
	shapeModifier = hkShapeModifier()
	
	addModifier theNode shapeModifier
	
	local bestType = hvkPhysics_getBestShapeTypeForNode theNode
	
	shapeModifier.shapeType = bestType
	
	return shapeModifier
)	

mapped function hvkPhysics_createRigidBody theNode =
(
	if (hvkPhysics_isRigidBody theNode) then return undefined

	rbModifier = hkRigidBodyModifier()
	
	addModifier theNode rbModifier
	
	return rbModifier

)

mapped function hvkPhysics_createSingleRigidBody theNode updateSelection:true =
(	
	hvkPhysics_createShape theNode
	
	rbModifier = hvkPhysics_createRigidBody theNode
	
	if (rbModifier!=undefined) and updateSelection then
	(
		hvkCommon_selectModifier rbModifier
	)	
	
	return rbModifier
)

function hvkPhysics_createCompoundRigidBody nodeList updateSelection:true =
(
	-- HVK-4803: "Create Compound Rigid Body" and "Create Rigid Body With Proxy(s)" can crash MAXScript because of cyclic links
	-- collect all nodes in hierarchy first
	nodesInHierarchy = #()
	rbody = nodeList[nodeList.count]
	while ( rbody != undefined ) do
	(
		append nodesInHierarchy rbody
		rbody = rbody.parent
	)
	-- traverse hierarchy from top to bottom, abort once we find the first (== topmost) node
	-- that is part of the supplied nodelist
	for i = nodesInHierarchy.count to 1 by -1 do
	(
		rbody = nodesInHierarchy[i]
		if ( (findItem (nodeList as array) rbody) > 0 ) then
		(
			exit
		)
	)

	-- ensure things are rightly parented
	local okToForceParenting = undefined
	for i in nodeList do
	(
		if (i == rbody) then continue
		
		lastParent = i
		while ((findItem (nodeList as array) lastParent.parent) > 0) do
		(
			lastParent = lastParent.parent
		)
		
		if (lastParent != rbody) then
		(			
			if (okToForceParenting == undefined) then
			(
				okToForceParenting = queryBox ("This will parent all shapes to "+rbody.name+". Continue ?") title:"Compound Rigid Body Creation"				
			)

			if (okToForceParenting) then
			(
				lastParent.parent = rbody
			)
			else
			(
				return()
			)
		)
	)

	-- Create shapes for all
	hvkPhysics_createShape nodeList

	-- Create rigid body for parent
	rbModifier = hvkPhysics_createRigidBody rbody	

	if (rbModifier!=undefined) and updateSelection then
	(
		hvkCommon_selectModifier rbModifier
	)	
	
	return rbModifier
)


function hvkPhysics_createRigidBodyWithProxy nodeList updateSelection:true =
(
	-- HVK-4803: "Create Compound Rigid Body" and "Create Rigid Body With Proxy(s)" can crash MAXScript because of cyclic links
	-- collect all nodes in hierarchy first
	nodesInHierarchy = #()
	rbody = nodeList[nodeList.count]
	while ( rbody != undefined ) do
	(
		append nodesInHierarchy rbody
		rbody = rbody.parent
	)
	-- traverse hierarchy from top to bottom, abort once we find the first (== topmost) node
	-- that is part of the supplied nodelist
	for i = nodesInHierarchy.count to 1 by -1 do
	(
		rbody = nodesInHierarchy[i]
		if ( (findItem (nodeList as array) rbody) > 0 ) then
		(
			exit
		)
	)

	-- ensure things are rightly parented
	local okToForceParenting = undefined
	for i in nodeList do
	(
		if (i == rbody) then continue
		
		lastParent = i
		while ((findItem (nodeList as array) lastParent.parent) > 0) do
		(
			lastParent = lastParent.parent
		)
		
		if (lastParent != rbody) then
		(			
			if (okToForceParenting == undefined) then
			(
				okToForceParenting = true --queryBox ("This will parent all shapes to "+rbody.name+". Continue ?") title:"Rigid Body & Proxy Creation"				
			)

			if (okToForceParenting) then
			(
				lastParent.parent = rbody
			)
			else
			(
				return()
			)
		)
	)
	
	-- and create shapes for them
	for i in nodeList do
	(
		if (i == rbody) then continue
		
		hvkPhysics_createShape i
	)

	-- Create the rigid body modifier
	rbModifier = hvkPhysics_createRigidBody rbody


	if (rbModifier!=undefined) and updateSelection then
	(
		hvkCommon_selectModifier rbModifier
	)	
	
	return rbModifier

)

-- adds a constraint modifier on the selection
function hvkPhysics_createConstraintFromSelection modifierType updateSelection:true springStyle:false=
(
		
	childRB = $selection[1]
	parentRB = undefined

	if (selection.count == 2) then
	(
		parentRB = $selection[2]
		if (hvkCommon_isDescendantOf parentRB childRB) then
		(
			k = parentRB
			parentRB = childRB
			childRB = k
		)
	)
	else
	(
		parentRB = childRB.parent
		
		if (parentRB != undefined) and (not hvkPhysics_isRigidBody parentRB) then
		(
			parentRB = undefined
		)
	)	

	if (not hvkPhysics_isRigidBody childRB) then
	(
		messageBox (childRB.name+" is not a rigid body.") title:"Create Constraint"
		return undefined
	)

	local theModifier = modifierType()

	if (parentRB != undefined) then
	(
		if (not hvkPhysics_isRigidBody parentRB) then
		(
			messageBox (parentRB.name+" is not a rigid body.") title:"Create Constraint"
			return undefined
		)
		theModifier.constrainTo = 1
		theModifier.parent = parentRB
	)
	else
	(
		theModifier.constrainTo = 0
	)

	-- Reset parent space (for stiff springs)
	theModifier.resetParentSpaceTranslation()
	theModifier.resetParentSpaceRotation()
	
	addModifier childRB theModifier
	
	-- Update the selection if we have been asked to do so
	if (updateSelection) then
	(
		hvkCommon_selectModifier theModifier
	)		

	return theModifier
)

mapped function hvkPhysics_createLocalFrame theNode updateSelection:true =
(		
	if (hvkPhysics_isLocalFrame theNode) then return undefined

	localFrameModifier = hkLocalFrameModifier()
	
	addModifier theNode localFrameModifier
	
	if (localFrameModifier!=undefined) and updateSelection then
	(
		hvkCommon_selectModifier localFrameModifier
	)	
	
	return localFrameModifier
)

