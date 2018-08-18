
--
-- THIS SCRIPT CONTAINS VALUES AND FUNCTIONS THAT THE USER MAY WANT TO CUSTOMIZE
--
-- Notice that reinstalling the exporter(s) will overwrite any changes to this file, so it may be safer to modify
-- a renamed copy of this file and then make this file forward to it rather than modifying this file itself
--

--
-- DEFAULTS FOR GLOBAL OPTIONS
--

-- Default scaling for bones for new scenes (Options Rollout)
global hvkBoneCollidableCustomizable_defaultBoneScaleX = 1.0
global hvkBoneCollidableCustomizable_defaultBoneScaleY = 1.0
global hvkBoneCollidableCustomizable_defaultBoneScaleZ = 1.0

-- Default value for whether to freeze or not associated bones for new scenes (Options Rollout)
global hvkBoneCollidableCustomizable_defaultFreezeAssociatedBone = false

-- Default value for whether to autoparent a collidable based on the associated bones parent and children collidables (Options Rollout)
hvkBoneCollidableCustomizable_autoParentCollidableOnCreation = true
--
-- CONSTANT GLOBAL OPTIONS
--

-- Switch to false to disallow docking of the ragdoll tool
global hvkBoneCollidableCustomizable_makeBoneCollidableToolDockable = true

--
-- PROPERTIES OF NEW BONES
--

-- This gets called whenever a proxy is created
function hvkBoneCollidableCustomizable_proxyCreated_Callback theBone =
(
	-- Add your custom processing here
)


--
-- DEFAULT NAMING OF BONES AND JOINTS
--

-- Default naming for new bone proxies (created based on another bone)
function hvkBoneCollidableCustomizable_renameNewBoneProxy newProxy associatedBone =
(
	-- Prefix with "Collidable_"
	local theName = "Collidable_" + associatedBone.name
	
	-- Make unique
	theName = uniqueName theName
	
	newProxy.name = theName
)

-- Default naming for new chain proxies (created based on another bone)
function hvkBoneCollidableCustomizable_renameNewChainProxy newProxy chainStart chainEnd =
(
	-- Prefix with "Collidable_" the name of the start of the chain
	local theName = "Collidable_" + chainStart.name
	
	-- Make unique
	theName = uniqueName theName
	
	newProxy.name = theName
)