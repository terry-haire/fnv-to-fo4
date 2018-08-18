
-- Utilities used by the tools

fileIn "havokPhysics/ragdollTools/hvkTools_Globals.ms"

--
-- OBJECTS BOUNDING BOX : Returns the bounding box of a set of objects, built around a specified localTransform
--

function hvkBoneTools_getObjectsBoundingBox objectList localTransform noExpand:false = 
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
		desiredSize = currentSize * [hvkGlobal_boneScaleX, hvkGlobal_boneScaleY, hvkGlobal_boneScaleZ]
		
		expand = desiredSize - currentSize
		
		minOut = minOut - (expand * 0.5)
		maxOut = maxOut + (expand * 0.5)
	)
		
	return #(minOut, maxOut)
)


--
-- CREATE BOUNDING CAPSULE : Given a list of nodes and the associatedObject, creates a capsule around them
--
function hvkBoneTools_createBoundingCapsule objectList associated = 
(
	-- We want to create a capsule with only rotation and translation - no scale
	local objectTransform = associated.objectTransform
	
	local objRotM = objectTransform.rotation as Matrix3
	local objPosM = transMatrix  objectTransform.position
	local objNiceTM = objRotM * objPosM
		
	local boundingBox = hvkBoneTools_getObjectsBoundingBox objectList objNiceTM
		
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

--
-- CREATE BOUNDING BOX : Given a node, it creates a box that bounds it
--
function hvkBoneTools_CreateBoundingBox objectList associated = 
(
	-- We want to create a box with only rotation and translation - no scale
	local objectTransform = associated.objectTransform
	
	local objRotM = objectTransform.rotation as Matrix3
	local objPosM = transMatrix  objectTransform.position
	local objNiceTM = objRotM * objPosM
		
	local boundingBox = hvkBoneTools_getObjectsBoundingBox objectList objNiceTM
		
	-- Create box
	local newBox = Box()
	newBox.width = boundingBox[2][1] - boundingBox[1][1]
	newBox.length = boundingBox[2][2] - boundingBox[1][2]
	newBox.height = boundingBox[2][3] - boundingBox[1][3]

	-- Ensure the pivot point is in the center of the box (X and Y are, but Z is not)
	newBox.objectOffsetPos = [0,0, -newBox.height*0.5]
	
	-- And then move the box so it matches the bounding box
	local newTransform = objNiceTM
	local centerObj = (boundingBox[1] + boundingBox[2]) * 0.5
	newTransform.position = centerObj * objNiceTM

	newBox.transform = newTransform
	
	-- Set the color
	newBox.wirecolor = associated.wirecolor

	-- Finally, the two objects are aligned in world, now let's align their pivots
	hvkCommon_AlignPivotTo newBox associated false
	
	return newBox
)

--
-- ADD TERMINAL
--

function hvkBoneTools_addTerminal obj =
(
	-- We want to create a box with only rotation and translation - no scale
	local objTransform = obj.transform
	
	local objRotM = objTransform.rotation as Matrix3
	local objPosM = transMatrix  objTransform.position
	local objNiceTM = objRotM * objPosM

	local boundingBox = hvkBoneTools_getObjectsBoundingBox #(obj) objNiceTM noExpand:true
	local minBox = boundingBox[1]
	local maxBox = boundingBox[2]
	local centerBox = (minBox + maxBox) * 0.5
	local boxSize = maxBox-minBox
	
	-- find furthest side from 0,0,0
	local maxmax = -10000000
	local maxmaxaxis = -1
	local minmin = 10000000
	local minminaxis = -1
		
	for axis=1 to 3 do
	(
		if maxBox[axis]>maxmax then
		(
			maxmaxaxis = axis
			maxmax = maxBox[axis]
		)
		
		if minBox[axis]<minmin then
		(
			minminaxis = axis
			minmin = minBox[axis]
		)
	)
		
	local terminalPos = centerBox	
	if (abs(maxmax) > abs(minmin)) then
	(
		terminalPos [maxmaxaxis] = maxmax
	)
	else
	(
		terminalPos [minminaxis] = minmin
	)
	
	terminalPos = terminalPos * objNiceTM
	
	terminal = Point()
	terminal.position = terminalPos
	terminal.parent = obj
	terminal.size = (boxSize[1] + boxSize[2] + boxSize[3]) * 0.4
	terminal.wirecolor = color 255 255 255
	hvkCustomizable_renameNewTerminal terminal obj
		
	return terminal
)
