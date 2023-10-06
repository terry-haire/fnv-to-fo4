
fileIn "havokPhysics/ragdollTools/hvkTools_Customizable.ms"
fileIn "havokPhysics/ragdollTools/hvkTools_Utils.ms"
fileIn "havokPhysics/ragdollTools/bone/hvkBoneTools.ms"
fileIn "havokPhysics/ragdollTools/joint/hvkJointTools.ms"
fileIn "havokPhysics/ragdollTools/options/hvkOptions.ms"

function hvkPhysics_openRagdollTools = 
(
	global hvkHavokRagdollToolFloater

	if (hvkHavokRagdollToolFloater == undefined) or (not hvkHavokRagdollToolFloater.open) then
	(
		hvkHavokRagdollToolFloater = newRolloutFloater "Havok Rag Doll Toolbox" 225 535

		if (hvkCustomizable_makeRagdollToolDockable == true) then
		(
			cui.RegisterDialogBar hvkHavokRagdollToolFloater style:#(#cui_dock_left, #cui_dock_right, #cui_floatable, #cui_handles, #cui_max_sized) minSize:[230,-1] maxSize:[230,-1]
		)

		addRollout hvkBoneTools hvkHavokRagdollToolFloater rolledUp:false
		addRollout hvkJointTools hvkHavokRagdollToolFloater rolledUp:false
		addRollout hvkOptions hvkHavokRagdollToolFloater rolledUp:true
	)
)

