rollout hvkOptions "Options" width:210 height:324
(
	groupBox grpBoneCreation "Proxy Creation" pos:[4,5] width:200 height:112	
	label lbl4 "X" pos:[35,68] width:10 height:12
	label lbl5 "Y" pos:[94,68] width:10 height:12
	label lbl6 "Z" pos:[153,67] width:10 height:12
	label kljlkj "Proxy Scale" pos:[22,28] width:158 height:16
	checkbox cbFreezeAssociated "Freeze associated  bone" pos:[21,89] width:144 height:17
	spinner spnScaleX "" pos:[19,48] width:53 height:16 range:[0.5,2,1] scale:0.001
	spinner spnScaleY "" pos:[76,48] width:53 height:16 range:[0.5,2,1] scale:0.001
	spinner spnScaleZ "" pos:[133,48] width:53 height:16 range:[0.5,2,1] scale:0.001
	groupBox grp7 "Skeleton Configuration" pos:[3,125] width:200 height:117
	dropDownList ddlMainAxis "" pos:[62,163] width:82 height:21 items:#("X positive", "X negative", "Y positive", "Y negative", "Z positive", "Z negative")
	dropDownList ddlBendAxis "" pos:[62,209] width:82 height:21 items:#("X positive", "X negative", "Y positive", "Y negative", "Z positive", "Z negative") selection:6
	bitmap bmp3 "Bitmap" pos:[149,140] width:45 height:90 fileName:"havokPhysics/ragdolltools/options/bendAxis.bmp"
	label lbl13 "<---- Main Axis" pos:[62,146] width:72 height:17
	bitmap bmp4 "Bitmap" pos:[9,142] width:45 height:90 fileName:"havokPhysics/ragdolltools/options/mainAxis.bmp"
	label lbl14 "Bend Axis ---->" pos:[75,192] width:69 height:17
	groupBox grp13 "Templates Folder" pos:[4,247] width:199 height:69
	label lblTemplatesFolder "d:/3dsmax/havok/templates/defaultHuman/" pos:[16,265] width:179 height:15
	button btn12 "Change" pos:[114,287] width:79 height:21
	on hvkOptions open  do
		hvkOptions_OpenRollout()
	on hvkOptions close  do
		hvkOptions_CloseRollout()
	on spnScaleX changed val do
		hvkOptions_Options_Changed()
	on cbFreezeAssociated changed state do
		hvkOptions_Options_Changed()
	on spnScaleY changed val do
		hvkOptions_Options_Changed()
	on spnScaleZ changed val do
		hvkOptions_Options_Changed()
	on ddlMainAxis selected sel do
		hvkOptions_Options_Changed()
	on ddlBendAxis selected sel do
		hvkOptions_Options_Changed()
	on btn12 pressed  do
		hvkOptions_ChangeTemplatesFolder_Pressed()
)