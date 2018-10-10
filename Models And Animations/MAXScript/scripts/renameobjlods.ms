(	
	fn getFilesRecursive =
	(
		d = "E:\\SteamLibrary\\steamapps\\common\\Fallout 4\\Data\\Meshes\\Terrain\\wastelandnv\\objects\\"
		my_files = getFiles d
		for f in my_files do
			print f
		my_files
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
	files = getFilesRecursive "E:\\SteamLibrary\\steamapps\\common\\Fallout 4\\Data\\Meshes\\Terrain\\wastelandnv\\objects\\" "*.BTO"
	for f in files do
		print f
)