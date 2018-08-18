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

	local strNone = "NONE"
	local strBlankSeq = "EMPTY_SEQUENCE"
	local AllActorRoots = #()
	local ActorRoot = undefined
	local AccumRoot = undefined
	local Layer_Root = undefined
	local AllLayer_Roots = #()
	local lastTime = 0.0
	local strAccum = "KFAccumRoot"
	local ActiveSequence = undefined
	local ActiveSequenceEnd = undefined
	local ActiveNoteTrack = undefined
	local ActiveMorphKeyTime = undefined
	local ActiveMorphKeyText = undefined
	local ActiveInfoKeyTime = undefined
	local ActiveInfoKeyText = undefined

	include "Gamebryo\AnimationHelpers.ms"

	rollout NiActorSeqTagsRollout "Sequence Tags"  
	(
		group "Morph Tags"
		(
			dropdownlist ddlMorphTags "Morph Tags:" enabled:false
			edittext editMorphText "Key Text:" text:"" enabled:false
			spinner spnMorphTagFrame "Tag Time: "  range:[0,99999,0] type:#integer align:#left width:132 enabled:false 
			button btnAddMorphTag "Add Morph Tag" enabled:false width:132
			button btnRemMorphTag "Remove Morph Tag" enabled:false width:132

		)
		
		group "Extra Info Tags"
		(
			dropdownlist ddlInfoTags "Extra Info Tags:" enabled:false
			edittext editInfoText "Key Text:" text:"" enabled:false
			spinner spnInfoTagFrame "Tag Time: "  range:[0,99999,0] type:#integer align:#left width:132 enabled:false 
			button btnAddInfoTag "Add Info Tag" enabled:false width:132
			button btnRemInfoTag "Remove Info Tag" enabled:false width:132
		)
		
		function GetActiveInfoKey =
		(
				for trackTime = ActiveSequence.time to ActiveSequenceEnd.time do 
				(
					TempInfoKey = undefined 
					TempInfoKeys = GetInfoKey ActiveNoteTrack trackTime 
					
					if TempInfoKeys != undefined and TempInfoKeys.count > 0 do
					(
						for i = 1 to TempInfoKeys.count do
						(
							TempInfoKey = TempInfoKeys[i]
							if ActiveInfoKeyTime == TempInfoKey.time and ActiveInfoKeyText == TempInfoKey.value then return TempInfoKey
						)
					)
					
				)
				
				return undefined
		)
		
		function GetActiveMorphKey =
		(
				for trackTime = ActiveSequence.time to ActiveSequenceEnd.time do 
				(
					TempMorphKey = undefined 
					TempMorphKeys = GetMorphKey ActiveNoteTrack trackTime 
					
					if TempMorphKeys != undefined and TempMorphKeys.count > 0 do
					(
						for i = 1 to TempMorphKeys.count do
						(
							TempMorphKey = TempMorphKeys[i]
							if ActiveMorphKeyTime == TempMorphKey.time and ActiveMorphKeyText == TempMorphKey.value then return TempMorphKey
						)
					)
					
				)
				
				return undefined
		)
				
		function UpdateSequenceTagsUI =
		(
			bAdded = false
			if Layer_Root != undefined and ActiveNoteTrack != undefined do
			(
				btnAddInfoTag.enabled = true
				btnAddMorphTag.enabled = true
			
				ddlInfoTags.enabled = false
				ddlMorphTags.enabled = false

				AllSequenceMorphTags = #()
				AllSequenceInfoTags = #()
				MorphTagSelectedIndex = 1
				InfoTagSelectedIndex = 1
				
				for trackTime = ActiveSequence.time to ActiveSequenceEnd.time do 
				(
					TempMorphKey = undefined 
					TempMorphKeys = GetMorphKey ActiveNoteTrack trackTime 
					
					if TempMorphKeys != undefined and TempMorphKeys.count > 0 do
					(
						for i = 1 to TempMorphKeys.count do
						(
							TempMorphKey = TempMorphKeys[i]
							append AllSequenceMorphTags (TempMorphKey.value as string)
							if ActiveMorphKeyTime == undefined do
							( 
								ActiveMorphKeyTime = TempMorphKey.time
								ActiveMorphKeyText = TempMorphKey.value
							)
							
							if ActiveMorphKeyTime == TempMorphKey.time and ActiveMorphKeyText == TempMorphKey.value do
							(
								MorphTagSelectedIndex = AllSequenceMorphTags.count
								print "MorphTagSelectedIndex = "
								print MorphTagSelectedIndex
								print "\n"
							)
						)
					)
					
					TempInfoKey = undefined 
					TempInfoKeys = GetInfoKey ActiveNoteTrack trackTime 
					
					if TempInfoKeys != undefined and TempInfoKeys.count > 0 do
					(
						for i = 1 to TempInfoKeys.count do
						(
							TempInfoKey = TempInfoKeys[i]
							append AllSequenceInfoTags (TempInfoKey.value as string)
							if ActiveInfoKeyTime == undefined do 
							(
								ActiveInfoKeyTime = TempInfoKey.time
								ActiveInfoKeyText = TempInfoKey.value
							)
							
							if ActiveInfoKeyText == TempInfoKey.value and ActiveInfoKeyTime == TempInfoKey.time do
							( 
								InfoTagSelectedIndex = AllSequenceInfoTags.count 
								print "InfoTagSelectedIndex = "
								print InfoTagSelectedIndex
								print "\n"
							)
						)
					)
				)
				
				if AllSequenceMorphTags.count > 0 do 
				(
					ddlMorphTags.items = AllSequenceMorphTags
					ddlMorphTags.enabled = true
					ddlMorphTags.selection = MorphTagSelectedIndex
				)
				if AllSequenceInfoTags.count > 0 do 
				(
					ddlInfoTags.items = AllSequenceInfoTags
					ddlInfoTags.enabled = true
					ddlInfoTags.selection = InfoTagSelectedIndex
				)
				
				if ActiveMorphKeyTime != undefined do
				(
					editMorphText.enabled = true
					value = ""
					if ActiveMorphKeyText.count > 7 then
						value = substring ActiveMorphKeyText 8 -1
					
					editMorphText.text = value
					spnMorphTagFrame.enabled = true
					spnMorphTagFrame.value = ActiveMorphKeyTime
					btnRemMorphTag.enabled = true
				)
				if ActiveMorphKeyTime == undefined do
				(
					editMorphText.enabled = false
					editMorphText.text = ""
					spnMorphTagFrame.enabled = false
					spnMorphTagFrame.value = slidertime
					btnRemMorphTag.enabled = false
				)
				
				if ActiveInfoKeyTime != undefined do
				(
					editInfoText.enabled = true
					value = ActiveInfoKeyText								
					editInfoText.text = value
					spnInfoTagFrame.enabled = true
					spnInfoTagFrame.value = ActiveInfoKeyTime
					btnRemInfoTag.enabled = true
				)
				if ActiveInfoKeyTime == undefined do
				(
					editInfoText.enabled = false
					editInfoText.text = ""
					spnInfoTagFrame.enabled = false
					spnInfoTagFrame.value = slidertime
					btnRemInfoTag.enabled = false
				)

				bAdded = true
			)
			if bAdded == false do
			(
				editMorphText.enabled = false
				editMorphText.text = ""
				editInfoText.enabled = false
				editInfoText.text = ""
				btnAddMorphTag.enabled = false
				btnAddInfoTag.enabled = false
				btnRemMorphTag.enabled = false
				btnRemInfoTag.enabled = false
				spnMorphTagFrame.enabled = false
				spnMorphTagFrame.value = slidertime
				spnInfoTagFrame.enabled = false
				spnInfoTagFrame.value = slidertime
			)
		)
		
		on ddlInfoTags selected index do 
		(
			iCount = 0
			for trackTime = ActiveSequence.time to ActiveSequenceEnd.time do 
			(
				TempInfoKeys = GetInfoKey ActiveNoteTrack trackTime 
				if TempInfoKeys != undefined and TempInfoKeys.count > 0 do
				(
					for i = 1 to TempInfoKeys.count do
					(
						iCount = iCount + 1
						if iCount == index do
						(
							ActiveInfoKeyTime = TempInfoKeys[i].time
							ActiveInfoKeyText = TempInfoKeys[i].value
							UpdateSequenceTagsUI()
							return ok
						)
					)
				)				
			)
		) 

		on ddlMorphTags selected index do 
		(
			iCount = 0
			for trackTime = ActiveSequence.time to ActiveSequenceEnd.time do 
			(
				TempMorphKeys = GetMorphKey ActiveNoteTrack trackTime 
				if TempMorphKeys != undefined and TempMorphKeys.count > 0 do
				(
					for i = 1 to TempMorphKeys.count do
					(
						iCount = iCount + 1
						if iCount == index do 
						(
							ActiveMorphKeyTime = TempMorphKeys[i].time
							ActiveMorphKeyText = TempMorphKeys[i].value
							UpdateSequenceTagsUI()
							return ok
						)
					)
				)				
			)
		) 
		
		on editMorphText changed text do
		(
			if text == "" or text == undefined do
			(
				text = "_"
			)
			if ActiveMorphKeyText != undefined do
			(
				value = "morph: " + text
				TempMorphKeys = GetMorphKey ActiveNoteTrack value 
				if TempMorphKeys != undefined and TempMorphKeys.count > 0 do
				(	
					for key in TempMorphKeys do
					(
						if key.value == value do
						(
							messageBox "Unable to set the input text on this key!\nA key with the same value already exists at this frame!"
							return ok
						)
					)
				)
				
				ActiveMorphKey = GetActiveMorphKey()
				ActiveMorphKeyText = value
				ActiveMorphKey.value = value
				UpdateSequenceTagsUI()
			)
		)
		
		on spnMorphTagFrame changed value do
		(
			bPassed = false
			if value  > ActiveSequence.time and value < ActiveSequenceEnd.time do
			(
				if ActiveMorphKeyText != undefined do
				(
					TempMorphKeys = GetMorphKey ActiveNoteTrack value 
					if TempMorphKeys != undefined and TempMorphKeys.count > 0 do
					(	
						for key in TempMorphKeys do
						(
							if key.value == ActiveMorphKeyText do
							(
								messageBox "Unable to move key to the selected frame!\nA key with the same value already exists at this frame!"
								return ok
							)
						)
					)
					
					bPassed = true
					seqIndex = GetStartKeyIndex ActiveNoteTrack ActiveSequence
					ActiveMorphKey = GetActiveMorphKey()
					ActiveMorphKey.time = value
					ActiveMorphKeyTime = value
				    ActiveSequence = GetStartKey ActiveNoteTrack seqIndex
				    ActiveSequenceEnd = GetEndKey ActiveNoteTrack ActiveSequence
					UpdateSequenceTagsUI()
				)
			)
			
			if not bPassed do
			(
				messageBox "You cannot set the morph tag time to this value.\nThe time must be between the current sequence start and end times. " 
			)
			
		)
		
		on btnAddMorphTag pressed do
		(
			bPassed = false
			if sliderTime >= ActiveSequence.time and sliderTime <= ActiveSequenceEnd.time do
			(
				value = "unknown"
				TempMorphKeys = GetMorphKey ActiveNoteTrack sliderTime 
				if TempMorphKeys != undefined and TempMorphKeys.count > 0 do
				(	
					unknownCount = 0
					for key in TempMorphKeys do
					(
						foundUnknown = findstring key.value "unknown"
						if foundUnknown != undefined do
						(		
							unknownCount = unknownCount + 1					
						)
						value = value + (unknownCount as string)
					)
				)
				
				bPassed = true
				
				seqIndex = GetStartKeyIndex ActiveNoteTrack ActiveSequence
				ActiveMorphKey = CreateNoteKey ActiveNoteTrack slidertime
				ActiveSequence = GetStartKey ActiveNoteTrack seqIndex
				ActiveSequenceEnd = GetEndKey ActiveNoteTrack ActiveSequence
				ActiveMorphKey.value = "morph: " + value
				ActiveMorphKeyTime = sliderTime
				ActiveMorphKeyText = ActiveMorphKey.value
				UpdateSequenceTagsUI()
			)

			if not bPassed do
			(
				messageBox "You cannot add a morph tag now.\nThe time slider must be between the current sequence start and end times. " 
			)
		)
		
		on btnRemMorphTag pressed do
		(
			nt = ActiveNoteTrack
			index = 0
			iCount = NiGetNoteKeyCount nt
			print iCount
			for i = 1 to iCount do
			(
				key = nt.keys[i]
				if key.time == ActiveMorphKeyTime and key.value == ActiveMorphKeyText do
				(
					foundMorph = findstring key.value "morph: "
					if foundMorph != undefined and foundMorph == 1 do
					(
						index = i
						exit
					)
				)
			)
			if index != 0 do
			(
    			seqIndex = GetStartKeyIndex ActiveNoteTrack ActiveSequence
				deletenotekey ActiveNoteTrack.keys index
				ActiveMorphKeyTime = undefined
				ActiveMorphKeyText = undefined
				ActiveSequence = GetStartKey ActiveNoteTrack seqIndex
				ActiveSequenceEnd = GetEndKey ActiveNoteTrack ActiveSequence
				UpdateSequenceTagsUI()
			)
		)
		
		on editInfoText changed text do
		(
			if text == "" or text == undefined do
			(
				text = "_"
			)
			
			if ActiveInfoKeyTime != undefined do
			(
				value = text
				TempInfoKeys = GetInfoKey ActiveNoteTrack value 
				if TempInfoKeys != undefined and TempInfoKeys.count > 0 do
				(	
					for key in TempInfoKeys do
					(
						if key.value == value do
						(
							messageBox "Unable to set the input text on this key!\nA key with the same value already exists at this frame!"
							return ok
						)
					)
				)
				ActiveInfoKey = GetActiveInfoKey()
				ActiveInfoKey.value = value
				ActiveInfoKeyText = value
				
				UpdateSequenceTagsUI()
			)
		)
		
		on spnInfoTagFrame changed value do
		(
			bPassed = false
			if value  > ActiveSequence.time and value < ActiveSequenceEnd.time do
			(
				if ActiveInfoKeyTime != undefined do
				(
					TempInfoKeys = GetInfoKey ActiveNoteTrack value 
					if TempInfoKeys != undefined and TempInfoKeys.count > 0 do
					(	
						for key in TempInfoKeys do
						(
							if key.value == ActiveInfoKeyText do
							(
								messageBox "Unable to move key to the selected frame!\nA key with the same value already exists at this frame!"
								return ok
							)
						)
					)
					bPassed = true
					seqIndex = GetStartKeyIndex ActiveNoteTrack ActiveSequence
				    ActiveInfoKey = GetActiveInfoKey()
					ActiveInfoKey.time = value
					ActiveInfoKeyTime = value
					ActiveSequence = GetStartKey ActiveNoteTrack seqIndex
				    ActiveSequenceEnd = GetEndKey ActiveNoteTrack ActiveSequence
					UpdateSequenceTagsUI()
				)
			)
			
			if not bPassed do
			(
				messageBox "You cannot set the info tag time to this value.\nThe time must be between the current sequence start and end times. " 
			)
			
		)
		
		on btnAddInfoTag pressed do
		(
			bPassed = false
			if sliderTime >= ActiveSequence.time and sliderTime <= ActiveSequenceEnd.time do
			(
				keyvalue = "unknown"
				TempInfoKeys = GetInfoKey ActiveNoteTrack sliderTime 
				if TempInfoKeys != undefined and TempInfoKeys.count > 0 do
				(	
					unknownCount = 0
					for key in TempInfoKeys do
					(
						foundUnknown = findstring key.value "unknown"
						if foundUnknown != undefined do
						(		
							unknownCount = unknownCount + 1					
						)
					)
					keyvalue = keyvalue + (unknownCount as string)
				)
				
				bPassed = true
				seqIndex = GetStartKeyIndex ActiveNoteTrack ActiveSequence
				ActiveInfoKey = CreateNoteKey ActiveNoteTrack slidertime
				ActiveSequence = GetStartKey ActiveNoteTrack seqIndex
				ActiveSequenceEnd = GetEndKey ActiveNoteTrack ActiveSequence
			    ActiveInfoKey.value = keyvalue
				ActiveInfoKeyTime = sliderTime
				ActiveInfoKeyText = ActiveInfoKey.value
				UpdateSequenceTagsUI()
			)
			
			if not bPassed do
			(
				messageBox "You cannot add an info tag now.\nThe time slider must be between the current sequence start and end times. " 
			)
		)
		
		on btnRemInfoTag pressed do
		(
			nt = ActiveNoteTrack
			index = 0
			iCount = NiGetNoteKeyCount nt
			print iCount
			for i = 1 to iCount do
			(
				key = nt.keys[i]
				if key.time == ActiveInfoKeyTime and key.value == ActiveInfoKeyText do
				(
					index = i
					exit
				)
			)
			if index != 0 do
			(
			    seqIndex = GetStartKeyIndex ActiveNoteTrack ActiveSequence
				deletenotekey ActiveNoteTrack.keys index
				ActiveSequence = GetStartKey ActiveNoteTrack seqIndex
				ActiveSequenceEnd = GetEndKey ActiveNoteTrack ActiveSequence
				ActiveInfoKeyTime = undefined
				ActiveInfoKeyText = undefined
				UpdateSequenceTagsUI()
			)
		)

		on NiActorSeqTagsRollout open do
		(
			UpdateSequenceTagsUI()
		)
	)

	function IsTopLevelSequence =
	(
		if AccumRoot != undefined and Layer_Root == ActorRoot and ActorRoot != undefined do
		(
			return true
		)
			
		return false
	)
	
	rollout NiActorAccumulationRollout "Sequence Accumulation"
	(
		group "Sequence Accumulation"
		(
			checkbox cbAccumRots "Accumulate Rotations" offset:[0, 0] align:#left enabled:false
			dropdownlist ddAccumRots "" items:#("X Axis", "Y Axis", "Z Axis", "All Axes") offset:[15, 0] selection:4 enabled:false align:#left width:120
			dropdownlist ddFront "Actor Faces:" items:#("X Axis", "Negative X Axis", "Y Axis", "Negative Y Axis") selection:1 offset:[15,0] width:120 enabled:false
			checkbox cbAccumTrans "Accumulate Translations" offset:[0, 6] align:#left enabled:false
			checkbox cbAccumXTrans "X Axis" offset:[15, 0] align:#left enabled:false
			checkbox cbAccumYTrans "Y Axis" offset:[15, 0] align:#left enabled:false
			checkbox cbAccumZTrans "Z Axis" offset:[15, 0] align:#left enabled:false
			
		)
		
		function UpdateAccumulationGroupUI =
		(
			bFixed = false
			if IsTopLevelSequence() and ActiveSequence != undefined do
			(
				bFixed = true
	 			local strTrans = GetSequenceAccumTrans ActiveSequence 
				strTrans = uppercase strTrans
				local strRots = GetSequenceAccumRot ActiveSequence
				strRots = uppercase strRots
				local strFront = GetSequenceFront ActiveSequence
				strFront = uppercase strFront
				
				
				cbAccumRots.enabled = true
				if strRots == "NONE" then 
					cbAccumRots.checked = false 
				else 
					cbAccumRots.checked = true
				
				ddAccumRots.enabled = cbAccumRots.checked
				
				if strRots == "X" then ddAccumRots.selection = 1 
				if strRots == "Y" then ddAccumRots.selection = 2
				if strRots == "Z" then ddAccumRots.selection = 3
				if strRots == "ALL" then ddAccumRots.selection = 4
 
				cbAccumTrans.enabled = true
				if strTrans == "NONE" then 
					cbAccumTrans.checked = false 
				else 
					cbAccumTrans.checked = true
				
				foundX = findstring strTrans "X"
				foundY = findstring strTrans "Y"
				foundZ = findstring strTrans "Z"

				if foundX != undefined then 
					cbAccumXTrans.checked = true 
				else 
					cbAccumXTrans.checked = false
				if foundY != undefined then 
					cbAccumYTrans.checked = true 
				else 
					cbAccumYTrans.checked = false
				if foundZ != undefined then 
					cbAccumZTrans.checked = true 
				else 
					cbAccumZTrans.checked = false
				
				if strTrans == "ALL" do 
				(
					cbAccumXTrans.checked = true
					cbAccumYTrans.checked = true
					cbAccumZTrans.checked = true
				)
				
				if cbAccumTrans.checked do
				(
					cbAccumXTrans.enabled = true
					cbAccumYTrans.enabled = true
					cbAccumZTrans.enabled = true
				)
				if not cbAccumTrans.checked do
				(
					cbAccumXTrans.enabled = false
					cbAccumYTrans.enabled = false
					cbAccumZTrans.enabled = false
				)
				
				if strRots == "NONE" then ddFront.enabled = false
				if strRots == "X" then ddFront.enabled = false 
				if strRots == "Y" then ddFront.enabled = false
				if strRots == "Z" then ddFront.enabled = true 
				if strRots == "ALL" then ddFront.enabled = true
					
				if ddFront.enabled == true do
				(
					if strFront == "X" then ddFront.selection = 1
					if strFront == "NEGX" then ddFront.selection = 2
					if strFront == "Y" then ddFront.selection = 3
					if strFront == "NEGY" then ddFront.selection = 4				
				)
			)	
			if bFixed == false do
			(
				cbAccumRots.enabled = false
				cbAccumRots.checked = false
				cbAccumTrans.enabled = false
				cbAccumTrans.checked = false
				cbAccumXTrans.enabled = false
				cbAccumXTrans.checked = false
				cbAccumYTrans.enabled = false
				cbAccumYTrans.checked = false
				cbAccumZTrans.enabled = false
				cbAccumZTrans.checked = false
				ddAccumRots.enabled = false
				ddFront.enabled = false	
			)
			
			
			NiActorSeqTagsRollout.UpdateSequenceTagsUI()
		)
					
		on cbAccumRots changed state do
		(
			print "cbAccumRots changed state..."
			items = filterstring ActiveSequence.value " "

			value = ""
			strRots = "none"
			if cbAccumRots.checked == true do
			(
				strRots = "all"
			)
			print strRots
			
			bAdded = false
			ignoreindex = 0
			for i = 1 to items.count do
			(
				item = items[i]
				bAppend = true
				if (EqualsNoCase item "-ar") do
				(
					bAppend = false 
					value = value + " -ar " + strRots + " "
					bAdded = true 
					ignoreindex = i + 1
					
					if items.count == ignoreindex  do
					(
						if strRots == "all" or strRots == "x" do
						(
							value = value + "-front x "
						)
					)
						
				)
				if i == ignoreindex then continue
				
				if bAppend == true then value = value + item + " "
			)
			
			if bAdded == false and cbAccumRots.checked == false then 
				value = value + " -ar none " 
			if bAdded == false and cbAccumRots.checked == true then
				value = value + " -ar " + strRots
			
			print value	
			ActiveSequence.value = value	
			UpdateAccumulationGroupUI()	
		)
		
		on ddAccumRots selected item do
		(
			items = filterstring ActiveSequence.value " "
			strRots = "none"
			
			if item == 1 then strRots = "x"
			if item == 2 then strRots = "y"
			if item == 3 then strRots = "z"			
			if item == 4 then strRots = "all"
			
			ignoreindex = 0
			value = ""
			for i = 1 to items.count do
			(
				item = items[i]
				bAppend = true
				if (EqualsNoCase item "-ar") do
				(
					bAppend = false 
					value = value + " -ar " + strRots + " "
					bAdded = true 
					ignoreindex = i + 1
				)
				if i == ignoreindex then continue
				if bAppend == true then value = value + item + " "
			)
			
			ActiveSequence.value = value
			UpdateAccumulationGroupUI()
		)
		
		on cbAccumTrans changed state do
		(
			print "cbAccumTrans changed state..."
			items = filterstring ActiveSequence.value " "

			value = ""
			strTrans = "none"
			if cbAccumTrans.checked == true do
			(
				strTrans = "xy"
			)
			print strTrans
			
			bAdded = false
			ignoreindex = 0
			for i = 1 to items.count do
			(
				item = items[i]
				bAppend = true
				if (EqualsNoCase item "-at") do
				(
					bAppend = false 
					value = value + " -at " + strTrans + " "
					bAdded = true 
					ignoreindex = i + 1
				)
				if i == ignoreindex then continue
				
				if bAppend == true then value = value + item + " "
			)
			
			if bAdded == false and cbAccumTrans.checked == false then 
				value = value + " -at none " 
			if bAdded == false and cbAccumTrans.checked == true then
				value = value + " -at " + strTrans + " "
			
			print value	
			ActiveSequence.value = value	
			UpdateAccumulationGroupUI()		
		)

		function UpdateTransAccumFlags =
		(
			items = filterstring ActiveSequence.value " "
			strTrans = ""
			
			if cbAccumXTrans.checked then strTrans = strTrans + "x"
			if cbAccumYTrans.checked then strTrans = strTrans + "y"
			if cbAccumZTrans.checked then strTrans = strTrans + "z"
			
			if strTrans == "" then strTrans = "none"
			
			ignoreindex = 0
			value = ""
			for i = 1 to items.count do
			(
				item = items[i]
				bAppend = true
				if (EqualsNoCase item "-at") do
				(
					bAppend = false 
					value = value + " -at " + strTrans + " "
					bAdded = true 
					ignoreindex = i + 1
				)
				if i == ignoreindex then continue
				if bAppend == true then value = value + item + " "
			)
			
			ActiveSequence.value = value
			UpdateAccumulationGroupUI()
		)
		
		on cbAccumXTrans changed state do
		(
			UpdateTransAccumFlags()
		)
		
		on cbAccumYTrans changed state do
		(
			UpdateTransAccumFlags()
		)
		
		on cbAccumZTrans changed state do
		(
			UpdateTransAccumFlags()
		)
		
		on ddFront selected item do
		(
			items = filterstring ActiveSequence.value " "
			strFront = ""
			
			if item == 1 then strFront = "x"
			if item == 2 then strFront = "negx"
			if item == 3 then strFront = "y"
			if item == 4 then strFront = "negy"
			
			ignoreindex = 0
			value = ""
			bAdded = false
			for i = 1 to items.count do
			(
				myitem = items[i]
				bAppend = true
				if (EqualsNoCase myitem "-front") do
				(
					bAppend = false 
					value = value + " -front " + strFront + " "
					bAdded = true 
					ignoreindex = i + 1
				)
				if i == ignoreindex then continue
				if bAppend == true then value = value + myitem + " "
			)


			if bAdded == false then value = value + " -front " + strFront + " "		
			ActiveSequence.value = value
		)
		
		on NiActorAccumulationRollout open do
		(
			UpdateAccumulationGroupUI()
		)
	)

	rollout NiActorSequenceRollout "Active Sequence"  
	(
		group  "Sequence"
		(
			dropdownlist  ddlSequences "Sequences:" align:#left enabled:false width:132 height:10
			label lblSeqName "Active Sequence Name:" align:#left enabled:false
			edittext editSeqName "" text:"NEW SEQUENCE" align:#left width:132 enabled:false
			label lblSeqCount "Sequence 0 of 0" enabled:false align:#left offset:[0, 6]
			checkbox cbLooping "Loop Sequence" offset:[0,5] enabled:false
			spinner spnStartFrame "Start Frame: " range:[-99999,99999,0] type:#integer align:#left enabled:false
			spinner spnEndFrame "End Frame: " range:[-99999,99999,0] type:#integer align:#left enabled:false
			
			button btnRecordStartFrame "Start Now" across:2 enabled:false width:65
			button btnRecordEndFrame "End Now" across: 2 enabled:false width:65

			button btnPrev "Previous" across:2 align:#center width:65 enabled:false
			button btnNext "Next" across:2 align:#center width:65 enabled:false
			
			button btnMakeSpanFit "Make Time Range Fit" width:132 enabled:false
			button btnCreate "Append New Sequence" align:#center width:132 enabled:false
			button btnPrepend "Prepend New Sequence" align:#center width:132 enabled:false
			button btnDestroy "Delete Current Sequence"  align:#center width:132 enabled:false
		)
		
		function UpdateSequenceUI =
		(
			print "Updating sequence UI..."
			print Layer_Root

			if Layer_Root != undefined do
			(
				if ActiveNoteTrack == undefined do
				(
					print "Active Note Track is undefined.. getting from layer root"
					ActiveNoteTrack = GetActorNoteTrack Layer_Root
				)
				print ActiveNoteTrack
				if ActiveSequence == undefined do
				(
					print "ActiveSequence == undefined"
					ActiveSequence = GetStartKey ActiveNotetrack 1
					ActiveInfoKeyTime = undefined
					ActiveInfoKeyText = undefined
					ActiveMorphKeyTime = undefined
					ActiveMorphKeyText= undefined
				)
				
				if ActiveSequenceEnd == undefined do
				(
					print "ActiveSequenceEnd == undefined"
					ActiveSequenceEnd = GetEndKey ActiveNotetrack ActiveSequence
					print "Active Sequence End:"
					print ActiveSequenceEnd
				)
				
				print "Active Sequence:"
				print ActiveSequence
				print "Active Sequence End:"
				print ActiveSequenceEnd

				list = #()
				listsize = GetSequenceCount ActiveNoteTrack
				
				if listsize != undefined do
				(
					for i = 1 to listsize do
					(
						startKey = GetStartKey ActiveNoteTrack i
						seqname = GetSequenceName startKey
						if seqname != undefined do
						(
							append list seqname
						)
					)
				)

				if listsize > 0 do
				(
					ddlSequences.items = list
				)
				if listsize == 0 do
				(
					ddlSequences.items = #()
				)
			

			)

			if ActiveSequence != undefined do
			(
				lblSeqName.enabled = true
				lblSeqCount.enabled = true
				editSeqName.enabled = true
				editSeqName.text = GetSequenceName ActiveSequence
				lblSeqCount.enabled = true
				seqCount = GetSequenceCount ActiveNoteTrack
				seqIndex = GetStartKeyIndex ActiveNoteTrack ActiveSequence
				strSeqCount = "Sequence " + seqIndex as string + " of " + seqCount as string
				lblSeqCount.caption = strSeqCount
				cbLooping.enabled = true
				cbLooping.checked = GetSequenceLoop ActiveSequence
				spnStartFrame.enabled = true
				spnEndFrame.enabled = true
				spnStartFrame.value = ActiveSequence.time
				spnEndFrame.value = ActiveSequenceEnd.time
				btnRecordStartFrame.enabled=true
				btnRecordEndFrame.enabled = true
				btnCreate.enabled = true
				btnPrepend.enabled = true
				btnMakeSpanFit.enabled = true
				
				if seqCount > 1 then 
					btnDestroy.enabled = true 
				else 
					btnDestroy.enabled = false
				
				if seqIndex == 1 then 
					btnPrev.enabled = false 
				else 
					btnPrev.enabled = true
					
				if seqIndex == seqCount then 
					btnNext.enabled = false 
				else 
					btnNext.enabled = true

				ddlSequences.enabled = true
				ddlSequences.selection = seqIndex
			)
			if ActiveSequence == undefined do
			(
				lblSeqName.enabled = false
				lblSeqCount.enabled = false
				editSeqName.enabled = false
				editSeqName.text = ""
				lblSeqCount.enabled = false
				seqCount = 0
				seqIndex = 0
				strSeqCount = "Sequence " + seqIndex as string + " of " + seqCount as string
				lblSeqCount.caption = strSeqCount
				cbLooping.enabled = false
				cbLooping.checked = false
				spnStartFrame.enabled = false
				spnEndFrame.enabled = false
				spnStartFrame.value = 0
				spnEndFrame.value = 0
				btnRecordStartFrame.enabled=false
				btnRecordEndFrame.enabled = false
				btnCreate.enabled = false	
				btnPrepend.enabled = false
				btnDestroy.enabled = false 
				btnPrev.enabled = false 
				btnNext.enabled = false 
				btnMakeSpanFit.enabled = false
				ddlSequences.items = #()
				ddlSequences.enabled = false
			)
			NiActorAccumulationRollout.UpdateAccumulationGroupUI()

		)
		
		on btnMakeSpanFit pressed do
		(
			print "Anim Range:"
			print animationRange
			animationRange = (interval ActiveSequence.time ActiveSequenceEnd.time)
		)
		
		function AddSequence nt name start end bLooping = 
		(
			if nt == undefined then return undefined
			NewSequence = SetSimpleStartKey nt name start bLooping
			NewSequenceEnd = SetSimpleEndKey nt end
			return NewSequence
		)
		
		function RemoveSequence nt StartKey EndKey=
		(
			if nt == undefined then return undefined
			
			keyArray = #()
			for key in nt.keys do
			(
				if key.time < startKey.time or key.time > endkey.time do
				(
					append keyArray key
				)
			)
			
			ntnew = notetrack "ActorManager2"
			addNoteTrack Layer_Root ntnew
			for key in keyArray do
			(
				newKey = CreateNoteKey ntnew key.time
				newKey.value = key.value
			)

			deleteNoteTrack Layer_Root nt
			ActiveNoteTrack = ntnew
			ntnew.name = "ActorManager"
		)
		
		on NiActorSequenceRollout open do
		(
			UpdateSequenceUI()
		)
		
		on ddlSequences selected seqnum do
		(
			index = seqnum
			ActiveSequence = GetStartKey ActiveNoteTrack index
			ActiveSequenceEnd = GetEndKey ActiveNoteTrack ActiveSequence
			ActiveInfoKeyTime = undefined
			ActiveInfoKeyText = undefined
			ActiveMorphKeyTime = undefined
			ActiveMorphKeyText = undefined
			UpdateSequenceUI()
		) 


		on btnPrepend pressed do
		(
			if ActiveSequence.time <= 0 do
			(
				message = "There cannot be a sequence earlier than this one!"
				messagebox message title:"Prepend error"
				return ok
			)
			
			index = GetStartKeyIndex ActiveNoteTrack ActiveSequence
			index = index - 1
			bLooping = cbLooping.enabled
			start = 0
			end = 0
			
			if index == 0 do
			(
				start = 0
				end = ActiveSequence.time - 1
			)
			if index > 0 do
			(
				nextSeq = GetStartKey ActiveNoteTrack index
				if nextSeq == undefined do
				(
					start = ActiveSequence.time - 1
					end = ActiveSequence.time - 10
				)
				if nextSeq != undefined do
				(
					prevEnd = GetEndKey ActiveNoteTrack nextSeq
					start = prevEnd.time + 1
					end = ActiveSequence.time - 1
					if (prevEnd.time == (ActiveSequence.time - 1)) or (start == end) do
					(
						message = "There is a sequence already immediately preceding this sequence!"
						messagebox message title:"Append error!"
						return ok
					)
				)
			)
			
			strNewSeqName = strBlankSeq + "_AT_" + (start as string) 
			NewSequence = AddSequence ActiveNoteTrack strNewSeqName start end bLooping
			if NewSequence != undefined do
			(
				print "btnPrepend pressed..."
				ActiveSequence = NewSequence
				print ActiveSequence
				ActiveSequenceEnd = GetEndKey ActiveNoteTrack ActiveSequence
				ActiveInfoKeyTime = undefined
				ActiveInfoKeyText = undefined
				ActiveMorphKeyTime = undefined
				ActiveMorphKeyText = undefined
				UpdateSequenceUI()
			)
		)
		
		on btnCreate pressed do
		(
			index = GetStartKeyIndex ActiveNoteTrack ActiveSequence
			index = index + 1
			bLooping = cbLooping.enabled
			start = 0
			end = 0
			
			nextSeq = GetStartKey ActiveNoteTrack index
			if nextSeq == undefined do
			(
				start = ActiveSequenceEnd.time+1
				end = ActiveSequenceEnd.time + 10
			)
			if nextSeq != undefined do
			(
				start = ActiveSequenceEnd.time + 1
				end = nextSeq.time - 1
				if nextSeq.time == (ActiveSequenceEnd.time+1) or (start == end) do
				(
					message = "There is a sequence already immediately following this sequence!"
					messagebox message title:"Append error!"
					return ok
				)
			)
			
			strNewSeqName = strBlankSeq + "_AT_" + (start as string) 
			NewSequence = AddSequence ActiveNoteTrack strNewSeqName start end bLooping
			if NewSequence != undefined do
			(
				print "btnCreate pressed..."
				ActiveSequence = NewSequence
				print ActiveSequence
				ActiveSequenceEnd = GetEndKey ActiveNoteTrack ActiveSequence
				ActiveInfoKeyTime = undefined
				ActiveInfoKeyText = undefined
				ActiveMorphKeyTime = undefined
				ActiveMorphKeyText = undefined
				UpdateSequenceUI()
			)
		)
		-- Start Bethesda Change
		function AppendOldSequences StartKeyTime EndKeyTime =
		(
			if hasNoteTracks Layer_Root do
			(
				ntAppendNum = numnotetracks Layer_Root 
				ntAppendNum = ntAppendNum - 1 
				for i = 1 to ntAppendNum  do
				(
					nt = getnotetrack Layer_Root i
					if nt != undefined do
					(
						keyArray = #()

						for key in nt.keys do
						(			
							if key.time < StartKeyTime or key.time > EndKeyTime do
							(
								append keyArray key
							)
						)
			
						ntnew = notetrack "temp"
						addNoteTrack Layer_Root ntnew
						for key in keyArray do
						(
							newKey = CreateNoteKey ntnew key.time
							newKey.value = key.value
						)
	
						oldNtName = nt.name
	
						deleteNoteTrack Layer_Root nt
						ntnew.name = oldNtName												
					)
				)
			)
		)
		-- End Bethesda Change
		
		on btnDestroy pressed do
		(
			-- Start Bethesda Change
			startKeyTime = ActiveSequence.time
			endKeyTime = ActiveSequenceEnd.time
			-- End Bethesda Change
			RemoveSequence ActiveNoteTrack ActiveSequence ActiveSequenceEnd
			ActiveSequence = undefined 
			ActiveSequenceEnd = undefined
			ActiveInfoKeyTime = undefined
			ActiveInfoKeyText = undefined
			ActiveMorphKeyTime = undefined
			ActiveMorphKeyText = undefined
			-- Start Bethesda Change
			AppendOldSequences startKeyTime endKeyTime 
			-- End Bethesda Change
			UpdateSequenceUI()
		)
		
		
		
		on btnPrev pressed do
		(
			index = GetStartKeyIndex ActiveNoteTrack ActiveSequence
			if index > 1 do
			(
				index = index - 1
				ActiveSequence = GetStartKey ActiveNoteTrack index
				ActiveSequenceEnd = GetEndKey ActiveNoteTrack ActiveSequence
				ActiveInfoKeyTime = undefined
				ActiveInfoKeyText = undefined
				ActiveMorphKeyTime = undefined
				ActiveMorphKeyText = undefined
				UpdateSequenceUI()
			)
		)
		
		on btnNext pressed do
		(
			index = GetStartKeyIndex ActiveNoteTrack ActiveSequence
			count = GetSequenceCount ActiveNoteTrack
			if index< count do
			(
				index = index + 1
				ActiveSequence = GetStartKey ActiveNoteTrack index
				ActiveSequenceEnd = GetEndKey ActiveNoteTrack ActiveSequence
				ActiveInfoKeyTime = undefined
				ActiveInfoKeyText = undefined
				ActiveMorphKeyTime = undefined
				ActiveMorphKeyText = undefined
				UpdateSequenceUI()
			)
		)
		
		
		function CanSetActiveSequenceTime start end =
		(
			if start > end then return false
			if start >= ActiveSequenceEnd.time then return false
			if end <= ActiveSequence.time then return false
			
			index = GetStartKeyIndex ActiveNoteTrack ActiveSequence
			if index > 1 do
			(
				PrevSequence = GetStartKey ActiveNoteTrack (index-1)
				PrevSequenceEnd = GetEndKey ActiveNoteTrack PrevSequence
				if PrevSequenceEnd.time >= start then return false
			)
			if index < GetSequenceCount ActiveNoteTrack do
			(
				NextSequence = GetStartKey ActiveNoteTrack (index+1)
				if NextSequence.time <= end then return false
			)
			return true
		)
		
		on btnRecordStartFrame pressed do
		(
			frame = slidertime 			
			bAdd = false
			if CanSetActiveSequenceTime frame ActiveSequenceEnd.time do
			(
			    seqIndex = GetStartKeyIndex ActiveNoteTrack ActiveSequence
				ActiveSequence.time = frame
				ActiveSequence = GetStartKey ActiveNoteTrack seqIndex
				ActiveSequenceEnd = GetEndKey ActiveNoteTrack ActiveSequence
				setsliderTime ActiveSequence.time
				spnStartFrame.value = frame
				ActiveMorphKeyTime = undefined
                ActiveMorphKeyText = undefined
                ActiveInfoKeyTime = undefined
                ActiveInfoKeyText = undefined
				UpdateSequenceUI()
				NiActorSeqTagsRollout.UpdateSequenceTagsUI()
				bAdd = true
			)
			
			if bAdd == false do
			(
				message = "Cannot move the Start frame to the specified time.\nThe time either conflicts with a subsequent key or is later than the end key"
				messagebox message title:"Start Frame failure"
				spnStartFrame.value = ActiveSequence.time
				return true
			)		
		)
		
		on btnRecordEndFrame pressed do
		(
			frame = sliderTime
			if frame == ActiveSequenceEnd.time then return true
			bAdd = false
			if CanSetActiveSequenceTime ActiveSequence.time frame do
			(
				seqIndex = GetStartKeyIndex ActiveNoteTrack ActiveSequence
				ActiveSequenceEnd.time = frame
				ActiveSequence = GetStartKey ActiveNoteTrack seqIndex
				ActiveSequenceEnd = GetEndKey ActiveNoteTrack ActiveSequence
				setsliderTime ActiveSequence.time
				spnEndFrame.value = frame
				bAdd = true
				ActiveMorphKeyTime = undefined
                ActiveMorphKeyText = undefined
                ActiveInfoKeyTime = undefined
                ActiveInfoKeyText = undefined
				UpdateSequenceUI()
				NiActorSeqTagsRollout.UpdateSequenceTagsUI()
			)
			
			if bAdd == false do
			(
				message = "Cannot move the End frame to the specified time.\nThe time either conflicts with a subsequent key or is earlier than the start key"
				messagebox message title:"Set End Frame failure"
				spnEndFrame.value = ActiveSequenceEnd.time
				return true
			)
		)
		
		on editSeqName changed text do
		(
			if ActiveSequence == undefined then return true
			name = GetSequenceName ActiveSequence
			if name == text then return true
			
			local finaltext = ""
			textwords = filterstring text " \t\n#@!%^&*()+=[]{}\|:;\"'<>,.?/~`"
			print textwords
			bHadToReviseText = false
			if textwords.count == 1 then finaltext = textwords[1]
			if textwords.count > 1 do
			(			
				finaltext = ""
				for i = 1 to textwords.count do
				(
					if i == textwords.count then 
						finaltext = finaltext + textwords[i] 
					else
						finaltext = finaltext + textwords[i] + "_" 
				)
				print "Had to revise text: "
				print finaltext
				bHadToReviseText = true
			)
			if text[text.count-1] == ' ' then finaltext = finaltext + "_"

			ddlSequences.selected = finaltext
			print finaltext
			items = filterstring ActiveSequence.value " "

			value = ""
			ignoreindex = 0
			for i = 1 to items.count do
			(
				item = items[i]
				bAppend = true
				if (EqualsNoCase item "-name") then bAppend = false
				if i == ignoreindex then continue 
				item = item + " "
				if bAppend == true then value = value + item
				if bAppend == false do
				(
					value = value + "-name " + finaltext + " "
					ignoreindex = i + 1
				)
			)
			print value
			ActiveSequence.value = value
			
			-- now find sequence tags in object's notetracks and rename
			ChildArray = #()
			GetAllChildren ActorRoot ChildArray
			-- replace name with finaltext
			for Child in ChildArray do
			(
				if hasNoteTracks Child then
				(
					for i = 1 to numNoteTracks Child do
					(
						Notes = getNoteTrack Child i
						if Notes != undefined then
						(
							for Key in Notes.keys do
							(
								searchString = "-" + name + "Ratio"
								oldLength = searchString.count
								-- find out if the old sequence name is in the key
								-- if it has a dash, it is a compression override
								index = findString Key.value searchString
								if index != undefined then
								(
									-- replace the sequence name
									value = replace Key.value index oldLength ("-" + finaltext + "Ratio")
									Key.value = value
								)
								searchString = "-" + name + "DontCompress"
								oldLength = searchString.count
								index = findString Key.value searchString
								if index != undefined then
									Key.value = replace Key.value index oldLength ("-" + finaltext + "DontCompress")
								searchString = "-" + name + "CompressFloats"
								oldLength = searchString.count
								index = findString Key.value searchString
								if index != undefined then
									Key.value = replace Key.value index oldLength ("-" + finaltext + "CompressFloats")
							)
						)
					)
				)
			)

			if bHadToReviseText then UpdateSequenceUI()
		)
		
		on cbLooping changed state do
		(
			name = GetSequenceName ActiveSequence		
			items = filterstring ActiveSequence.value " "

			value = ""
			bLoopAdded
			for i = 1 to items.count do
			(
				item = items[i]
				bAppend = true
				if (EqualsNoCase item "-loop") then bAppend = false 
			    item = item + " "

				if bAppend == true then value = value + item
			)
			
			if cbLooping.checked == true then 
				value = value + " -loop"
			ActiveSequence.value = value
		)
		
		on spnStartFrame changed frame do
		(
			bAdd = false
			if CanSetActiveSequenceTime frame ActiveSequenceEnd.time do
			(
				seqIndex = GetStartKeyIndex ActiveNoteTrack ActiveSequence
				ActiveSequence.time = frame
				ActiveSequence = GetStartKey ActiveNoteTrack seqIndex
				ActiveSequenceEnd = GetEndKey ActiveNoteTrack ActiveSequence
				setsliderTime ActiveSequence.time
				ActiveMorphKeyTime = undefined
                ActiveMorphKeyText = undefined
                ActiveInfoKeyTime = undefined
                ActiveInfoKeyText = undefined
				UpdateSequenceUI()
				NiActorSeqTagsRollout.UpdateSequenceTagsUI()
				bAdd = true
			)
			
			if bAdd == false do
			(
				message = "Cannot move the Start frame to the specified time.\nThe time either conflicts with a subsequent key or is later than the end key"
				messagebox message title:"Start Frame failure"
				spnStartFrame.value = ActiveSequence.time
				return true
			)
		)
		
		on spnEndFrame changed frame do
		(
			bAdd = false
			if CanSetActiveSequenceTime ActiveSequence.time frame do
			(
			    seqIndex = GetStartKeyIndex ActiveNoteTrack ActiveSequence
				ActiveSequenceEnd.time = frame
				ActiveSequence = GetStartKey ActiveNoteTrack seqIndex
				ActiveSequenceEnd = GetEndKey ActiveNoteTrack ActiveSequence
				setsliderTime ActiveSequence.time
				bAdd = true
				ActiveMorphKeyTime = undefined
                ActiveMorphKeyText = undefined
                ActiveInfoKeyTime = undefined
                ActiveInfoKeyText = undefined
				UpdateSequenceUI()
				NiActorSeqTagsRollout.UpdateSequenceTagsUI()
			)
			
			if bAdd == false do
			(
				message = "Cannot move the End frame to the specified time.\nThe time either conflicts with a subsequent key or is earlier than the start key"
				messagebox message title:"Set End Frame failure"
				spnEndFrame.value = ActiveSequenceEnd.time
				return true
			)
		)
		
	)
	
	rollout NiActorLayerRollout "Active Layer"  
	(
		group "Layer"
		(
			dropdownlist ddLayer_Root "Known Layer Roots:" items:#("NONE") selection:1 width:120 align:#center  enabled:false
			pickbutton btnAddLayer_Root "Add" align:#center width:55 across:2 enabled:false
			button btnRemLayer_Root "Remove" align:#center width:55 enabled:false
		)
		
		function RefreshLayer_Roots obj=
		(
			nt = GetActorNoteTrack obj
			if nt != undefined do
			(
				append AllLayer_Roots obj
			)
			
			for child in obj.children do 			(
				RefreshLayer_Roots child
			)
		)
		
		function UpdateLayerGroupUI =
		(
			if Layer_Root == undefined and ActorRoot != undefined then
				Layer_Root = ActorRoot
		
			if Layer_Root != undefined do
			(
				AllLayer_Roots = #()
				RefreshLayer_Roots ActorRoot
				print AllLayer_Roots
				ddLayer_Root.items = GetNameArrayFromObjArray AllLayer_Roots
				
				index = 1
				for layer in AllLayer_Roots do
				(
					if layer == Layer_Root then ddLayer_Root.selection = index
					index = index + 1
				)
				
				print "Updating layer UI..."
				ddLayer_Root.enabled = true
				btnAddLayer_Root.enabled = true
				btnRemLayer_Root.enabled = true
				select Layer_Root
				NiActorSequenceRollout.UpdateSequenceUI()
				
			)	
			
			if Layer_Root == undefined do
			(
				AllLayer_Roots = #()
				ddLayer_Root.items = #("None")
				ddLayer_Root.enabled = false
				btnAddLayer_Root.enabled = false
				btnRemLayer_Root.enabled = false
				ActiveSequence = undefined
				ActiveSequenceEnd = undefined
				ActiveInfoKeyTime = undefined
				ActiveInfoKeyText = undefined
				ActiveMorphKeyTime = undefined
				ActiveMorphKeyText = undefined
				ActiveNoteTrack = undefined
				NiActorSequenceRollout.UpdateSequenceUI()					
			)
		)
		
		
		on btnAddLayer_Root picked obj do
		(
			bCanDo = ParentIsActor ActorRoot obj
			if bCanDo == true do
			(
				nt = MakeActorNoteTrack obj
				Layer_Root = obj
				ActiveSequence = undefined
				ActiveSequenceEnd = undefined
				ActiveInfoKeyTime = undefined
				ActiveInfoKeyText = undefined
				ActiveMorphKeyTime = undefined
				ActiveMorphKeyText = undefined
				ActiveNoteTrack = undefined
				UpdateLayerGroupUI()
				select Layer_Root
			)
			if bCanDo == false do
			(
				message = "Object \"" + obj.name + "\" does not have Actor \"" + ActorRoot.name + "\" as a parent!"
				messagebox message title:"Add Layer Root Error!"
			)
		)
		
		on btnRemLayer_Root pressed do
		(
			if Layer_Root == ActorRoot do
			(
				message = "Cannot remove the topmost layer root!\nTo do this, you must remove the Actor root."
				messagebox message title:"Remove Layer Root Error!"
				return true
			)
			
			RemoveActorNoteTrack Layer_Root
			Layer_Root = ActorRoot
			ActiveSequence = undefined
			ActiveSequenceEnd = undefined
			ActiveNoteTrack = undefined
			UpdateLayerGroupUI()
		)
		
		on ddLayer_Root selected item do
		(
			name = ddLayer_Root.items[item]
			for obj in AllLayer_Roots do
			(
				if obj.name == name do
				(
					Layer_Root = obj
					str = "layer root: " + obj.name
					print str
					ActiveSequence = undefined
					ActiveSequenceEnd = undefined
					ActiveNoteTrack = undefined
					ActiveInfoKeyTime = undefined
					ActiveInfoKeyText = undefined
					ActiveMorphKeyTime = undefined
					ActiveMorphKeyText = undefined
					
					NiActorSequenceRollout.UpdateSequenceUI()
					select Layer_Root
					return true
				)
			)
		)
		
		on NiActorLayerRollout open do
		(
			UpdateLayerGroupUI()
		)
	)		
	
	rollout NiActorManagerRollout "Actors"  
	(
		button btnRefreshAll "Refresh All" width:150
			
		group "Actor"
		(
			dropdownlist ddActorRoot "Known Actor Roots:" items:#("NONE") selection:1 width:120 align:#center 
			pickbutton btnAddActorRoot "Add" align:#center width:55 across:2 
			button btnRemActorRoot "Remove" align:#center width:55
			
			label lblAccumRoot "Accumulation Root:" width:120 align:#left enabled:false
			label lblAccumRootName "NONE" width:120 align:#center  enabled:false
			pickbutton btnSetAccumRoot "Pick" align:#center width:55 across:2 enabled:false
			button btnResetAccumRoot "Default" align:#center width:55 enabled:false
			
		)
			
		function MakeAccumRoot obj =
		(
			setUserProp obj strAccum ""
			AccumRoot = obj
		)
		
		function IsAccumRoot obj =
		(
			str = GetUserProp obj strAccum
			if str != undefined do
			(
				message =  "Is Accum Root :" + obj.name + " str: \"" + str + "\""
				print message
			)
			if str == undefined then return false else return true
		)
		
		function FindAccumRoot obj =
		(
			bIsAccum = IsAccumRoot obj
			if bIsAccum == true then return obj
			
			for child in obj.children do
			(
				result = FindAccumRoot child
				if result != undefined then return child
			)
			return undefined
		)
		
		function RemoveAccumRoot obj =
		(
			print ("Start RemoveAccumRoot for " + obj as string)
			if obj != undefined then
			(
				propBuffer = getUserPropBuffer obj
				if (findstring propBuffer strAccum) != undefined then
				(
					bufferArr = filterString propBuffer "\n"
					newBuffer = ""
					for bufLine in bufferArr do
						if (findstring bufLine strAccum) == undefined then
							newBuffer += (bufLine + "\n")
					
					setUserPropBuffer obj newBuffer
				)
				
				if (IsAccumRoot obj) then print "Uh-oh in RemoveAccumRoot!!!!"
				
				for child in obj.children do
					RemoveAccumRoot child
			)
		)
		
		function UpdateActorGroupUI =
		(
			if ActorRoot != undefined do
			(
				ddActorRoot.items = GetNameArrayFromObjArray AllActorRoots
				index = 1;
				for actor in AllActorRoots do
				(
					if actor == ActorRoot do
					(
						ddActorRoot.selection = index
					)
					index = index + 1
				)
				
				AccumRoot = FindAccumRoot ActorRoot
				if AccumRoot == undefined then MakeAccumRoot ActorRoot
				lblAccumRootName.caption = AccumRoot.name
				lblAccumRootName.enabled = true
				lblAccumRoot.enabled = true
				btnSetAccumRoot.enabled = true
				btnResetAccumRoot.enabled = true
				
				NiActorLayerRollout.UpdateLayerGroupUI()
			)
			if ActorRoot == undefined do
			(
				ddActorRoot.items = #("None")
				AccumRoot = undefined
				lblAccumRootName.caption = "None"
				lblAccumRootName.enabled = false
				lblAccumRoot.enabled = false
				btnSetAccumRoot.enabled = false
				btnResetAccumRoot.enabled = false
				
				NiActorLayerRollout.UpdateLayerGroupUI()
			)
		)
		
		
		function RefreshAll =
		(
			AllActorRoots = #()
			GetActorRoots rootNode AllActorRoots
			if AllActorRoots.count == 0 then 
				ActorRoot = undefined
			else
				ActorRoot = AllActorRoots[1]
			Layer_Root = undefined
			AllLayer_Roots = #()
			ActiveSequence = undefined
			ActiveSequenceEnd = undefined
			ActiveNoteTrack = undefined
			ActiveInfoKeyTime = undefined
			ActiveInfoKeyText = undefined
			ActiveMorphKeyTime = undefined
			ActiveMorphKeyText = undefined
			UpdateActorGroupUI()
		)

		on btnRefreshAll pressed do
		(
			RefreshAll()
		)

		function CanCreateActorRoot obj =
		(
			bCanAdd = true
			for actor in AllActorRoots do
			(
				if actor == obj then bCanAdd = false
			)
			parent = obj.parent
			
			while parent != undefined do
			(
				nt = GetActorNoteTrack parent
				if nt != undefined then bCanAdd = false	
				parent = parent.parent
			)
			
			return bCanAdd
		) 
		
		function MakeActorRoot obj = 
		(
			MakeActorNoteTrack obj
			select obj
			append AllActorRoots obj
			MakeAccumRoot obj
			b = IsAccumRoot obj
			ActorRoot = obj
			Layer_Root = obj
			ActiveSequence = undefined
			ActiveSequenceEnd = undefined
			ActiveNoteTrack = undefined
			ActiveInfoKeyTime = undefined
			ActiveInfoKeyText = undefined
			ActiveMorphKeyTime = undefined
			ActiveMorphKeyText = undefined
			if b == false then print "Error in MakeActorRoot: Object is not an AccumRoot."
			-- set a key at time zero with the global compression values stored
			nt = GetActorNoteTrack obj
			if nt != undefined then
			(
				index = getNoteKeyIndex nt 0
				if index == undefined then
				(
					Key = addNewNoteKey nt.keys 0
					SetSequenceData Key "-GlobalRatio" 100
					SetSequenceData Key "-GlobalCompressFloats" true
					SetSequenceData Key "-GlobalDontCompress" false
				)
				else
				(
					Key = nt.keys[Index]
					ratio = GetSequenceData Key "-GlobalRatio"
					compressFloats = GetSequenceData Key "-GlobalCompressFloats"
					dontCompress = GetSequenceData Key "-GlobalDontCompress"
					
					if ratio == undefined then
						SetSequenceData Key "-GlobalRatio" 100
					if compressFloats == undefined then
						SetSequenceData Key "-GlobalCompressFloats" true
					if dontCompress == undefined then
						SetSequenceData Key "-GlobalDontCompress" false
				)
			)
		)
		
		on ddActorRoot selected itemnumber do
		(
			name = ddActorRoot.items[itemnumber]
			for root in AllActorRoots do
			(
				if root.name == name do
				( 
					ActorRoot = root
					str =  "Actor Root: " + ActorRoot.name
					print str
					AccumRoot = FindAccumRoot ActorRoot
					if AccumRoot == undefined then MakeAccumRoot ActorRoot
					str = "Accum Root: "+ AccumRoot.name
					print str
					Layer_Root = ActorRoot
					ActiveSequence = undefined
					ActiveSequenceEnd = undefined
					ActiveNoteTrack = undefined
					ActiveInfoKeyTime = undefined
					ActiveInfoKeyText = undefined
					ActiveMorphKeyTime = undefined
					ActiveMorphKeyText = undefined
					UpdateActorGroupUI()
					select ActorRoot
				)
			)
		)
		
		on btnAddActorRoot picked obj do
		(
			bResult = CanCreateActorRoot obj
			if bResult == true do
			(
				print "Creating actor root!"
				print obj.name

				MakeActorRoot obj
				UpdateActorGroupUI()
				select ActorRoot
			)
			if bResult == false do
			(

				str = "Cannot add \"" + obj.name + "\" as an actor root.\nThis is because the object has a parent that is an actor root or it is already an actor root\n"
				messagebox str title:"Add Actor Root Error"
			)
		)
		
		on btnRemActorRoot pressed do
		(
			if ActorRoot != undefined do
			(
				nt = GetActorNoteTrack ActorRoot

				if nt != undefined do
				(
					print "Deleting note track"
					deletenotetrack ActorRoot nt
				)
				RemoveAccumRoot ActorRoot
				RefreshAll()
			)
		)
		
		on btnSetAccumRoot picked obj do
		(
			parent = obj

			bCanAdd = false	
			bFoundCurrentActorRoot = false		
			while parent != undefined do
			(
				nt = GetActorNoteTrack parent
				if nt != undefined then bCanAdd = true
				if parent == ActorRoot then bFoundCurrentActorRoot = true		
				parent = parent.parent
			)

			if bCanAdd == true and bFoundCurrentActorRoot == true do
			(
				RemoveAccumRoot AccumRoot
				MakeAccumRoot obj
				UpdateActorGroupUI()
			)
			
			if bCanAdd == false do
			(
				str = "Cannot add \"" + obj.name + "\" as an accumulation root.\nThis is because the object isn't the current Actor Root or it is not a child of the Actor Root!\n"
				messagebox str title:"Add Accumulation Root Error"
			)
		)
		
		on btnResetAccumRoot pressed do
		(
			RemoveAccumRoot AccumRoot
			MakeAccumRoot ActorRoot
			UpdateActorGroupUI()
		)

		on NiActorManagerRollout open do
		(
			RefreshAll()
		)

        on NiActorManagerRollout close do
        (
            try(callbacks.removeScripts #filePreOpen id:#ActorManagerUtilPreOpen);catch()
	        try(callbacks.removeScripts #filePostOpen id:#ActorManagerUtilPostOpen);catch()	
            try(callbacks.removeScripts #systemPreReset id:#ActorManagerUtilPreReset);catch()
	            
        )
		
	)
	
	