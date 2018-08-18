-- NUMERICAL DESIGN LIMITED PROPRIETARY INFORMATION
--
-- This software is supplied under the terms of a license agreement or
-- nondisclosure agreement with Numerical Design Limited and may not
-- be copied or disclosed except in accordance with the terms of that
-- agreement.
--
--      Copyright (c) 1996-2002 Numerical Design Limited.
--      All Rights Reserved.
--
-- Numerical Design Limited, Chapel Hill, North Carolina 27514
-- http://www.ndl.com
-----------------------------------------------------------------------------

global BSBoneLODUtility
global BSPriorityUtility

-----------------------------------------------------------------------------
-- This utility was designed to assist with Bone Level-of-detail setup.
-----------------------------------------------------------------------------
utility BSBoneLODUtils "Bethsoft Utilities"  
( 
    include "Gamebryo/BSBoneLODHelper.ms"
    include "Gamebryo/BSPriorityHelper.ms"

	-----------------------------------------------------------------------------
	-- On Bone LOD Utils open, do this
	-----------------------------------------------------------------------------
	on  BSBoneLODUtils open do 
	( 
		addRollout NiBSBoneLODRollout
		BSBoneLODUtility = NiBSBoneLODRollout
		callbacks.addScript #filePostOpen "BSBoneLODUtility.RefreshAll()\nBSBoneLODUtility.UpdateUI()\n" id:#BSBoneSkinLODUtilPostOpen
		
		addRollout NiBSPriorityRollout
		BSPriorityUtility = NiBSPriorityRollout
		callbacks.addScript #filePostOpen "BSPriorityUtility.RefreshAll()\nBSPriorityUtility.UpdateUI()\n" id:#BSPriorityUtilPostOpen
	) 

	-----------------------------------------------------------------------------
	-- On Bone LOD Utility closing, do this
	-----------------------------------------------------------------------------
	on  BSBoneLODUtils close do 
	( 
		callbacks.removeScripts #filePostOpen id:#BSBoneSkinLODUtilPostOpen
		BSBoneLODUtility = undefined
		removeRollout NiBSBoneLODRollout 

		callbacks.removeScripts #filePostOpen id:#BSPriorityUtilPostOpen
		BSPriorityUtility = undefined
		removeRollout NiBSPriorityRollout 
	) 
)
