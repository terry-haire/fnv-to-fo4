
-- Utilities used by the tools

fileIn "havokCloth/boneCollidableTools/hvkBoneCollidableTools_Globals.ms"

--
-- OBJECTS BOUNDING BOX : Returns the bounding box of a set of objects, built around a specified localTransform
--

function hvkBoneCollidableBoneTools_getObjectsBoundingBox objectList localTransform noExpand:false = 
(
	local minOut = [1000000000, 100000000, 10000000]
	local maxOut = [-1000000000, -100000000, -10000000]

	for obj in objectList do
	(
		local objectTransform = obj.objectTransform
		
		-- we transform the points by the object transform and then make them relative to the specified localtransform
		local meshTransform = objectTransform * (Inverse localTransform)
		
		theMesh = obj.mesh
		
		for theVertex in theMesh.verts do
		(
			local p = theVertex.pos * meshTransform
			if (p.x > maxOut.x) then maxOut.x = p.x
			if (p.y > maxOut.y) then maxOut.y = p.y
			if (p.z > maxOut.z) then maxOut.z = p.z
			if (p.x < minOut.x) then minOut.x = p.x
			if (p.y < minOut.y) then minOut.y = p.y
			if (p.z < minOut.z) then minOut.z = p.z		
		)
	)
	
	-- Expand the bounding box by a user-specified amount
	
	if (not noExpand) then
	(
		currentSize = maxOut-minOut
		desiredSize = currentSize * [hvkGlobal_boneCollidableScaleX, hvkGlobal_boneCollidableScaleY, hvkGlobal_boneCollidableScaleZ]
		
		expand = desiredSize - currentSize
		
		minOut = minOut - (expand * 0.5)
		maxOut = maxOut + (expand * 0.5)
	)
		
	return #(minOut, maxOut)
)


--
-- CREATE BOUNDING CAPSULE : Given a list of nodes and the associatedObject, creates a capsule around them
--
function hvkBoneCollidableBoneTools_createBoundingCapsule objectList associated = 
(
	-- We want to create a capsule with only rotation and translation - no scale
	local objectTransform = associated.objectTransform
	
	local objRotM = objectTransform.rotation as Matrix3
	local objPosM = transMatrix  objectTransform.position
	local objNiceTM = objRotM * objPosM
		
	local boundingBox = hvkBoneCollidableBoneTools_getObjectsBoundingBox objectList objNiceTM
		
	-- Look for the two longest axis in the box
	local longestAxis = -1
	local longestLength = -1
	local secondAxis = -1
	local secondLength = -1
	for axis = 1 to 3 do
	(
		local len = boundingBox[2][axis] - boundingBox[1][axis]
		if (len > longestLength) then
		(
			secondAxis = longestAxis
			secondLength = longestLength
			longestAxis = axis
			longestLength = len
		)
		else
		(
			if (len > secondLength) then
			(
				secondAxis = axis
				secondLength = len
			)
		)
	)
	
	-- Create capsule : longest axis is its height, second longest its diameter
	
	local newCapsule = TaperCapsule ()
	newCapsule.radius = 0.5 * secondLength
	newCapsule.taper = 1.0;
	newCapsule.height = longestLength - 0.5*(secondLength + secondLength*newCapsule.taper);
	
	-- Ok, now we have to align them; it's kinda tricky
	
	-- Start by moving the pivot of the new capsule to its center 
	-- We need to rotate to match the long axis (default is Z) and also move the pivot to the center (don't need to do it for TaperedCapsule)
	if (longestAxis == 1) then --X
	(
		newCapsule.objectOffsetRot = (angleaxis -90 [0,1,0])
	)
	if (longestAxis == 2) then --Y
	(
		newCapsule.objectOffsetRot = (angleaxis 90 [1,0,0])
	)
	
	-- And then move the capsule so it matches the box
	local newTransform = objNiceTM
	local centerObj = (boundingBox[1] + boundingBox[2]) * 0.5
	newTransform.position = centerObj * objNiceTM

	newCapsule.transform = newTransform
	
	-- Set the color
	newCapsule.wirecolor = associated.wirecolor
	
	-- Finally, the two objects are aligned in world, now let's align their pivots
	hvkCommon_AlignPivotTo newCapsule associated false
	
	return newCapsule
)	


