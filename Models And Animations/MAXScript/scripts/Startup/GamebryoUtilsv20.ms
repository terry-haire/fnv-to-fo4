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

utility GamebryoMaxUtils "Gamebryo Misc Utilities"  -- define the utility name and description string 
( 
	label 		lblName			 "Gamebryo Max Utils"		pos:[40, 17]
	label 		lblVersion		 "   Version: 1.0"		pos:[40, 41]
	button 		RecurseAndExport "Recursive Export" 	pos:[20, 72] 	width:122 	height:20
	
	function recursiveExport sourceDir exportDir bPrompt = 
	(
	  for f in getFiles (sourceDir + "*.max") do 
	  (
	    if loadMaxFile f then
		(
		  if exportDir == undefined then 
			  nifFile = sourceDir + getFilenameFile f + ".nif"
	      else
		  	  nifFile = exportDir + getFilenameFile f + ".nif"
		  if bPrompt then
		      exportFile nifFile
		  else exportFile nifFile #noPrompt
	    )
	  )
	  for d in getDirectories (sourceDir + "*") do
	    recursiveExport d exportDir bPrompt
	)

	on RecurseAndExport pressed do
	(
		sourceRoot = getSavePath caption:"All MAX files in the folder you choose and its subfolders will be exported to NIF."
		if sourceRoot != undefined then 
		(
			exportDir = getSavePath caption:"Select export directory for NIF files, or click Cancel to use the same folder as the MAX file."
		
			message = "Do you wish to see the NIF Export Options dialog for each MAX file?\n" +
							   "If not, the options you selected for the most recent NIF export will be used.\n" + 
							   "Or, if you have not yet exported to NIF during this MAX session, the default options will be used."
			bPrompt = queryBox message beep:no
			if bPrompt then
			   promptYN = "will"
			else
			   promptYN = "will not"
		
			message = "Do you wish to set warnings, errors, and plugin reports\n" +
							"to be written to \"GamebryoOutputLog.xml\" instead of being\n" +
							"presented in modal dialogs?\n\n" + 
							"This will prevent the recursive export from being held up by\n" +
							"a prompt dialog and can be reset in the Gamebryo Utility Panel."
			bSilentExport = queryBox message beep:no
			if bSilentExport then
			(
				SetExport WriteErrorsToFile:TRUE
			)
		
			if exportDir == undefined then
			   exportDirMsg = "the same folder as the MAX file."
			else
		    (
			   if exportDir[exportDir.count] != "\\" then
			      exportDir = exportDir + "\\"
		       exportDirMsg = exportDir
			)
			if sourceRoot[sourceRoot.count] != "\\" then
			   sourceRoot = sourceRoot + "\\"
			   
			message = "You have chosen to export all MAX files in\n" +
				sourceRoot + 
				"\nand its subfolders.  The NIF files will be saved in\n" +

				exportDirMsg +
				"\n\nYou " + promptYN + " be prompted for NIF export options.\n\nDo you wish to continue?"
				
			if queryBox message beep:no then
				recursiveExport sourceRoot exportDir bPrompt
		)
	)
	

    include "Gamebryo/ZBufferHelpers.ms"
    include "Gamebryo/BillboardHelpers.ms"


	
	on GamebryoMaxUtils open do 
	( 
		addRollout ZBufferPanel 
		addRollout BillboardPanel 
	) 

	on GamebryoMaxUtils close do 
	( 
		removeRollout ZBufferPanel 
		removeRollout BillboardPanel 
	) 
	

)