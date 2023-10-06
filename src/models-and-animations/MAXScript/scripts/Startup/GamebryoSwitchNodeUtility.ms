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

utility SwitchNodeUtils "Gamebryo Switch Node Utilities"  -- define the utility name and description string 
( 
	global SwitchNodeUtility

    include "Gamebryo/SwitchNodeHelpers.ms"
	
	
	on  SwitchNodeUtils open do 
	( 
		-- SwitchNodeRollout = newRolloutFloater "Gamebryo SwitchNode Util" 220 560
		addRollout NiSwitchNodeRollout 
		SwitchNodeUtility = NiSwitchNodeRollout
		
		callbacks.addScript #filePostOpen "SwitchNodeUtility.RefreshSwitchNodeGroups()" id:#SwitchNodeUtilPostOpen
	) 

	on  SwitchNodeUtils close do 
	( 
		callbacks.removeScripts #filePostOpen id:#SwitchNodeUtilPostOpen
		SwitchNodeUtility = undefined
		removeRollout NiSwitchNodeRollout 
	) 
)
