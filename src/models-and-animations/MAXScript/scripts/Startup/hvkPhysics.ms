global hvkPhysicsInitialized

if (hvkCommonInitialized==undefined) then
(
	fileIn "startup/hvkCommon.ms"
)

global hvkPhysics_getHavokPhysicsModifierTypes

if (hvkPhysicsInitialized==undefined) then
(
	fileIn "havokPhysics/hvkPhysics_Utils.ms"
	fileIn "havokPhysics/ragdollTools/hvkTools.ms"
	fileIn "havokPhysics/hvkPhysics_UI.ms"

	-- The defition of CA sets the dirty flag in the scene. We reset it
	clearUndoBuffer()

	-- Register the physics modifiers
	physicsModifiers = hvkPhysics_getHavokPhysicsModifierTypes()
	registerHavokModifiers physicsModifiers
	
	hvkPhysicsInitialized = true
)

