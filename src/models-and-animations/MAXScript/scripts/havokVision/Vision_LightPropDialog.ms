fn CheckInput elem label rangeStart rangeEnd =
(
	szRangeS = rangeStart as string
	szRangeE = rangeEnd as string
  content_string = elem.text as string

	-- Check for dot in number
	coma_index = findString content_string "."
	if coma_index == undefined then
	(
		coma_index = findString content_string ","
	)

	-- Check for number
	item = elem.text as Integer
	if item != undefined and coma_index == undefined then
	(
		if item >= rangeStart and item <= rangeEnd then
		(
			return true
		)
		else
		(
			szMessage = "The value of "
			append szMessage label.text
			append szMessage " is not within the allowed range of "
			append szMessage szRangeS 
			append szMessage " and "
			append szMessage szRangeE
			append szMessage "."
			messagebox szMessage
		)
	)
	else
	(
		szMessage = " The "
		append szMessage label.text 
		append szMessage " does not contain an integer number, though it is an integer parameter!\n"
		messagebox szMessage
	)

	false 
)

fn CheckInputFloat elem label rangeStart rangeEnd =
(
	szRangeS = rangeStart as string
	szRangeE = rangeEnd as string

	-- Check for number
	item = elem.text as Float
	if item != undefined then
	(
		if item >= rangeStart and item <= rangeEnd then
		(
			return true
		)
		else
		(
			szMessage = "The value of "
			append szMessage label.text
			append szMessage " is not within the allowed range of "
			append szMessage szRangeS 
			append szMessage " and "
			append szMessage szRangeE
			append szMessage "."
			messagebox szMessage
		)
	)
	else
	(
		szMessage = " The "
		append szMessage label.text
		append szMessage " does not contain a number, though it is a numerical parameter!\n"
		messagebox szMessage
	)
	false
)

--fn FileDialog elem =
--(
	--Shows how to export a nodel and animation file
	--Not needed anymore, since you can choose an option during vmesh export to also export an animation file
--	projectDir = getProjectDir()

--	fileDialog = dotNetObject "System.Windows.Forms.OpenFileDialog"
--	fileDialog.Title = "Vision 8.2 Texture Selector"	
--	fileDialog.Filter = "Microsoft Directx Texture ( *.dds)|*.dds|Portable Network Graphics (*.png)| *.png|Targa Vision (*.tga)|*.tga"
--	fileDialog.InitialDirectory = projectDir
--	result = fileDialog.ShowDialog()

	--Get the result from the dialog
--	file = fileDialog.FileName

--	if file != "" and file != undefined then
--	(
--		elem.text = file
		--substituteString file projectDir finalTex
		--elem.text = finalTex
--	)

--)

rollout roLightProp "Vision" width:320 height:344
(
	pickButton btn1 "Light" pos:[5,6] width:299 height:18
	checkbox chkCorona "Corona" pos:[7,160] width:72 height:16
	checkbox chkLensflare "Lensflare" pos:[8,88] width:72 height:16
	label lbl1 "Corona Texture" pos:[25,176] width:96 height:16
	editText txtCoronaTex "" pos:[113,176] width:158 height:16
	--button btn2 "..." pos:[279,176] width:24 height:16
	label lbl2 "Projected Texture" pos:[8,112] width:96 height:16
	editText txtProjTex "" pos:[113,112] width:158 height:16
	--button btn3 "..." pos:[280,112] width:24 height:16
	pickButton btn4 "Corona" pos:[7,136] width:296 height:16
	pickButton btn6 "Animation" pos:[7,208] width:296 height:16
	label lbl3 "Animation Bitmap" pos:[24,232] width:96 height:16
	editText txtAnimBmp "" pos:[112,232] width:158 height:16
	--button btn7 "..." pos:[280,232] width:24 height:16
	label lbl4 "Animation Time" pos:[24,256] width:88 height:16
	editText txtAnimTime "" pos:[112,256] width:160 height:16
	label lbl5 "Animation Phase" pos:[24,280] width:88 height:16
	editText txtAnimPhase "" pos:[112,280] width:160 height:16
	button btnOk "Ok" pos:[48,312] width:104 height:24
	button btnCancel "Cancel" pos:[160,312] width:104 height:24
	checkbox chkLightDynamic "Dynamic Light" pos:[8,32] width:96 height:16
	label lbl6 "Dynamic Light Influence Mask" pos:[30,50] width:155 height:16
	editText txtDynInfMask "" pos:[185,50] width:118 height:16
	label lbl7 "Static Light Influence Mask" pos:[30,69] width:155 height:16
	editText txtStatInfMask "" pos:[185,69] width:118 height:16
  on btn7 pressed do
	(
		FileDialog txtAnimBmp
	)
	
	on btn3 pressed do
	(
		FileDialog txtProjTex
	)
	
	on btn2 pressed do
	(
		FileDialog txtCoronaTex
	)
	
    on  roLightProp open do
	(
		selArray = selection as array
		
		item = getUserProp selArray[1] "vision_light_dynamicLight"
		if item != undefined then
		(
			chkLightDynamic.triState = item as integer
		)
		else
		(
			chkLightDynamic.triState = 0
		)
		
		item = getUserProp selArray[1] "vision_light_corona"
		if item != undefined then
		(
			chkCorona.triState = item as integer
		)
		else
		(
			chkCorona.triState = 0
		)
		
		item = getUserProp selArray[1] "vision_light_coronaTexture"
		if item != undefined then
		(
			txtCoronaTex.text = item as string
		)
		else
		(
			txtCoronaTex.text = ""
		)
		
		item = getUserProp selArray[1] "vision_light_lensflare"
		if item != undefined then
		(
			chkLensflare.triState = item as integer
		)
		else
		(
			chkLensflare.triState = 0
		)
		
		item = getUserProp selArray[1] "vision_light_projectedTexture"
		if item != undefined then
		(
			txtProjTex.text = item as string
		)
		else
		(
			txtProjTex.text = ""
		)
		
		item = getUserProp selArray[1] "vision_light_animBitmap"
		if item != undefined then
		(
			txtAnimBmp.text = item as string
		)
		else
		(
			txtAnimBmp.text = ""
		)
		
		item = getUserProp selArray[1] "vision_light_animTime"
		if item != undefined then
		(
			txtAnimTime.text = item as string
		)
		else
		(
			txtAnimTime.text = "0.0"
		)
		
		item = getUserProp selArray[1] "vision_light_animPhase"
		if item != undefined then
		(
			txtAnimPhase.text = item as string
		)
		else
		(
			txtAnimPhase.text = "0.0"
		)
		
		item = getUserProp selArray[1] "vision_light_staticGeometryInfluenceMask"
		if item != undefined then
		(
			txtStatInfMask.text = item as string
		)
		else
		(
			txtStatInfMask.text = "65535"
		)
		
		item = getUserProp selArray[1] "vision_light_dynamicGeometryInfluenceMask"
		if item != undefined then
		(
			txtDynInfMask.text = item as string
		)
		else
		(
			txtDynInfMask.text = "65535"
		)
		
	)
	
	on btnOk pressed do
	(
		-- store node properties
		selArray = selection as array
		
		setUserProp selArray[1] "vision_light_dynamicLight" chkLightDynamic.triState
		setUserProp selArray[1] "vision_light_corona" chkCorona.triState
		setUserProp selArray[1] "vision_light_coronaTexture" txtCoronaTex.text
		setUserProp selArray[1] "vision_light_lensflare" chkLensflare.triState
		setUserProp selArray[1] "vision_light_projectedTexture" txtProjTex.text
		setUserProp selArray[1] "vision_light_animBitmap" txtAnimBmp.text
		
		ret = CheckInputFloat txtAnimTime lbl4 0.0 1.0
		if ret == false then
		  return false
	  
		setUserProp selArray[1] "vision_light_animTime" txtAnimTime.text
	  
	     ret = CheckInputFloat txtAnimPhase lbl5 0.0 1.0
		 if ret == false then
		   return false
	  
		setUserProp selArray[1] "vision_light_animPhase" txtAnimPhase.text
	  
	    ret = CheckInput txtStatInfMask lbl7 0 65535
		if ret == false then
		  return false
	  
		setUserProp selArray[1] "vision_light_staticGeometryInfluenceMask" txtStatInfMask.text
	  
	    ret = CheckInput txtDynInfMask lbl6 0 65535
		if ret == false then
		  return false
	  
		setUserProp selArray[1] "vision_light_dynamicGeometryInfluenceMask" txtDynInfMask.text
		
		DestroyDialog roLightProp
	)
	
	on btnCancel pressed do
	(
		DestroyDialog roLightProp
	)
)

createDialog roLightProp escapeEnabled:true modal:true