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
-- FILE:    BSParentAttachment.ms
-- VERSION: 1.0
-- AUTHOR:  Ryan Ashford
-- DATE:    10/05/2009
-- -------------------------------------------------------------------------

--Utility to be loaded by MAX that we can set techniques with.
utility Util_ParentAttachment "BSParentAttachment"
(
	rollout RO_ParentAttachment "BSParentAttachment" width:162 height:119
	(
		local utilUpdateCallback = undefined
		
		edittext edTextBox "" pos:[18,26] width:121 height:18
		button btnApply "Apply Selected" pos:[33,57] width:94 height:21
		button btnClear "Clear From Selected" pos:[26,88] width:108 height:21
		label lbl1 "Parent bone to attach to:" pos:[22,8] width:120 height:16 enabled:true
		
		--Updates the textbox to reflect any parent strings previously set on the selected object.
		fn RetrieveUtilitySettingsFromSelected =
		(
			propString = GetUserProp selection[1] "ParentAttachment"
			
			if propString == undefined then
				propString = ""

			edTextBox.text = propString
		)
		
		--Applies the string to the selected object.
		fn SetTechniquesToSelection =
		(
			--selection data is in $selection
			selObj = undefined
		
			for i = 1 to selection.count do
			(	
				selObj = selection[i]
				SetUserProp selObj "ParentAttachment" edTextBox.text
			)
		)
		
		--A callback which is triggered whenever the selection changes in MAX.
		fn RefreshRollbackCallback cbevent cbnode =
		(
			--If there are more than one object selected in the scene, clear the selections.
			if selection.count != 1 then
			(
				edTextBox.text = ""
				edTextBox.readOnly = true
			)
			else
			(
				edTextBox.readOnly = false
				RetrieveUtilitySettingsFromSelected()
			)
		)
		
		on RO_ParentAttachment open do
		(
			--Register a callback function with the selectionChanged event.
			utilUpdateCallback = NodeEventCallback selectionChanged:RefreshRollbackCallback
		)
		on RO_ParentAttachment close do
		(
			--A workaround for unregistering the selection callback due to the fact that Autodesk sucks 
			--and didn't create a NodeEventCallbackUnregister function.
			utilUpdateCallback = undefined
			gc()
		)
		on btnApply pressed do
			SetTechniquesToSelection()
		on btnClear pressed do
		(
			edTextBox.text = ""
			SetTechniquesToSelection()
		)
	)
	
	on Util_ParentAttachment open do
	(
		addRollout RO_ParentAttachment rolledUp:false
	)
	
	on Util_ParentAttachment close do
	(
		removeRollout RO_ParentAttachment
	)
)