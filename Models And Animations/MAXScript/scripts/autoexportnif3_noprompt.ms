--include "Startup\Materials\BSLightingFX.ms"
--include "Startup\Materials\BSMaterialUIUtils.ms"

(	
	fn setLodBorders obj =
	(
		--local obj = getNodeByName "Land" --create a Sphere
		local borderPos = obj.min.z
		local verts = #()
		for v = getNumVerts obj to 1 by -1 do
		(
			local vert = getVert obj v --get the v-th vertex
			if vert.z == borderPos then
			(
				for j = 1 to getNumVerts obj do
				(
					local vert2 = getVert obj j
					if ((vert.x == vert2.x) and (vert.y == vert2.y)) then
					(
						if vert.z < vert2.z then setVert obj v vert.x vert.y (vert2.z - 500)
						--else setVert obj verts[j] vert2.x vert2.y (vert.z - 250)
					)
				)
			)
			--vert.z = 0.0 --change the Z coordinate to 0.0
			--setVert obj v vert --assign back to the v-thvertex
		)
		update obj
	)
	
	fn GetMaterialTemplate =
	(
		local slMaterialTemplate = #()
		append slMaterialTemplate "{"
		append slMaterialTemplate "   \"bAlphaTest\" : false,"
		append slMaterialTemplate "   \"bAnisoLighting\" : false,"
		append slMaterialTemplate "   \"bCastShadows\" : true,"
		append slMaterialTemplate "   \"bDecal\" : false,"
		append slMaterialTemplate "   \"bDecalNoFade\" : false,"
		append slMaterialTemplate "   \"bDiffuseEnable\" : false,"
		append slMaterialTemplate "   \"bDissolveFade\" : false,"
		append slMaterialTemplate "   \"bEmitEnabled\" : false,"
		append slMaterialTemplate "   \"bEnableEditorAlphaRef\" : false,"
		append slMaterialTemplate "   \"bEnvironmentMapping\" : false,"
		append slMaterialTemplate "   \"bEnvironmentMappingEye\" : false,"
		append slMaterialTemplate "   \"bEnvironmentMappingLightFade\" : true,"
		append slMaterialTemplate "   \"bEnvironmentMappingWindow\" : false,"
		append slMaterialTemplate "   \"bEnvmapEnable\" : false,"
		append slMaterialTemplate "   \"bExternalEmittance\" : false,"
		append slMaterialTemplate "   \"bFacegen\" : false,"
		append slMaterialTemplate "   \"bGlowEnable\" : false,"
		append slMaterialTemplate "   \"bGlowmap\" : false,"
		append slMaterialTemplate "   \"bGrayscaleTextureEnable\" : false,"
		append slMaterialTemplate "   \"bGrayscaleToPaletteColor\" : false,"
		append slMaterialTemplate "   \"bHair\" : false,"
		append slMaterialTemplate "   \"bHideSecret\" : false,"
		append slMaterialTemplate "   \"bModelSpaceNormals\" : false,"
		append slMaterialTemplate "   \"bNonOccluder\" : false,"
		append slMaterialTemplate "   \"bNormalEnable\" : false,"
		append slMaterialTemplate "   \"bRefraction\" : false,"
		append slMaterialTemplate "   \"bRefractionFalloff\" : false,"
		append slMaterialTemplate "   \"bScreenSpaceReflections\" : false,"
		append slMaterialTemplate "   \"bSkinTint\" : false,"
		append slMaterialTemplate "   \"bSmoothSpecEnable\" : false,"
		append slMaterialTemplate "   \"bSpecularEnabled\" : true,"
		append slMaterialTemplate "   \"bSubsurfaceLighting\" : false,"
		append slMaterialTemplate "   \"bTileU\" : true,"
		append slMaterialTemplate "   \"bTileV\" : true,"
		append slMaterialTemplate "   \"bTree\" : false,"
		append slMaterialTemplate "   \"bTwoSided\" : false,"
		append slMaterialTemplate "   \"bWrinklesEnable\" : false,"
		append slMaterialTemplate "   \"bZBufferTest\" : true,"
		append slMaterialTemplate "   \"bZBufferWrite\" : true,"
		append slMaterialTemplate "   \"cEmittanceColor\" : \"#000000\","
		append slMaterialTemplate "   \"cHairTintColor\" : \"#808080\","
		append slMaterialTemplate "   \"cSpecularColor\" : \"#ffffff\","
		append slMaterialTemplate "   \"eAlphaBlendMode\" : \"None\","
		append slMaterialTemplate "   \"eParallaxType\" : \"None\","
		append slMaterialTemplate "   \"fAlpha\" : 1,"
		append slMaterialTemplate "   \"fAlphaTestRef\" : 128,"
		append slMaterialTemplate "   \"fBackLightPower\" : 0,"
		append slMaterialTemplate "   \"fEmittanceMult\" : 1,"
		append slMaterialTemplate "   \"fEnvironmentMappingMaskScale\" : 1,"
		append slMaterialTemplate "   \"fGrayscaleToPaletteScale\" : 0.5,"
		append slMaterialTemplate "   \"fParallaxInnerLayerUScale\" : 1,"
		append slMaterialTemplate "   \"fParallaxInnerLayerVScale\" : 1,"
		append slMaterialTemplate "   \"fParallaxLayerThickness\" : 10,"
		append slMaterialTemplate "   \"fParallaxOcclusionHeightScale\" : 1,"
		append slMaterialTemplate "   \"fParallaxOcclusionMaxPasses\" : 4,"
		append slMaterialTemplate "   \"fParallaxRefractionScale\" : 1,"
		append slMaterialTemplate "   \"fRefractionPower\" : 0,"
		append slMaterialTemplate "   \"fSmoothness\" : 1,"
		append slMaterialTemplate "   \"fSpecularMult\" : 1,"
		append slMaterialTemplate "   \"fSubsurfaceLightingRolloff\" : 0.30000001192092896,"
		append slMaterialTemplate "   \"fUOffset\" : 0,"
		append slMaterialTemplate "   \"fUScale\" : 1,"
		append slMaterialTemplate "   \"fVOffset\" : 0,"
		append slMaterialTemplate "   \"fVScale\" : 1,"
		append slMaterialTemplate "   \"sDiffuseTexture\" : \"\","
		append slMaterialTemplate "   \"sEnvmapTexture\" : \"\","
		append slMaterialTemplate "   \"sGlowTexture\" : \"\","
		append slMaterialTemplate "   \"sGreyscaleTexture\" : \"\","
		append slMaterialTemplate "   \"sNormalTexture\" : \"\","
		append slMaterialTemplate "   \"sRootMaterialPath\" : \"\","
		append slMaterialTemplate "   \"sSmoothSpecTexture\" : \"\","
		append slMaterialTemplate "   \"sWrinklesTexture\" : \"\""
		append slMaterialTemplate "}"
		slMaterialTemplate
	)
	
	fn handleBox = 
	(
		local windowHandle = DialogMonitorOPS.GetWindowHandle()
		if (windowHandle != 0) then 
		(
			local title = UIAccessor.GetWindowText WindowHandle
			if title == "Display Gamebryo Export Errors/Warnings" then
			(
				local children = UIAccessor.getChildWindows windowHandle
				
				/*
				for child in children do
				(
					print(UIAccessor.GetWindowText child)
					--if (UIAccessor.GetWindowText child) == "Do not prompt me again."
				)
				*/
				
				UIAccessor.PressButtonByName windowHandle "No"
				--local error = UIAccessor.GetWindowDllDescription WindowHandle
				--UIAccessor.PressDefaultButton()
				true
			)
			else
			(
				MessageBox "Unknown Error Occured"
				true
			)
		)
		else ( false )
	)

	fn ShowTextures =
	(
		for i = 1 to sceneMaterials.count do
		(
			if sceneMaterials[i].name == "BSLightingFX" then
			(
				sceneMaterials[i].DiffuseEnableParam = on
				sceneMaterials[i].NormalEnableParam = on
				sceneMaterials[i].SmoothSpecEnableParam = on
				sceneMaterials[i].EnvmapEnableParam = on
					
				sceneMaterials[i].ShowAmbientParam = on
				sceneMaterials[i].ShowDiffuseParam = on
				sceneMaterials[i].ShowTextureParam = on
				sceneMaterials[i].ShowVertexColorParam = on
				sceneMaterials[i].ShowSpecularParam = on
				sceneMaterials[i].ShowNormalMapParam = on
				sceneMaterials[i].ShowAlphaParam = on
				sceneMaterials[i].ShowLeafWeightsParam = on
			)
		)
	)
	
	fn getFilesRecursive root pattern =
	(
		dir_array = GetDirectories (root+"/*")
		for d in dir_array do
			join dir_array (GetDirectories (d+"/*"))
		my_files = #()
		for f in dir_array do
			join my_files (getFiles (f + pattern))
		my_files
	)

	fn CreateMaterial i srcMat _MatName _TX00 _TX01 _TX02 _TX03 _TX04 _TX05 bLod =
	(
		with undo off
		(
			-- BSBlinn seems a better option but materials will more complicated unless material saving functions can be added to BSBlinn
			setmeditmaterial i (BSLightingFX ())
			meditMaterials[i].ShowVertexColorParam = off --Or Textures Glitch sometimes
			bTextures = false
			--lod
			/*
			if findString (substituteString (toLower _MatName) "\\\\" "\\") "materials\\new_vegas\\landscape\\lod\\" != undefined then
			(
				meditmaterials[i].ModelSpaceNormalParam = on
				_TX01 = undefined
			)
			*/
			
			if _TX00 != undefined then 
			(
				_TX00 = (substituteString _TX00 "\\\\" "\\")
				if findString (toLower _TX00) "Data\\" == 1 then
					_TX00 = replace _TX00 1 5 ""
				meditmaterials[i].diffuseMap = _TX00
				meditMaterials[i].DiffuseEnableParam = on
				bTextures = true
			)
			if _TX01 != undefined then 
			(
				_TX01 = (substituteString _TX01 "\\\\" "\\")
				if findString (toLower _TX01) "Data\\" == 1 then
					_TX01 = replace _TX01 1 5 ""
				meditmaterials[i].normalMap = _TX01
				meditMaterials[i].NormalEnableParam = on
				bTextures = true
			)
			if _TX02 != undefined then 
			(
				_TX02 = (substituteString _TX02 "\\\\" "\\")
				if findString (toLower _TX02) "Data\\" == 1 then
					_TX02 = replace _TX02 1 5 ""
				meditmaterials[i].environmentMapMask = _TX02
				meditmaterials[i].AlphaParam = on
				meditMaterials[i].SmoothSpecEnableParam = on
				bTextures = true
			)
			if _TX03 != undefined then 
			(
				_TX03 = (substituteString _TX03 "\\\\" "\\")
				if findString (toLower _TX03) "Data\\" == 1 then
					_TX03 = replace _TX03 1 5 ""
				meditmaterials[i].glowMap = _TX03
				meditMaterials[i].GlowEnableParam = on
				bTextures = true
			)
			/*
			if _envMask != undefined then -- Might have to create BSEffect Material might be wrong
			(
				_envMask = (substituteString _envMask "\\\\" "\\")
				meditmaterials[i].environmentMapMask = _envMask
				meditMaterials[i].SmoothSpecEnableParam = on
				bTextures = true
			)
			*/
			if _TX05 != undefined then 
			(
				_TX05 = (substituteString _TX05 "\\\\" "\\")
				if findString (toLower _TX05) "Data\\" == 1 then
					_TX05 = replace _TX05 1 5 ""
				meditmaterials[i].environmentMap = _TX05
				meditMaterials[i].EnvmapEnableParam = on
				bTextures = true
			)
			
			if srcMat != undefined then
			(
				if srcMat.useSelfIllumColor == true then
				(
					meditmaterials[i].ShowEmitParam = on
					meditmaterials[i].EmitColorParam = srcMat.selfIllumColor
				)
				if srcMat.opacity < 100 then
				(
					meditmaterials[i].AlphaParam = on
					meditmaterials[i].AlphaValueParam = srcMat.opacity / 100 as float
				)
				--if findString (toLower _MatName) "_lod" != undefined then
				--	meditmaterials[i].ModelSpaceNormalParam = on
			)
			
			if bLod == false then
			(
				makeDir (getFilenamePath _MatName) all:true
				--print _MatName
				_MatName = (substituteString _MatName "\\\\" "\\")
				if stricmp (filenameFromPath _MatName) "Default.bgsm" == 0 then
				(
					_MatName = replace _MatName (_MatName.count - 11) 0 "nv_"
					--print _MatName
					--MessageBox _MatName
				)
				meditmaterials[i].BGSMatPathParam = _MatName
				meditmaterials[i].SaveAsFileName = _MatName
				--print _MatName
			)
			if bTextures == false then 
				if bLod == false then
					setmeditmaterial i (BSBlinn())
		)
	)
	
	fn GetTexPath s1 _path s2 fileRoot =
	(
		_path = substituteString _path (fileRoot + "textures\\") ""
		_path = substituteString _path "\\" "\\\\"
		_path = s1 + _path + s2
		_path
	)

	fn CreateMaterialBSBlinn i _MatName fileRoot _exportloc _TX00 _TX01 _TX02 _TX03 _TX04 _TX05 slMatTemplate obj =
	(
		-- TX04 (parallax) dont know where
		-- BSBlinn seems a better option but materials will more complicated unless material saving functions can be added to BSBlinn
		--matfile = #()
		matfile = deepcopy slMatTemplate -- Otherwise would point to same data
		--for s in matfile do print s
		setmeditmaterial i (BSBlinn())
		--meditmaterials[i][#Standard].maps = obj.material.maps
		
		/*
			These maps have not been found in any nif
			1
			3
			4
			5
			8
			11
			12
		*/
		
		
		if obj.material != undefined then
		(
			-- ambient map	
			-- 0 occurences
			if obj.material.maps[1] != undefined then 
			(
				meditmaterials[i][#Standard].maps[1] = obj.material.maps[1]
				meditmaterials[i][#Standard].ambientMapEnable = on
				meditmaterials[i][#Standard].ambientMapAmount = obj.material.ambientMapAmount
			)
			
			-- diffuse map
			if ((obj.material.maps[2] != undefined) or (_TX00 != undefined)) then 
			(
				if _TX00 == undefined then
				(
					meditmaterials[i][#Standard].diffuseMapAmount = obj.material.diffuseMapAmount
					meditmaterials[i][#Standard].maps[2] = obj.material.maps[2]
				)
				else
					meditmaterials[i][#Standard].diffuseMap = Bitmaptexture fileName:(fileRoot + "textures\\" + _TX00)
				
				meditmaterials[i][#Standard].diffuseMapEnable = on
				matfile[7] = "   \"bDiffuseEnable\" : true,"
				matfile[66] = GetTexPath "   \"sDiffuseTexture\" : \"" meditmaterials[i][#Standard].maps[2].filename "\"," fileRoot
			)
			
			-- specular map
			-- 0 occurences
			if obj.material.maps[3] != undefined then 
			(
				meditmaterials[i][#Standard].maps[3] = obj.material.maps[3]
				meditmaterials[i][#Standard].specularMapEnable = on
				meditmaterials[i][#Standard].specularMapAmount = obj.material.specularMapAmount
			)
			
			-- specular levels map
			if obj.material.maps[4] != undefined then 
			(
				meditmaterials[i][#Standard].maps[4] = obj.material.maps[4]
				meditmaterials[i][#Standard].specularLevelMapEnable = on
				meditmaterials[i][#Standard].specularLevelMapAmount = obj.material.specularLevelMapAmount
				matfile[20] = "   \"bGrayscaleTextureEnable\" : true,"
				matfile[69] = GetTexPath "   \"sGreyscaleTexture\" : \"" meditmaterials[i][#Standard].maps[4].filename "\"," fileRoot
			)
			
			-- glossiness map
			-- 0 occurences
			if obj.material.maps[5] != undefined then 
			(
				meditmaterials[i][#Standard].maps[5] = obj.material.maps[5]
				meditmaterials[i][#Standard].glossinessMapEnable = on
				meditmaterials[i][#Standard].glossinessMapAmount = obj.material.glossinessMapAmount
			)
			
			-- self illumination map
			if ((obj.material.maps[6] != undefined) or (_TX03 != undefined)) then 
			(
				if _TX03 == undefined then
				(
					meditmaterials[i][#Standard].selfillumMapAmount = obj.material.selfillumMapAmount
					meditmaterials[i][#Standard].maps[6] = obj.material.maps[6]
				)
				else
					meditmaterials[i][#Standard].selfillumMap = Bitmaptexture fileName:(fileRoot + "textures\\" + _TX03)
				
				meditmaterials[i][#Standard].selfillumMapEnable = on
				matfile[18] = "   \"bGlowEnable\" : true,"
				matfile[19] = "   \"bGlowmap\" : true,"
				matfile[68] = GetTexPath "   \"sGlowTexture\" : \"" meditmaterials[i][#Standard].maps[6].filename "\"," fileRoot
			)
			
			-- opacity map
			if ((obj.material.maps[7] != undefined) or (_TX02 != undefined)) then 
			(
				if _TX02 == undefined then
				(
					meditmaterials[i][#Standard].maps[7] = obj.material.maps[7]				
					meditmaterials[i][#Standard].opacityMapAmount = obj.material.opacityMapAmount
				)
				else
					meditmaterials[i][#Standard].maps[7] = Bitmaptexture fileName:(fileRoot + "textures\\" + _TX02)
				meditmaterials[i][#Standard].opacityMapEnable = on
				matfile[2] = "   \"bAlphaTest\" : true,"
				matfile[31] = "   \"bSmoothSpecEnable\" : true,"
				matfile[72] = GetTexPath "   \"sSmoothSpecTexture\" : \"" meditmaterials[i][#Standard].maps[7].filename "\"," fileRoot
			)
			
			-- filtermap
			-- 0 occurences
			if obj.material.maps[8] != undefined then 
			(
				meditmaterials[i][#Standard].maps[8] = obj.material.maps[8]
				meditmaterials[i][#Standard].filterMapEnable = on
				meditmaterials[i][#Standard].filterMapAmount = obj.material.filterMapAmount
			)
			
			-- bump map
			if ((obj.material.maps[9] != undefined) or (_TX01 != undefined)) then 
			(
				if _TX01 == undefined then
				(
					meditmaterials[i][#Standard].bumpMapAmount = obj.material.bumpMapAmount
					meditmaterials[i][#Standard].maps[9] = obj.material.maps[9]
				)
				else
					meditmaterials[i][#Standard].bumpMap = Bitmaptexture fileName:(fileRoot + "textures\\" + _TX01)
				
				meditmaterials[i][#Standard].bumpMapEnable = on
				matfile[26] = "   \"bNormalEnable\" : true,"
				matfile[70] = GetTexPath "   \"sNormalTexture\" : \"" meditmaterials[i][#Standard].maps[9].normal_map.filename "\"," fileRoot
			)
			
			-- reflection map / Alpha 2?
			if ((obj.material.maps[10] != undefined) or (_TX05 != undefined)) then 
			(
				if _TX05 == undefined then
				(
					meditmaterials[i][#Standard].reflectionMapAmount = obj.material.reflectionMapAmount
					meditmaterials[i][#Standard].maps[10] = obj.material.maps[10]
				)
				else
					meditmaterials[i][#Standard].reflectionMap = Bitmaptexture fileName:(fileRoot + "textures\\" + _TX05)
					
				meditmaterials[i][#Standard].reflectionMapEnable = on
				matfile[11] = "   \"bEnvironmentMapping\" : true,"
				if hasProperty meditmaterials[i][#Standard].maps[10] "map" == true then 
					matfile[67] = GetTexPath "   \"sEnvmapTexture\" : \"" meditmaterials[i][#Standard].maps[10].map.filename "\"," fileRoot
				else if hasProperty meditmaterials[i][#Standard].maps[10] "mask" == true then
				(
					meditmaterials[i][#Standard].opacityMapEnable = on
					matfile[2] = "   \"bAlphaTest\" : true,"
					matfile[31] = "   \"bSmoothSpecEnable\" : true,"
					matfile[72] = GetTexPath "   \"sSmoothSpecTexture\" : \"" meditmaterials[i][#Standard].maps[10].mask.filename "\"," fileRoot
				)
				else 
					matfile[67] = GetTexPath "   \"sEnvmapTexture\" : \"" meditmaterials[i][#Standard].maps[10].filename "\"," fileRoot
			)
			
			-- refraction map
			-- 0 occurences
			if obj.material.maps[11] != undefined then 
			(
				meditmaterials[i][#Standard].maps[11] = obj.material.maps[11]
				meditmaterials[i][#Standard].refractionMapEnable = on
				meditmaterials[i][#Standard].refractionMapAmount = obj.material.refractionMapAmount
			)
			
			-- displacement map
			-- 0 occurences
			if obj.material.maps[12] != undefined then 
			(
				meditmaterials[i][#Standard].maps[12] = obj.material.maps[12]
				meditmaterials[i][#Standard].displacementMapEnable = on
				meditmaterials[i][#Standard].displacementMapAmount = obj.material.displacementMapAmount
				matfile[38] = "   \"bWrinklesEnable\" : true,"
				matfile[73] = GetTexPath "   \"sWrinklesTexture\" : \"" meditmaterials[i][#Standard].maps[12].filename "\"," fileRoot
			)
			
			-- Emit
			if obj.material.useSelfIllumColor == true then
			(
				meditmaterials[i][#Standard].useSelfIllumColor = on
				meditmaterials[i][#Standard].selfIllumColor = obj.material.selfIllumColor
				local _colorcode = "#"
				local _colorcode = _colorcode + bit.intAsHex(obj.material.selfIllumColor.red as integer)
				local _colorcode = _colorcode + bit.intAsHex(obj.material.selfIllumColor.green as integer)
				local _colorcode = _colorcode + bit.intAsHex(obj.material.selfIllumColor.blue as integer)
				matfile[41] = "   \"cEmittanceColor\" : \"" + _colorcode +"\","
			)
			
			if obj.material.opacity < 100 then
			(
				meditmaterials[i][#Standard].opacity = obj.material.opacity
				matfile[2] = "   \"bAlphaTest\" : true,"
				matfile[46] = "   \"fAlpha\" : " + (substring((obj.material.opacity / 100 as float) as string) 1 4) + ","
				matfile[47] = "   \"fAlphaTestRef\" : 128,"
			)
		)
		
		makeDir (getFilenamePath _MatName) all:true
		if doesFileExist _MatName then deleteFile _MatName
		try 
			out_file = createfile _MatName
		catch
			out_file = undefined
		--format 
		if out_file != undefined then
		(
			for l in matfile do
			(
				format l to:out_file
				format "\n" to:out_file
			)
			close out_file
			_MatName = (substituteString _MatName "\\\\" "\\")
			_MatName = (substituteString _MatName _exportloc "")
			meditmaterials[i].TargetMaterialFile = _MatName
		)
		matfile = undefined
		_TX00 = undefined
		_TX01 = undefined 
		_TX02 = undefined
		_TX03 = undefined
		_TX04 = undefined
		_TX05 = undefined
	)
	
	-- Can choose to use a different ini when using a batch file and can use that ini to change plugcfg location
	_INI_Path = "C:\\Users\\" + sysInfo.username + "\\OneDrive\\Projects\\FNV_to_FO4\\Profiles\\" + sysInfo.computername + "\\FNV_to_FO4.ini"
	
	
	xEditLoc = getINISetting _INI_Path "USERPATHS" "xEdit"
	fileRoot = getINISetting _INI_Path "USERPATHS" "FNVExtracted"
	_exportloc = getINISetting _INI_Path "USERPATHS" "FNVConverted"
	_exportINI = (getINISetting (getMAXIniFile()) "Directories" "PlugCFG") + "\\mimmerse.ini"
	if not doesFileExist _exportINI then
	(
		MessageBox "\"mimmerse.ini\" Not Found"
		exit
	)
	files = getFilesRecursive (fileRoot + "Meshes") "*.nif"
	startloc = fileRoot + "Meshes\\architecture\\\\mccarran\\nv_mccarran-wall02_lod.nif"
	startloc = fileRoot + "Meshes\\landscape\\\\lod\\\\bouldercityworld\\bouldercityworld.level4.x-2.y-1.nif"
	startloc = fileRoot + "Meshes\\architecture\\\\hooverdam\\nv_hooverdam_aagun.nif"
	startloc = fileRoot + "Meshes\\landscape\\\\lod\\\\bouldercityworld\\\\blocks\\bouldercityworld.level4.x2.y-1.nif"
	startloc = fileRoot + "Meshes\\landscape\\\\lod\\\\wastelandnv\\wastelandnv.level16.x-16.y-16.nif"
	startloc = fileRoot + "Meshes\\landscape\\\\lod\\\\wastelandnv\\wastelandnv.level4.x20.y-48.nif"
	startloc = "D:\\Games\\Fallout New Vegas\\FNVExtracted\\Data\\Meshes\\landscape\\\\lod\\\\wastelandnv\\\\blocks\\wastelandnv.level4.high.x-4.y12.nif"
	
	/*
	xEditLoc = "C:\\Users\Terry\OneDrive\Bethesda\\xEdit\\"
	fileRoot = "D:\\Games\Fallout New Vegas\FNVExtracted\Data\\"
	_exportloc = "D:\\Games\\Fallout New Vegas\\FNVFo4 Converted\\Data\\"
	_exportINI = "C:\\Users\\Terry\\AppData\\Local\\Autodesk\\3dsMax\\2013 - 64bit\\ENU\\en-US\\plugcfg\\mimmerse.ini"
	files = getFilesRecursive "D:\\Games\Fallout New Vegas\FNVExtracted\Data\\Meshes" "*.nif"
	startloc = "D:\\Games\\Fallout New Vegas\\FNVExtracted\\Data\\Meshes\\architecture\\\\mccarran\\nv_mccarran-wall02_lod.nif"
	startloc = "D:\\Games\\Fallout New Vegas\\FNVExtracted\\Data\\Meshes\\landscape\\\\lod\\\\wastelandnv\\wastelandnv.level16.x-16.y-16.nif"
	startloc = "D:\\Games\\Fallout New Vegas\\FNVExtracted\\Data\\Meshes\\landscape\\\\lod\\\\bouldercityworld\\bouldercityworld.level4.x-2.y-1.nif"
	startloc = "D:\\Games\\Fallout New Vegas\\FNVExtracted\\Data\\Meshes\\architecture\\\\hooverdam\\nv_hooverdam_aagun.nif"
	startloc = "D:\\Games\\Fallout New Vegas\\FNVExtracted\\Data\\Meshes\\landscape\\\\lod\\\\bouldercityworld\\\\blocks\\bouldercityworld.level4.x2.y-1.nif"
	startloc = "D:\\Games\\Fallout New Vegas\\FNVExtracted\\Data\\Meshes\\landscape\\\\lod\\\\wastelandnv\\wastelandnv.level4.x20.y-48.nif"
	*/
	
	
	_defexportscript = "Script_-_(\"_-_PE_-_Static_-_Art\",\"Export\")_\\n_{_\\n__\\t_Plugin_-_(\"BSNodeAttachTechniques\",\"BSNodeAttachTechniques_-_Plug-in\",\"1.0\",\"PROCESS\")_\\n__\\t_{_\\n__\\t_}_\\n__\\t_Plugin_-_(\"BSHavokProcess\",\"BSHavokProcess_-_Plug-in\",\"1.0\",\"PROCESS\")_\\n__\\t_{_\\n__\\t_}_\\n__\\t_Plugin_-_(\"NiSceneGraphOptimizationPlugin\",\"Scene_-_Graph_-_Optimization\",\"1.1\",\"PROCESS\")_\\n__\\t_{_\\n__\\t__\\t_Parameter_-_(\"AnimationKeyReductionTolerance\",\"0.000100\");_\\n__\\t__\\t_Parameter_-_(\"RemoveDupProperties\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"RemoveChildlessNodes\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"RemoveMultiMtlNodes\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"RemoveUselessChildNodes\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"MergeSiblingNodes\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"RemoveDegenerateTriShapeData\",\"FALSE\");_\\n__\\t__\\t_Parameter_-_(\"NiTriShapeVertexCacheOptimization\",\"FALSE\");_\\n__\\t__\\t_Parameter_-_(\"MergeSiblingTriShapes\",\"FALSE\");_\\n__\\t__\\t_Parameter_-_(\"NoMergeOnAlpha\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"RemoveExtraUVSets\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"RemoveUnnecessaryNormals\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"RemoveUnnecessaryVisControllers\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"RemoveNames\",\"FALSE\");_\\n__\\t__\\t_Parameter_-_(\"NameUnnamedObjects\",\"FALSE\");_\\n__\\t__\\t_Parameter_-_(\"RemoveBadTexturingProps\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"RemoveUnnecessaryExtraData\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"RemoveUnnecessaryLookAtControllers\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"RemoveHiddenBoneGeometry\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"ReduceAnimationKeys\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"SortByTexturingProp\",\"FALSE\");_\\n__\\t__\\t_Parameter_-_(\"WeldSkin\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"ExportPS2SoftwareSkin\",\"FALSE\");_\\n__\\t__\\t_Parameter_-_(\"ExportPS2HardwareSkin\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"ExportSoftwareSkin\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"ExportHardwareSkin\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"BonesPerPartition\",\"180\");_\\n__\\t__\\t_Parameter_-_(\"MoveBonesBeforeSkins\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"MoveEditorMarkersToRoot\",\"TRUE\");_\\n__\\t_}_\\n__\\t_Plugin_-_(\"ShaderLighting\",\"ShaderLighting_-_Plug-in\",\"1.0\",\"PROCESS\")_\\n__\\t_{_\\n__\\t_}_\\n__\\t_Plugin_-_(\"MeshLOD\",\"MeshLOD_-_Plug-in\",\"1.0\",\"PROCESS\")_\\n__\\t_{_\\n__\\t_}_\\n__\\t_Plugin_-_(\"KillHidden\",\"KillHidden_-_Plug-in\",\"1.1\",\"PROCESS\")_\\n__\\t_{_\\n__\\t__\\t_Parameter_-_(\"KILLHIDDEN_UNREFERENCED_BOOL\",\"FALSE\");_\\n__\\t__\\t_Parameter_-_(\"KILLHIDDEN_ALLVERTSSKINNED_BOOL\",\"TRUE\");_\\n__\\t_}_\\n__\\t_Plugin_-_(\"BethsoftProcessPlugin\",\"TES4_-_Requirements_-_Plug-in\",\"1.0\",\"PROCESS\")_\\n__\\t_{_\\n__\\t__\\t_Parameter_-_(\"TES4DDS\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"TES4TexDir\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"TES4IncTex\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"TES4ZeroOrigin\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"TES4AnimFlags\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"TES4NeedBound\",\"FALSE\");_\\n__\\t_}_\\n__\\t_Plugin_-_(\"ExtraData\",\"ExtraData_-_Plug-in\",\"1.0\",\"PROCESS\")_\\n__\\t_{_\\n__\\t_}_\\n__\\t_Plugin_-_(\"BSDestructionNodes\",\"BSDestructionNodes_-_Plug-in\",\"1.0\",\"PROCESS\")_\\n__\\t_{_\\n__\\t_}_\\n__\\t_Plugin_-_(\"BSOrderedNodes\",\"BSOrderedNodes_-_Plug-in\",\"1.0\",\"PROCESS\")_\\n__\\t_{_\\n__\\t_}_\\n__\\t_Plugin_-_(\"BSMultiBoundNodes\",\"BSMultiBoundNodes_-_Plug-in\",\"1.0\",\"PROCESS\")_\\n__\\t_{_\\n__\\t_}_\\n__\\t_Plugin_-_(\"BSFadeNodes\",\"BSFadeNodes_-_Plug-in\",\"1.0\",\"PROCESS\")_\\n__\\t_{_\\n__\\t_}_\\n__\\t_Plugin_-_(\"BSLeafAnimNodes\",\"BSLeafAnimNodes_-_Plug-in\",\"1.0\",\"PROCESS\")_\\n__\\t_{_\\n__\\t_}_\\n__\\t_Plugin_-_(\"BSRenderOrder\",\"BSRenderOrder_-_Plug-in\",\"1.0\",\"PROCESS\")_\\n__\\t_{_\\n__\\t_}_\\n__\\t_Plugin_-_(\"BSOrderSkinGeom\",\"BSOrderSkinGeom_-_Plug-in\",\"1.0\",\"PROCESS\")_\\n__\\t_{_\\n__\\t_}_\\n__\\t_Plugin_-_(\"BSBehaviorGraph\",\"BSBehaviorGraph_-_Plug-in\",\"1.0\",\"PROCESS\")_\\n__\\t_{_\\n__\\t_}_\\n__\\t_Plugin_-_(\"ConvertNiToBS\",\"ConvertNiToBS_-_Plug-in\",\"1.0\",\"PROCESS\")_\\n__\\t_{_\\n__\\t_}_\\n__\\t_Plugin_-_(\"NifExportPlugin\",\"NIF_-_Exporter\",\"1.0\",\"EXPORT\")_\\n__\\t_{_\\n__\\t_}_\\n_}_\\n_"
	_PE_ANIMkey = "Script_-_(\"_-_PE_-_Anim\",\"Export\")_\\n_{_\\n__\\t_Plugin_-_(\"BSNodeAttachTechniques\",\"BSNodeAttachTechniques_-_Plug-in\",\"1.0\",\"PROCESS\")_\\n__\\t_{_\\n__\\t_}_\\n__\\t_Plugin_-_(\"BSHavokProcess\",\"BSHavokProcess_-_Plug-in\",\"1.0\",\"PROCESS\")_\\n__\\t_{_\\n__\\t_}_\\n__\\t_Plugin_-_(\"NiSceneGraphOptimizationPlugin\",\"Scene_-_Graph_-_Optimization\",\"1.1\",\"PROCESS\")_\\n__\\t_{_\\n__\\t__\\t_Parameter_-_(\"AnimationKeyReductionTolerance\",\"0.000100\");_\\n__\\t__\\t_Parameter_-_(\"RemoveDupProperties\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"RemoveChildlessNodes\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"RemoveMultiMtlNodes\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"RemoveUselessChildNodes\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"MergeSiblingNodes\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"RemoveDegenerateTriShapeData\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"NiTriShapeVertexCacheOptimization\",\"FALSE\");_\\n__\\t__\\t_Parameter_-_(\"MergeSiblingTriShapes\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"NoMergeOnAlpha\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"RemoveExtraUVSets\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"RemoveUnnecessaryNormals\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"RemoveUnnecessaryVisControllers\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"RemoveNames\",\"FALSE\");_\\n__\\t__\\t_Parameter_-_(\"NameUnnamedObjects\",\"FALSE\");_\\n__\\t__\\t_Parameter_-_(\"RemoveBadTexturingProps\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"RemoveUnnecessaryExtraData\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"RemoveUnnecessaryLookAtControllers\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"RemoveHiddenBoneGeometry\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"ReduceAnimationKeys\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"SortByTexturingProp\",\"FALSE\");_\\n__\\t__\\t_Parameter_-_(\"WeldSkin\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"ExportPS2SoftwareSkin\",\"FALSE\");_\\n__\\t__\\t_Parameter_-_(\"ExportPS2HardwareSkin\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"ExportSoftwareSkin\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"ExportHardwareSkin\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"BonesPerPartition\",\"180\");_\\n__\\t__\\t_Parameter_-_(\"MoveBonesBeforeSkins\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"MoveEditorMarkersToRoot\",\"TRUE\");_\\n__\\t_}_\\n__\\t_Plugin_-_(\"ShaderLighting\",\"ShaderLighting_-_Plug-in\",\"1.0\",\"PROCESS\")_\\n__\\t_{_\\n__\\t_}_\\n__\\t_Plugin_-_(\"MeshLODClean\",\"MeshLODClean_-_Plug-in\",\"1.0\",\"PROCESS\")_\\n__\\t_{_\\n__\\t_}_\\n__\\t_Plugin_-_(\"BethsoftProcessPlugin\",\"TES4_-_Requirements_-_Plug-in\",\"1.0\",\"PROCESS\")_\\n__\\t_{_\\n__\\t__\\t_Parameter_-_(\"TES4DDS\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"TES4TexDir\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"TES4IncTex\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"TES4ZeroOrigin\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"TES4AnimFlags\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"TES4NeedBound\",\"FALSE\");_\\n__\\t__\\t_Parameter_-_(\"TES4Keyframes\",\"FALSE\");_\\n__\\t_}_\\n__\\t_Plugin_-_(\"ExtraData\",\"ExtraData_-_Plug-in\",\"1.0\",\"PROCESS\")_\\n__\\t_{_\\n__\\t_}_\\n__\\t_Plugin_-_(\"BSDestructionNodes\",\"BSDestructionNodes_-_Plug-in\",\"1.0\",\"PROCESS\")_\\n__\\t_{_\\n__\\t_}_\\n__\\t_Plugin_-_(\"BSSequenceMaker\",\"BSSequenceMaker_-_Plug-in\",\"1.0\",\"PROCESS\")_\\n__\\t_{_\\n__\\t_}_\\n__\\t_Plugin_-_(\"BSOrderedNodes\",\"BSOrderedNodes_-_Plug-in\",\"1.0\",\"PROCESS\")_\\n__\\t_{_\\n__\\t_}_\\n__\\t_Plugin_-_(\"BSMultiBoundNodes\",\"BSMultiBoundNodes_-_Plug-in\",\"1.0\",\"PROCESS\")_\\n__\\t_{_\\n__\\t_}_\\n__\\t_Plugin_-_(\"BSFadeNodes\",\"BSFadeNodes_-_Plug-in\",\"1.0\",\"PROCESS\")_\\n__\\t_{_\\n__\\t_}_\\n__\\t_Plugin_-_(\"BSLeafAnimNodes\",\"BSLeafAnimNodes_-_Plug-in\",\"1.0\",\"PROCESS\")_\\n__\\t_{_\\n__\\t_}_\\n__\\t_Plugin_-_(\"BSRenderOrder\",\"BSRenderOrder_-_Plug-in\",\"1.0\",\"PROCESS\")_\\n__\\t_{_\\n__\\t_}_\\n__\\t_Plugin_-_(\"BSRotAccumIntrp\",\"BSRotAccumIntrp_-_Plug-in\",\"1.0\",\"PROCESS\")_\\n__\\t_{_\\n__\\t_}_\\n__\\t_Plugin_-_(\"BSBehaviorGraph\",\"BSBehaviorGraph_-_Plug-in\",\"1.0\",\"PROCESS\")_\\n__\\t_{_\\n__\\t_}_\\n__\\t_Plugin_-_(\"ConvertNiToBS\",\"ConvertNiToBS_-_Plug-in\",\"1.0\",\"PROCESS\")_\\n__\\t_{_\\n__\\t_}_\\n__\\t_Plugin_-_(\"NifExportPlugin\",\"NIF_-_Exporter\",\"1.0\",\"EXPORT\")_\\n__\\t_{_\\n__\\t_}_\\n_}_\\n_"
	_PE_WEAPkey = "Script_-_(\"_-_PE_-_Weapon\",\"Export\")_\\n_{_\\n__\\t_Plugin_-_(\"KillHidden\",\"KillHidden_-_Plug-in\",\"1.1\",\"PROCESS\")_\\n__\\t_{_\\n__\\t__\\t_Parameter_-_(\"KILLHIDDEN_UNREFERENCED_BOOL\",\"TRUE\");_\\n__\\t_}_\\n__\\t_Plugin_-_(\"BSHavokProcess\",\"BSHavokProcess_-_Plug-in\",\"1.0\",\"PROCESS\")_\\n__\\t_{_\\n__\\t_}_\\n__\\t_Plugin_-_(\"AddOnPart\",\"AddOnPart_-_Plug-in\",\"1.1\",\"PROCESS\")_\\n__\\t_{_\\n__\\t_}_\\n__\\t_Plugin_-_(\"NiSceneGraphOptimizationPlugin\",\"Scene_-_Graph_-_Optimization\",\"1.1\",\"PROCESS\")_\\n__\\t_{_\\n__\\t__\\t_Parameter_-_(\"AnimationKeyReductionTolerance\",\"0.000100\");_\\n__\\t__\\t_Parameter_-_(\"RemoveDupProperties\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"RemoveChildlessNodes\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"RemoveMultiMtlNodes\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"RemoveUselessChildNodes\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"MergeSiblingNodes\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"RemoveDegenerateTriShapeData\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"NiTriShapeVertexCacheOptimization\",\"FALSE\");_\\n__\\t__\\t_Parameter_-_(\"MergeSiblingTriShapes\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"NoMergeOnAlpha\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"RemoveExtraUVSets\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"RemoveUnnecessaryNormals\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"RemoveUnnecessaryVisControllers\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"RemoveNames\",\"FALSE\");_\\n__\\t__\\t_Parameter_-_(\"NameUnnamedObjects\",\"FALSE\");_\\n__\\t__\\t_Parameter_-_(\"RemoveBadTexturingProps\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"RemoveUnnecessaryExtraData\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"RemoveUnnecessaryLookAtControllers\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"RemoveHiddenBoneGeometry\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"ReduceAnimationKeys\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"SortByTexturingProp\",\"FALSE\");_\\n__\\t__\\t_Parameter_-_(\"WeldSkin\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"ExportPS2SoftwareSkin\",\"FALSE\");_\\n__\\t__\\t_Parameter_-_(\"ExportPS2HardwareSkin\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"ExportSoftwareSkin\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"ExportHardwareSkin\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"BonesPerPartition\",\"180\");_\\n__\\t__\\t_Parameter_-_(\"MoveBonesBeforeSkins\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"MoveEditorMarkersToRoot\",\"FALSE\");_\\n__\\t_}_\\n__\\t_Plugin_-_(\"ShaderLighting\",\"ShaderLighting_-_Plug-in\",\"1.0\",\"PROCESS\")_\\n__\\t_{_\\n__\\t_}_\\n__\\t_Plugin_-_(\"MeshLODClean\",\"MeshLODClean_-_Plug-in\",\"1.0\",\"PROCESS\")_\\n__\\t_{_\\n__\\t_}_\\n__\\t_Plugin_-_(\"BethsoftProcessPlugin\",\"TES4_-_Requirements_-_Plug-in\",\"1.0\",\"PROCESS\")_\\n__\\t_{_\\n__\\t__\\t_Parameter_-_(\"TES4DDS\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"TES4TexDir\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"TES4IncTex\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"TES4ZeroOrigin\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"TES4AnimFlags\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"TES4NeedBound\",\"FALSE\");_\\n__\\t__\\t_Parameter_-_(\"TES4Keyframes\",\"TRUE\");_\\n__\\t_}_\\n__\\t_Plugin_-_(\"ExtraData\",\"ExtraData_-_Plug-in\",\"1.0\",\"PROCESS\")_\\n__\\t_{_\\n__\\t_}_\\n__\\t_Plugin_-_(\"BSDestructionNodes\",\"BSDestructionNodes_-_Plug-in\",\"1.0\",\"PROCESS\")_\\n__\\t_{_\\n__\\t_}_\\n__\\t_Plugin_-_(\"BSOrderedNodes\",\"BSOrderedNodes_-_Plug-in\",\"1.0\",\"PROCESS\")_\\n__\\t_{_\\n__\\t_}_\\n__\\t_Plugin_-_(\"BSMultiBoundNodes\",\"BSMultiBoundNodes_-_Plug-in\",\"1.0\",\"PROCESS\")_\\n__\\t_{_\\n__\\t_}_\\n__\\t_Plugin_-_(\"BSFadeNodes\",\"BSFadeNodes_-_Plug-in\",\"1.0\",\"PROCESS\")_\\n__\\t_{_\\n__\\t_}_\\n__\\t_Plugin_-_(\"BSLeafAnimNodes\",\"BSLeafAnimNodes_-_Plug-in\",\"1.0\",\"PROCESS\")_\\n__\\t_{_\\n__\\t_}_\\n__\\t_Plugin_-_(\"BSRenderOrder\",\"BSRenderOrder_-_Plug-in\",\"1.0\",\"PROCESS\")_\\n__\\t_{_\\n__\\t_}_\\n__\\t_Plugin_-_(\"BSOrderSkinGeom\",\"BSOrderSkinGeom_-_Plug-in\",\"1.0\",\"PROCESS\")_\\n__\\t_{_\\n__\\t_}_\\n__\\t_Plugin_-_(\"BSBehaviorGraph\",\"BSBehaviorGraph_-_Plug-in\",\"1.0\",\"PROCESS\")_\\n__\\t_{_\\n__\\t_}_\\n__\\t_Plugin_-_(\"ConvertNiToBS\",\"ConvertNiToBS_-_Plug-in\",\"1.0\",\"PROCESS\")_\\n__\\t_{_\\n__\\t_}_\\n__\\t_Plugin_-_(\"NifExportPlugin\",\"NIF_-_Exporter\",\"1.0\",\"EXPORT\")_\\n__\\t_{_\\n__\\t_}_\\n_}_\\n_"
	_PE_SKYkey = "Script_-_(\"_-_PE_-_Sky\",\"Export\")_\\n_{_\\n__\\t_Plugin_-_(\"BSHavokProcess\",\"BSHavokProcess_-_Plug-in\",\"1.0\",\"PROCESS\")_\\n__\\t_{_\\n__\\t_}_\\n__\\t_Plugin_-_(\"NiSceneGraphOptimizationPlugin\",\"Scene_-_Graph_-_Optimization\",\"2.0\",\"PROCESS\")_\\n__\\t_{_\\n__\\t__\\t_Parameter_-_(\"AnimationKeyReductionTolerance\",\"0.000100\");_\\n__\\t__\\t_Parameter_-_(\"RemoveDupProperties\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"RemoveChildlessNodes\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"RemoveMultiMtlNodes\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"RemoveUselessChildNodes\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"MergeSiblingNodes\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"RemoveDegenerateTriShapeData\",\"FALSE\");_\\n__\\t__\\t_Parameter_-_(\"NiTriShapeVertexCacheOptimization\",\"FALSE\");_\\n__\\t__\\t_Parameter_-_(\"MergeSiblingTriShapes\",\"FALSE\");_\\n__\\t__\\t_Parameter_-_(\"NoMergeOnAlpha\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"RemoveExtraUVSets\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"RemoveUnnecessaryNormals\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"RemoveUnnecessaryVisControllers\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"RemoveNames\",\"FALSE\");_\\n__\\t__\\t_Parameter_-_(\"NameUnnamedObjects\",\"FALSE\");_\\n__\\t__\\t_Parameter_-_(\"RemoveBadTexturingProps\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"RemoveUnnecessaryExtraData\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"RemoveUnnecessaryLookAtControllers\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"RemoveHiddenBoneGeometry\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"ReduceAnimationKeys\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"SortByTexturingProp\",\"FALSE\");_\\n__\\t__\\t_Parameter_-_(\"WeldSkin\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"ExportPS2SoftwareSkin\",\"FALSE\");_\\n__\\t__\\t_Parameter_-_(\"ExportPS2HardwareSkin\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"ExportSoftwareSkin\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"ExportHardwareSkin\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"BonesPerPartition\",\"180\");_\\n__\\t__\\t_Parameter_-_(\"MoveBonesBeforeSkins\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"MoveEditorMarkersToRoot\",\"FALSE\");_\\n__\\t_}_\\n__\\t_Plugin_-_(\"ShaderLighting\",\"ShaderLighting_-_Plug-in\",\"1.0\",\"PROCESS\")_\\n__\\t_{_\\n__\\t_}_\\n__\\t_Plugin_-_(\"KillHidden\",\"KillHidden_-_Plug-in\",\"1.1\",\"PROCESS\")_\\n__\\t_{_\\n__\\t__\\t_Parameter_-_(\"KILLHIDDEN_UNREFERENCED_BOOL\",\"FALSE\");_\\n__\\t__\\t_Parameter_-_(\"KILLHIDDEN_ALLVERTSSKINNED_BOOL\",\"TRUE\");_\\n__\\t_}_\\n__\\t_Plugin_-_(\"BethsoftProcessPlugin\",\"TES4_-_Requirements_-_Plug-in\",\"1.0\",\"PROCESS\")_\\n__\\t_{_\\n__\\t__\\t_Parameter_-_(\"TES4DDS\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"TES4TexDir\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"TES4IncTex\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"TES4ZeroOrigin\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"TES4AnimFlags\",\"TRUE\");_\\n__\\t__\\t_Parameter_-_(\"TES4NeedBound\",\"FALSE\");_\\n__\\t_}_\\n__\\t_Plugin_-_(\"ExtraData\",\"ExtraData_-_Plug-in\",\"1.0\",\"PROCESS\")_\\n__\\t_{_\\n__\\t_}_\\n__\\t_Plugin_-_(\"BSDestructionNodes\",\"BSDestructionNodes_-_Plug-in\",\"1.0\",\"PROCESS\")_\\n__\\t_{_\\n__\\t_}_\\n__\\t_Plugin_-_(\"BSOrderedNodes\",\"BSOrderedNodes_-_Plug-in\",\"1.0\",\"PROCESS\")_\\n__\\t_{_\\n__\\t_}_\\n__\\t_Plugin_-_(\"BSMultiBoundNodes\",\"BSMultiBoundNodes_-_Plug-in\",\"1.0\",\"PROCESS\")_\\n__\\t_{_\\n__\\t_}_\\n__\\t_Plugin_-_(\"BSRenderOrder\",\"BSRenderOrder_-_Plug-in\",\"1.0\",\"PROCESS\")_\\n__\\t_{_\\n__\\t_}_\\n__\\t_Plugin_-_(\"MeshLODClean\",\"MeshLODClean_-_Plug-in\",\"1.0\",\"PROCESS\")_\\n__\\t_{_\\n__\\t_}_\\n__\\t_Plugin_-_(\"ConvertNiToBS\",\"ConvertNiToBS_-_Plug-in\",\"1.0\",\"PROCESS\")_\\n__\\t_{_\\n__\\t_}_\\n__\\t_Plugin_-_(\"NifExportPlugin\",\"NIF_-_Exporter\",\"1.0\",\"EXPORT\")_\\n__\\t_{_\\n__\\t_}_\\n_}_\\n_"
	--print _exportloc
	--file = "D:\\Games\Fallout New Vegas\FNVExtracted\Data\meshes\architecture\strip\gamorrahyard.nif"
	--file = "D:\\Games\Fallout New Vegas\FNVExtracted\Data\meshes\Weapons\2HandAutomatic\AssaultRifle.NIF"
	--file = "D:\\Games\\Fallout New Vegas\\FNVExtracted\\Data\\meshes\\weapons\\1handpistol\\9mm.nif"
	indexlist = #(0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,31,30,34)
	indexskiplist = #(0,1,undefined,3,4,5,6,undefined,undefined,9,10,undefined,undefined,13,undefined,15,undefined,undefined,undefined,19,undefined,undefined,undefined,undefined,undefined,undefined,undefined,undefined,undefined,undefined,undefined,undefined,undefined,undefined,undefined,undefined,undefined,undefined,undefined,undefined,undefined,undefined,undefined,undefined,undefined,undefined,undefined,undefined,undefined,undefined,undefined,undefined,undefined,undefined,undefined,undefined,undefined,undefined,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85)
	index2list = #(1,57,25,29,31,33,39,46,52,66,78,64,41,81,24,55,65,32,30,32,34,32,32,32,32,83,65,32,83,32,56,39,46)
	mswpfull = (dotnetClass "System.IO.File").ReadAllLines (xEditLoc + "ElementConverions\MaterialSwaps.csv")
	mswpnifs = (dotnetClass "System.IO.File").ReadAllLines (xEditLoc + "ElementConverions\MaterialSwapsNifs.csv")
	mswp3dns = (dotnetClass "System.IO.File").ReadAllLines (xEditLoc + "ElementConverions\MaterialSwaps3Names.csv")
	LODList = #()
	bMSWP = false
	MSWPList = #()
	/*
	if MSWPList != undefined then
	(
		if MSWPList.count > 0 then
		(
			for i = 1 to MSWPList.Count do
			(
				--print MSWPList[i]
				--print mswpfull[(MSWPList[i])]
			)
		)
	)
	*/
	
	slMatTemplate = GetMaterialTemplate()
	--slMatTemplate = (dotnetClass "System.IO.File").ReadAllLines (fileRoot + "templateEmpty.BGSM")
	for s in slMatTemplate do print s
	
	MatCount = 0
	--files = #("D:\\Games\Fallout New Vegas\FNVExtracted\Data\meshes\Weapons\2HandAutomatic\AssaultRifle.NIF")
	--files = #("D:\Games\Fallout New Vegas\FNVExtracted\Data\Meshes\effects\haroldheartroots.nif")
	--files = #("D:\\Games\Fallout New Vegas\FNVExtracted\Data\meshes\architecture\strip\gamorrahyard.nif")
	--files = #("D:\Games\Fallout New Vegas\FNVExtracted\Data\Meshes\scol\scolgsschool.nif")
	--files = getFiles "D:\\Games\Fallout New Vegas\FNVExtracted\Data\\Meshes\\*.nif"
	print files.count
	FileCount = 0
	--startloc = undefined
	startpoint = false
	bSingleFile = false
	bLod = false
	bObjLodOnly = false
	bLodOnly = false
	
	bFinalize = false
	
	gc() --Garbage Collection.
	freescenebitmaps() --Cleans up in texture memory.
	clearUndoBuffer() --Removes your Undo's
	macros.run "Medit Tools" "clear_medit_slots"
	macros.run "Medit Tools" "condense_medit_slots"
	
	k = 1
	BSLightingFXMode = true
	if batchstart != undefined then
	(
		k = batchstart as integer
		k = (k * 483 + 1)
		startpoint = true
		BSLightingFXMode = true
	)
	
	--for f in files while(not keyboard.escPressed) do with undo off
	for k = k to files.count do with undo off
	(
		if k == files.count then bFinalize = true
		s=timeStamp() 
		f = files[k]
		if f == startloc then 
		(
			startpoint = true
			print(k as string)
			print((k / 483) as string)
		)
		if batchstart != undefined then
		(
			FileCount += 1
			print (FileCount as string)
			if BSLightingFXMode == true then
				if FileCount == 484 then --483 iterations
					exit
		)
		if startpoint == false then continue
		if f == (fileRoot + "Meshes\\nvdlc04\\\\effects\\nvdlc04_wastelandnukeexp.nif") then continue
		if f == (fileRoot + "Meshes\\pipboy3000\\pipboyarm.nif") then continue
		if findString (replace (substituteString (toLower f) "\\\\" "\\") 1 fileRoot.count "") "meshes\\landscape\\lod\\" == 1 then bLod = true
		if bLod == false then
			if bLodOnly == true then
				continue
		if bObjLodOnly == true then
			if findString (replace (substituteString (toLower f) "\\\\" "\\") 1 fileRoot.count "") "meshes\\landscape\\lod\\wastelandnv\\blocks\\" != 1 then
				continue
		
		print (substituteString f "\\" "\\\\")
		--Turn off import vertex colors in nif import options
		--delete objects
		resetMaxFile #noPrompt
		--disableSceneRedraw()
		gc() --Garbage Collection.
		freescenebitmaps() --Cleans up in texture memory.
		clearUndoBuffer() --Removes your Undo's
		macros.run "Medit Tools" "clear_medit_slots"
		macros.run "Medit Tools" "condense_medit_slots"
		
		
		--max file import --Import Prompt
		file = f
		file_name = getFilenameFile file
		gamefilepath = substituteString file (fileRoot + "meshes\\") ""
		bIsAnimated = false
		
		for j = mswpnifs.count to 1 by -1 do
		(
			--print mswpnifs[i]
			if mswpnifs[j] == gamefilepath then 
			(
				append MSWPList j
				deleteItem mswpnifs j
				-- delete items from other arrays later
			)
			--bMSWP = true
		)
		
		importFile file #noPrompt
		
		root = "undefined"
		index = undefined
		index2 = undefined
		--for i = 1 to objects.count do if (classof objects[i].modifiers[1] == bhkRigidBody) == true then root = objects[i]
		while getnodebyname "bhkRigidBody" != undefined do
		(
			-- All collision shapes have a bhkRigidBody
			select(getnodebyname "bhkRigidBody")
			$.name = "BoxHelper"
			rootparent = selection[1].parent
			max modify mode
			hwndVC = (windows.getChildHWND #max "Rigid Body Parameters")[2]
			child_array = UIAccessor.GetChildWindows hwndVC
			hwnd = child_array[3]
			(
				local WM_COMMAND = 0x111 -- Windows Message: Command
				local CB_GETCURSEL = 0x0147 -- ComboBox message: Get current selection
				index = (windows.sendMessage hwnd CB_GETCURSEL 0 0) -- get selection
				if index == 0 then index = 1 -- unidentified to static
				if index == 2 then index = 6 -- proj
				if index == 25 then index = 19 --itemPick to small debris
				-- if index == 13 then index =
				--messageBox index
				index = indexskiplist[(index + 1)] -- Object Type
				if index != undefined then index = indexlist[(index + 1)]
				
			)
			f_rb_mass									= UIAccessor.GetWindowText child_array[16] as float
			f_rb_friction								= UIAccessor.GetWindowText child_array[20] as float
			f_rb_restitution							= UIAccessor.GetWindowText child_array[24] as float
			f_rb_linear_damping						= UIAccessor.GetWindowText child_array[29] as float
			f_rb_angular_damping					= UIAccessor.GetWindowText child_array[34] as float
			f_rb_max_linear_velocity				= UIAccessor.GetWindowText child_array[39] as float
			f_rb_max_angular_velocity				= UIAccessor.GetWindowText child_array[44] as float
			f_rb_penetration_depth					= UIAccessor.GetWindowText child_array[49] as float
			s_rb_quality = UIAccessor.GetWindowText child_array[12]
			if s_rb_quality != undefined then
			(
				if s_rb_quality == "0: Invalid" 					then s_rb_quality = undefined
				if s_rb_quality == "1: Fixed" 						then s_rb_quality = 0
				if s_rb_quality == "2: Keyframed" 				then s_rb_quality = 1
				if s_rb_quality == "3: Debris" 					then s_rb_quality = 3
				if s_rb_quality == "4: Moving" 					then s_rb_quality = 4
				if s_rb_quality == "5: Critical" 					then s_rb_quality = 5
				if s_rb_quality == "4: Moving5: Critical" 		then s_rb_quality = 4
				if s_rb_quality == "6: Bullet" 						then s_rb_quality = 6
				if s_rb_quality == "7: User" 						then s_rb_quality = undefined
				if s_rb_quality == "8: Character" 				then s_rb_quality = undefined
				if s_rb_quality == "9: Keyframed Report" 		then s_rb_quality = 2
			)
			--return messageBox $.name
			if index == undefined then index = 1
			delete selection
			children = rootparent.children
			for i = 1 to children.count do
			(
				if children[i].name == "bhkPackedNiTriStripsShape" then 
				(
					root = children[i]
					--messageBox(selection[1].modifiers[#bhkRigidBodyModifier].material + 2)
					--messageBox children[i].name
					index2 = index2list[(root.modifiers[#bhkRigidBodyModifier].material + 2)]
				)
				if children[i].name == "bhkConvexVerticesShape" then 
				(
					root = children[i]
					index2 = index2list[(root.modifiers[#bhkRigidBodyModifier].material + 2)]
				)
				if children[i].name == "bhkBoxShape" then 
				(
					root = children[i]
					index2 = index2list[(root.baseObject.material + 2)]
				)
				if children[i].name == "bhkCapsuleShape" then 
				(
					root = children[i]
					index2 = index2list[(root.baseObject.material + 2)]
				)
				if children[i].name == "bhkSphereShape" then 
				(
					root = children[i]
					index2 = index2list[(root.baseObject.material + 2)]
				)
			)
			--getmaterial selection
			
			print index
			print index2
			if index == undefined then 
			(
				print "Index undefined. Skipping Collision"
				--messageBox("Index undefined in " + file + ". Possibly no Collision")
				--if index2 == undefined then messageBox("Index2 undefined in " + file)
				index2 = undefined
			)
			--if index2 == undefined then return messageBox("Index2 undefined in " + file)
			
			if root != "undefined" then
			(
				root.name = ("c_" + rootparent.name)
				convertto root PolyMeshObject
			)
			if root != "undefined" AND index != undefined then 
			(
				(
					select root
					
					--root.material = (BSLightingFX ())
					root.material = (BSBlinn())
					MatCount += 1
					print ((MatCount as string) + " Materials Created")
					if root.material != undefined then
					(
						root.material[#Standard].wire = on
						root.material[#Standard][#Shader_Basic_Parameters].Diffuse = color 255 0 0
						addmodifier root (Shell ())
						root.modifiers[#Shell].outerAmount = 0
						root.modifiers[#Shell].autosmooth = off
						maxOps.CollapseNodeTo root 1 off
					)
					
					maxOps.cloneNodes root cloneType:#copy newNodes:&nnl #nodialog
					nnl[1].name = ("rb_" + rootparent.name)
					nnl[1].name = (rootparent.name)
					local nnlparent = nnl[1].parent
					if classOf nnlparent == BoneGeometry then nnlparent = nnlparent.parent
					--nnl[1].parent = nnlparent
					root.parent = nnl[1]
					
					
					addmodifier root (Havok_Shape())
					root.modifiers[#Shape].shapeType = 5
					--deletemodifier root (Havok_Shape())
					select root
					max utility mode 
					UtilityPanel.OpenUtility collsiongroup -- CollisionGroup Must be open
					local hwndVC = (windows.getChildHWND #max "CollisionGroup")[2]
					child_array = UIAccessor.GetChildWindows hwndVC
					(
						hwnd = child_array[3]
						local WM_COMMAND = 0x111 -- Windows Message: Command
						local CB_SETCURSEL = 0x014E -- ComboBox message: Set current selection
						local CBN_SELCHANGE = 1
						my_id = UIAccessor.getWindowResourceID hwnd
						windows.sendMessage hwnd CB_SETCURSEL index2 0 -- set selection
						windows.sendMessage hwndVC WM_COMMAND ((bit.shift CBN_SELCHANGE 16) + my_id) hwnd -- message parent
						hwnd = child_array[6]
						local WM_COMMAND = 0x111 -- Windows Message: Command
						local CB_SETCURSEL = 0x014E -- ComboBox message: Set current selection
						local CBN_SELCHANGE = 1
						my_id = UIAccessor.getWindowResourceID hwnd
						windows.sendMessage hwnd CB_SETCURSEL index 0 -- set selection
						windows.sendMessage hwndVC WM_COMMAND ((bit.shift CBN_SELCHANGE 16) + my_id) hwnd -- message parent
					)
					UIAccessor.PressButton (windows.getChildHWND hwndVC "Apply To Selected")[1]
				)
			)
		)
		--undo off
		select (for o in objects where not classOf o == BoneGeometry collect o)
		if bLod == false then
			for j = 1 to selection.count do ConvertToPoly selection[j]
		/*
		else
		(
			for j = 1 to selection.count where selection[j].faces.count != 0 do 
			(
				setLodBorders(selection[j])
				ConvertToPoly selection[j]
			)
		)
		*/
			
		/*
		for o in objects where not classOf o == BoneGeometry do
		(
			ConvertToPoly o 
		)
		*/
		--ConvertToPoly (for o in objects where not classOf o == BoneGeometry collect o)
		--convertto (for o in objects where not classOf o == BoneGeometry collect o) PolyMeshObject
		--print root.name
		--collisiongroup
		while getnodebyname "Multibound" != undefined do
		(
			select (getnodebyname "Multibound")
			oMultibound = sphere()
			oMultibound.pos = $.pos
			oMultibound.radius = (($.max[3] - $.min[3]) / 2)
			oMultibound.segs = 10 -- based on one example
			delete $
		)
		if bLod == false then
			select (for o in objects where ((o.modifiers[#Shape] == undefined) and (not classOf o == BoneGeometry)) collect o)
		else
			select (for o in objects where not classOf o == BoneGeometry collect o)
		
		
		if selection.count>0 do
		(
			for i=1 to selection.count do 
			(
				
				if selection[i].material != undefined then
					if selection[i].material.name == "BSBlinn" then
						continue
				(
					-- Save Material
					
					matfile = file
					matfile = replace matfile (fileRoot.count + 1) 6 "Materials\\new_vegas"
					matfile = replace matfile 1 fileRoot.count _exportloc
					matfile = replace matfile (matfile.count - 3) 4 "\\"
					
					local _3DName = selection[i].name
					if MSWPList != undefined then
					(
						if MSWPList.count > 0 then
						(
							for i = 1 to MSWPList.Count do
							(
								--print _3DName
								--print mswp3dns[(MSWPList[i])]
								--if _3DName == mswp3dns[(MSWPList[i])] then
								if findString _3DName mswp3dns[(MSWPList[i])] == 1 then
								(
									_3DName = mswp3dns[(MSWPList[i])] -- Some 3D Names leave out the ":0"
									pInfo = (filterString mswpfull[(MSWPList[i])] ";")
									_MatName = _exportloc + "Materials\\new_vegas\\MSWP\\" + pInfo[2] + ".BGSM" -- Editor ID
									_TX00 = undefined
									_TX01 = undefined
									_TX02 = undefined
									_TX03 = undefined
									_TX04 = undefined
									_TX05 = undefined
									if pInfo[4] != undefined then _TX00 = fileRoot + "textures\\new_vegas\\" + pInfo[4] -- Diffuse
									if pInfo[5] != undefined then _TX01 = fileRoot + "textures\\new_vegas\\" + pInfo[5] -- Normal
									if pInfo[6] != undefined then _TX02 = fileRoot + "textures\\new_vegas\\" + pInfo[6] -- Env Mask
									if pInfo[7] != undefined then _TX03 = fileRoot + "textures\\new_vegas\\" + pInfo[6] -- Glow
									if pInfo[8] != undefined then _TX04 = fileRoot + "textures\\new_vegas\\" + pInfo[6] -- Paralax
									if pInfo[9] != undefined then _TX05 = fileRoot + "textures\\new_vegas\\" + pInfo[9] -- Env
									if BSLightingFXMode == true then
										CreateMaterial 2 selection[i].material _MatName _TX00 _TX01 _TX02 _TX03 _TX04 _TX05 bLod
									else
										CreateMaterialBSBlinn 2 _MatName fileRoot _exportloc _TX00 _TX01 _TX02 _TX03 _TX04 _TX05 slMatTemplate selection[i]
									MatCount += 1
									print ((MatCount as string) + " Materials Created")
									deleteItem mswp3dns MSWPList[i]
									deleteItem mswpfull MSWPList[i]
								)
							)
						)
					)
					_3DName = substituteString _3DName ":" "#"
					_MatName = matfile + _3DName + ".BGSM"
					
					if selection[i].material != undefined then
					(
						_TexDiffuse = undefined
						_TexNormal = undefined
						_TexSpecMask = undefined --Alpha?
						_TexEnvironmentMask = undefined
						_TexEnvironment = undefined
						_TexGlow = undefined
						/*
						--Niftools Shader
						if selection[i].material.maps[1] != undefined then _TexDiffuse = selection[i].material.maps[1].filename -- Diffuse
						if selection[i].material.maps[6] != undefined then _TexNormal = selection[i].material.maps[6].normal_map.filename -- Bump
						if selection[i].material.maps[7] != undefined then _TexNormal = selection[i].material.maps[7].filename -- Normal
						if selection[i].material.maps[12] != undefined then _TexEnvironmentMask = selection[i].material.maps[12].filename -- Env Mask
						if selection[i].material.maps[13] != undefined then _TexEnvironment = selection[i].material.maps[13].filename --Env
						*/
							
						if selection[i].material.maps[2] != undefined then _TexDiffuse = selection[i].material.maps[2].filename --Diffuse
						if selection[i].material.maps[6] != undefined then _TexGlow = selection[i].material.maps[6].filename --Glow
						--if selection[i].material.maps[9] != undefined then _TexNormal = selection[i].material.maps[9].normal_map.filename --Normal
						if selection[i].material.maps[9] != undefined then 
						(
							_TexNormal = selection[i].material.maps[9].normal_map.name --Normal
							if findString _TexNormal "Data\\" == 1 then _Texnormal = replace _Texnormal 1 5 ""
							_TexNormal = replace _TexNormal 1 8 (_exportloc + "textures\\new_vegas")
						)						
						if selection[i].material.maps[7] != undefined then _TexSpecMask = selection[i].material.maps[7].filename --Alpha
						if selection[i].material.maps[10] != undefined then 
						(
							if hasProperty selection[i].material.maps[10] "map" == true then _TexEnvironment = selection[i].material.maps[10].map.filename
							else _TexEnvironment = selection[i].material.maps[10].filename
						)
						-- for non niftools shader
						--selection[i].material.maps[7].filename --Alpha
						--selection[i].material.maps[2].filename --Diffuse
						--selection[i].material.maps[9].normal_map.filename --Normal
						--selection[i].material.maps[6].filename --Glow? (self illumination)
						--selection[i].material.maps[10].map.filename -- Environment Map
						--selection[i].material.maps[10].mask.filename -- Environment Mask
						if selection[i].material.maps[1] != undefined then return messagebox ("Map 1 defined in: " + selection[i].name)
						if selection[i].material.maps[3] != undefined then return  messagebox ("Map 3 defined in: " + selection[i].name)
						if selection[i].material.maps[4] != undefined then return  messagebox ("Map 4 defined in: " + selection[i].name)
						if selection[i].material.maps[5] != undefined then return  messagebox ("Map 5 defined in: " + selection[i].name)
						if selection[i].material.maps[8] != undefined then return  messagebox ("Map 8 defined in: " + selection[i].name)
						if selection[i].material.maps[11] != undefined then return  messagebox ("Map 11 defined in: " + selection[i].name)
						if selection[i].material.maps[12] != undefined then return  messagebox ("Map 12 defined in: " + selection[i].name)
					)
					--for s in slMatTemplate do print s
					if BSLightingFXMode == true then
						CreateMaterial 1 selection[i].material _MatName _TexDiffuse _TexNormal _TexSpecMask _TexGlow undefined _TexEnvironment bLod
					else
						CreateMaterialBSBlinn 1 _MatName fileRoot _exportloc undefined undefined undefined undefined undefined undefined slMatTemplate selection[i]
					selection[i].material = meditmaterials[1]
					MatCount += 1
					print ((MatCount as string) + " Materials Created")
					--return messageBox(_TexDiffuse)
					--return messageBox(selection[i].material.diffuseMap)
					--return messageBox(selection[i].name)
				)
			)
		)	
		
		
		--if root != "undefined" then deselect root
		if bLod == false then
		(
			select (for o in objects where ((o.modifiers[#Shape] == undefined) and (not classOf o == BoneGeometry)) collect o)
			macros.run "Havok Physics" "mcrPhysics_createSingleRigidBody"
			for i = 1 to selection.count do 
			(
				-- Mass for static
				selection[i].modifiers[#Rigid_Body].mass = 60
				-- Mass
				if ((f_rb_mass != 0) and (f_rb_mass != undefined)) then 
				(
					selection[i].modifiers[#Rigid_Body].mass = f_rb_mass
				)
				-- Friction
				if ((f_rb_friction != 0) and (f_rb_friction != undefined)) then 
				(
					selection[i].modifiers[#Rigid_Body].friction = f_rb_friction
				)
				-- Restitution
				if ((f_rb_restitution != 0) and (f_rb_restitution != undefined)) then 
				(
					selection[i].modifiers[#Rigid_Body].restitution = f_rb_restitution
				)
				-- Linear Damping
				if ((f_rb_linear_damping != 0) and (f_rb_linear_damping != undefined)) then 
				(
					selection[i].modifiers[#Rigid_Body].changeLinearDamping = on
					selection[i].modifiers[#Rigid_Body].linearDamping = f_rb_linear_damping
				)
				-- Angular Damping
				if ((f_rb_angular_damping != 0) and (f_rb_angular_damping != undefined)) then 
				(
					selection[i].modifiers[#Rigid_Body].changeAngularDamping = on
					selection[i].modifiers[#Rigid_Body].AngularDamping = f_rb_angular_damping
				)
				-- Max Linear Velocity
				if ((f_rb_max_linear_velocity != 0) and (f_rb_max_linear_velocity != undefined)) then 
				(
					selection[i].modifiers[#Rigid_Body].changeMaxLinearVelocity = on
					selection[i].modifiers[#Rigid_Body].maxLinearVelocity = f_rb_max_linear_velocity
				)
				-- Max Angular Velocity
				if ((f_rb_max_angular_velocity != 0) and (f_rb_max_angular_velocity != undefined)) then 
				(
					selection[i].modifiers[#Rigid_Body].changeMaxAngularVelocity = on
					selection[i].modifiers[#Rigid_Body].maxAngularVelocity = f_rb_max_angular_velocity
				)
				-- penetration depth
				if ((f_rb_penetration_depth != 0) and (f_rb_penetration_depth != undefined)) then 
				(
					selection[i].modifiers[#Rigid_Body].changeAllowedPenetrationDepth = on
					selection[i].modifiers[#Rigid_Body].allowedPenetrationDepth = f_rb_max_angular_velocity
				)
				if s_rb_quality != undefined then
				(
					selection[i].modifiers[#Rigid_Body].changeQualityType = on
					selection[i].modifiers[#Rigid_Body].qualityType = s_rb_quality
				)
				if selection[i].modifiers[2].name == "Shape" then deletemodifier selection[i] 2
			)
		)
		
		select (for o in objects where (classOf o == BoneGeometry) collect o)
		for i = 1 to selection.count do
		(
			--if findstring selection[i].name "c_" == 1 then selection[i].name = replace selection[i].name 1 2 "b_"
		)
		
		select objects[1]
		if index == 5 then
		(
			eM=emptyModifier()
			addModifier objects[1] eM
			
			--Create the defintion for the custom attribute
			def=attributes testAttrib
			(
				--Parameter block to store the tracks of animation
				parameters testP rollout:testR
				(
					--A track of animation
					--Look under scripted plugins for the types that can be used.
					Prn type:#string UI:mySpinner
				)
				--The rollout that will show up in the modifier panel.
				rollout testR "Extra Data"
				(
					--The spinner that is connected to the animationTrack
					EditText mySpinner "Prn"
				)
			)
			--Add the definition to the emptyModifier
			custAttributes.add eM def
			objects[1].modifiers[#Attribute_Holder].testAttrib.Prn = "WEAPON"
			
			if setINISetting _exportINI "MAXIMMERSE" "EXPORT_SCRIPT" _PE_WEAPkey == false then
			(
				MessageBox "Failed to set export settings"
				Exit
			)			
			if setINISetting _exportINI "MAXIMMERSE" "EXPORT_SCRIPT_NAME" "_-_PE_-_Weapon" == false then
			(
				MessageBox "Failed to set export settings"
				Exit
			)		
		)
		--root.parent = GetNodeByName "NVGSSchoolHouse002"
		--root.parent = objects[1]
		
		--select objects[1]
		--print $.name
		index = undefined
		index2 = undefined
		DialogMonitorOPS.Enabled
		for i = currentMaterialLibrary.count to 1 by -1 do
			deleteItem currentMaterialLibrary i		
		while getnodebyname "PipBoyArm" != undefined do
		(
			delete(getnodebyname "PipBoyArm")
		)
		while getnodebyname "Bip01 R ForeTwistDriver" != undefined do
		(
			delete(getnodebyname "Bip01 R ForeTwistDriver")
		)
		while getnodebyname "Bip01 L ForeTwistDriver" != undefined do
		(
			delete(getnodebyname "Bip01 L ForeTwistDriver")
		)
		
		
		--lod
		if bLod == true then
		(
			local root = objects[1]
			
			-- TEST works but no difference in export
			/*
			delete root
			local root  = dummy()
			for o in objects where not o == root do o.parent = root
			*/
			
			root.pos = [0, 0, 0]
			local _newpath = replace (substituteString (toLower file) "\\\\" "\\") 1 fileRoot.count ""
			if findstring _newpath "\\blocks\\" == undefined then
			(
				
				root.name = "chunk"	
				while GetNodeByName "" != undefined do
				(
					local obj = GetNodeByName ""
					obj.name = "Land"
					if obj.material.diffuseMap != undefined then
					(
						local mat = copy obj.material
					)
					if obj.faces.count == 0 then delete obj
				)
				while objects.count > 2 do
				(
					--Should be mesh already
					--converttomesh objects[1]
					meshop.attach objects[3] objects[2] attachMat:#IDToMat condenseMat:true
				)
				/*
				while objects.count > 2 do
				(
					delete objects[3]
				)
				*/
				local obj = GetNodeByName "Land"
				mat.DecalParam = off
				mat.ExternalEmittanceParam = off
				mat.DecalNoFadeParam = off
				mat.HideSecretParam = off
				mat.ScreenSpaceReflectionsParam = off
				mat.ModelSpaceNormalParam = on
				mat.TwoSidedParam = off
				mat.CastShadowsParam = off
				mat.DissolveFadeParam = off
				mat.NonOccluderParam = off
				
				mat.AlphaParam = off
				mat.EditorAlphaTestRef = off
				mat.ZTestParam = on
				mat.ZWriteParam = on
				mat.SubSurfaceLightingParam = off
				mat.SpecularParam = off
				mat.AnisoLightingParam = off
				mat.ShowEmitParam = on
				mat.ApplyGlowmapToEmitParam = off
				mat.RefractionParam = off
				mat.RefractionFireParam = off
				mat.ParallaxOccParam = off
				mat.MultiLayerParallaxParam = off
				mat.HairParam = off
				mat.EnvmapEyeParam = off
				mat.EnvmapWindowParam = off
				mat.EnvmapLightFadeParam = off
				mat.TreeParam = off
				mat.GrayscaleColorParam = off
				mat.TwoSidedParam = off
				mat.ModelSpaceNormalParam = on
				mat.DecalParam = off
				mat.DecalNoFadeParam = off
				mat.ExternalEmittanceParam = off
				mat.HideSecretParam = off
				mat.CastShadowsParam = off
				mat.DissolveFadeParam = off
				mat.ScreenSpaceReflectionsParam = off
				mat.NonOccluderParam = off
				mat.SkinTintParam = off
				mat.UTilingParam = off
				mat.VTilingParam = off
				mat.BGSMatInit = off
				obj.material = mat
				
				objects[2].pos = [0, 0, 0]
				setLodBorders(GetNodeByName "Land")
				
				if setINISetting _exportINI "MAXIMMERSE" "EXPORT_SCRIPT" _PE_SKYkey == false then
				(
					MessageBox "Failed to set export settings"
					Exit
				)			
				if setINISetting _exportINI "MAXIMMERSE" "EXPORT_SCRIPT_NAME" "_-_PE_-_Sky" == false then
				(
					MessageBox "Failed to set export settings"
					Exit
				)		
			)
			else
			(
				root.name = "obj"	
				while GetNodeByName "" != undefined do
				(
					local obj = GetNodeByName ""
					obj.name = "obj"
					if obj.faces.count == 0 then 
						delete obj
					else
					(
						convertto obj PolyMeshObject
						local mat = obj.material
						-- FSF2 LOD Objects needs patching
						mat.DecalParam = off
						mat.ExternalEmittanceParam = off
						mat.DecalNoFadeParam = off
						mat.HideSecretParam = off
						mat.ScreenSpaceReflectionsParam = off
						mat.ModelSpaceNormalParam = on
						mat.TwoSidedParam = off
						mat.CastShadowsParam = off
						mat.DissolveFadeParam = off
						mat.NonOccluderParam = off
						
						mat.AlphaParam = off
						mat.EditorAlphaTestRef = off
						mat.ZTestParam = on
						mat.ZWriteParam = on
						mat.SubSurfaceLightingParam = off
						mat.SpecularParam = on
						mat.AnisoLightingParam = off
						mat.ShowEmitParam = on
						mat.ApplyGlowmapToEmitParam = off
						mat.RefractionParam = off
						mat.RefractionFireParam = off
						mat.ParallaxOccParam = off
						mat.MultiLayerParallaxParam = off
						mat.HairParam = off
						mat.EnvmapEyeParam = off
						mat.EnvmapWindowParam = off
						mat.EnvmapLightFadeParam = off
						mat.TreeParam = off
						mat.GrayscaleColorParam = off
						mat.TwoSidedParam = off
						mat.ModelSpaceNormalParam = off
						mat.DecalParam = off
						mat.DecalNoFadeParam = off
						mat.ExternalEmittanceParam = off
						mat.HideSecretParam = off
						mat.CastShadowsParam = off
						mat.DissolveFadeParam = off
						mat.ScreenSpaceReflectionsParam = off
						mat.NonOccluderParam = off
						mat.SkinTintParam = off
						mat.UTilingParam = off
						mat.VTilingParam = off
						mat.BGSMatInit = off
						mat.GrayscaleColorScaleParam = 1
						obj.material = mat
					)
				)
			)
			setUserPropBuffer root ""
			
			oMultibound = box()
			oMultibound.name = "Multibound"
			oMultibound.parent = root
			
			oMultibound.pos.x = objects[2].pos.x + 8196
			oMultibound.pos.y = objects[2].pos.y + 8196
			/*
			if objects[2].max.x != 0 then 
				oMultibound.pos.x = (objects[2].max.x / 2)
			else
				oMultibound.pos.x = (objects[2].min.x / 2)
			
			if objects[2].max.y != 0 then 
				oMultibound.pos.y = (objects[2].max.y / 2)
			else
				oMultibound.pos.y = (objects[2].min.y / 2)
			*/
			
			oMultibound.pos.z = 9904.000000
			oMultibound.length = objects[2].max.x - objects[2].min.x
			oMultibound.width = objects[2].max.y - objects[2].min.y
			oMultibound.height = 10384.000000
			oMultibound.material = BSBlinn()
			oMultibound.material[#Standard].wire = on
			oMultibound.material[#Standard][#Shader_Basic_Parameters].Diffuse = color 255 0 0
			--scale objects[2] [0.5, 0.5, 0.5]
			--objects[2].material.CastShadowsParam = off
		)
		
		
		select objects[1]
		--print (ClassOf selection[1] as string)
		if (ClassOf selection[1] as string) != "BoneGeometry" then 
		(
			--messagebox(ClassOf selection[1] as string)
			--continue
		)
		--exit
		_exportfile = file
		_exportfile = replace _exportfile (fileRoot.count + 1) 6 "Meshes\\new_vegas"
		--_exportfile = replace _exportfile (fileRoot.count + 1) 6 "MaxFiles"
		--_exportfile = replace _exportfile (_exportfile.count - 2) 3 "max"
		_exportfile = substituteString _exportfile fileRoot _exportloc
		--messagebox _exportfile
		--exit
		makeDir (getFilenamePath _exportfile) all:true
		print _exportfile
		
		/*
		probably meant only for character animations
		for o in objects do
		(
			if o.pos.isAnimated == true then bIsAnimated = true
			if o.rotation.isAnimated == true then bIsAnimated = true
			if o.scale.isAnimated == true then bIsAnimated = true
		)
		if bIsAnimated == true then
		(
			if setINISetting _exportINI "MAXIMMERSE" "EXPORT_SCRIPT" _PE_ANIMkey == false then
			(
				MessageBox "Failed to set export settings"
				Exit
			)			
			if setINISetting _exportINI "MAXIMMERSE" "EXPORT_SCRIPT_NAME" "_-_PE_-_Anim" == false then
			(
				MessageBox "Failed to set export settings"
				Exit
			)		
		)
		*/
		
		--saveMaxFile _exportfile
		DialogMonitorOPS.RegisterNotification handleBox id:#hello
		DialogMonitorOPS.Enabled = true
		exportFile _exportfile #noPrompt selectedOnly: true using: nif_export_class
		DialogMonitorOPS.Enabled = false
		if setINISetting _exportINI "MAXIMMERSE" "EXPORT_SCRIPT" _defexportscript == false then
		(
			MessageBox "Failed to reset export settings"
			Exit
		)
		if setINISetting _exportINI "MAXIMMERSE" "EXPORT_SCRIPT_NAME" "_-_PE_-_Static_-_Art" == false then
		(
			MessageBox "Failed to reset export settings"
			Exit
		)
		
		
		
		if bLod == true then
		(
			local _newpath
			local _newname
			_newpath = replace (substituteString (toLower file) "\\\\" "\\") 1 fileRoot.count ""
			_newpath = replace _newpath 1 21 ""
			_newname = getFilenameFile _newpath
			_newname = substituteString _newname ".level" "."
			_newname = substituteString _newname ".x-" ".-"
			_newname = substituteString _newname ".y-" ".-"
			_newname = substituteString _newname ".x" "."
			_newname = substituteString _newname ".y" "."
			if findstring _newpath "\\blocks\\" != undefined then
			(
				_newpath = substituteString _newpath "\\blocks\\" "\\objects\\"
				_newname = _newname + ".BTO"				
			)
			else
				_newname = _newname + ".BTR"
			_newpath = _exportloc + "Meshes\\Terrain\\" + _newpath
			_newpath = getFilenamePath _newpath
			makeDir _newpath all:true
			
			local iLevels
			if findstring _newname ".4.high." != undefined then
			(
				iLevels = 3
				local _newnameCopy = copy _newname
			)
			else
				iLevels = 1
			for i = 1 to iLevels do
			(
				if iLevels > 1 then
				(
					-- Starts at level 8
					local iLevel = (2^(i+2))
					_newname = substituteString _newnameCopy ".4.high." ("." + (iLevel as string) + ".")
					
					-- e.g.  wastelandnv.16.-20.-28.BTO to wastelandbv, 16, -20, -28, BTO	
					local slCoords = (filterString _newname ".")
					
					local iCoord_x = (slCoords[slCoords.count - 2] as integer)
					local iCoord_y = (slCoords[slCoords.count - 1] as integer)
					local iBlockSize = 4096 -- level 4 block div 4
					local iCoord_xDiff = mod iCoord_x iLevel
					local iCoord_yDiff = mod iCoord_y iLevel
						
					for o in objects where (ClassOf o != BoneGeometry) do o.parent = undefined
					if ClassOf objects[1] == BoneGeometry then delete objects[1]
					if getNodeByName "Multibound" != undefined then
						delete (getNodeByName "Multibound")
					
					if ((iCoord_xDiff != 0) or (iCoord_yDiff != 0)) then
					(
						--To Positive then subtract level
						if iCoord_xDiff < 0 then iCoord_xDiff = - iCoord_xDiff - iLevel
						if iCoord_yDiff < 0 then iCoord_yDiff = - iCoord_yDiff - iLevel
							
						-- Always move negative
						if iCoord_xDiff > 0 then iCoord_xDiff = - iCoord_xDiff
						if iCoord_yDiff > 0 then iCoord_yDiff = - iCoord_yDiff
						--move objects[1] [(iCoord_xDiff*iBlockSize),(iCoord_yDiff*iBlockSize),0]
						--print (objects[1].pos.x + iCoord_xDiff*iBlockSize)
						local obj = objects[1]
						/*
						obj.pivot = [0,0,0]
						obj.scale.x = (obj.scale.x)/iLevel
						obj.scale.y = (obj.scale.y)/iLevel
						obj.scale.z = (obj.scale.z)/iLevel
						iBlockSize = iBlockSize/iLevel
						*/
						
						objects[1].pos = [(objects[1].pos.x + iCoord_xDiff*iBlockSize),(objects[1].pos.y + iCoord_yDiff*iBlockSize),0]
						--resetxform obj
						--maxOps.CollapseNode obj true
						
					)
					
					local _newname2 = Copy _newname
					_newname = ""
					for j = 1 to (slCoords.count - 3) do
						_newname = _newname + slCoords[j] + "."
					iCoord_x = (iCoord_x + iCoord_xDiff) as integer
					iCoord_y = (iCoord_y + iCoord_yDiff) as integer
					_newname = _newname + (iCoord_x as string) + "."
					_newname = _newname + (iCoord_y as string)
					
					--Save it with the original name
					makeDir (_newpath + "groups\\" + _newname) all:true
					saveMaxFile (_newpath + "groups\\" + _newname + "\\"  + _newname2 + ".MAX")
					
					_newname = _newname + ".BTO"
				)
				if doesFileExist (_newpath + _newname) then
					deleteFile (_newpath + _newname)
				if i == iLevels then
				(
					if renameFile _exportfile (_newpath + _newname) == false then
					(
						MessageBox "Failed to rename lod"
						Exit
					)
				)
				else
				(
					if copyFile _exportfile (_newpath + _newname) == false then
					(
						MessageBox "Failed to Copy lod"
						Exit
					)
				)
				print ("Lod renamed to: " + _newpath + _newname)			
				append LODList ((substituteString file "\\\\" "\\") + ";" + _newpath + _newname)
			)
			bLod = false
			
		)
		
		/*
		(
			if UIAccessor.GetWindowText(DialogMonitorOPS.GetWindowHandle()) == "Display Gamebryo Export Errors/Warnings" then
				print ("Errors or Warnings while exporting " + f)
			else
				print "Success"
		)
		*/
		--exportFile ("D:\\Games\Fallout New Vegas\FNVFo4\Data\meshes\architecture\strip\\" + file_name + ".nif") #noPrompt selectedOnly: true
		--exportFile ("C:\\Users\\Terry\\OneDrive\\Documenten\\3dsMax\\export\\" + file_name + ".nif") #noPrompt selectedOnly: true
		--print "done"
		for i = currentMaterialLibrary.count to 1 by -1 do
			deleteItem currentMaterialLibrary i
		e=timeStamp()
		windows.processPostedMessages()
		format "%s\n" ((e-s)/1000.0) 
		if batchstart == undefined then
		(
			FileCount += 1
			if keyboard.escPressed do 
			(
				enableSceneRedraw()
				ShowTextures()
				exit
			)
		)
		print (FileCount as string)
		if BSLightingFXMode == true then
			if FileCount == 483 then
				exit
			
		--if FileCount == 8 then exit
		if bSingleFile == true then exit
	)
	--enableSceneRedraw()
	ShowTextures()
	viewport.ResetAllViews() 
	print (LODList.count as string)
	if LODList.count > 0 then
	(
		local LODListPath = _exportloc + "Meshes\\Terrain\\LODList.csv"
		if not doesFileExist LODListPath then
		(
			makeDir (getFilenamePath LODListPath) all:true
			out_file = createfile LODListPath
			close out_file
		)
		if batchstart == undefined then
		(
			local out_file = openFile LODListPath mode:"wt" --Remove Contents
		)
		else
			local out_file = openFile LODListPath mode:"at" --Append Text Mode
		for l in LODList do
		(
			format l to:out_file
			format "\n" to:out_file
		)
		close out_file
	)
	
	--if bFinalize == true then
	(
		local _INI_Path = "C:\\Users\\" + sysInfo.username + "\\OneDrive\\Projects\\FNV_to_FO4\\Profiles\\" + sysInfo.computername + "\\FNV_to_FO4.ini"
		local _exportloc = getINISetting _INI_Path "USERPATHS" "FNVConverted"
		_source = _exportloc + "Meshes\\Terrain\\"
		local dirsWorldSpaces = getDirectories (_source + "*")
		for dWrld in dirsWorldSpaces do
		(
			local _path = dWrld + "objects\\groups\\"
			local dirsGroups = getDirectories (_path + "*")
			for dGroup in dirsGroups do
			(
				resetMaxFile #noPrompt
				local root = BoneSys.createBone [0,0,0] [0,0,0] [0,0,0]
				root.name = "obj"
				root.width = 5
				root.height = 5
				resetxform root
				maxOps.CollapseNode root true
				local files = getFiles (dGroup + "*")
				--mergeMAXFile "D:\Games\Fallout New Vegas\FNVFo4 Converted\Data\Meshes\Terrain\wastelandnv\objects\groups\wastelandnv.8.-8.8"
				--return messagebox "return"
				for f in files do
				(
					--mergeMAXFile f #renameMtlDups #autoRenameDups
					mergeMAXFile f #mergeDups #useMergedMtlDups
				)
				if objects.count > 1 then
				(
					objects[2].name = "obj"
					while objects.count > 2 do
						polyop.attach objects[2] objects[3]
					--return messagebox "return"
					objects[2].parent = objects[1]
					select objects[1]
					local slName = (filterString (filenameFromPath dGroup) ".")
					local iLevel = slName[slName.count - 2] as integer
					local _exportname = dWrld + "objects\\"
					_exportname = _exportname + replace dGroup  1 (_path.count) ""
					_exportname = replace _exportname _exportname.count 1 ""
					
					-- Multibound
					(
						oMultibound = box()
						oMultibound.name = "Multibound"
						oMultibound.parent = root
						
						oMultibound.pos.x = (objects[2].max.x) - ((objects[2].max.x - objects[2].min.x)/2)
						oMultibound.pos.y = (objects[2].max.y) - ((objects[2].max.y - objects[2].min.y)/2)
						oMultibound.pos.z = (objects[2].min.z) -- - ((objects[2].max.z - objects[2].min.z)/2)
						
						oMultibound.width = objects[2].max.x - objects[2].min.x
						oMultibound.length = objects[2].max.y - objects[2].min.y
						oMultibound.height = objects[2].max.z - objects[2].min.z
						
						oMultibound.material = BSBlinn()
						oMultibound.material[#Standard].wire = on
						oMultibound.material[#Standard][#Shader_Basic_Parameters].Diffuse = color 255 0 0
					)
					
					SaveMaxFile (_exportname + ".max")
					print _exportname
					exportFile (_exportname + ".nif") #noPrompt selectedOnly: true using: nif_export_class
					
					if doesFileExist (_exportname + ".BTO") then
						deleteFile (_exportname + ".BTO")
					if renameFile (_exportname + ".nif") (_exportname + ".BTO") == false then
					(
						MessageBox "Failed to rename lod"
						Exit
					)
				)
			)
		)
	)
)