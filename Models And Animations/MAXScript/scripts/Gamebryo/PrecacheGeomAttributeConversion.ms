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
fn GetOldPrecacheData obj OldDef TempAttribute =
(
    bSuccess = true
	TempConsistency = undefined
	TempKeepPositions = undefined
	TempKeepNormals = undefined
	TempKeepVertColors = undefined
	TempKeepUVCoords = undefined
	TempKeepBoneIndices = undefined
	TempKeepBoneData = undefined
	TempCompressPositions = undefined
	TempCompressNormals = undefined
	TempCompressVertColors = undefined
	TempCompressUVCoords = undefined
	TempCompressBoneWeights = undefined
	                        
	                            
	try
	(
	    tempValue = NiGetCustAttrib obj "Consistency"
		if tempValue != undefined then TempConsistency = tempValue
					
		tempValue = NiGetCustAttrib obj "KeepPositions"
		if tempValue != undefined then TempKeepPositions = tempValue
	    
	    tempValue = NiGetCustAttrib obj "KeepNormals"
		if tempValue != undefined then TempKeepNormals = tempValue
	    
	    tempValue = NiGetCustAttrib obj "KeepVertColors"
		if tempValue != undefined then TempKeepVertColors = tempValue

        tempValue = NiGetCustAttrib obj "KeepUVCoords"
		if tempValue != undefined then TempKeepUVCoords = tempValue
	    
	    tempValue = NiGetCustAttrib obj "KeepBoneIndices"
		if tempValue != undefined then TempKeepBoneIndices = tempValue
	    
	    tempValue = NiGetCustAttrib obj "KeepBoneData"
		if tempValue != undefined then TempKeepBoneData = tempValue
	    
	    tempValue = NiGetCustAttrib obj "CompressPositions"
		if tempValue != undefined then TempCompressPositions = tempValue
	    
	    tempValue = NiGetCustAttrib obj "CompressNormals"
		if tempValue != undefined then TempCompressNormals = tempValue
	    
	    tempValue = NiGetCustAttrib obj "CompressVertColors"
		if tempValue != undefined then TempCompressVertColors = tempValue
	    
	    tempValue = NiGetCustAttrib obj "CompressUVCoords"
		if tempValue != undefined then TempCompressUVCoords = tempValue

        tempValue = NiGetCustAttrib obj "CompressBoneWeights"
		if tempValue != undefined then TempCompressBoneWeights = tempValue
	)
	catch 
	(
	    bSuccess = false
	    strMessage = "WARNING! Failed to convert Precache Geometry custom attributes on object: " + (obj.name as string)
        print strMessage
	)
		
	if bSuccess == true do
	(
        DataHolder = #(obj, TempConsistency, TempKeepPositions, TempKeepNormals, TempKeepVertColors, TempKeepUVCoords, TempKeepBoneIndices, TempKeepBoneData, TempCompressPositions, TempCompressNormals, TempCompressVertColors, TempCompressUVCoords, TempCompressBoneWeights) 
        custAttributes.delete obj OldDef
	)
	
	if bSuccess == false do
	(
	    DataHolder = #(obj)
	)
	
    
	return DataHolder
)
-----------------------------------------------------------------------------
fn SetOldPrecacheData obj OldDataHolder NewCADef=
(
	if OldDataHolder == undefined or OldDataHolder.count == 1 then return false
    
    TempConsistency	= OldDataHolder[2] 
	TempKeepPositions= OldDataHolder[3] 
	TempKeepNormals = OldDataHolder[4] 
	TempKeepVertColors	= OldDataHolder[5] 
	TempKeepUVCoords = OldDataHolder[6] 
	TempKeepBoneIndices	 = OldDataHolder[7] 
	TempKeepBoneData  = OldDataHolder[8] 
	TempCompressPositions = OldDataHolder[9] 
	TempCompressNormals = OldDataHolder[10] 
	TempCompressVertColors = OldDataHolder[11] 
	TempCompressUVCoords = OldDataHolder[12] 
	TempCompressBoneWeights	 = OldDataHolder[13] 
	
	custAttributes.add obj NewCADef
	obj.Consistency = TempConsistency
	obj.KeepPositions = TempKeepPositions
	obj.KeepNormals = TempKeepNormals
	obj.KeepVertColors = TempKeepVertColors
	obj.KeepUVCoords = TempKeepUVCoords
	obj.KeepBoneIndices = TempKeepBoneIndices
	obj.KeepBoneData = TempKeepBoneData
	obj.CompressPositions = TempCompressPositions
	obj.CompressNormals = TempCompressNormals
	obj.CompressVertColors = TempCompressVertColors
	obj.CompressUVCoords = TempCompressUVCoords
	obj.CompressBoneWeights = TempCompressBoneWeights
	return true
)
-----------------------------------------------------------------------------
fn HandlePrecacheConversion =
(
    NewAttribID = #(0x47ba7c95, 0xa68a3bca)
    NewAttribName = "PrecacheGeometryCA"
    DefinedCA = undefined
    OldDefs = GetOldAttributeDefs NewAttribName NewAttribID
	
    if OldDefs != undefined do
    (
	    if OldDefs.count != 0 do
	    (
	        tempFunction = #(GetOldPrecacheData)
        	   
	        OldDataArray = GetOldDefsInScene NewAttribName NewAttribID tempFunction
			
        	   
	        if DefinedCA == undefined do
	        (
	   		        include "Gamebryo/PrecacheGeometryCA.ms"
			        DefinedCA = PrecacheGeometryCA
					
	        )
        	   
	        for OldData in OldDataArray do
	        (
	            bSuccess = SetOldPrecacheData OldData[1] OldData DefinedCA
		        if bSuccess == true then bSave = true
	        )
        	   
        	CleanOldDefsByName NewAttribName
	    )
    )
)

-----------------------------------------------------------------------------
-- The following code will be executed automatically
-----------------------------------------------------------------------------

HandlePrecacheConversion()
setSaveRequired bSave
if bSave == false then clearUndoBuffer()
