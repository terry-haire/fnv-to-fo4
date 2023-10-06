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

ParticleSystemCA = attributes "ParticleSystemSettings" version:9 attribID:#(0xa33966f, 0x9c15746a)
( 

	parameters NiPSys rollout:params 
	( 
		NiPSysLoop 			type:#boolean default:true 	animatable:false	ui:chkLoop	
		NiPSysLoopStart 	type:#integer default:0 	animatable:false	ui:spnLoopStart
		NiPSysLoopEnd 		type:#integer default:10 	animatable:false	ui:spnLoopEnd
		NiPSysUseViewport	type:#boolean default:true 	animatable:false	ui:chkUseViewportRate
		NiPSysResetOnLoop	type:#boolean default:false	animatable:false	ui:chkResetOnLoop
	
		NiPSysMaxAlloc	 	type:#integer default:0 	animatable:false	ui:spnMaxAllocs
		
		NiPSysLocalCoords	type:#boolean default:false animatable:false	ui:chkUseLocalCoords
		
		NiPSysRotationSpeed	type:#float default:0		animatable:true		ui:spnRotationSpeed
		NiPSysRotationVariation	type:#float default:0	animatable:true 	ui:spnRotationVariation
		NiPSysBidirectionalRotation type:#boolean default:false animatable:false ui:chkBidirectionalRot
		
		NiPSysBoundsUpdateType  type:#integer default:1 animatable:false    ui:comboBoundsUpdateType
		NiPSysDynamicBoundsSkip type:#integer default:1 animatable:false    ui:spnDynamicBoundsSkip
		NiPSysBoundPosition	type:#point3				animatable:false 
		NiPSysBoundRadius	type:#float default:1.0		animatable:false	ui:spnBoundRadius
		
		NiPSysParentNode    type:#node					animatable:false	ui:pickParentNode
		
		NiPSysEnableHavok	type:#boolean	default:false	animatable:false	ui:enableHavok
		
		NiPSysEnableMotionInheritance	type:#boolean default:false animatable:false ui:enableMotionInheritance
	) 

	rollout params "Gamebryo Export Params" 
	( 
		group "Simulation Options"
		(
			checkbox enableMotionInheritance "Enable 'Object Motion Inheritance' Rollout" align:#left height:30 width:160
			
			checkbox enableHavok "Havok Particles"
			
			checkbox chkLoop		"Loop" align:#left
			checkbox chkResetOnLoop "Reset On Loop" align:#left
			
			spinner spnLoopStart "System Start: " range:[-99999,99999,1] type:#integer  align:#left offset:[0,8]
			spinner spnLoopEnd   "System End:  " range:[-99999,99999,1] type:#integer  align:#left

			checkbox chkUseViewportRate "Honor Viewport Counts" align:#left
			checkbox chkUseLocalCoords "Use Local Space PSystem" align:#left
			label  lblUseLocalCoords "(Move particles with parent)" offset:[15,0] align:#left
			
			label  lblParentNode "PSystem Parent Node:" offset:[0, 10] align:#center
			pickbutton pickParentNode "" across:2 width:100 message:"Choose the node you wish to move relative to." toolTip:"Choose the node you wish to move relative to." align:#right enabled:false offset:[40,0]
			button btnResetParentNode "R"  enabled:false align:#right
			
			label  lblMaxAllocs "Maximum Active Particles:" offset:[0,10] align:#center
			spinner spnMaxAllocs "" range:[0,99999,1] type:#integer  align:#center 

			button btnRecalcMaxAllocs "Re-estimate Maximum"  offset:[0,5]
		)
		
		group "Particle Rotation"
		(
			spinner spnRotationSpeed "Speed:      " range:[-36000,36000,0] type:#float align:#left
			spinner spnRotationVariation "Variation:   " range:[0,36000,0] type:#float align:#left
			label lblRotationUnits "(degrees per second)" align:#center
			checkBox chkBidirectionalRot "Bi-Directional Rotation"
		)

		group "Bounding Volume Options" 
		(
			dropdownlist comboBoundsUpdateType "Bounds Update Type:" items:#("Dynamic Bounding Volume","Static Bounding Volume") align:#left offset:[0,10]
			label  lblDynamicBoundsSkip "Update Every X Frames:" offset:[0,5] align:#left 
			spinner spnDynamicBoundsSkip "" align:#left type:#integer enabled:false range:[1,1000,1] offset:[25,0]
			
			label  lblBounds "Static Bound Position:" offset:[0,5] align:#left
			spinner spnBoundX   "X:" range:[-99999,99999,1] type:#float  align:#left enabled:false offset:[15,0]
			spinner spnBoundY   "Y:" range:[-99999,99999,1] type:#float  align:#left enabled:false offset:[15,0]
			spinner spnBoundZ   "Z:" range:[-99999,99999,1] type:#float  align:#left enabled:false offset:[15,0]
			label  lblBoundsRadius "Static Bound Radius:" align:#left enabled:false
			spinner spnBoundRadius "" range:[0,99999,1] type:#float  align:#left enabled:false offset:[25,0]
			button  btnComputeStaticBound "Use Current Frame Bounds" align:#center enabled:false 
		)
		
		on spnLoopStart changed value do
		(
			if value >= NiPSysLoopEnd do
			(
				NiPSysLoopStart = NiPSysLoopEnd - 1
			)
		)

		on spnLoopEnd changed value do
		(	
			if value <= NiPSysLoopStart do
			(
				NiPSysLoopEnd = NiPSysLoopStart + 1
			)
		)

		
		fn CalcViewportRate obj =
		(
			viewPercent = 1.0

			if (isKindOf obj PArray) or (isKindOf obj PCloud) or (isKindOf obj SuperSpray) or (isKindOf obj Blizzard) do
			(
				viewPercent = obj.viewPercent / 100.0	
			)

			if (isKindOf obj Snow) then viewPercent = (obj.rendercount as float) / (obj.viewportcount as float)
			if (isKindOf obj Spray) then viewPercent = (obj.rendercount as float) / (obj.viewportcount as float)

			return viewPercent
		)
		
		on chkUseViewportRate changed state do
		(
			local obj = $
			viewPercent = CalcViewportRate obj
			
			if state == true do
			(
				obj.NiPSysMaxAlloc = obj.NiPSysMaxAlloc * viewPercent
			)
			if state == false do
			(
				obj.NiPSysMaxAlloc = obj.NiPSysMaxAlloc / viewPercent
			)
		)

		on btnRecalcMaxAllocs pressed do
		(
			local obj = $
			setWaitCursor()
			
			sliderTimePrevious = sliderTime
			if (isKindOf obj PArray) or (isKindOf obj PCloud) or (isKindOf obj SuperSpray) or (isKindOf obj Blizzard) do
			(
			    sliderTime = obj.Emitter_Start
			)
			
			if (isKindOf obj Snow) or (isKindOf obj Spray) do
			(
			    sliderTime = obj.start
			)
			
			count = particleCount obj	
			obj.NiPSysMaxAlloc = count
			sliderTime = sliderTimePrevious

			if obj.NiPSysUseViewport == false do
			(
				viewPercent = CalcViewportRate obj
				obj.NiPSysMaxAlloc = obj.NiPSysMaxAlloc / viewPercent

			)
			setArrowCursor()

		)
		
		
		function UpdateUI =
		(
			if NiPSysBoundsUpdateType == 1 do
			(
				lblBounds.enabled = false
				spnBoundX.enabled = false
				spnBoundY.enabled = false 
				spnBoundZ.enabled = false
				spnBoundRadius.enabled = false 
				btnComputeStaticBound.enabled = false
				lblBoundsRadius.enabled = false
				
				spnDynamicBoundsSkip.enabled = true
				lblDynamicBoundsSkip.enabled = true
			)
			if NiPSysBoundsUpdateType == 2 do
			(
				lblBounds.enabled = true
				spnBoundX.enabled = true
				spnBoundY.enabled = true 
				spnBoundZ.enabled = true
				spnBoundRadius.enabled = true 
				btnComputeStaticBound.enabled = true
				lblBoundsRadius.enabled = true
				
				spnDynamicBoundsSkip.enabled = false
				lblDynamicBoundsSkip.enabled = false
			)
			
			spnBoundX.value = NiPSysBoundPosition.x
			spnBoundY.value = NiPSysBoundPosition.y
			spnBoundZ.value = NiPSysBoundPosition.z
			
			pickParentNode.enabled = NiPSysLocalCoords
			btnResetParentNode.enabled = NiPSysLocalCoords
			
			if NiPSysParentNode != undefined do
			(
				pickParentNode.caption = (NiPSysParentNode.name as string)
			)
			if NiPSysParentNode == undefined do
			(
				local obj = $
				pickParentNode.caption = "Root"
			)
		)
		
		on chkUseLocalCoords changed state do
		(
			UpdateUI()
		)

		on pickParentNode picked parent do
		(
			UpdateUI()
		)
		 
		on btnResetParentNode pressed do
		(
			NiPSysParentNode = undefined
			UpdateUI()
		)
		
		on comboBoundsUpdateType selected type do
		(
			UpdateUI()
		)
		 
		on spnBoundX changed value do
		(
			NiPSysBoundPosition.x = value
		)

		on spnBoundY changed value do
		(
			NiPSysBoundPosition.y = value
		)

		on spnBoundZ changed value do
		(
			NiPSysBoundPosition.z = value
		)

		on spnBoundRadius changed value do
		(
			NiPSysBoundRadius = value
		)
				
		on btnComputeStaticBound pressed do
		(
			local obj = $	
			local viewPercent = 1.0
			local particleSize = 1.0
			setWaitCursor() 

			if (isKindOf obj PArray) or (isKindOf obj PCloud) or (isKindOf obj SuperSpray) or (isKindOf obj Blizzard) do
			(
				viewPercent = obj.viewPercent 
				particleSize = obj.size
				obj.viewPercent = 100.0
			)

			if (isKindOf obj Snow) or (isKindOf obj Spray) do
			(
				 viewPercent = obj.viewportcount
				 obj.viewportcount = obj.rendercount
			)
			completeRedraw() 
			
			NiPSysBoundPosition.x = obj.center.x
			NiPSysBoundPosition.y = obj.center.y
			NiPSysBoundPosition.z = obj.center.z
			radiusTemp = distance obj.min obj.max
			radiusTemp = (radiusTemp) / 2.0
			NiPSysBoundRadius = radiusTemp
			
			if (isKindOf obj PArray) or (isKindOf obj PCloud) or (isKindOf obj SuperSpray) or (isKindOf obj Blizzard) do
			(
				obj.viewPercent = viewPercent
			)

			if (isKindOf obj Snow) or (isKindOf obj Spray) do
			(
				 obj.viewportcount = viewPercent
			)
			UpdateUI()
			setArrowCursor() 

		)
		
		on params open do
		(
			UpdateUI()
		)
	) 
	
	on update do
	(
		if version < 9 then
		(
			if AddToParticleCAArray != undefined then
			(
				AddToParticleCAArray this
			)
		)
	)

) 


	