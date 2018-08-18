
if selection.count>0 do
(
	MatBank=for i in 1 to selection.count where selection[i].material!=undefined  collect selection[i].material
	for i = 1 to selection.count do
	--if MatBank[i].name != "collision" then 
	if MatBank[i] != undefined then 
	(
		print MatBank[i].diffuseMap.filename
		texturefilepath = MatBank[i].diffuseMap.filename
		print texturefilepath
		if doesFileExist (texturefilepath) == true then 
		(
			meditmaterials[1].diffuseMap = texturefilepath
		)
		texturefilepath2 = (getFilenamePath texturefilepath) + (getFilenameFile texturefilepath) + "_n.dds"
		if doesFileExist texturefilepath2 == true then 
		(
			meditmaterials[1].normalMap = texturefilepath2
		)
		texturefilepath3 = (getFilenamePath texturefilepath) + (getFilenameFile texturefilepath) + "_m.dds"
		if doesFileExist texturefilepath3 == true then 
		(
			meditmaterials[1].environmentMap = texturefilepath3
		)
		--newBitmap = openBitMap texturefilepath
		--print "load okay " + newBitmap
	)
)
-- diffuse meditMaterials[2].maps[1]
-- bump meditMaterials[2].maps[6]
-- environment meditMaterials[2].maps[13]