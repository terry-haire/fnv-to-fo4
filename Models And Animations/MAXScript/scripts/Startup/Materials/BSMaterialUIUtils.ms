------------------------------------------------------------------------
-- ZENIMAX MEDIA PROPRIETARY INFORMATION
-- 
-- This software is developed and/or supplied under the terms of a license
-- or non-disclosure agreement with ZeniMax Media Inc. and may not be copied
-- or disclosed except in accordance with the terms of that agreement.
-- 
--   Copyright (c) 2009 ZeniMax Media Incorporated.
--   All Rights Reserved.
-- 
-- ZeniMax Media Incorporated, Rockville, Maryland 20850
-- http://www.zenimax.com
-- Owner: Ryan Ashford
------------------------------------------------------------------------

--START CONFIG FUNCTIONS
SettingsFileName = "BSToolSettings.ini"
global bPreFileOpenG

function GetExportSettingsFile =
(
	configDir = GetDir #plugcfg
	if configDir != undefined then
	(
		configDir = configDir + "\\" + SettingsFileName
	)
	
	configDir
)

INISectionMaterialName = "Materials"
INISectionP4Name = "P4"
INISectionConfigName = "Config"

INIRootDataPathKey = "LocalDataPath"
INIRootSourcePathKey = "LocalSourcePath"
INIP4WorkspaceKey = "Workspace"
INIP4VerboseKey = "Verbose"
INIConfigsDir = "ConfigFilesDir"

function GetRootDataPath childFolder:"" =
(
	local INIPath = GetExportSettingsFile()
	local dataPath = ""
	if INIPath != undefined and INIPath != "" then
		dataPath = getINISetting INIPath INISectionMaterialName INIRootDataPathKey
	
	if childFolder != "" then
	(
		dataPath = pathConfig.AppendPath dataPath childFolder
		if dataPath[dataPath.count] != "\\" then
			dataPath += "\\"
	)
	
	dataPath
)

function GetRootSourcePath childFolder:"" =
(
	local INIPath = GetExportSettingsFile()
	local sourcePath = ""
	if INIPath != undefined and INIPath != "" then
		sourcePath = getINISetting INIPath INISectionMaterialName INIRootSourcePathKey
	
	if childFolder != "" then
	(
		sourcePath = pathConfig.AppendPath sourcePath childFolder
		if sourcePath[sourcePath.count] != "\\" then
			sourcePath += "\\"
	)
	
	sourcePath
)

function SetRootDataFolder =
(
	local previousPath = GetRootDataPath()
	local dataPath = getSavePath initialDir:previousPath caption:"Set the path to the Root Data directory (Likely C:\Projects\...\Build\PC\Data\)."
	if dataPath != undefined and dataPath != "" then
	(
		local INIPath = GetExportSettingsFile()
		if INIPath != undefined then setINISetting INIPath INISectionMaterialName INIRootDataPathKey (dataPath + "\\")
	)
	
	dataPath
)

function SetRootSourceFolder =
(
	local previousPath = GetRootSourcePath()
	local sourcePath = getSavePath initialDir:previousPath caption:"Set the path to the Root Source directory (Wherever your TGATextures and DDSTextures directories are)."
	if sourcePath != undefined and sourcePath != "" then
	(
		local INIPath = GetExportSettingsFile()
		if INIPath != undefined then setINISetting INIPath INISectionMaterialName INIRootSourcePathKey (sourcePath + "\\")
	)
	
	sourcePath
)

function INI_GetP4Workspace =
(
	local workspace = ""
	local INIPath = GetExportSettingsFile()
	if INIPath != undefined and INIPath != "" then
		workspace = getINISetting INIPath INISectionP4Name INIP4WorkspaceKey
	if workspace == undefined then (workspace = "")
	
	workspace
)

function INI_GetP4Verbose =
(
	local bverbose = false
	local INIPath = GetExportSettingsFile()
	if INIPath != undefined and INIPath != "" then
		bverbose = (getINISetting INIPath INISectionP4Name INIP4VerboseKey) == "true"
	
	bverbose
)

function INI_GetConfigsDir =
(
	local configsDir = ""
	local INIPath = GetExportSettingsFile()
	if INIPath != undefined and INIPath != "" then
		configsDir = getINISetting INIPath INISectionConfigName INIConfigsDir
	if configsDir == undefined then (configsDir = "")
	
	configsDir
)

rollout SettingsRollout "Settings" width:336 height:200
(
	label lbl1 "Update Current Settings:" pos:[10,8] width:149 height:18
	button SetRootDataFolderControl "Set Root Data Folder" pos:[12,31] width:313 height:34 toolTip:"Set this to the 'Data' folder which contains Textures, Meshes, and other assets."
	button SetRootSourceFolderControl "Set Root Source Folder" pos:[12,72] width:313 height:34 toolTip:"Set this to the source folder which contains your TGATextures and DDSTextures folders."
	edittext SetP4WorkspaceControl "Workspace" pos:[15,131] width:308 height:20
	groupBox grpP4 "Perforce" pos:[8,113] width:321 height:68
	checkbox DisplayP4OutputControl "Display output" pos:[15,156] width:93 height:18
	
	function UpdatePathButtonText button:undefined pathType:"" rootPath:"" =
	(
		if button != undefined then
		(
			if rootPath != undefined and rootPath != "" then
				button.text = pathType + ": " + rootPath
			else
				button.text = "Set Root " + pathType + " Folder"
		)
	)

	on SettingsRollout open do
	(
		local INIPath = GetExportSettingsFile()
		
		local dataPath = GetRootDataPath()
		UpdatePathButtonText button:SetRootDataFolderControl pathType:"Data" rootPath:dataPath
		
		local sourcePath = GetRootSourcePath()
		UpdatePathButtonText button:SetRootSourceFolderControl pathType:"Source" rootPath:sourcePath
		
		--Workspace
		SetP4WorkspaceControl.text = INI_GetP4Workspace()
		
		--Verbosity
		DisplayP4OutputControl.checked = INI_GetP4Verbose()
	)
	on SetRootDataFolderControl pressed do
	(
		SetRootDataFolder()
		local dataPath = GetRootDataPath()
		UpdatePathButtonText button:SetRootDataFolderControl pathType:"Data" rootPath:dataPath
	)
	on SetRootSourceFolderControl pressed do
	(
		SetRootSourceFolder()
		local sourcePath = GetRootSourcePath()
		UpdatePathButtonText button:SetRootSourceFolderControl pathType:"Source" rootPath:sourcePath
	)
	on SetP4WorkspaceControl changed arg do
	(
		if arg != undefined and arg != "" then
		(
			local INIPath = GetExportSettingsFile()
			if INIPath != undefined then
				setINISetting INIPath INISectionP4Name INIP4WorkspaceKey arg
		)
	)
	on DisplayP4OutputControl changed arg do
	(
		if arg != undefined then
		(
			local INIPath = GetExportSettingsFile()
			if INIPath != undefined then
				setINISetting INIPath INISectionP4Name INIP4VerboseKey (arg as string)
		)
	)		
)

rollout FileNotFoundRollout "File Not Found" width:228 height:123
(
	label NotFoundLabel "" pos:[16,18] width:195 height:13
 
	label SuggestionLabel2 "Make sure your settings are correct:" pos:[29,51] width:177 height:13
	button SettingsControl "Settings" pos:[59,80] width:113 height:30
	
	fn SetMissingFilePath filePath =
	(
		if filePath != undefined and filePath != "" then
			NotFoundLabel.text = filePath
		else
			NotFoundLabel.text = "Missing unknown file."
	)
	
	on SettingsControl pressed do
		(CreateDialog SettingsRollout)
)

rollout ClearConfirmRollout "Clear Material Map?" width:237 height:78
(
	local confirm
	
	label SuggestionLabel2 "Are you sure you want to Clear this map?" pos:[19,15] width:210 height:13
	button ConfirmControl "Yes" pos:[44,40] width:66 height:21
	button CancelControl "Cancel" pos:[125,40] width:68 height:21
	
	on ClearConfirmRollout open do
		(confirm = false)
	on ConfirmControl pressed do
	(
		confirm = true
		destroyDialog ClearConfirmRollout
	)
	on CancelControl pressed do
		(destroyDialog ClearConfirmRollout)
)
--END CONFIG FUNCTIONS

--Changes a path's slashes from \ to /
function ForceForwardSlashes filePath =
(
	newPath = filePath
	if newPath != undefined then
	(
		for i =1 to newPath.count do
			if newPath[i] == "\\" then newPath[i] = "/"
	)
	
	newPath
)

DataFolder = @"data\"

--Given a path, attempts to resolve it to the data-relative location on the drive (set in INI).
--The original path is returned in case of failure.
--dataRelativePrefix parameter is to specify "Textures" "Materials" or whatever other folders live in the Data\ directory.
function BuildPathUsingLocalDataRoot filePath dataRelativePrefix:"" = 
(
	if filePath != undefined and filePath != "" and dataRelativePrefix != undefined and not doesFileExist filePath then
	(
		dataPath = GetRootDataPath childFolder:dataRelativePrefix
		index = (findString filePath DataFolder)
		baseIndex = (findString filePath (dataRelativePrefix))

		if index != undefined then
		(
			sizeToReplace = index+DataFolder.count-1
			if baseIndex != undefined and baseIndex-index == DataFolder.count then
				sizeToReplace += dataRelativePrefix.count
			
			filePath = replace filePath 1 sizeToReplace ""
		)
		--If only base is found, use it to resolve.
		else if baseIndex != undefined then
				filePath = replace filePath 1 (baseIndex+dataRelativePrefix.count-1) ""
		
		if filePath[1] == "\\" then
			filePath = replace filePath 1 1 ""
		
		--Now attach the prefix to the resulting filePath.
		filePath = dataPath + filePath
	)
	
	filePath
)

--Performs a smart search for files using the external file path settings.
--If not found, undefined is returned.
--DEPRECATED: Leaving here in case the new method (BuildPathUsingLocalDataRoot) falls through.
function CorrectPathUsingExternalPaths filePath =
(
	newPath = undefined
	
	if(filePath != undefined and filepath != "") then
	(
		--If it's a valid path, use it.
		if(not doesFileExist filePath) then
		(
			--Get the filename
			fileName = filenameFromPath filePath
			
			--Get List of external file paths with appended filename.
			newpathslist = #()
			for i = 1 to mapPaths.count() do
			(
				extFilePath = mapPaths.get i
				appendedPath = pathConfig.AppendPath extFilePath fileName
				append newpathslist appendedPath
			)
			
			if(newpathslist.count > 0) then
			(
				relativeFilePath = filePath
				
				if filePath[2] == ':' then
					relativeFilePath = (pathconfig.removepathtopparent filePath)
				
				while relativeFilePath != "" and relativeFilePath != fileName do
				(
					pattern = "*" + relativeFilePath as string
					
					--Go through the list to see if the relative file path can be found
					--using the modified external file paths list.
					for fp in newpathslist do
					(
						--Does the relative path match any of the external file paths?
						if(matchPattern fp pattern:pattern ignoreCase:true) then
							return fp
					)
					
					--Removes the top level folder (i.e. C:\temp\ turns into temp\)
					relativeFilePath = pathconfig.removepathtopparent relativeFilePath
				)
			)
		)
		else newPath = filePath
	)

	newPath
)

--Detects if a material's texture is on the user's machine. If it does not exist,
--the texture path is searched for and applied to the material if found to be valid.
function UpdateTexturePath aDirectXMaterial aBitmapPropName =
(
	--If the current texture path is not found, try to resolve it to the base data folder.
	--If it still can't be found after that, leave it as is.
	try
	(
		bitmapName = GetDXBitmapPathByName aDirectXMaterial aBitmapPropName
 		if bitmapName != undefined then
 		(
			--Check for a different local path to this texture.
			newPath = BGSFixupTexturePath bitmapName

			--If the path was found, and it's not the same as the existing path, load the new bitmap.
 			if(newPath != undefined and newPath != bitmapName) then
 			(
 				newBitmap = openBitmap newPath
				
				if newBitmap != undefined then
					setproperty aDirectXMaterial.delegate aBitmapPropName newBitmap
 			)
 		)
	)
	catch
	(
		format "BSMaterialUIUtils %\n" (getCurrentException())
	)
)

--RECURSIVE: Gathers all BS material types (with textures) into an array.
function GatherMaterialsRec aMat aMatArray = 
(
	if aMat != undefined then
	(
		if classOf aMat == multimaterial then
		(
			for mat in aMat do
				aMatArray = (GatherMaterialsRec mat aMatArray)
		)
		else if (classof aMat == BSLightingFX) or (classof aMat == BSEffectFX) or (classof aMat == BSSkyMaterial) or (classof aMat == BSWaterMaterial) then
			AppendIfUnique aMatArray aMat
	)
	
	aMatArray
)

--Collects BS materials used in any scene objects into an array.
function GatherAllMaterialsFromScene aMatArray:#() =
(
	--Gather a list of unique materials being used by all objects in the scene.
	for o in objects do
	(
		local objMat = o.material
		aMatArray = (GatherMaterialsRec objMat aMatArray)
	)
	
	aMatArray
)

--Collects BS materials used in the material editor into an array.
function GatherAllMaterialsFromEditor aMatArray:#() =
(
	for mat in meditmaterials do	
		aMatArray = (GatherMaterialsRec mat aMatArray)
	
	aMatArray
)

--Goes through all objects in a max scene and updates any BSMaterials that use textures.
--Used for cases where texture paths are not consistent between users' machines.
function ResolveFXMaterials abResolveBGSMs:false =
(
	--Get the materials currently in use.
	materials = GatherAllMaterialsFromScene()
	--Get the rest of the materials as well ('materials' now includes Scene + Editor)
	materials = GatherAllMaterialsFromEditor aMatArray:materials
	
	print("Materials found in MAX file: " + materials.count as string)

	--Convert the old material to nitrous-supported if necessary. 
	--This recompiles the shader every time it is fixed, but should only happen the first time an old file is opened.
	for m in materials do
	(
		if m != undefined then
		(
			if classof m == BSLightingFX and m.delegate.effectfile != "LightingMAX.fx" then
				m.delegate.effectfile = "LightingMAX.fx"
			else if classof m == BSEffectFX and m.delegate.effectfile != "EffectMAX.fx" then
				m.delegate.effectfile = "EffectMAX.fx"
			else if classof m == BSSkyMaterial and m.delegate.effectfile != "SkyMAX.fx" then
				m.delegate.effectfile = "SkyMAX.fx"
			else if classof m == BSWaterMaterial and m.delegate.effectfile != "WaterMAX.fx" then
				m.delegate.effectfile = "WaterMAX.fx"
		)
	)
	
	--Run through the used materials in the scene
	for m in materials do
	(
		--Update the BSLightingFX material's maps.
		if(classof m == BSLightingFX and (abResolveBGSMs or m.BGSMatPathParam == undefined or m.BGSMatPathParam == "")) then
		(
			UpdateTexturePath m "diffuseTexture"
			UpdateTexturePath m "normalTexture"
			UpdateTexturePath m "smoothspecmaskTexture"
			UpdateTexturePath m "heightTexture"
			UpdateTexturePath m "envTexture"
			UpdateTexturePath m "glowTexture"
			UpdateTexturePath m "wrinklesTexture"
			m.UpdateAllRollouts()
		)
		--Update the BSEffectFX material's maps.
		else if(classof m == BSEffectFX) then
		(
			UpdateTexturePath m "baseTexture"
			UpdateTexturePath m "grayscaleTexture"
			UpdateTexturePath m "envmapTexture"
			UpdateTexturePath m "normalTexture"
			UpdateTexturePath m "envmapMaskTexture"
		)
	)
	
	--Redraw any visible objects (which forces them to use the updated material).
	for o in objects do
	(
		if(not o.isNodeHidden) then
		(
			hide o
			unhide o
		)
	)
)

function ReloadFXFile aDirectXMaterial aFileName = 
(
	--REQUIRES THE USE OF EXTERNAL FILE PATHS USING THIS METHOD.
	animate off aDirectXMaterial.delegate.effectfile = aFileName
	aDirectXMaterial.delegate.reloadeffect()
	
	if aFileName == aDirectXMaterial.delegate.effectfilename then
	(
		CreateDialog FileNotFoundRollout
		FileNotFoundRollout.SetMissingFilePath (aFileName + " could not be found.")
	)
)

function LoadFXBitmap aDirectXMaterial aBitmapProperty aFileName = 
(
	newBitmap = openBitMap aFileName
	if(newBitmap == undefined) then
	(
		CreateDialog FileNotFoundRollout
		FileNotFoundRollout.SetMissingFilePath = (aFileName + " could not be found.")
	) else (
		with animate off (setproperty aDirectXMaterial.delegate aBitmapProperty newBitmap)
	)
)

function SetBitmapButtonText aButton aDirectXMaterial aBitmapPropName =
(
	-- Accessing a bitmap property can cause a runtime error if the bitmap cannot be found
	try
	(
		aButton.tooltip = ""
		bitmapName = GetDXBitmapPathByName aDirectXMaterial aBitmapPropname
		if bitmapName != undefined then
		(
			aButton.tooltip = bitmapName
			if doesfileexist bitmapname then
				aButton.text = filenameFromPath bitmapName
			else aButton.text = "Not Found"
		)
		else aButton.text = "None"
	)
	catch
	(
		format "BSMaterialUIUtils %\n" (getCurrentException())
		aButton.text = "Not Found"
	)
)

function SelectFXBitmap aDirectXMaterial aProperty aUIControl =
(
	newBitmap = selectbitmap()
	if(newBitmap != undefined) do
	(
		aUIControl.text = filenameFromPath newBitmap.filename
		with animate off (setproperty aDirectXMaterial.delegate aProperty newBitmap)
	)
)

function SelectFXBitmap2 aDirectXMaterial aProperty aUIControl newBitmap =
(
	if(newBitmap != undefined AND newBitmap != "None") do
	(
		with animate off (setproperty aDirectXMaterial.delegate aProperty newBitmap)
	)
)

function ReloadFXBitmap aDirectXMaterial aProperty =
(
	prevBitmapName = GetDXBitmapPathByName aDirectXMaterial aProperty
	if prevBitmapName != undefined then
		reloadedBitmap = openBitMap prevBitmapName
	if reloadedBitmap != undefined then
		with animate off (setproperty aDirectXMaterial.delegate aProperty reloadedBitmap)
)

function ClearFXMapPath aDirectXMaterial aBitmapPropName aUITexControl aUIEnableControl =
(
	if aDirectXMaterial != undefined and aDirectXMaterial.delegate != undefined and aUITexControl != undefined and aBitmapPropName != undefined then
	(
		try
		(
			createDialog ClearConfirmRollout modal:true
			
			if ClearConfirmRollout.confirm == true then
			(
				(ClearFXBitmap aDirectXMaterial aBitmapPropName)
				auiTexControl.text = "None"
				
				if aUIEnableControl != undefined then
					aUIEnableControl.checked = false
			)
		)
		catch
		(
			format "ClearFXMapPath: %\n" (getCurrentException())
		)
	)
)

function DisplayFXBitmap aDirectXMaterial aBitmapPropName = 
(
	if aDirectXMaterial != undefined then
	(
		fileName = GetDXBitmapPathByName aDirectXMaterial aBitmapPropName
		if fileName != undefined and DoesFileExist fileName then
		(
			display (GetProperty aDirectXMaterial.delegate aBitmapPropName)
			
		)
	)
)

-- Checks any materials derived from the DirectX material to see if their delegate (the DirectX material)
-- contains parameters with controllers on them. Any keys on these controllers can cause problems because
-- they are duplicates of keys on our material (BSLightingFX, BSEffectFX) parameters.
-- removeKeys: If true removes any keys found on the DirectX materials
function CheckDirectXMaterialKeys removeKeys:false =
(
	local keysFound = false
	for i=1 to meditmaterials.count do
	(
		if (isProperty meditmaterials[i] #delegate and
			(meditmaterials[i].delegate.classid[1] == DirectX_9_Shader.classid[1] and
				meditmaterials[i].delegate.classid[2] == DirectX_9_Shader.classid[2])) then
		(
			-- Material is derived from DirectX material
			for prop in getPropNames meditmaterials[i].delegate do
			(
				-- Check for controller and delete any keys
				local propController = getPropertyController meditmaterials[i].delegate prop
				if (undefined != propController and 0 != propController.keys.count) then
				(
					keysFound = true
					print ("Keys found on material: " + (meditmaterials[i] as string) + ".delegate." + (prop as string) + ".controller")
					if removeKeys do
					(
						deleteKeys propController #allKeys
					)
				)
			)
		)
	)
	
	if not keysFound then
		"No keys found"
	else
		ok
)

function IsBSFXMaterial aBSMat =
(
	--A multimaterial can have an empty material slot. Check for undefined
	aBSMat != undefined and 
	((aBSMat.classid[1] == BSLightingFX.classid[1] and aBSMat.classid[2] == BSLightingFX.classid[2]) or
	(aBSMat.classid[1] == BSEffectFX.classid[1] and aBSMat.classid[2] == BSEffectFX.classid[2]))
)

-- Access any material's animated parameters to cause the parameter's get handler to be called
function RefreshBSMaterialAnims =
(
	for i=1 to sceneMaterials.count do
	(
		if (IsBSFXMaterial sceneMaterials[i]) then
		(
			for subAnimIndex=1 to sceneMaterials[i].numSubs do
			(
				if sceneMaterials[i][subAnimIndex].isAnimated then
					sceneMaterials[i][subAnimIndex].value
			)
		)
		else if (sceneMaterials[i].classid[1] == Multimaterial.classid[1] and sceneMaterials[i].classid[2] == Multimaterial.classid[2]) do
		(
			-- Sub-materials one layer deep are supported. The exporter assumes nested multi-materials are not present.
			for subMatIndex=1 to sceneMaterials[i].numSubs do
			(
				if (IsBSFXMaterial sceneMaterials[i][subMatIndex]) do
				(
					for subAnimIndex=1 to sceneMaterials[i][subMatIndex].numSubs do
					(
						if sceneMaterials[i][subMatIndex][subAnimIndex].isAnimated then
							sceneMaterials[i][subMatIndex][subAnimIndex].value
					)
				)
			)
		)
	)
)

--Pass along the enable state to a specified function. If none available do a blanket control adjustment.
function SetRolloutEnableState aRollout abEnabled aRefreshUIFunction:undefined =
(
	if aRollout != undefined and abEnabled != undefined then
	(
		bhandled = false
		--If true, make the rollout refresh itself, as long as the refresh exists.
		if aRefreshUIFunction != undefined then
		(
			aRefreshUIFunction abEnabled
			bhandled = true
		)
		
		if not bhandled then
		(
			for ctrl in aRollout.controls do
			(
				if ctrl != undefined then ctrl.enabled = abEnabled
			)
		)
	)
)

------PERFORCE
P4BatchFilePath = @"C:\Temp\BGSP4_BatchCmds.bat"

--Gets the specified workspace from the INI, or constructs the common workspace.
function GetWorkspace =
(
	--Do an INI check here.
	local workspace = INI_GetP4Workspace()
	
	if workspace == undefined or workspace == "" then (workspace = sysinfo.username + "_Fallout4Data")
	
	workspace
)

--Constructs a P4 command to add or checkout a specified file in a specified workspace.
function GetP4CMDCheckoutAddFile aFile aWorkspace:"" =
(
	cmd = ""
	if aFile != undefined and aFile != "" then
	(
		--Check for an array of files with classof?
		if aWorkspace == undefined or aWorkspace == "" then (aWorkspace = GetWorkspace())
		
		cmd = "p4 -c " + aWorkspace as string + " add " + aFile as string + "\n"
		cmd += "p4 -c " + aWorkspace as string + " edit " + aFile as string + "\n"
	)
	
	cmd
)

--Constructs a P4 command to revert a specified file in a specified workspace.
function GetP4CMDRevertFile aFile aWorkspace:"" =
(
	cmd = ""
	if aFile != undefined and aFile != "" then
	(
		if aWorkspace == undefined or aWorkspace == "" then (aWorkspace = GetWorkspace())
		
		cmd = "p4 -c " + aWorkspace as string + " revert " + aFile as string + "\n"
	)
	
	cmd
)

--Constructs a P4 command to sync a specified file in a specified workspace.
function GetP4CMDSyncFile aFile aWorkspace:"" =
(
	cmd = ""
	if aFile != undefined and aFile != "" then
	(
		if aWorkspace == undefined or aWorkspace == "" then (aWorkspace = GetWorkspace())
		
		cmd = "p4 -c " + aWorkspace as string + " sync " + aFile as string + "\n"
	)
	
	cmd
)

function GetP4Verbose =
(
	not bPreFileOpenG and INI_GetP4Verbose()
)

--Given a set of commands, constructs a temporary batch file for execution.
function CreateP4BatchFile aCmdString =
(
	if GetP4Verbose() then (aCmdString += "pause\n")
	file = createfile P4BatchFilePath -- Make the file
	format aCmdString to: file -- Write the file
	close file -- Close the file
)

--Runs the constructed batch file in a hidden cmd process.
function ExecuteP4BatchFile =
(
	if GetP4Verbose() then 
		(DOSCommand p4BatchFilePath)
	else (HiddenDOSCommand P4BatchFilePath)
)

--Attempts to add or checkout the specified file in the specified workspace.
function CheckoutOrAddFile aFile =
(
	if aFile != undefined and aFile != "" then (CheckoutOrAddFiles #(aFile))
)

--Attempts to add or checkout all of the specified files in the specified workspace.
function CheckoutOrAddFiles aFiles =
(
	bvalid = false
	if aFiles != undefined and classof aFiles == Array and aFiles.count > 0 then
	(
		local bverbose = GetP4Verbose()
		local fullcmd = ""
		for f in aFiles do
		(
			if bverbose then print("Checkout/Add: " + f as string)
			fullcmd += GetP4CMDCheckoutAddFile f
		)

		CreateP4BatchFile fullcmd
		ExecuteP4BatchFile()
		
		bvalid = true
	)

	bvalid
)

--Attempts to get the latest version of a specified file. If it's not in the specified workspace it will be ignored.
function SyncFile aFile =
(
	if aFile != undefined and aFile != "" then (SyncFiles #(aFile))
)

--Attempts to get the latest version of all specified files. Any files not in the specified workspace will be ignored.
function SyncFiles aFiles =
(
	bvalid = false
	if aFiles != undefined and classof aFiles == Array and aFiles.count > 0 then
	(
		local bverbose = GetP4Verbose()
		local fullcmd = ""
		for f in aFiles do
		(
			if bverbose then print("Sync: " + f as string)
			fullcmd += GetP4CMDSyncFile f
		)

		CreateP4BatchFile fullcmd
		ExecuteP4BatchFile()
		
		bvalid = true
	)

	bvalid
)

--Reverts a given file from perforce
function RevertFile aFile =
(
	if aFile != undefined and aFile != "" then
	(
		if GetP4Verbose() then print("Revert: " + aFile as string)
		CreateP4BatchFile (GetP4CMDRevertFile aFile)
		ExecuteP4BatchFile()
	)
)

------END PERFORCE

macroscript BSRemapMaterialTextures category:"Bethesda" tooltip:"Remap Material Texture Paths"
(
	ResolveFXMaterials abResolveBGSMs:true
)