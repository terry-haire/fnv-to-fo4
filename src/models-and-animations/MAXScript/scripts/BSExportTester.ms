(
	_exportpath = "D:\\Games\\Fallout New Vegas\\FNVFo4 Converted\\Data\\Test\\"
	resetMaxFile #noPrompt
	obj = Box()
	obj.material = BSLightingFX()
	select obj
	for i = 1 to 250 do with undo off
	(
		_exportfile = _exportpath + (i as string) + ".nif"
		-- Evaluate the batch exporter
		fileIn "scripts\\Startup\\Materials\\BSMaterialUIUtils.ms"
		--fileIn "scripts\\Startup\\Materials\\BSLightingFX.ms"
		-- Evaluate it AGAIN
		--fileIn "scripts\\Startup\\Materials\\BSLightingFX.ms"
		exportFile _exportfile #noPrompt selectedOnly: true using: nif_export_class		
		--_exportfile = _exportpath + (i as string) + ".max"
		--saveMaxFile _exportfile
		print(i as string)
		print(bPreFileOpenG as string)
	)
)