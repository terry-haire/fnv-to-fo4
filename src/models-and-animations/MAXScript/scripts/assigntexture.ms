try(DestroyDialog Browse) catch()
rollout Browse "Browse" width:550
(
    editText edt_image "Image File:" fieldWidth:400 across:2
    button btn_browse "Browse" align:#right
    button btn_assign "Assign Shader"

    on btn_browse pressed do
    (
        local imgPath = getOpenFilename caption: "Open File" types: "Jpg (*.jpg)|*.jpg|Exr (*.exr)|*.exr|Tif (*.tif)|*.tif|ALL|*.*|"
        if imgPath != undefined do edt_image.text = imgPath
    )

    on btn_assign pressed do if isProperty meditMaterials[1] #diffuseMap AND doesFileExist edt_image.text do
    (   
        meditMaterials[1].diffuseMap = BitmapTexture filename:edt_image.text
        selection.material = meditMaterials[1]
    )
)
createDialog Browse