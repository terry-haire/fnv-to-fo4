-- -------------------------------------------------------------------------
-- ZENIMAX MEDIA PROPRIETARY INFORMATION
-- 
-- This software is developed and/or supplied under the terms of a license
-- or non-disclosure agreement with ZeniMax Media Inc. and may not be copied
-- or disclosed except in accordance with the terms of that agreement.
-- 
--   Copyright ( c ) 2006 ZeniMax Media Incorporated.
--   All Rights Reserved.
-- 
-- ZeniMax Media Incorporated, Rockville, Maryland 20850
-- http://www.zenimax.com
-- 
-- FILE:    BSNodeAttachTechniques.mcr
-- VERSION: 1.0
-- AUTHOR:  Ryan Ashford
-- DATE:    7/20/2009
-- -------------------------------------------------------------------------

--Need this for the INI query.
include "Materials/BSMaterialUIUtils.ms"

AttachTechniquesConfigFileName = "AttachTechniques.cfg"

--Utility to be loaded by MAX that we can set techniques with.
utility Util_AttachTechniques "BSNodeAttachTechniques"
(
	--The list of techniques which will appear in the listbox.
	local techniqueList = #()
	
	fn GetTechniqueListFromFile = 
	(
		--Clear the list each time to ensure the list is the latest from the network.
		techniqueList = #()
		
		--Get a list of technique names from AttachmentTechniques.cfg 
		local configPath = INI_GetConfigsDir()
		local fileStream = undefined
		if configPath != undefined and AttachTechniquesConfigFileName != undefined then
		(
			configPath = configPath + AttachTechniquesConfigFileName
			fileStream = openFile configPath mode:"rt"
		)
		
		if (fileStream != undefined) then
		(
			local tempString = undefined
			while not eof fileStream do
			(
				tempString = readLine fileStream
				
				--If the string is valid, add it to the list of techniques
				if (tempString != "" and not matchPattern tempString pattern:";*") then
				(
					techniqueList = append techniqueList tempString
				)
			)
			
			close fileStream
		)
	)
	
	--Creates a string based on the selected items in the listbox.
	fn BuildNewTechniquesString selTechs =
	(
		techniqueString = ""
		
		--Iterate through each of the selected items
		for i = 1 to selTechs.count do
		(
			if selTechs[i] then
			(
				--For formatting/parsing purposes, only put a semicolon between entries.
				if techniqueString != "" then
					techniqueString += ";"
				
				techniqueString += techniqueList[i] as string
			)
		)
		
		techniqueString
	)
	
	fn SetTechniquesToSelection selTechs:#{} =
	(
		--selection data is in $selection
		selObj = undefined
		
		propString = BuildNewTechniquesString selTechs
		
		for i = 1 to selection.count do
		(
			selObj = selection[i]
			SetUserProp selObj "AttachT" propString
		)
	)
	
	rollout RO_AttachTechniques "Attach Techniques" width:162 height:231
	(
		local utilUpdateCallback = undefined
		
		--Create and populate multilistbox with names obtained from cfg.
		--Note: mlb's selection bitarray cannot be directly modified.
		--To change individual selections, modify a local copy first, and then assign back to mlb.selection.
		multiListBox mlb "Attach Techniques" pos:[13,7] width:136 height:10 items:techniqueList
		button btnApply "Apply Selected" pos:[34,169] width:94 height:21
		button btnClear "Clear From Selected" pos:[27,200] width:108 height:21
		
		--Updates the listbox selection to reflect any settings previously set on the selected object.
		fn RetrieveUtilitySettingsFromSelected =
		(
			propString = GetUserProp selection[1] "AttachT"
			
			--Make a local copy of the multilistbox selection bitarray since it appears it cannot be modified directly.
			mlbSelectionCopy = copy mlb.selection
			
			--Reset bit array to all unselected, but maintain the size
			for i = 1 to mlbSelectionCopy.count do
				mlbSelectionCopy[i] = false
			
			if propString == "" or propString == undefined then
				mlbSelectionCopy = #{}
			else
			(
				fs = filterString propString ";"
				
				--Iterate through all of the technique names set on this object.
				for i = 1 to fs.count do
				(
					strIdx = 1
					bfound = false
					
					--Check the technique name against the current set of names.
					--Start at the beginning since both sets of names are ordered by index.
					while strIdx <= mlb.items.count and not bfound do
					(
						if(mlb.items[strIdx] == fs[i]) then
						(
							--Mark this item as selected.
							mlbSelectionCopy[strIdx] = true
							bfound = true
						)
						
						strIdx += 1
					)
				)
			)
			
			--Assign the copy back to the real selection bitarray.
			mlb.selection = mlbSelectionCopy
		)
		
		--A callback which is triggered whenever the selection changes in MAX.
		fn RefreshRollbackCallback cbevent cbnode =
		(
			--If there are more than one object selected in the scene, clear the selections.
			if selection.count != 1 then
				mlb.selection = #{}
			else
				RetrieveUtilitySettingsFromSelected()
		)
		
		on btnApply pressed do
			SetTechniquesToSelection selTechs:mlb.selection
		on btnClear pressed do
		(
			mlb.selection = #{}
			SetTechniquesToSelection()
		)
		
		on RO_AttachTechniques open do
			--Register a callback function with the selectionChanged event.
			utilUpdateCallback = NodeEventCallback selectionChanged:RefreshRollbackCallback
		on RO_AttachTechniques close do
		(
			--A workaround for unregistering the selection callback due to the fact that Autodesk sucks 
			--and didn't create a NodeEventCallbackUnregister function.
			utilUpdateCallback = undefined
			gc()
		)
	)
	
	on Util_AttachTechniques open do
	(
		--Only populate the technique list whenever the rollout is opened.
		GetTechniqueListFromFile()
		addRollout RO_AttachTechniques rolledUp:false
	)
	
	on Util_AttachTechniques close do
	(
		removeRollout RO_AttachTechniques
	)
)