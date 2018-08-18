rollout convertTextureToChannelDialog "Convert Texture to Vertex Colors" width:336 height:232
(
	groupBox grp4 "Input:" pos:[8,9] width:320 height:80
	checkbox loadImageCheckbox "Load Image" pos:[22,29] width:106 height:19
	editText filePath "File" pos:[36,55] width:232 height:17 enabled:false
	button browseButton "..." pos:[276,56] width:32 height:16 enabled:true
	groupBox grp6 "Options:" pos:[8,96] width:320 height:96
	spinner channelIDSpinner "" pos:[104,120] width:40 height:16 range:[0,99,10] type:#integer scale:1
	label lbl4 "Channel ID" pos:[24,120] width:80 height:15
	editText channelName "" pos:[144,120] width:146 height:17 enabled:false
	label lbl5 "Vertex Paint Modifier" pos:[24,152] width:104 height:16
	button btn4 "Convert" pos:[218,282] width:95 height:21
	button btn5 "Convert" pos:[218,282] width:95 height:21
	button btn6 "Convert" pos:[218,282] width:95 height:21
	button btn7 "Convert" pos:[218,282] width:95 height:21
	button convertButton "Convert" pos:[232,200] width:95 height:21
	dropDownList modifierUseDropDown "" pos:[152,152] width:136 height:21 items:#("Create new", "Use currently selected")
	on convertTextureToChannelDialog open  do
		hvkChannelConvertTools_UpdateTextureToChannelDialog()
	on loadImageCheckbox changed state do
		hvkChannelConvertTools_UpdateTextureToChannelDialog()
	on browseButton pressed  do
		hvkChannelConvertTools_TextureToChannel_browseForFile()
	on channelIDSpinner changed val do
		hvkChannelConvertTools_TextureToChannel_updateChannelName()
	on btn4 pressed  do
		hvkChannelConvertTools_convertChannelToTexture()
	on btn5 pressed  do
		hvkChannelConvertTools_convertChannelToTexture()
	on btn6 pressed  do
		hvkChannelConvertTools_convertChannelToTexture()
	on btn7 pressed  do
		hvkChannelConvertTools_convertChannelToTexture()
	on convertButton pressed  do
		hvkChannelConvertTools_convertTextureToChannel()
	on modifierUseDropDown selected sel do
		hvkChannelConvertTools_UpdateTextureToChannelDialog()
)