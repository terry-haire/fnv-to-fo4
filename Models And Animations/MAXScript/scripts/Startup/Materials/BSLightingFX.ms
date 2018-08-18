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

global bPreFileOpenG

plugin material BSLightingFX
	name:"BSLightingFX"
	classID:#(0x4cdce7fb, 0x50191395)
	extends:DirectX_9_Shader
	replaceUI:true
	version:1

(		
	-- Combines the Ambient and Diffuse colors from 3DSMax into the ambient color in the shader
	fn SetAmbientDiffuse =
	(
		with animate off
		(
			this.delegate.bShowDiffuse = this.ShowDiffuseParam
			this.delegate.bShowAmbient = this.ShowAmbientParam or this.ShowDiffuseParam
			
			newColor = color 0 0 0 0
			if(this.ShowAmbientParam) then newColor += ambientColor
			-- Only add diffuse color if diffuse texture is disabled
			if(this.ShowDiffuseParam and not this.DiffuseEnableParam) then newColor += this.DiffuseColorParam
			-- Color values can be > 255, cap them
			newColor.r = amin 255 newColor.r; newColor.g = amin 255 newColor.g; newColor.b = amin 255 newColor.b; newColor.a = amin 255 newColor.a
			this.delegate.ambientColor = newColor
		)
	)
	
	-- Resets ambient and diffuse for all BSLightingFX materials in the material editor
	fn ResetAllMaterialColor =
	(
		for i=1 to sceneMaterials.count do
		(
			if (sceneMaterials[i].classID[1] == BSLightingFX.classID[1] and sceneMaterials[i].classID[2] == BSLightingFX.classID[2]) then
			(
				sceneMaterials[i].SetAmbientDiffuse()
			)
			else if (sceneMaterials[i].classID[1] == Multimaterial.classID[1] and sceneMaterials[i].classID[2] == Multimaterial.classID[2]) then
			(
				-- Sub-materials one layer deep are supported. The exporter assumes nested multi-materials are not present.
				for j=1 to sceneMaterials[i].numsubs do
				(
					if (sceneMaterials[i][j].classID[1] == BSLightingFX.classID[1] and sceneMaterials[i][j].classID[2] == BSLightingFX.classID[2]) then
						sceneMaterials[i][j].SetAmbientDiffuse()
				)
			)
		)
	)
	
	-- Ensures only one unique feature is set
	fn EnforceSingleUniqueFeature aUpdatedFeature = 
	(
		local newFeatureVal = getProperty this aUpdatedFeature
		if((classof newFeatureVal == Integer and newFeatureVal != 1) or
			(classof newFeatureVal == BooleanClass and newFeatureVal)) then
		(
			-- Turn all unique features off and then turn the single feature on
			this.ApplyGlowmapToEmitParam = false
			this.RefractionParam = false
			-- Allow multi-layer parallax and environment mapping to be enabled at same time.
			if( aUpdatedFeature != "EnvmapParam" or this.ParallaxModeParam != 4 ) then
			(
				this.ParallaxModeParam = 1
			)
		    if( this.ParallaxModeParam != 1 ) then
	  		(
	        	this.EnvmapParam = false
			)

			this.HairParam = false
			this.TreeParam = false
			
			setProperty this aUpdatedFeature newFeatureVal
		)
	)
	
	parameters MainParams rollout:MainRollout
	(
		-- View
		ShowAmbientParam type:#boolean default:false ui:ShowAmbientControl animatable:false
		on ShowAmbientParam set arg do (SetAmbientDiffuse())
		DiffuseColorParam type:#color default:[128,128,128] ui:DiffuseColorControl animatable:false
		on DiffuseColorParam set arg do (SetAmbientDiffuse())
		ShowDiffuseParam type:#boolean default:false ui:ShowDiffuseControl animatable:false
		on ShowDiffuseParam set arg do (SetAmbientDiffuse())
		ShowTextureParam type:#boolean default:false ui:ShowTextureControl animatable:false
		on ShowTextureParam set arg do (animate off delegate.bShowTexture = arg)
		ShowVertexColorParam type:#boolean default:false ui:ShowVertexColorControl animatable:false
		on ShowVertexColorParam set arg do (animate off delegate.bVertexColorsEnabled = arg)
		ShowSpecularParam type:#boolean default:false ui:ShowSpecularControl animatable:false
		on ShowSpecularParam set arg do (animate off delegate.bSpecularEnabled = (arg and this.SpecularParam))
		ShowNormalMapParam type:#boolean default:false ui:ShowNormalMapControl animatable:false
		on ShowNormalMapParam set arg do (animate off delegate.bUseNormalMap = arg)
		ShowAlphaParam type:#boolean default:false ui:ShowAlphaControl animatable:false
		on ShowAlphaParam set arg do (animate off delegate.bShowAlpha = arg)
		ShowLeafWeightsParam type:#boolean default:false ui:ShowLeafWeightsControl animatable:false
		on ShowLeafWeightsParam set arg do (animate off delegate.bShowLeafWeights = arg)
			
		-- Alpha
		AlphaParam type:#boolean default:false ui:AlphaControl animatable:false
		AlphaValueParam type:#float default:1.0 ui:AlphaValueControl
		on AlphaValueParam get arg do (animate off delegate.MatAlpha = arg)
		AlphaRefParam type:#integer default:128 ui:AlphaRefControl
		on AlphaRefParam get arg do (animate off delegate.g_AlphaRef = arg)
		AlphaBlendParam type:#integer default:4 ui:AlphaBlendControl animatable:false
		on AlphaParam set arg do
		(
			animate off delegate.g_AlphaTest = arg
			this.MainRollout.AlphaValueControl.enabled = arg or (4 != AlphaBlendParam)
		)
		on AlphaBlendParam set arg do
		(
			with animate off
			(
				delegate.g_AlphaStandard = (1 == arg)
				delegate.g_AlphaAdd = (2 == arg)
				delegate.g_AlphaMult = (3 == arg)
			)
			this.MainRollout.AlphaValueControl.enabled = (4 != arg) or AlphaParam
		)
		EditorAlphaTestRef type:#boolean default:false ui:EditorAlphaTestRefControl animatable:false

		-- Z Test, Write
		ZTestParam type:#boolean default:true ui:ZTestControl animatable:false
		on ZTestParam set arg do (animate off delegate.bZTestEnabled = arg)
		ZWriteParam type:#boolean default:true ui:ZWriteControl animatable:false
		on ZWriteParam set arg do (animate off delegate.bZWriteEnabled = arg)
		
		-- SubSurface Lighting
		SubSurfaceLightingParam type:#boolean default:false ui:SubSurfaceLightingControl animatable:false
		on SubSurfaceLightingParam set arg do
		(
			this.MainRollout.SubSurfaceRolloffControl.enabled = arg
			animate off delegate.bSubSurfaceLightingEnabled = arg
		)
		SubSurfaceRolloffParam type:#float default:0.3 ui:SubSurfaceRolloffControl
		on SubSurfaceRolloffParam get arg do (animate off delegate.fSubSurfaceLightRolloff = arg)
		
		-- Back Lighting
		BackLightingPowerParam type:#float default:0.0 ui:BackLightingPowerControl
		on BackLightingPowerParam get arg do (animate off delegate.fBackLightPower = arg)
		
		-- Specular
		SpecularParam type:#boolean default:true ui:SpecularControl animatable:false
		SpecularColorParam type:#color default:white ui:SpecularColorControl
		on SpecularColorParam get arg do (animate off delegate.SpecularColor = arg)
		SmoothnessParam type:#float default:1.0 ui:SmoothnessControl
		on SmoothnessParam get arg do (animate off delegate.fSmoothness = arg)
		SpecularScaleParam type:#float default:1.0 ui:SpecularScaleControl
		on SpecularScaleParam get arg do (animate off delegate.fSpecularScale = arg)
		AnisoLightingParam type:#boolean default:false ui:AnisoLightingControl
		on AnisoLightingParam set arg do (animate off delegate.bAnisoLightingEnabled = arg)
		on SpecularParam set arg do
		(
			animate off delegate.bSpecularEnabled = arg
			this.MainRollout.SpecularColorControl.enabled = arg
			this.MainRollout.SpecularScaleControl.enabled = arg
			this.MainRollout.AnisoLightingControl.enabled = arg
		)
		
		-- Emit
		ShowEmitParam type:#boolean default:false ui:ShowEmitControl animatable:false
		on ShowEmitParam set arg do
		(
			this.MainRollout.EmitScaleControl.enabled = arg
			this.MainRollout.EmitScaleControl.enabled = arg
			this.MainRollout.EmitColorControl.enabled = arg
			animate off delegate.bShowEmit = arg
		)
		EmitScaleParam type:#float default:1.0 ui:EmitScaleControl
		on EmitScaleParam get arg do (animate off delegate.fEmitScale = arg)
		EmitColorParam type:#color ui:EmitColorControl
		on EmitColorParam get arg do (animate off delegate.EmitColor = arg)
		
		-- Unique Features --

		-- Glowmap
		ApplyGlowmapToEmitParam type:#boolean default:false ui:ApplyGlowmapToEmitControl animatable:false
		on ApplyGlowmapToEmitParam set arg do
		(
			EnforceSingleUniqueFeature "ApplyGlowmapToEmitParam"
		)
		
		-- Refraction
		RefractionParam type:#boolean default:false ui:RefractionControl animatable:false
		on RefractionParam set arg do
		(
			EnforceSingleUniqueFeature "RefractionParam"
			this.MainRollout.RefractionPowerControl.enabled = arg
			this.MainRollout.RefractionFireControl.enabled = arg
			animate off delegate.bRefractionEnabled = arg
		)
		RefractionPowerParam type:#float default:0.0 ui:RefractionPowerControl
		on RefractionPowerParam get arg do (animate off delegate.fRefractionPower = arg)
		RefractionFireParam type:#boolean default:false ui:RefractionFireControl animatable:false
		on RefractionFireParam get arg do (animate off delegate.bRefractionFalloffEnabled = arg)
		
		-- Parallax
		ParallaxModeParam type:#integer default:1 ui:ParallaxModeControl animatable:false
		on ParallaxModeParam set arg do
		(
			-- Disabling parallax until it is re-implemented again
			EnforceSingleUniqueFeature "ParallaxModeParam"
			this.ParallaxParam = (arg == 2)
			this.ParallaxOccParam = (arg == 3)
			this.MultiLayerParallaxParam = (arg == 4)
			
			-- Height texture only enabled for "Standard" or "Occlusion" modes
			-- Disabled because height texture has been replaced by grayscale texture
			--this.HeightEnableParam = false --(arg == 2 or arg == 3)
			--this.MapRollout.HeightEnableControl.enabled = false --this.HeightEnableParam
			--this.MapRollout.HeightTexControl.enabled = false --this.HeightEnableParam
		)
		ParallaxParam type:#boolean default:false animatable:false
		on ParallaxParam set arg do (animate off delegate.bParallaxEnabled = arg)
		ParallaxOccParam type:#boolean default:false animatable:false
		on ParallaxOccParam set arg do
		(
			-- Disabling parallax until it is re-implemented again
			this.MainRollout.grpParallaxOcclusion.enabled = false --arg
			this.MainRollout.ParallaxHeightScaleControl.enabled = false --arg
			this.MainRollout.ParallaxStepsControl.enabled = false --arg
			animate off delegate.bParallaxOccEnabled = arg
		)
		MultiLayerParallaxParam type:#boolean default:false animatable:false
		on MultiLayerParallaxParam set arg do
		(
			-- Disabling parallax until it is re-implemented again
			this.MainRollout.grpParallaxMultiLayer.enabled = false --arg
			this.MainRollout.ParallaxThicknessControl.enabled = false --arg
			this.MainRollout.ParallaxRefractionScaleControl.enabled = false --arg
			this.MainRollout.ParallaxInnerUScaleControl.enabled = false --arg
			this.MainRollout.ParallaxInnerVScaleControl.enabled = false --arg
			--if( ParallaxModeParam != 1 ) then
				--this.EnvmapParam = arg
			--this.MainRollout.EnvmapControl.enabled = not arg
			animate off delegate.bMultiLayerParallaxEnabled = arg
		)
		ParallaxHeightScaleParam type:#float default:1.0 ui:ParallaxHeightScaleControl
		on ParallaxHeightScaleParam get arg do (animate off delegate.ParallaxHeightScale = arg)
		ParallaxStepsParam type:#integer default:4 ui:ParallaxStepsControl
		on ParallaxStepsParam get arg do (animate off delegate.ParallaxNumSteps = arg)
		ParallaxThicknessParam type:#float default:10.0 ui:ParallaxThicknessControl
		on ParallaxThicknessParam get arg do (animate off delegate.fParallaxLayerThickness = arg)
		ParallaxRefractionScaleParam type:#float default:1.0 ui:ParallaxRefractionScaleControl
		on ParallaxRefractionScaleParam get arg do (animate off delegate.fParallaxRefractionScale = arg)
		ParallaxInnerUScaleParam type:#float default:1.0 ui:ParallaxInnerUScaleControl
		on ParallaxInnerUScaleParam get arg do (animate off delegate.fParallaxInnerLayerUScale = arg)
		ParallaxInnerVScaleParam type:#float default:1.0 ui:ParallaxInnerVScaleControl
		on ParallaxInnerVScaleParam get arg do (animate off delegate.fParallaxInnerLayerVScale = arg)
		
		-- Hair
		HairParam type:#boolean default:false ui:HairControl animatable:false

		HairColorParam type:#color default:gray ui:HairColorControl animatable:false
		on HairColorParam set arg do (animate off delegate.HairTintColor = arg)
		
		-- Environment Mapping
		EnvmapParam type:#boolean default:false ui:EnvmapControl animatable:false
		on EnvmapParam set arg do
		(
			EnforceSingleUniqueFeature "EnvmapParam"
			this.MainRollout.EnvmapScaleControl.enabled = arg
			this.MainRollout.EnvmapEyeControl.enabled = arg
			this.MainRollout.EnvmapWindowControl.enabled = arg
			this.MainRollout.EnvmapLightFadeControl.enabled = arg
			animate off delegate.bEnvmapEnabled = arg
		)
		EnvmapScaleParam type:#float default:1.0 ui:EnvmapScaleControl
		on EnvmapScaleParam get arg do (animate off delegate.fEnvmapScale = arg)
		EnvmapEyeParam type:#boolean default:false ui:EnvmapEyeControl animatable:false
		on EnvmapEyeParam set arg do (animate off delegate.bEnvmapEye = arg)
		EnvmapWindowParam type:#boolean default:false ui:EnvmapWindowControl animatable:false
		on EnvmapWindowParam set arg do (animate off delegate.bEnvmapWindow = arg)
		EnvmapLightFadeParam type:#boolean default:true ui:EnvmapLightFadeControl animatable:false
		on EnvmapLightFadeParam set arg do (animate off delegate.bEnvmapLightFade = arg)
		
		-- Tree
		TreeParam type:#boolean default:false ui:TreeControl animatable:false
		on TreeParam set arg do (
			EnforceSingleUniqueFeature "TreeParam"
			animate off delegate.bTreeAnim = arg
		)
		
		-- Grayscape palette mapping parameter (gradient mapping)
		GrayscaleColorParam type:#boolean default:false ui:GrayscaleColorEnableControl animatable:false
		GrayscaleColorScaleParam type:#float default:0.5 ui:GrayscaleColorScaleControl animatable:false
		on GrayscaleColorScaleParam set arg do (
			scaledColor = arg * 255
			animate off delegate.HairTintColor = color scaledColor scaledColor scaledColor
		)
		
		on GrayscaleColorParam set arg do (
			animate off delegate.bGrayscaleToColor = arg
			this.MainRollout.HairColorControl.enabled = not arg
			if arg then (
				HairParam = false
			)
		)
		
		on HairParam set arg do (
			EnforceSingleUniqueFeature "HairParam"
			animate off delegate.bHairEnabled = arg
			this.Mainrollout.GrayscaleColorScaleControl.enabled = not arg
			if arg then (
				GrayscaleColorParam = false
			)
		)
		
		-- Misc
		TwoSidedParam type:#boolean default:false ui:TwoSidedControl animatable:false
		on TwoSidedParam set arg do (animate off delegate.g_bTwoSided = arg)
		ModelSpaceNormalParam type:#boolean default:false ui:ModelSpaceNormalControl animatable:false
		on ModelSpaceNormalParam set arg do (animate off delegate.bModelSpaceNormals = arg)
		DecalParam type:#boolean default:false ui:DecalControl animatable:false
		on DecalParam set arg do (animate off delegate.bDecal = arg)
		DecalNoFadeParam type:#boolean default:false ui:DecalNoFadeControl animatable:false
		on DecalNoFadeParam set arg do (animate off delegate.bDecalNoFade = arg)
		ExternalEmittanceParam type:#boolean default:false ui:ExternalEmittanceControl animatable:false
		on ExternalEmittanceParam set arg do (animate off delegate.bExternalEmittance = arg)
		HideSecretParam type:#boolean default:false ui:HideSecretControl animatable:false
		on HideSecretParam set arg do (animate off delegate.bHideSecret = arg)
		CastShadowsParam type:#boolean default:true ui:CastShadowsControl animatable:false
		DissolveFadeParam type:#boolean default:false ui:DissolveFadeControl animatable:false
		ScreenSpaceReflectionsParam type:#boolean default:false ui:ScreenSpaceReflectionsControl animatable:false
		NonOccluderParam type:#boolean default:false ui:NonOccluderControl animatable:false
		
		-- Skin
		SkinTintParam type:#boolean default:false animatable:false -- Unused, old param
		SkinTypeParam type:#integer default:1 ui:SkinTypeControl animatable:false
	)
	
	parameters MapParams rollout:MapRollout
	(
		-- Diffuse Texture
		DiffuseEnableParam type:#boolean default:false ui:DiffuseEnableControl animatable:false
		on DiffuseEnableParam set arg do
		(
			SetAmbientDiffuse();
			this.MainRollout.ShowTextureControl.checked = arg
			animate off delegate.bDiffuseTexEnabled = arg
		)
		
		-- Normal Texture
		NormalEnableParam type:#boolean default:false ui:NormalEnableControl animatable:false
		on NormalEnableParam set arg do (animate off delegate.bNormalTexEnabled = arg)

		-- Smooth/Spec Texture
		SmoothSpecEnableParam type:#boolean default:false ui:SmoothSpecEnableControl animatable:false
		on SmoothSpecEnableParam set arg do (animate off delegate.bSmoothSpecMaskTexEnabled = arg)
		
		-- Grayscale palette remapping texture (replaces height texture, which is no longer used)
		GrayscaleTexEnableParam type:#boolean default:false ui:GrayscaleEnableControl animatable:false
		on GrayscaleTexEnableParam set arg do (animate off delegate.bGrayscaleToColor = arg)
		
		-- Envmap Texture
		EnvmapEnableParam type:#boolean default:false ui:EnvmapEnableControl animatable:false
		on EnvmapEnableParam set arg do (animate off delegate.bEnvTexEnabled = arg)
		
		-- Glow Texture
		GlowEnableParam type:#boolean default:false ui:GlowEnableControl animatable:false
		on GlowEnableParam set arg do (animate off delegate.bGlowTexEnabled = arg)

		-- Wrinkle Texture
		WrinkleEnableParam type:#boolean default:false ui:WrinkleEnableControl animatable:false
		on WrinkleEnableParam set arg do (animate off delegate.bWrinkleTexEnabled = arg)
		
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
	
	fn CanEditBGSM filePath =
	(
		(not doesFileExist filePath or not getFileAttribute filePath #readOnly)
	)
	
	--bRefreshFromBGSM is used to determine whether or not we want to reload the BGSM into the material (it gets called multiple times).
	local bRefreshFromBGSM = false
	fn RefreshMaterial filePath =
	(
		try
		(
			if bRefreshFromBGSM or bPreFileOpenG then
			(
				--NOTE: This call can be slow due to full effect reload.
				(LoadLightingFXFromBGSM this filePath)
				UpdateAllMapPaths()
			)
			
			UpdateAllRollouts()
		)
		catch
		(
			format "RefreshMaterial: %\n" (getCurrentException())
		)
		
		bRefreshFromBGSM = false
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
	
	fn GetRelativeTemplatePath filePath =
	(
		relPath = undefined
		materialRelativePath = GetRelativeMatPath filePath
		if materialRelativePath != undefined and materialRelativePath != "" then
		(
			-- Strip off the Materials\\ part, which GetRelativeMatPath will ensure we have
			-- But also make sure we're in the template folder
			index = (findString materialRelativePath "\\Template\\")
			if index != undefined then
				relPath = substring materialRelativePath (index+1) -1
		)
		
		relPath
	)
	
	local bupdating = false -- Prevents circular event handling when editing the mat param inside its own set handler.
	parameters BGSMatParams rollout:BGSMatRollout
	(
		BGSMatInit type:#boolean default:false
		BGSMatPathParam type:#string default:"" 
		BGSMatPathRelativeParam type:#string default:"" ui:BGSMatPathTexControl
		RootMatPathRelativeParam type:#string default:"" ui:RootMatPathTexControl
		
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
	
	local DefaultBGSMPath = "Data\\Materials\\Default.bgsm"
	local DefaultMaterialPath = "C:\\Projects\\Fallout4\\Build\\PC\\Data\\Materials\\"

	rollout BGSMatRollout "BGSMaterial" width:326 height:81
	(
		label lbl1 "Path:" pos:[5,9] width:29 height:17
		edittext BGSMatPathTexControl "" pos:[30,6] width:290 height:20 readOnly:true
		button BGSMatPathLoadControl "Load" pos:[10,34] width:45 height:19 toolTip:"Load/Link a BGSM to this material, overwriting any options currently set."
		button BGSMatPathSaveControl "Save" pos:[65,34] width:45 height:19 toolTip:"Save this material's data to the current BGSM (Select if none)."
		button BGSMatPathSaveAsControl "Save As" pos:[120,34] width:60 height:19 toolTip:"Save this material's data to a selected BGSM."
		button BGSMatPathRefreshControl "Refresh" pos:[190,34] width:60 height:19 toolTip:"Refresh the material with the contents of the current BGSM."
		button BGSMatPathDefaultControl "Default" pos:[260,34] width:56 height:19 toolTip:"Load/link the default BGSM to this material. This material will be read only."
		button BGSMatPathRevertControl "Revert" pos:[200,58] width:60 height:19 toolTip:"Revert the current BGSM in perforce and refresh this material with the reverted BGSM."
		button BGSMatPathUnlinkControl "Unlink" pos:[270,58] width:46 height:19 toolTip:"Remove the current BGSM path, but keep the material data."
		button BGSMatPathCheckoutControl "Checkout/Add" pos:[10,58] width:95 height:19
		button BGSMatPathGetLatestControl "Get Latest" pos:[115,58] width:75 height:19
		
		GroupBox grpTemplate "Template" pos:[5,82] width:315 height:68
		label lblTemplatePath "Path:" pos:[10,101] width:29 height:17
		edittext RootMatPathTexControl "" pos:[38,98] width:275 height:20 readOnly:true
		button RootMatPathPickControl "Pick" pos:[185,124] width:60 height:19 toolTip:"Pick the root template material"
		button RootMatPathClearControl "Clear" pos:[253,124] width:60 height:19 toolTip:"Clear the root template material"
		
		fn ClearPaths =
		(
			BGSMatPathParam = ""
			BGSMatPathRelativeParam = ""
			RootMatPathRelativeParam = ""
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
			if stricmp (filenameFromPath BGSMatPathParam) "Default.bgsm" == 0 then
				MessageBox "You cannot save to the Default material file."
			else if not doesFileExist BGSMatPathParam or not getFileAttribute BGSMatPathParam #readOnly then
			(
				if (SaveLightingFXToBGSM this BGSMatPathParam) == undefined then
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
			filePath = getOpenFileName caption:"Select a .BGSM to load:" types:"Bethesda Game Shader Material (*.BGSM)|*.BGSM" historyCategory:"BGSMaterial" filename:matPath
			if filePath != undefined then
			(
				bRefreshFromBGSM = true
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
			filePath = getSaveFileName caption:"Select a .BGSM to save to:" types:"Bethesda Game Shader Material (*.BGSM)|*.BGSM" historyCategory:"BGSMaterial" filename:matPath
			if filePath != undefined then
			(
				if SetRelativeMatPath(filePath) != undefined then
					BGSMatPathParam = filePath
			matPath = GetMaterialFilePathOrDefault()
			filePath = getOpenFileName caption:"Select a .BGSM to load:" types:"Bethesda Game Shader Material (*.BGSM)|*.BGSM" historyCategory:"BGSMaterial" filename:matPath
			if filePath != undefined then
			(
				bRefreshFromBGSM = true
				if SetRelativeMatPath(filePath) != undefined then
					BGSMatPathParam = filePath
			)
				if SaveBGSMaterial() then
					CheckoutOrAddFile BGSMatPathParam -- add the file to perforce as well, since chances are they'll want that anyway
			)
		)
		on BGSMatPathRefreshControl pressed do
		(
			bRefreshFromBGSM = true
			RefreshMaterial BGSMatPathParam
		)
		on BGSMatPathDefaultControl pressed do
		(
			--Set non-interactable (except for BGSMat data)
			localDefault = BuildPathUsingLocalDataRoot DefaultBGSMPath dataRelativePrefix:"Materials" 
			if localDefault != undefined and localDefault != DefaultBGSMPath then
			(
				bRefreshFromBGSM = true
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
		on RootMatPathPickControl pressed do
		(
			matPath = GetMaterialFilePathOrDefault() + "\\Template\\"
			filePath = getOpenFileName caption:"Select a .BGSM to template from:" types:"Bethesda Game Shader Material (*.BGSM)|*.BGSM" historyCategory:"BGSMaterialTemplate" filename:matPath
			if filePath != undefined then
			(
				shortPath = GetRelativeTemplatePath(filePath)
				if shortPath != undefined then
					RootMatPathRelativeParam = shortPath
				else MessageBox @"Invalid path. Must be somewhere in \Data\Materials\Template"
			)
		)
		on RootMatPathClearControl pressed do
		(
			RootMatPathRelativeParam = ""
		)
	)
	
	local FXFilename = "LightingMAX.fx"

	rollout MainRollout "Parameters" width:326 height:950
	(
		-- View
		GroupBox grpAmbient "View" pos:[6,3] width:312 height:125
		checkbox ShowAmbientControl "Show Ambient Lighting" pos:[16,22] width:129 height:15
		button ReloadAmbientControl "Reload" pos:[60,40] width:59 height:19
		colorPicker DiffuseColorControl "Diffuse Color" pos:[36,81] width:114 height:20
		checkbox ShowDiffuseControl "Show Diffuse Lighting" pos:[16,63] width:125 height:15
		checkbox ShowTextureControl "Show Texture" pos:[201,15] width:92 height:15
		checkbox ShowVertexColorControl "Show Vertex Color" pos:[201,34] width:108 height:15
		checkbox ShowSpecularControl "Show Specular" pos:[201,52] width:96 height:15
		checkbox ShowNormalMapControl "Show Normal Map" pos:[201,71] width:110 height:15
		checkbox ShowAlphaControl "Show Alpha" pos:[201,90] width:96 height:15
		checkbox ShowLeafWeightsControl "Show Leaf Weights" pos:[201,109] width:108 height:15

		-- Alpha
		GroupBox grpAlpha "Alpha" pos:[6,133] width:312 height:88
		checkbox AlphaControl "Alpha Testing" pos:[50,200] width:91 height:15
		spinner AlphaValueControl "Value" pos:[77,153] width:57 height:16 range:[0,90,1] scale:0.01 fieldwidth:40
		spinner AlphaRefControl "Alpha Test Ref" pos:[32,177] width:101 height:16 range:[0,255,128] scale:1 fieldwidth:40
		radiobuttons AlphaBlendControl "Blend Mode" pos:[148,148] width:168 height:46 labels:#("Standard", "Additive", "Multiplicative", "None") columns:2
		checkbox EditorAlphaTestRefControl "Editor Alpha Test Ref" pos:[170,200] width:120 height:15
		
		-- Specular
		GroupBox grpSpecular "Specular" pos:[164,269] width:154 height:118
		checkbox SpecularControl "Enable" pos:[180,290] width:60 height:15
		colorPicker SpecularColorControl "Color" pos:[245,289] width:65 height:20
		spinner SmoothnessControl "Smoothness" pos:[187,336] width:106 height:16 range:[0,1,1] scale:0.01 fieldwidth:35
		spinner SpecularScaleControl "Scale" pos:[218,315] width:75 height:16 range:[0,10,1] scale:0.01 fieldwidth:35
		checkbox AnisoLightingControl "Anisotropic Lighting" pos:[181,359] width:116 height:15
		
		-- SubSurface Lighting
		GroupBox grpSubSurface "Sub-Surface Lighting" pos:[6,269] width:154 height:55
		checkbox SubSurfaceLightingControl "Enable" pos:[17,287] width:62 height:15 across:2
		spinner SubSurfaceRolloffControl "Rolloff" pos:[72,300] width:66 height:16 range:[0,10,0.3] scale:0.01 fieldwidth:40
		
		-- Back Lighting
		GroupBox grpBackLighting "Back Lighting" pos:[6,223] width:154 height:45
		spinner BackLightingPowerControl "Power" pos:[56,241] width:63 height:16 range:[0.0,1000,2] scale:0.01 fieldwidth:40
		
		-- Z Test, Write
		GroupBox grpZBuffer "Z Buffer" pos:[164,223] width:154 height:45
		checkbox ZTestControl "Z Test" pos:[182,241] width:55 height:15
		checkbox ZWriteControl "Z Write" pos:[249,241] width:59 height:15
		
		-- Emit
		GroupBox grpEmit "Emit" pos:[6,324] width:154 height:63
		checkbox ShowEmitControl "Enable" pos:[17,338] width:56 height:17
		spinner EmitScaleControl "Scale" pos:[96,360] width:59 height:16 range:[0,10,1] scale:0.01 fieldwidth:30
		colorPicker EmitColorControl "Color" pos:[12,357] width:70 height:20
		
		GroupBox UniqueFeaturesGrp "Unique Features" pos:[-1,388] width:329 height:412
		
		-- Glowmap
		GroupBox GlowmapFeatureGroup "Glowmap" pos:[6,407] width:154 height:60
		checkbox ApplyGlowmapToEmitControl "Apply Glowmap to Emit" pos:[17,428] width:134 height:18
		
		-- Refraction
		GroupBox grpRefraction "Refraction" pos:[164,407] width:154 height:60
		checkbox RefractionControl "Enable" pos:[177,423] width:73 height:15
		spinner RefractionPowerControl "Power" pos:[211,445] width:76 height:16 range:[0,1,0] scale:0.001 fieldwidth:40
		checkbox RefractionFireControl "Falloff" pos:[258,423] width:48 height:15
		
		-- Parallax
		GroupBox grpParallax "Parallax" pos:[6,473] width:312 height:135
		GroupBox grpParallaxOcclusion "Occlusion" pos:[172,480] width:139 height:57
		GroupBox grpParallaxMultiLayer "Multi-Layer" pos:[12,537] width:299 height:64
		radiobuttons ParallaxModeControl "" pos:[20,495] width:148 height:32 labels:#("None", "Standard", "Occlusion", "Multi-Layer") columns:2
		spinner ParallaxHeightScaleControl "Height Scale" pos:[198,495] width:101 height:16 range:[0,10,1] scale:0.1 fieldwidth:37
		spinner ParallaxStepsControl "Num Steps" pos:[207,517] width:92 height:16 range:[1,320,4] scale:1 fieldwidth:37
		spinner ParallaxThicknessControl "Layer Thickness" pos:[27,555] width:119 height:16 range:[5,500,10] scale:0.1 fieldwidth:37
		spinner ParallaxRefractionScaleControl "Refraction Scale" pos:[29,579] width:117 height:16 range:[0,1,1] scale:0.001 fieldwidth:37
		spinner ParallaxInnerUScaleControl "Inner Layer U Scale" pos:[167,555] width:135 height:16 range:[-100,100,1] scale:0.01 fieldwidth:37
		spinner ParallaxInnerVScaleControl "Inner Layer V Scale" pos:[159,580] width:143 height:16 range:[-100,100,1] scale:0.01 fieldwidth:37
		
		-- Environment Mapping
		GroupBox grpEnvmap "Environment Mapping" pos:[7,609] width:312 height:63
		checkbox EnvmapControl "Enable" pos:[20,626] width:57 height:15
		spinner EnvmapScaleControl "Scale" pos:[140,628] width:75 height:16 range:[0,10,1] scale:0.01
		checkbox EnvmapEyeControl "Eye" pos:[225,652] width:42 height:15
		checkbox EnvmapWindowControl "Window" pos:[42,650] width:63 height:15
		checkbox EnvmapLightFadeControl "LightFade" pos:[120,651] width:90 height:15
		
		-- Hair
		GroupBox grpHair "Hair" pos:[8,672] width:309 height:43
		checkbox HairControl "Enable" pos:[20,690] width:60 height:15
		colorPicker HairColorControl "Hair Tint Preview" pos:[155,687] width:125 height:20
		
		-- Tree
		GroupBox TreeGrp "Tree" pos:[8,716] width:83 height:39
		checkbox TreeControl "Enable" pos:[18,733] width:57 height:15
		
		-- Grayscale palette remapping
		GroupBox grpPalette "Grayscale To Palette" pos:[99,716] width:150 height:39
		checkbox GrayscaleColorEnableControl "Color" pos:[109,733] width:59 height:15 enabled:true
		spinner GrayscaleColorScaleControl "Scale" pos:[190,733] width:50 height:15 range:[0,1,0] scale:0.001 enabled:true
		
		label UniqueFeaturesEnd "End Unique Features" pos:[10,802] width:100 height:18
		
		-- Misc
		GroupBox grpMisc "Misc" pos:[8,820] width:312 height:106
		checkbox DecalControl "Decal" pos:[18,839] width:52 height:15
		checkbox ExternalEmittanceControl "External Emittance" pos:[18,855] width:112 height:15
		checkbox DecalNoFadeControl "Decal NoFade" pos:[18,871] width:93 height:15
		checkbox HideSecretControl "Hide Secret" pos:[18,887] width:80 height:15 
		checkbox ScreenSpaceReflectionsControl "Screen Space Reflections" pos:[18,903] width:150 height:15
		checkbox ModelSpaceNormalControl "Model Space Normals" pos:[183,839] width:128 height:15
		checkbox TwoSidedControl "Two Sided" pos:[183,855] width:128 height:15
		checkbox CastShadowsControl "Cast Shadows" pos:[183,871] width:95 height:15
		checkbox DissolveFadeControl "Dissolve Fade" pos:[183,887] width:110 height:15
		checkbox NonOccluderControl "Non-Occluder" pos:[183,903] width:110 height:15
		
		-- Skin Type
		GroupBox grpSkin "Skin" pos:[8,934] width:312 height:73
		radiobuttons SkinTypeControl "" pos:[18,953] width:52 height:40 labels:#("None", "Face Customization", "Skin Tint") columns:1
		
		-- Reload FX File
		button ReloadFXControl "Reload FX File" pos:[9,766] width:85 height:21
		button SettingsControl "Settings" pos:[110,766] width:85 height:21
		
		fn UpdateMainRollout abEnabled =
		(
			-- View
			grpAmbient.enabled = abEnabled
			ShowAmbientControl.enabled = abEnabled
			ReloadAmbientControl.enabled = abEnabled
			DiffuseColorControl.enabled = abEnabled
			ShowDiffuseControl.enabled = abEnabled
			ShowTextureControl.enabled = abEnabled
			ShowVertexColorControl.enabled = abEnabled
			ShowSpecularControl.enabled = abEnabled
			ShowNormalMapControl.enabled = abEnabled
			ShowAlphaControl.enabled = abEnabled
			ShowLeafWeightsControl.enabled = abEnabled

			--Alpha
			grpAlpha.enabled = abEnabled
			AlphaControl.enabled = abEnabled
			AlphaValueControl.enabled = abEnabled and ((AlphaBlendParam != 4) or AlphaParam)
			AlphaRefControl.enabled = abEnabled
			AlphaBlendControl.enabled = abEnabled
			EditorAlphaTestRefControl.enabled = abEnabled
			
			-- Specular
			grpSpecular.enabled = abEnabled
			SpecularControl.enabled = abEnabled
			SpecularColorControl.enabled = abEnabled and SpecularParam
			SmoothnessControl.enabled = abEnabled
			SpecularScaleControl.enabled = abEnabled and SpecularParam
			AnisoLightingControl.enabled = abEnabled and SpecularParam
			
			-- SubSurface Lighting
			grpSubSurface.enabled = abEnabled
			SubSurfaceLightingControl.enabled = abEnabled
			SubSurfaceRolloffControl.enabled = abEnabled and SubSurfaceLightingParam
			
			-- Back Lighting
			grpBackLighting.enabled = abEnabled
			BackLightingPowerControl.enabled = abEnabled
			
			-- Z Test, Write
			grpZBuffer.enabled = abEnabled
			ZTestControl.enabled = abEnabled
			ZWriteControl.enabled = abEnabled
			
			-- Emit
			grpEmit.enabled = abEnabled
			ShowEmitControl.enabled = abEnabled
			EmitScaleControl.enabled = abEnabled and ShowEmitParam
			EmitColorControl.enabled = abEnabled and ShowEmitParam
			
			-- Glowmap
			GlowmapFeatureGroup.enabled = abEnabled
			ApplyGlowmapToEmitControl.enabled = abEnabled
			
			-- Refraction
			grpRefraction.enabled = abEnabled
			RefractionControl.enabled = abEnabled
			RefractionPowerControl.enabled = abEnabled and RefractionParam
			RefractionFireControl.enabled = abEnabled and RefractionParam

			-- Parallax
			-- Disabling parallax til it is supported again
			grpParallax.enabled = false --abEnabled
			grpParallaxOcclusion.enabled = false --abEnabled and ParallaxOccParam
			grpParallaxMultiLayer.enabled = false --abEnabled and MultiLayerParallaxParam
			ParallaxModeControl.enabled = false --abEnabled
			ParallaxHeightScaleControl.enabled = false --abEnabled and ParallaxOccParam
			ParallaxStepsControl.enabled = false --abEnabled and ParallaxOccParam
			ParallaxThicknessControl.enabled = false --abEnabled and MultiLayerParallaxParam
			ParallaxRefractionScaleControl.enabled = false --abEnabled and MultiLayerParallaxParam
			ParallaxInnerUScaleControl.enabled = false --abEnabled and MultiLayerParallaxParam
			ParallaxInnerVScaleControl.enabled = false --abEnabled and MultiLayerParallaxParam
			
			-- Environment Mapping
			grpEnvmap.enabled = abEnabled
			EnvmapControl.enabled = abEnabled and ( ParallaxModeParam != 4 )
			EnvmapScaleControl.enabled = abEnabled and EnvmapParam
			EnvmapEyeControl.enabled = abEnabled and EnvmapParam
			EnvmapWindowControl.enabled = abEnabled and EnvmapParam
			EnvmapLightFadeControl.enabled = abEnabled and EnvmapParam
			
			-- Hair
			grpHair.enabled = abEnabled
			HairControl.enabled = abEnabled
			HairColorControl.enabled = abEnabled and HairParam
			
			-- Tree
			TreeGrp.enabled = abEnabled
			TreeControl.enabled = abEnabled
			
			-- Grayscale palette remapping
			grpPalette.enabled = abEnabled
			GrayscaleColorEnableControl.enabled = abEnabled
			GrayscaleColorScaleControl.enabled = abEnabled and GrayscaleColorParam
			
			UniqueFeaturesGrp.enabled = abEnabled
			UniqueFeaturesEnd.enabled = abEnabled
		
			-- Misc
			grpMisc.enabled = abEnabled
			TwoSidedControl.enabled = abEnabled
			ModelSpaceNormalControl.enabled = abEnabled
			DecalControl.enabled = abEnabled
			DecalNoFadeControl.enabled = abEnabled
			ExternalEmittanceControl.enabled = abEnabled
			HideSecretControl.enabled = abEnabled
			ScreenSpaceReflectionsControl.enabled = abEnabled
			CastShadowsControl.enabled = abEnabled
			DissolveFadeControl.enabled = abEnabled
			NonOccluderControl.enabled = abEnabled
			
			-- Skin Type
			grpSkin.enabled = abEnabled
			SkinTypeControl.enabled = abEnabled
		)
		
		fn MainRolloutOpen = 
		(
			-- If this is called from plugin postload the delegate can be undefined
			if delegate != undefined then
			(
				UpdateMainRollout (BGSMatPathParam == "" or (CanEditBGSM BGSMatPathParam))
			)
			
			-- Migrate data from old param type to new param type
			if SkinTintParam then
			(
				SkinTypeParam = 2 -- set it to "face"
				SkinTintParam = false -- clear the old param so we know we've migrated
			)
		)
		
		-- Event handlers

		on MainRollout open do (
			MainRollout.MainRolloutOpen()
		)
		on ReloadAmbientControl pressed do
			(ResetAllMaterialColor())
		on ReloadFXControl pressed do
		(
			(ReloadFXFile this FXFilename)
			MessageBox "FX Reloaded"
		)
		on SettingsControl pressed do
			(CreateDialog SettingsRollout)
	)
	
	parameters MapRolloutParams2 rollout:MapRollout
	(		
		--Diffuse Texture Custom
		--maps type:#texturemap array
		diffuseMap type:#string
		on diffuseMap set arg do
		if arg != undefined then
		(
			newBitmap = openBitMap arg
			SelectFXBitmap2 this "diffuseTexture" DiffuseTexControl newBitmap
		)
		
		normalMap type:#string
		on normalMap set arg do
		if arg != undefined then
		(
			newBitmap = openBitMap arg
			SelectFXBitmap2 this "normalTexture" NormalTexControl newBitmap
		)
		
		environmentMapMask type:#string
		on environmentMapMask set arg do
		if arg != undefined then
		(
			newBitmap = openBitMap arg
			SelectFXBitmap2 this "smoothspecmaskTexture" SmoothSpecTexControl newBitmap
		)
		
		glowMap type:#string
		on glowMap set arg do
		if arg != undefined then
		(
			newBitmap = openBitMap arg
			SelectFXBitmap2 this "glowTexture" GlowTexControl newBitmap
		)
		
		environmentMap type:#string
		on environmentMap set arg do
		if arg != undefined then
		(
			newBitmap = openBitMap arg
			SelectFXBitmap2 this "envTexture" EnvmapTexControl newBitmap
		)
	)
	
	rollout MapRollout "Maps" width:326 height:285
	(
		-- Diffuse Texture
		checkbox DiffuseEnableControl "Diffuse Texture" pos:[6,14] width:96 height:15
		button DiffuseTexControl "None" pos:[143,11] width:100 height:21
		button DiffuseReloadControl "Reload" pos:[247,11] width:39 height:21
		button DiffuseViewControl "V" pos:[289,11] width:16 height:21 toolTip:"View"
		button DiffuseClearControl "X" pos:[307,11] width:16 height:21 toolTip:"Clear"
		
		-- Normal Texture
		checkbox NormalEnableControl "Normal Texture" pos:[6,40] width:96 height:15
		button NormalTexControl "None" pos:[143,39] width:100 height:21
		button NormalReloadControl "Reload" pos:[247,38] width:39 height:21
		button NormalViewControl "V" pos:[289,38] width:16 height:21 toolTip:"View"
		button NormalClearControl "X" pos:[307,38] width:16 height:21 toolTip:"Clear"

		-- Smoothness / SpecMask Texture
		checkbox SmoothSpecEnableControl "Smoothness/Spec Mask Texture" pos:[6,66] width:130 height:15
		button SmoothSpecTexControl "None" pos:[143,65] width:100 height:21
		button SmoothSpecReloadControl "Reload" pos:[247,65] width:39 height:21
		button SmoothSpecViewControl "V" pos:[289,65] width:16 height:21 toolTip:"View"
		button SmoothSpecClearControl "X" pos:[307,65] width:16 height:21 toolTip:"Clear"
		
		-- Grayscale Palette Texture
		checkbox GrayscaleEnableControl "Palette Texture" pos:[6,91] width:96 height:15
		button GrayscaleTexControl "None" pos:[143,92] width:100 height:21
		button GrayscaleReloadControl "Reload" pos:[247,92] width:39 height:21
		button GrayscaleViewControl "V" pos:[289,92] width:16 height:21 toolTip:"View"
		button GrayscaleClearControl "X" pos:[307,92] width:16 height:21 toolTip:"Clear"
		
		-- Envmap Texture
		checkbox EnvmapEnableControl "Envmap Texture" pos:[6,121] width:96 height:15
		button EnvmapTexControl "None" pos:[143,119] width:100 height:21
		button EnvmapReloadControl "Reload" pos:[247,119] width:39 height:21
		button EnvmapViewControl "V" pos:[289,119] width:16 height:21 toolTip:"View"
		button EnvmapClearControl "X" pos:[307,119] width:16 height:21 toolTip:"Clear"
		
		-- Glow
		checkbox GlowEnableControl "Glow" pos:[6,147] width:130 height:15
		button GlowTexControl "None" pos:[143,146] width:100 height:21
		button GlowReloadControl "Reload" pos:[247,146] width:39 height:21
		button GlowViewControl "V" pos:[289,146] width:16 height:21 toolTip:"View"
		button GlowClearControl "X" pos:[307,146] width:16 height:21 toolTip:"Clear"

		-- Wrinkle Texture
		checkbox WrinkleEnableControl "Wrinkle Texture" pos:[6,176] width:130 height:15
		button WrinkleTexControl "None" pos:[143,175] width:100 height:21
		button WrinkleReloadControl "Reload" pos:[247,175] width:39 height:21
		button WrinkleViewControl "V" pos:[289,175] width:16 height:21 toolTip:"View"
		button WrinkleClearControl "X" pos:[307,175] width:16 height:21 toolTip:"Clear"

		-- UV Tiling
		checkbox UTilingControl "U Tiling" pos:[80,212] width:60 height:15
		checkbox VTilingControl "V Tiling" pos:[186,212] width:59 height:15
		
		-- UV Offsets
		spinner UOffsetControl "U Offset" pos:[55,234] width:80 height:16 range:[-100,100,0] scale:0.001 fieldwidth:40
		spinner VOffsetControl "V Offset" pos:[167,234] width:83 height:16 range:[-100,100,0] scale:0.001 fieldwidth:40
		spinner UScaleControl "U Scale" pos:[55,258] width:80 height:16 range:[-100,100,0] scale:0.001 fieldwidth:40
		spinner VScaleControl "V Scale" pos:[168,258] width:82 height:16 range:[-100,100,0] scale:0.001 fieldwidth:40

	fn UpdateMapRollout abEnabled =
		(
			SetBitmapButtonText DiffuseTexControl this "diffuseTexture"
			DiffuseEnableControl.enabled = abEnabled
			DiffuseTexControl.enabled = abEnabled
			DiffuseReloadControl.enabled = true
			DiffuseViewControl.enabled = true
			DiffuseClearControl.enabled = abEnabled
			
			SetBitmapButtonText NormalTexControl this "normalTexture"
			NormalEnableControl.enabled = abEnabled
			NormalTexControl.enabled = abEnabled
			NormalReloadControl.enabled = true
			NormalViewControl.enabled = true
			NormalClearControl.enabled = abEnabled
			
			SetBitmapButtonText SmoothSpecTexControl this "smoothspecmaskTexture"
			SmoothSpecEnableControl.enabled = abEnabled
			SmoothSpecTexControl.enabled = abEnabled
			SmoothSpecReloadControl.enabled = true
			SmoothSpecViewControl.enabled = true
			SmoothSpecClearControl.enabled = abEnabled
			
			SetBitmapButtonText GrayscaleTexControl this "heightTexture"
			GrayscaleEnableControl.enabled = abEnabled
			GrayscaleTexControl.enabled = abEnabled
			GrayscaleReloadControl.enabled = true
			GrayscaleViewControl.enabled = true
			GrayscaleClearControl.enabled = abEnabled
			
			SetBitmapButtonText EnvmapTexControl this "envTexture"
			EnvmapEnableControl.enabled = abEnabled
			EnvmapTexControl.enabled = abEnabled
			EnvmapReloadControl.enabled = true
			EnvmapViewControl.enabled = true
			EnvmapClearControl.enabled = abEnabled
			
			SetBitmapButtonText GlowTexControl this "glowTexture"
			GlowEnableControl.enabled = abEnabled
			GlowTexControl.enabled = abEnabled
			GlowReloadControl.enabled = true
			GlowViewControl.enabled = true
			GlowClearControl.enabled = abEnabled

			SetBitmapButtonText WrinkleTexControl this "wrinklesTexture"
			WrinkleEnableControl.enabled = abEnabled
			WrinkleTexControl.enabled = abEnabled
			WrinkleReloadControl.enabled = true
			WrinkleViewControl.enabled = true
			WrinkleClearControl.enabled = abEnabled

			UTilingControl.enabled = abEnabled
			VTilingControl.enabled = abEnabled
			
			UOffsetControl.enabled = abEnabled
			VOffsetControl.enabled = abEnabled
			UScaleControl.enabled = abEnabled
			VScaleControl.enabled = abEnabled
		)

		fn UpdateMapPaths =
		(
			UpdateTexturePath this "diffuseTexture"
			UpdateTexturePath this "normalTexture"
			UpdateTexturePath this "smoothspecmaskTexture"
			UpdateTexturePath this "heightTexture"
			UpdateTexturePath this "envTexture"
			UpdateTexturePath this "glowTexture"
			UpdateTexturePath this "wrinklesTexture"
		)

		-- Separate function to be called from the rollout open handler or when we want to reset the rollout
		-- Needed because calling <rollout>.open() doesn't work (open is a property and a handler on a rollout)
		fn MapRolloutOpen =
		(
			-- If this is called from plugin postload the delegate can be undefined
			if delegate != undefined then
			(
				--UpdateMapPaths()
				UpdateMapRollout (BGSMatPathParam == "" or (CanEditBGSM BGSMatPathParam))
			)
		)
		
		
		-- Event handlers for updating textures
		on MapRollout open do
			(MapRollout.MapRolloutOpen())
		on DiffuseTexControl pressed do
			(SelectFXBitmap this "diffuseTexture" DiffuseTexControl)
		on DiffuseReloadControl pressed do
			(ReloadFXBitmap this "diffuseTexture")
		on DiffuseViewControl pressed do
			(DisplayFXBitmap this "diffuseTexture")
		on DiffuseClearControl pressed do
			(ClearFXMapPath this "diffuseTexture" DiffuseTexControl DiffuseEnableControl)
		on NormalTexControl pressed do
			(SelectFXBitmap this "normalTexture" NormalTexControl)
		on NormalReloadControl pressed do
			(ReloadFXBitmap this "normalTexture")
		on NormalViewControl pressed do
			(DisplayFXBitmap this "normalTexture")
		on NormalClearControl pressed do
			(ClearFXMapPath this "normalTexture" NormalTexControl NormalEnableControl)
		on SmoothSpecTexControl pressed do
			(SelectFXBitmap this "smoothspecmaskTexture" SmoothSpecTexControl)
		on SmoothSpecReloadControl pressed do
			(ReloadFXBitmap this "smoothspecmaskTexture")
		on SmoothSpecViewControl pressed do
			(DisplayFXBitmap this "smoothspecmaskTexture")
		on SmoothSpecClearControl pressed do
			(ClearFXMapPath this "smoothspecmaskTexture" SmoothSpecTexControl SmoothSpecEnableControl)
		on GrayscaleTexControl pressed do
			(SelectFXBitmap this "heightTexture" GrayscaleTexControl)
		on GrayscaleReloadControl pressed do
			(ReloadFXBitmap this "heightTexture")
		on GrayscaleViewControl pressed do
			(DisplayFXBitmap this "heightTexture")
		on GrayscaleClearControl pressed do
			(ClearFXMapPath this "heightTexture" GrayscaleTexControl GrayscaleEnableControl)
		on EnvmapTexControl pressed do
			(SelectFXBitmap this "envTexture" EnvmapTexControl)
		on EnvmapReloadControl pressed do
			(ReloadFXBitmap this "envTexture")
		on EnvmapViewControl pressed do
			(DisplayFXBitmap this "envTexture")
		on EnvmapClearControl pressed do
			(ClearFXMapPath this "envTexture" EnvmapTexControl EnvmapEnableControl)
		on GlowTexControl pressed do
			(SelectFXBitmap this "glowTexture" GlowTexControl)
		on GlowReloadControl pressed do
			(ReloadFXBitmap this "glowTexture")
		on GlowViewControl pressed do
			(DisplayFXBitmap this "glowTexture")
		on GlowClearControl pressed do
			(ClearFXMapPath this "glowTexture" GlowTexControl GlowEnableControl)
		on WrinkleTexControl pressed do
			(SelectFXBitmap this "wrinklesTexture" WrinkleTexControl)
		on WrinkleReloadControl pressed do
			(ReloadFXBitmap this "wrinklesTexture")
		on WrinkleViewControl pressed do
			(DisplayFXBitmap this "wrinklesTexture")
		on WrinkleClearControl pressed do
			(ClearFXMapPath this "wrinklesTexture" WrinkleTexControl WrinkleEnableControl)
	)

	-- Set .fx file in the DirectX material
	on create do (ReloadFXFile this FXFilename)
		
	on clone orig do (BGSMatRollout.ClearPaths())
		
	fn UpdateAllMapPaths =
	(
		MapRollout.UpdateMapPaths()
	)
	
	fn UpdateAllRollouts abForceEnabled:false = 
	(
		if MainRollout.open then -- Don't bother updating the rollout if it's not even visible yet.
		(
			benable = abForceEnabled or BGSMatPathParam == "" or (CanEditBGSM BGSMatPathParam)
		
			(SetRolloutEnableState MainRollout benable aRefreshUIFunction:MainRollout.UpdateMainRollout)
			(SetRolloutEnableState MapRollout benable aRefreshUIFunction:MapRollout.UpdateMapRollout)
		)
	)
	
	--Utility function to set a BGSM on the current material
	fn TrySetMatParam aFullMaterialPath =
	(
		if aFullMaterialPath != undefined then
		(
			shortPath = GetRelativeMatPath(aFullMaterialPath)
			if shortPath != undefined then
			(
				bRefreshFromBGSM = true
				
				--We know we're explicitly setting the params, so mark us as already initialized.
				BGSMatInit = true
				BGSMatPathRelativeParam = shortPath
				BGSMatPathParam = aFullMaterialPath
			)
			else MessageBox @"Invalid path. Must be somewhere in \Data\Materials"
		)
	)
	
	--Utility function to set a BGSM on the current material
	fn TrySetMatParam2 aFullMaterialPath =
	(
		if aFullMaterialPath != undefined then
		(
			shortPath = GetRelativeMatPath(aFullMaterialPath)
			if shortPath != undefined then
			(
				--bRefreshFromBGSM = true
				
				--We know we're explicitly setting the params, so mark us as already initialized.
				BGSMatInit = true
				BGSMatPathRelativeParam = shortPath
				BGSMatPathParam = aFullMaterialPath
			)
			else MessageBox @"Invalid path. Must be somewhere in \Data\Materials"
		)
	)
		
	fn SetRelativeMatPath2 filePath =
	(
		shortPath = GetRelativeMatPath(filePath)
		if shortPath != undefined then
			BGSMatPathTexControl.text = shortPath
		else MessageBox @"Invalid path. Must be somewhere in \Data\Materials"
		
		shortPath
	)
		
	fn SaveBGSMaterial2 BGSMatPathParam =
	(
		bretVal = false
		if stricmp (filenameFromPath BGSMatPathParam) "Default.bgsm" == 0 then
			MessageBox "You cannot save to the Default material file."
		else if not doesFileExist BGSMatPathParam or not getFileAttribute BGSMatPathParam #readOnly then
		(
			if (SaveLightingFXToBGSM this BGSMatPathParam) == undefined then
			(
				print "Unable to save material file."
				--MessageBox "Unable to save material file."
			)
			else
			(
				TrySetMatParam2(BGSMatPathParam)
				bretVal = true
				UpdateAllRollouts()
			)
		)
		else
			MessageBox "This file is read only. Please check out from perforce."
		bretVal
	)
	
	parameters CustomParameters rollout:BGSMatRollout
	(
		--Custom
		SaveAsFileName type:#string
		on SaveAsFileName set arg do
		if arg != undefined then
		(
			--matPath = GetMaterialFilePathOrDefault()
			--BGSMatPathSaveControl.pressed
			SaveBGSMaterial2(BGSMatPathParam)
			CheckoutOrAddFile(BGSMatPathParam)
		)
		CustomMatPath type:#string
	)
)
