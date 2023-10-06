-- Definition of the functions called from the UI

fileIn "havokCloth/boneCollidableTools/hvkBoneCollidableTools_Globals.ms"

--
-- UPDATE UI
--

function hvkBoneCollidableOptions_updateUI =
(
	hvkBoneCollidableOptions.spnScaleX.value = hvkGlobal_boneCollidableScaleX
	hvkBoneCollidableOptions.spnScaleY.value = hvkGlobal_boneCollidableScaleY
	hvkBoneCollidableOptions.spnScaleZ.value = hvkGlobal_boneCollidableScaleZ	

	hvkBoneCollidableOptions.cbFreezeAssociated.checked = hvkGlobal_freezeCollidableAssociatedBone
	
	hvkBoneCollidableOptions.cbAutoParent.checked = hvkGlobal_autoParentCollidableOnCreation
)


--
-- EVENTS
--

function hvkBoneCollidableOptions_Options_Changed =
(
	hvkGlobal_boneCollidableScaleX = hvkBoneCollidableOptions.spnScaleX.value
	hvkGlobal_boneCollidableScaleY = hvkBoneCollidableOptions.spnScaleY.value
	hvkGlobal_boneCollidableScaleZ = hvkBoneCollidableOptions.spnScaleZ.value 

	hvkGlobal_freezeCollidableAssociatedBone = hvkBoneCollidableOptions.cbFreezeAssociated.checked
	
	hvkGlobal_autoParentCollidableOnCreation = hvkBoneCollidableOptions.cbAutoParent.checked
		
)

function hvkBoneCollidableOptions_OpenRollout =
(
	hvkBoneCollidableOptions_updateUI()
)

function hvkBoneCollidableOptions_CloseRollout =
(
	
)

