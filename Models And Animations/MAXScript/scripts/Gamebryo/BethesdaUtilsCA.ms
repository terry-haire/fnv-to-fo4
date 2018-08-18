-- -------------------------------------------------------------------------
-- ZENIMAX MEDIA PROPRIETARY INFORMATION
-- 
-- This software is developed and/or supplied under the terms of a license
-- or non-disclosure agreement with ZeniMax Media Inc. and may not be copied
-- or disclosed except in accordance with the terms of that agreement.
-- 
--   Copyright (c) 2006 ZeniMax Media Incorporated.
--   All Rights Reserved.
-- 
-- ZeniMax Media Incorporated, Rockville, Maryland 20850
-- http://www.zenimax.com
-- 
-- FILE:    BethesdaUtilsCA.ms
-- VERSION: 1.0
-- AUTHOR:  Mike Dulany
-- DATE:    11/17/2006
-- -------------------------------------------------------------------------

BSAttributes = attributes "BSAttributes" version:4 attribID:#(0x3f8718a1, 0x58c27b40)
(
	parameters main rollout: params
	(
		boneExport type:#boolean ui:boneExport default:true
		bonePriority type:#integer ui:bonePriorityUI default:0
		rotaryAccumInterp type:#boolean ui:rotaryAccumInterpUI default:false
		treadController type:#boolean ui:treadControllerUI default:false
	)
	rollout params "BSAttributes"
	(
		checkbox boneExport "Export Bone Anim" type:#boolean align:#left
		spinner bonePriorityUI "Bone Priority" range:[0,100,1] type:#integer align:#left width:75
		checkbox rotaryAccumInterpUI "Rotary Accum Interpolator" type:#boolean align:#left
		checkbox treadControllerUI "Tread Controller" type:#boolean align:#left
	)
)
