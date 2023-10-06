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
-- FILE:    BSLagBoneModifier.ms
-- VERSION: 1.0
-- AUTHOR:  Ryan Ashford
-- DATE:    7/20/2010
-- -------------------------------------------------------------------------

plugin modifier 'BSLagBoneModifier'
	name:"Lag Bone"
	classID:#(0x51a93a60, 0x2832ce19)
	version:1
(
	parameters main rollout:params
	(
		linvelocity type:#float animatable:false ui:linvelocity default:0
		rotvelocity type:#float animatable:false ui:rotvelocity default:0
		maxdistance type:#float animatable:false ui:maxdistance default:0
	)

	rollout params "Parameters"
	(
		spinner linvelocity "Lin Velocity: " range:[0,500,0]
		spinner rotvelocity "Rot Velocity: " range:[0,15,0]
		spinner maxdistance "Max Distance: " range:[0,1000,0]
	)
)