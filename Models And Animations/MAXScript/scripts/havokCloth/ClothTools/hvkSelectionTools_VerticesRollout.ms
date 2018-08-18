rollout hvkVertexSelectionTools "Vertex Selection Tools" width:278 height:158
(
	button saveSelectionAs "Create" pos:[211,13] width:44 height:24 enabled:false toolTip:"Create a new vertex selection set"
	button deleteSelection "Delete" pos:[211,122] width:44 height:24 enabled:false toolTip:"Remove vertex selection set"
	button saveSelection "Save" pos:[211,40] width:44 height:24 enabled:false toolTip:"Save vertex selection set"
	button loadSelection "Select" pos:[211,67] width:44 height:24 enabled:false toolTip:"Load vertex selection"
	button renameSelection "Rename" pos:[211,95] width:44 height:24 enabled:false toolTip:"Rename vertex selection set"
	listBox selectionSets "Named Vertex Selection Sets" pos:[6,9] width:182 height:7
	button refreshSelection "Refresh" pos:[6,135] width:44 height:18 toolTip:"Refresh the selection list"
	on hvkVertexSelectionTools open  do
		hvkSelectionTools_OpenRollout()
	on hvkVertexSelectionTools close  do
		hvkSelectionTools_CloseRollout()
	on saveSelectionAs pressed  do
		hvkSelectionTools_SaveVertexSelectionAs()
	on deleteSelection pressed  do
		hvkSelectionTools_DeleteVertexSelection()
	on saveSelection pressed  do
		hvkSelectionTools_SaveVertexSelection()
	on loadSelection pressed  do
		hvkSelectionTools_LoadVertexSelection()
	on renameSelection pressed  do
		hvkSelectionTools_RenameVertexSelection()
	on selectionSets selected sel do
		hvkSelectionTools_Refresh()
	on selectionSets doubleClicked sel do
		hvkSelectionTools_LoadVertexSelection()
	on refreshSelection pressed  do
		hvkSelectionTools_Refresh()
)