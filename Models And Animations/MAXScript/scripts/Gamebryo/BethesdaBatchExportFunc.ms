-- -------------------------------------------------------------------------
-- ZENIMAX MEDIA PROPRIETARY INFORMATION
-- 
-- This software is developed and/or supplied under the terms of a license
-- or non-disclosure agreement with ZeniMax Media Inc. and may not be copied
-- or disclosed except in accordance with the terms of that agreement.
-- 
--   Copyright (c) 2006 ZeniMax Media Incorporated.
--   All Rights Reserved.
-- 
-- ZeniMax Media Incorporated, Rockville, Maryland 20850
-- http://www.zenimax.com
-- 
-- FILE:    BethesdaBatchExportFunc.ms
-- VERSION: 1.0
-- AUTHOR:  Mike Dulany
-- DATE:    10/17/2006
-- -------------------------------------------------------------------------

-- ---------------------------------------------------------------------------
-- Batch export utility functions
-- ---------------------------------------------------------------------------
-- Summary: Attempts to make directories for the given file path.
-- Returns: None.
fn makeDirRec path =
(
	-- Split path into folders
	folders = filterString path "\\"
	tempPath = ""
	
	-- For each new folder.
	for folder in folders do
	(
		-- Add it to temp path and attempt to make the directory.
		tempPath = tempPath + folder
		makeDir tempPath
		tempPath = tempPath + "\\"
	)
)

-- Summary: Looks for a property set in the file properties comments field.
-- Returns: Value of property or "" if not found.
fn ExtractExportProp name =
(
	numSummaryProps = fileProperties.getNumProperties #summary
	retValue = ""
		
	if ( numSummaryProps != 0 ) do
	(
		for i = 1 to numSummaryProps do 
		(
			-- Loop through properities looking for Comments.
			propName = fileProperties.getPropertyName #summary i
					
			if (propName == "Comments") do
			(
				-- Parse the comments string
				exportPropStr = fileproperties.getPropertyValue #summary i
				exportProps = filterString exportPropStr ";"
				
				-- Iterate over properties defined and extract values we use.		
				for prop in exportProps do
				(
					propSplit = filterString prop "="
					propName = trimLeft propSplit[1]
					propValue = propSplit[2]
					if (propName == name) do retValue = if ( propValue != undefined ) then propValue else ""
				)
			)
		)										
	)
	retValue
)	

-- Summary: Create the filepath for the current export.
-- Returns: Filepath of export.
fn CreateFilePath exportDir node:undefined = 
(
	filePath = ""

	-- If this export is for a multiobject max file.
	if ( node != undefined ) then
	(
		-- First check the nodes user properties for the path.
		filePath = getUserProp node "ExportLoc"
	)
	
	-- If it was a multiobject with no path defined or it was a single object.
	
	-- Try to extract from the file properties.
	if ( filePath == "" or filePath == undefined ) do filePath = ExtractExportProp("ExportLoc")
	
	-- Try to use the export directory.
	if ( filePath == "" or filePath == undefined ) do filePath = exportDir

	-- We need to recursively check folders to make sure their made.
	makeDirRec filePath 
	
	-- Make sure filePath exists.
	makeDir filePath
	
	filePath
)

-- Summary: Given a source directory and a filepath this function creates the filepath of the export.
-- Returns: Export directory name for the directory export.
fn GetExportDir sourceDir exportDir filePath =
(
	retExportDir = ""

	-- This function should only be used in a directory export.
	sourceDirectoryEnd = sourceDir.count + 2
	
	-- Trim the filename from the full filename+path
	fileNameNoPath = filenameFromPath filePath
	fileNameSize = fileNameNoPath.count
	
	-- Size of path without the filename
	size = filePath.count - fileNameSize
	trimFilePath = substring filePath 1 size	

	-- Append source subdirectories to the export directory
	subDirectoryName = substring trimFilePath sourceDirectoryEnd -1
	retExportDir = exportDir + subDirectoryName

	retExportDir
)

-- Summary: Checks the passed export script for the file extension type exported.
-- Returns: File extension related to the export script name passed in.
fn GetExportFileExt exportScript = 
(
	-- Default export should be nif.
	fileExt = ".nif"
	if ( ( matchPattern exportScript pattern:"PE Multiple KF*" ) or  ( matchPattern exportScript pattern:"PE Single KF*" ) ) then fileExt = ".kf"
	if ( matchPattern exportScript pattern:"PE Ragdoll Template" ) then fileExt = ".rdt"
	fileExt
)

-- Summary: Create the filename for the current export.
-- Returns: Filename with correct extension.
fn CreateFileName exportScript sourceFile node:undefined =
(
	fileName = ""
	
	-- If this export is for a multiobject max file.
	if (node != undefined ) then
	(
		-- First check the nodes user properties for the filename.
		fileName = getUserProp node "ExportFileName"
		
		-- Otherwise use the node name.
		if (fileName == "") do fileName = node.name
	)
	else
	(
		-- First check the file properties.
		fileName = ExtractExportProp("ExportFileName")
		
		-- Otherwise use the max file name.
		if (fileName == "") do fileName = getFilenameFile sourceFile
	)
	
	-- Maybe check for file ext already placed.
	
	-- Append correct file extension suffix.
	fileExt = GetExportFileExt (exportScript)
	fileName = fileName + fileExt
	
	fileName	
)

-- Summary: Create subdirectories in the destination directory that are found in the source directory.
-- Returns: None.
fn CreateNewPaths sourceDir exportDir = 
(
	-- Get directories.
	dir_array = GetDirectories (sourceDir + "\*")
	for d in dir_array do
		join dir_array (GetDirectories (d+"\*"))

	-- If we have to create new folders in the destination directory we have to know 
	-- where to start the string for the sub-directories.
	folderStartIndex = sourceDir.count + 2

	-- Make sub-directories in the export directory if they don't exist.				
	for d in dir_array do
	(
		newFolderName = substring d folderStartIndex -1
		newFolderPath = exportDir + newFolderName
		makeDir newFolderPath
	)
)

-- Summary: Find all the .max files in a given directory and it's sub-directories.
-- Returns: Array of files found.
fn GetMaxFilesInDir directory =
(
	maxfiles = #()
				
	-- Get directories.
	dir_array = GetDirectories (directory + "\*")
	for d in dir_array do
		join dir_array (GetDirectories (d+"\*"))

	-- Get a list of max files in sub-directories.
	for f in dir_array do
		join maxfiles (getFiles (f + "\*.max"))
			
	-- Add max files found in the root directory.
	join maxfiles ( getFiles (directory + "\\*.max") )
	
	maxfiles
)

-- Summary: Iterates over the children of the scene root and looks for nodes marked for selected export.
-- Returns: Array of nodes that have the batch export selected user property.
fn GetSelectedNodes =
(
	-- Array of selected nodes.
	selNodes = #()

	-- Find all objects that have the export selected user property set.
	for obj in rootNode.children do 
	( 
		exportSelected = getUserProp obj "ExportSel"
		if ( exportSelected == "Yes" ) do
		(
			append selNodes obj
		)
	)
	
	selNodes
)

-- Summary: Sets the exporter to batch mode.
-- Returns: None.
fn SetFileBatchMode =
(
	-- Sets the keyword property to batch.  This value is checked by the exporter in order to use the correct 
	-- exporting options.
	fileProperties.addProperty #custom "Batch" "Yes"
)

-- Summary: Grabs the export options from the correct location and sets related custom options so that
--          the exporter can use them.
-- Returns: None.
fn SetExportOptions bIsSelected node:undefined =
(
	-- Read the export options in the file properties.
	processScript = ExtractExportProp("ProcessScript")
	exportScript  = ExtractExportProp("ExportScript")
	animDisabled  = ExtractExportProp("AnimDisabled")
	exportWCoord  = ExtractExportProp("ExportWCoord")
	exportCams    = ExtractExportProp("ExportCams")	

	-- If we are looking for options on a specific node.
	if ( bIsSelected == true ) then 
	(
		-- Read the export options in the nodes user defined properties.
		processScriptProp = getUserProp node "ProcessScript"
		exportScriptProp  = getUserProp node "ExportScript"
		animDisabledProp  = getUserProp node "AnimDisabled"
		exportWCoordProp  = getUserProp node "ExportWCoord"
		exportCamsProp    = getUserProp node "ExportCams"
		
		-- Override the file properties if the node defines specific export options.
		if ( ( processScriptProp != undefined ) and ( processScriptProp != "" ) ) do processScript = processScriptProp
		if ( ( exportScriptProp  != undefined ) and ( exportScriptProp  != "" ) ) do exportScript  = exportScriptProp
		if ( ( animDisabledProp  != undefined ) and ( animDisabledProp  != "" ) ) do animDisabled  = animDisabledProp
		if ( ( exportWCoordProp  != undefined ) and ( exportWCoordProp  != "" ) ) do exportWCoord  = exportWCoordProp
		if ( ( exportCamsProp    != undefined ) and ( exportCamsProp    != "" ) ) do exportCams    = exportCamsProp
	)
	
	-- Set process script option.
	if ( ( processScript != undefined ) and ( processScript != "" ) ) do fileProperties.addProperty #custom "PROCESS_SCRIPT_NAME" processScript

	-- Set export script option.
	if ( ( exportScript != undefined ) and ( exportScript != "" ) ) do 
	(
		-- Check for PE scripts and append whitespace to front
		peScript = substring exportScript 1 2
		if ( peScript == "PE" ) do exportScript = " " + exportScript
		
		fileProperties.addProperty #custom "EXPORT_SCRIPT_NAME" exportScript 
	)

	-- Set animation disabled option.
	if ( ( animDisabled != undefined ) and ( animDisabled != "" ) ) do fileProperties.addProperty #custom "AnimDisabled" animDisabled

	-- Set export W coordinates option.
	if ( ( exportWCoord != undefined ) and ( exportWCoord != "" ) ) do fileProperties.addProperty #custom "ExportWCoord" exportWCoord

	-- Set export cameras option.
	if ( ( exportCams != undefined ) and ( exportCams != "" ) ) do fileProperties.addProperty #custom "ExportCams" exportCams 	
)

-- Summary: Prints string to either a buffer passed or to the max listener window.
-- Returns: None.
fn PrintOut str logFile:undefined =
(
	-- If no buffer is passed in just print to the listener.
	if ( logFile == undefined ) then
	( 
		print str
	)
	else
	(
		-- Print to the file buffer.
		print str to:logFile
	)
)

-- Summary: Prints general batch information.
-- Returns: None.
fn PrintBatchSummary sourceFile sourceDir exportDir log:undefined =
(
	-- Print the file currently exporting from.
	outMsg = "Begin Batch Export ************************" 
	PrintOut outMsg logFile:log

	-- Print the file currently exporting from.
	if ( sourceDir != "" ) then 
	(
		outMsg = "Source Directory: " + sourceDir
		PrintOut outMsg logFile:log
	)

	if ( sourceFile != "" ) then 
	(	
		-- Print the file currently exporting from.
		outMsg = "Source File: " + sourceFile
		PrintOut outMsg logFile:log
	)

	-- Print the destination directory.
	outMsg = "Destination Dir: " + exportDir
	PrintOut outMsg logFile:log

	-- Print some blank space.
	PrintOut "" logFile:log
	PrintOut "" logFile:log
)

-- Summary: Prints export information.
-- Returns: None.
fn PrintExportSummary sourceMaxFile destinationFile node:undefined logFileBuff:undefined =
(
	-- Print the file currently exporting from.
	outMsg = "Exporting from file: " + sourceMaxFile 
	PrintOut outMsg logFile:logFileBuff

	-- If this is a multiobject export, print the object currently being exported.		
	if ( node != undefined) do (
		outMsg = "Exporting object: " + node.name
		PrintOut outMsg logFile:logFileBuff
	)

	-- Print the destination of the export.	
	outMsg = "Exported file: " + destinationFile
	PrintOut outMsg logFile:logFileBuff
	
	-- Print line break.
	PrintOut "" logFile:logFileBuff
	
)

-- Summary: Exports max file normally.
-- Returns: None.
fn ExportStandard sourceFile sourceDir exportDir log:undefined =
(
	if ( sourceDir == "") do sourceDir = getFilenamePath sourceFile

	-- Create the default export directory.
	currExportDir = GetExportDir sourceDir exportDir sourceFile
			
	-- Check for export dir properties set in the max file.
	currExportDir = CreateFilePath currExportDir

	exportScript = ExtractExportProp "ExportScript"
	exportFileName = CreateFileName exportScript sourceFile
			
	-- Final path is the directory + the filename.
	finalExportPath = currExportDir + exportFileName
			
	-- Export the file with prompts surpressed.
	exportFile finalExportPath #noprompt

	-- Print export information.			
	PrintExportSummary sourceFile finalExportPath logFileBuff:log
)

-- Summary: Removes batch file export options from a nodes user defined buffer.
-- Returns: None.
fn RemoveBatchProps node = 
(	
	-- Check to see if the first user properties wiped is the first user property.
	nodePropBuffer = getUserPropBuffer node
	processScriptIndx = findString nodePropBuffer "ProcessScript"
	
	-- Clear all the set properties and consequently move the properties to the end of the buffer.
	--  We exploit the move when removing the options since we know that everything after the first
	--  export option found can be truncated.
	setUserProp node "ProcessScript" ""	
	setUserProp node "ExportScript" ""
	setUserProp node "AnimDisabled" ""	
	setUserProp node "ExportWCoord" ""
	setUserProp node "ExportLoc" ""
	setUserProp node "ExportCams" ""
	setUserProp node "ExportFileName" ""
	setUserProp node "ExportSel" ""
	setUserProp node "ExportSet" ""	

	nodePropBuffer = getUserPropBuffer node

	-- Check were the exportscript string exists in the buffer.	
	exportScriptIndex = findString nodePropBuffer "ExportScript"
	
	-- HACK: There is a bug in maxscript when setting user properties. If there are no other user
	--       defined properties other than the export options then for some reason the first
	--       export option we set to "" gets removed from the buffer. Whoops...
	if ( exportScriptIndex == 1 ) then 
	(
		-- Process script has disappeared into maxscript air
		exportOptionsIndex = exportScriptIndex
	)
	else
	(
		exportOptionsIndex = findString nodePropBuffer "ProcessScript"	
	)
	
	-- Truncate the export options from the user buffer.
	nodePropBuffer = substring nodePropBuffer 1 ( exportOptionsIndex - 1 )
	
	-- Write user defined properties buffer back.
	setUserPropBuffer node nodePropBuffer 
)

-- Summary: Exports scene objects marked for export.
-- Returns: None.
fn ExportMultiObject sourceFile sourceDir exportDir log:undefined =
(
	-- Find all nodes marked for export selected ( this will probably be held in the nodes properties page )
	selectedNodes = GetSelectedNodes()
					
	-- For each node 					
	for obj in selectedNodes do
	(
		-- Extract the specific node info ( process/export ) yadda yadda and set custom vars
		SetExportOptions true node:obj
  					    
		-- Select the node in max
		select obj
				
		-- Check for export dir properties set in the max file.
		currExportDir = CreateFilePath exportDir node:obj

		exportScript = getUserProp obj "ExportScript"
		if ( ( exportScript == undefined ) or ( exportScript == "" ) ) do exportScript = ExtractExportProp("ExportScript")
		
		exportFileName = CreateFileName exportScript sourceFile node:obj

		-- Final path is the directory + the filename.
		finalExportPath = currExportDir + exportFileName
				
		-- Remove batch related user properties on node so they don't export.
		RemoveBatchProps(obj)
				
		-- Export selected
		exportFile finalExportPath #noprompt selectedOnly:true
				
		-- Print export information to listener.
		PrintExportSummary sourceFile finalExportPath node:obj logFileBuff:log
				
		-- Clear custom vars
		fileProperties.deleteProperty #custom "PROCESS_SCRIPT_NAME"
		fileProperties.deleteProperty #custom "EXPORT_SCRIPT_NAME"
		fileProperties.deleteProperty #custom "AnimDisabled"
		fileProperties.deleteProperty #custom "ExportWCoord"
		fileProperties.deleteProperty #custom "ExportCams"
						
		-- Deselect the node in max
		deselect obj					  
	)
)

-- Summary: Traverses the max scene from the node passed in accumulating the nodes which are not contained
--          in the setArray.
-- Returns: Array of nodes that the in nodes scenegraph but not contained in setArray.
fn GetNodesArr node setArray =
(
	nodeArr = #()
	
	-- Is the node passed in the set array?
	nodeIndex = findItem setArray node
	
	-- If not ( and it's not the max root) appended it to the nodes returned.
	if ( ( nodeIndex == 0 ) and ( node != rootNode ) ) do append nodeArr node

	-- Traverse children doing looking for nodes.
	for nodes in node.children do 
	(
		join nodeArr ( GetNodesArr nodes setArray )
	)

	nodeArr 
)

-- Summary: Unhides all nodes in the selection set passed in and hides the rest of the scene.
-- Returns: None.
fn ShowExportSelSet exportSet =
(
	-- Array of nodes in current set.
	setNodesArr = #()
		
	-- Fill the nodes of the selection set
	numExportSets = exportSet.count
	for i = 1 to numExportSets do append setNodesArr exportSet[i]

	-- Array of nodes in the scene but not included in current set.
	hiddenNodesArr = GetNodesArr rootNode setNodesArr
		
	-- Hide nodes not in the set.
	for node in hiddenNodesArr do hide node
		
	-- Unhide the nodes in the set.
	for node in setNodesArr do unhide node
)

-- Summary: Find all selection sets in the max file marked for export.
-- Returns: Array of names of the selection sets marked for export.
fn GetExportSets =
(
	exportSets = #()
	
	-- Fill exportSets array.
	numSelSets = selectionSets.count
	for i = 1 to numSelSets do
	(
		-- Get name of selection set.
		selectSetName = getNamedSelSetName i
		selSetInfoName = selectSetName + "_info"

		-- Look for appropriately named dummy node in scene that contains export options.
		infoNode = getNodeByName selSetInfoName
				
		if ( infoNode != undefined ) then 
		(
			-- Check if this set is marked for export.
			exportSet = getUserProp infoNode "ExportSet"
				
			-- If marked then add it to the array of sets to be exported.
			if ( exportSet == 1 ) do append exportSets selectSetName
		)
	)
	exportSets	
)

-- Summary: Exports selection sets marked for export.
-- Returns: None.
fn ExportSelectionSets sourceFile sourceDir exportDir log:undefined =
(
	-- Names of selection sets marked for export.
	exportSets = GetExportSets()
	
	for exSet in exportSets do 
	(
		-- Get selection set from global array.
		exportSet = selectionSets[exSet]
		
		-- Get export info dummy node.
		setInfoName = exSet + "_info"
		setInfoNode = getNodeByName setInfoName

		-- Hide all nodes not in the current selection set.
		ShowExportSelSet( exportSet )

		-- Extract the specific node info ( process/export ) yadda yadda and set custom vars
		SetExportOptions true node:setInfoNode

		-- Check for export dir properties set in the max file.
		currExportDir = CreateFilePath exportDir node:setInfoNode
				
		exportScript = getUserProp setInfoNode "ExportScript"

		if ( ( exportScript == undefined ) or ( exportScript == "" ) ) do exportScript = ExtractExportProp("ExportScript")		

		if (exportScript == "" or exportScript == undefined ) do 
		( 
			msg = "No export script defined for set: " + exSet +"\nSet will not be exported."
			messagebox msg
		)			
		
		exportFileName = CreateFileName exportScript sourceFile node:setInfoNode

		-- Final path is the directory + the filename.
		finalExportPath = currExportDir + exportFileName
		
		-- Export selected
		exportFile finalExportPath #noprompt
				
		-- Print export information to listener.
		PrintExportSummary sourceFile finalExportPath node:setInfoNode logFileBuff:log
				
		-- Clear custom vars
		fileProperties.deleteProperty #custom "PROCESS_SCRIPT_NAME"
		fileProperties.deleteProperty #custom "EXPORT_SCRIPT_NAME"
		fileProperties.deleteProperty #custom "AnimDisabled"
		fileProperties.deleteProperty #custom "ExportWCoord"
		fileProperties.deleteProperty #custom "ExportCams"
	)
)

-- Summary: Creates a list of files to export given the UI input and exports them accordingly.
-- Returns: None.
fn BatchExport sourceDir exportDir sourceFile bCreateLog:false =
(
	-- List of max files to be exported.
	maxfiles = #()
	
	-- Are we exporting a directory?
	if ( sourceFile == "" or sourceFile == "undefined" ) then 
	(
		-- Make sure we have at least a source directory.
		if sourceDir == "" or sourceDir == "undefined" then 
		( 
			messagebox "No source directory or file supplied." 
			return 0
		)

		-- If export directory not defined use the source.
		if exportDir == "" or exportDir == "undefined" then 
		( 
			exportDir = (sourceDir + "\\")
		)
		else
		(
			-- Set export directory.
			exportDir = (exportDir + "\\")
		)

		-- Get a list of max file in the directory & all its sub-directories.
		maxfiles = GetMaxFilesInDir( sourceDir )
		
		-- Creates folders in the destination directory that are in the source directory.
		CreateNewPaths sourceDir exportDir
	)
	else
	(
		-- If export directory not defined use the source files directory.
		if exportDir == "" or exportDir == "undefined" then 
		( 
			sourceFileDir = getFilenamePath sourceFile
			exportDir = sourceFileDir
		)
	
		-- Set export directory.
		exportDir = (exportDir + "\\")	
	
		-- We are exporting a single file. 
		append maxfiles sourceFile
	)
	
	-- Create log file.
	if ( bCreateLog == true ) do 
	(
		logFileName = exportDir + "BatchExportLog.txt"
		logFile = createFile logFileName
	)
	
	-- Print general batch information.
	PrintBatchSummary sourceFile sourceDir exportDir log:logFile
	
	for fl in maxfiles do		
	(
		-- Load the file into max.
		loadMaxFile fl
				
		-- Set exporter to use correct exporting options.
		SetFileBatchMode()
				
		-- These are options that are normally set through the exporter dialog box. 
		SetExportOptions (false)
				
		-- Check for a multiobject max export.
		multiObject = ExtractExportProp("MultiObject")
		
		-- Check for selection set export.
		selectSets = ExtractExportProp("SelectionSets")		

		-- If this is not a mulitObject or selection set max file.
		if (multiObject != "Yes" and selectSets != "Yes") then
		(
			ExportStandard fl sourceDir exportDir log:logFile
		)
		-- If this is a multiobject max file.
		if (multiObject == "Yes" ) then
		(
			ExportMultiObject fl sourceDir exportDir log:logFile
		)
		-- If this is a selection set max file.
		if ( selectSets == "Yes" ) then
		(
			ExportSelectionSets fl sourceDir exportDir log:logFile
		)		
	)

	-- Output end of batch.
	PrintOut "End Batch Export ************************" logFile:logFile
	PrintOut "" logFile:logFile
	
	--Close log buffer.
	if ( bCreateLog == true ) do 
	(	
		close logFile
	)
)
-- ---------------------------------------------------------------------------

-- ---------------------------------------------------------------------------
-- Batch info utility functions
-- ---------------------------------------------------------------------------
-- Summary: Updates a file property.
-- Returns: None.
fn CreateDefaultFileProp propertyName propertyVal:"" =
(
	-- Search for comments field.
	comments =  fileProperties.findProperty #summary "Comments"
	
	-- If the comments field isn't blank.
	if ( comments != 0 ) then
	(	
		-- Split the string by semi-colons.
		exportPropStr = fileproperties.getPropertyValue #summary comments 
		exportProps = filterString exportPropStr ";"
		
		-- If the property is found on this file.
		found = false
				
		-- Iterate over properties defined and extract values we use.		
		for prop in exportProps do
		(
			propSplit = filterString prop "="
			propName = trimLeft propSplit[1]
			propValue = propSplit[2]
			if (propName == propertyName) do found = true
		)
		
		-- If not found then add it.
		if ( found == false ) then 
		(
			propStr = exportPropStr + propertyName + "=" + propertyVal + ";"
			fileProperties.addProperty #summary "Comments" propStr
		)
	)
	else
	(
		-- Create first entry in the comments field.
		propStr = propertyName + "=" + propertyVal + ";"
		fileProperties.addProperty #summary "Comments" propStr	
	)
)

-- Summary: Updates either the node or file information depending on whether a node is passed.
-- Returns: None.
fn CreateDefaultProp propertyName propertyValue:"" node:undefined =
(
	-- If we are updating the user defined properties on a max node.
	if ( node != undefined ) then
	(
		-- Attempt to get the user defined property.
		property = getUserProp node propertyName
		-- If blank or undefined set it to our value.
		if ( ( property == undefined ) or ( property == "") ) do setUserProp node propertyName propertyValue
	)
	-- Otherwise update the file properties.
	else
	(
		CreateDefaultFileProp propertyName propertyVal:propertyValue
	)
)

-- Summary: Adds batch information to file properties.
-- Returns: None.
fn AddBatchInfoToFile =
(
	-- Read in currently set batch file information to make sure no properties are overwritten.
	CreateDefaultProp "ProcessScript" propertyValue:"Do Nothing"
	CreateDefaultProp "ExportScript"
	CreateDefaultProp "ExportLoc"
	CreateDefaultProp "ExportFileName"
	CreateDefaultProp "AnimDisabled" propertyValue:"No"
	CreateDefaultProp "ExportWCoord" propertyValue:"No"
	CreateDefaultProp "ExportCams" propertyValue:"No"
	CreateDefaultProp "MultiObject" propertyValue:"No"
	CreateDefaultProp "SelectionSets" propertyValue:"No"	
)

-- Summary: Iterates through selected max nodes and adds batch information.
-- Returns: None.
fn AddBatchInfoToNode =
(
	-- For each node selected.
	for obj in selection do 
	(
		-- Read in currently set batch file information to make sure no properties are overwritten.
		CreateDefaultProp "ProcessScript" propertyValue:"Do Nothing" node:obj
		CreateDefaultProp "ExportScript" node:obj 
		CreateDefaultProp "ExportLoc" node:obj 
		CreateDefaultProp "ExportFileName" node:obj 
		CreateDefaultProp "AnimDisabled" propertyValue:"No" node:obj 
		CreateDefaultProp "ExportWCoord" propertyValue:"No" node:obj 
		CreateDefaultProp "ExportCams" propertyValue:"No" node:obj 
		CreateDefaultProp "ExportSel" propertyValue:"No" node:obj 
		CreateDefaultProp "ExportSet" propertyValue:"No" node:obj 
	)
)
-- ---------------------------------------------------------------------------
fn GetBSScriptDirectory =
(
	"c:\\program files\\autodesk\\3ds max 2013\\plugins\\BGS\\scripts\\*.script"
)