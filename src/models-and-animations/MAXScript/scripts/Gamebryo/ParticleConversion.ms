
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


bSave = getSaveRequired() 
include "Gamebryo/ConvertCAHelpers.ms"
particleCAArray = #()

fn CalcPSysMax obj =
(
    if (isKindOf obj Snow) then obj.NiPSysMaxAlloc = obj.viewportcount
    if (isKindOf obj Spray) then obj.NiPSysMaxAlloc = obj.viewportcount 

    if (isKindOf obj PArray) or (isKindOf obj PCloud) or (isKindOf obj SuperSpray) or (isKindOf obj Blizzard) do
    (
	    if obj.quantityMethod == 1 then obj.NiPSysMaxAlloc = obj.Total_Number
	    if obj.quantityMethod == 0 then obj.NiPSysMaxAlloc = (obj.Emitter_Stop - obj.Emitter_Start) * obj.Birth_Rate

	    if obj.NiPSysMaxAlloc == 0 then obj.NiPSysMaxAlloc = 100

	    if (obj.spawnType > 0 ) then obj.NiPSysMaxAlloc = obj.NiPSysMaxAlloc * 2

	    if obj.NiPSysUseViewport == true then obj.NiPSysMaxAlloc = obj.NiPSysMaxAlloc * (obj.viewPercent / 100.0)
    )
)

fn AddToParticleCAArray obj =
(
	if obj != undefined then
	(
		append particleCAArray obj
	)
)

HaveUserPermission = false
bDefined = false
DefinedPSysCA = undefined

for obj in objects do
(
	if obj != undefined do
	(
		bConvert = false
		if (isKindOf obj PArray) then bConvert = true
		if (isKindOf obj PCloud) then bConvert = true	
		if (isKindOf obj SuperSpray) then bConvert = true
		if (isKindOf obj Blizzard) then bConvert = true
		if (isKindOf obj Snow) then bConvert = true
		if (isKindOf obj Spray) then bConvert = true
    	

		if bConvert == true do
		(
			if DefinedPSysCA == undefined do
			(
				include "Gamebryo/ParticleSystemCA.ms"
	 			DefinedPSysCA = ParticleSystemCA
			)
    		
			iCACount = custAttributes.count obj
			iFoundIndex = -1
			for i = 1 to iCACount do
			(
				TempCA = custAttributes.getdef obj i
				if TempCA != undefined and TempCA.name == DefinedPSysCA.name do
				(
					iFoundIndex = i
				)
				if TempCA != undefined and TempCA.name == "ParticleSystemCA" do
				(
					iFoundIndex = i
				)
			) 

			if iFoundIndex >= 0 do
			(
				TempAttribute = custAttributes.get obj iFoundIndex
				TempCA = custAttributes.getdef obj iFoundIndex
				for updatedCA in particleCAArray do
				(
					if updatedCA == TempAttribute then
					(
						if (isKindOf obj PArray) or (isKindOf obj PCloud) or
							(isKindOf obj Blizzard) or (isKindOf obj SuperSpray) then
						(
							if obj.particleType == 0 then	--standard (sprite) particles
							(
								if (obj.size.isAnimated == false) then
								(
									obj.size *= 0.5
								)
							)
							else -- if particle type is other than sprite
							(
								-- translate the spin time and spin time variation parameters to
								-- their gamebryo rotation speed and rotation speed var equivalent
								if (obj.Spin_Time != 0) then
								(
									obj.NiPSysRotationSpeed = -(ticksPerFrame * frameRate * 360) / (obj.Spin_Time as Float)
									obj.NiPSysRotationVariation = (abs obj.NiPSysRotationSpeed) *
										(obj.Spin_Time_Variation / 100)
								)
								else
								(
									obj.NiPSysRotationSpeed = 0
									obj.NiPSysRotationVariation = 0
								)
							) -- end if particle type is sprite
						)
						else if (isKindOf obj Snow) then
						(
							-- convert flakesize
							if (obj.flakesize.isAnimated == false) then
							(
								obj.flakesize *= 0.5
							)
						)
						else if (isKindOf obj Spray) then
						(
							-- convert dropsize
							if (obj.dropsize.isAnimated == false) then
							(
								obj.dropsize *= 0.5
							)
						)
					) -- end if updatedCA == TempAttribute
				)
				if TempCA.source != DefinedPSysCA.source do
				(
					if TempCA.attribID == DefinedPSysCA.attribID do
					(
						custAttributes.redefine TempCA DefinedPSysCA.source
						bSave = true
					)
					if TempCA.attribID != DefinedPSysCA.attribID do
					(
					    TempNiPSysLoop = true
						TempNiPSysLoopStart = 0 
						TempNiPSysLoopEnd = 10
						TempNiPSysUseViewport = true
						TempNiPSysResetOnLoop = false
						TempNiPSysMaxAlloc = 0
						TempNiPSysLocalCoords = false
						TempNiPSysBoundsUpdateType = 1
						TempNiPSysDynamicBoundsSkip = 1
						TempNiPSysBoundPosition	= [0.0,0.0,0.0]
						TempNiPSysBoundRadius = 1.0	
						TempNiPSysParentNode   = undefined
						
						-- version 1 data conversion
						tempValue = NiGetCustAttrib obj "NiPSysLoop"
						if tempValue != undefined then TempNiPSysLoop = tempValue
						
						tempValue = NiGetCustAttrib obj "NiPSysLoopStart"
						if tempValue != undefined then TempNiPSysLoopStart = tempValue
						
						tempValue = NiGetCustAttrib obj "NiPSysLoopEnd"
						if tempValue != undefined then TempNiPSysLoopEnd = tempValue
						
						tempValue = NiGetCustAttrib obj "NiPSysUseViewport"
						if tempValue != undefined then TempNiPSysUseViewport = tempValue
						
						tempValue = NiGetCustAttrib obj "NiPSysResetOnLoop"
						if tempValue != undefined then TempNiPSysResetOnLoop = tempValue
						
						tempValue = NiGetCustAttrib obj "NiPSysMaxAlloc"
						if tempValue != undefined then TempNiPSysMaxAlloc = tempValue
						
						-- version 4
						tempValue = NiGetCustAttrib obj "NiPSysLocalCoords"
						if tempValue != undefined then TempNiPSysLocalCoords = tempValue
						
						tempValue = NiGetCustAttrib obj "NiPSysBoundsUpdateType"
						if tempValue != undefined then TempNiPSysBoundsUpdateType = tempValue
						
						tempValue = NiGetCustAttrib obj "NiPSysDynamicBoundsSkip"
						if tempValue != undefined then TempNiPSysDynamicBoundsSkip = tempValue
						
						tempValue = NiGetCustAttrib obj "NiPSysBoundPosition"
						if tempValue != undefined then TempNiPSysBoundPosition = tempValue
						
						tempValue = NiGetCustAttrib obj "NiPSysBoundRadius"
						if tempValue != undefined then TempNiPSysBoundRadius = tempValue
						
						tempValue = NiGetCustAttrib obj "NiPSysParentNode"
						if tempValue != undefined then TempNiPSysParentNode = tempValue
					    
						custAttributes.delete obj TempCA
						custAttributes.add obj DefinedPSysCA
						obj.NiPSysLoop = TempNiPSysLoop
						obj.NiPSysLoopStart = TempNiPSysLoopStart
						obj.NiPSysLoopEnd = TempNiPSysLoopEnd
						obj.NiPSysUseViewport = TempNiPSysUseViewport
						obj.NiPSysResetOnLoop = TempNiPSysResetOnLoop
						obj.NiPSysMaxAlloc = TempNiPSysMaxAlloc
						obj.NiPSysLocalCoords = TempNiPSysLocalCoords
						obj.NiPSysBoundsUpdateType = TempNiPSysBoundsUpdateType
						obj.NiPSysDynamicBoundsSkip = TempNiPSysDynamicBoundsSkip
						obj.NiPSysBoundPosition = TempNiPSysBoundPosition
						obj.NiPSysBoundRadius = TempNiPSysBoundRadius
						obj.NiPSysParentNode = TempNiPSysParentNode
						
						if (isKindOf obj PArray) or (isKindOf obj PCloud) or 
							(isKindOf obj Blizzard) or (isKindOf obj SuperSpray) then
						(
							if obj.particleType == 0 then	--standard (sprite) particles
							(
								if (obj.size.isAnimated == false) then
								(
									obj.size *= 0.5
								)
							)
							else -- if obj.particleType != 0 then
							(
								-- translate the spin time and spin time variation parameters to
								-- their gamebryo rotation speed and rotation speed var equivalent
								obj.NiPSysRotationSpeed = -(frameRate * 360) / obj.Spin_Time
								obj.NiPSysRotationVariation = (abs obj.NiPSysRotationSpeed) *
									(obj.Spin_Time_Variation / 100)
							)
						)
						else if (isKindOf obj Snow) then
						(
							-- convert flakesize
							if (obj.flakesize.isAnimated == false) then
							(
								obj.flakesize *= 0.5
							)
						)
						else if (isKindOf obj Spray) then
						(
							-- convert dropsize
							if (obj.dropsize.isAnimated == false) then
							(
								obj.dropsize *= 0.5
							)
						)
						if obj.NiPSysMaxAlloc == 0 then CalcPSysMax obj
						bSave = true
					)
				)	--end if newSource != oldSource
    			
			)
			if iFoundIndex < 0 do
			(
				custAttributes.add obj DefinedPSysCA
				obj.NiPSysLoopStart = animationRange.start
				obj.NiPSysLoopEnd = animationRange.end
                bSave = true
    				
				CalcPSysMax obj
    			
				propBuffer = getUserPropBuffer obj
				print "propBuffer"
				print propBuffer
				if propBuffer != undefined do
				(
					foundZmodeIdx = findString propBuffer "zMode"
					foundPsysNodeIdx = findString propBuffer "PSysNode:"
					if foundPsysNodeIdx != undefined do
					(
						foundPsysNodeIdx = foundPsysNodeIdx + 9
						newPropBuffer = substring propBuffer foundPsysNodeIdx -1
						propStrings = filterString newPropBuffer "#"
						if propStrings != undefined do
						(
							newRootName = propStrings[1]
							newNode = getNodeByName newRootName
							if newNode != undefined do
							(
								obj.NiPSysLocalCoords = true
								obj.NiPSysParentNode = newNode 
							)
						)
					)
					if foundZmodeIdx == undefined do
					(
						print "Adding new z-buffer property to particle system."
						newPropBuffer = propBuffer + "\r\x00AzMode10"
						setUserPropBuffer obj newPropBuffer
					)
				)			
			)
		)
	)
)

CleanOldDefsByName "ParticleSystemCA"

setSaveRequired bSave 
