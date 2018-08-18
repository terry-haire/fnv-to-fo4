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

	rollout ZBufferPanel "Z-Buffer Utils" 
	( 
		checkbox ZBufferRead "Read from Z-Buffer" pos:[20,17] width:122 height:14
		checkbox ZBufferWrite "Write to Z-Buffer" pos:[20,41] width:122 height:14
		button ZBufferApply "Apply to Selection" pos:[20,72] width:122 height:20
		button ZBufferSelect "Select Matching Objects" pos:[20,104] width:122 height:20
		on ZBufferApply pressed  do
		(
			zbuffRead = "0"
			zbuffWrite = "0"
			if ZBufferWrite.checked then zbuffWrite = "1"
			if ZBufferRead.checked then zbuffRead = "1"
			zbuffvalue = "zMode" + zbuffRead + zBuffWrite

			for obj in selection do -- values for each selected object 
			(
				userpropbuffer = getUserPropBuffer obj
				AddZString = false
				
				iFoundIdx = findString userpropbuffer "zMode11"
				if iFoundIdx != undefined
				then (
					userpropbuffer = replace userpropbuffer iFoundIdx 7 zbuffvalue
					AddZString = true
				)
				
				iFoundIdx = findString userpropbuffer "zMode10"
				if iFoundIdx != undefined
				then(
					userpropbuffer = replace userpropbuffer iFoundIdx 7 zbuffvalue
					AddZString = true

				)
				
				iFoundIdx = findString userpropbuffer "zMode00"
				if iFoundIdx != undefined
				then (
					userpropbuffer = replace userpropbuffer iFoundIdx 7 zbuffvalue
					AddZString = true
				)
				
				iFoundIdx = findString userpropbuffer "zMode01"
				if iFoundIdx != undefined 
				then (
					userpropbuffer = replace userpropbuffer iFoundIdx 7 zbuffvalue
					AddZString = true
				)
				
				if AddZString == false
				then userpropbuffer = userpropbuffer + "\r\x00A" + zbuffvalue + "\r\x00A" 
				
				setUserPropBuffer obj userpropbuffer
			)
		)
		on ZBufferSelect pressed  do
		(
			zbuffRead = "0"
			zbuffWrite = "0"
			if ZBufferWrite.checked then zbuffWrite = "1"
			if ZBufferRead.checked then zbuffRead = "1"
			zbuffvalue = "zMode" + zbuffRead + zBuffWrite
			
			clearSelection()
			for obj in $* do
			(
				userpropbuffer = getUserPropBuffer obj
				
				iFoundIdx = findString userpropbuffer zbuffvalue
				if iFoundIdx != undefined then selectMore obj
			)
		)
	)