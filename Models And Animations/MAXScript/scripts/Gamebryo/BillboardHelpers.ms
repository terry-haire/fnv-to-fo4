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

	rollout BillboardPanel "Billboard Utils" 
	( 
		fn selectNoBillboard = 
			for obj in $* do
			(
				userpropbuffer = getUserPropBuffer obj
				iSelect = true
				iSelect = findString userpropbuffer "billboard" == undefined and iSelect
				iSelect = findString userpropbuffer "billboardUp" == undefined and iSelect
				iSelect = findString userpropbuffer "billboardRigid" == undefined and iSelect
				iSelect = findString userpropbuffer "billboardCenter" == undefined and iSelect
				iSelect = findString userpropbuffer "billboardRigidCenter" == undefined and iSelect

				if iSelect == true then selectMore obj
			) 


		fn selectBillboard = 
			for obj in $* do
			(
				userpropbuffer = getUserPropBuffer obj
				iSelect = true
				iSelect = findString userpropbuffer "billboard" != undefined and iSelect
				iSelect = findString userpropbuffer "billboardUp" == undefined and iSelect
				iSelect = findString userpropbuffer "billboardRigid" == undefined and iSelect
				iSelect = findString userpropbuffer "billboardCenter" == undefined and iSelect
				iSelect = findString userpropbuffer "billboardRigidCenter" == undefined and iSelect

				if iSelect == true then selectMore obj
			) 
   
   		fn selectBillboardUp = 
			for obj in $* do
			(
				userpropbuffer = getUserPropBuffer obj
				iFoundIdx = findString userpropbuffer "billboardUp"
				if iFoundIdx != undefined then selectMore obj
			) 

		fn selectBillboardRigid = 
			for obj in $* do
			(
				userpropbuffer = getUserPropBuffer obj
				iSelect = true
				iSelect = findString userpropbuffer "billboardRigid" != undefined and iSelect
				iSelect = findString userpropbuffer "billboardRigidCenter" == undefined and iSelect

				if iSelect == true then selectMore obj
			) 

		fn selectBillboardCenter = 
			for obj in $* do
			(
				userpropbuffer = getUserPropBuffer obj
				iFoundIdx = findString userpropbuffer "billboardCenter"
				if iFoundIdx != undefined then selectMore obj
			) 

		fn selectBillboardRigidCenter = 
			for obj in $* do
			(
				userpropbuffer = getUserPropBuffer obj
				iFoundIdx = findString userpropbuffer "billboardRigidCenter"
				if iFoundIdx != undefined then selectMore obj
			) 


		radioButtons BillboardModes "Billboard Modes:" pos:[37,18] width:81 height:110 labels:#("None","Standard", "Up", "Rigid", "Center", "Rigid Center") default:1
		button BillboardApply "Apply to Selection" pos:[20,150] width:122 height:20
		button BillboardSelect "Select Matching Objects" pos:[20,180] width:122 height:20
		on BillboardApply pressed  do
		(
			billboardValue = ""
			if BillboardModes.state == 2 then billboardValue = "billboard"
			if BillboardModes.state == 3 then billboardValue = "billboardUp"
			if BillboardModes.state == 4 then billboardValue = "billboardRigid"
			if BillboardModes.state == 5 then billboardValue = "billboardCenter"
			if BillboardModes.state == 6 then billboardValue = "billboardRigidCenter"

			for obj in selection do -- values for each selected object 
			(
				userpropbuffer = getUserPropBuffer obj
				AddBillboardString = false
				
				iFoundIdx = findString userpropbuffer "billboardRigidCenter"
				if iFoundIdx != undefined and AddBillboardString == false
				then (
					userpropbuffer = replace userpropbuffer iFoundIdx 20 billboardValue
					AddBillboardString = true
				)
				
				iFoundIdx = findString userpropbuffer "billboardCenter"
				if iFoundIdx != undefined and AddBillboardString == false
				then(
					userpropbuffer = replace userpropbuffer iFoundIdx 15 billboardValue
					AddBillboardString = true

				)
				
				iFoundIdx = findString userpropbuffer "billboardRigid"
				if iFoundIdx != undefined and AddBillboardString == false
				then (
					userpropbuffer = replace userpropbuffer iFoundIdx 14 billboardValue
					AddBillboardString = true
				)
				
				iFoundIdx = findString userpropbuffer "billboardUp"
				if iFoundIdx != undefined  and AddBillboardString == false
				then (
					userpropbuffer = replace userpropbuffer iFoundIdx 11 billboardValue
					AddBillboardString = true
				)
				
				iFoundIdx = findString userpropbuffer "billboard"
				if iFoundIdx != undefined and AddBillboardString == false
				then (
					userpropbuffer = replace userpropbuffer iFoundIdx 9 billboardValue
					AddBillboardString = true
				)

				if AddBillboardString == false
				then userpropbuffer = userpropbuffer + "\r\x00A" + billboardValue + "\r\x00A" 
				
				setUserPropBuffer obj userpropbuffer
			)
		)
		on BillboardSelect pressed  do
		(
			clearSelection()
			if BillboardModes.state == 1 then selectNoBillboard()
			if BillboardModes.state == 2 then selectBillboard()
			if BillboardModes.state == 3 then selectBillboardUp()
			if BillboardModes.state == 4 then selectBillboardRigid()
			if BillboardModes.state == 5 then selectBillboardCenter()
			if BillboardModes.state == 6 then selectBillboardRigidCenter()
		)
	)