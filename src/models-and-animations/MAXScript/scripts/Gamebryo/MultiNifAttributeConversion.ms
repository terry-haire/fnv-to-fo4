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

-----------------------------------------------------------------------------
fn GetOldMultiNifData obj OldDef TempAttribute =
(
    bSuccess = true
    TempMultiNifExportUseGlobalSettings = undefined
    TempMultiNifExportFileName = undefined
    TempMultiNifExportUseObjectName = undefined
	TempMultiNifExportDeleteAfterExport = undefined
	TempMultiNifExportRepairEmitterWithoutParticles = undefined
	TempMultiNifExportTranslateType = undefined
    TempMultiNifExportRotateType = undefined
    TempMultiNifExportScaleType = undefined
        
    try
    (
        tempValue = NiGetCustAttrib obj "MultiNifExportUseGlobalSettings"
	    if tempValue != undefined then TempMultiNifExportUseGlobalSettings = tempValue
						
		tempValue = NiGetCustAttrib obj "MultiNifExportFileName"
	    if tempValue != undefined then TempMultiNifExportFileName = tempValue
		
		tempValue = NiGetCustAttrib obj "MultiNifExportUseObjectName"
	    if tempValue != undefined then TempMultiNifExportUseObjectName = tempValue
		
		tempValue = NiGetCustAttrib obj "MultiNifExportDeleteAfterExport"
	    if tempValue != undefined then TempMultiNifExportDeleteAfterExport = tempValue
		
		tempValue = NiGetCustAttrib obj "MultiNifExportRepairEmitterWithoutParticles"
	    if tempValue != undefined then TempMultiNifExportRepairEmitterWithoutParticles = tempValue
		
		tempValue = NiGetCustAttrib obj "MultiNifExportTranslateType"
	    if tempValue != undefined then TempMultiNifExportTranslateType = tempValue
        
        tempValue = NiGetCustAttrib obj "MultiNifExportRotateType"
	    if tempValue != undefined then TempMultiNifExportRotateType = tempValue

        tempValue = NiGetCustAttrib obj "MultiNifExportScaleType"
	    if tempValue != undefined then TempMultiNifExportScaleType = tempValue
    )
    catch
    (
        bSuccess = false
        strMessage = "WARNING! Failed to convert Multi-Nif custom attributes on object: " + (obj.name as string)
        print strMessage
    )

	if bSuccess == true do
	(
        DataHolder = #(obj, TempMultiNifExportUseGlobalSettings, TempMultiNifExportFileName, TempMultiNifExportUseObjectName, TempMultiNifExportDeleteAfterExport, TempMultiNifExportRepairEmitterWithoutParticles, TempMultiNifExportTranslateType, TempMultiNifExportRotateType, TempMultiNifExportScaleType)
	    custAttributes.delete obj OldDef
	)
	
	if bSuccess == false do
	(
	    DataHolder = #(obj)
	)
	
	return DataHolder
)
-----------------------------------------------------------------------------
fn SetOldMultiNifData obj OldDataHolder NewCADef=
(
    if OldDataHolder == undefined or OldDataHolder.count == 1 then return false
    
	TempMultiNifExportUseGlobalSettings = OldDataHolder[2] 
    TempMultiNifExportFileName = OldDataHolder[3] 
    TempMultiNifExportUseObjectName  = OldDataHolder[4] 
    TempMultiNifExportDeleteAfterExport = OldDataHolder[5] 
    TempMultiNifExportRepairEmitterWithoutParticles = OldDataHolder[6] 
    TempMultiNifExportTranslateType	 = OldDataHolder[7] 
    TempMultiNifExportRotateType = OldDataHolder[8] 
    TempMultiNifExportScaleType  = OldDataHolder[9] 
    
    custAttributes.add obj NewCADef
	obj.MultiNifExportUseGlobalSettings = TempMultiNifExportUseGlobalSettings
	obj.MultiNifExportFileName = TempMultiNifExportFileName
	obj.MultiNifExportUseObjectName = TempMultiNifExportUseObjectName
	obj.MultiNifExportDeleteAfterExport = TempMultiNifExportDeleteAfterExport
	obj.MultiNifExportRepairEmitterWithoutParticles = TempMultiNifExportRepairEmitterWithoutParticles
	obj.MultiNifExportTranslateType = TempMultiNifExportTranslateType
	obj.MultiNifExportRotateType = TempMultiNifExportRotateType
	obj.MultiNifExportScaleType = TempMultiNifExportScaleType
	return true
)
-----------------------------------------------------------------------------
fn HandleMultiNifConversion =
(
    NewAttribID = #(0x99977ad7, 0x72555b55)
    NewAttribName = "MultiNifExport"
    DefinedCA = undefined
    OldDefs = GetOldAttributeDefs NewAttribName NewAttribID
	
    if OldDefs != undefined do
    (
	    if OldDefs.count != 0 do
	    (
	        tempFunction = #(GetOldMultiNifData)
        	   
	        OldDataArray = GetOldDefsInScene NewAttribName NewAttribID tempFunction
			
        	   
	        if DefinedCA == undefined do
	        (
	   		        include "Gamebryo/MultiNifExportCustAttribs.ms"
			        DefinedCA = MultiNifExportCA
					
	        )
        	   
	        for OldData in OldDataArray do
	        (
		        bSuccess = SetOldMultiNifData OldData[1] OldData DefinedCA
		        if bSuccess == true then bSave = true
	        )
        	   
        	CleanOldDefsByName NewAttribName
	    )
    )
)

-----------------------------------------------------------------------------
-- The following code will be executed automatically
-----------------------------------------------------------------------------
HandleMultiNifConversion()
setSaveRequired bSave
if bSave == false then clearUndoBuffer()
