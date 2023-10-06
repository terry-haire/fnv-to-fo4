	--ProOmptimizer
	(
		select (for o in objects where not classOf o == BoneGeometry collect o)
		selection.material = (BSLightingFX ())
		macros.run "Modifiers" "ProOptimizerMod"
		selection[1].modifiers[#ProOptimizer].MergePoints = on
		selection[1].modifiers[#ProOptimizer].MergePointsThreshold = 10
		selection[1].modifiers[#ProOptimizer].MergeFaces = on
		selection[1].modifiers[#ProOptimizer].MergeFacesAngle = 10
		selection[1].modifiers[#ProOptimizer].Calculate = off
		selection[1].modifiers[#ProOptimizer].Calculate = on
		selection[1].modifiers[#ProOptimizer].VertexPercent = 75
		select (for o in objects where not classOf o == BoneGeometry collect o)
		for i = 1 to selection.count do
		(
			--deleteModifier selection[i] 1
			maxOps.CollapseNodeTo selection[i] 1 off
		)
	)