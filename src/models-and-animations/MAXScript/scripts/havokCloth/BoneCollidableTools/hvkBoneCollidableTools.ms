
fileIn "havokCloth/boneCollidableTools/hvkBoneCollidableTools_Customizable.ms"
fileIn "havokCloth/boneCollidableTools/hvkBoneCollidableTools_Utils.ms"
fileIn "havokCloth/boneCollidableTools/bone/hvkBoneCollidableBoneTools.ms"
fileIn "havokCloth/boneCollidableTools/options/hvkBoneCollidableOptions.ms"

function hvkCloth_openBoneCollidableTools = 
(
	global hvkHavokBoneCollidableToolFloater

	if (hvkHavokBoneCollidableToolFloater == undefined) or (not hvkHavokBoneCollidableToolFloater.open) then
	(
		hvkHavokBoneCollidableToolFloater = newRolloutFloater "Havok Bone Collidable Toolbox" 225 535

		if (hvkBoneCollidableCustomizable_makeBoneCollidableToolDockable == true) then
		(
			cui.RegisterDialogBar hvkHavokBoneCollidableToolFloater style:#(#cui_dock_left, #cui_dock_right, #cui_floatable, #cui_handles, #cui_max_sized) minSize:[230,-1] maxSize:[230,-1]
		)

		addRollout hvkBoneCollidableBoneTools hvkHavokBoneCollidableToolFloater rolledUp:false
		addRollout hvkBoneCollidableOptions hvkHavokBoneCollidableToolFloater rolledUp:true
	)
)

