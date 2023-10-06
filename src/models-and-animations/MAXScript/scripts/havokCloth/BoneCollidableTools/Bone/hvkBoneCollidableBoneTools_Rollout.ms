rollout hvkBoneCollidableBoneTools "Proxy Tools" width:210 height:292
(
	button btnAlignPivots "Align Pivots" pos:[19,140] width:85 height:21 toolTip:"Align the pivot of the proxy with the pivot of the associated bone"
	groupBox grpCreateBone "Create Proxy Collidable" pos:[5,0] width:198 height:87
	button btnCapsuleChain "" pos:[114,20] width:34 height:34 images:#("havokCloth/boneCollidableTools/bone/icons.bmp", "havokCloth/boneCollidableTools/bone/iconsAlpha.bmp", 8, 3, 3, 7, 7) toolTip:"Bounding Capsule (Chain)"
	button btnCapsule "" pos:[19,20] width:34 height:34 images:#("havokCloth/boneCollidableTools/bone/icons.bmp", "havokCloth/boneCollidableTools/bone/iconsAlpha.bmp", 8, 1, 1, 5, 5) toolTip:"Bounding Capsule"
	button btnAlignObjects "Align Objects" pos:[106,140] width:85 height:21 toolTip:"Move the proxy so it is aligned with the associated bone"
	button btnSelectDrivingBone "->" pos:[151,108] width:22 height:22 toolTip:"Select the bone(s) associated with this proxy"
	groupBox grpAssociatedBones "Associated Bones(s)" pos:[6,92] width:196 height:77
	button btnRemoveAssociation "" pos:[174,108] width:22 height:22 images:#("havokCloth/boneCollidableTools/bone/smallIcons.bmp", "havokCloth/boneCollidableTools/bone/smallIconsAlpha.bmp", 4, 1, 1, 3, 3) toolTip:"Remove the current bone/chain association of this cloth collidable"
	label lblAssociatedBonesValue "Spine01 - Spine03" pos:[14,113] width:134 height:14
	button btnUseCustomSingle "Custom" pos:[19,60] width:77 height:17
	button btnUseCustomChain "Custom" pos:[114,60] width:77 height:17
	
	on hvkBoneCollidableBoneTools open  do
		hvkBoneCollidableBoneTools_OpenRollout()
	on hvkBoneCollidableBoneTools close  do
		hvkBoneCollidableBoneTools_CloseRollout()
	on btnAlignPivots pressed  do
		hvkBoneCollidableBoneTools_AlignPivots_Pressed()
	on btnCapsuleChain pressed  do
		hvkBoneCollidableBoneTools_CreateCapsuleChain_Pressed()
	on btnCapsule pressed  do
		hvkBoneCollidableBoneTools_CreateCapsule_Pressed()
	on btnAlignObjects pressed  do
		hvkBoneCollidableBoneTools_AlignObjects_Pressed()
	on btnSelectDrivingBone pressed  do
		hvkBoneCollidableBoneTools_SelectDrivingBone_Pressed()
	on btnRemoveAssociation pressed  do
		hvkBoneCollidableBoneTools_RemoveAssociation_Pressed()
	on btnUseCustomSingle pressed  do
		hvkBoneCollidableBoneTools_UseCustomSingle_Pressed()
	on btnUseCustomChain pressed  do
		hvkBoneCollidableBoneTools_UseCustomChain_Pressed()
)