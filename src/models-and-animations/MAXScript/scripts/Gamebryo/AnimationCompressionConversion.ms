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

include "Gamebryo\\AnimationHelpers.ms"

-- This version of the file simply recurses the scene looking for actor roots
-- then if it finds any, it adds animation compression data if not already there

Key = undefined
ActorArray = #()
GetActorRoots rootNode ActorArray
for i = 1 to ActorArray.count do
(
	Notes = GetActorNoteTrack ActorArray[i]
	if Notes != undefined then
	(
		Index = undefined
		keyCount = NiGetNoteKeyCount Notes
		for i = 1 to keyCount do
		(
			ratio = GetSequenceData Notes.keys[i] "-GlobalRatio"
			if ratio != undefined then
			(
				Index = i
			)
		)
		if Index == undefined then
		(
			Index = getNoteKeyIndex Notes 0 -- global values are usually at time 0
		)
		if Index == undefined then
		(
			-- add a new note at time zero
			Key = addNewNoteKey Notes.keys 0
			-- set it's value
			SetSequenceData Key "-GlobalRatio" 100
			SetSequenceData Key "-GlobalCompressFloats" true
			SetSequenceData Key "-GlobalDontCompress" false
		)
		else -- if there was an existing global key
		(
			-- get values
			Key = Notes.keys[Index]
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
