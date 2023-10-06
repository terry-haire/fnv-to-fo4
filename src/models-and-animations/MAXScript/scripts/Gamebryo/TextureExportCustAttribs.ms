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

Global GamebryoNumPlatforms = 4

TextureExportCA = attributes "TextureExportSettings" version:5 attribID:#(0x88da7c45, 0x46542296)
( 
	-- Ordering in the tab: 
	--		1) "Generic"
	--		2) "Xbox 360"
	--		3) "Playstation 3"
	--		4) "DirectX 9"

	-- Image Quality Options in the Tab:
	--		1)"Image Default"
	--		2)"Use Global Settings"
	--		3)"32 bit"
	--		4)"16 bit"
	--		5)"8 bit Palettized"
	--		6)"DXT1"
	--		7)"DXT3"
	--		8)"DXT5"

	parameters main rollout:BitmapUI
	( 
		UseMasterIndexForAll	type:#boolean	animatable:false	default:false
		MasterIndex		type:#integer	animatable:false	default:1		ui:ddlCurrentPlatform
		FinalImageSize	type:#intTab 	animatable:false	default:1		tabSizeVariable:false  tabSize:4
		FinalImageQuality type:#intTab 	animatable:false	default:2		tabSizeVariable:false  tabSize:4
		FilterMode 		type:#intTab 	animatable:false	default:2		tabSizeVariable:false  tabSize:4
		MipMapMode 		type:#intTab 	animatable:false	default:2		tabSizeVariable:false  tabSize:4	
		FileSettings	type:#intTab  	animatable:false	default:1		tabSizeVariable:false  tabSize:5
	) 

	rollout BitmapUI "Texture Export Parameters" 
	( 	
		dropdownlist	ddlCurrentPlatform			"Selected Platform"			items:#("Generic","Xbox 360", "Playstation 3", "DirectX 9")	selection:1 across:2
		checkbox		cbUseCurrentPlatformForAll	"Use Current Platform For All" checked:false offset:[4,20]  

		groupBox		grpFilter		"Filtering"				pos:[15,165]	width:143 height:149
		radioButtons	rdoFilterMode	"Filter Mode:"			pos:[25,185]	width:60  height:46		labels:#("Nearest", "Linear") columns:1
		radioButtons	rdoMipMapMode	"Mip-Mapping Mode:"		pos:[25,244]	width:60  height:62		labels:#("Nearest", "Linear", "Off") columns:1

		groupBox		grpQuality		"Quality"				pos:[171,50]	width:140 height:264
		radioButtons	rdoImageQuality "Final Pixel Quality:"	pos:[178,72]	width:123 height:158	labels:#("Image Default", "Use Global Settings", "32 bit", "16 bit", "8 bit Palettized", "DXT1", "DXT3", "DXT5")
		radioButtons	rdoImageSize	"Final Texture Size"	pos:[178,242]	width:81  height:62		labels:#("Full Size", "Half Size", "Quarter Size") columns:1

		groupBox		grpExportMode	"Export Mode"			pos:[15,50]		width:143 height:110
		radioButtons	rdoFileSettings "Texture Export Settings:" pos:[25,66]	width:117 height:90		labels:#("Global Settings", "Internal To NIF", "External NIF texture", "Original Images", "Original Images VRAM") columns:1 
		
		function UpdateBitmapUI = 
		(
			if MasterIndex < 1 or MasterIndex > GamebryoNumPlatforms then
				MasterIndex = 1
			
			if FileSettings[MasterIndex] >= 4 do		
			(
				rdoImageSize.enabled = false
				rdoImageQuality.enabled = false
			)
			
			if FileSettings[MasterIndex] < 4 do
			(
				rdoImageSize.enabled = true
				rdoImageQuality.enabled = true
			)

			ddlCurrentPlatform.selection = MasterIndex
			cbUseCurrentPlatformForAll.checked = UseMasterIndexForAll
			ddlCurrentPlatform.enabled = not UseMasterIndexForAll

			rdoFilterMode.state = FilterMode[MasterIndex]
			rdoMipMapMode.state = MipMapMode[MasterIndex]
			rdoImageQuality.state = FinalImageQuality[MasterIndex]
			rdoImageSize.state = FinalImageSize[MasterIndex]
			rdoFileSettings.state = FileSettings[MasterIndex]
		)

		on BitmapUI reload do
		(
			UpdateBitmapUI()
		)
		
		on BitmapUI open  do
		(
			UpdateBitmapUI()
		)

		on ddlCurrentPlatform selected item do
		(
			MasterIndex = item
			UpdateBitmapUI()
		)

		on cbUseCurrentPlatformForAll changed state do
		(
			UseMasterIndexForAll = state
			MasterIndex = ddlCurrentPlatform.selection
			ddlCurrentPlatform.enabled = not state

			if state == true do
			(
				for i = 1 to GamebryoNumPlatforms do 
				(
					if i != MasterIndex do
					(
						FilterMode[i] = FilterMode[MasterIndex] 
						MipMapMode[i] = MipMapMode[MasterIndex] 
						FinalImageQuality[i] = FinalImageQuality[MasterIndex]
						FinalImageSize[i] = FinalImageSize[MasterIndex]
						FileSettings[i] = FileSettings[MasterIndex]
					)
				)
				UpdateBitmapUI()
			)
		)

		on rdoFilterMode changed state do
		(
			for i = 1 to GamebryoNumPlatforms do 
			(
				bAdd = false
				if UseMasterIndexForAll == true then bAdd = true
				if i == MasterIndex then bAdd = true

				if bAdd == true then FilterMode[i] = state
			)
		)
		
		on rdoMipMapMode changed state do
		(
			for i = 1 to GamebryoNumPlatforms do 
			(
				bAdd = false
				if UseMasterIndexForAll == true then bAdd = true
				if i == MasterIndex then bAdd = true

				if bAdd == true then MipMapMode[i] = state
			)
		
		)
		
		on rdoImageQuality changed state do
		(
			for i = 1 to GamebryoNumPlatforms do 
			(
				bAdd = false
				if UseMasterIndexForAll == true then bAdd = true
				if i == MasterIndex then bAdd = true

				if bAdd == true then FinalImageQuality[i] = state
			)

			rdoImageQuality.state = state
			
		)
		
		on rdoImageSize changed state do
		(
			for i = 1 to GamebryoNumPlatforms do 
			(
				bAdd = false
				if UseMasterIndexForAll == true then bAdd = true
				if i == MasterIndex then bAdd = true

				if bAdd == true then FinalImageSize[i] = state
			)
		)
		
		on rdoFileSettings changed state do
		(
			oldState = rdoFileSettings.state
			for i = 1 to GamebryoNumPlatforms do 
			(
				bAdd = false
				if UseMasterIndexForAll == true then bAdd = true
				if i == MasterIndex then bAdd = true

				if bAdd == true then FileSettings[i] = state		
			)

			if state >= 4 do
			(
 		 	    for i = 1 to GamebryoNumPlatforms do 
				(
					bAdd = false
					if UseMasterIndexForAll == true then bAdd = true
					if i == MasterIndex then bAdd = true

					if bAdd == true do
					( 	
						FinalImageSize[i] = 1
						FinalImageQuality[i] = 1
					)	
				)
			
			)

			UpdateBitmapUI()
		)
	)
	
	on update do
	(
		if (version < 4) do
		(
			--Compensate for the removal of 4-bit palletized, which was PS2 only
		    if (FinalImageQuality[1] == 6) do
		    (
				FinalImageQuality[1] = 5
		    )
		    if (FinalImageQuality[1] > 6) do
		    (
				FinalImageQuality[1] -= 1
		    )
		    MasterIndex = 1
		    if UseMasterIndexForAll then
		    (
				-- set all the other platform options to the current PC settings
				for i = 2 to 4 do
				(
					FinalImageSize[i] = FinalImageSize[1]
					FinalImageQuality[i] = FinalImageQuality[1]
					FilterMode[i] = FilterMode[1]
					MipMapMode[i] = MipMapMode[1]
					FileSettings[i] = FileSettings[1]
				)
		    )
		    else
		    (
				-- set all other options back to default as they are no longer valid
				for i = 2 to 4 do
				(
					FinalImageSize[i] = 1
					FinalImageQuality[i] = 2
					FilterMode[i] = 2
					MipMapMode[i] = 2
					FileSettings[i] = 1
				)
			)
		)
	) 
) 