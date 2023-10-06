-- -------------------------------------------------------------------------
-- ZENIMAX MEDIA PROPRIETARY INFORMATION
-- 
-- This software is developed and/or supplied under the terms of a license
-- or non-disclosure agreement with ZeniMax Media Inc. and may not be copied
-- or disclosed except in accordance with the terms of that agreement.
-- 
--   Copyright ( c ) 2012 ZeniMax Media Incorporated.
--   All Rights Reserved.
-- 
-- ZeniMax Media Incorporated, Rockville, Maryland 20850
-- http://www.zenimax.com
-- 
-- FILE:    BSStickyContactModifier.ms
-- VERSION: 1.0
-- AUTHOR:  Mike Dulany
-- DATE:    11/8/2012
-- -------------------------------------------------------------------------

plugin modifier 'BSStickyContactModifier'
	name:"Sticky Action"
	classID:#(0x77034744, 0x16054eab)
	version:1
(
	parameters main rollout:params
	(
		bStayInPlace type:#boolean animatable:false ui:ui_bStayInPlace default:false
		fStickTimeMin type:#float animatable:false ui:ui_fStickTimeMin default:0.5
		fStickTimeMax type:#float animatable:false ui:ui_fStickTimeMax default:3.0
		fGravityFactor type:#float animatable:false ui:ui_fGravityFactor default:4.0
		bStretch type:#boolean animatable:false ui:ui_bStretch default:true
		fStretchLenMin type:#float animatable:false ui:ui_fStretchLenMin default:0.3
		fStretchLenMax type:#float animatable:false ui:ui_fStretchLenMax default:1.0
		fStretchSpdMin type:#float animatable:false ui:ui_fStretchSpdMin default:0.3
		fStretchSpdMax type:#float animatable:false ui:ui_fStretchSpdMax default:0.6
		fStretchAcc type:#float animatable:false ui:ui_fStretchAcc default:2.0
	)

	rollout params "Parameters"
	(
		checkbox ui_bStayInPlace "Stay In Place" checked:false
		spinner ui_fStickTimeMin "Stick Time Min" range:[0,9999,1] enabled: ( not bStayInPlace )
		spinner ui_fStickTimeMax "Stick Time Max" range:[0,9999,2] enabled: ( not bStayInPlace )
		spinner ui_fGravityFactor "Gravity Factor" range:[-100,100,4] enabled: ( not bStayInPlace )
		checkbox ui_bStretch "Stretch" checked:true
		spinner ui_fStretchLenMin "Stretch Len Min" range:[0,9999,1] enabled: ( bStretch )
		spinner ui_fStretchLenMax "Stretch Len Max" range:[0,9999,10] enabled: ( bStretch )
		spinner ui_fStretchSpdMin "Stretch Spd Min" range:[0,9999,1] enabled: ( bStretch )
		spinner ui_fStretchSpdMax "Stretch Spd Max" range:[0,9999,10] enabled: ( bStretch )
		spinner ui_fStretchAcc "Stretch Acc" range:[0,9999,2] enabled: ( bStretch )

		-- Disable/Enable stick params based on bStayInPlace
		on ui_bStayInPlace changed checked do ( 
			ui_fStickTimeMin.enabled = not ui_bStayInPlace.checked 
			ui_fStickTimeMax.enabled = not ui_bStayInPlace.checked 
			ui_fGravityFactor.enabled = not ui_bStayInPlace.checked 
		)

		-- Disable/Enable stretch params based on bStretch
		on ui_bStretch changed checked do (
			ui_fStretchLenMin.enabled = ui_bStretch.checked
			ui_fStretchLenMax.enabled = ui_bStretch.checked
			ui_fStretchSpdMin.enabled = ui_bStretch.checked
			ui_fStretchSpdMax.enabled = ui_bStretch.checked
			ui_fStretchAcc.enabled = ui_bStretch.checked
		)
	)
)