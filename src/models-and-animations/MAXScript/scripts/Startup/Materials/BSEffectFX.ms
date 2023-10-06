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

include "BSMaterialUIUtils.ms"

plugin material BSEffectFX
	name:"BSEffectFX"
	classID:#(0x53a764f9, 0x20725e97)
	extends:DirectX_9_Shader
	replaceUI:true
	version:1
(
	parameters MainParams rollout:MainRollout
	(
		-- Base
		ShowBaseParam type:#boolean default:true ui:ShowBaseControl animatable:false
		on ShowBaseParam set arg do (animate off delegate.bShowBase = arg)
		BaseColorParam type:#color default: white ui:BaseColorControl
		on BaseColorParam get arg do (animate off delegate.baseColor = arg)
		BaseColorScaleParam type:#float default:1.0 ui:BaseColorScaleControl
		on BaseColorScaleParam get arg do (animate off delegate.fBaseColorScale = arg)
		
		-- Misc
		ShowVertexColorParam type:#boolean default:false ui:ShowVertexColorControl animatable:false
		on ShowVertexColorParam set arg do (animate off delegate.bVertexColorsEnabled = arg)
		TwoSidedParam type:#boolean default:false ui:TwoSidedControl animatable:false
		on TwoSidedParam set arg do (animate off delegate.g_bTwoSided = arg)
		DecalParam type:#boolean default:false ui:DecalControl animatable:false
		on DecalParam set arg do (animate off delegate.bDecal = arg)
		DecalNoFadeParam type:#boolean default:false ui:DecalNoFadeControl animatable:false
		on DecalNoFadeParam set arg do (animate off delegate.bDecalNoFade = arg)
		ScreenSpaceReflectionsParam type:#boolean default:false ui:ScreenSpaceReflectionsControl animatable:false
		
		-- Falloff
		FalloffParam type:#boolean default:false ui:FalloffAlphaControl animatable:false -- repurposed as alpha falloff
		FalloffColorParam type:#boolean default:false ui:FalloffColorControl animatable:false
		on FalloffParam set arg do
		(
			this.MainRollout.FalloffStartAngleControl.enabled = arg or FalloffColorParam
			this.MainRollout.FalloffStopAngleControl.enabled = arg or FalloffColorParam
			this.MainRollout.FalloffStartValueControl.enabled = arg or FalloffColorParam
			this.MainRollout.FalloffStopValueControl.enabled = arg or FalloffColorParam
			animate off delegate.bAlphaFalloffEnabled = arg
		)
		on FalloffColorParam set arg do
		(
			this.MainRollout.FalloffStartAngleControl.enabled = arg or FalloffParam
			this.MainRollout.FalloffStopAngleControl.enabled = arg or FalloffParam
			this.MainRollout.FalloffStartValueControl.enabled = arg or FalloffParam
			this.MainRollout.FalloffStopValueControl.enabled = arg or FalloffParam
			animate off delegate.bColorFalloffEnabled = arg
		)
		FalloffStartAngleParam type:#float default:0.0 ui:FalloffStartAngleControl
		on FalloffStartAngleParam get arg do (animate off delegate.fFalloffStartAngle = arg)
		FalloffStopAngleParam type:#float default:0.0 ui:FalloffStopAngleControl
		on FalloffStopAngleParam get arg do (animate off delegate.fFalloffStopAngle = arg)
		FalloffStartOpacityParam type:#float default:0.0 ui:FalloffStartValueControl -- repurposed as start "value"
		on FalloffStartOpacityParam get arg do (animate off delegate.fFalloffStartOpacity = arg)
		FalloffStopOpacityParam type:#float default:0.0 ui:FalloffStopValueControl -- repurposed as stop "value"
		on FalloffStopOpacityParam get arg do (animate off delegate.fFalloffStopOpacity = arg)
		
		-- Z Test, Write
		ZTestParam type:#boolean default:true ui:ZTestControl animatable:false
		on ZTestParam set arg do (animate off delegate.bZTestEnabled = arg)
		ZWriteParam type:#boolean default:true ui:ZWriteControl animatable:false
		on ZWriteParam set arg do (animate off delegate.bZWriteEnabled = arg)
		
		-- Lighting
		LightingParam type:#boolean default:false ui:LightingEnableControl animatable:false
		on LightingParam set arg do
		(
			this.MainRollout.LightingInfluenceControl.enabled = arg
			animate off delegate.bLightingEnabled = arg
		)
		LightingInfluenceParam type:#float default:1.0 ui:LightingInfluenceControl
		on LightingInfluenceParam get arg do (animate off delegate.fLightingInfluence = arg)
		
		-- Soft
		SoftParam type:#boolean default:false ui:SoftControl animatable:false
		on SoftParam set arg do
		(
			this.MainRollout.SoftDepthControl.enabled = arg
			animate off delegate.bSoft = arg
		)
		SoftDepthParam type:#float default:100.0 ui:SoftDepthControl
		on SoftDepthParam get arg do (animate off delegate.fSoftDepth = arg)
		
		-- Alpha
		AlphaParam type:#boolean default:false ui:AlphaControl animatable:false
		AlphaValueParam type:#float default:1.0 ui:AlphaValueControl
		on AlphaValueParam get arg do (animate off delegate.fBaseAlpha = arg)
		AlphaRefParam type:#integer default:128 ui:AlphaRefControl
		on AlphaRefParam get arg do (animate off delegate.g_AlphaRef = arg)
		AlphaBlendParam type:#integer default:4 ui:AlphaBlendControl animatable:false
		on AlphaParam set arg do
		(
			animate off delegate.g_AlphaTest = arg
			this.MainRollout.AlphaValueControl.enabled = arg or (AlphaBlendParam != 4)
		)
		on AlphaBlendParam set arg do
		(
			with animate off
			(
				delegate.g_AlphaStandard = (1 == arg)
				delegate.g_AlphaAdd = (2 == arg)
				delegate.g_AlphaMult = (3 == arg)
			)
			this.MainRollout.AlphaValueControl.enabled = (arg != 4) or AlphaParam
		)
		
		-- Blood
		BloodParam type:#boolean default:false ui:BloodEnableControl animatable:false
		on BloodParam set arg do (animate off delegate.bBloodEnabled = arg)
		BloodFalloffThresh type:#float default:0.3 ui:BloodFalloffThreshControl
		on BloodFalloffThresh get arg do (animate off delegate.fBloodFalloffThresh = arg)
		BloodAlphaToRGBScale type:#float default:0.85 ui:BloodAlphaToRGBScaleControl
		on BloodAlphaToRGBScale get arg do (animate off delegate.fBloodAlphaToRGBScale = arg)
		
		--Grayscale
		GrayscaleColorParam type:#boolean default:false ui:GrayscaleColorEnableControl animatable:false
		on GrayscaleColorParam set arg do (animate off delegate.bGrayscaleToColor = arg)
		GrayscaleAlphaParam type:#boolean default:false ui:GrayscaleAlphaEnableControl animatable:false
		on GrayscaleAlphaParam set arg do (animate off delegate.bGrayscaleToAlpha = arg)
		GrayscaleTexEnableParam type:#boolean default:false ui:GrayscaleTexEnableControl animatable:false
		on GrayscaleTexEnableParam set arg do (animate off delegate.bGrayscaleTextureEnabled = arg)

		-- Env map
		EnvmapScaleParam type:#float default:1.0 ui:EnvmapScaleControl
		on EnvmapScaleParam get arg do (animate off delegate.fEnvmapScale = arg)
		EnvmapMinLODParam type:#integer default:0 ui:EnvmapMinLODControl
		on EnvmapMinLODParam get arg do (animate off delegate.iEnvmapMinLOD = arg)

		-- Refraction
		RefractionParam type:#boolean default:false ui:RefractionControl animatable:false
		on RefractionParam set arg do
		(
			this.MainRollout.RefractionPowerControl.enabled = arg
			this.MainRollout.RefractionFireControl.enabled = arg
			animate off delegate.bRefractionEnabled = arg
		)
		RefractionPowerParam type:#float default:0.0 ui:RefractionPowerControl
		on RefractionPowerParam get arg do (animate off delegate.fRefractionPower = arg)
		RefractionFireParam type:#boolean default:false ui:RefractionFireControl animatable:false
		on RefractionFireParam get arg do (animate off delegate.bRefractionFalloffEnabled = arg)

		-- Base Texture
		BaseTexEnableParam type:#boolean default:false ui:BaseTexEnableControl animatable:false
		on BaseTexEnableParam set arg do (animate off delegate.bBaseTextureEnabled = arg)
		
		-- Envmap Texture
		EnvmapTexEnableParam type:#boolean default:false ui:EnvmapTexEnableControl animatable:false
		on EnvmapTexEnableParam set arg do (animate off delegate.bEnvmapTextureEnabled = arg)

		-- Normal Texture
		NormalTexEnableParam type:#boolean default:false ui:NormalTexEnableControl animatable:false
		on NormalTexEnableParam set arg do (animate off delegate.bNormalTextureEnabled = arg)
		
		-- Envmap Mask Texture
		EnvmapMaskTexEnableParam type:#boolean default:false ui:EnvmapMaskTexEnableControl animatable:false
		on EnvmapMaskTexEnableParam set arg do (animate off delegate.bEnvmapMaskTextureEnabled = arg)
		
		-- UV Tiling
		UTilingParam type:#boolean default:true ui:UTilingControl animatable:false
		on UTilingParam set arg do (animate off delegate.bTileU = arg)
		VTilingParam type:#boolean default:true ui:VTilingControl animatable:false
		on VTilingParam set arg do (animate off delegate.bTileV = arg)
		
		-- UV Offsets
		UOffsetParam type:#float default:0 ui:UOffsetControl
		on UOffsetParam get arg do (animate off delegate.UOffset = arg)
		VOffsetParam type:#float default:0 ui:VOffsetControl
		on VOffsetParam get arg do (animate off delegate.VOffset = arg)
		UScaleParam type:#float default:1 ui:UScaleControl
		on UScaleParam get arg do (animate off delegate.UScale = arg)
		VScaleParam type:#float default:1 ui:VScaleControl
		on VScaleParam get arg do (animate off delegate.VScale = arg)
	)
	
	-- To give access to the Update functions defined at the bottom of the file.
	local UpdateAllMapPaths
	local UpdateAllRollouts
	
	fn CanEditBGEM filePath =
	(
		(not doesFileExist filePath or not getFileAttribute filePath #readOnly)
	)
	
	--bRefreshFromBGEM is used to determine whether or not we want to reload the BGEM into the material (it gets called multiple times).
	local bRefreshFromBGEM = false
	fn RefreshMaterial filePath =
	(
		try
		(
			if bRefreshFromBGEM or bPreFileOpenG then
			(
				--NOTE: This call can be slow due to full effect reload.
				(LoadEffectFXFromBGEM this filePath)
				UpdateAllMapPaths()
			)
			
			UpdateAllRollouts()
		)
		catch
		(
			format "RefreshMaterial: %\n" (getCurrentException())
		)
		
		bRefreshFromBGEM = false
	)
	
	fn GetRelativeMatPath filePath =
	(
		relPath = undefined
		if filePath != undefined and filePath != "" then
		(
			index = (findString filePath "Data\\Materials\\")
			if index != undefined then
				relPath = substring filePath (index+5) -1
		)
		
		relPath
	)
	
	local bupdating = false -- Prevents circular event handling when editing the mat param inside its own set handler.
	parameters BGSMatParams rollout:BGSMatRollout
	(
		BGSMatInit type:#boolean default:false
		BGSMatPathParam type:#string default:"" 
		BGSMatPathRelativeParam type:#string default:"" ui:BGSMatPathTexControl
		
		on BGSMatPathParam set arg do 
		(
			if BGSMatPathParam != "" and not bupdating then
			(
				bupdating = true
				if bPreFileOpenG then
				(
					--On open, make any material paths local
					BGSMatPathParam = BuildPathUsingLocalDataRoot arg dataRelativePrefix:"Materials" 
					arg = BGSMatPathParam
					SyncFile BGSMatPathParam
				)
				RefreshMaterial(arg)
			)
			bupdating = false
		)
	)

	local TrySetMatParam
	
	local DefaultBGSMPath = "Data\\Materials\\DefaultEffect.bgem"
	local DefaultMaterialPath = "C:\\Projects\\Fallout4\\Build\\PC\\Data\\Materials\\"

	rollout BGSMatRollout "BGSMaterial" width:326 height:81
	(
		label lbl1 "Path:" pos:[5,9] width:29 height:17
		edittext BGSMatPathTexControl "" pos:[30,6] width:290 height:20 readOnly:true
		button BGSMatPathLoadControl "Load" pos:[10,34] width:45 height:19 toolTip:"Load/Link a BGEM to this material, overwriting any options currently set."
		button BGSMatPathSaveControl "Save" pos:[65,34] width:45 height:19 toolTip:"Save this material's data to the current BGEM (Select if none)."
		button BGSMatPathSaveAsControl "Save As" pos:[120,34] width:60 height:19 toolTip:"Save this material's data to a selected BGEM."
		button BGSMatPathRefreshControl "Refresh" pos:[190,34] width:60 height:19 toolTip:"Refresh the material with the contents of the current BGEM."
		button BGSMatPathDefaultControl "Default" pos:[260,34] width:56 height:19 toolTip:"Load/link the default BGEM to this material. This material will be read only."
		button BGSMatPathRevertControl "Revert" pos:[200,58] width:60 height:19 toolTip:"Revert the current BGEM in perforce and refresh this material with the reverted BGEM."
		button BGSMatPathUnlinkControl "Unlink" pos:[270,58] width:46 height:19 toolTip:"Remove the current BGEM path, but keep the material data."
		button BGSMatPathCheckoutControl "Checkout/Add" pos:[10,58] width:95 height:19
		button BGSMatPathGetLatestControl "Get Latest" pos:[115,58] width:75 height:19
		
		fn ClearPaths =
		(
			BGSMatPathParam = ""
			BGSMatPathRelativeParam = ""
			BGSMatInit = true
		)
		
		fn SetRelativeMatPath filePath =
		(
			shortPath = GetRelativeMatPath(filePath)
			if shortPath != undefined then
				BGSMatPathTexControl.text = shortPath
			else MessageBox @"Invalid path. Must be somewhere in \Data\Materials"
			
			shortPath
		)
		
		fn BGSMatRolloutOpen =
		(
			if not BGSMatInit then ClearPaths()
		)
		
		fn SaveBGSMaterial =
		(
			bretVal = false
			if stricmp (filenameFromPath BGSMatPathParam) "DefaultEffect.bgem" == 0 then
				MessageBox "You cannot save to the Default material file."
			else if not doesFileExist BGSMatPathParam or not getFileAttribute BGSMatPathParam #readOnly then
			(
				if (SaveEffectFXToBGEM this BGSMatPathParam) == undefined then
					MessageBox "Unable to save material file."
				else
				(
					bretVal = true
					UpdateAllRollouts()
				)
			)
			else
				MessageBox "This file is read only. Please check out from perforce."
			bretVal
		)
		
		--Returns the path to the material folder of the currently set material file, or the default if none.
		fn GetMaterialFilePathOrDefault = 
		(
			if BGSMatPathParam != undefined and BGSMatPathParam != "" then
			(
				matPath = (GetFilenamePath BGSMatPathParam)
				if doesFileExist matPath then
					localMatPath = matPath
			)
			if localMatPath == undefined then
				localMatPath = GetRootDataPath childFolder:"Materials"
			
			localMatPath
		)
		
		on BGSMatRollout open do
			(BGSMatRolloutOpen())
		on BGSMatPathLoadControl pressed do
		(
			matPath = GetMaterialFilePathOrDefault()
			filePath = getOpenFileName caption:"Select a .BGEM to load:" types:"Bethesda Game Effect Material (*.BGEM)|*.BGEM" historyCategory:"BGEMaterial" filename:matPath
			if filePath != undefined then
			(
				bRefreshFromBGEM = true
				if SetRelativeMatPath(filePath) != undefined then
					BGSMatPathParam = filePath
			)
		)
		on BGSMatPathSaveControl pressed do
		(
			if BGSMatPathParam == undefined or BGSMatPathParam == "" then
				BGSMatPathSaveAsControl.pressed()
			else
				SaveBGSMaterial()
		)
		on BGSMatPathSaveAsControl pressed do
		(
			matPath = GetMaterialFilePathOrDefault()
			filePath = getSaveFileName caption:"Select a .BGEM to save to:" types:"Bethesda Game Effect Material (*.BGEM)|*.BGEM" historyCategory:"BGEMaterial" filename:matPath
			if filePath != undefined then
			(
				if SetRelativeMatPath(filePath) != undefined then
					BGSMatPathParam = filePath
				if SaveBGSMaterial() then
					CheckoutOrAddFile BGSMatPathParam -- add the file to perforce as well, since chances are they'll want that anyway
			)
		)
		on BGSMatPathRefreshControl pressed do
		(
			bRefreshFromBGEM = true
			RefreshMaterial BGSMatPathParam
		)
		on BGSMatPathDefaultControl pressed do
		(
			--Set non-interactable (except for BGSMat data)
			localDefault = BuildPathUsingLocalDataRoot DefaultBGSMPath dataRelativePrefix:"Materials" 
			if localDefault != undefined and localDefault != DefaultBGSMPath then
			(
				bRefreshFromBGEM = true
				if SetRelativeMatPath(localDefault) != undefined then
					BGSMatPathParam = localDefault
			)
		)
		on BGSMatPathRevertControl pressed do
		(
			if BGSMatPathParam != undefined and BGSMatPathParam != "" then
			(
				RevertFile BGSMatPathParam
				BGSMatPathRefreshControl.pressed()
			)
		)
		on BGSMatPathUnlinkControl pressed do
		(
			BGSMatPathParam = ""
			BGSMatPathRelativeParam = ""
			UpdateAllRollouts()
		)
		on BGSMatPathCheckoutControl pressed do
		(
			if BGSMatPathParam != undefined and BGSMatPathParam != "" then
			(
				BGSMatPathGetLatestControl.pressed()
				CheckoutOrAddFile BGSMatPathParam
				UpdateAllRollouts()
			)
		)
		on BGSMatPathGetLatestControl pressed do
		(
			if BGSMatPathParam != undefined and BGSMatPathParam != "" then
			(
				--Do get latest of the single file.
				SyncFile BGSMatPathParam
				BGSMatPathRefreshControl.pressed()
			)
		)
	)
	
	local FXFilename = "EffectMAX.fx"
	rollout MainRollout "Parameters" width:326 height:775
	(
		-- Base
		GroupBox grpBase "Base" pos:[6,6] width:140 height:107
		checkbox ShowBaseControl "Show" pos:[17,26] width:51 height:15
		colorPicker BaseColorControl "Color" pos:[17,46] width:68 height:20
		spinner BaseColorScaleControl "Scale" pos:[26,73] width:72 height:16 range:[0,360,0] scale:0.01 fieldwidth:40
		
		-- Misc
		GroupBox grpMisc "Misc" pos:[158,6] width:160 height:107
		checkbox ShowVertexColorControl "Show Vertex Color" pos:[171,21] width:111 height:15
		checkbox TwoSidedControl "Two Sided" pos:[171,39] width:75 height:15
		checkbox DecalControl "Decal" pos:[171,57] width:75 height:15
		checkbox DecalNoFadeControl "Decal No Fade" pos:[171,75] width:117 height:15
		checkbox ScreenSpaceReflectionsControl "Screen Space Reflections" pos:[171,93] width:140 height:15
		
		-- Falloff
		GroupBox grpFalloff "Falloff" pos:[6,117] width:312 height:87
		checkbox FalloffAlphaControl "Alpha" pos:[17,135] width:57 height:15
		checkbox FalloffColorControl "Color" pos:[74,135] width:57 height:15
		spinner FalloffStartAngleControl "Start Angle" pos:[64,156] width:80 height:16 range:[0,360,0] scale:0.1 fieldwidth:40
		spinner FalloffStopAngleControl "Stop Angle" pos:[62,177] width:82 height:16 range:[0,360,0] scale:0.1 fieldwidth:40
		spinner FalloffStartValueControl "Start Value" pos:[188,156] width:91 height:16 range:[0,1,0] scale:0.01 fieldwidth:40
		spinner FalloffStopValueControl "Stop Value" pos:[189,177] width:90 height:16 range:[0,1,0] scale:0.01 fieldwidth:40
		
		-- Z Test, Write
		GroupBox grpZBuffer "Z Buffer" pos:[6,298] width:146 height:48
		checkbox ZTestControl "Z Test" pos:[20,317] width:55 height:15
		checkbox ZWriteControl "Z Write" pos:[85,317] width:59 height:15
		
		-- Lighting
		GroupBox grpLighting "Lighting" pos:[157,298] width:161 height:48
		checkbox LightingEnableControl "Enable" pos:[165,317] width:59 height:15 enabled:true
		spinner LightingInfluenceControl "Influence" pos:[222,318] width:90 height:16 range:[-1.0,1,0] scale:0.01 fieldwidth:32
		
		-- Soft
		GroupBox grpSoft "Soft" pos:[7,441] width:311 height:48
		checkbox SoftControl "Enable" pos:[19,463] width:59 height:15 enabled:true
		spinner SoftDepthControl "Depth" pos:[126,464] width:82 height:16 range:[0,9999,100] scale:1 fieldwidth:40
		
		-- Grayscale
		GroupBox grpGrayscale "Grayscale To Palette" pos:[7,493] width:311 height:48
		checkbox GrayscaleColorEnableControl "Color" pos:[19,513] width:59 height:15 enabled:true
		checkbox GrayscaleAlphaEnableControl "Alpha" pos:[100,513] width:59 height:15 enabled:true
		
		-- Alpha
		GroupBox grpAlpha "Alpha" pos:[6,207] width:312 height:88
		checkbox AlphaControl "Alpha Test" pos:[113,274] width:91 height:15
		spinner AlphaValueControl "Base" pos:[77,227] width:57 height:16 range:[0,90,1] scale:0.01 fieldwidth:40
		spinner AlphaRefControl "Alpha Test Ref" pos:[32,251] width:101 height:16 range:[0,255,128] scale:1 fieldwidth:40
		radiobuttons AlphaBlendControl "Blend Mode" pos:[148,222] width:168 height:46 labels:#("Standard", "Additive", "Multiplicative", "None") columns:2
		
		-- Blood
		GroupBox grpBlood "Blood" pos:[6,349] width:312 height:89
		checkbox BloodEnableControl "Enable" pos:[20,369] width:55 height:15
		spinner BloodFalloffThreshControl "[GameSetting] Falloff Threshold" pos:[90,390] width:184 height:16 range:[0,1,1] scale:0.01 fieldwidth:40
		spinner BloodAlphaToRGBScaleControl "[GameSetting] Alpha To RGB Scale" pos:[68,410] width:206 height:16 range:[0,1,1] scale:0.01 fieldwidth:40
		
		-- Envmap params
		GroupBox grpEnvmap "Environment Mapping" pos:[7,543] width:146 height:60
		spinner EnvmapScaleControl "Scale" pos:[6,558] width:90 height:16 range:[0.01,20,1] scale:0.01 fieldwidth:32
		spinner EnvmapMinLODControl "Min LOD" pos:[6,583] width:90 height:16 range:[0,16,0] scale:1 fieldwidth:32
		
		-- Refraction
		GroupBox grpRefraction "Refraction" pos:[164,543] width:154 height:60
		checkbox RefractionControl "Enable" pos:[177,559] width:73 height:15
		spinner RefractionPowerControl "Power" pos:[183,578] width:76 height:16 range:[0,1,0] scale:0.001 fieldwidth:40
		checkbox RefractionFireControl "Falloff" pos:[258,559] width:48 height:15
		
		GroupBox grpTextures "Textures" pos:[6,610] width:312 height:230
		
		-- Base Texture
		checkbox BaseTexEnableControl "Base Texture" pos:[18,625] width:96 height:15
		button BaseTexControl "None" pos:[104,623] width:112 height:21
		button BaseTexReloadControl "Reload" pos:[219,623] width:43 height:21
		button BaseTexViewControl "View" pos:[265,623] width:34 height:21
		button BaseTexClearControl "X" pos:[302,623] width:12 height:21
		
		-- Grayscale Texture
		checkbox GrayscaleTexEnableControl "Palette Tex" pos:[18,653] width:96 height:15
		button GrayscaleTexControl "None" pos:[104,651] width:112 height:21
		button GrayscaleTexReloadControl "Reload" pos:[219,651] width:43 height:21
		button GrayscaleTexViewControl "View" pos:[265,651] width:34 height:21
		button GrayscaleTexClearControl "X" pos:[302,651] width:12 height:21
		
		-- Envmap Texture
		checkbox EnvmapTexEnableControl "Envmap Tex" pos:[18,681] width:96 height:15
		button EnvmapTexControl "None" pos:[104,679] width:112 height:21
		button EnvmapTexReloadControl "Reload" pos:[219,679] width:43 height:21
		button EnvmapTexViewControl "View" pos:[265,679] width:34 height:21
		button EnvmapTexClearControl "X" pos:[302,679] width:12 height:21
		
		-- Envmap Mask Texture
		checkbox EnvmapMaskTexEnableControl "Envmap Mask Tex" pos:[18,709] width:96 height:15
		button EnvmapMaskTexControl "None" pos:[104,707] width:112 height:21
		button EnvmapMaskTexReloadControl "Reload" pos:[219,707] width:43 height:21
		button EnvmapMaskTexViewControl "View" pos:[265,707] width:34 height:21
		button EnvmapMaskTexClearControl "X" pos:[302,707] width:12 height:21

		-- Normal Texture
		checkbox NormalTexEnableControl "Normal Tex" pos:[18,737] width:96 height:15
		button NormalTexControl "None" pos:[104,735] width:112 height:21
		button NormalTexReloadControl "Reload" pos:[219,735] width:43 height:21
		button NormalTexViewControl "View" pos:[265,735] width:34 height:21
		button NormalTexClearControl "X" pos:[302,735] width:12 height:21
		
		-- UV Tiling
		checkbox UTilingControl "U Tiling" pos:[80,767] width:60 height:15
		checkbox VTilingControl "V Tiling" pos:[186,767] width:59 height:15
		
		-- UV Offsets
		spinner UOffsetControl "U Offset" pos:[55,788] width:80 height:16 range:[-100,100,0] scale:0.001 fieldwidth:40
		spinner VOffsetControl "V Offset" pos:[167,788] width:83 height:16 range:[-100,100,0] scale:0.001 fieldwidth:40
		spinner UScaleControl "U Scale" pos:[55,809] width:80 height:16 range:[-100,100,0] scale:0.001 fieldwidth:40
		spinner VScaleControl "V Scale" pos:[168,809] width:82 height:16 range:[-100,100,0] scale:0.001 fieldwidth:40
		
		-- Reload FX File
		button ReloadFXControl "Reload FX File" pos:[65,849] width:85 height:21
		
		button SettingsControl "Settings" pos:[162,849] width:85 height:21
		
		fn UpdateMainRollout abEnabled =
		(
			-- Base
			grpBase.enabled = abEnabled
			ShowBaseControl.enabled = abEnabled
			BaseColorControl.enabled = abEnabled
			BaseColorScaleControl.enabled = abEnabled
			
			-- Misc
			grpMisc.enabled = abEnabled
			ShowVertexColorControl.enabled = abEnabled
			TwoSidedControl.enabled = abEnabled
			DecalControl.enabled = abEnabled
			DecalNoFadeControl.enabled = abEnabled
			
			-- Falloff
			grpFalloff.enabled = abEnabled
			FalloffAlphaControl.enabled = abEnabled
			FalloffColorControl.enabled = abEnabled
			FalloffStartAngleControl.enabled = (FalloffParam or FalloffColorParam) and abEnabled
			FalloffStopAngleControl.enabled = (FalloffParam or FalloffColorParam)  and abEnabled
			FalloffStartValueControl.enabled = (FalloffParam or FalloffColorParam)  and abEnabled
			FalloffStopValueControl.enabled = (FalloffParam or FalloffColorParam)  and abEnabled
			
			-- ZTest
			grpZBuffer.enabled = abEnabled
			ZTestControl.enabled = abEnabled
			ZWriteControl.enabled = abEnabled
			
			-- Lighting
			grpLighting.enabled = abEnabled
			LightingEnableControl.enabled = abEnabled
			LightingInfluenceControl.enabled = LightingParam and abEnabled
		
			-- Soft
			grpSoft.enabled = abEnabled
			SoftControl.enabled = abEnabled
			SoftDepthControl.enabled = SoftParam and abEnabled
			
			-- Grayscale
			grpGrayscale.enabled = abEnabled
			GrayscaleColorEnableControl.enabled = abEnabled
			GrayscaleAlphaEnableControl.enabled = abEnabled
			
			-- Alpha
			grpAlpha.enabled = abEnabled
			AlphaControl.enabled = abEnabled
			AlphaValueControl.enabled = abEnabled and (AlphaParam or (AlphaBlendParam != 4))
			AlphaRefControl.enabled = abEnabled
			AlphaBlendControl.enabled = abEnabled
			
			-- Blood
			grpBlood.enabled = abEnabled
			BloodEnableControl.enabled = abEnabled
			BloodFalloffThreshControl.enabled = abEnabled
			BloodAlphaToRGBScaleControl.enabled = abEnabled
			
			-- Environment mapping
			grpEnvmap.enabled = abEnabled
			EnvmapScaleControl.enabled = abEnabled
			EnvmapMinLODControl.enabled = abEnabled
			
			-- Refraction
			grpRefraction.enabled = abEnabled
			RefractionControl.enabled = abEnabled
			RefractionPowerControl.enabled = RefractionParam and abEnabled
			RefractionFireControl.enabled = RefractionParam and abEnabled
			
			-- Base texture
			SetBitmapButtonText BaseTexControl this "baseTexture"
			BaseTexEnableControl.enabled = abEnabled
			BaseTexControl.enabled = abEnabled
			BaseTexReloadControl.enabled = true
			BaseTexViewControl.enabled = true
			BaseTexClearControl.enabled = abEnabled
			
			-- Grayscale texture
			SetBitmapButtonText GrayscaleTexControl this "grayscaleTexture"
			GrayscaleTexEnableControl.enabled = abEnabled
			GrayscaleTexControl.enabled = abEnabled
			GrayscaleTexReloadControl.enabled = true
			GrayscaleTexViewControl.enabled = true
			GrayscaleTexClearControl.enabled = abEnabled
			
			-- Envmap texture
			SetBitmapButtonText EnvmapTexControl this "envmapTexture"
			EnvmapTexEnableControl.enabled = abEnabled
			EnvmapTexControl.enabled = abEnabled
			EnvmapTexReloadControl.enabled = true
			EnvmapTexViewControl.enabled = true
			EnvmapTexClearControl.enabled = abEnabled
			
			-- Envmap mask texture
			SetBitmapButtonText EnvmapMaskTexControl this "envmapMaskTexture"
			EnvmapMaskTexEnableControl.enabled = abEnabled
			EnvmapMaskTexControl.enabled = abEnabled
			EnvmapMaskTexReloadControl.enabled = true
			EnvmapMaskTexViewControl.enabled = true
			EnvmapMaskTexClearControl.enabled = abEnabled
			
			-- Normal texture
			SetBitmapButtonText NormalTexControl this "normalTexture"
			NormalTexEnableControl.enabled = abEnabled
			NormalTexControl.enabled = abEnabled
			NormalTexReloadControl.enabled = true
			NormalTexViewControl.enabled = true
			NormalTexClearControl.enabled = abEnabled
			
			-- UV Tiling
			UTilingControl.enabled = abEnabled
			VTilingControl.enabled = abEnabled
			
			-- UV Offsets
			UOffsetControl.enabled = abEnabled
			VOffsetControl.enabled = abEnabled
			UScaleControl.enabled = abEnabled
			VScaleControl.enabled = abEnabled
		)
		
		-- Separate function to be called from the rollout open handler or when we want to reset the rollout
		-- Needed because calling <rollout>.open() doesn't work (open is a property and a handler on a rollout)
		fn RolloutOpen =
		(
			-- If this is called from plugin postload the delegate can be undefined
			if delegate != undefined then
			(
				UpdateMainRollout (BGSMatPathParam == "" or (CanEditBGEM BGSMatPathParam))
			)
		)
		
		fn UpdateMapPaths =
		(
			UpdateTexturePath this "baseTexture"
			UpdateTexturePath this "grayscaleTexture"
			UpdateTexturePath this "envmapTexture"
			UpdateTexturePath this "envmapMaskTexture"
			UpdateTexturePath this "normalTexture"
		)
		
		-- Event handlers for updating textures
		on MainRollout open do
			(MainRollout.RolloutOpen())
				
		on BaseTexControl pressed do
			(SelectFXBitmap this "baseTexture" BaseTexControl)
		on BaseTexReloadControl pressed do
			(ReloadFXBitmap this "baseTexture")
		on BaseTexViewControl pressed do
			(DisplayFXBitmap this "baseTexture")
		on BaseTexClearControl pressed do
			(ClearFXMapPath this "baseTexture" BaseTexControl BaseTexEnableControl)

		on GrayscaleTexControl pressed do
			(SelectFXBitmap this "grayscaleTexture" GrayscaleTexControl)
		on GrayscaleTexReloadControl pressed do
			(ReloadFXBitmap this "grayscaleTexture")
		on GrayscaleTexViewControl pressed do
			(DisplayFXBitmap this "grayscaleTexture")
		on GrayscaleTexClearControl pressed do
			(ClearFXMapPath this "grayscaleTexture" GrayscaleTexControl GrayscaleTexEnableControl)
		
		on EnvmapTexControl pressed do
			(SelectFXBitmap this "envmapTexture" EnvmapTexControl)
		on EnvmapTexReloadControl pressed do
			(ReloadFXBitmap this "envmapTexture")
		on EnvmapTexViewControl pressed do
			(DisplayFXBitmap this "envmapTexture")
		on EnvmapTexClearControl pressed do
			(ClearFXMapPath this "envmapTexture" EnvmapTexControl EnvmapTexEnableControl)
				
		on EnvmapMaskTexControl pressed do
			(SelectFXBitmap this "envmapMaskTexture" EnvmapMaskTexControl)
		on EnvmapMaskTexReloadControl pressed do
			(ReloadFXBitmap this "envmapMaskTexture")
		on EnvmapMaskTexViewControl pressed do
			(DisplayFXBitmap this "envmapMaskTexture")
		on EnvmapMaskTexClearControl pressed do
			(ClearFXMapPath this "envmapMaskTexture" EnvmapMaskTexControl EnvmapMaskTexEnableControl)
		
		on NormalTexControl pressed do
			(SelectFXBitmap this "normalTexture" NormalTexControl)
		on NormalTexReloadControl pressed do
			(ReloadFXBitmap this "normalTexture")
		on NormalTexViewControl pressed do
			(DisplayFXBitmap this "normalTexture")
		on NormalTexClearControl pressed do
			(ClearFXMapPath this "normalTexture" NormalTexControl NormalTexEnableControl)
		
		on ReloadFXControl pressed do
			(ReloadFXFile this FXFilename)
		on SettingsControl pressed do
			(CreateDialog SettingsRollout)
	)
	
	-- Set .fx file in the DirectX material
	on create do (ReloadFXFile this FXFilename)
	-- Make sure everything is updated on load
	on postLoad do (MainRollout.RolloutOpen())
		
	fn UpdateAllMapPaths =
	(
		MainRollout.UpdateMapPaths()
	)
	
	fn UpdateAllRollouts abForceEnabled:false = 
	(
		if MainRollout.open then -- Don't bother updating the rollout if it's not even visible yet.
		(
			benable = abForceEnabled or BGSMatPathParam == "" or (CanEditBGEM BGSMatPathParam)
		
			(SetRolloutEnableState MainRollout benable aRefreshUIFunction:MainRollout.UpdateMainRollout)
		)
	)
	
	--Utility function to set a BGEM on the current material
	fn TrySetMatParam aFullMaterialPath =
	(
		if aFullMaterialPath != undefined then
		(
			shortPath = GetRelativeMatPath(aFullMaterialPath)
			if shortPath != undefined then
			(
				bRefreshFromBGEM = true
				
				--We know we're explicitly setting the params, so mark us as already initialized.
				BGSMatInit = true
				BGSMatPathRelativeParam = shortPath
				BGSMatPathParam = aFullMaterialPath
			)
			else MessageBox @"Invalid path. Must be somewhere in \Data\Materials"
		)
	)
)