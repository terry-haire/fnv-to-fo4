
-- Utilities used by all tools

fileIn "havokCloth/boneCollidableTools/hvkBoneCollidableTools_CAttribs.ms"
fileIn "havokCloth/boneCollidableTools/hvkBoneCollidableTools_Customizable.ms"
fileIn "havokCloth/boneCollidableTools/hvkBoneCollidableTools_Globals.ms"
fileIn "havokCloth/boneCollidableTools/hvkBoneCollidableTools_CAttribs.ms"
fileIn "havokCloth/hvkCloth_Utils.ms"

--
-- REORDER PARENT FIRST : Reorders a list of nodes so parents go first
--

function hvkBoneCollidableTools_depthOf aNode =
(
	if (aNode.parent == undefined) then return 0
	
	return ( (hvkBoneCollidableTools_depthOf aNode.parent) +1 )
)

function hvkBoneCollidableTools_reorderParentFirst originalList= 
(
	local nodeList = originalList + #()
	
	function sortFunc nodeA nodeB =
	(		
		return ( (hvkBoneCollidableTools_depthOf nodeA) - (hvkBoneCollidableTools_depthOf nodeB) )
	)
	
	qsort nodeList sortFunc
	
	return nodeList
)

--
-- GET ASSOCIATED BONE : Returns the driving bone associated with this proxy
--
function hvkBoneCollidableTools_getAssociatedBone proxyNode =
(
	boneProxyCA = hvkBoneCollidableTools_getBoneProxyCA proxyNode
	
	if (boneProxyCA == undefined) then return undefined
	
	return boneProxyCA.associatedBone
)

--
-- ASSOCIATE BONE : Associated a bone to a proxy
--
function hvkBoneCollidableTools_associateBone proxyNode boneNode =
(
	boneProxyCA = hvkBoneCollidableTools_getOrCreateBoneProxyCA proxyNode
	
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
function hvkBoneCollidableTools_isBoneProxy node =
(
	return (hvkBoneCollidableTools_GetAssociatedBone node != undefined)
)

--
-- GET ASSOCIATED CHAIN : Returns the start and end bones associated with this proxy
--
function hvkBoneCollidableTools_getAssociatedChain proxyNode =
(
	chainCA = hvkBoneCollidableTools_getChainProxyCA proxyNode
	
	if (chainCA == undefined) then return undefined
	
	start = chainCA.startChain
	end = chainCA.endChain
	
	if (start==undefined) or (end==undefined) then return undefined
	
	return #(start, end)
)

--
-- GET BONES IN CHAIN : Given an start and an end, it returns the bones in that chain
--
function hvkBoneCollidableTools_getBonesInChain chainStart chainEnd =
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
function hvkBoneCollidableTools_associateChain proxyNode chainStart chainEnd =
(
	chainCA = hvkBoneCollidableTools_getOrCreateChainProxyCA proxyNode
	
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
function hvkBoneCollidableTools_isChainProxy theNode =
(
	return (hvkBoneCollidableTools_getAssociatedChain theNode != undefined)
)


-- 
-- GET ASSOCIATED BONE OR START OF CHAIN : works for both bone and chain proxies
--
function hvkBoneCollidableTools_getAssociatedBoneOrStartChain proxyNode =
(

	-- Look first for single-bone proxies
	associated = hvkBoneCollidableTools_getAssociatedBone proxyNode
	if (associated != undefined ) then return associated
	
	-- Otherwise look for chains
	chain = hvkBoneCollidableTools_getAssociatedChain proxyNode
	
	if (undefined != chain) then return chain[1]
	
	return undefined
)

-- 
-- GET ASSOCIATED BONE OR END OF CHAIN : works for both bone and chain proxies
--
function hvkBoneCollidableTools_getAssociatedBoneOrEndChain proxyNode =
(

	-- Look first for single-bone proxies
	associated = hvkBoneCollidableTools_getAssociatedBone proxyNode
	if (associated != undefined ) then return associated
	
	-- Otherwise look for chains
	chain = hvkBoneCollidableTools_getAssociatedChain proxyNode
	
	if (undefined != chain) then return chain[2]
	
	return undefined
)

-- 
-- GET ASSOCIATED BONES : works for both bone and chain proxies
--
function hvkBoneCollidableTools_getAssociatedBones proxyNode =
(
	-- Look first for single-bone proxies
	associated = hvkBoneCollidableTools_getAssociatedBone proxyNode
	if (associated != undefined ) then return #(associated)
	
	-- Otherwise look for chains
	startEnd = hvkBoneCollidableTools_getAssociatedChain proxyNode
	
	if (undefined != startEnd) then 
	(	
		local chainBones = hvkBoneCollidableTools_getBonesInChain startEnd[1] startEnd[2]
		
		return chainBones
	)
	
	return undefined
)

--
-- MAKE COLLIDABLE : Adds the collidable modifier, sets defaults, 
--
function hvkBoneCollidableTools_makeCollidable node =
(
	-- Use the same function we use from the UI, without changing the selection
	collidableModifier = hvkCloth_createClothCollidable node updateSelection:false

	if (collidableModifier == undefined) then return false
	
	collidableModifier.collidableShapeType = hvkCloth_getBestCollidableTypeForNode theNode
		
	if (collidableModifier!=undefined) and updateSelection then
	(
		hvkCommon_selectModifier collidableModifier
	)
	-- notify the user 
	hvkBoneCollidableCustomizable_ProxyCreated_Callback node
	
	return true
)

-- 
-- CAN CREATE BONE PROXY : Returns true if we can create a proxy based on this guy's geometry
--
function hvkBoneCollidableTools_canCreateBoneProxyFrom obj =
(
	-- Undefined? NO
	if (undefined == obj) then return false
	
	-- If it's already a collidable return NO
	if (hvkCloth_isClothCollidable obj) then return false
	
	-- Only can create bones from geometry
	return (isKindOf obj GeometryClass)
)

--
-- CAN CREATE CHAIN PROXY : Returns true if we can create a chain proxy from these nodes
--
function hvkBoneCollidableTools_canCreateChainProxyFrom nodeList =
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
		local associated= hvkBoneCollidableTools_getAssociatedBoneOrStartChain node
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
function hvkBoneCollidableTools_getStartAndEndOfChainFrom nodeList =
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




