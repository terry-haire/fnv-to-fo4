
--
-- CA DEFINITION : For the "Bone Proxy" attributes
--
hvkGlobal_boneProxyCADef = attributes hkBoneProxyCA version:1 attribId:#(0x6e663460, 0x32682c72)
(
	parameters hkBoneProxyCA rollout:rolloutUI 
	(
		associatedBone type:#node UI:associatedBoneUI
	)
	
	rollout rolloutUI "Bone Proxy" width:162 height:615
	(
		label lblDrivingBone "Associated  Bone" Align:#Center
		pickbutton associatedBoneUI "Associated Bone" Width:150 Height:25 Align:#Center Offset:[0,0] Type:#node autoDisplay:true
	)
)

--
-- CA DEFINITION : For the "Bone Chain Proxy" attributes
--
hvkGlobal_chainProxyCADef = attributes hkChainProxyCA version:1 attribId:#(0x4d253d52, 0x7f8208bf)
(
	parameters hkChainProxyCA rollout:rolloutUI 
	(
		startChain type:#node UI:startChainUI
		endChain type:#node UI:endChainUI
	)
	
	rollout rolloutUI "Bone Chain Proxy" width:162 height:615
	(
		label lblStartChain "Start Chain" Align:#Center
		pickbutton startChainUI "Start Chain" Width:150 Height:25 Align:#Center Offset:[0,0] Type:#node autoDisplay:true
		label lblEndChain "End Chain" Align:#Center
		pickbutton endChainUI "End Chain" Width:150 Height:25 Align:#Center Offset:[0,0] Type:#node autoDisplay:true

	)
)

--
-- GET CA : Finds the given CA (definition) in the collidable modifier of the node
--
function hvkBoneCollidableTools_getCA theNode caDef =
(
	clothModifier = hvkCloth_getClothCollidableModifier theNode
	
	if (clothModifier == undefined) then return undefined
	
	ca = custAttributes.get clothModifier caDef
	
	return ca	
)


--
-- GET OR CREATE CA : As GetCA, but if not found, it creates it
--
function hvkBoneCollidableTools_getOrCreateCA theNode caDef=
(
	clothCollidableModifier = hvkCloth_getClothCollidableModifier theNode
	
	-- We need the cloth collidable modifier present at least
	if (clothCollidableModifier == undefined) then return undefined
	
	ca = custAttributes.get clothCollidableModifier caDef
	
	-- If CA already there, return it
	if (ca != undefined) then return ca
	
	-- Otherwise add it
	custAttributes.add clothCollidableModifier caDef

	-- and get it back
	ca = custAttributes.get clothCollidableModifier caDef
	
	return ca
)

--
-- REMOVE BONE ASSOCATION
--
mapped function hvkBoneCollidableTools_removeProxyCAs theNode =
(
	clothCollidableModifier = hvkCloth_getClothCollidableModifier theNode
	
	-- We need the Cloth Collidable modifier present at least
	if (clothCollidableModifier == undefined) then return undefined

	custAttributes.delete clothCollidableModifier hvkGlobal_boneProxyCADef
	custAttributes.delete clothCollidableModifier hvkGlobal_chainProxyCADef
)
	
--
-- VERSIONS FOR THE BONE PROXY CA
--
function hvkBoneCollidableTools_getBoneProxyCA theNode = 
(
	return hvkBoneCollidableTools_getCA theNode hvkGlobal_boneProxyCADef
)

function hvkBoneCollidableTools_getOrCreateBoneProxyCA theNode =
(
	return hvkBoneCollidableTools_getOrCreateCA theNode hvkGlobal_boneProxyCADef
)

-- 
-- VERSIONS FOR THE BONE CHAIN CA
--
function hvkBoneCollidableTools_getChainProxyCA theNode = 
(
	return hvkBoneCollidableTools_getCA theNode hvkGlobal_chainProxyCADef
)

function hvkBoneCollidableTools_getOrCreateChainProxyCA theNode =
(
	return hvkBoneCollidableTools_getOrCreateCA theNode hvkGlobal_chainProxyCADef
)
