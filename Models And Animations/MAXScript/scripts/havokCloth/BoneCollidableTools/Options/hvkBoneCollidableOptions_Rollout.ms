rollout hvkBoneCollidableOptions "Options" width:210 height:324
(
	groupBox grpBoneCreation "Proxy Creation" pos:[4,5] width:200 height:136
	spinner spnScaleX "" pos:[19,48] width:53 height:16 range:[0.5,2,1] scale:0.05
	label lbl4 "X" pos:[35,68] width:10 height:12
	label lbl5 "Y" pos:[94,68] width:10 height:12
	label lbl6 "Z" pos:[153,67] width:10 height:12
	label kljlkj "Proxy Scale" pos:[22,28] width:158 height:16
	checkbox cbFreezeAssociated "Freeze associated  bone" pos:[21,89] width:144 height:17
	spinner spnScaleY "" pos:[76,48] width:53 height:16 range:[0.5,2,1] scale:0.05
	spinner spnScaleZ "" pos:[133,48] width:53 height:16 range:[0.5,2,1] scale:0.05
	checkbox cbAutoParent "Auto Parent Collidable" pos:[21,113] width:144 height:17
	on hvkBoneCollidableOptions open  do
		hvkBoneCollidableOptions_OpenRollout()
	on hvkBoneCollidableOptions close  do
		hvkBoneCollidableOptions_CloseRollout()
	on spnScaleX changed val do
		hvkBoneCollidableOptions_Options_Changed()
	on cbFreezeAssociated changed state do
		hvkBoneCollidableOptions_Options_Changed()
	on spnScaleY changed val do
		hvkBoneCollidableOptions_Options_Changed()
	on spnScaleZ changed val do
		hvkBoneCollidableOptions_Options_Changed()
	on cbAutoParent changed state do
		hvkBoneCollidableOptions_Options_Changed()
	
)