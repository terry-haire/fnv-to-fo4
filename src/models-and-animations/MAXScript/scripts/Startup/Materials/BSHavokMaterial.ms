------------------------------------------------------------------------
-- ZENIMAX MEDIA PROPRIETARY INFORMATION
-- 
-- This software is developed and/or supplied under the terms of a license
-- or non-disclosure agreement with ZeniMax Media Inc. and may not be copied
-- or disclosed except in accordance with the terms of that agreement.
-- 
--   Copyright (c) 2009 ZeniMax Media Incorporated.
--   All Rights Reserved.
-- 
-- ZeniMax Media Incorporated, Rockville, Maryland 20850
-- http://www.zenimax.com
-- Owner: Ryan Ashford
------------------------------------------------------------------------

include "BSMaterialUIUtils.ms"

global BSHavokMaterialTypes = #()

HavokMaterialConfigFileName = "CollisionMaterials.cfg"

fn LoadBSHavokMaterialTypes = 
(
	-- Error dialog
	rollout FileNotFound "File Not Found" width:300 height:50
	(
		label NotFoundLabel "Could not find/open Materials.cfg file"
	)
	
	BSHavokMaterialTypes = #()
	
	local configPath = INI_GetConfigsDir()
	if configPath != undefined and HavokMaterialConfigFileName != undefined then
	(
		configPath = configPath + HavokMaterialConfigFileName
	)
	
	matConfigFile = openFile configPath mode:"rt"
	if matConfigFile != undefined then
	(
		while not eof matConfigFile do
		(
			matLine = readLine matConfigFile
			if(matLine.count != 0 and matLine[1] != ";") then
				append BSHavokMaterialTypes matLine
		)
	)
	else
		CreateDialog FileNotFound
)

plugin material BSHavokMaterial
	name:"BSHavokMaterial"
	classID:#(0x784b0e88, 0x7e3f41b6)
	extends:Standard
	replaceUI:true
	version:1
(
	parameters MainParams rollout:MainRollout
	(
		MaterialColorParam type:#color ui:MaterialColorControl
		on MaterialColorParam set arg do (delegate.diffuse = arg)
		
		MaterialNameParam type:#string
		
		DefaultMaterialParam type:#index ui:DefaultMaterialControl

		CustomMaterialEnableParam type:#boolean ui:CustomMaterialEnableControl
		on CustomMaterialEnableParam set arg do
		(
			this.MainRollout.CustomMaterialControl.enabled = arg
			this.MainRollout.DefaultMaterialControl.enabled = not arg
			-- On load, rollout controls are not ready and material name is already set
			if not loading then
			(
				if arg then
					MaterialNameParam = this.MainRollout.CustomMaterialControl.text
				else
				(
					if this.MainRollout.DefaultMaterialControl.selected != undefined then
						MaterialNameParam = this.MainRollout.DefaultMaterialControl.selected
				)
			)
		)
	)
	
	rollout MainRollout "Parameters" width:326 height:125
	(
		groupBox grpHavok "Havok" pos:[7,3] width:310 height:113
		colorPicker MaterialColorControl "Color" pos:[23,25] width:68 height:20
		dropdownList DefaultMaterialControl "Default Material" pos:[24,58] width:129 height:40
		checkbox CustomMaterialEnableControl "Custom Material" pos:[184,57] width:99 height:15
		edittext CustomMaterialControl "" pos:[180,79] width:120 height:17
		
		on MainRollout open do
		(
			-- Enable/disable controls
			CustomMaterialControl.enabled = CustomMaterialEnableParam
			DefaultMaterialControl.enabled = not CustomMaterialEnableParam
			
			DefaultMaterialControl.selection = DefaultMaterialParam
			if CustomMaterialEnableParam do (CustomMaterialControl.text = MaterialNameParam)
			
			-- Populate default materials dropdown
			if BSHavokMaterialTypes.count == 0 then LoadBSHavokMaterialTypes()
			DefaultMaterialControl.items = BSHavokMaterialTypes
		)
		on DefaultMaterialControl selected arg do
		(
			MaterialNameParam = this.MainRollout.DefaultMaterialControl.selected
		)
		on CustomMaterialControl changed arg do
		(
			MaterialNameParam = arg
		)
	)
)