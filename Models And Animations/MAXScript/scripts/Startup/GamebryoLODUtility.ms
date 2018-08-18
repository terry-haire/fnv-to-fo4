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

utility LODUtils "Gamebryo LOD Utilities"  -- define the utility name and description string 
( 
	global LODUtility

    include "Gamebryo/LODHelpers.ms"
	
	
	on  LODUtils open do 
	( 
		-- lodRollout = newRolloutFloater "Gamebryo LOD Util" 220 560
		addRollout NiLODRollout 
		LODUtility = NiLODRollout
		
		callbacks.addScript #filePreOpen "LODUtility.ViewMatchTimer.active = false" id:#LODUtilityCallbacks
		callbacks.addScript #filePostOpen "try(LODUtility.ResetUtility(); LODUtility.PopulateSetName()); catch(print \"Error in LODUtility FilePostLoad callback.\")" id:#LODUtilityCallbacks
		callbacks.addScript #nodePostDelete "LODUtility.UpdateUI(); LODUtility.RefreshLODGroups rootNode" id:#LODUtilityCallbacks
		callbacks.addScript #nodeRenamed "LODUtility.UpdateUI(); LODUtility.RefreshLODGroups rootNode" id:#LODUtilityCallbacks
		callbacks.addScript #systemPostReset "try(LODUtility.ResetUtility());catch()" id:#LODUtilityCallbacks
		callbacks.addScript #systemPostNew "try(LODUtility.ResetUtility());catch()" id:#LODUtilityCallbacks
	) 

	on  LODUtils close do 
	( 
		callbacks.removeScripts id:#LODUtilityCallbacks
		LODUtility = undefined
		removeRollout NiLODRollout 
	) 
)
