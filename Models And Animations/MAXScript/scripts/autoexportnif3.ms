
(
	resetMaxFile #noPrompt
	global selection1 = 1
	global selection2 = 1
	file = "D:\\Games\Fallout New Vegas\FNVExtracted\Data\meshes\architecture\strip\gamorrahyard.nif"
	file_name = getFilenameFile file
	importFile file #noPrompt
	if (getnodebyname "collision") != undefined then delete (getnodebyname "collision")
	delete (for o in objects where classOf o.modifiers[1] == bhkRigidBody collect o)
	--Module assigntexture4
	(
		convertto (for o in objects where not classOf o == BoneGeometry collect o) PolyMeshObject
		select (for o in objects where not classOf o == BoneGeometry collect o)
		if selection.count>0 do
		(
			MatBank=for i in 1 to selection.count where selection[i].material!=undefined  collect selection[i].material
			mySlot=MatBank.count
			if mySlot>24 do mySlot=24
			for i=1 to mySlot do 
			(
				if MatBank[i] != undefined then
				(
					setmeditmaterial i (BSLightingFX ())
					if MatBank[i].maps[1] != undefined then 
					(
						meditmaterials[i].diffuseMap = MatBank[i].maps[1].filename
						meditMaterials[i].DiffuseEnableParam = on
						meditMaterials[i].ShowTextureParam = on
					)
					if MatBank[i].maps[6] != undefined then 
					(
						meditmaterials[i].normalMap = MatBank[i].maps[6].normal_map.filename
						meditMaterials[i].NormalEnableParam = on
					)
					if MatBank[i].maps[13] != undefined then 
					(
						meditmaterials[i].environmentMap = MatBank[i].maps[13].filename
						meditMaterials[i].EnvmapEnableParam = on
					)
					selection[i].material = meditmaterials[i]
				)
			)
		)
	)
	
	/*
	(
		if (getnodebyname "collision") != undefined then getnodebyname "collision"
		(
			if selection[1].modifiers[#bhkRigidBodyModifier].material == -1 then index2 = 1 -- Generic
			if selection[1].modifiers[#bhkRigidBodyModifier].material == 0 then index2 = 57 -- Stone
			if selection[1].modifiers[#bhkRigidBodyModifier].material == 1 then index2 = 25 -- Cloth
			if selection[1].modifiers[#bhkRigidBodyModifier].material == 2 then index2 = 29 -- Dirt
			if selection[1].modifiers[#bhkRigidBodyModifier].material == 3 then index2 = 31 -- Glass
			if selection[1].modifiers[#bhkRigidBodyModifier].material == 4 then index2 = 33 -- Grass
			if selection[1].modifiers[#bhkRigidBodyModifier].material == 5 then index2 = 39 -- Metal
			if selection[1].modifiers[#bhkRigidBodyModifier].material == 6 then index2 = 46 -- Organic
			if selection[1].modifiers[#bhkRigidBodyModifier].material == 7 then index2 = 52 -- Skin
			if selection[1].modifiers[#bhkRigidBodyModifier].material == 8 then index2 = 66 -- Water
			if selection[1].modifiers[#bhkRigidBodyModifier].material == 9 then index2 = 78 -- Wood
			if selection[1].modifiers[#bhkRigidBodyModifier].material == 10 then index2 = 64 -- Heavy Stone
			if selection[1].modifiers[#bhkRigidBodyModifier].material == 11 then index2 = 41 -- Heavy Metal
			if selection[1].modifiers[#bhkRigidBodyModifier].material == 12 then index2 = 81 -- Heavy Wood
			if selection[1].modifiers[#bhkRigidBodyModifier].material == 13 then index2 = 24 -- Chain
			if selection[1].modifiers[#bhkRigidBodyModifier].material == 14 then index2 = 55 -- Snow
			if selection[1].modifiers[#bhkRigidBodyModifier].material == 15 then index2 = 65 -- Stone Stairs
			if selection[1].modifiers[#bhkRigidBodyModifier].material == 16 then index2 = 32 -- Cloth Stairs
			if selection[1].modifiers[#bhkRigidBodyModifier].material == 17 then index2 = 30 -- Dirt Stairs
			if selection[1].modifiers[#bhkRigidBodyModifier].material == 18 then index2 = 32 -- Glass Stairs
			if selection[1].modifiers[#bhkRigidBodyModifier].material == 19 then index2 = 34 -- Grass Stairs
			if selection[1].modifiers[#bhkRigidBodyModifier].material == 20 then index2 = 32 -- Metal Stairs
			if selection[1].modifiers[#bhkRigidBodyModifier].material == 21 then index2 = 32 -- Organic Stairs
			if selection[1].modifiers[#bhkRigidBodyModifier].material == 22 then index2 = 32 -- Skin Stairs
			if selection[1].modifiers[#bhkRigidBodyModifier].material == 23 then index2 = 32 -- Water Stairs
			if selection[1].modifiers[#bhkRigidBodyModifier].material == 24 then index2 = 83 -- Wood Stairs
			if selection[1].modifiers[#bhkRigidBodyModifier].material == 25 then index2 = 65 -- Heavy Stone Stairs
			if selection[1].modifiers[#bhkRigidBodyModifier].material == 26 then index2 = 32 -- Heavy Metal Stairs
			if selection[1].modifiers[#bhkRigidBodyModifier].material == 27 then index2 = 83 -- Heavy Wooden Stairs
			if selection[1].modifiers[#bhkRigidBodyModifier].material == 28 then index2 = 32 -- Chain Stairs
			if selection[1].modifiers[#bhkRigidBodyModifier].material == 29 then index2 = 56 -- Snow Stairs
			if selection[1].modifiers[#bhkRigidBodyModifier].material == 30 then index2 = 39 -- Elevator
			if selection[1].modifiers[#bhkRigidBodyModifier].material == 31 then index2 = 46 -- Rubber
			/* --Skyrim
			if selection[1].modifiers[#bhkRigidBodyModifier].material == 0 then index2 = 57 -- Barrel
			if selection[1].modifiers[#bhkRigidBodyModifier].material == 0 then index2 = 57 -- Bottle
			if selection[1].modifiers[#bhkRigidBodyModifier].material == 0 then index2 = 57 -- Broken Stone
			if selection[1].modifiers[#bhkRigidBodyModifier].material == 0 then index2 = 57 -- Dragon
			if selection[1].modifiers[#bhkRigidBodyModifier].material == 0 then index2 = 57 -- Gravel
			if selection[1].modifiers[#bhkRigidBodyModifier].material == 0 then index2 = 57 -- Ice
			if selection[1].modifiers[#bhkRigidBodyModifier].material == 0 then index2 = 57 -- Light Wood
			if selection[1].modifiers[#bhkRigidBodyModifier].material == 0 then index2 = 57 -- Armor Heavy
			if selection[1].modifiers[#bhkRigidBodyModifier].material == 0 then index2 = 57 -- Armor Light
			if selection[1].modifiers[#bhkRigidBodyModifier].material == 0 then index2 = 57 -- Arrow
			if selection[1].modifiers[#bhkRigidBodyModifier].material == 0 then index2 = 57 -- Axe 1Hand
			if selection[1].modifiers[#bhkRigidBodyModifier].material == 0 then index2 = 57 -- Basket
			if selection[1].modifiers[#bhkRigidBodyModifier].material == 0 then index2 = 57 -- Blade 1 Hand
			if selection[1].modifiers[#bhkRigidBodyModifier].material == 0 then index2 = 57 -- Blade 1 Hand Small
			if selection[1].modifiers[#bhkRigidBodyModifier].material == 0 then index2 = 57 -- Blade 2 Hand
			if selection[1].modifiers[#bhkRigidBodyModifier].material == 0 then index2 = 57 -- Blunt 2 Hand
			if selection[1].modifiers[#bhkRigidBodyModifier].material == 0 then index2 = 57 -- Bone
			if selection[1].modifiers[#bhkRigidBodyModifier].material == 0 then index2 = 57 -- Book
			if selection[1].modifiers[#bhkRigidBodyModifier].material == 0 then index2 = 57 -- Bottle Small
			if selection[1].modifiers[#bhkRigidBodyModifier].material == 0 then index2 = 57 -- Boulder Large
			if selection[1].modifiers[#bhkRigidBodyModifier].material == 0 then index2 = 57 -- Boulder Medium
			if selection[1].modifiers[#bhkRigidBodyModifier].material == 0 then index2 = 57 -- Boulder Small
			if selection[1].modifiers[#bhkRigidBodyModifier].material == 0 then index2 = 57 -- Bows Staves
			if selection[1].modifiers[#bhkRigidBodyModifier].material == 0 then index2 = 57 -- Carpet
			if selection[1].modifiers[#bhkRigidBodyModifier].material == 0 then index2 = 57 -- Ceramic Medium
			if selection[1].modifiers[#bhkRigidBodyModifier].material == 0 then index2 = 57 -- Chain Metal
			if selection[1].modifiers[#bhkRigidBodyModifier].material == 0 then index2 = 57 -- Coin
			if selection[1].modifiers[#bhkRigidBodyModifier].material == 0 then index2 = 57 -- Shield Heavy
			if selection[1].modifiers[#bhkRigidBodyModifier].material == 0 then index2 = 57 -- Shield Light
			if selection[1].modifiers[#bhkRigidBodyModifier].material == 0 then index2 = 57 -- Skin Large
			if selection[1].modifiers[#bhkRigidBodyModifier].material == 0 then index2 = 57 -- Skin Small
			if selection[1].modifiers[#bhkRigidBodyModifier].material == 0 then index2 = 57 -- Mud
			if selection[1].modifiers[#bhkRigidBodyModifier].material == 0 then index2 = 57 -- Sand
			
		)
	)
	*/
	
	--Custom Collision Mesh
	(
		--actionMan.executeAction 0 "40010"  -- File: Import File
		if (getnodebyname "collision") != undefined then delete (getnodebyname "collision")
		select (for o in objects where not classOf o == BoneGeometry collect o)
		namesArray = for s in selection collect s.name
		maxOps.cloneNodes (selection as array) cloneType:#copy newNodes:&nnl #nodialog
		--Loop through the array of object it returns
		thePrefix = "c_"

		--ProOmptimizer
		(
			--print ("nnl count is " + nnl.count)
			select (for o in nnl where not classOf o == BoneGeometry collect o)
			selection.material = (BSLightingFX ())
			macros.run "Modifiers" "ProOptimizerMod"
			selection[1].modifiers[#ProOptimizer].MergePoints = on
			selection[1].modifiers[#ProOptimizer].MergePointsThreshold = 10
			selection[1].modifiers[#ProOptimizer].MergeFaces = on
			selection[1].modifiers[#ProOptimizer].MergeFacesAngle = 10
			selection[1].modifiers[#ProOptimizer].Calculate = off
			selection[1].modifiers[#ProOptimizer].Calculate = on
			selection[1].modifiers[#ProOptimizer].VertexPercent = 100
			select (for o in nnl where not classOf o == BoneGeometry collect o)
			for i = 1 to selection.count do
			(
				--deleteModifier selection[i] 1
				maxOps.CollapseNodeTo selection[i] 1 off
			)
		)
		for i = 1 to nnl.count do
		(
			--rename the objects to a unique name
			nnl[i].name = thePrefix + namesArray[i]
			obj = getnodebyname nnl[i].name
			if obj != undefined then select obj
			obj2 = getnodebyname namesArray[i]
			if obj2 != undefined then selectmore obj2
			obj.parent = obj2
			macros.run "Havok Physics" "mcrPhysics_createRigidBodyWithProxy"
			--UIAccessor.PressDefaultButton()
			selection[1].modifiers[#Rigid_Body].mass = 60
			if obj != undefined then select obj
			selection[1].modifiers[#Shape].shapeType = 5
		)
	)
	
	-- CollisionGroup
	rollout convertnif "Convert" width:162 height:136
	(
		button btn9 "Go" pos:[62,101] width:37 height:26
		dropDownList ddl1 "DropDownList" pos:[16,13] width:130 height:40 items:#("Static", "anim Static", "Clutter", "Prop") selection:selection1
		on btn9 pressed do
		(
			if ddl1.selection == 1 then global index = 1
			if ddl1.selection == 2 then global index = 2
			if ddl1.selection == 3 then global index = 4
			if ddl1.selection == 4 then global index = 10
			global selection1 = ddl1.selection
			DestroyDialog convertnif
			for i = 1 to namesArray.count do
			(
				select (getnodebyname namesArray[i])
				selectmore (getnodebyname nnl[i].name)
				max hide inv
				rollout defaultmaterial "Default Material" width:162 height:136
				(
					button btn9 "Go" pos:[62,101] width:37 height:26
					dropDownList ddl2 "DropDownList" pos:[16,13] width:130 height:40 
					items:#("Generic", "Basket", "Bone", "Book","Bottle", "BottleSmall", "Brick", "Carpet","CeramicMedium", "Concrete","Dirt","Glass","Grass","Gravel","Insect","Meat","Metal","MetalBarrel",
						"MetalHeavy","MetalHollow","MetalLight","MetalSolid","Mud","Organic","Paper","Plastic","PotsPans","Sand","Skeleton","Skin","Stone","StoneBoulderMedium","Wood","WoodBarrel") selection:selection2
					on btn9 pressed do
					(
						if ddl2.selection == 1 then index2 = 1 -- Generic
						if ddl2.selection == 2 then index2 = 16 -- Basket
						if ddl2.selection == 3 then index2 = 17 -- Bone
						if ddl2.selection == 4 then index2 = 18 -- Book
						if ddl2.selection == 5 then index2 = 19 -- Bottle
						if ddl2.selection == 6 then index2 = 20 -- BottleSmall
						if ddl2.selection == 7 then index2 = 21 -- Brick
						if ddl2.selection == 8 then index2 = 22 -- Carpet
						if ddl2.selection == 9 then index2 = 23 -- CeramicMedium
						if ddl2.selection == 10 then index2 = 28 -- Concrete
						if ddl2.selection == 11 then index2 = 29 -- Dirt
						if ddl2.selection == 12 then index2 = 31 -- Glass
						if ddl2.selection == 13 then index2 = 33 -- Grass
						if ddl2.selection == 14 then index2 = 35 -- Gravel
						if ddl2.selection == 15 then index2 = 37 -- Insect
						if ddl2.selection == 16 then index2 = 38 -- Meat
						if ddl2.selection == 17 then index2 = 39 -- Metal
						if ddl2.selection == 18 then index2 = 40 -- MetalBarrel
						if ddl2.selection == 19 then index2 = 41 -- MetalHeavy
						if ddl2.selection == 20 then index2 = 42 -- MetalHollow
						if ddl2.selection == 21 then index2 = 43 -- MetalLight
						if ddl2.selection == 22 then index2 = 44 -- MetalSolid
						if ddl2.selection == 23 then index2 = 45 -- Mud
						if ddl2.selection == 24 then index2 = 46 -- Organic
						if ddl2.selection == 25 then index2 = 47 -- Paper
						if ddl2.selection == 26 then index2 = 48 -- Plastic
						if ddl2.selection == 27 then index2 = 49 -- PotsPans
						if ddl2.selection == 28 then index2 = 50 -- Sand
						if ddl2.selection == 29 then index2 = 51 -- Skeleton
						if ddl2.selection == 30 then index2 = 52 -- Skin
						if ddl2.selection == 31 then index2 = 57 -- Stone
						if ddl2.selection == 32 then index2 = 60 -- StoneBoulderMedium
						if ddl2.selection == 33 then index2 = 78 -- Wood
						if ddl2.selection == 34 then index2 = 79 --WoodBarrel
						if ddl2.selection == 34 then index2 = 24 -- Chain
						if ddl2.selection == 34 then index2 = 25 -- Cloth
						if ddl2.selection == 34 then index2 = 81 -- WoodHeavy
						if ddl2.selection == 34 then index2 = 64 -- StoneHeavy
						if ddl2.selection == 34 then index2 = 55 -- Snow
						if ddl2.selection == 34 then index2 = 30 -- DirtStairs
						if ddl2.selection == 34 then index2 = 32 -- GlassStairs
						if ddl2.selection == 34 then index2 = 34 -- GrassStairs
						if ddl2.selection == 34 then index2 = 56 -- SnowStairs
						if ddl2.selection == 34 then index2 = 65 -- StoneStairs
						if ddl2.selection == 34 then index2 = 83 -- WoodStairs
						if ddl2.selection == 34 then index2 = 66 -- Water
						if ddl2.selection == 34 then index2 = 79 --
						if ddl2.selection == 34 then index2 = 79 --
						if ddl2.selection == 34 then index2 = 79 --
						if ddl2.selection == 34 then index2 = 79 --
						if ddl2.selection == 34 then index2 = 79 --
						if ddl2.selection == 34 then index2 = 79 --
						if ddl2.selection == 34 then index2 = 79 --
						if ddl2.selection == 34 then index2 = 79 --
						if ddl2.selection == 34 then index2 = 79 --
						if ddl2.selection == 34 then index2 = 79 --
						global selection2 = ddl2.selection
						max unhide all
						max utility mode 
						UtilityPanel.OpenUtility collsiongroup -- CollisionGroup Must be open
						DestroyDialog defaultmaterial
						local hwndVC = (windows.getChildHWND #max "CollisionGroup")[2]
						child_array = UIAccessor.GetChildWindows hwndVC
						for j = 1 to child_array.count do
						(
							child_name = UIAccessor.GetWindowText child_array[j]
							if child_name == "NullMaterial" then	
							(
								hwnd = child_array[j]
								local WM_COMMAND = 0x111 -- Windows Message: Command
								local CB_SETCURSEL = 0x014E -- ComboBox message: Set current selection
								local CBN_SELCHANGE = 1
								my_id = UIAccessor.getWindowResourceID hwnd
								windows.sendMessage hwnd CB_SETCURSEL index2 0 -- set selection
								windows.sendMessage hwndVC WM_COMMAND ((bit.shift CBN_SELCHANGE 16) + my_id) hwnd -- message parent
							)
							if child_name == "Unidentified" then	
							(
								hwnd = child_array[j]
								local WM_COMMAND = 0x111 -- Windows Message: Command
								local CB_SETCURSEL = 0x014E -- ComboBox message: Set current selection
								local CBN_SELCHANGE = 1
								my_id = UIAccessor.getWindowResourceID hwnd
								windows.sendMessage hwnd CB_SETCURSEL index 0 -- set selection
								windows.sendMessage hwndVC WM_COMMAND ((bit.shift CBN_SELCHANGE 16) + my_id) hwnd -- message parent
							)
						)
						UIAccessor.PressButton (windows.getChildHWND hwndVC "Apply To Selected")[1]
					)
				)
				createdialog defaultmaterial modal:true
			)
		)
	)
	createdialog convertnif modal:true
	print "done"
	--export
	/*
	(
		dummyObj = Dummy()
		for i = 1 to namesArray.count do
		(
			(getnodebyname namesArray[i]).parent = dummyObj
		)
		dummyObj.name = file_name
		select (getnodebyname dummyObj.name)
		print file_export
		exportFile (file_name + ".nif") #noPrompt selectedOnly: true
	)
	*/
)