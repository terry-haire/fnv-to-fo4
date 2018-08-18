rollout hvkChannelConvertTools "Conversion Tools" width:268 height:233
(
	groupBox grp24 "Vertex Colors <=> Texture" pos:[4,5] width:228 height:99
	button convertColorsToTextureButton "Colors => Texture..." pos:[16,24] width:163 height:24
	button convertTextureToColorsButton "Texture => Colors..." pos:[16,56] width:163 height:24
	groupBox grp25 "Vertex Selections <=> Vertex Colors" pos:[4,110] width:228 height:99
	button convertSelectionToColorsButton "Selection => Colors..." pos:[16,129] width:163 height:24
	button convertColorsToSelectionButton "Colors => Selection..." pos:[16,161] width:163 height:24
	on hvkChannelConvertTools open  do
		hvkChannelConvertTools_OpenRollout()
	on hvkChannelConvertTools close  do
		hvkChannelConvertTools_CloseRollout()
	on convertColorsToTextureButton pressed  do
		hvkChannelConvertTools_OpenChannelToBmp()
	on convertTextureToColorsButton pressed  do
		hvkChannelConvertTools_OpenTextureToChannel()
	on convertSelectionToColorsButton pressed  do
		hvkChannelConvertTools_openSelectionToChannelDialog()
	on convertColorsToSelectionButton pressed  do
		hvkChannelConvertTools_openChannelToSelectionDialog()
)