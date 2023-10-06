
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
