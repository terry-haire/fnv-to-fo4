rollout hvkVertexPaintingTools "Vertex Painting Tools" width:278 height:261
(
	button newChannel "New" pos:[4,179] width:55 height:19 enabled:false toolTip:"Create a new vertex channel"
	button removeChannel "Remove" pos:[62,202] width:55 height:19 enabled:false toolTip:"Remove selected channel"
	button paintOnChannel "Paint" pos:[62,179] width:55 height:19 enabled:false toolTip:"Start painting on selected channel"
	button renameChannel "Rename" pos:[4,202] width:55 height:19 enabled:false toolTip:"Rename selected channel"
	listBox vertexChannels "Vertex Channels" pos:[3,7] width:129 height:10
	button newExportChannel "Add New" pos:[143,178] width:55 height:19
	button toggleDisplay "Toggle Display" pos:[150,223] width:98 height:19
	button editExportChannel "Edit" pos:[143,200] width:55 height:19
	button removeExportChannel "Remove" pos:[202,200] width:55 height:19
	listBox havokExportChannels "Exported Channels" pos:[141,8] width:129 height:10
	button renameExportChannel "Rename" pos:[202,178] width:55 height:19
	on hvkVertexPaintingTools open  do
		hvkVertexPaintingTools_OpenRollout()
	on hvkVertexPaintingTools close  do
		hvkVertexPaintingTools_CloseRollout()
	on newChannel pressed  do
		hvkVertexPaintingTools_CreateNewChannel()
	on removeChannel pressed  do
		hvkVertexPaintingTools_RemoveChannel()
	on paintOnChannel pressed  do
		hvkVertexPaintingTools_PaintCurrentChannel()
	on renameChannel pressed  do
		hvkVertexPaintingTools_RenameChannel()
	on vertexChannels selected sel do
		hvkVertexPaintingTools_Refresh()
	on vertexChannels doubleClicked sel do
		hvkVertexPaintingTools_PaintCurrentChannel()
	on newExportChannel pressed  do
		hvkVertexPaintingTools_addExportChannelFromCurrentSelection()
	on toggleDisplay pressed  do
		hvkVertexPaintingTools_toggleDisplayOfExportChannel()
	on editExportChannel pressed  do
		hvkVertexPaintingTools_editExportChannel()
	on removeExportChannel pressed  do
		hvkVertexPaintingTools_removeExportChannel()
	on havokExportChannels selected sel do
		hvkVertexPaintingTools_Refresh()
	on havokExportChannels doubleClicked sel do
		hvkVertexPaintingTools_editExportChannel()
	on renameExportChannel pressed  do
		hvkVertexPaintingTools_renameExportChannel()
)