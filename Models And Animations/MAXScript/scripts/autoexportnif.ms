
	actionMan.executeAction 0 "40010"  -- File: Import File
	meditMaterials[1] = Standardmaterial ()
	actionMan.executeAction 0 "40021"  -- Selection: Select All
--	objName = "D:\\Games\Fallout New Vegas\FNVExtracted\BaseGameAndDLC\meshes\architecture\strip\\" + selection[1].name + ".obj"
	--obj = getnodebyname selection[1].name
	--if obj != undefined then select obj
--	importFile objName #noPrompt
--	actionMan.executeAction 0 "40021"  -- Selection: Select All
--	--clone the selected objects
	thePrefix = "c_"
	for i = 1 to selection.count do
	(
		selection[i].name = "c_" + selection[i].name
	)
--	namesArray = for s in selection collect s.name
--	maxOps.cloneNodes (selection as array) cloneType:#copy newNodes:&nnl #nodialog
--	--Loop through the array of object it returns
--	for i = 1 to nnl.count do
--	(
--	    --rename the objects to a unique name
--	    nnl[i].name = thePrefix + namesArray[i]
--	)
	actionMan.executeAction 0 "40010"  -- File: Import File
--    fn selectLastCreatedObj = 
--    (
--    	objID = amax (for o in objects collect o.inode.handle) 
--    	select (maxOps.getNodeByHandle objID)
--    )
--	selection[1].name = "c_" + selection[1].name
	actionMan.executeAction 0 "40021" -- Selection: Select All
	macros.run "Havok Physics" "mcrPhysics_createRigidBodyWithProxy"
	selection[1].modifiers[#Rigid_Body].mass = 60
	actionMan.executeAction 0 "40021" -- Selection: Select All
	for i = 2 to selection.count do
	(
		selection[i].modifiers[#Shape].shapeType = 5
	)
--	modPanel.setCurrentObject objects[1].modifiers[#Rigid_Body]
--	modPanel.setCurrentObject objects[1].modifiers[#Shape]
--	objects[1].modifiers[#Shape].shapeType = 6
	-- collisiongroup
