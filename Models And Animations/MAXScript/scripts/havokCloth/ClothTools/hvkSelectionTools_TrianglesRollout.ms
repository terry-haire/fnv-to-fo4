rollout hvkTriangleSelectionTools "Triangle Selection Tools" width:278 height:158
(
	button saveSelectionAs "Create" pos:[211,13] width:44 height:24 enabled:false toolTip:"Create a new triangle selection set"
	button deleteSelection "Delete" pos:[211,120] width:44 height:24 enabled:false toolTip:"Remove triangle selection set"
	button saveSelection "Save" pos:[211,40] width:44 height:24 enabled:false toolTip:"Save triangle selection set"
	button loadSelection "Select" pos:[211,67] width:44 height:24 enabled:false toolTip:"Load triangle selection"
	button renameSelection "Rename" pos:[211,93] width:44 height:24 enabled:false toolTip:"Rename triangle selection set"
	listBox selectionSets "Named Triangle Selection Sets" pos:[6,9] width:182 height:7
	button refreshSelection "Refresh" pos:[6,135] width:44 height:18 toolTip:"Refresh the selection list"
	on hvkTriangleSelectionTools open  do
		hvkSelectionTools_OpenRollout()
	on hvkTriangleSelectionTools close  do
		hvkSelectionTools_CloseRollout()
	on saveSelectionAs pressed  do
		hvkSelectionTools_SaveTriangleSelectionAs()
	on deleteSelection pressed  do
		hvkSelectionTools_DeleteTriangleSelection()
	on saveSelection pressed  do
		hvkSelectionTools_SaveTriangleSelection()
	on loadSelection pressed  do
		hvkSelectionTools_LoadTriangleSelection()
	on renameSelection pressed  do
		hvkSelectionTools_RenameTriangleSelection()
	on selectionSets selected sel do
		hvkSelectionTools_Refresh()
	on selectionSets doubleClicked sel do
		hvkSelectionTools_LoadTriangleSelection()
	on refreshSelection pressed  do
		hvkSelectionTools_Refresh()
)