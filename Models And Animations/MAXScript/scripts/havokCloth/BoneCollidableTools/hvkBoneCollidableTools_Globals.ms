
fileIn "havokCloth/boneCollidableTools/hvkBoneCollidableTools_Customizable.ms"

-- declare global options - use defaults defined by user

persistent global hvkGlobal_boneCollidableScaleX
if (undefined == hvkGlobal_boneCollidableScaleX) then
(
	hvkGlobal_boneCollidableScaleX = hvkBoneCollidableCustomizable_defaultBoneScaleX
)

persistent global hvkGlobal_boneCollidableScaleY
if (undefined == hvkGlobal_boneCollidableScaleY) then
(
	hvkGlobal_boneCollidableScaleY = hvkBoneCollidableCustomizable_defaultBoneScaleY
)

persistent global hvkGlobal_boneCollidableScaleZ
if (undefined == hvkGlobal_boneCollidableScaleZ) then
(
	hvkGlobal_boneCollidableScaleZ = hvkBoneCollidableCustomizable_defaultBoneScaleZ
)

persistent global hvkGlobal_freezeCollidableAssociatedBone
if (undefined == hvkGlobal_freezeCollidableAssociatedBone) then
(
	hvkGlobal_freezeCollidableAssociatedBone = hvkBoneCollidableCustomizable_defaultFreezeAssociatedBone
)

persistent global hvkGlobal_autoParentCollidableOnCreation
if (undefined == hvkGlobal_autoParentCollidableOnCreation) then
(
	hvkGlobal_autoParentCollidableOnCreation = hvkBoneCollidableCustomizable_autoParentCollidableOnCreation
)