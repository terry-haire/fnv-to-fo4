rollout hvkEdgeSelectionTools "Edge Selection Tools" width:278 height:158
(
	button saveSelectionAs "Create" pos:[211,13] width:44 height:24 enabled:false toolTip:"Create a new edge selection set"
	button deleteSelection "Delete" pos:[211,120] width:44 height:24 enabled:false toolTip:"Remove edge selection set"
	button saveSelection "Save" pos:[211,40] width:44 height:24 enabled:false toolTip:"Save edge selection set"
	button loadSelection "Select" pos:[211,67] width:44 height:24 enabled:false toolTip:"Load edge selection"
	button renameSelection "Rename" pos:[211,93] width:44 height:24 enabled:false toolTip:"Rename edge selection set"
	listBox selectionSets "Named Edge Selection Sets" pos:[6,9] width:182 height:7
	button refreshSelection "Refresh" pos:[6,135] width:44 height:18 toolTip:"Refresh the selection list"
	on hvkEdgeSelectionTools open  do
		hvkSelectionTools_OpenRollout()
	on hvkEdgeSelectionTools close  do
		hvkSelectionTools_CloseRollout()
	on saveSelectionAs pressed  do
		hvkSelectionTools_SaveEdgeSelectionAs()
	on deleteSelection pressed  do
		hvkSelectionTools_DeleteEdgeSelection()
	on saveSelection pressed  do
		hvkSelectionTools_SaveEdgeSelection()
	on loadSelection pressed  do
		hvkSelectionTools_LoadEdgeSelection()
	on renameSelection pressed  do
		hvkSelectionTools_RenameEdgeSelection()
	on selectionSets selected sel do
		hvkSelectionTools_Refresh()
	on selectionSets doubleClicked sel do
		hvkSelectionTools_LoadEdgeSelection()
	on refreshSelection pressed  do
		hvkSelectionTools_Refresh()
)