(
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
	
	counter = 0
	files = getFilesRecursive "D:\\Games\Fallout New Vegas\FNVExtracted\Data\\Meshes" "*.nif"
	for f in files while(not keyboard.escPressed) do with undo off
	(
		resetMaxFile #noPrompt
		importFile f #noPrompt
		print f
		for o in objects do o.material = BSLightingFX()
		counter += 1
		print (counter as string)
		if counter == 500 then exit
	)
)