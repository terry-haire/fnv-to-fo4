--Functions and CAs used by all CD rollouts

global \
hvkConvexDecomp_OrigMeshScaleCAdef,
hvkConvexDecomp_OrigMeshCAdef,
hvkConvexDecomp_ConvexHullGroupCAdef,
hvkConvexDecomp_IsDecomposedCAdef,
hvkConvexDecomp_ExplodeCAdef,
hvkConvexDecomp_TransformCAdef,
hvkConvexDecomp_GetGroupHead,
hvkConvexDecomp_ConnectNewNodes,
hvkConvexDecomp_SelectNodes,
hvkConvexDecomp_RemoveCamerasFromArray,
hvkConvexDecomp_ConnectGroupHead,
hvkConvexDecomp_GetSelectedMeshes,
hvkConvexDecomp_CalcHullGroupCom,
hvkConvexDecomp_ExplodeHulls,
hvkConvexDecomp_SetHullTransforms,
hvkConvexDecomp_HideOriginalMesh

hvkConvexDecomp_OrigMeshScaleCAdef = attributes hvkConvexDecomp_OrigMeshScaleCA
(
	parameters main
	(
		scale type:#float
	)
)

hvkConvexDecomp_OrigMeshCAdef = attributes hvkConvexDecomp_OrigMeshCA
(
	parameters main
	(
		mesh type:#node
	)
)

hvkConvexDecomp_ConvexHullGroupCAdef = attributes hvkConvexDecomp_ConvexHullGroupCA
(
	parameters main
	(
		groupHead type:#node
	)
)

hvkConvexDecomp_IsDecomposedCAdef = attributes hvkConvexDecomp_IsDecomposedCA
(
	parameters main
	(
		flag type:#boolean
	)
)

hvkConvexDecomp_ExplodeCAdef = attributes hvkConvexDecomp_ExplodeCA
(
	parameters main
	(
		explodeFactor type:#float
		flag type:#boolean
		nHulls type:#integer
		com type:#Point3
	)
)

hvkConvexDecomp_TransformCAdef = attributes hvkConvexDecomp_TransformCA
(
	parameters main
	(
		originalTransform type:#Point3
	)
)

function hvkConvexDecomp_GetGroupHead groupNodes =
(
	if (0 == groupNodes.count) then
	(
		return undefined
	)
	else
	(
		local node = groupNodes[1]

		while (isGroupMember node) do
		(
			node = node.parent
		)
		return node
	)
)

function hvkConvexDecomp_ConnectNewNodes origMesh &outputNodes =
(
	if (undefined == custAttributes.get origMesh hvkConvexDecomp_IsDecomposedCAdef) then
	(
		custAttributes.add origMesh hvkConvexDecomp_IsDecomposedCAdef
	)
	origMesh.hvkConvexDecomp_IsDecomposedCA.flag = true

	for node in outputNodes do
	(
		custAttributes.add node hvkConvexDecomp_OrigMeshCAdef
		node.hvkConvexDecomp_OrigMeshCA.mesh = origMesh
	)
	return true
)

function hvkConvexDecomp_ConnectGroupHead origMesh groupHead =
(
	if (undefined == custAttributes.get origMesh hvkConvexDecomp_ConvexHullGroupCAdef) then
	(
		custAttributes.add origMesh hvkConvexDecomp_ConvexHullGroupCAdef
	)
	origMesh.hvkConvexDecomp_ConvexHullGroupCA.groupHead = groupHead

	return true
)

function hvkConvexDecomp_RemoveCamerasFromArray nodes =
(
	meshes = nodes

	i = 1
	while (i <= meshes.count) do
	(
		obj = meshes[i]

		if (isGroupHead obj or canConvertTo obj Editable_mesh) then
		(
			i += 1
		)
		else
		(
			deleteItem meshes i
		)
	)

	return meshes
)

function hvkConvexDecomp_GetSelectedMeshes selectedNodes =
(
	local tempMeshes = #() --<TODO> could use hashtable
	local nodeCA
	local meshNode

	for node in selectedNodes do
	(
		nodeCA = custAttributes.get node hvkConvexDecomp_OrigMeshCAdef

		if (undefined != nodeCA) then
		(
			meshNode = nodeCA.mesh
			if (undefined != meshNode) then
			(
				append tempMeshes meshNode
			)
		)
		else
		(
			nodeCA = custAttributes.get node hvkConvexDecomp_IsDecomposedCAdef

			if (undefined != nodeCA) then
			(
				append tempMeshes node
			)
		)
	)

	local meshes = #()
	local lastMesh = undefined

	for mesh in tempMeshes do
	(
		if (mesh != lastMesh) then
		(
			if (0 == findItem meshes mesh) then
			(
				append meshes mesh
				lastMesh = mesh
			)
		)
	)

	return meshes
)

function hvkConvexDecomp_CalcHullGroupCom hullGroup =
(
	local Point3 overallCom = [0,0,0]

	for hull in hullGroup do
	(
		--transforms are centred on hulls
		overallCom += hull.pos
	)

	local nHulls = 1 / hullGroup.count as float

	overallCom *= nHulls

	return overallCom
)

function hvkConvexDecomp_ExplodeHulls hulls com explodeFactor =
(
	for hull in hulls do
	(
		hull.pos = hull.hvkConvexDecomp_TransformCA.originalTransform + (hull.hvkConvexDecomp_TransformCA.originalTransform - com) * explodeFactor
	)
	return true
)

function hvkConvexDecomp_SetHullTransforms origMesh hulls =
(
	local Point3 minPoint = [10000,10000,10000]
	local Point3 maxPoint = [-10000,-10000,-10000]
	
	for hull in hulls do
	(
		if (undefined == custAttributes.get hull hvkConvexDecomp_TransformCAdef) then
		(
			custAttributes.add hull hvkConvexDecomp_TransformCAdef
		)
		hull.hvkConvexDecomp_TransformCA.originalTransform = hull.pos
		if (hull.pos.x < minPoint.x) then (minPoint.x = hull.pos.x)
		if (hull.pos.y < minPoint.y) then (minPoint.y = hull.pos.y)
		if (hull.pos.z < minPoint.z) then (minPoint.z = hull.pos.z)
		if (hull.pos.x > maxPoint.x) then (maxPoint.x = hull.pos.x)
		if (hull.pos.y > maxPoint.y) then (maxPoint.y = hull.pos.y)
		if (hull.pos.z > maxPoint.z) then (maxPoint.z = hull.pos.z)
	)
	maxPoint-= minPoint
	local maxDim = maxPoint.x
	if (maxPoint.y > maxDim) then (maxDim = maxPoint.y)
	if (maxPoint.z > maxDim) then (maxDim = maxPoint.z)

	if (undefined == custAttributes.get origMesh hvkConvexDecomp_OrigMeshScaleCADef) then
	(
		custAttributes.add origMesh hvkConvexDecomp_OrigMeshScaleCADef
	)
	origMesh.hvkConvexDecomp_OrigMeshScaleCA.scale = maxDim

	return true
)

function hvkConvexDecomp_HideOriginalMesh mesh doHide =
(
	if (not isGroupHead mesh) then
	(
		if (doHide) then
		(
			hide mesh
		)
		else
		(
			unhide mesh
		)
	)
	else
	(
		local meshNodes = #()
		append meshNodes mesh

		if (doHide) then
		(
			hide mesh
		)
		else
		(
			unhide mesh
		)

		while (0 != meshNodes.count) do
		(
			local children = meshNodes[meshNodes.count].children
			deleteItem meshNodes meshNodes.count

			for child in children do
			(
				if (doHide) then
				(
					hide child
				)
				else
				(
					unhide child
				)

				if (isGroupHead child) then
				(
					append meshNodes child
				)
			)
		)
	)

	if (not doHide) then
	(
		selectMore mesh
	)
	return true
)















