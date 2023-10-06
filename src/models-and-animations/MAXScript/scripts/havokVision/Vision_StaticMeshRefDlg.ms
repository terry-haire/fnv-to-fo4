rollout roStaticMeshDlg "Static Mesh Reference Dialog" width:399 height:80
(
	editText txtRef "Static Mesh Reference" pos:[16,10] width:345 height:22
	button btnOk "Ok" pos:[52,43] width:129 height:23
	button btn2 "Cancel" pos:[190,43] width:129 height:23
	button btn5 "..." pos:[365,11] width:30 height:21
  
	on roStaticMeshDlg open do
	(
	  -- retrieve the already existing references
	  selArray = selection as array
		if selArray.count >0 then
		(
		  file = getUserProp selArray[1] "vision_export_targetFile" 
		  if file != undefined and file != OK then
			txtRef.text = file
	   )
	   else
	   (
		   messageBox "Nothing selected!"
		   destroydialog roStaticMeshDlg
	   )
   )
  -- currently sets the reference for all selected objects which doesn't make sense
	on btnOk pressed  do
  (
     sel1 = selection as array
	if selection.count > 0 then
	(
		setUserProp sel1[1] "vision_export_targetFile" txtRef.text
	)
	else
	(
		messageBox "Couldn't update the mesh properties, because no mesh was selected!"
	)
    destroydialog roStaticMeshDlg
  )
	
  on btn2 pressed  do
  (
    destroydialog roStaticMeshDlg
  )
  
  on btn5 pressed do
  (
    fileDialog = dotNetObject "System.Windows.Forms.SaveFileDialog"
    fileDialog.Title = "Vision 8.2 Exporter"	
    fileDialog.Filter = "Vision 8.2 Static Mesh (*.vmesh)|*.vmesh"
    result = fileDialog.ShowDialog()

    --Get the result from the dialog
    file = fileDialog.FileName
    
    if file != "" then
    (
      txtRef.text = file
    )
  )
)

createdialog roStaticMeshDlg escapeEnabled:true