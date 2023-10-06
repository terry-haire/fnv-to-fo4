--Create convex decomposition rollout

fileIn "havokConvexDecomp/ConvexDecompositionTools/hvkConvexDecomp_Decompose.ms"
fileIn "havokConvexDecomp/ConvexDecompositionTools/hvkConvexDecomp_Combine.ms"
fileIn "havokConvexDecomp/ConvexDecompositionTools/hvkConvexDecomp_Results.ms"
fileIn "havokConvexDecomp/ConvexDecompositionTools/hvkConvexDecomp_View.ms"

function hvkPhysics_openConvexDecompositionTools = 
(
	global hvkHavokConvexDecompositionToolFloater

	if (hvkHavokConvexDecompositionToolFloater == undefined) or (not hvkHavokConvexDecompositionToolFloater.open) then
	(
		hvkHavokConvexDecompositionToolFloater = newRolloutFloater "Havok Decomposition Toolbox" 209 680

		if (hvkCustomizable_makeRagdollToolDockable == true) then
		(
			cui.RegisterDialogBar hvkHavokConvexDecompositionToolFloater style:#(#cui_dock_left, #cui_dock_right, #cui_floatable, #cui_handles, #cui_max_sized) minSize:[214,-1] maxSize:[214,-1]
			--cui.dockDialogBar hvkHavokConvexDecompositionToolFloater #cui_dock_left
		)

		addRollout hvkConvexDecomp_Decompose hvkHavokConvexDecompositionToolFloater rolledUp:false
		addRollout hvkConvexDecomp_DecomposeAdv hvkHavokConvexDecompositionToolFloater rolledUp:true
		addRollout hvkConvexDecomp_Combine hvkHavokConvexDecompositionToolFloater rolledUp:false
		addRollout hvkConvexDecomp_View hvkHavokConvexDecompositionToolFloater rolledUp:false
		addRollout hvkConvexDecomp_Results hvkHavokConvexDecompositionToolFloater rolledUp:false
	)
)













