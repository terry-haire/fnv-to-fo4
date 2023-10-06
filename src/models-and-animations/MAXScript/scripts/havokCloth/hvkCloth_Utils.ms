-- TODO:	
--			hvkCloth_paintParticleChannel: before creating a new modifier it checks if there's an existest 
--			VertexPaint modifier for the selected channel,even if the channel was just created. 
--			if the old modifier was using a different channel we can't reuse it.
--			We can check all Vertex Paint mods of the object and reuse one whose channel is not supported anymore.
--			This still doesn't fix it since most likely a "deleted" channel will stil have map support and number 
--			of vertices != 0. 

function hvkCloth_getClothCollidableModifier theNode =
(
	return hvkCommon_getModifierOfType theNode hkClothCollidableModifier
)

function hvkCloth_isClothCollidable theNode =
(
	return ((hvkCloth_getClothCollidableModifier theNode) != undefined)
)


function hvkCloth_canCreateClothCollidable theNode = 
(
	-- We can only create cloth from geometry
	if (not isKindOf theNode GeometryClass) then return false
	
	-- Can't create a collidable from a collidable
	if(hvkCloth_isClothCollidable theNode) then return false;
	
	-- We cannot use biped bones
	if (classOf (theNode.controller) == BipSlave_Control) then return false
	
	return true;
)

mapped function hvkCloth_createExportChannel theNode channelID channelName channelExportName updateSelection:true = 
(
	local expChModifier = hkExportChannelModifier()
	expChModifier.channelID = channelID
	expChModifier.channelName = channelName
	expChModifier.channelExportName = channelExportName
	addModifier theNode expChModifier
	
	if ( expChModifier != undefined and updateSelection ) do
	(
		hvkCommon_selectModifier expChModifier
	)
)

function hvkCloth_getBestCollidableTypeForNode theNode =
(
	-- 0 = Sphere
	-- 1 = Plane
	-- 2 = Capsule
	-- 3 = Convex Geometry
	-- 4 = Convex Heightfield
		
	shapeType = 3 -- Convex Geometry by default

	if (hvkCommon_haveSameClass theNode Sphere) or (hvkCommon_haveSameClass theNode GeoSphere) then
	(
		shapeType = 0
	)
	else
	(
		if (hvkCommon_haveSameClass theNode Plane) then
		(
			shapeType = 1
		)
		else
		(
			if (hvkCommon_haveSameClass theNode Capsule) then
			(
				shapeType = 2
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

	return shapeType

)

mapped function hvkCloth_createClothCollidable theNode updateSelection:true = 
(
	if ( hvkCloth_canCreateClothCollidable theNode ) then 
	(
		-- create the modifier
		collidableModifier = hkClothCollidableModifier()
		addModifier theNode collidableModifier
		
		-- set the best type
		collidableModifier.collidableShapeType = hvkCloth_getBestCollidableTypeForNode theNode
		
		if (collidableModifier!=undefined) and updateSelection then
		(
			hvkCommon_selectModifier collidableModifier
		)
		
	)
)

function hvkCloth_getHavokClothModifierTypes =
(
	local clothTypes = #( hkExportChannelModifier, hkClothCollidableModifier )
	
	return clothTypes
)
