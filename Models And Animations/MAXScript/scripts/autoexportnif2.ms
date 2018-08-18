actionMan.executeAction 0 "40010"  -- File: Import File
	actionMan.executeAction 0 "40021"  -- Selection: Select All
	namesArray = for s in selection collect s.name
	maxOps.cloneNodes (selection as array) cloneType:#copy newNodes:&nnl #nodialog
	--Loop through the array of object it returns
	thePrefix = "c_"
	for i = 1 to nnl.count do
	(
	    --rename the objects to a unique name
	    nnl[i].name = thePrefix + namesArray[i]
	obj = getnodebyname nnl[i].name
	if obj != undefined then select obj
	obj2 = getnodebyname namesArray[i]
	if obj2 != undefined then selectmore obj2
	macros.run "Havok Physics" "mcrPhysics_createRigidBodyWithProxy"
	selection[1].modifiers[#Rigid_Body].mass = 60
	if obj != undefined then select obj
	selection[1].modifiers[#Shape].shapeType = 5
	)
	--max utility mode
	--selection[1].modifiers[#Rigid_Body].mass = 60