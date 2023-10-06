------------------------------------------------------------------------
-- ZENIMAX MEDIA PROPRIETARY INFORMATION
-- 
-- This software is developed and/or supplied under the terms of a license
-- or non-disclosure agreement with ZeniMax Media Inc. and may not be copied
-- or disclosed except in accordance with the terms of that agreement.
-- 
--   Copyright (c) 2013 ZeniMax Media Incorporated.
--   All Rights Reserved.
-- 
-- ZeniMax Media Incorporated, Rockville, Maryland 20850
-- http://www.zenimax.com
-- Owner: Jeffrey Lundin
------------------------------------------------------------------------

plugin material BSBlinn
	name:"BSBlinn"
	classID:#(0x49081c5e, 0x4ba50427)
	extends:Standard
	replaceUI:false
	version:1
(
	-- forward define the functions so it can be called (it requires some variables defined later in the file)
	local setRadioToLightingFX
	local setRadioToMaterialFile
	local radioIsLightingFX
	local radioIsMaterialFile
	local getMaterialFilePathOrDefault
	local getRelativeMatPath
	local updateFromTargetMat
	local clearMaterial
	local setLightingFX
	local setMaterialFile
	
	-- Max is stupid, it will compile this script just fine, not knowing anything about BSLightingFX
	-- (because it is alphabetically after this one) and not spit out any errors. But any type check
	-- will fail because it didn't know about the type when the script loaded. We don't want to use
	-- filein to solve the issue because that will slow max down (cause it does it each time, even if
	-- it did it before). So this is the workaround - manually input the class ID for comparison.
	local BSLightingFXClassID = #(0x4cdce7fb, 0x50191395)
	
	parameters BSBlinnMain rollout:BSBlinnMainRollout
	(
		-- We pretend to be either a material, or a material file - if the material is set, it wins
		TargetBSMaterial type:#Material -- the material we pretend to be on export
		TargetMaterialFile type:#string -- the material file we pretend to be on export
	)
	
	rollout BSBlinnMainRollout "BSBlinn"
	(
		radiobuttons matVsFile pos:[5,9] labels:#("Material File", "BSLightingFX")
		edittext targetMaterialNameOrPath pos:[5,32] width:285 readOnly:true
		button targetMaterialBtn "..." pos:[295,30] width:25
		button updateMaterialBtn "Update from source material" pos:[5,55] width:315
		
		on matVsFile changed matType do
		(
			-- whenever the radio button changes, just wipe out the data
			clearMaterial()
			updateFromTargetMat()
		)
		
		on targetMaterialBtn pressed do
		(
			if radioIsLightingFX() then
			(
				-- open the material browser to pick a material, but make sure to instance only, do not copy
				local materialToTry = materialBrowseDlg #mats #instanceOnly
				if materialToTry != undefined then -- don't pass undefined to the function or it will clear the value (the user canceled, not approved)
				(
					if not (setLightingFX materialToTry) then
						messageBox "Unsupported material type, please pick a BSLightingFX-based material" title:"BSBlinn"
				)
			)
			else if radioIsMaterialFile() then
			(
				local smatPath = getMaterialFilePathOrDefault()
				local sfilePath = getOpenFileName caption:"Select a .BGSM to load:" types:"Bethesda Game Shader Material (*.BGSM)|*.BGSM" historyCategory:"BGSMaterial" filename:smatPath
				if sfilePath != undefined then
				(
					if not (setMaterialFile sfilePath) then
						messageBox @"Invalid path. Must be somewhere in \Data\Materials"
				)
			)
		)
		
		on updateMaterialBtn pressed do
		(
			updateFromTargetMat()
		)
		
		on BSBlinnMainRollout open do
		(
			-- rollout was opened, so make sure UI displays correctly
			if TargetBSMaterial != undefined then
			(
				setRadioToLightingFX()
				targetMaterialNameOrPath.text = TargetBSMaterial.name
			)
			else if TargetMaterialFile != undefined and TargetMaterialFile != "" then
			(
				setRadioToMaterialFile()
				local sshortPath = getRelativeMatPath TargetMaterialFile
				if sshortPath != undefined then
					targetMaterialNameOrPath.text = sshortPath
				else
					targetMaterialNameOrPath.text = ""
			)
			else
			(
				-- default to material file
				setRadioToMaterialFile()
				targetMaterialNameOrPath.text = ""
			)
		)
	)
	
	-- tiny helpers so we don't have to worry about which state the of the radio button is which
	fn setRadioToMaterialFile =
	(
		BSBlinnMainRollout.matVsFile.state = 1 -- Material File
	)
	fn setRadioToLightingFX =
	(
		BSBlinnMainRollout.matVsFile.state = 2 -- BSLightingFX
	)
	fn radioIsMaterialFile =
	(
		BSBlinnMainRollout.matVsFile.state == 1 -- Material File
	)
	fn radioIsLightingFX =
	(
		BSBlinnMainRollout.matVsFile.state == 2 -- BSLightingFX
	)
	
	--Returns the path to the material folder of the currently set material file, or the default if none.
	fn getMaterialFilePathOrDefault = 
	(
		local slocalMatPath = undefined
		if TargetMaterialFile != undefined and TargetMaterialFile != "" then
		(
			local smatPath = (GetFilenamePath TargetMaterialFile)
			if doesFileExist smatPath then
				slocalMatPath = smatPath
		)
		if slocalMatPath == undefined then
			slocalMatPath = GetRootDataPath childFolder:"Materials"
		
		slocalMatPath
	)
	
	-- Converts the file path of a material file to the relative path
	-- Returns undefined if "Data\Materials" is not a part of the path
	fn getRelativeMatPath asFilePath =
	(
		local srelPath = undefined
		if asFilePath != undefined and asFilePath != "" then
		(
			-- find Data\Materials and then trim off the data part
			local iindex = (findString asFilePath @"Data\Materials\")
			if iindex != undefined then
			(
				-- trim from 5 past the found location to the end of the string
				-- (yes, no space between - and 1 is important)
				srelPath = substring asFilePath (iindex + 5) -1
			)
		)
		
		srelPath
	)
	
	-- Function that loads all material data from our target into ourselves (or at least the bits
	-- we care about
	fn updateFromTargetMat =
	(
		if TargetBSMaterial != undefined then
		(
			-- make a new bitmap texture for the diffuse map using the file in slot 1 on the BS material
			local bitmapToUse = TargetBSMaterial.delegate.getEffectBitmap 1
			if bitmapToUse != undefined then
			(
				delegate.diffuseMap = BitmapTexture fileName:bitmapToUse.fileName
				delegate.showInViewport = true
			)
			else
				delegate.diffuseMap = undefined
		)
		else if TargetMaterialFile != undefined and TargetMaterialFile != "" then
		(
			-- tell the C++ code to load our data for us
			LoadLightingFXFromBGSM this TargetMaterialFile
		)
		else
			delegate.diffuseMap = undefined
	)
	
	-- Tiny helper function to clear out all material data (does not perform update though)
	fn clearMaterial =
	(
		TargetBSMaterial = undefined
		TargetMaterialFile = ""
		BSBlinnMainRollout.targetMaterialNameOrPath.text = ""
	)
	
	-- function to to set the lighting fx material (if valid) and update the UI
	-- if given an undefined material, it clears the material we have set and returns true
	-- if given an invalid material, it returns false, but doesn't touch the material we have set
	fn setLightingFX aMatToSet =
	(
		local bvalidMaterial = false
		if aMatToSet == undefined then
		(
			bvalidMaterial = true -- giving us nothing clears the value and is considered valid
			clearMaterial()
			setRadioToLightingFX()
			updateFromTargetMat()
		)
		else if IsKindOf aMatToSet Material then
		(
			-- Max won't let you compare classIDs directly (comparison ALWAYS fails, even if they're
			-- identical). Work around? Convert them to a string and compare the strings. *sigh*
			bvalidMaterial = (aMatToSet.classID as string == BSLightingFXClassID as string)
			if bvalidMaterial then
			(
				clearMaterial()
				TargetBSMaterial = aMatToSet
				BSBlinnMainRollout.targetMaterialNameOrPath.text = aMatToSet.name
				setRadioToLightingFX()
				updateFromTargetMat()
			)
		)
		-- return validity to caller - do NOT use return (or break, or exit, or continue) because
		-- Max implements them via C++ exceptions which is slow and just plain stupid.
		bvalidMaterial
	)
	
	-- funciton to set the material file and update the UI
	-- if given an undefined or empty string, it clears the material we have set and returns true
	-- if given an invalid path (not under "Data\Materials") then it will return false and not touch anything
	fn setMaterialFile asFilenameAndPath =
	(
		local bvalidPath = false
		local sstringFile = asFilenameAndPath as string
		if sstringFile == undefined or sstringFile == "" then
		(
			bvalidPath = true -- giving us nothing clears the value and is considered valid
			clearMaterial()
			setRadioToMaterialFile()
			updateFromTargetMat()
		)
		else
		(
			local sshortPath = getRelativeMatPath sstringFile
			if sshortPath != undefined then
			(
				bvalidPath = true
				clearMaterial()
				TargetMaterialFile = sstringFile -- save full path to material
				BSBlinnMainRollout.targetMaterialNameOrPath.text = sshortPath
				setRadioToMaterialFile()
				updateFromTargetMat()
			)
		)
		
		bvalidPath
	)
)