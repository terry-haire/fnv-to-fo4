rollout roCollisionBitmaskDlg "CollisionBitmask Dialog" width:376 height:80
(
	editText txtRef "Collision Bitmask (32-bit value)" pos:[16,11] width:345 height:22
	button btnOk "Ok" pos:[51,43] width:129 height:23
	button btn2 "Cancel" pos:[190,43] width:129 height:23
	
	on roCollisionBitmaskDlg open do
	(
		selArray = selection as array
		if selArray.count > 0 then
		(
			value = getUserProp selArray[1] "vision_physics_colMask"
			if value != undefined then
				txtRef.text = value as string
		)
		else
		(
			messageBox "Nothing selected!"
			destroyDialog roCollisionBitmaskDlg
		)
		
	)
	
	on btnOk pressed  do
  (
    for elem in selection do
    (
      setUserProp elem "vision_physics_colMask" txtRef.text
    )
    destroyDialog roCollisionBitmaskDlg
	)
	on btn2 pressed  do
  (
    destroyDialog roCollisionBitmaskDlg
	)
)
createDialog roCollisionBitmaskDlg escapeEnabled:true