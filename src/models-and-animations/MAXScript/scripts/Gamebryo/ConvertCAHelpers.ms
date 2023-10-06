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
fn IsOldDef Def AttribName AttribID =
(
	if Def.name != AttribName then return false
	if Def.attribID[1] != AttribID[1] then return true
	if Def.attribID[2] != AttribID[2] then return true
	return false
)
-----------------------------------------------------------------------------
fn GetOldAttributeDefs AttribName AttribID = 
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
fn DeleteOldDefs Defs =
(
	for def in Defs do
	(
		try 
		    custAttributes.deleteDef def
	    catch 
	    ( 
	    )   
	)
)
-----------------------------------------------------------------------------
fn CleanOldDefs =
(
    for def in custAttributes.getSceneDefs () do
    (
	    try 
		    custAttributes.deleteDef def
	    catch 
	    ( 
	    )      
    ) 
)
-----------------------------------------------------------------------------
fn CleanOldDefsByName AttribName =
(
    for def in custAttributes.getSceneDefs () do
    (
        if def.name == AttribName do
        (
            --print "Deleting old def"
	        try 
		        custAttributes.deleteDef def
	        catch 
	        ( 
	        )  
	    )    
    ) 
)
-----------------------------------------------------------------------------
fn GetOldDefsInMap map AttribName AttribID GetFunction = 
(
    if map == undefined then return undefined
    iCount = custAttributes.count map
    for i = 1 to iCount do
    (
	    cadef = custAttributes.getdef map i 
	    if cadef != undefined do
	    (
		    bIsOldDef = IsOldDef cadef AttribName AttribID
		    if bIsOldDef == true do
		    (
			    --print "Found 0ne"
			    TempAttribute = custAttributes.get map i
			    OldData = GetFunction[1] map cadef TempAttribute
			    return OldData
		    )
	    )
    )
    return undefined
)
-----------------------------------------------------------------------------

GamebryoTempCustomAttributeMaterial = undefined

-----------------------------------------------------------------------------
fn GetOldDefsInMaterial matl AttribName AttribID GetFunction = 
(
	DefDataArray = #()
	if matl == undefined then return DefDataArray 
	
    if isKindOf matl StandardMaterial do
	(
	    --print "StandardMaterial"
	    if matl.maps != undefined do
	    (
	        for map in matl.maps do
		    (
			    if map != undefined do
			    (
			        OldData = GetOldDefsInMap map AttribName AttribID GetFunction
			        if OldData != undefined do
			        (
    			        append DefDataArray OldData
			        )
			    )
		    )
		)
		--print "CustAttribs"
		iCACount = custAttributes.count matl
		for i = 1 to iCACount do
		(
			ParamCount = (NiGetCustAttribCount matl "NiShaderCustAttribs")
			if ParamCount == undefined then
				continue
			for j = 0 to (NiGetCustAttribCount matl "NiShaderCustAttribs") do
			(
				texmap = NiGetCustAttrib matl j "NiShaderCustAttribs"
				if isKindOf texmap textureMap then
				(
					OldData = GetOldDefsInMap texmap AttribName AttribID GetFunction
					if OldData != undefined then
					(
						append DefDataArray OldData
					)
				)
			)
		)
	)
	if isKindOf matl multimaterial do
	(
		--print "multimaterial"
		for submatl in matl.materialList do
		(
			subArray = GetOldDefsInMaterial submatl AttribName AttribID GetFunction
			if subArray != undefined do
			(
				for OldData in subArray do
				(
					append DefDataArray OldData
				)
			)
		)
	)
    if isKindOf matl  Gamebryo_XPlatform_Material do
    (
        --print "XPlatform Material"
	    tempMtl = matl.PCMaterial
	    subArray = GetOldDefsInMaterial tempMtl AttribName AttribID GetFunction
 	    if subArray != undefined do
	    (
			for OldData in subArray do
			(
				append DefDataArray OldData
			)
        )
        
        tempMtl = matl.XenonMaterial
        subArray = GetOldDefsInMaterial tempMtl AttribName AtribID GetFunction
        if subArray != undefined do
        (
            for OldData in subArray do
            (
                append DefDataArray OldData
            )
        )
    )

    ThisMaxVersion = maxVersion() 
    if ThisMaxVersion[1] >= 5000 do
    (
		if isKindOf matl Shell_Material do
		(
            --print "Shell_Material"
			tempMtl = matl.bakedMaterial
			subArray = GetOldDefsInMaterial tempMtl AttribName AttribID GetFunction
			if subArray != undefined do
			(
				for OldData in subArray do
				(
					append DefDataArray OldData
				)
			)
			tempMtl = matl.originalMaterial
			subArray = GetOldDefsInMaterial tempMtl AttribName AttribID GetFunction
			if subArray != undefined do
			(
				for OldData in subArray do
				(
					append DefDataArray OldData
				)
			)
		)
    )
	
	return DefDataArray
)
-----------------------------------------------------------------------------
fn GetOldDefsInAllMaterials AttribName AttribID GetFunction = 
(
   DefDataArray = #()
   for matl in scenematerials do
   (
   		OldDataArray = GetOldDefsInMaterial matl AttribName AttribID GetFunction
		for OldData in OldDataArray do
		(
		    append DefDataArray OldData
		)
   )
   
   for matl in meditMaterials do
   (
   		OldDataArray = GetOldDefsInMaterial matl AttribName AttribID GetFunction
		for OldData in OldDataArray do
		(
		    append DefDataArray OldData
		)
   )

   
   for matl in currentMaterialLibrary do
   (
   		OldDataArray = GetOldDefsInMaterial matl AttribName AttribID GetFunction
		for OldData in OldDataArray do
		(
		    append DefDataArray OldData
		)
   )

   return DefDataArray
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
		    if bIsOldDef == true do
		    (
			    --print "Found 0ne"
			    TempAttribute = custAttributes.get obj i
			    OldData = GetFunction[1] obj cadef TempAttribute
			    append DefDataArray OldData
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
