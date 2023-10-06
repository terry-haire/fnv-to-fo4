
--
-- TOOLBAR
--

if (hkToolbarGUP != undefined) then
(
	-- Hide the toolbar to avoid flickering
	wasVisible = hkToolbarGUP.isVisible()
	hkToolbarGUP.hide()
	hkToolbarGUP.addMacro "Havok Cloth" "mcrCloth_meshChannelToolbox"
	hkToolbarGUP.addMacro "Havok Cloth" "mcrCloth_createClothCollidable"
	hkToolbarGUP.addMacro "Havok Cloth" "mcrCloth_openBoneCollidableTools"
	hkToolbarGUP.addMacro "Havok Cloth" "mcrCloth_openBonesFromMeshUtility"
	
	
	-- restore the toolbar
	if (wasVisible) then hkToolbarGUP.show()
)  
 

  
--  
-- MENU      
--        
       
function hvkCloth_createHavokClothMenu =     
(    
	local clothMenu = menuMan.createMenu "Cloth" 
 	   
	local item = menuMan.createActionItem "mcrCloth_meshChannelToolbox"  "Havok Cloth"
	ClothMenu.addItem item -1
	local item = menuMan.createActionItem "mcrCloth_createClothCollidable"  "Havok Cloth"
	ClothMenu.addItem item -1   
	item = menuMan.createActionItem "mcrCloth_openBoneCollidableTools" "Havok Cloth"
	ClothMenu.addItem item -1
	item = menuMan.createActionItem "mcrCloth_openBonesFromMeshUtility" "Havok Cloth"
	ClothMenu.addItem item -1
		      
	local mainMenuBar = menuMan.getMainMenuBar() 
      
	for i=1 to mainMenuBar.numItems() do    
	(    
		mItem = mainMenuBar.getItem i      
		if (mItem.getTitle() == "Havok Content Tools") then   
		(         
			item = menuMan.createSeparatorItem()    
			(mItem.getSubMenu()).addItem item -1      
    
			item = menuMan.createSubMenuItem "Havok Cloth" clothMenu  
			(mItem.getSubMenu()).addItem item -1   
		)
	)     
    
	menuMan.updateMenuBar()     
)  
  
function hvkCloth_repairHavokClothMenu = 
(  
	hvkPhysics_repairHavokPhysicsMenu() 
	hvkCloth_createHavokClothMenu()
)   

if menuMan.registerMenuContext 0x2800a038 then
( 
	hvkCloth_createHavokClothMenu() 
)
else
(    
	hvkCloth_repairHavokClothMenu() 
)   
        