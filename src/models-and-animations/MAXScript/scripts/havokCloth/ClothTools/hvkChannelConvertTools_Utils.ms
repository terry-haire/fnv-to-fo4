
------  TEXTURE <=> COLORS CONVERSION -----------------------------------------------
	

-- Creates a material and sets its diffuse map with vertex colors, it expects the node and the ID of the vertex colors channel.
-- Returns the index of the previously assigned material
function hvkChannelConvert_setupVertexColorMaterial theNode channelID = 
(
	-- find the index of the currently assigned material
	local oldMadIdx = findItem meditMaterials theNode.material
	
	-- create a new blank material
	local targetMaterial = StandardMaterial()
	
	-- enable diffuse map and assign vertex color to it
	targetMaterial.diffuseMapEnable = on
	targetMaterial.diffuseMap = Vertex_Color()
	
	-- set the channel
	targetMaterial.diffuseMap.map = channelID
	
	-- set self illumination to max to avoid shadows
	targetMaterial.selfIllumAmount = 100
	
	-- assign the material to the object
	theNode.material = targetMaterial
	
	return oldMatIdx;
)

-- renders the currentMap of theNode to fullFileName, using provided size and mapping channel ID 
function hvkChannelConvert_renderDiffuseMap theNode xSize ySize uvChannelID fullFileName showImage =
(
	local fName = getFilenameFile fullFileName
	local fType = getFilenameType fullFileName
	
	-- prepare diffuse map baking element
	local currentMap = DiffuseMap()
	currentMap.filename = fName
	currentMap.fileType = fType
	currentMap.outputSzX = xSize
	currentMap.outputSzY = ySize
	currentMap.shadowsOn = false
	
	-- set baking properties
	local bakeProps = theNode.INodeBakeProperties
	bakeProps.addBakeElement currentMap
	bakeProps.bakeChannel = uvChannelID
	bakeProps.bakeEnabled = true
	
	-- render to texture
	render rendertype:#bakeSelected outputwidth:xSize outputheight:ySize outputfile:fullFileName vfb:showImage 
	
	-- cleanup
	bakeProps.removeAllBakeElements()
	bakeProps.bakeEnabled = false
)

function hvkChannelConvert_addUnwrapUVWModifierToNodeAndFlatten theNode uvwChannelID =
(
	select theNode
	
	-- create the modifier and select the channel
	unwrapMod = Unwrap_UVW()
	unwrapMod.setMapChannel uvwChannelID
	
	-- add the modifier to the stack
	addModifier theNode unwrapMod
	
	-- flatten uvws
	unwrapMod.flattenMapNoParams()
)

-- renders vertex colors in channelID to the texture identified by the path
-- when done it restores the previous material and settings
function hvkChannelConvert_renderVertexColorsToTexture theNode channelID textureOutputPath uvwChannelID:1 xSize:512 ySize:512 showImage:false =
(
	-- check that the node exists and the channel is supported 
	if ( theNode != undefined and ( meshop.getMapSupport theNode.mesh channelID ) ) do 
	(
		-- setup the material that we'll use for the rendering and store the index of the old one
		local oldMatIdx = hvkChannelConvert_setupVertexColorMaterial theNode channelID
		
		-- render the diffuse map to texture
		hvkChannelConvert_renderDiffuseMap theNode xSize ySize uvwChannelID textureOutputPath showImage

		-- assign the old material back to the object
		if oldMatIdx != undefined do
		(
			theNode.material = meditMaterials[ oldMatIdx ]
		)
	)
) 

------  SELECTION <=> COLORS CONVERSION -----------------------------------------------

function hvkSelectionTools_convertCurrentVertexSelectionToVertexChannel vpModifier channelID selectedValue unselectedValue = 
(
	local selected =  $selection as Array
	local justOneNodeSelected = selected.count == 1
	
	if ( justOneNodeSelected ) do
	(
		hkConversionUtilGUP.convertSelectionToVertexChannel selected[1] vpModifier selectedValue unselectedValue
	)
)


function hvkSelectionTools_convertVertexChannelToVertexSelection vpModifier thresholdValue invert selectionName = 
(
	local selected =  $selection as Array
	local justOneNodeSelected = selected.count == 1
	
	if ( justOneNodeSelected and ( subObjectLevel == 1 ) ) do
	(
		hkConversionUtilGUP.convertVertexChannelToSelection selected[1] vpModifier thresholdValue invert selectionName
	)
)