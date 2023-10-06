
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
global hvkCustomizable_defaultBoneScaleX = 1.2
global hvkCustomizable_defaultBoneScaleY = 1.1
global hvkCustomizable_defaultBoneScaleZ = 1.1

-- Default value for whether to freeze or not associated bones for new scenes (Options Rollout)
global hvkCustomizable_defaultFreezeAssociatedBone = false

-- Default axis configuration for new scenes  (Options Rollout)
global hvkCustomizable_defaultMainAxis = 1  -- positive X
global hvkCustomizable_defaultBendAxis = 6  -- negative Z

-- Default template sfolder (for new scenes, etc)
global hvkCustomizable_defaultTemplatesFolder = (getdir #maxroot)+"scripts/havokPhysics/ragdollTools/templates/defaultHuman"

--
-- CONSTANT GLOBAL OPTIONS
--

-- Switch to false to disallow docking of the ragdoll tool
global hvkCustomizable_makeRagdollToolDockable = true

--
-- PROPERTIES OF NEW BONES
--

-- Properties set to new bones (that don't have them set already)
global hvkCustomizable_defaultProxyMass = 5.0
global hvkCustomizable_defaultProxyRestitution = 0.8
global hvkCustomizable_defaultProxyFriction = 0.3

-- This gets called whenever a proxy is created
function hvkCustomizable_proxyCreated_Callback theBone =
(
	-- Add your custom processing here
)


--
-- DEFAULT NAMING OF BONES AND JOINTS
--

-- Default naming for new bone proxies (created based on another bone)
function hvkCustomizable_renameNewBoneProxy newProxy associatedBone =
(
	-- Prefix with "Ragdoll_"
	local theName = "Ragdoll_" + associatedBone.name
	
	-- Make unique
	theName = uniqueName theName
	
	newProxy.name = theName
)

-- Default naming for new chain proxies (created based on another bone)
function hvkCustomizable_renameNewChainProxy newProxy chainStart chainEnd =
(
	-- Prefix with "Ragdoll_" the name of the start of the chain
	local theName = "Ragdoll_" + chainStart.name
	
	-- Make unique
	theName = uniqueName theName
	
	newProxy.name = theName
)

-- Default naming for new joints (created from template)
function hvkCustomizable_renameNewJoint newJoint templateName =
(
	-- Leaves the default name
)

--
-- TERMINALS
--

-- Default naming for terminals
function hvkCustomizable_renameNewTerminal newTerminal proxy =
(
	newTerminal.name = proxy.name+"_Terminal"
)
