
--
-- CHECK CONVEX DECOMPOSITION DLL
--


function checkConvexDecompDll =
(
	try
		fileIn "havokConvexDecomp/convexDecompositionTools/hvkConvexDecomp_Tools.ms"
	catch
	(
		-- The physics product is not present
		return false
	)
	
	if ( undefined != hkConvexDecompUtility ) then
	(
		if ( undefined != hkConvexDecompUtility.checkValidity ) then
		(
			if ( hkConvexDecompUtility.checkValidity() ) then
			(
				return true
			)
		)
	)

	-- The physics product is present, but the keycode is invalid or the convex decomp dll could not be loaded
	return false
)

isConvexDecompDllOk = checkConvexDecompDll()

--
-- TOOLBAR
--

if (hkToolbarGUP != undefined) then
(
	-- Hide the toolbar to avoid flickering
	wasVisible = hkToolbarGUP.isVisible()
	hkToolbarGUP.hide()
	hkToolbarGUP.addSeparator()
    hkToolbarGUP.addMacro "Havok Physics" "mcrPhysics_removeHavokData"
    hkToolbarGUP.addSeparator()
	hkToolbarGUP.addMacro "Havok Physics" "mcrPhysics_createSingleRigidBody"
	hkToolbarGUP.addMacro "Havok Physics" "mcrPhysics_createCompoundRigidBody"
	hkToolbarGUP.addMacro "Havok Physics" "mcrPhysics_createBallAndSocketConstraint"
	hkToolbarGUP.addMacro "Havok Physics" "mcrPhysics_createHingeConstraint"
	hkToolbarGUP.addMacro "Havok Physics" "mcrPhysics_createRagdollConstraint"
	hkToolbarGUP.addMacro "Havok Physics" "mcrPhysics_createStiffSpringConstraint"
	hkToolbarGUP.addMacro "Havok Physics" "mcrPhysics_createPrismaticConstraint"
	hkToolbarGUP.addMacro "Havok Physics" "mcrPhysics_createWheelConstraint"
	hkToolbarGUP.addMacro "Havok Physics" "mcrPhysics_createFixedConstraint"
	hkToolbarGUP.addMacro "Havok Physics" "mcrPhysics_createLocalFrame"
    hkToolbarGUP.addMacro "Havok Physics" "mcrPhysics_openRagdollTools"
	hkToolbarGUP.addMacro "Havok Physics" "mcrPhysics_openConvexHullUtility"
	hkToolbarGUP.addMacro "Havok Physics" "mcrPhysics_openCgoUtility"
	
	-- Add convex decomp macro if dll and keycode are valid
	if ( isConvexDecompDllOk ) then
	(
		hkToolbarGUP.addMacro "Havok Physics" "mcrPhysics_openConvexDecompUtility"
	)
        
    hkToolbarGUP.addSeparator()
	
	-- restore the toolbar
	if (wasVisible) then hkToolbarGUP.show()
)



--
-- MENU
-- 

function hvkPhysics_createHavokPhysicsMenu =
(
	local physicsMenu = menuMan.createMenu "Physics"
 	
	local item = menuMan.createActionItem "mcrPhysics_createSingleRigidBody"  "Havok Physics"
	physicsMenu.addItem item -1
	item = menuMan.createActionItem "mcrPhysics_createCompoundRigidBody" "Havok Physics"
	physicsMenu.addItem item -1
	local item = menuMan.createActionItem "mcrPhysics_createRigidBodyWithProxy"  "Havok Physics"
	physicsMenu.addItem item -1
	local item = menuMan.createActionItem "mcrPhysics_createCapsule"  "Havok Physics"
	physicsMenu.addItem item -1
	item = menuMan.createSeparatorItem()
	physicsMenu.addItem item -1
	item = menuMan.createActionItem "mcrPhysics_openRagdollTools" "Havok Physics"
	physicsMenu.addItem item -1
	item = menuMan.createSeparatorItem()
	physicsMenu.addItem item -1
	item = menuMan.createActionItem "mcrPhysics_createBallAndSocketConstraint" "Havok Physics"
	physicsMenu.addItem item -1
	item = menuMan.createActionItem "mcrPhysics_createHingeConstraint" "Havok Physics"
	physicsMenu.addItem item -1
	item = menuMan.createActionItem "mcrPhysics_createRagdollConstraint" "Havok Physics"
	physicsMenu.addItem item -1
	item = menuMan.createActionItem "mcrPhysics_createStiffSpringConstraint" "Havok Physics"
	physicsMenu.addItem item -1
	item = menuMan.createActionItem "mcrPhysics_createPrismaticConstraint" "Havok Physics"
	physicsMenu.addItem item -1
	item = menuMan.createActionItem "mcrPhysics_createWheelConstraint" "Havok Physics"
	physicsMenu.addItem item -1
	item = menuMan.createActionItem "mcrPhysics_createFixedConstraint" "Havok Physics"
	physicsMenu.addItem item -1
	item = menuMan.createSeparatorItem()
	physicsMenu.addItem item -1
	local item = menuMan.createActionItem "mcrPhysics_openConvexHullUtility" "Havok Physics"
	physicsMenu.addItem item -1
	local item = menuMan.createActionItem "mcrPhysics_openCgoUtility" "Havok Physics"
	physicsMenu.addItem item -1
	item = menuMan.createSeparatorItem()
	physicsMenu.addItem item -1
	local item = menuMan.createActionItem "mcrPhysics_createLocalFrame" "Havok Physics"
	physicsMenu.addItem item -1
	item = menuMan.createSeparatorItem()
	physicsMenu.addItem item -1

	-- Add convex decomp macro if dll and keycode are valid
	if ( isConvexDecompDllOk ) then
	(
		local item = menuMan.createActionItem "mcrPhysics_openConvexDecompUtility" "Havok Physics"
		physicsMenu.addItem item -1
		item = menuMan.createSeparatorItem()
		physicsMenu.addItem item -1
	)

	local mainMenuBar = menuMan.getMainMenuBar()

	for i=1 to mainMenuBar.numItems() do
	(
		mItem = mainMenuBar.getItem i
		if (mItem.getTitle() == "Havok Content Tools") then
		(
			item = menuMan.createSeparatorItem()
			(mItem.getSubMenu()).addItem item -1
			
			item = menuMan.createActionItem "mcrPhysics_removeHavokData" "Havok Physics"
			(mItem.getSubMenu()).addItem item -1

			item = menuMan.createSeparatorItem()
			(mItem.getSubMenu()).addItem item -1

			item = menuMan.createSubMenuItem "Havok Physics" physicsMenu
			(mItem.getSubMenu()).addItem item -1
		)
	)

	menuMan.updateMenuBar()
)

function hvkPhysics_repairHavokPhysicsMenu =
(
	hvkCommon_repairHavokMenu()
	hvkPhysics_createHavokPhysicsMenu()
)

if menuMan.registerMenuContext 0x2800a038 then
(
	hvkPhysics_createHavokPhysicsMenu()
)
else
(
	hvkPhysics_repairHavokPhysicsMenu()
)
