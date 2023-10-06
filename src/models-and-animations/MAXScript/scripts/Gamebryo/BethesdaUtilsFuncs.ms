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
-- FILE:    BethesdaUtilsFuncs.ms
-- VERSION: 1.0
-- AUTHOR:  Mike Dulany
-- DATE:    11/20/2006
-- -------------------------------------------------------------------------

-- Summary: Macroscript which adds the BSAttribute to all selected nodes.
macroScript AddBSAttribute
category:"Bethesda Utilities Apply Attribute" 
tooltip:"Apply Bethesda Attribute" 
(
	on execute do for obj in selection do 
	(
		local hasBSAttr = false
		
		--if object has custom attributes		
		if (custAttributes.count obj != 0) do 
		(
			--loop through cust attributes definitions looking for BSAttribute		
			for objDef in (custAttributes.getDefs obj) do
			(
				if (objDef.name == "BSAttributes") do 
				(
					hasBSAttr = true
				)
			)
		)

		--if the object does not have the attribute then add it
		if (hasBSAttr == false) do
		(
			custAttributes.add obj BSAttributes
		)
	)
)

-- Summary: Macroscript which removes the BSAttribute from all selected nodes.
macroScript RemoveBSAttribute
category:"Bethesda Utilities Apply Attribute" 
tooltip:"Remove Bethesda Attribute" 
(
	--for each object selected
	on execute do for obj in selection do 
	(
		local hasBSAttr = false
		local bsAttrDef
		
		--if object has custom attributes
		if (custAttributes.count obj != 0) do 
		(
			--loop through cust attributes definitions looking for BSAttribute
			for objDef in (custAttributes.getDefs obj) do
			(
				if (objDef.name == "BSAttributes") do 
				(
					hasBSAttr = true
					bsAttrDef= objDef 
				)
			)
		)
		
		--if the object has the attribute then remove it
		if (hasBSAttr == true) do
		(
			custAttributes.delete obj bsAttrDef
		)
	)
)