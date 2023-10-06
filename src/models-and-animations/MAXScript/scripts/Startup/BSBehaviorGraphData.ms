-- -------------------------------------------------------------------------
-- ZENIMAX MEDIA PROPRIETARY INFORMATION
-- 
-- This software is developed and/or supplied under the terms of a license
-- or non-disclosure agreement with ZeniMax Media Inc. and may not be copied
-- or disclosed except in accordance with the terms of that agreement.
-- 
--   Copyright ( c ) 2009 ZeniMax Media Incorporated.
--   All Rights Reserved.
-- 
-- ZeniMax Media Incorporated, Rockville, Maryland 20850
-- http://www.zenimax.com
-- 
-- FILE:    BSBehaviorGraphData.ms
-- VERSION: 1.0
-- AUTHOR:  Ryan Ashford
-- DATE:    3/30/2010
-- -------------------------------------------------------------------------

--Utility to be loaded by MAX that we can set techniques with.
utility Util_BehaviorGraphData "BSBehaviorGraphData"
(
	rollout RO_BehaviorGraphData "BSBehaviorGraphData" width:162 height:144
	(
		local utilUpdateCallback = undefined
		local propBGPath = "BGPath"
		local propBGCtrlBaseSkel = "BGBaseSkel"
		local meshesPath = "Data\\Meshes\\"
		local graphExt = "hkx"
		
		edittext edGraphPath "" pos:[10,26] width:121 height:18
		button btnApply "Apply To Selected Obj" pos:[21,80] width:117 height:21
		button btnClear "Clear From Selected" pos:[25,111] width:108 height:21
		label lblBGPath "Behavior Graph Path:" pos:[29,8] width:103 height:16 enabled:true
		button btnSelPath "..." pos:[131,26] width:14 height:18
		checkbox chkCtrlBaseSkel "Controls Base Skeleton" pos:[14,54] width:131 height:19
		
		rollout RO_PathError_Loc "Path Error: Bad Location" width:327 height:81
		(
			button btnOK "OK" pos:[126,42] width:65 height:24
			label lbl5 "Error: Behavior graph must exist under the 'Data\Meshes' folder!" pos:[14,12] width:301 height:17
			
			on btnOK pressed do
			(
				destroydialog RO_PathError_Loc
			)
		)
		
		rollout RO_PathError_None "Path Error: Bad Or Nonexistant Path" width:368 height:81
		(
			button btnOK "OK" pos:[154,42] width:65 height:24
			label lbl5 "Error: Path to behavior graph is bad or nonexistant! Settings not applied." pos:[14,12] width:343 height:17
			
			on btnOK pressed do
			(
				destroydialog RO_PathError_None
			)
		)
		
		--Updates the textbox to reflect any parent strings previously set on the selected object.
		fn RetrieveUtilitySettingsFromSelected =
		(
			propStringPath = GetUserProp selection[1] propBGPath
			propCtrlBaseSkel = GetUserProp selection[1] propBGCtrlBaseSkel
			
			if propStringPath == undefined then
				propStringPath = ""
			if propCtrlBaseSkel == undefined then
				propCtrlBaseSkel = false

			edGraphPath.text = propStringPath
			chkCtrlBaseSkel.checked = propCtrlBaseSkel
		)
		
		--Applies the string to the selected object.
		fn SetToSelection =
		(
			SetUserProp selection[1] propBGPath edGraphPath.text
			SetUserProp selection[1] propBGCtrlBaseSkel chkCtrlBaseSkel.checked
		)
		
		--Refresh the UI based on selection data.
		fn RefreshUI =
		(
			--If there are more than one object selected in the scene, clear the selections.
			if selection.count != 1 then
			(
				lblBGPath.enabled = false
				edGraphPath.text = ""
				edGraphPath.readOnly = true
				btnApply.enabled = false
				btnClear.enabled = false
				btnSelPath.enabled = false
				chkCtrlBaseSkel.checked = false
				chkCtrlBaseSkel.enabled = false
			)
			else
			(
				lblBGPath.enabled = true
				edGraphPath.readOnly = false
				btnApply.enabled = true
				btnClear.enabled = true
				btnSelPath.enabled = true
				chkCtrlBaseSkel.enabled = true
				RetrieveUtilitySettingsFromSelected()
			)
		)
		
		--A callback which is triggered whenever the selection changes in MAX.
		fn BGD_RefreshRolloutCallback cbevent cbnode =
		(
			RefreshUI()
		)
		
		on RO_BehaviorGraphData open do
		(
			--Register a callback function with the selectionChanged event.
			utilUpdateCallback = NodeEventCallback selectionChanged:BGD_RefreshRolloutCallback
			RefreshUI()
		)
		on RO_BehaviorGraphData close do
		(
			--A workaround for unregistering the selection callback due to the fact that Autodesk sucks 
			--and didn't create a NodeEventCallbackUnregister function.
			utilUpdateCallback = undefined
			gc()
		)
		on btnApply pressed do
		(			
			if edGraphPath.text != undefined and edGraphPath.text != "" then
				SetToSelection()
			else createDialog RO_PathError_None modal:true
		)
		on btnClear pressed do
		(
			edGraphPath.text = ""
			chkCtrlBaseSkel.checked = false
			SetToSelection()
		)
		on btnSelPath pressed do
		(
			--Update the object with the behavior graph path if it's not undefined.
			exportPath = getOpenFileName caption:"Select Behavior Graph or Project" types:"HKP/HKX (*.hkp, *.hkx)|*.hk*|" historyCategory:"BehaviorGraphData"
			if exportPath != undefined then
			(
				--Find the Data/Meshes folder, and trim off anything before(and including) it.
				index = findString exportPath meshesPath
				if index == undefined then
					createDialog RO_PathError_Loc modal:true
				else
				(
					--Chop off anything before, and including, "Data\Meshes\".
					exportPath = substring exportPath (index+meshesPath.count) -1
					
					--Replace .hk* with .hkx
					local extIndex = findString exportPath "."
					
					exportPath = (substring exportPath 1 extIndex) + graphExt
					
					edGraphPath.text = exportPath
				)
			)
		)
	)
	
	on Util_BehaviorGraphData open do
	(
		addRollout RO_BehaviorGraphData rolledUp:false
	)
	
	on Util_BehaviorGraphData close do
	(
		removeRollout RO_BehaviorGraphData
	)
)