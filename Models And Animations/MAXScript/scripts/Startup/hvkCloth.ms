
global hvkClothInitialized
global hvkPhysicsInitialized

global hvkCloth_getHavokClothModifierTypes
global registerHavokModifiers

global hvkCloth_openClothTools


if (hvkClothInitialized==undefined) then
(
	if (hvkPhysicsInitialized==undefined) then
	(
		fileIn "startup/hvkPhysics.ms"
	)
	
	fileIn "havokCloth/hvkCloth_Utils.ms"
	fileIn "havokCloth/hvkCloth_UI.ms"
	fileIn "havokCloth/clothTools/hvkClothTools.ms"
	fileIn "havokCloth/boneCollidableTools/hvkBoneCollidableTools.ms"
	
	-- The defition of CA sets the dirty flag in the scene. We reset it
	clearUndoBuffer()
	
	-- Register the cloth modifiers
	local clothModifiers = hvkCloth_getHavokClothModifierTypes ()
	registerHavokModifiers clothModifiers
	
	hvkClothInitialized = true
)	
   