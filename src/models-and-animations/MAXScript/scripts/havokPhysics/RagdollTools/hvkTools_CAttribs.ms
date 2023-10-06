
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
-- GET CA : Finds the given CA (definition) in the RB modifier of the node
--
function hvkTools_getCA theNode caDef =
(
	rbModifier = hvkPhysics_getRigidBodyModifier theNode
	
	if (rbModifier == undefined) then return undefined
	
	ca = custAttributes.get rbModifier caDef
	
	return ca	
)


--
-- GET OR CREATE CA : As GetCA, but if not found, it creates it
--
function hvkTools_getOrCreateCA theNode caDef=
(
	rbModifier = hvkPhysics_getRigidBodyModifier theNode
	
	-- We need the rb modifier present at least
	if (rbModifier == undefined) then return undefined
	
	ca = custAttributes.get rbModifier caDef
	
	-- If CA already there, return it
	if (ca != undefined) then return ca
	
	-- Otherwise add it
	custAttributes.add rbModifier caDef

	-- and get it back
	ca = custAttributes.get rbModifier caDef
	
	return ca
)

--
-- REMOVE BONE ASSOCATION
--
mapped function hvkTools_removeProxyCAs theNode =
(
	rbModifier = hvkPhysics_getRigidBodyModifier theNode
	
	-- We need the rb modifier present at least
	if (rbModifier == undefined) then return undefined

	custAttributes.delete rbModifier hvkGlobal_boneProxyCADef
	custAttributes.delete rbModifier hvkGlobal_chainProxyCADef
)
	
--
-- VERSIONS FOR THE BONE PROXY CA
--
function hvkTools_getBoneProxyCA theNode = 
(
	return hvkTools_getCA theNode hvkGlobal_boneProxyCADef
)

function hvkTools_getOrCreateBoneProxyCA theNode =
(
	return hvkTools_getOrCreateCA theNode hvkGlobal_boneProxyCADef
)

-- 
-- VERSIONS FOR THE BONE CHAIN CA
--
function hvkTools_getChainProxyCA theNode = 
(
	return hvkTools_getCA theNode hvkGlobal_chainProxyCADef
)

function hvkTools_getOrCreateChainProxyCA theNode =
(
	return hvkTools_getOrCreateCA theNode hvkGlobal_chainProxyCADef
)
