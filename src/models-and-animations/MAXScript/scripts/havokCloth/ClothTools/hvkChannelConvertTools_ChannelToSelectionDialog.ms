rollout convertChannelToSelectionDialog "Convert Vertex Channel To Vertex Selection" width:304 height:200
(
	spinner channelIDSpinner "" pos:[104,17] width:40 height:16 range:[0,99,10] type:#integer scale:1
	label lbl3 "Input Channel ID" pos:[8,17] width:91 height:15
	editText channelName "" pos:[144,16] width:146 height:17 enabled:false
	spinner thresholdSpinner "" pos:[120,56] width:40 height:16 range:[0,1,1]
	label lbl4 "Conversion Threshold" pos:[8,56] width:104 height:16
	button convertButton "Convert" pos:[208,160] width:78 height:23
	checkbox invertCheckbox "Invert" pos:[184,56] width:116 height:16
	editText selectionName "Selection Name" pos:[32,112] width:256 height:17
	checkbox saveAsNamedCheckbox "Save As Named Selection" pos:[8,88] width:200 height:16
	on convertChannelToSelectionDialog open  do
		hvkChannelConvertTools_UpdateColorsToSelectionDialog()
	on channelIDSpinner changed val do
		hvkChannelConvertTools_UpdateColorsToSelectionDialog()
	on convertButton pressed  do
		hvkChannelConvertTools_ChannelToSelection_convertChannelToSelection()
	on invertCheckbox changed state do
(
	
	)
	on selectionName entered text do
		hvkChannelConvertTools_UpdateColorsToSelectionDialog()
	on saveAsNamedCheckbox changed state do
		hvkChannelConvertTools_UpdateColorsToSelectionDialog()
)