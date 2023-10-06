rollout convertSelectionToChannelDialog "Convert Vertex Selection to Vertex Colors" width:312 height:144
(
	spinner channelIDSpinner "" pos:[104,9] width:40 height:16 range:[0,99,10] type:#integer scale:1
	label lbl10 "Output Channel ID" pos:[8,9] width:91 height:15
	editText channelName "" pos:[144,8] width:146 height:17 enabled:false
	label lbl11 "Conversion values" pos:[8,40] width:94 height:18
	button btn7 "Convert" pos:[218,282] width:95 height:21
	button btn8 "Convert" pos:[218,282] width:95 height:21
	button btn9 "Convert" pos:[218,282] width:95 height:21
	button convertButton "Convert" pos:[224,112] width:78 height:23
	spinner selectedValue "Selected vert to    " pos:[153,39] width:120 height:16 range:[0,1,1] type:#float scale:1
	spinner unselectedValue "Unselected vert to" pos:[153,63] width:120 height:16 range:[0,1,0] type:#float scale:1
	on convertSelectionToChannelDialog open  do
		hvkChannelConvertTools_UpdateSelectionToColorsDialog()
	on channelIDSpinner changed val do
		hvkChannelConvertTools_SelectionToChannel_updateChannelName()
	on btn7 pressed  do
		hvkChannelConvertTools_convertChannelToTexture()
	on btn8 pressed  do
		hvkChannelConvertTools_convertChannelToTexture()
	on btn9 pressed  do
		hvkChannelConvertTools_convertChannelToTexture()
	on convertButton pressed  do
		hvkChannelConvertTools_SelectionToChannel_convertSelectionToChannel()
	on selectedValue changed val do
		hvkChannelConvertTools_ChannelToTexture_updateChannelName()
	on unselectedValue changed val do
		hvkChannelConvertTools_ChannelToTexture_updateChannelName()
)