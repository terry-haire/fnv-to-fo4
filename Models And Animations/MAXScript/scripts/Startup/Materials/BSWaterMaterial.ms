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

plugin material BSWaterMaterial
	name:"BSWaterMaterial"
	classID:#(0x342ade2b, 0x2c69c53f)
	extends:DirectX_9_Shader
	replaceUI:true
	version:1
(
	parameters MainParams rollout:MainRollout
	(
		--Reflections
		ReflectionParam type:#boolean default:false ui:EnableReflections animatable:false
		on ReflectionParam set arg do (animate off delegate.bReflectionsEnabled = this.MainRollout.ReflectionMode.enabled = arg)
		ReflectionModeParam type:#integer default:1 ui:ReflectionMode animatable:false
		on ReflectionModeParam set arg do (animate off delegate.bSilhouetteReflectionsEnabled = (arg == 2))

		--Refractions
		RefractionParam type:#boolean default:false ui:EnableRefractions animatable:false
		on RefractionParam set arg do (animate off delegate.bRefractionsEnabled = arg)
		
		--Underwater
		FogParam type:#boolean default:false ui:Fogging animatable:false
		on FogParam set arg do (animate off delegate.bFoggingEnabled = arg)

		--Depth
		DepthParam type:#boolean default:false ui:EnableDepth animatable:false
		on DepthParam set arg do (animate off delegate.bDepthEnabled = this.MainRollout.DepthMode.enabled  = arg)
		DepthModeParam type:#integer default:1 ui:DepthMode animatable:false
		on DepthModeParam set arg do (animate off delegate.bVertexAlphaDepthEnabled = (arg==2))

		--Texture Mode
		NoiseParam type:#integer default:1 ui:NoiseSettings animatable:false
		on NoiseParam set arg do (animate off delegate.bVertexUVEnabled = (arg==2))
	)
	
	local FXFilename = "WaterMAX.fx"
	rollout MainRollout "Parameters" width:326 height:319
	(
		-- Reflections
		checkbox EnableReflections "Enable" pos:[30,33] width:83 height:15
		GroupBox Reflections "Reflections" pos:[15,15] width:300 height:46
		radiobuttons ReflectionMode "Reflection Mode" pos:[135,27] width:169 height:30 enabled:false labels:#("Standard", "Silhouette") columns:2

		--Refractions
		GroupBox Refractions "Refractions" pos:[15,66] width:300 height:40
		checkbox EnableRefractions "Enable" pos:[30,82] width:100 height:15
		
		--Underwater
		GroupBox Underwater "Underwater Settings" pos:[15,111] width:300 height:40
		checkbox Fogging "Fogging" pos:[30,129] width:82 height:15

		--Depth
		GroupBox depth "Depth Settings" pos:[15,155] width:300 height:51
		checkbox EnableDepth "Enable" pos:[30,175] width:77 height:15
		radiobuttons DepthMode "Depth Mode" pos:[135,170] width:200 height:30 enabled:false labels:#("Standard", "Vertex Alpha") default:1 columns:2

		--Texture Mode
		GroupBox grp5 "Texture Settings" pos:[15,210] width:300 height:51
		radiobuttons NoiseSettings "Texture Mode" pos:[135,225] width:125 height:30 enabled:true labels:#("Projected", "Vertex UV") default:1 columns:2

		-- Reload FX File
		button ReloadFXControl "Reload FX File" pos:[116,310] width:85 height:21

		-- Separate function to be called from the rollout open handler or when we want to reset the rollout
		-- Needed because calling <rollout>.open() doesn't work (open is a property and a handler on a rollout)
		fn RolloutOpen =
		(
			-- If this is called from plugin postload the delegate can be undefined
			if delegate != undefined then
			(
				-- Enable/disable controls
				ReflectionMode.enabled = ReflectionParam
				DepthMode.enabled = DepthParam				
			)
		)


		on MainRollout open do
			(MainRollout.RolloutOpen())
		on ReloadFXControl pressed do
			(ReloadFXFile this FXFilename)
	)

	-- Set .fx file in the DirectX material
	on create do (ReloadFXFile this FXFilename)
	-- Make sure everything is updated on load
	on postLoad do (MainRollout.RolloutOpen())
)
