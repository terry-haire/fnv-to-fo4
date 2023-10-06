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

global BSSkyObjectTypes = #("Sun", "Sun_Glare", "Atmosphere", "Clouds", "SkyQuad", "Stars", "Moon", "MoonShadow")

plugin material BSSkyMaterial
	name:"BSSkyMaterial"
	classID:#(0x4e09571d, 0x1e0d6ce6)
	extends:DirectX_9_Shader
	replaceUI:true
	version:1
(
	parameters MainParams rollout:MainRollout
	(
		MaterialColorParam type:#color ui:MaterialColorControl
		on MaterialColorParam get arg do (animate off delegate.BaseColor = arg)

		ObjectTypeParam type:#index ui:ObjectTypeControl
		on ObjectTypeParam get arg do (animate off delegate.Type = arg)
	)
	
	local FXFilename = "SkyMAX.fx"
	rollout MainRollout "Parameters" width:326 height:182
	(
		colorPicker MaterialColorControl "Color" pos:[23,25] width:68 height:20
		dropdownList ObjectTypeControl "Object Type" pos:[24,58] width:129 height:40
		
		button BaseTexControl "Texture" pos:[66,118] width:112 height:21
		button BaseTexReloadControl "Reload" pos:[182,118] width:43 height:21
		button BaseTexViewControl "View" pos:[229,118] width:34 height:21
		button BaseTexClearControl "X" pos:[267,118] width:12 height:21
		
		on MainRollout open do
		(
			-- Populate default materials dropdown
			ObjectTypeControl.items = BSSkyObjectTypes
			
			SetBitmapButtonText BaseTexControl this "baseTexture"
		)
		on BaseTexControl pressed do
			(SelectFXBitmap this "baseTexture" BaseTexControl)
		on BaseTexReloadControl pressed do
			(ReloadFXBitmap this "baseTexture")
		on BaseTexViewControl pressed do
			(DisplayFXBitmap this "baseTexture")
		on BaseTexClearControl pressed do
			(ClearFXMapPath this "baseTexture" BaseTexControl undefined)
	)
	
	-- Set .fx file in the DirectX material
	on create do (ReloadFXFile this FXFilename)
)
