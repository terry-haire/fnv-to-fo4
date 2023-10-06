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

MipMapPyramidCA = attributes "MipMapPyramidSettings" version:2 attribID:#(0x372fd1f6, 0x526fbdaf) 
( 
	parameters MipMapParams rollout:MipMapPyramidUI
	(
		AutoGenMipMaps 	type:#boolean	animatable:false	default:true	ui:chkAutoGenMipMap	
		MipMaps			type:#bitmapTab tabSize:11			animatable:false	
	)

	rollout MipMapPyramidUI "MipMap Pyramid" width:315 height:378 rolledUp:true
	(
		label lbl1 "Level 1:" pos:[10,54] width:40 height:19
		button btnMipMap1 "None" pos:[61,52] width:213 height:18 enabled:false
		label lbl15 "Level 2:" pos:[10,83] width:40 height:19
		button btnMipMap2 "None" pos:[62,83] width:213 height:18 enabled:false
		label lbl16 "Level 3:" pos:[10,112] width:40 height:19
		button btnMipMap3 "None" pos:[63,112] width:213 height:18 enabled:false
		label lbl17 "Level 4:" pos:[10,141] width:40 height:19
		button btnMipMap4 "None" pos:[63,141] width:213 height:18 enabled:false
		label lbl18 "Level 5:" pos:[10,170] width:40 height:19
		button btnMipMap5 "None" pos:[63,170] width:213 height:18 enabled:false
		label lbl19 "Level 6:" pos:[10,199] width:40 height:19
		button btnMipMap6 "None" pos:[63,199] width:213 height:18 enabled:false
		label lbl20 "Level 7:" pos:[10,228] width:40 height:19
		button btnMipMap7 "None" pos:[63,228] width:213 height:18 enabled:false
		label lbl21 "Level 8:" pos:[10,257] width:40 height:19
		button btnMipMap8 "None" pos:[63,257] width:213 height:18 enabled:false
		label lbl22 "Level 9:" pos:[10,286] width:40 height:19
		button btnMipMap9 "None" pos:[63,286] width:213 height:18 enabled:false
		label lbl23 "Level 10:" pos:[10,315] width:53 height:19
		button btnMipMap10 "None" pos:[63,315] width:213 height:18 enabled:false
		label lbl24 "Level 11:" pos:[10,344] width:53 height:19
		button btnMipMap11 "None" pos:[63,345] width:213 height:18 enabled:false
		checkbox chkAutoGenMipMap "Auto-Generate Mip-Maps" pos:[10,10] width:228 height:23
		button btnMipMapView1 "View" pos:[281,52] width:32 height:18 enabled:false
		button btnMipMapView2 "View" pos:[281,83] width:32 height:18 enabled:false
		button btnMipMapView3 "View" pos:[281,112] width:32 height:18 enabled:false
		button btnMipMapView4 "View" pos:[281,141] width:32 height:18 enabled:false
		button btnMipMapView5 "View" pos:[281,170] width:32 height:18 enabled:true
		button btnMipMapView6 "View" pos:[281,199] width:32 height:18 enabled:false
		button btnMipMapView7 "View" pos:[281,228] width:32 height:18 enabled:false
		button btnMipMapView8 "View" pos:[281,257] width:32 height:18 enabled:false
		button btnMipMapView9 "View" pos:[281,286] width:32 height:18 enabled:false
		button btnMipMapView10 "View" pos:[281,315] width:32 height:18 enabled:false
		button btnMipMapView11 "View" pos:[281,345] width:32 height:18 enabled:false

		local buttons = #(btnMipMap1, btnMipMap2, btnMipMap3, btnMipMap4, btnMipMap5, btnMipMap6, btnMipMap7, btnMipMap8, btnMipMap9, btnMipMap10, btnMipMap11)
		local views = #(btnMipMapView1, btnMipMapView2, btnMipMapView3, btnMipMapView4, btnMipMapView5, btnMipMapView6, btnMipMapView7, btnMipMapView8, btnMipMapView9, btnMipMapView10, btnMipMapView11)
		global TempMipMapCA

		function GetActiveMipMapTexMapFromMaterial mtl =
		(
			if mtl == undefined then return undefined
			print "GetActiveMipMapTexMapFromMaterial "

			print mtl
			if IsKindOf mtl StandardMaterial do
			(
				print "Standard Material"
				currentTexMap = undefined
				
				for texmap in mtl.maps do
				(
					if texmap != undefined do
					(
						print texmap
						flags = getMTLMEditFlags texmap
						if flags[1] == true do
						(
							--print "Found current tex map"
							currentTexMap = texmap
							return currentTexMap
						)
					)
				)
			
			)

			if isKindOf mtl MultiMaterial do
			(
				--print "MultiMaterial"
				mm = mtl
				for submtl in mm.materialList do 
				(
					tempMtl = GetActiveMipMapTexMapFromMaterial submtl
					if tempMtl != undefined then return tempMtl
				)
			)

			if isKindOf mtl Gamebryo_XPlatform_Material do
			(
				--print "XPlatform Material"
				tempMtl = GetActiveMipMapTexMapFromMaterial mtl.PCMaterial
				if tempMtl != undefined then return tempMtl

				tempMtl = GetActiveMipMapTexMapFromMaterial mtl.XenonMaterial
				if tempMtl != undefined then return tempMtl
			)

			ThisMaxVersion = maxVersion() 

			if ThisMaxVersion[1] >= 5000 do
			(
				if isKindOf mtl Shell_Material do
				(
					tempMtl = GetActiveTexMapFromMaterial mtl.bakedMaterial
					if tempMtl != undefined then return tempMtl

					tempMtl = GetActiveTexMapFromMaterial mtl.originalMaterial
					if tempMtl != undefined then return tempMtl
				)
			)

			iCACount = custAttributes.count mtl
			print "Searching through ca's"
			for i = 1 to iCACount do
			(
				for j = 0 to (NiGetCustAttribCount mtl "NiShaderCustAttribs") do
				(
					texmap = NiGetCustAttrib mtl j "NiShaderCustAttribs"
					if isKindOf texmap textureMap then
					(
						flags = getMTLMEditFlags texmap
						if flags[1] == true do
						(
							return texmap
						)
					)
				)
			) 
			return undefined
		)

		function GetMipMapActiveBitmapTexture =
		(

			currentMaterial = meditMaterials[medit.GetActiveMtlSlot()]
			--print currentMaterial
			return GetActiveMipMapTexMapFromMaterial currentMaterial
		)

		function IsPowerOfTwo number =
		(
			print "IsPowerOfTwo"
			print (number as string)
			fValue = 2
			if number == undefined do
			(
				print "number is undefined"
				return false
			)

			if number == 1 then return true
			if number == 2 then return true

			while fValue <= 2048 do
			(
				fValue = 2 * fValue
				if number == fValue then return true
			)

			return false
		)

		
		function IsSupportedFilename filename =
		(
			extension =	getFilenameType filename
			--print "Extension:"
			--print extension
			if (matchPattern extension pattern:".bmp") then return true
			if (matchPattern extension pattern:".tga") then return true
			if (matchPattern extension pattern:".rgb") then return true
			if (matchPattern extension pattern:".rgba") then return true
			if (matchPattern extension pattern:".png") then return true
			if (matchPattern extension pattern:".dds") then return true
			if (matchPattern extension pattern:".int") then return true
			if (matchPattern extension pattern:".inta") then return true
			if (matchPattern extension pattern:".targa") then return true
			if (matchPattern extension pattern:".hdr") then return true
			
			return false
		)

		function GetSrcBitmap =
		(
			currentTexMap = GetMipMapActiveBitmapTexture()
			--print currentTexMap.classId
			if isKindOf currentTexMap Bitmaptexture do
			(
				if (currentTexMap.bitmap == undefined) do
				(
					print "Failure to load bitmap"
					return undefined
				)
				if (not IsSupportedFilename currentTexMap.bitmap.filename) do
				(
					print "File type is not supported."
					print "Filename: " + currentTexMap.bitmap.filename
	   			    return undefined
				)
				print "Valid bitmap"

			)
			if not isKindOf currentTexMap Bitmaptexture do
			(
				print "This texturemap is not a bitmap texture"
				return undefined
			)
			return currentTexMap
		)

		function GetTruncatedFilename strBm =
		(
			if strBm != undefined do
			(
				pathArray = filterstring strBm "\\"
				filename = pathArray[pathArray.count]
				i = pathArray.count - 1
				while filename.count < 24 and i > 0 do
				(
					filename = pathArray[i] + "\\" + filename
					i = i - 1
				)
				
				filename = ".." + filename
				return filename
			)

			filename = "None (Invalid Bitmap)"
			return filename

		)

		
		function GamebryoOpenBitMap =
		(
			tempBitmap = selectBitMap caption:"Select Gamebryo Bitmap:"
			if tempBitmap == undefined do
			(
				return undefined
			)

			if (not IsSupportedFilename tempBitmap.filename) do
			(
				InvalidTexString = "Bitmap '" + tempBitmap.filename +"' is not supported natively by Gamebryo."
				MessageBox "Bitmap is not supported natively by Gamebryo.\nCancelling open.\n" title:"File Type Error" beep:true
				return undefined
			)

			return tempBitmap
		)

		function GamebryoOpenBitMapToDimensions width height=
		(
			tempBitmap = GamebryoOpenBitMap()

			if tempBitmap == undefined then return undefined

			if (tempBitmap.height == height and tempBitmap.width == width) do
			(
				return tempBitmap
			)

			strMessage = "In order to complete the mipmap pyramid, this texture must be: "
			strMessage = strMessage + (width as string) + " x " + (height as string)
			MessageBox strMessage title:"MipMap Pyramid Error" beep:true

			return undefined
		)

		function CalculateWidth MipMapSrcBitmap level =
		(
			if MipMapSrcBitmap == undefined then return 0
			if MipMapSrcBitmap.bitmap == undefined then return 0
			width = MipMapSrcBitmap.bitmap.width
			while level != 0 and width != 1 do
			(
				if (bit.get width 1) then width += 1
				width = width / 2
				level = level - 1 
			)

			return width
		)
		
		function CalculateHeight MipMapSrcBitmap level =
		(
			if MipMapSrcBitmap == undefined then return 0
			if MipMapSrcBitmap.bitmap == undefined then return 0
			height = MipMapSrcBitmap.bitmap.height
			while level != 0 and height != 1 do
			(
			    if (bit.get height 1) then height += 1
				height = height / 2
				level = level - 1 
			)

			return height
		)

		function VerifyMipMapPyramid MipMapSrcBitmap level =
		(
			if MipMapSrcBitmap == undefined then return false
			if MipMapSrcBitmap.bitmap == undefined then return false

			print MipMapSrcBitmap
			width = CalculateWidth MipMapSrcBitmap level
			height = CalculateHeight MipMapSrcBitmap level

			theMap = MipMaps[level]
			if theMap == undefined then return false		
			if theMap.width != width then return false
			if theMap.height != height then return false
			return true
		)

		function CalculateNumMipLevels MipMapSrcBitmap =
		(
			if MipMapSrcBitmap == undefined then return 0
			if MipMapSrcBitmap.bitmap == undefined then return 0

			--print MipMapSrcBitmap
			for level = 1 to 11 do
			(
				width = CalculateWidth MipMapSrcBitmap level
				height = CalculateHeight MipMapSrcBitmap level

				if width == 1 and height == 1 then return level
			)

			return 0
		)

				
		function GetMipMapButtonString MipMapSrcBitmap level =
		(
			if MipMapSrcBitmap == undefined then return "None"

			width = CalculateWidth MipMapSrcBitmap level
			height = CalculateHeight MipMapSrcBitmap level
	
			whstring = " (" + (width as string) + "x" + (height as string) + ")"
			if MipMaps[level] != undefined do
			(
				pathArray = filterstring MipMaps[level].filename "\\"
				filename = pathArray[pathArray.count]
				i = pathArray.count - 1
				while filename.count < 24 and i > 0 do
				(
					filename = pathArray[i] + "\\" + filename
					i = i - 1
				)
				
				filename = ".." + filename + whstring
				return filename
			)

			filename = "None" + whstring
			return filename

		)

		function UpdateButtons  =
		(
			try
			(
				MipMapSrcBitmap = GetSrcBitmap()
				print "Have Src Bitmap"

				if MipMapSrcBitmap != undefined and MipMapSrcBitmap.bitmap != undefined do
				(
					numLevels = CalculateNumMipLevels MipMapSrcBitmap
					print (numLevels as string)				
					
					for i = 1 to 11 do
					(
						buttons[i].enabled = not AutoGenMipMaps
						views[i].enabled = not AutoGenMipMaps

						if (MipMaps[i] == undefined) do
						(
							views[i].enabled = false
							buttons[i].caption = GetMipMapButtonString MipMapSrcBitmap i
						)

						if (MipMaps[i] != undefined) do
						(
							if (not AutoGenMipMaps) then views[i].enabled = true
							buttons[i].caption = GetMipMapButtonString MipMapSrcBitmap i
						) 

						if i > numLevels do
						(
							buttons[i].enabled = false
							views[i].enabled = false
						)
					)
				
				)

				if MipMapSrcBitmap == undefined or MipMapSrcBitmap.bitmap == undefined do
				(
					print "MipMapSrcBitmap == undefined or MipMapSrcBitmap.bitmap == undefined"
					for i = 1 to 11 do
					(
						buttons[i].enabled = false
						views[i].enabled = false
						buttons[i].caption = "None (Invalid Bitmap)"
					)
				)
			)
			catch
			(
				print "Caught an error in dealing with the bitmap"
				for i = 1 to 11 do
				(
					buttons[i].enabled = false
					views[i].enabled = false
					buttons[i].caption = "None (Invalid Bitmap)"
				)
			)
		)

		on MipMapPyramidUI reload do
		(
			bSilentMode = setSilentMode true
			UpdateButtons()
			setSilentMode bSilentMode
		)

		on MipMapPyramidUI open  do
		(
			bSilentMode = setSilentMode true
			UpdateButtons()
			setSilentMode bSilentMode
		)

		on MipMapPyramidUI close do
		(
			bSilentMode = setSilentMode true
			try 
			(
				if AutoGenMipMaps != true do
				(
					MipMapSrcBitmap = GetSrcBitmap()

					if MipMapSrcBitmap != undefined and MipMapSrcBitmap.bitmap != undefined do
					(
						bMessageBox = false
						mbString = "The following Mip Map Bitmap levels do not form a valid pyramid:\n"
						numLevels = CalculateNumMipLevels(MipMapSrcBitmap)
						for level = 1 to numLevels do
						(
							if (not VerifyMipMapPyramid MipMapSrcBitmap level) do
							(
								mbString = mbString + "\n LEVEL"+ (level as string) + ": " + (GetMipMapButtonString MipMapSrcBitmap level)
								bMessageBox = true
							)
						)
			
						if bMessageBox do
						(
							MessageBox mbString caption:"Invalid MipMap Pyramid"
						)
					)
				)
			)
			catch
			(
			)
			setSilentMode bSilentMode
		)


		function OnMipMapBtnPress level =
		(
			bSilentMode = setSilentMode true
			try
			(
				MipMapSrcBitmap = GetSrcBitmap()
				if MipMapSrcBitmap != undefined and MipMapSrcBitmap.bitmap != undefined do
				(
					width = CalculateWidth MipMapSrcBitmap level
					height = CalculateHeight MipMapSrcBitmap level

					tempBitmap = GamebryoOpenBitMapToDimensions width height 
					if tempBitmap != undefined do
					(
						MipMaps[level] = tempBitmap
						UpdateButtons()
					)
				)
			)
			catch
			(
				
			)
			setSilentMode bSilentMode
			
		)

		on btnMipMap1 pressed  do
		(
			OnMipMapBtnPress 1
		)
		on btnMipMap2 pressed  do
		(
			OnMipMapBtnPress 2
		)
		on btnMipMap3 pressed  do
		(
			OnMipMapBtnPress 3
		)
		on btnMipMap4 pressed  do
		(
			OnMipMapBtnPress 4
		)
		on btnMipMap5 pressed  do
		(
			OnMipMapBtnPress 5
		)
		on btnMipMap6 pressed  do
		(
			OnMipMapBtnPress 6
		)
		on btnMipMap7 pressed  do
		(
			OnMipMapBtnPress 7
		)
		on btnMipMap8 pressed  do
		(
			OnMipMapBtnPress 8
		)
		on btnMipMap9 pressed  do
		(
			OnMipMapBtnPress 9
		)
		on btnMipMap10 pressed  do
		(
			OnMipMapBtnPress 10
		)
		on btnMipMap11 pressed  do
		(
			OnMipMapBtnPress 11
		)

		on chkAutoGenMipMap changed state do
		(
			bSilentMode = setSilentMode true

			try
			(
				MipMapSrcBitmap = GetSrcBitmap()
				if MipMapSrcBitmap != undefined and MipMapSrcBitmap.bitmap != undefined do
				(
					AutoGenMipMaps = state
					UpdateButtons()
				) 
				if MipMapSrcBitmap == undefined or MipMapSrcBitmap.bitmap == undefined do
				(
					print "Unable to comply with AutoGenMipMaps = false"
					AutoGenMipMaps = true
					UpdateButtons()   
				)
			)
			catch
			(
				AutoGenMipMaps = true
			)
			setSilentMode bSilentMode
			
		)
		
		on btnMipMapView1 pressed  do
			display MipMaps[1]
		on btnMipMapView2 pressed  do
			display MipMaps[2]
		on btnMipMapView3 pressed  do
			display MipMaps[3]
		on btnMipMapView4 pressed  do
			display MipMaps[4]
		on btnMipMapView5 pressed  do
			display MipMaps[5]
		on btnMipMapView6 pressed  do
			display MipMaps[6]
		on btnMipMapView7 pressed  do
			display MipMaps[7]
		on btnMipMapView8 pressed  do
			display MipMaps[8]
		on btnMipMapView9 pressed  do
			display MipMaps[9]
		on btnMipMapView10 pressed  do
			display MipMaps[10]
		on btnMipMapView11 pressed  do
			display MipMaps[11]
		
	) 
) 