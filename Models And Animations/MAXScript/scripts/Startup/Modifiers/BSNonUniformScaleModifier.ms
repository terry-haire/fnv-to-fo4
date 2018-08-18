-- -------------------------------------------------------------------------
-- ZENIMAX MEDIA PROPRIETARY INFORMATION
-- 
-- This software is developed and/or supplied under the terms of a license
-- or non-disclosure agreement with ZeniMax Media Inc. and may not be copied
-- or disclosed except in accordance with the terms of that agreement.
-- 
--   Copyright ( c ) 2010 ZeniMax Media Incorporated.
--   All Rights Reserved.
-- 
-- ZeniMax Media Incorporated, Rockville, Maryland 20850
-- http://www.zenimax.com
-- 
-- FILE:    BSNonUniformScaleModifier.ms
-- VERSION: 1.0
-- AUTHOR:  Ryan Ashford
-- DATE:    7/29/2010
-- -------------------------------------------------------------------------

plugin modifier 'BSNonUniformScaleModifier'
	name:"Non-Uniform Scale"
	classID:#(0x19c22cd, 0x37056ff7)
	version:1
(
	parameters main rollout:params
	(
		xscale type:#float animatable:true ui:ui_xscale default:100.0
		yscale type:#float animatable:true ui:ui_yscale default:100.0
		zscale type:#float animatable:true ui:ui_zscale default:100.0
	)

	--Stores as scale * 100 to match 3dsmax scale. Divided by 100 before converted in the exporter to match Gamebryo scale.
	rollout params "Parameters"
	(
		spinner ui_xscale "X Scale (%): " range:[100,3000,100]
		spinner ui_yscale "Y Scale (%): " range:[100,3000,100]
		spinner ui_zscale "Z Scale (%): " range:[100,3000,100]
	)
	
	--apply param is whether or not to apply or remove the stored scale.
	fn ScaleObject apply =
	(
		if selection[1] != undefined and xscale != undefined and yscale != undefined and zscale != undefined then
		(
			scaleVal = [1.0,1.0,1.0]
			
			if apply == true then
				scaleVal = [xscale / 100.0, yscale / 100.0, zscale / 100.0]
			
			selection[1].scale = scaleVal
		)
	)
	
	parameters preview rollout:utils
	(
		bPreviewing type:#boolean animatable:false ui:preview default:false
	)
		
	rollout utils "Utils"
	(
		checkbutton preview "Preview Scale" checked:false tooltip:"Preview scale before exporting"
		button acquireScale "Acquire Scale" tooltip:"Obtains the current scale of the object and puts that data into the modifier."
		
		on preview changed state do
		(
			if state == on then
				bPreviewing = true
			else bPreviewing = false
			
			ScaleObject bPreviewing
		)
		
		on acquireScale pressed do
		(
			if selection[1] != undefined then
			(
				xscale = (selection[1].scale.x * 100.0)
				yscale = (selection[1].scale.y * 100.0)
				zscale = (selection[1].scale.z * 100.0)
				
				preview.checked = true
			)
		)
		
		on utils open do
		(
			if bPreviewing == true then
				preview.checked = true
		)
	)
)