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
		
	fileRoot = "D:\\Games\\Fallout New Vegas\\FNVFo4 Converted\\Data\\"
	files = getFilesRecursive "D:\\Games\\Fallout New Vegas\\FNVFo4 Converted\\Data\\MaxFiles" "*.max"
	print(files.count as string)
	startloc = "D:\\Games\\Fallout New Vegas\\FNVFo4 Converted\\Data\\MaxFiles\\nvdlc01\\\\dungeons\\\\casino\\\\suites\\nvdlc01_suiteshallsm1way01half.max"
	counter = 0
	startpoint = false
	for f in files while(not keyboard.escPressed) do with undo off
	(
		s=timeStamp() 
		if f == startloc then startpoint = true
		if startpoint == false then continue
		print (substituteString f "\\" "\\\\")
		loadMaxFile f
		_exportfile = f
		--_exportfile = replace _exportfile (fileRoot.count + 1) 6 "Meshes\\new_vegas"
		_exportfile = replace _exportfile (fileRoot.count + 1) 8 "Meshes\\new_vegas"
		_exportfile = replace _exportfile (_exportfile.count - 2) 3 "nif"
		--_exportfile = substituteString _exportfile fileRoot _exportloc
		select objects[1]
		makeDir (getFilenamePath _exportfile) all:true
		exportFile _exportfile #noPrompt selectedOnly: true using: nif_export_class
		--exportFile _exportfile #noPrompt selectedOnly: true
		counter += 1
		e=timeStamp()
		windows.processPostedMessages()
		format "%s\n" ((e-s)/1000.0) 
		print(counter as string)
		if counter == 483 then exit
	)
	
)