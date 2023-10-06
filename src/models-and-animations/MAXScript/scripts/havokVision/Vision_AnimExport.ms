--Shows how to export a nodel and animation file
--Not needed anymore, since you can choose an option during vmesh export to also export an animation file

fileDialog = dotNetObject "System.Windows.Forms.SaveFileDialog"
fileDialog.Title = "Vision 8.2 Animation Exporter"	
fileDialog.Filter = "Vision 8.2 Animated Model (*.model)|*model"
result = fileDialog.ShowDialog()

--Get the result from the dialog
file = fileDialog.FileName

if file != "" then
(
	-- Rebuild the file name to export the anim file
	pos = findString file ".model"
	tempString = substring file 1 (pos-1)
	if tempString == undefined then tempString ="nopath"
	animFile = tempString + ".anim"

	--export the model file
	exportVisionFile "Model" file "" "-noprompt"
	--export the animation file
	exportVisionFile "Animation" animfile "" "-noprompt"
)

	
