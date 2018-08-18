--include "Startup\Materials\BSLightingFX.ms"
--include "Startup\Materials\BSMaterialUIUtils.ms"

(	
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

	fn CreateMaterial i _MatName _TX00 _TX01 _TX02 _TX03 _TX04 _TX05 =
	(
		-- BSBlinn seems a better option but materials will more complicated unless material saving functions can be added to BSBlinn
		setmeditmaterial i (BSLightingFX ())
		meditMaterials[i].ShowVertexColorParam = off --Or Textures Glitch sometimes
		bTextures = false
		if _TX00 != undefined then 
		(
			_TX00 = (substituteString _TX00 "\\\\" "\\")
			meditmaterials[i].diffuseMap = _TX00
			-- showing textures may cause directx errors
			meditMaterials[i].DiffuseEnableParam = on
			--meditMaterials[i].ShowTextureParam = on
			bTextures = true
		)
		if _TX01 != undefined then 
		(
			_TX01 = (substituteString _TX01 "\\\\" "\\")
			meditmaterials[i].normalMap = _TX01
			meditMaterials[i].NormalEnableParam = on
			bTextures = true
		)
		if _TX02 != undefined then 
		(
			_TX02 = (substituteString _TX02 "\\\\" "\\")
			meditmaterials[i].environmentMapMask = _TX02
			meditMaterials[i].SmoothSpecEnableParam = on
			bTextures = true
		)
		if _TX03 != undefined then 
		(
			_TX03 = (substituteString _TX03 "\\\\" "\\")
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
			meditmaterials[i].environmentMap = _TX05
			meditMaterials[i].EnvmapEnableParam = on
			bTextures = true
		)
		makeDir (getFilenamePath _MatName) all:true
		--print _MatName
		_MatName = (substituteString _MatName "\\\\" "\\")
		--meditmaterials[i].BGSMatPathParam = _MatName
		--meditmaterials[i].SaveAsFileName = _MatName
		--print _MatName
		if bTextures == false then setmeditmaterial i (BSBlinn())
	)
	
	fn GetTexPath s1 _path s2 fileRoot =
	(
		_path = substituteString _path (fileRoot + "textures\\") ""
		_path = substituteString _path "\\" "\\\\"
		_path = s1 + _path + s2
		_path
	)

	fn CreateMaterialBSBlinn i _MatName fileRoot _exportloc _TX00 _TX01 _TX02 _TX03 _TX04 _TX05 matfile obj =
	(
		-- TX04 (parallax) dont know where
		-- BSBlinn seems a better option but materials will more complicated unless material saving functions can be added to BSBlinn
		setmeditmaterial i (BSBlinn())
		--meditmaterials[i][#Standard].maps = obj.material.maps
		
		if obj.material != undefined then
		(
			-- ambient map	
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
			if obj.material.maps[7] != undefined then 
			(
				meditmaterials[i][#Standard].maps[7] = obj.material.maps[7]
				meditmaterials[i][#Standard].opacityMapEnable = on
				meditmaterials[i][#Standard].opacityMapAmount = obj.material.opacityMapAmount
				matfile[31] = "   \"bSmoothSpecEnable\" : true,"
				matfile[72] = GetTexPath "   \"sSmoothSpecTexture\" : \"" meditmaterials[i][#Standard].maps[7].filename "\"," fileRoot
			)
			
			-- filtermap
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
			
			-- reflection map
			if ((obj.material.maps[10] != undefined) or (_TX02 != undefined) or (_TX05 != undefined)) then 
			(
				if ((_TX02 == undefined) and (_TX05 == undefined)) then
				(
					meditmaterials[i][#Standard].reflectionMapAmount = obj.material.reflectionMapAmount
					meditmaterials[i][#Standard].maps[10] = obj.material.maps[10]
				)
				else
				(
					-- Need to take care of _TX02
					if _TX05 != undefined then
						meditmaterials[i][#Standard].reflectionMap = Bitmaptexture fileName:(fileRoot + "textures\\" + _TX05)
				)
				
				if meditmaterials[i][#Standard].maps[10] != undefined then
				(
					meditmaterials[i][#Standard].reflectionMapEnable = on
					matfile[11] = "   \"bEnvironmentMapping\" : true,"
					if hasProperty meditmaterials[i][#Standard].maps[10] "map" == true then 
						matfile[67] = GetTexPath "   \"sEnvmapTexture\" : \"" meditmaterials[i][#Standard].maps[10].map.filename "\"," fileRoot
					else if hasProperty meditmaterials[i][#Standard].maps[10] "mask" == true then
					(
						meditmaterials[i][#Standard].opacityMapEnable = on
						matfile[31] = "   \"bSmoothSpecEnable\" : true,"
						matfile[72] = GetTexPath "   \"sSmoothSpecTexture\" : \"" meditmaterials[i][#Standard].maps[10].mask.filename "\"," fileRoot
					)
					else 
						matfile[67] = GetTexPath "   \"sEnvmapTexture\" : \"" meditmaterials[i][#Standard].maps[10].filename "\"," fileRoot
				)
			)
			
			-- refraction map
			if obj.material.maps[11] != undefined then 
			(
				meditmaterials[i][#Standard].maps[11] = obj.material.maps[11]
				meditmaterials[i][#Standard].refractionMapEnable = on
				meditmaterials[i][#Standard].refractionMapAmount = obj.material.refractionMapAmount
				matfile[11] = "   \"bEnvironmentMapping\" : true,"
				matfile[67] = GetTexPath "   \"sEnvmapTexture\" : \"" meditmaterials[i][#Standard].maps[11].filename "\"," fileRoot
			)
			
			-- displacement map
			if obj.material.maps[12] != undefined then 
			(
				meditmaterials[i][#Standard].maps[12] = obj.material.maps[12]
				meditmaterials[i][#Standard].displacementMapEnable = on
				meditmaterials[i][#Standard].displacementMapAmount = obj.material.displacementMapAmount
				matfile[38] = "   \"bWrinklesEnable\" : true,"
				matfile[73] = GetTexPath "   \"sWrinklesTexture\" : \"" meditmaterials[i][#Standard].maps[12].filename "\"," fileRoot
			)
		)
		
		makeDir (getFilenamePath _MatName) all:true
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
			_MatName = (substituteString _MatName "\\\\" "\\")
			_MatName = (substituteString _MatName _exportloc "")
			meditmaterials[i].TargetMaterialFile = _MatName
		)
	)
	
	xEditLoc = "C:\\Users\Terry\OneDrive\Bethesda\\xEdit\\"
	fileRoot = "D:\\Games\Fallout New Vegas\FNVExtracted\Data\\"
	_exportloc = "D:\\Games\\Fallout New Vegas\\FNVFo4 Converted\\Data\\"
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
	
	slMatTemplate = (dotnetClass "System.IO.File").ReadAllLines (fileRoot + "templateEmpty.BGSM")
	for s in slMatTemplate do print s
	
	MatCount = 0
		
	files = getFilesRecursive "D:\\Games\Fallout New Vegas\FNVExtracted\Data\\Meshes" "*.nif"
	--files = #("D:\\Games\Fallout New Vegas\FNVExtracted\Data\meshes\Weapons\2HandAutomatic\AssaultRifle.NIF")
	--files = #("D:\Games\Fallout New Vegas\FNVExtracted\Data\Meshes\effects\haroldheartroots.nif")
	--files = #("D:\\Games\Fallout New Vegas\FNVExtracted\Data\meshes\architecture\strip\gamorrahyard.nif")
	--files = #("D:\Games\Fallout New Vegas\FNVExtracted\Data\Meshes\scol\scolgsschool.nif")
	--files = getFiles "D:\\Games\Fallout New Vegas\FNVExtracted\Data\\Meshes\\*.nif"
	print files.count
	FileCount = 0
	startloc = "D:\\Games\\Fallout New Vegas\\FNVExtracted\\Data\\Meshes\\scol\\scolgsschool_lod.nif"
	startpoint = true
	
	gc() --Garbage Collection.
	freescenebitmaps() --Cleans up in texture memory.
	clearUndoBuffer() --Removes your Undo's
	macros.run "Medit Tools" "clear_medit_slots"
	macros.run "Medit Tools" "condense_medit_slots"
	
	for f in files do with undo off
	(
		--print (substituteString f "\\" "\\\\")
		if f == startloc then startpoint = true
		if startpoint == false then continue
		if f == "D:\\Games\\Fallout New Vegas\\FNVExtracted\\Data\\Meshes\\nvdlc04\\\\effects\\nvdlc04_wastelandnukeexp.nif" then continue
		if f == "D:\\Games\\Fallout New Vegas\\FNVExtracted\\Data\\Meshes\\pipboy3000\\pipboyarm.nif" then continue
		
		print (substituteString f "\\" "\\\\")
		--Turn off import vertex colors in nif import options
		--delete objects
		resetMaxFile #noPrompt
		disableSceneRedraw()
		gc() --Garbage Collection.
		freescenebitmaps() --Cleans up in texture memory.
		clearUndoBuffer() --Removes your Undo's
		macros.run "Medit Tools" "clear_medit_slots"
		macros.run "Medit Tools" "condense_medit_slots"
		
		
		--max file import --Import Prompt
		file = f
		file_name = getFilenameFile file
		gamefilepath = substituteString file (fileRoot + "meshes\\") ""
		
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
		--undo off
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
				--print index
				--print indexskiplist[(index + 1)]
				index = indexskiplist[(index + 1)] -- Object Type
				--print index
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
		select (for o in objects where not classOf o == BoneGeometry collect o)
		for j = 1 to selection.count do ConvertToPoly selection[j]
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
		select (for o in objects where ((o.modifiers[#Shape] == undefined) and (not classOf o == BoneGeometry)) collect o)
		
		
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
									CreateMaterial 2 _MatName _TX00 _TX01 _TX02 _TX03 _TX04 _TX05
									--CreateMaterialBSBlinn 2 _MatName fileRoot _exportloc _TX00 _TX01 _TX02 _TX03 _TX04 _TX05 slMatTemplate selection[i]
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
						if selection[i].material.maps[9] != undefined then _TexNormal = selection[i].material.maps[9].normal_map.filename --Normal
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
					CreateMaterial 1 _MatName _TexDiffuse _TexNormal _TexSpecMask _TexGlow undefined _TexEnvironment
					--CreateMaterialBSBlinn 1 _MatName fileRoot _exportloc undefined undefined undefined undefined undefined undefined slMatTemplate selection[i]
					selection[i].material = meditmaterials[1]
					MatCount += 1
					print ((MatCount as string) + " Materials Created")
					--return messageBox(_TexDiffuse)
					--return messageBox(selection[i].material.diffuseMap)
					--return messageBox(selection[i].name)
				)
			)
		)		
		
		select (for o in objects where ((o.modifiers[#Shape] == undefined) and (not classOf o == BoneGeometry)) collect o)
		--if root != "undefined" then deselect root
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
		)
		--root.parent = GetNodeByName "NVGSSchoolHouse002"
		--root.parent = objects[1]
		
		--select objects[1]
		--print $.name
		_exportfile = file
		_exportfile = replace _exportfile (fileRoot.count + 1) 6 "Meshes\\new_vegas"
		_exportfile = substituteString _exportfile fileRoot _exportloc
		makeDir (getFilenamePath _exportfile) all:true
		print _exportfile
		index = undefined
		index2 = undefined
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
		--exit
		--exportFile _exportfile #noPrompt selectedOnly: true
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
		if keyboard.escPressed do 
		(
			ShowTextures()
			exit
		)
		FileCount += 1
		print (FileCount as string)
		if FileCount == 500 then exit
		
	)
	enableSceneRedraw()
	ShowTextures()
)