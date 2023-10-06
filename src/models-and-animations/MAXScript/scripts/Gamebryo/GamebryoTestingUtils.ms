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
utility GamebryoTestUtils "Gamebryo Testing Utilities"  -- define the utility name and description string 
( 
	label 		lblName			 "Gamebryo Max Testing Utils"		pos:[20, 17]
	label 		lblVersion		 "Version: 1.0"		pos:[20, 41]
	group "Root File Path"
	(
		edittext    edtFilename		 text:"c:\\ndl\\gamebryo2.1\\test\\maximmerse\\" width:122 height:20
		button      btnSelectPath    "Select Path"		width:122	height:20
		button      btnCollect       "Collect Files"  	width:122 	height:20
	)
	checkbox	ckViewWithDefault "View with default viewer" checked:true
	checkbox	ckViewWithSceneViewer "View with asset viewer" checked:false
	checkbox    ckExport		  "Export file" checked:false
	button 		btnNextFile 	 "Next File" 	 	width:122 	height:20
	
	label edtThisFile "unknown" align:#right
	label edtNextFile "unknown" align:#right

	button      btnSkipNext      "Skip Next"  width:122 height:20
	button		btnSkipNextDir	 "Skip Next Dir" width:122 height:20

		
	local theArray = #()
	local myIndex = 1
	
	
	function recursiveAddFiles sourceDir array= 
	(
	  theFiles = getFiles (sourceDir + "*.max")
	  join array theFiles
	  for d in getDirectories (sourceDir + "*") do
	    array = recursiveAddFiles d array
	  return array
	)

	on btnNextFile pressed do
	(
		if myIndex < theArray.count do
		(
			file = theArray[myIndex]
			bLoaded = false
			vers = maxVersion()
			if (vers[1] < 5000) do
			(
				bLoaded = loadMaxFile file
			)
			if (vers[1] >= 5000) do
			(
				bLoaded = loadMaxFile file useFileUnits:true
			)
			
			if (bLoaded == true) do 
			(
				edtThisFile.text = file
				if myIndex + 1 < theArray.count do
				(
					edtNextFile.text = theArray[myIndex+1]
				)
				
				myIndex = myIndex + 1
				if ckViewWithDefault.checked == true do
				(
					DoGamebryoView(-1)
				)
				
				if ckViewWithSceneViewer.checked == true do
				(
					DoGamebryoView(4)
				)
				
				if ckExport.checked == true do
				(
					strFilename = GetExportValue "NiFilename"
					GamebryoExport strFilename
				)
			)
		)
	)
	
	on btnCollect pressed do
	(
		theArray = #()
		recursiveAddFiles  edtFilename.text theArray
		myIndex = 1
	)
	
	on btnSelectPath pressed do
	(
		newPath = getSavePath caption:"Select the root directory you wish to load from"
		if newPath != undefined do
		(
			edtFilename.text = newPath
		)
	)
	
	on 	btnSkipNext pressed do
	(
		if myIndex < theArray.count do
		(
			myIndex = myIndex + 1
			edtNextFile.text = theArray[myIndex]
		)
	)
	
	on btnSkipNextDir pressed do
	(
	    curPath = getFilenamePath edtNextFile.text 
		print curPath
		while ((myIndex < theArray.count) and (curPath == getFilenamePath theArray[myIndex])) do
		(
			print "skipping..."
		    print theArray[myIndex]
			myIndex = myIndex + 1
			edtNextFile.text = theArray[myIndex]
		)
	)
)