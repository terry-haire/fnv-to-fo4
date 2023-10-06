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

utility ActorManagerUtil "Gamebryo Animation Manager"  -- define the utility name and description string 
( 
	global ActorManagerUtility
	label ActorManagerUtilVersion "Version: 1.0.0" align:#center

    include "Gamebryo/AnimationManager.ms"

	on  ActorManagerUtil open do 
	( 
		-- ActorManagerRollout = newRolloutFloater "Gamebryo ActorManager Util" 220 560
		addRollout NiActorManagerRollout rolledUp:false
		addRollout NiActorLayerRollout rolledUp:true
		addRollout NiActorSequenceRollout rolledUp:false
		addRollout NiActorAccumulationRollout rolledUp:true
		addRollout NiActorSeqTagsRollout rolledUp:true
		ActorManagerUtility = NiActorManagerRollout
		callbacks.addScript #filePostOpen "try(ActorManagerUtility.RefreshAll());catch()" id:#ActorManagerUtilPostOpen
	) 

	on  ActorManagerUtil close do 
	( 
		callbacks.removeScripts #filePostOpen id:#ActorManagerUtilPostOpen
		ActorManagerUtility = undefined
		removeRollout NiActorManagerRollout 
		removeRollout NiActorLayerRollout
		removeRollout NiActorAccumulationRollout
		removeRollout NiActorSeqTagsRollout
		removeRollout NiActorSequenceRollout
	) 
)