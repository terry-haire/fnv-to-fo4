-- EMERGENT GAME TECHNOLOGIES PROPRIETARY INFORMATION
--
-- This software is supplied under the terms of a license agreement or
-- nondisclosure agreement with Emergent Game Technologies and may not
-- be copied or disclosed except in accordance with the terms of that
-- agreement.
--
--      Copyright (c) 1996-2006 Emergent Game Technologies.
--      All Rights Reserved.
--
-- Emergent Game Technologies, Chapel Hill, North Carolina 27517
-- http://www.emergent.net
-----------------------------------------------------------------------------

	rollout NiOptimizationPanel "NiOptimization Utils" 
	( 
		checkbox NiOptimizationKeepCheck "Do Not Optimize This Object" pos:[20,17] width:122 height:14
		button NiOptimizationApply "Apply to Selection" pos:[20,36] width:122 height:20
		button NiOptimizationSelect "Select Matching Objects" pos:[20,66] width:122 height:20

		on NiOptimizationApply pressed  do
		(
			if NiOptimizationKeepCheck.checked == true do
			(
				for obj in selection do -- values for each selected object 
				(
					userpropbuffer = getUserPropBuffer obj
					
					iFoundIdx = findString userpropbuffer "NiOptimizeKeep"
					if iFoundIdx == undefined then (
						userpropbuffer = userpropbuffer + "\r\x00ANiOptimizeKeep\r\x00A" 
						setUserPropBuffer obj userpropbuffer
					)
				)
			)
			if NiOptimizationKeepCheck.checked  == false do
			(
				for obj in selection do -- values for each selected object 
				(
					userpropbuffer = getUserPropBuffer obj
					
					iFoundIdx = findString userpropbuffer "NiOptimizeKeep"
					if iFoundIdx != undefined then (
						userpropbuffer = replace userpropbuffer iFoundIdx 14 ""
						setUserPropBuffer obj userpropbuffer
					)
				)
			)

			
		)
		on NiOptimizationSelect pressed  do
		(
			clearSelection()

			if NiOptimizationKeepCheck.checked == true do
			(
				for obj in $* do
				(
					userpropbuffer = getUserPropBuffer obj
					
					iFoundIdx = findString userpropbuffer "NiOptimizeKeep"
					if iFoundIdx != undefined then selectMore obj
					
					iFoundIdx = findString userpropbuffer "sgoKeep"
					if iFoundIdx != undefined then selectMore obj
					
				)
			)

			if NiOptimizationKeepCheck.checked == false do
			(
				for obj in $* do
				(
					userpropbuffer = getUserPropBuffer obj

					iFoundIdxA = findString userpropbuffer "NiOptimizeKeep"
					iFoundIdxB = findString userpropbuffer "sgoKeep"
					if iFoundIdxA == undefined and iFoundIdxB == undefined do selectMore obj
				)
			)
		)
	)