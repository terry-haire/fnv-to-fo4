------------------------------------------------------------------------
-- ZENIMAX MEDIA PROPRIETARY INFORMATION
-- 
-- This software is developed and/or supplied under the terms of a license
-- or non-disclosure agreement with ZeniMax Media Inc. and may not be copied
-- or disclosed except in accordance with the terms of that agreement.
-- 
--   Copyright (c) 2010 ZeniMax Media Incorporated.
--   All Rights Reserved.
-- 
-- ZeniMax Media Incorporated, Rockville, Maryland 20850
-- http://www.zenimax.com
-- Owner: Paul Graber
------------------------------------------------------------------------

macroScript BSMergeVertexColors category:"Bethesda" buttonText:"MergeVertCols"
toolTip:"MergeVertCols - Scans each vertex in selected meshes, averaging the colors of any vertex with more than one color"
(
	on execute do
	(
		-- Toggle to print info about every vert with multiple colors
		local printVertInfo = false
		
		print ("\n")
		print ("---BSMergeVertexColors processing " + selection.count as string + " object(s)---")
		
		local startTime = timeStamp()
		
		for obj in selection do
		(
			print ("Processing: " + obj as string)
			local colorsMerged = false
			
			-- Vertex colors can only be changed on an editable object
			-- Since Editable_Mesh and Editable_Poly have their own functions, much of this code is doubled
			local numVerts = 0
			if(classof obj.baseobject == Editable_Mesh and
				(meshop.getMapSupport obj 0) and -- Map channel 0 = vertex colors
				(meshop.getNumCPVVerts obj > 0)) then
			(
				numVerts = meshop.getNumVerts obj
			)
			else if(classof obj.baseobject == Editable_Poly and 
				(polyop.getMapSupport obj 0) and -- Map channel 0 = vertex colors
				(polyop.getNumMapVerts obj 0) > 0) then
			(
				numVerts = polyop.getNumVerts obj
			)
			else
			(
				print ("\tBase object of " + obj as string + " is not an editable mesh or poly or has no vertex colors")
			)
			
			for vertIndex = 1 to numVerts do
			(
				-- Build array of face indices pointing to currently processing vertex
				local faceVertIndex = #()
				local vertFaces = #()
				
				if(classof obj.baseobject == Editable_Mesh) then
				(
					-- Meshes have 3 verts per face
					vertFaces = (meshop.getFacesUsingVert obj vertIndex) as array
					faceVertIndex[vertFaces.count] = -1
					for faceIndex = 1 to vertFaces.count do
					(
						local face = getFace obj vertFaces[faceIndex]
						if(face.x == vertIndex) then faceVertIndex[faceIndex] = 1
						else if(face.y == vertIndex) then faceVertIndex[faceIndex] = 2
						else if(face.z == vertIndex) then faceVertIndex[faceIndex] = 3
						else print ("ERROR: Face returned from getFacesUsingVert() that isn't using vert")
					)
				)
				else
				(
					-- Polys can have >3 verts per face
					vertFaces = (polyop.getFacesUsingVert obj vertIndex) as array
					faceVertIndex[vertFaces.count] = -1
					for faceIndex = 1 to vertFaces.count do
					(
						local face = polyop.getFaceVerts obj vertFaces[faceIndex]
						for currentVertIndex = 1 to face.count do
						(
							if(face[currentVertIndex] == vertIndex) then
								faceVertIndex[faceIndex] = currentVertIndex
						)
					)
				)
				
				-- Examine vertex color at each face's vert index
				if(faceVertIndex.count > 1) do
				(
					-- Get color associated with processing vertex at the first face
					local firstColor
					if(classof obj.baseobject == Editable_Mesh) then
						firstColor = getVertColor obj (getVCFace obj vertFaces[1])[faceVertIndex[1]]
					else
						firstColor = polyop.getMapVert obj 0 (polyop.getMapFace obj 0 vertFaces[1])[faceVertIndex[1]]
					
					local averagedColor = firstColor
					local differentColors = false
					
					-- Compare first color with rest of colors
					for faceIndex = 2 to vertFaces.count do
					(
						if(classof obj.baseobject == Editable_Mesh) then
							compareColor = getVertColor obj (getVCFace obj vertFaces[faceIndex])[faceVertIndex[faceIndex]]
						else
							compareColor = polyop.getMapVert obj 0 (polyop.getMapFace obj 0 vertFaces[faceIndex])[faceVertIndex[faceIndex]]
						
						differentColors = differentColors or (firstColor != compareColor)
						averagedColor += compareColor
					)
					
					-- If multiple vertex colors were found associated with the processing vertex, average the colors and re-assign them
					if(differentColors) do
					(
						colorsMerged = colorsMerged or differentColors
						averagedColor /= vertFaces.count
						
						if(printVertInfo) then
							print ("\tVertex" + vertIndex as string + " has " + vertFaces.count as string + " vertex colors being set to averaged color: " + averagedColor as string)
						
						if(classof obj.baseobject == Editable_Mesh) then
						(
							for faceIndex = 1 to vertFaces.count do
							(
								setVertColor obj (getVCFace obj vertFaces[faceIndex])[faceVertIndex[faceIndex]] averagedColor
							)
						)
						else
						(
							for faceIndex = 1 to vertFaces.count do
							(
								polyop.setMapVert obj 0 (polyop.getMapFace obj 0 vertFaces[faceIndex])[faceVertIndex[faceIndex]] averagedColor
							)
						)
					)
				)
			)
			
			if(numVerts > 0) then
				update obj
			
			if(colorsMerged) then
				print ("\tMultiple vertex colors per vertex found and merged on " + obj as string)
			else
				print ("\tNo vertex colors changed on " + obj as string)
		)
		
		print ("Processing took " + (timeStamp() - startTime) as string + " milliseconds")
	)
)
