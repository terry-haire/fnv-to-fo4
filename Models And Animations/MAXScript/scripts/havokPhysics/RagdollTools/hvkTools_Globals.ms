
fileIn "havokPhysics/ragdollTools/hvkTools_Customizable.ms"

-- declare global options - use defaults defined by user

persistent global hvkGlobal_boneScaleX
if (undefined == hvkGlobal_boneScaleX) then
(
	hvkGlobal_boneScaleX = hvkCustomizable_defaultBoneScaleX
)

persistent global hvkGlobal_boneScaleY
if (undefined == hvkGlobal_boneScaleY) then
(
	hvkGlobal_boneScaleY = hvkCustomizable_defaultBoneScaleY
)

persistent global hvkGlobal_boneScaleZ
if (undefined == hvkGlobal_boneScaleZ) then
(
	hvkGlobal_boneScaleZ = hvkCustomizable_defaultBoneScaleZ
)

persistent global hvkGlobal_freezeAssociatedBone
if (undefined == hvkGlobal_freezeAssociatedBone) then
(
	hvkGlobal_freezeAssociatedBone = hvkCustomizable_defaultFreezeAssociatedBone
)

persistent global hvkGlobal_mainAxis
if (undefined == hvkGlobal_mainAxis) then
(
	hvkGlobal_mainAxis = hvkCustomizable_defaultMainAxis
)

persistent global hvkGlobal_bendAxis
if (undefined == hvkGlobal_bendAxis) then
(
	hvkGlobal_bendAxis = hvkCustomizable_defaultBendAxis
)

-- We don't make this global persistent because we don't want it save with the asset, since
-- the path is absolute and therefore depends on the machine installation
global hvkGlobal_templatesFolder
if (undefined == hvkGlobal_templatesFolder) then
(
	hvkGlobal_templatesFolder = hvkCustomizable_defaultTemplatesFolder
)

-- This global is used by the Joint Tools in order to store the "cut" joint
-- Is not persistent and is not initialized
global hvkGlobal_constraintClipboard