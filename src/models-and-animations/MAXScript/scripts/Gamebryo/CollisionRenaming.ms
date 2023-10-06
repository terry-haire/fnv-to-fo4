-- EMERGENT GAME TECHNOLOGIES PROPRIETARY INFORMATION
--
-- This software is supplied under the terms of a license agreement or
-- nondisclosure agreement with Emergent Game Technologies and may not
-- be copied or disclosed except in accordance with the terms of that
-- agreement.
--
--      Copyright (c) 1996-2006 Emergent Game Technologies.
--      All Rights Reserved.
--
-- Emergent Game Technologies, Chapel Hill, North Carolina 27517
-- http://www.emergent.net
-----------------------------------------------------------------------------
-- Converts old style collision parameters
-- to new style.

HaveUserPermission = false
for obj in objects do
(
	if obj != undefined do
	(
		objname = obj.name as string
		iABVIndex = findstring objname "ABV"
		if iABVIndex == 1 do
		(	
		    -- The first time, we warn the user what we
			-- are about to do and give them the option
			-- to bail out.
			if HaveUserPermission == false then
			(
				HaveUserPermission = \
					 queryBox "Collision Data was found and needs to be converted. The conversion process will modify the names of nodes tagged for collision to fit with the most recent specification. Do you wish to perform this conversion?"  \
					 title:"Convert Collision Data" beep:true
					 
				if HaveUserPermission == false then
					exit -- We don't have users permission	 
			)
				
		
			-- Index 5,6,7 is old style parameters
			-- for example BnC, BnN, HnN, SnC, etc...
			
			-- Translation to new style parameters is
			-- dependent on 3rd parameter (index 7)
			
			if objname[7] == "N" do
			(
				-- NONE changes to NEVER propagate
				newparams = objname[5] + "N"
				objname = replace objname 5 3 newparams 				
				objname = replace objname 1 3 "NDLCD"
				obj.name = objname
				continue
			)
	
			if objname[7] == "O" do
			(
				-- USE_OBB changes to ON_SUCCESS propagation
				newparams = objname[5] + "S"
				objname = replace objname 5 3 newparams 				
				objname = replace objname 1 3 "NDLCD"
				obj.name = objname
    			continue		
			)

			if objname[7] == "C" do
			(
				-- CONTINUE changes to ALWAYS propagate
				newparams = objname[5] + "A"
				objname = replace objname 5 3 newparams 				
				objname = replace objname 1 3 "NDLCD"
				obj.name = objname
    			continue		
			)
			
			if objname[7] == "X" do
			(
				-- NO_TEST changes to
                -- NEVER propagate with NOTEST flag
				newparams = "NN"
				objname = replace objname 5 3 newparams 				
				objname = replace objname 1 3 "NDLCD"
				obj.name = objname
    			continue		
			)
			
			if objname[7] == "T" do
			(
				-- USE_TRI changes to 
                -- TRI with NEVER propagate
				newparams = "TN"
				objname = replace objname 5 3 newparams 				
				objname = replace objname 1 3 "NDLCD"
				obj.name = objname
    			continue		
			)			
		)
	)
)