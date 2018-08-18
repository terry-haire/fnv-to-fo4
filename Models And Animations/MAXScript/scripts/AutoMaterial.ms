macroScript AutoMat
(
 local AutoMat_Enabled
 on isChecked return AutoMat_Enabled
 on Execute do
 (
  if AutoMat_Enabled == undefined then
   AutoMat_Enabled = true
  else
   AutoMat_Enabled = not AutoMat_Enabled
  if AutoMat_Enabled then
  (
   txt ="if superclassof meditmaterials[2] != texturemap do \n"
   txt +="selection.material = meditmaterials[2]"
   callbacks.addscript #selectionSetChanged txt \
    id:#AssignMaterial persistent:false
  )
  else
   callbacks.removescripts id:#AssignMaterial
  updateToolbarButtons()
 )--end Execute
)--end macroScript 