------------------------------------------------------------------------
-- ZENIMAX MEDIA PROPRIETARY INFORMATION
-- 
-- This software is developed and/or supplied under the terms of a license
-- or non-disclosure agreement with ZeniMax Media Inc. and may not be copied
-- or disclosed except in accordance with the terms of that agreement.
-- 
--   Copyright (c) 2010 ZeniMax Media Incorporated.
--   All Rights Reserved.
-- 
-- ZeniMax Media Incorporated, Rockville, Maryland 20850
-- http://www.zenimax.com
-- Owner: Paul Graber
------------------------------------------------------------------------

function IsCorrectSnowMaterial aMat =
(
	-- BSLightingFX material
	aMat.classid[1] == 0x4cdce7fb and aMat.classid[2] == 0x50191395
)

-- Creates a dialog containing controls to modify attributes of a BSLightingFX material related to snow
macroscript BSSnowPreview category:"Bethesda"
(
	rollout PreviewRollout "Snow Preview"
	(
		local snowMaterial
		local projNoiseTexture
		
		-- Button to select which material to control
		label UseActiveMaterialLabel "BSLightingFX material must be selected in Material Editor"
		button UseActiveMaterialControl "Control Active Material"
		on UseActiveMaterialControl pressed do
		(
			snowMaterial = undefined
			if(IsCorrectSnowMaterial (medit.GetCurMtl())) then
				snowMaterial = medit.GetCurMtl()

			-- Disable UI controls if a non-BSLightingFX material is selected
			PreviewRollout.EnableSnowControl.enabled = snowMaterial != undefined
			PreviewRollout.EnableSnowControl.changed (snowMaterial != undefined)
			
			if(snowMaterial != undefined) then
				PreviewRollout.CurrentMaterialLabel.text = ("Current Material: " + snowMaterial as string)
			else
				PreviewRollout.CurrentMaterialLabel.text = "Current Material:"
		)
		label CurrentMaterialLabel "Current Material:" align:#left
		
		-- Used to toggle snow features
		checkbox EnableSnowControl "Enable Snow Preview"
		on EnableSnowControl changed arg do
		(
			PreviewRollout.EnableSnowControl.checked = arg
			PreviewRollout.NoiseFalloffScaleControl.enabled = arg
			PreviewRollout.NoiseFalloffBiasControl.enabled = arg
			PreviewRollout.NoiseTextureScaleControl.enabled = arg
			PreviewRollout.AngleRangeControl.enabled = arg
			PreviewRollout.ProjUVColorControl.enabled = arg
			PreviewRollout.LODObjectControl.enabled = arg
			
			if(snowMaterial != undefined) then
			(
				snowMaterial.delegate.bProjectedUV = arg
				
				-- Sync UI controls with material's values
				PreviewRollout.NoiseFalloffScaleControl.value = snowMaterial.delegate.fProjUVNoiseFalloffScale
				PreviewRollout.NoiseFalloffBiasControl.value = snowMaterial.delegate.fProjUVNoiseFalloffBias
				PreviewRollout.NoiseTextureScaleControl.value = 1/snowMaterial.delegate.fProjUVNoiseTextureScale
				PreviewRollout.AngleRangeControl.value = acos snowMaterial.delegate.fProjUVAngleRange
				PreviewRollout.ProjUVColorControl.color = snowMaterial.delegate.ProjUVColor
				PreviewRollout.LODObjectControl.checked = snowMaterial.delegate.bLODObjectsHD
				
				-- Get the material's projected noise texture if it has one, otherwise assign it the currently selected noise texture
				if(snowMaterial.delegate.projectedNoiseTexture != undefined) then
				(
					projNoiseTexture = snowMaterial.delegate.projectedNoiseTexture
					PreviewRollout.ProjNoiseTextureControl.text = filenameFromPath projNoiseTexture.filename
				)
				else if(projNoiseTexture != undefined) then
				(
					snowMaterial.delegate.projectedNoiseTexture = projNoiseTexture
				)
			)
		)
		
		-- Projected UV properties
		spinner NoiseFalloffScaleControl "Noise Falloff Scale" align:#center range:[0,10,1] scale:0.01 fieldwidth:40
		on NoiseFalloffScaleControl changed arg do
			(snowMaterial.delegate.fProjUVNoiseFalloffScale = arg)
		
		spinner NoiseFalloffBiasControl "Noise Falloff Bias" align:#center range:[-1,1,0] scale:0.01 fieldwidth:40
		on NoiseFalloffBiasControl changed arg do
			(snowMaterial.delegate.fProjUVNoiseFalloffBias = arg)
		
		spinner NoiseTextureScaleControl "Noise Texture Scale" align:#center range:[0,10000,1] scale:0.1 fieldwidth:40
		on NoiseTextureScaleControl changed arg do
			(snowMaterial.delegate.fProjUVNoiseTextureScale = 1/arg)
		
		spinner AngleRangeControl "Angle Range" align:#center range:[0,120,45] scale:0.1 fieldwidth:40
		on AngleRangeControl changed arg do
			(snowMaterial.delegate.fProjUVAngleRange = cos arg)
		
		colorpicker ProjUVColorControl "Projected Color" align:#center color:[0,0,255]
		on ProjUVColorControl changed arg do
			(snowMaterial.delegate.ProjUVColor = arg)
		
		label ProjectedNoiseTexLabel "Projected Noise Texture"
		button ProjNoiseTextureControl "texture"
		on ProjNoiseTextureControl pressed do
		(
				newBitmap = selectbitmap()
				if(newBitmap != undefined) do
				(
					projNoiseTexture = newBitmap
					PreviewRollout.ProjNoiseTextureControl.text = filenameFromPath newBitmap.filename
					snowMaterial.delegate.projectedNoiseTexture = newBitmap
				)
		)
		
		checkbox LODObjectControl "Preview Per-Vertex Coverage Adjustment (LOD only)"
		on LODObjectControl changed arg do
		(
			snowMaterial.delegate.bLODObjectsHD = arg
		)
		
		on PreviewRollout open do
		(
			-- Disable all controls initially
			EnableSnowControl.changed false
			EnableSnowControl.enabled = false
		)
	)
	
	on execute do
	(
		CreateDialog PreviewRollout width:300
	)
)