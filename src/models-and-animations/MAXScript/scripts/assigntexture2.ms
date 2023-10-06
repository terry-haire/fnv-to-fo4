--meditMaterials[1].DiffuseEnableParam = on
--meditMaterials[1].ShowTextureParam = on

--meditMaterials[1].diffuseMap = BitmapTexture filename:"D:\\Games\Fallout New Vegas\FNVExtracted\BaseGameAndDLC\textures\architecture\strip\gamorrah01.dds"
--showProperties(meditMaterials[1])

--	newBitmap = openBitMap @"D:\Games\Fallout New Vegas\FNVExtracted\BaseGameAndDLC\textures\architecture\strip\gamorrah01.dds"
	--print newBitmap
	
for m in sceneMaterials do 
(
	--print "okay"
	--print m.name
	if m.name != "collision" then 
	(
		print m.diffuseMap.filename
		texturefilepath = m.diffuseMap.filename
		if doesFileExist (texturefilepath) == true then meditmaterials[1].diffuseMap = texturefilepath
		texturefilepath2 = (getFilenamePath texturefilepath) + (getFilenameFile texturefilepath) + "_n.dds"
		if doesFileExist texturefilepath2 == true then meditmaterials[1].normalMap = texturefilepath2
		texturefilepath3 = (getFilenamePath texturefilepath) + (getFilenameFile texturefilepath) + "_m.dds"
		if doesFileExist texturefilepath3 == true then meditmaterials[1].environmentMap = texturefilepath3
		newBitmap = openBitmap texturefilepath
		print newBitmap
		print "OKay?"
	)
)
--materialArray = for s in selection collect s.material
--print materialArray.count
--for i = 1 to materialArray.count do print materialArray[i]
--selection.material = meditmaterials[1]