rollout hvkJointTools "Constraint Tools" width:210 height:170
(
	dropDownList ddlJointType "" pos:[15,21] width:131 height:21 items:#("Human Knee + Friction", "Human Spine")
	button btnCreateJoint "Create Joint" pos:[15,50] width:82 height:21 toolTip:"Create a new constraint (joint) between the two selected bones based on the current template"
	button btnReplaceJoint "Replace Joint" pos:[112,50] width:82 height:21 toolTip:"Replace the selected constraint (joint) by a new one based on current template"
	groupBox grpTemplates "Templates" pos:[5,1] width:200 height:80
	groupBox grpClipboard "Clipboard" pos:[4,88] width:200 height:75
	button btnCopyJoint "Copy" pos:[20,109] width:78 height:21 toolTip:"Store the selected constraint configuration so it can be pasted on other bones"
	button btnPasteJoint "Paste" pos:[113,109] width:78 height:21 toolTip:"Use (paste) the stored constraint on the selected rigid bodies"
	button btnSaveAs "" pos:[150,20] width:22 height:22 images:#("havokPhysics/ragdollTools/joint/smallIcons.bmp", "havokPhysics/ragdollTools/joint/smallIconsAlpha.bmp", 4, 2, 2, 4, 4) toolTip:"Save the selected constraint as a template"
	button btnRemoveTemplate "" pos:[174,20] width:22 height:22 images:#("havokPhysics/ragdollTools/joint/smallIcons.bmp", "havokPhysics/ragdollTools/joint/smallIconsAlpha.bmp", 4, 1, 1, 3, 3) toolTip:"Remove the selected template"
	label lblClipboardContents "Havok_Hinge_Constraint" pos:[20,137] width:171 height:15
	on hvkJointTools open  do
		hvkJointTools_OpenRollout()
	on hvkJointTools close  do
		hvkJointTools_CloseRollout()
	on btnCreateJoint pressed  do
		hvkJointTools_CreateJoint_Pressed()
	on btnReplaceJoint pressed  do
		hvkJointTools_ReplaceJoint_Pressed()
	on btnCopyJoint pressed  do
		hvkJointTools_CopyJoint_Pressed()
	on btnPasteJoint pressed  do
		hvkJointTools_PasteJoint_Pressed()
	on btnSaveAs pressed  do
		hvkJointTools_SaveAs_Pressed()
	on btnRemoveTemplate pressed  do
		hvkJointTools_RemoveTemplate_Pressed()
)