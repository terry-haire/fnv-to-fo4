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

function FindBlankKey nt time =
(
	if nt != undefined do
	(
		for key in nt.keys do
		(
			if key.time == time do
			(
				if key.value == "" then return key
			)
		)
	)
	
	return undefined
)
	
function CreateNoteKey nt time =
(
	blankKey = FindBlankKey nt time
	
	if blankKey == undefined do
	(
		NiAddBlankNoteKey nt time
		blankKey = FindBlankKey nt time
	)
	
	print "blankKey = "
	print blankKey
	print "\n"
	return blankKey
)

function SetSliderTime time =
(
	lastTime = time
	sliderTime = time
)

function uppercase instring = 
(
	-- this function converts instring to all capitol letters
	-- so that we can do a case-insensitive compare
	local upper, lower, outstring
	upper="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	lower="abcdefghijklmnopqrstuvwxyz" 
	outstring = copy instring 

	for i = 1 to outstring.count do 
	(
		j = findString lower outstring[i] 
		if (j != undefined) do outstring[i] = upper[j] 
	)
	outstring
)

function EqualsNoCase instring outstring =
(
	local string1 = uppercase instring
	local string2 = uppercase outstring
	return string1 == string2
)

function GetActorNoteTrack node =
(
	if hasNoteTracks node do
	(
		for i = 1 to numnotetracks node do
		(
			nt = getnotetrack node i
			if nt != undefined do
			(
				for key in nt.keys do
				(
					foundValue = findstring key.value "start"
					if foundValue != undefined do
					(
						 return nt
					)
				)
			)
		)
	)
	return undefined
)

function SetSimpleStartKey nt name time bLoop=
(
	key = CreateNoteKey nt time
	value = "start -name " + name
	if bLoop == true then  value = value + " -loop"
	key.value = value
	return key
)

function SetTopLevelStartKey nt name time bAccum bAccumRots AccumRotState bAccumTrans bXAx bYAx bZAx ActorFaces =
(
	key = CreateNoteKey nt time
	value = "start -name " + name
	if bLoop == true then value = value + " -loop"
	if bAccum == true do
	(
		if bAccumRots == true do
		(
			value = value + " -ar "
			bAdded = false
			if AccumRotState == "X Axis" do
			(
				value = value + "x "
				bAdded = true
			)
				
			if AccumRotState == "Y Axis" do
			(
				value = value + "y "
				bAdded = true
			)

			if AccumRotState == "Z Axis" or AccumRotState == "All Axes" do
			(
				if AccumRotState == "Z Axis" then value = value + "z "
				if AccumRotState == "All Axes" then value = value + "all "
				
				value = value + " -front "
				if ActorFaces == "X Axis" then value = value + "x "
				if ActorFaces == "Negative X Axis" then value = value + "negx "
				if ActorFaces == "Y Axis" then value = value + "y "
				if ActorFaces == "Negative Y Axis" then value = value + "negy "
				bAdded = true
			)
						
			if bAdded == false do
			(
				value = value + "none "
			)
		)
		
		if bAccumTrans == true do
		(
			value = value + " -at "
			bAdded = false
			
			if bXAx == true do 
			(
				value = value + "x "
				bAdded = true
			)
			if bYAx == true do 
			(
				value = value + "y "
				bAdded = true
			)
			if bZAx == true do
			(
				value = value + "z "
				bAdded = true
			)
			
			if bAdded == false do
			(
				value = value + "none "
			)
		)
	)
	if bAccum == false do
	(
		value = value + " -at none -ar none"
	)
	key.value = value
	return key 

)

function SetSimpleEndKey nt time =
(
	key = CreateNoteKey nt time
	value = "end"
	key.value = value
	return key 
)

function MakeActorNoteTrack node =
(
	nt = GetActorNoteTrack node
	if nt != undefined then return nt
	
	nt = notetrack "ActorManager"
	addNoteTrack node nt
	strNewSeqName = "EMPTY_SEQUENCE_AT_" + (sliderTime as string) 
	SetSimpleStartKey nt strNewSeqName animationRange.start false
	SetSimpleEndKey nt animationRange.end
)

function RemoveActorNoteTrack node =
(
	nt = GetActorNoteTrack node
	if nt == undefined then return false
	
	deletenotetrack node nt
)

function GetActorRoots Parent RootArray =
(
	for Object in Parent.children do
	(
		if hasNoteTracks Object then
		(
			for i = 1 to numNoteTracks Object do
			(
				Notes = getNoteTrack Object i
				for key in Notes.keys do
				(
					retVal = findString key.value "start"
					if retVal != undefined then
					(
						append RootArray Object
						exit
					)
				)
			)
		)
		else
			GetActorRoots Object RootArray
	)
)

function GetLayerRootsUp Object RootArray = 
(
	-- search the heirarchy above the object for anything with a note track
	-- this method is recursive
	if Object.parent != undefined then
	(
		GetLayerRootsUp Object.parent RootArray
	)
	-- see if it has a note track
	if hasNoteTracks Object then
	(
		append RootArray Object
	)
)

function GetLayerRootsDown Object RootArray =
(
	-- search the heriarchy below the object for anything with a sequence note track
	-- this method is recursive
	if hasNoteTracks Object then
	(
		for i = 1 to numNoteTracks Object do
		(
			Notes = getNoteTrack Object i
			for key in Notes.keys do
			(
				retVal = findString key.value "start"
				if retVal != undefined then
				(
					append RootArray Object
					exit
				)
			)
		)
	)
	-- search all of the children
	for Child in Object.children do
	(
		GetLayerRootsDown Child RootArray
	)
)

function GetStartKey nt index =
(
	if nt == undefined then return undefined
	i = 0
	for key in nt.keys do
	(
		foundValue = findstring key.value "start"
 			if foundValue != undefined do
		(
			i = i + 1
			if i == index then return key
		)
	)
	return undefined
)

function GetSequenceCount nt = 
(
	if nt == undefined then return 0
	index = 1
	count = 0
	key = GetStartKey nt index
	while key != undefined do
	(
		count = count + 1
		index = index + 1
		key = GetStartKey nt index
	)
	return count
)

function GetStartKeyIndex nt ActiveKey =
(
	if nt == undefined then return 0
	i = 0
	for key in nt.keys do
	(
		foundValue = findstring key.value "start"
		if foundValue != undefined do
		(
			i = i + 1
			if ActiveKey.value == key.value then return i
		)
	)
	return 0
)

function GetEndKey nt StartKey = 
(
	print "Get End Key"
	print nt
	if nt == undefined or StartKey == undefined then return undefined
	index = 1
	startIdx = 0
	for key in nt.keys do
	(
		print ("Index = " + (index as string))
		print key.value
		if key.value == startKey.value do
		( 
			startIdx = index
			print "found start index..."
		)
		
		foundIdx = findString key.value "end"
		if startIdx == 0 do
		(
			index = index + 1
			continue
		)			
		if foundIdx == undefined do
		(
			index = index + 1
			continue
		)
		if foundIdx != 1 do
		(
			index = index + 1
			continue
		)			
		if foundIdx == 1 do
		(
			print "Found end key"
			print key
			return key
		) 
	)
	return undefined		
)

function GetSequenceName key = 
(
	if key != undefined then
	(
		strings = filterstring key.value " "
		index = 1
		for string in strings do
		(
			bEquals = EqualsNoCase string "-name"
			if bEquals then return strings[index+1] 
			index = index + 1
		)
	)
	else
		return undefined
)

function GetSequenceLoop key =
(
	strings = filterstring key.value " "
	index = 1
	for string in strings do
	(
		bEquals = EqualsNoCase string "-loop"
		if bEquals then return true 
		index = index + 1
	)
	return false
)

function GetSequenceAccumTrans key =
(
	strings = filterstring key.value " "
	index = 1
	for string in strings do
	(
		bEquals = EqualsNoCase string "-at"
		if bEquals do
		(
			return strings[index + 1]
		) 
		index = index + 1
	)
	return "none"
)

function GetSequenceAccumRot key =
(
	strings = filterstring key.value " "
	index = 1
	for string in strings do
	(
		bEquals = EqualsNoCase string "-ar"
		if bEquals do
		(
			return strings[index + 1]
		) 
		index = index + 1
	)
	return "none"
)

function GetSequenceFront key =
(
	strings = filterstring key.value " "
	index = 1
	for string in strings do
	(
		bEquals = EqualsNoCase string "-front"
		if bEquals do
		(
			return strings[index + 1]
		) 
		index = index + 1
	)
	return "X Axis"	
)

function GetSequenceData key dataName =
(
	if key != undefined then
	(
		strings = filterstring key.value " "
		index = 1
		for string in strings do
		(
			bEquals = EqualsNoCase string dataName
			if bEquals do
			(
				return strings[index + 1]
			) 
			index = index + 1
		)
	)
	return undefined	
)

function SetSequenceData key dataName newValue =
(
	if key != undefined then
	(
		index = findString key.value dataName
		length = dataName.count 
		
		if index != undefined then
		(
			-- find the value part
			startIndex = (index + length + 1)
			tempString = substring key.value startIndex -1
			endIndex = findString tempString " "
			if endIndex != undefined then
				value = replace key.value startIndex endIndex ((newValue as string) + " ")
			else
				value = replace key.value startIndex (key.value.count - startIndex + 1) (newValue as string)
			key.value = value
		)
		else
		(
			-- append that data on to the end
			key.value += " " + dataName + " " + (newValue as string)
		)
	)
)

function DeleteSequenceData key dataName =
(
	if key != undefined then
	(
		index = findString key.value dataName
		length = dataName.count
		
		if index != undefined then
		(
			-- find the index of the value
			valueIndex = (index + length + 1)
			tempString = substring key.value valueIndex -1
			endIndex = findString tempString " "
			if endIndex != undefined then
				value = replace key.value (index - 1) (length + endIndex + 1) ""
			else
				value = replace key.value (index - 1) (key.value.count - index + 2) ""
			key.value = value
		)
	)
)

function GetSequenceList Object =
(
	-- given a root, find all the available sequences
	-- returns an array of strings that are sequence names
	-- if there are no sequences, it returns undefined
	if hasNoteTracks Object then
	(
		ReturnList = #()
		for i = 1 to GetSequenceCount (GetActorNoteTrack Object) do
		(
			StartKey = GetStartKey (GetActorNoteTrack Object) i
			KeyName = GetSequenceName StartKey
			if KeyName != undefined then
			(
				append ReturnList KeyName
			)
		)
		return ReturnList
	)
	return undefined
)

function GetMorphKey nt time =
(
	if nt == undefined then return #()
	AllKeys = #()
	
	for key in nt.keys do
	(
		if key.time == time do
		(
			foundMorph = findstring key.value "morph: "
			if foundMorph != undefined and foundMorph == 1 do
			(
				append AllKeys key
			)
		)
	)
	return AllKeys
)

function GetInfoKey nt time =
(
	if nt == undefined then return #()
	AllKeys = #()
	for key in nt.keys do
	(
		if key.time == time do
		(
			foundMorph = findstring key.value "morph: "
			if foundMorph != undefined then continue
			foundStart = findstring key.value "start"
			if foundStart != undefined and foundStart == 1 then continue
			foundEnd = findstring key.value "end"
			if foundEnd != undefined and foundEnd == 1 then continue
			append AllKeys key
		)
	)
	
	return AllKeys
)

function GetNameArrayFromObjArray objarray =
(
	nameArray = #()
	for obj in objarray do
	(
		if obj != undefined then append nameArray obj.name
	)
	return nameArray
)

function ParentIsActor actor obj =
(
	if obj == actor then return true
	parent = obj.parent
	while parent != undefined do
	(
		if parent == actor then return true
		parent = parent.parent
	)
	
	return false
)

function GetAllChildren parent ObjectArray =
(
	append ObjectArray parent
	for Object in parent.children do
	(
		GetAllChildren Object ObjectArray
	)
)
