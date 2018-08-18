-- Be careful! This file does not match the rollout Visual MaxScript file! If you resave it this will be overwritten
global gRenameRolloutOkPressed
global gOldText
global gRolloutTitle

rollout selRenameRollout "Untitled" width:181 height:64
(
	editText renameEdit "Name" pos:[6,8] width:170 height:16
	button ok "OK" pos:[37,39] width:44 height:20
	button cancel "Cancel" pos:[92,39] width:44 height:20
	on ok pressed  do
	(
		if ( renameEdit != "" ) do ( gRenameRolloutOkPressed = true )
		DestroyDialog selRenameRollout
	)
	on selRenameRollout open do 
	(
		gRenameRolloutOkPressed = false
		selRenameRollout.renameEdit.text = gOldText
		selRenameRollout.title = gRolloutTitle
		setFocus selRenameRollout.renameEdit
	)
	on cancel pressed  do
	(
		gRenameRolloutOkPressed = false
		DestroyDialog selRenameRollout
	)
)


