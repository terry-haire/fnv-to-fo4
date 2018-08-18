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

-----------------------------------------------------------------------------
-- This utility was designed to assist with Bone Level-of-detail setup.
-----------------------------------------------------------------------------
utility BoneLODUtils "Gamebryo BoneLOD Utilities"  
( 
	global BoneLODUtility
	global SkinLODUtility
    include "Gamebryo/BoneLODHelper.ms"

	-----------------------------------------------------------------------------
	-- On Bone LOD Utils open, do this
	-----------------------------------------------------------------------------
	on  BoneLODUtils open do 
	( 
		addRollout NiBoneLODRollout
		BoneLODUtility = NiBoneLODRollout
		callbacks.addScript #filePostOpen "try(BoneLODUtility.RefreshAll()\nBoneLODUtility.RefreshAllSkins()\nBoneLODUtility.UpdateUI()\nBoneLODUtility.UpdateSkinUI()\n);catch()" id:#BoneSkinLODUtilPostOpen
	) 

	-----------------------------------------------------------------------------
	-- On Bone LOD Utility closing, do this
	-----------------------------------------------------------------------------
	on  BoneLODUtils close do 
	( 
		callbacks.removeScripts #filePostOpen id:#BoneSkinLODUtilPostOpen
		BoneLODUtility = undefined
		removeRollout NiBoneLODRollout 
	) 
)
