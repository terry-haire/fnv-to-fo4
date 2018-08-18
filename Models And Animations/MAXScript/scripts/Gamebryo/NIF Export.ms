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
function recursiveExport sourceDir exportDir bPrompt sourceRoot= 
(
  for f in getFiles (sourceDir + "*.max") do 
  (
    if loadMaxFile f useFileUnits:true then
	(
	  strDir = getFilenamePath f
	  strSubDir = replace strDir  1 sourceRoot.count ""

	  if exportDir == undefined then 
		  nifFile = sourceDir + strSubDir + getFilenameFile f + ".nif"
      else
	  	  nifFile = exportDir + strSubDir + getFilenameFile f + ".nif"
	  if bPrompt then
	      exportFile nifFile
	  else exportFile nifFile #noPrompt
    )
  )
  for d in getDirectories (sourceDir + "*") do
    recursiveExport d exportDir bPrompt sourceRoot
)
-----------------------------------------------------------------------------

sourceRoot = getSavePath caption:"All MAX files in the folder you choose and its subfolders will be exported to NIF."
if sourceRoot != undefined then (
	exportDir = getSavePath caption:"Select export directory for NIF files, or click Cancel to use the same folder as the MAX file."

	message = "Do you wish to see the NIF Export Options dialog for each MAX file?\n" +
					   "If not, the options you selected for the most recent NIF export will be used.\n" + 
					   "Or, if you have not yet exported to NIF during this MAX session, the default options will be used."
	bPrompt = queryBox message beep:no
	if bPrompt then
	   promptYN = "will"
	else
	   promptYN = "will not"

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
		recursiveExport sourceRoot exportDir bPrompt sourceRoot
)