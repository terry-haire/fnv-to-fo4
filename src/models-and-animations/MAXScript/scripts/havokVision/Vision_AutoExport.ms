
fn CheckAutoExport node projectDir &exportedFiles =
(
	szExportTo = getUserProp node "vision_export_targetFile"
	szPreset   = getUserProp node "vision_export_preset"
	
	-- get file extension
	if szExportTo != undefined and szExportTo != "" then
	(
		splitFileNameArray = filterString szExportTo "."
		szFileExt = splitFileNameArray[splitFileNameArray.count]
		
		if szFileExt == "model" then
		(
		  szExportFormat = "Model"
		  if szPreset == undefined then
		  (
			szPreset = "prefabmodel"
		  )
		)
		else
		(
		  szExportFormat = "Mesh"
		  if szPreset == undefined then
		  (
			szPreset = "prefabmesh"
		  )
		)
	)

	if szExportTo != undefined and szExportTo != "" and (findItem exportedFiles szExportTo) == 0 then
	(
		print ("Exporting mesh:"+szExportTo)
		select node
		exportVisionFile szExportFormat (projectDir + "\\" + szExportTo) "" "-noprompt" "-exportSelected" szPreset
		append exportedFiles szExportTo
	)

	-- recurse
	for child in node.children do
	(
		CheckAutoExport child projectDir &exportedFiles
	)
)

if ensureProjectDir() then
(
    projectDir = getProjectDir()
	selList = selection as array  -- get a copy since we'll change the selection for using export selected
	exportedFiles = #()

	if selection.count > 0 then
	(
		-- go through selected nodes
		for obj in selList do 
			CheckAutoExport obj projectDir &exportedFiles
	)
	else
	(
		-- go through all nodes
		for obj in rootNode.children do
			CheckAutoExport obj projectDir &exportedFiles
	)

	-- restore selection
	clearSelection()
	for obj in selList do
		selectMore obj
)
