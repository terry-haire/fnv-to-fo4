
--
-- TOOLBAR
--
-- Sets up the buttons in the Havok Toolbar
-- This is not saved in the CUI file, so it needs to be executed
-- on startup

if (hkToolbarGUP != undefined) then
(
	-- Hide the toolbar to avoid flickering
	wasVisible = hkToolbarGUP.isVisible()
	hkToolbarGUP.hide()
	hkToolbarGUP.addMacro "Havok Vision" "mcrVision_nodeProperty"
	hkToolbarGUP.addMacro "Havok Vision" "mcrVision_prefabAutoExportOptions"
	hkToolbarGUP.addMacro "Havok Vision" "mcrVision_createPortalXY"
	hkToolbarGUP.addMacro "Havok Vision" "mcrVision_createPortalXZ"
	hkToolbarGUP.addMacro "Havok Vision" "mcrVision_createPortalYZ"
	hkToolbarGUP.addSeparator()
    hkToolbarGUP.addMacro "Havok Common" "mcrCommon_BatchExport"
	hkToolbarGUP.addMacro "Havok Common" "mcrCommon_Export"
	hkToolbarGUP.addMacro "Havok Common" "mcrCommon_OpenUtility"
    
	-- restore the toolbar
	if (wasVisible) then hkToolbarGUP.show()
)

--
-- MENU
--

function hvkCommon_createHavokMenu =
(
	local havokMenu = menuMan.createMenu "Havok Content Tools"
	
	local item = menuMan.createActionItem "mcrCommon_Export" "Havok Common" 
	havokMenu.addItem item -1
	local item = menuMan.createActionItem "mcrCommon_BatchExport" "Havok Common" 
	havokMenu.addItem item -1
	item = menuMan.createActionItem "mcrCommon_OpenUtility" "Havok Common" 
	havokMenu.addItem item -1
	item = menuMan.createActionItem "mcrCommon_ShowToolbar" "Havok Common"
	havokMenu.addItem item -1
	
	local havokHelpSubMenu = menuMan.createMenu "Help"
	item = menuMan.createActionItem "mcrCommon_OpenVideoBrowser"  "Havok Common"
	havokHelpSubMenu.addItem item -1
	item = menuMan.createActionItem "mcrCommon_OpenContentToolsChm"  "Havok Common"
	havokHelpSubMenu.addItem item -1
	
	local havokHelpSubMenuItem = menuMan.createSubMenuItem "Help" havokHelpSubMenu
	
	havokMenu.addItem havokHelpSubMenuItem -1
	
	local mainMenuBar = menuMan.getMainMenuBar()
	item = menuMan.createSubMenuItem "Havok Exporter" havokMenu
	-- Place the Havok menu just before "Help"
	local havokMenuIndex = mainMenuBar.numItems()
	mainMenuBar.addItem item havokMenuIndex
	
	menuMan.updateMenuBar()
)

function hvkCommon_repairHavokMenu =
(
	-- First we look for a Havok Menu, and remove it
	mainMenuBar = menuMan.getMainMenuBar()
	for i=1 to mainMenuBar.numItems() do
	(
		mItem = mainMenuBar.getItem i
		if (mItem.getTitle() == "Havok Content Tools") then
		(
			mainMenuBar.removeItemByPosition i
			exit
		)
	)
	
	-- Then we create it again
	hvkCommon_createHavokMenu()
)
			
 -- Sets up the Havok menu
-- This is saved in the CUI file, so it only needs to be done once
-- Check if the menu is there, otherwise
if menuMan.registerMenuContext 0x2800a03e then
(
	hvkCommon_createHavokMenu()
)
else
(
	hvkCommon_repairHavokMenu()
)
		