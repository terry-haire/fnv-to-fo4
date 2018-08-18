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
-- FILE:    BethesdaUtilsCA.ms
-- VERSION: 1.0
-- AUTHOR:  Mike Dulany
-- DATE:    09/19/2007
-- -------------------------------------------------------------------------

-- Checks to see if the attribute definition name is the same as the on passed
-- but the attribute id's differ.
fn IsOldDef Def AttribName AttribID =
(
	bret = false
	if ( Def.name == AttribName) and ( Def.attribID[1] != AttribID[1] ) and ( Def.attribID[2] != AttribID[2] ) then bret = true

	--str = "Comparing " + (Def.name as string) + " and " + ( AttribName as string ) + " with result " + (bret as string)
	--print str
	
	return bret
)
-----------------------------------------------------------------------------
-- Checks the scene for old attribute ID's and returns an array
-- of those found.
fn GetBSOldAttributeDefs AttribName AttribID = 
(
	oldDefs = #()
	defs = custAttributes.getSceneDefs () 
	for def in defs do
	(
		if IsOldDef def AttribName AttribID do
		(
			append oldDefs def
		)
	)
	return oldDefs
)
-----------------------------------------------------------------------------
fn GetOldBSAttributesData obj OldDef TempAttribute =
(
    oldBoneExport = undefined
    oldBonePriority = undefined
	
	--str = (obj as string) + " " + (OldDef.attribID[1] as string)
	--print str
	
	-- Note: we place the empty catch blocks so we can check for all versions of the attribute
	-- in this one function so all of the member vars may not be present.	
    try
    (   
	    tempValue = TempAttribute.boneExport
	    if tempValue != undefined then oldBoneExport = tempValue else oldBoneExport = true
    )
    catch
    (
		oldBoneExport = true
    )
	
	try 
	(
		tempValue = TempAttribute.bonePriority
	    if tempValue != undefined then oldBonePriority = tempValue else oldBonePriority = 0
	)	
    catch
    (
		oldBonePriority = 0
    )
	
    DataHolder = #(obj, oldBoneExport, oldBonePriority)

	return DataHolder
)
-----------------------------------------------------------------------------
fn SetOldBSAttributesData obj OldDataHolder NewCADef=
(
    if OldDataHolder == undefined or OldDataHolder.count == 1 then return false
    
	oldBoneExport = OldDataHolder[2] 
    oldBonePriority = OldDataHolder[3] 
    
    custAttributes.add obj NewCADef
	obj.boneExport = oldBoneExport
	obj.bonePriority = oldBonePriority
	return true
)
-----------------------------------------------------------------------------
fn GetOldDefsInObject obj AttribName AttribID GetFunction = 
(
    DefDataArray = #()
	if obj == undefined then return DefDataArray 
	
    iCount = custAttributes.count obj
    for i = 1 to iCount do
    (
	    cadef = custAttributes.getdef obj i 
	    if cadef != undefined do
	    (
		    bIsOldDef = IsOldDef cadef AttribName AttribID
			--str = "Object: " + (obj.name as string)-- + " Old def return " + (bIsOldDef as string)
			--print str
		    if bIsOldDef == true do
		    (
			    TempAttribute = custAttributes.get obj i
			    OldData = GetFunction[1] obj cadef TempAttribute
			    append DefDataArray OldData
		    )
	    )
    )
	
	-- It seems like a bad idea to be deleting CA's while looping through them
	-- so do that now.
	bAllCADeleted = false
	while not bAllCADeleted do
	(
		bAllCADeleted = true
		for i = 1 to ( custAttributes.count obj ) do
		(
			cadef = custAttributes.getdef obj i 
		    if cadef != undefined do
		    (
			    bIsOldDef = IsOldDef cadef AttribName AttribID			
				if ( bIsOldDef == true ) do
				(
					--str = "Deleting " + (cadef.name as string) + " from " + ( obj.name as string) + " is old def " + (bIsOldDef as string)
					--print str	
					custAttributes.delete obj cadef
					bAllCADeleted = false
					i = 1
				)
			)
		)
	)
    
    for child in obj.children do
    (
        OldDataArray = GetOldDefsInObject child AttribName AttribID GetFunction
        for OldData in OldDataArray do
	    (
		    append DefDataArray OldData
	    )
    )
    
    return DefDataArray
)
-----------------------------------------------------------------------------
fn GetOldDefsInScene AttribName AttribID GetFunction = 
(
   DefDataArray = #()
   
   	OldDataArray = GetOldDefsInObject rootNode AttribName AttribID GetFunction
	for OldData in OldDataArray do
	(
		append DefDataArray OldData
	)

   return DefDataArray
)
-----------------------------------------------------------------------------
fn CleanOldDefs AttribName AttribID =
(
    for def in custAttributes.getSceneDefs () do
    (
		bIsOldDef = IsOldDef def AttribName AttribID			
		if ( bIsOldDef == true ) do
		(	
    	    --str = "Deleting old def " + (def.name as string) + " " + (def.attribID[1] as string) + " " + (def.attribID[2] as string) + " " + ( bIsOldDef as string)
	        --print str		
	        try 
		        custAttributes.deleteDef def
	        catch 
	        ( 
	        )    
		)
    ) 
)
-----------------------------------------------------------------------------
fn HandleBSAttributeConversion =
(
	OldAttribID = #( #(0x042D1981, 0x41697837), #(0x480925DB, 0x69341C66) ) 
    NewAttribID = #(0x3f8718a1, 0x58c27b40)
    NewAttribName = "BSAttributes"
    DefinedCA = undefined

	-- See if there are any version of BSAttributes defined in scene
	-- that do not have the newest attribute ID.	
	OldDefs =  GetBSOldAttributeDefs NewAttribName NewAttribID
	
    if OldDefs != undefined do
    (
	    if OldDefs.count != 0 do
	    (
	        tempFunction = #(GetOldBSAttributesData)
			
	        OldDataArray = GetOldDefsInScene NewAttribName NewAttribID tempFunction

	        if DefinedCA == undefined do
	        (
	   			include "Gamebryo\BethesdaUtilsCA.ms"
				DefinedCA = BSAttributes
		    )
        	   
	        for OldData in OldDataArray do
	        (
				--print OldData[1]
		        SetOldBSAttributesData OldData[1] OldData DefinedCA
	        )
        	   
        	CleanOldDefs NewAttribName NewAttribID
	    )
    )
)

-----------------------------------------------------------------------------
-- The following code will be executed automatically
-----------------------------------------------------------------------------
HandleBSAttributeConversion()
