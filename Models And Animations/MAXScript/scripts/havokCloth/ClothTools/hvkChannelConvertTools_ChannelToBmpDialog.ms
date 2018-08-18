rollout convertChannelToTextureDialog "Convert Vertex Colors to Texture" width:312 height:304
(
	groupBox grp3 "Input:" pos:[8,9] width:296 height:49
	spinner channelIDSpinner "" pos:[112,32] width:40 height:16 range:[0,99,10] type:#integer scale:1
	label lbl1 "Colors Channel ID" pos:[15,32] width:95 height:15
	groupBox grp5 "Output:" pos:[7,64] width:297 height:57
	editText filePath "File" pos:[16,88] width:232 height:17
	button browseButton "..." pos:[256,88] width:32 height:16
	groupBox grp6 "Options:" pos:[7,129] width:296 height:136
	checkbox unwrapUVWCheckbox "Unwrap UVW" pos:[16,208] width:106 height:17
	spinner textureSizeY "Y" pos:[104,168] width:48 height:16 range:[0,2048,256] type:#integer scale:1
	label lbl4 "Texture size" pos:[20,152] width:58 height:21
	spinner uvwChannelIDSpinner "" pos:[112,232] width:40 height:16 range:[0,99,1] type:#integer scale:1
	label lbl5 "UVW Channel ID" pos:[24,232] width:88 height:15
	button convertButton "Convert" pos:[208,272] width:95 height:21
	editText channelName "" pos:[152,32] width:146 height:17 enabled:false
	editText uvwChannelName "" pos:[152,232] width:146 height:17 enabled:false
	spinner textureSizeX "X" pos:[104,144] width:48 height:16 range:[0,2048,256] type:#integer scale:1
	checkbox showImage "Show Image" pos:[192,144] width:106 height:17
	on convertChannelToTextureDialog open  do
		hvkChannelConvertTools_UpdateChannelToTextureDialog()
	on channelIDSpinner changed val do
		hvkChannelConvertTools_UpdateChannelToTextureDialog()
	on filePath entered text do
		hvkChannelConvertTools_UpdateChannelToTextureDialog()
	on browseButton pressed  do
		hvkChannelConvertTools_ChannelToTexture_browseForFile()
	on unwrapUVWCheckbox changed state do
		hvkChannelConvertTools_ChannelToTexture_updateUVWChannelName()
	on uvwChannelIDSpinner changed val do
		hvkChannelConvertTools_ChannelToTexture_updateUVWChannelName()
	on convertButton pressed  do
		hvkChannelConvertTools_convertChannelToTexture()
)