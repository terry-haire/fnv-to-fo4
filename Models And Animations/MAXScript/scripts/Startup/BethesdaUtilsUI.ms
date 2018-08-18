-- -------------------------------------------------------------------------
-- ZENIMAX MEDIA PROPRIETARY INFORMATION
-- 
-- This software is developed and/or supplied under the terms of a license
-- or non-disclosure agreement with ZeniMax Media Inc. and may not be copied
-- or disclosed except in accordance with the terms of that agreement.
-- 
--   Copyright (c) 2006 ZeniMax Media Incorporated.
--   All Rights Reserved.
-- 
-- ZeniMax Media Incorporated, Rockville, Maryland 20850
-- http://www.zenimax.com
-- 
-- FILE:    BethesdaUtilsUI.ms
-- VERSION: 1.0
-- AUTHOR:  Mike Dulany
-- DATE:    11/17/2006
-- -------------------------------------------------------------------------

fileIn "Gamebryo/BethesdaUtilsCA.ms"
fileIn "Gamebryo/BethesdaUtilsFuncs.ms"


function createBethUtilsMenu =
(
	-- Get the main menu bar
	local mainMenuBar = menuMan.getMainMenuBar()

	-- Create a new menu
	local subMenu = menuMan.createMenu "Bethesda Utils"
	
	-- create the "Add BSAttribute" menu item
	local addBSAttrItem = menuMan.createActionItem "AddBSAttribute" "Bethesda Utilities Apply Attribute"
	subMenu.addItem addBSAttrItem -1
	addBSAttrItem.setUseCustomTitle true
	addBSAttrItem.setTitle "Apply BSAttribute"
	
	-- create the "Remove BSAttribute" menu item
	local remBSAttrItem = menuMan.createActionItem "RemoveBSAttribute" "Bethesda Utilities Apply Attribute"
	subMenu.addItem remBSAttrItem -1
	remBSAttrItem.setUseCustomTitle true
	remBSAttrItem.setTitle "Remove BSAttribute"	
	
 	-- Create a new menu item with the menu as it's sub-menu
	local subMenuItem = menuMan.createSubMenuItem "Bethesda Utils" subMenu

	-- compute the index of the next-to-last menu item in the main menu bar
	local subMenuIndex = mainMenuBar.numItems() - 1

	-- Add the sub-menu just at the second to last slot
	mainMenuBar.addItem subMenuItem subMenuIndex

	-- redraw the menu bar with the new item
	menuMan.updateMenuBar()
)

if menuMan.registerMenuContext 0x1ee76a1e then
(
	createBethUtilsMenu() 
)
else
(
	-- First we look for a Menu, and remove it
	mainMenuBar = menuMan.getMainMenuBar()
	for i=1 to mainMenuBar.numItems() do
	(
		mItem = mainMenuBar.getItem i
		if (mItem.getTitle() == "Bethesda Utils") then
		(
			mainMenuBar.removeItemByPosition i
			exit
		)
	)
	
	-- Then we create it again
	createBethUtilsMenu()
)


callbacks.addScript #filepostopen filename:"Gamebryo\\BSAttributeConversion.ms" id:#ConvertBSAttribute persistent:false
 
