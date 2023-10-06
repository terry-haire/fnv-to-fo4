rollout hvkBoneTools "Proxy Tools" width:210 height:292
(
	button btnAlignPivots "Align Pivots" pos:[19,140] width:85 height:21 toolTip:"Align the pivot of the proxy with the pivot of the associated bone"
	groupBox grpCreateBone "Create Proxy RB" pos:[5,0] width:198 height:87
	groupBox grpBoneProperties "Rigid Body Properties" pos:[4,172] width:199 height:114
	spinner spnMass "Mass" pos:[51,193] width:99 height:16 range:[0,1e+007,0]
	spinner spnFriction "Friction" pos:[51,213] width:99 height:16 range:[0,255,0]
	spinner spnRestitution "Restitution" pos:[51,233] width:99 height:16 range:[0,1.98,0]
	button btnBoxChain "" pos:[157,20] width:34 height:34 images:#("havokPhysics/ragdollTools/bone/icons.bmp", "havokPhysics/ragdollTools/bone/iconsAlpha.bmp", 8, 4, 4, 8, 8) toolTip:"Bounding Box (Chain)"
	button btnCapsuleChain "" pos:[114,20] width:34 height:34 images:#("havokPhysics/ragdollTools/bone/icons.bmp", "havokPhysics/ragdollTools/bone/iconsAlpha.bmp", 8, 3, 3, 7, 7) toolTip:"Bounding Capsule (Chain)"
	button btnBox "" pos:[62,20] width:34 height:34 images:#("havokPhysics/ragdollTools/bone/icons.bmp", "havokPhysics/ragdollTools/bone/iconsAlpha.bmp", 8, 2, 2, 6, 6) toolTip:"Bounding Box"
	button btnCapsule "" pos:[19,20] width:34 height:34 images:#("havokPhysics/ragdollTools/bone/icons.bmp", "havokPhysics/ragdollTools/bone/iconsAlpha.bmp", 8, 1, 1, 5, 5) toolTip:"Bounding Capsule"
	button btnAlignObjects "Align Objects" pos:[106,140] width:85 height:21 toolTip:"Move the proxy so it is aligned with the associated bone"
	button btnSelectDrivingBone "->" pos:[151,108] width:22 height:22 toolTip:"Select the bone(s) associated with this proxy"
	groupBox grpAssociatedBones "Associated Bones(s)" pos:[6,92] width:196 height:77
	button btnOpenRBModifier "->" pos:[160,193] width:28 height:19 toolTip:"Open the RB modifier for this object"
	button btnRemoveAssociation "" pos:[174,108] width:22 height:22 images:#("havokPhysics/ragdollTools/bone/smallIcons.bmp", "havokPhysics/ragdollTools/bone/smallIconsAlpha.bmp", 4, 1, 1, 3, 3) toolTip:"Remove the current bone/chain association of this rigid body"
	label lblAssociatedBonesValue "Spine01 - Spine03" pos:[14,113] width:134 height:14
	button btnUseCustomSingle "Custom" pos:[19,60] width:77 height:17
	button btnUseCustomChain "Custom" pos:[114,60] width:77 height:17
	button btnAddTerminal "Add Terminal Point" pos:[41,258] width:115 height:20 toolTip:"Add a point helper at the tip of this proxy"
	on hvkBoneTools open  do
		hvkBoneTools_OpenRollout()
	on hvkBoneTools close  do
		hvkBoneTools_CloseRollout()
	on btnAlignPivots pressed  do
		hvkBoneTools_AlignPivots_Pressed()
	on spnMass changed val do
		hvkBoneTools_Mass_Changed()
	on spnFriction changed val do
		hvkBoneTools_Friction_Changed()
	on spnRestitution changed val do
		hvkBoneTools_Restitution_Changed()
	on btnBoxChain pressed  do
		hvkBoneTools_CreateBoxChain_Pressed()
	on btnCapsuleChain pressed  do
		hvkBoneTools_CreateCapsuleChain_Pressed()
	on btnBox pressed  do
		hvkBoneTools_CreateBox_Pressed()
	on btnCapsule pressed  do
		hvkBoneTools_CreateCapsule_Pressed()
	on btnAlignObjects pressed  do
		hvkBoneTools_AlignObjects_Pressed()
	on btnSelectDrivingBone pressed  do
		hvkBoneTools_SelectDrivingBone_Pressed()
	on btnOpenRBModifier pressed  do
		hvkBoneTools_OpenRBModifier_Pressed()
	on btnRemoveAssociation pressed  do
		hvkBoneTools_RemoveAssociation_Pressed()
	on btnUseCustomSingle pressed  do
		hvkBoneTools_UseCustomSingle_Pressed()
	on btnUseCustomChain pressed  do
		hvkBoneTools_UseCustomChain_Pressed()
	on btnAddTerminal pressed  do
		hvkBoneTools_AddTerminal_Pressed()
)
