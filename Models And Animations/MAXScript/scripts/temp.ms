(
	fn CorrectBorderVerts =
	(
		obj = getNodeByName "Land" --create a Sphere
		verts = #()
		for v = 1 to getNumVerts obj do --loop through all vertices
		(
			local vert = getVert obj v --get the v-th vertex
			if  ((vert.x == obj.max.x) or (vert.x == obj.min.x) or (vert.y == obj.max.y) or (vert.y == obj.min.y)) then
				append verts v
			--vert.z = 0.0 --change the Z coordinate to 0.0
			--setVert obj v vert --assign back to the v-thvertex
		)
		for i = verts.count to 1 by -1 do
		(
			vert = getVert obj verts[i]
			for j = 1 to verts.count do
			(
				vert2 = getVert obj verts[j]
				if ((vert.x == vert2.x) and (vert.y == vert2.y)) then
				(
					if vert.z < vert2.z then setVert obj verts[i] vert.x vert.y (vert2.z - 250)
					--else setVert obj verts[j] vert2.x vert2.y (vert.z - 250)
				)
			)
		)
		update obj --update the mesh - the sphere should be flattened
	)
	
	fn GetBorderVerts =
	(
		obj = getNodeByName "Land" --create a Sphere
		i = (getVert obj 1).x
		for v = 1 to getNumVerts obj do --loop through all vertices
		(
			vert = getVert obj v --get the v-th vertex
			--print(vert.x as string)
			if vert.x > i then
				i = vert.x
		)
		i
	)
	
	fn DeleteLowVerts =
	(
		obj = getNodeByName "Land" --create a Sphere
		local borderPos = obj.min.z
		verts = #()
		for v = getNumVerts obj to 1 by -1 do
		(
			local vert = getVert obj v --get the v-th vertex
			if vert.z == borderPos then deleteVert obj v
			--vert.z = 0.0 --change the Z coordinate to 0.0
			--setVert obj v vert --assign back to the v-thvertex
		)
		update obj
	)
	
	fn MoveLowVerts =
	(
		local obj = getNodeByName "Land" --create a Sphere
		local borderPos = obj.min.z
		local verts = #()
		for v = getNumVerts obj to 1 by -1 do
		(
			local vert = getVert obj v --get the v-th vertex
			if vert.z == borderPos then
			(
				for j = 1 to getNumVerts obj do
				(
					local vert2 = getVert obj j
					if ((vert.x == vert2.x) and (vert.y == vert2.y)) then
					(
						if vert.z < vert2.z then setVert obj v vert.x vert.y (vert2.z - 500)
						--else setVert obj verts[j] vert2.x vert2.y (vert.z - 250)
					)
				)
			)
			--vert.z = 0.0 --change the Z coordinate to 0.0
			--setVert obj v vert --assign back to the v-thvertex
		)
		update obj
	)
	
	--DeleteLowVerts()
	$.name = "Land"
	MoveLowVerts()
	--CorrectBorderVerts()
	--i = GetBorderVerts()
	--messageBox(i as string)
	obj = $ --create a Sphere
	ConvertToPoly obj
	--delete (#Edge ((polyOp.getOpenEdges obj) as bitarray))
	--obj.EditablePoly.SetSelection #Edge ((polyOp.getOpenEdges obj) as bitarray)
	--delete selection
	
	obj.EditablePoly.SetSelection #Edge ((polyOp.getOpenEdges obj) as bitarray)
)