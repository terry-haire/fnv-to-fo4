
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

bSave = getSaveRequired() 

include "Gamebryo/ConvertCAHelpers.ms"
Global GamebryoNumPlatforms = 2

-----------------------------------------------------------------------------
fn GetOldTextureExportData obj OldDef TempAttribute =
(
    bSuccess = true
	try
	(
        TempUseMasterIndexForAll = obj.UseMasterIndexForAll 
        TempMasterIndex	 = obj.MasterIndex
        TempFinalImageSize = obj.FinalImageSize  
        TempFinalImageQuality = obj.FinalImageQuality
        TempFilterMode  = obj.FilterMode 	
        TempMipMapMode  = obj.MipMapMode 			
        TempFileSettings = obj.FileSettings
	)
	catch 
	(
	    bSuccess = false
	    strMessage = "WARNING! Failed to convert Texture Export custom attributes on object: " + (obj.name as string)
        print strMessage
	)

	if bSuccess == true do
	(
	    DataHolder = #(obj, TempUseMasterIndexForAll, TempMasterIndex, TempFinalImageSize, TempFinalImageQuality, TempFilterMode,TempMipMapMode,TempFileSettings)
	    custAttributes.delete obj OldDef
	)
	
	if bSuccess == false do
	(
	    DataHolder = #(obj)
	)
	
	return DataHolder
)
-----------------------------------------------------------------------------
fn SetOldTextureExportData obj OldDataHolder NewCADef=
(
    if OldDataHolder == undefined or OldDataHolder.count == 1 then return false
    
	TempUseMasterIndexForAll = OldDataHolder[2] 
	TempMasterIndex	 = OldDataHolder[3]
	TempFinalImageSize = OldDataHolder[4]
	TempFinalImageQuality = OldDataHolder[5]
	TempFilterMode  = OldDataHolder[6]
	TempMipMapMode  = OldDataHolder[7]
	TempFileSettings = OldDataHolder[8]
	
	-- attribute definitions that are this old have xbox, gcn, ps2 settings
	-- we need to clear these settings and just keep PC now that we no longer support them
	custAttributes.add obj NewCADef
	obj.FinalImageSize[1] = TempFinalImageSize[1]

	-- we have ditched the 4-bit palette option, so the image quality numbers past it are
	-- off by one
	if (TempFinalImageQuality[1] == 6) then
		TempFinalImageQuality[1] = 5
	else if (TempFinalImageQuality[1] > 6) then
		TempFinalImageQuality[1] -= 1
		
    obj.FinalImageQuality[1] = TempFinalImageQuality[1]
    obj.FilterMode[1] = TempFilterMode[1]
    obj.MipMapMode[1] = TempMipMapMode[1]  
    obj.FileSettings[1] = TempFileSettings[1]

	for i = 2 to GamebryoNumPlatforms do
	(
		-- clear to default
	    obj.FinalImageSize[i] = 1
	    obj.FinalImageQuality[i] = 2
	    obj.FilterMode[i] = 2
	    obj.MipMapMode[i] = 2
	    obj.FileSettings[i] = 1
	)
	obj.UseMasterIndexForAll = TempUseMasterIndexForAll 
	obj.MasterIndex = 1
	return true
)
-----------------------------------------------------------------------------
fn HandleTexMapConversion =
(
    NewAttribID = #(0x88da7c45, 0x46542296)
    NewAttribName = "TextureExport"
    DefinedCA = undefined
    OldDefs = GetOldAttributeDefs NewAttribName NewAttribID

    if OldDefs != undefined do
    (
	    if OldDefs.count != 0 do
	    (
	        tempFunction = #(GetOldTextureExportData)
        	   
	        OldDataArray = GetOldDefsInAllMaterials NewAttribName NewAttribID tempFunction
        	   
	        if DefinedCA == undefined do
	        (
	   			include "Gamebryo/TextureExportCustAttribs.ms"
				DefinedCA = TextureExportCA 
	        )
        	   
	        for OldData in OldDataArray do
	        (
		        bSuccess = SetOldTextureExportData OldData[1] OldData DefinedCA
		        if bSuccess == true then bSave = true
	        )
        	   
        	CleanOldDefsByName NewAttribName
        	
	        theSlot = medit.GetActiveMtlSlot()
	        medit.SetActiveMtlSlot theSlot true
	    )
    )
)
-----------------------------------------------------------------------------
fn GetOldMipMapData obj OldDef TempAttribute =
(
    bSuccess = true
	try
	(
	    TempAutoGenMipMaps = obj.AutoGenMipMaps
        TempMipMaps = #(obj.MipMaps[1], obj.MipMaps[2], obj.MipMaps[3], obj.MipMaps[4], obj.MipMaps[5], obj.MipMaps[6], obj.MipMaps[7], obj.MipMaps[8], obj.MipMaps[9], obj.MipMaps[10], obj.MipMaps[11])
	)
	catch
	(
	    bSuccess = false
	    strMessage = "WARNING! Failed to convert Texture Mip-Map custom attributes on object: " + (obj.name as string)
        print strMessage
	)
	
	if bSuccess == true do
	(
	    DataHolder = #(obj, TempAutoGenMipMaps, TempMipMaps)
	    custAttributes.delete obj OldDef
	)
	
	if bSuccess == false do
	(
	    DataHolder = #(obj)
	)
	
	return DataHolder
)
-----------------------------------------------------------------------------
fn SetOldMipMapData obj OldDataHolder NewCADef=
(
    if OldDataHolder == undefined or OldDataHolder.count == 1 then return false
    
	TempAutoGenMipMaps = OldDataHolder[2] 
	TempMipMaps = OldDataHolder[3]
	
	custAttributes.add obj NewCADef
	obj.AutoGenMipMaps  = TempAutoGenMipMaps
	if TempMipMaps[1] != undefined then obj.MipMaps[1] = TempMipMaps[1]
	if TempMipMaps[2] != undefined then obj.MipMaps[2] = TempMipMaps[2]
	if TempMipMaps[3] != undefined then obj.MipMaps[3] = TempMipMaps[3]
	if TempMipMaps[4] != undefined then obj.MipMaps[4] = TempMipMaps[4]
	if TempMipMaps[5] != undefined then obj.MipMaps[5] = TempMipMaps[5]
	if TempMipMaps[6] != undefined then obj.MipMaps[6] = TempMipMaps[6]
	if TempMipMaps[7] != undefined then obj.MipMaps[7] = TempMipMaps[7]
	if TempMipMaps[8] != undefined then obj.MipMaps[8] = TempMipMaps[8]
	if TempMipMaps[9] != undefined then obj.MipMaps[9] = TempMipMaps[9]
	if TempMipMaps[10] != undefined then obj.MipMaps[10] = TempMipMaps[10]
	if TempMipMaps[11] != undefined then obj.MipMaps[11] = TempMipMaps[11]
	
	return true
)
-----------------------------------------------------------------------------
fn HandleMipMapConversion =
(
    NewAttribID = #(0x372fd1f6, 0x526fbdaf)
    NewAttribName = "MipMapPyramid"
    DefinedCA = undefined
    OldDefs = GetOldAttributeDefs NewAttribName NewAttribID

    if OldDefs != undefined do
    (
	    if OldDefs.count != 0 do
	    (
	        tempFunction = #(GetOldMipMapData)
        	   
	        OldDataArray = GetOldDefsInAllMaterials NewAttribName NewAttribID tempFunction
        	   
	        if DefinedCA == undefined do
	        (
	   		        include "Gamebryo/MipMapCustAttribs.ms"
			        DefinedCA = MipMapPyramidCA 
	        )
        	   
	        for OldData in OldDataArray do
	        (
		        bSuccess = SetOldMipMapData OldData[1] OldData DefinedCA
		        if bSuccess == true then bSave = true
	        )
    	    
	        --CleanOldDefsByName NewAttribName
        	   
	        theSlot = medit.GetActiveMtlSlot()
	        medit.SetActiveMtlSlot theSlot true
	    )
    )
)
-----------------------------------------------------------------------------
-- The following code will be executed automatically
-----------------------------------------------------------------------------

HandleTexMapConversion()
HandleMipMapConversion()
setSaveRequired bSave
if bSave == false then clearUndoBuffer()
