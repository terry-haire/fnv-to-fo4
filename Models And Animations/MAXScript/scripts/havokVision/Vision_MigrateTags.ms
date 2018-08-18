allObjects = $*
for n in allObjects do
(
  print ("Migrating node: " + n as string)

  -- get the values from the old format
  -- Need to verify that the values match especially for vision_ExportTo
  szExportTo = getUserProp n "vision_ExportTo"
  bVisible = getUserProp n "Visible" 
  iCollision = getUserProp n "CollisionFlags"
  bDynamicLight = getUserProp n "Dynamic"
  szKey = getUserProp n "Key"
  bCorona = getUserProp n "Corona"
  szCoronaTex = getUserProp n "CoronaTexture"
  bLensflare = getUserProp n "Lensflare"
  szProjTex = getUserProp n "ProjectedTexture"
  szAnimBmp = getUserProp n "AnimBitmap"
  fAnimTime = getUserProp n "AnimTime"
  fAnimPhase = getUserProp n "AnimPhase"
  bNoCull = getUserProp n "vMax.bone.NoCull"
  szPropBuffer = getUserPropBuffer n
  szNewProps = ""

  ssPropBuffer = szPropBuffer as stringstream

  -- Add all customer data to the new buffer
  while eof ssPropBuffer == false do
  (
    szLine = readLine ssPropBuffer
    bFoundExp = findstring szLine "vision_ExportTo"
    bFoundVis = findstring szLine "Visible"
    bFoundCol = findstring szLine "CollisionFlags"

    -- Lighting tags
    bFoundDynamicLight = findstring szLine "Dynamic"
    bFoundKey = findstring szLine "Key"
    bFoundCorona = findstring szLine "Corona"
    bFoundCoronaTex = findstring szLine "CoronaTexture"
    bFoundLensflare = findstring szLine "Lensflare"
    bFoundProjTex = findstring szLine "ProjectedTexture"
    bFoundAnimBmp = findstring szLine "AnimBitmap"
    bFoundAnimTime = findstring szLine "AnimTime"
    bFoundAnimPhase = findstring szLine "AnimPhase"


    if  bFoundExp == undefined and 
        bFoundVis == undefined and 
        bFoundCol == undefined and 
        bFoundDynamicLight == undefined and 
        bFoundKey == undefined and 
        bFoundCorona == undefined and 
        bFoundCoronaTex == undefined and 
        bFoundLensflare == undefined and 
        bFoundProjTex == undefined and
        bFoundAnimBmp == undefined and
        bFoundAnimTime == undefined and
        bFoundAnimPhase == undefined and
        szLine != "" then
    (
      append szNewProps szLine
      append szNewProps "\r\n"
    )
  )

  -- add all previously set tags in the new format
  setUserPropBuffer n ""
  if szExportTo != undefined then
  (
    append szNewProps "vision_export_targetFile = "
    append szNewProps szExportTo
    append szNewProps "\r\n"
  )

  if bNoCull != undefined then
  (
    append szNewProps "vision_export_as = unoptimized\r\n"
  )

  if bVisible != undefined then
  (    
    szVisible = bVisible as String
    if szVisible == "0" then
    (
      append szNewProps "vision_export_as = colMesh\r\n"  -- export invisible meshes as collision meshes
    )
  )

  if iCollision != undefined then
  (
    szCollision = iCollision as string
    append szNewProps "vision_physics_colMask = "
    append szNewProps szCollision
    append szNewProps "\n"
  )

  if bDynamicLight != undefined then
  (
    szDL = bDynamicLight as string
    append szNewProps "vision_light_dynamicLight = "
    append szNewProps szDL
    append szNewProps "\n"
  )

  if szKey != undefined then
  (
    append szNewProps "vision_light_key = "
    append szNewProps szKey
    append szNewProps "\n"
  )

  if bCorona != undefined then
  (
    szCor = bCorona as string
    append szNewProps "vision_light_corona = "
    append szNewProps szCor
    append szNewProps "\n"
  )

  if szCoronaTex != undefined then
  (
    append szNewProps "vision_light_coronaTexture = "
    append szNewProps szCoronaTex
    append szNewProps "\n"
  )

  if bLensflare != undefined then
  (
    szLens = bLensflare as string
    append szNewProps "vision_light_lensflare = "
    append szNewProps szLens
    append szNewProps "\n"
  )

  if szProjTex != undefined then
  (
    append szNewProps "vision_light_projectedTexture = "
    append szNewProps szProjTex
    append szNewProps "\n"
  )

  if szAnimBmp != undefined then
  (
    append szNewProps "vision_light_animBitmap = "
    append szNewProps szAnimBmp
    append szNewProps "\n"
  )

  if fAnimTime != undefined then
  (
    szAnimTime = fAnimTime as string
    append szNewProps "vision_light_animTime = "
    append szNewProps szAnimTime 
    append szNewProps "\n"
  )

  if fAnimPhase != undefined then
  (
    szAnimPhase = fAnimPhase as string
    append szNewProps "vision_light_animPhase = "
    append szNewProps szAnimPhase
    append szNewProps "\n"
  )

  setUserPropBuffer n szNewProps
)

allPortals = $portal*
for n in allPortals do
(
  print ("Migrating portal: " + n as string)
  setUserProp n "vision_export_as" "portal"
)
messageBox "Migration finished!"

