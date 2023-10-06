------------------------------------------------------------------------
-- ZENIMAX MEDIA PROPRIETARY INFORMATION
-- 
-- This software is developed and/or supplied under the terms of a license
-- or non-disclosure agreement with ZeniMax Media Inc. and may not be copied
-- or disclosed except in accordance with the terms of that agreement.
-- 
--   Copyright (c) 2009 ZeniMax Media Incorporated.
--   All Rights Reserved.
-- 
-- ZeniMax Media Incorporated, Rockville, Maryland 20850
-- http://www.zenimax.com
-- Owner: Ryan Ashford
------------------------------------------------------------------------

include "Materials/BSMaterialUIUtils.ms"

--Used to flag the initialization period for scripted materials.
global bPreFileOpenG = false

callbacks.removeScripts id:#ResolveFXMaterials
function ResolveFXMaterialsCallback = (ResolveFXMaterials())
callbacks.addScript #filePostOpen "ResolveFXMaterialsCallback()" id:#ResolveFXMaterials persistent:false

callbacks.removeScripts id:#BSFilePreOpenSetup
function PreOpenCallback = (bPreFileOpenG = true)
callbacks.addScript #filePreOpen "PreOpenCallback()" id:#BSFilePreOpenSetup persistent:false
	
callbacks.removeScripts id:#BSFilePostOpenCleanUp
function PostOpenCallback = (bPreFileOpenG = false)
callbacks.addScript #filePostOpen "PostOpenCallback()" id:#BSFilePostOpenCleanUp persistent:false
	
-- If this script file is evaluated more than once make sure there is only one time callback
unRegisterTimeCallback RefreshBSMaterialCallback
function RefreshBSMaterialCallback = (RefreshBSMaterialAnims())
registerTimeCallback RefreshBSMaterialCallback
	
callbacks.removeScripts id:#ForceNitrousShaded
function ForceNitrousShadedCallback = 
(
	impl = NitrousGraphicsManager.GetActiveViewportSetting()
	if impl != undefined and impl.VisualStyleMode != #shaded then
	(
		local bwire = viewport.iswire()
		local bedgefaces = viewport.getshowedgefaces()
		actionMan.executeAction 0 "550" --Set shaded viewport as a base so the DX shader works.
		if bwire then (actionMan.executeAction 0 "551")
		if bedgefaces then (viewport.SetShowEdgeFaces true)
	)
)
callbacks.addScript #filePostOpen "ForceNitrousShadedCallback()" id:#ForceNitrousShaded persistent:false

callbacks.removeScripts id:#ForceNitrousShadedReset
callbacks.addScript #systemPostReset "ForceNitrousShadedCallback()" id:#ForceNitrousShadedReset persistent:false

callbacks.removeScripts id:#ForceNitrousShadedNew
callbacks.addScript #systemPostNew "ForceNitrousShadedCallback()" id:#ForceNitrousShadedNew persistent:false
