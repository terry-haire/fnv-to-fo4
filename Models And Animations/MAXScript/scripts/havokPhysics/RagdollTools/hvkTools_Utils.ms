
-- Utilities used by all tools

fileIn "havokPhysics/ragdollTools/hvkTools_CAttribs.ms"
fileIn "havokPhysics/ragdollTools/hvkTools_Customizable.ms"
fileIn "havokPhysics/ragdollTools/hvkTools_Globals.ms"
fileIn "havokPhysics/ragdollTools/hvkTools_CAttribs.ms"

--
-- REORDER PARENT FIRST : Reorders a list of nodes so parents go first
--

function hvkTools_depthOf aNode =
(
	if (aNode.parent == undefined) then return 0
	
	return ( (hvkTools_depthOf aNode.parent) +1 )
)

function hvkTools_reorderParentFirst originalList= 
(
	local nodeList = originalList + #()
	
	function sortFunc nodeA nodeB =
	(		
		return ( (hvkTools_depthOf nodeA) - (hvkTools_depthOf nodeB) )
	)
	
	qsort nodeList sortFunc
	
	return nodeList
)

--
-- GET ASSOCIATED BONE : Returns the driving bone associated with this proxy
--
function hvkTools_getAssociatedBone proxyNode =
(
	boneProxyCA = hvkTools_getBoneProxyCA proxyNode
	
	if (boneProxyCA == undefined) then return undefined
	
	return boneProxyCA.associatedBone
)

--
-- ASSOCIATE BONE : Associated a bone to a proxy
--
function hvkTools_associateBone proxyNode boneNode =
(
	boneProxyCA = hvkTools_getOrCreateBoneProxyCA proxyNode
	
	if (boneProxyCA == undefined) then return false
	
	try 
	(
		boneProxyCA.associatedBone = boneNode
	)
	catch
	(
		messageBox ("Cannot associate "+proxyNode.name+" and "+boneNode.name)
		throw()
		return false
	)
	
	return true
)

--
-- IS BONE PROXY : Returns true if the object was created as a proxy
--
function hvkTools_isBoneProxy node =
(
	return (hvkTools_GetAssociatedBone node != undefined)
)

--
-- GET ASSOCIATED CHAIN : Returns the start and end bones associated with this proxy
--
function hvkTools_getAssociatedChain proxyNode =
(
	chainCA = hvkTools_getChainProxyCA proxyNode
	
	if (chainCA == undefined) then return undefined
	
	start = chainCA.startChain
	end = chainCA.endChain
	
	if (start==undefined) or (end==undefined) then return undefined
	
	return #(start, end)
)

--
-- GET BONES IN CHAIN : Given an start and an end, it returns the bones in that chain
--
function hvkTools_getBonesInChain chainStart chainEnd =
(
	bones = #(chainEnd)
	
	p = chainEnd.parent
	
	while (p!=undefined) and (p!=chainStart) do
	(
		insertItem p bones 1
		p = p.parent
	)
	
	if (p==undefined) then
	(
		-- invalid chain
		return #()
	)
	else
	(
		insertItem chainStart bones 1
		return bones
	)
)

--
-- ASSOCIATE CHAIN : Associates a chain with a proxy
--
function hvkTools_associateChain proxyNode chainStart chainEnd =
(
	chainCA = hvkTools_getOrCreateChainProxyCA proxyNode
	
	if (chainCA == undefined) then return false

	try 
	(	
		chainCA.startChain = chainStart
		chainCA.endChain = chainEnd
	)
	catch
	(
		messageBox ("Cannot Associate "+proxyNode.name+" with chain "+chainStart.name+"-"+chainEnd.name)
		throw()
		return false
	)
	
	return true
)

--
-- IS CHAIN PROXY : Returns true if the node is a proxy of chain
--
function hvkTools_isChainProxy theNode =
(
	return (hvkTools_getAssociatedChain theNode != undefined)
)


-- 
-- GET ASSOCIATED BONE OR START OF CHAIN : works for both bone and chain proxies
--
function hvkTools_getAssociatedBoneOrStartChain proxyNode =
(

	-- Look first for single-bone proxies
	associated = hvkTools_getAssociatedBone proxyNode
	if (associated != undefined ) then return associated
	
	-- Otherwise look for chains
	chain = hvkTools_getAssociatedChain proxyNode
	
	if (undefined != chain) then return chain[1]
	
	return undefined
)

-- 
-- GET ASSOCIATED BONE OR END OF CHAIN : works for both bone and chain proxies
--
function hvkTools_getAssociatedBoneOrEndChain proxyNode =
(

	-- Look first for single-bone proxies
	associated = hvkTools_getAssociatedBone proxyNode
	if (associated != undefined ) then return associated
	
	-- Otherwise look for chains
	chain = hvkTools_getAssociatedChain proxyNode
	
	if (undefined != chain) then return chain[2]
	
	return undefined
)

-- 
-- GET ASSOCIATED BONES : works for both bone and chain proxies
--
function hvkTools_getAssociatedBones proxyNode =
(
	-- Look first for single-bone proxies
	associated = hvkTools_getAssociatedBone proxyNode
	if (associated != undefined ) then return #(associated)
	
	-- Otherwise look for chains
	startEnd = hvkTools_getAssociatedChain proxyNode
	
	if (undefined != startEnd) then 
	(	
		local chainBones = hvkTools_getBonesInChain startEnd[1] startEnd[2]
		
		return chainBones
	)
	
	return undefined
)

--
-- MAKE RIGID BODY : Adds the rigid body and shape modifiers, sets defaults, 
--
function hvkTools_makeRigidBody node =
(
	-- Use the same function we use from the UI, without changing the selection
	rbModifier = hvkPhysics_createSingleRigidBody node updateSelection:false

	if (rbModifier == undefined) then return false
	
	-- set default properties
	rbModifier.mass = hvkCustomizable_defaultProxyMass
	rbModifier.friction = hvkCustomizable_defaultProxyFriction
	rbModifier.restitution = hvkCustomizable_defaultProxyRestitution

	-- notify the user 
	hvkCustomizable_ProxyCreated_Callback node
	
	return true
)

-- 
-- CAN CREATE BONE PROXY : Returns true if we can create a proxy based on this guy's geometry
--
function hvkTools_canCreateBoneProxyFrom obj =
(
	-- Undefined? NO
	if (undefined == obj) then return false
	
	-- If it's already a rb return NO
	if (hvkPhysics_isRigidBody obj) then return false
	
	-- Only can create bones from geometry
	return (isKindOf obj GeometryClass)
)

--
-- CAN CREATE CHAIN PROXY : Returns true if we can create a chain proxy from these nodes
--
function hvkTools_canCreateChainProxyFrom nodeList =
(

	if (nodeList==undefined) then return false
	
	if (nodeList.count < 2) then return false

	-- If the nodes form a chain, all of them except one are parents to another one in the list
	-- Ensure that's the case

	-- With simple assignment maxscript just does a reference copy
	parentList = nodeList + #()
	
	for node in nodeList do
	(
		-- They all have to have some geometry
		if not (isKindOf node GeometryClass) then return false
		
		-- we also ensure that none of the bones is already associated
		local associated= hvkTools_getAssociatedBoneOrStartChain node
		if (associated != undefined) then return false
		
		pi = findItem parentList node.parent
		
		if (pi!=0) then
		(
			deleteItem parentList pi
		)
	)
	
	-- Only one node should be left
	if (parentList.count != 1) then return false
	
	return true
)

--
-- GET START AND END OF CHAIN : Returns the a pair #(start,end) from the list of nodes, or undefined
--								if they don't form a chain
--
function hvkTools_getStartAndEndOfChainFrom nodeList =
(
	if (nodeList.count<2) then return undefined
	
	parentList = nodeList + #()
	childList = nodeList + #()
	
	for node in nodeList do
	(
		pi = findItem parentList node.parent
		
		if (pi!=0) then
		(
			deleteItem parentList pi
			deleteItem childList (findItem childList node) 				
		)
	)
	
	if (parentList.count != 1) then return undefined
	if (childList.count != 1) then return undefined
	
	chainStart = childList[1] -- only node that is not a child
	chainEnd = parentList[1] -- only node that is not a parent

	return #(chainStart, chainEnd)
)

--
-- BONE PROPERTIES : Mass, Restitution and Friction
--

function hvkTools_GetRBMass theNode =
(
	rbModifier = hvkPhysics_getRigidBodyModifier theNode
	
	if (rbModifier == undefined) then return undefined
	
	return rbModifier.mass
)

function hvkTools_SetRBMass theNode theMass = 
(
	rbModifier = hvkPhysics_getRigidBodyModifier theNode
	
	if (rbModifier == undefined) then return false
	
	rbModifier.mass = theMass
	
	return true;
)

function hvkTools_GetRBRestitution theNode =
(
	rbModifier = hvkPhysics_getRigidBodyModifier theNode
	
	if (rbModifier == undefined) then return undefined
	
	return rbModifier.restitution
)

function hvkTools_SetRBRestitution theNode theRestitution = 
(
	rbModifier = hvkPhysics_getRigidBodyModifier theNode
	
	if (rbModifier == undefined) then return false
	
	rbModifier.restitution = theRestitution
	
	return true;
)

function hvkTools_GetRBFriction theNode =
(
	rbModifier = hvkPhysics_getRigidBodyModifier theNode
	
	if (rbModifier == undefined) then return undefined
	
	return rbModifier.friction
)

function hvkTools_SetRBFriction theNode theFriction = 
(
	rbModifier = hvkPhysics_getRigidBodyModifier theNode
	
	if (rbModifier == undefined) then return false
	
	rbModifier.friction = theFriction
	
	return true;
)


