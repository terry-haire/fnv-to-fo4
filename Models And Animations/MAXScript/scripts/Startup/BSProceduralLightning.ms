------------------------------------------------------------------------
-- ZENIMAX MEDIA PROPRIETARY INFORMATION
-- 
-- This software is developed and/or supplied under the terms of a license
-- or non-disclosure agreement with ZeniMax Media Inc. and may not be copied
-- or disclosed except in accordance with the terms of that agreement.
-- 
--   Copyright (c) 2010 ZeniMax Media Incorporated.
--   All Rights Reserved.
-- 
-- ZeniMax Media Incorporated, Rockville, Maryland 20850
-- http://www.zenimax.com
-- Owner: Paul Graber
------------------------------------------------------------------------

plugin simpleObject BSProceduralLightning
	name:"Lightning"
	classID:#(0x5545fe42, 0x24a7a1a1)
	category:"BSProceduralGeometry"
(
	parameters main rollout:params
	(
		GenerationSignalParam type:#boolean default:false animatable:true
		MutationSignalParam type:#boolean default:false animatable:true
		SubdivisionsParam type:#integer default:2 ui:SubdivisionsControl animatable:true
		NumBranchesParam type:#integer default:0 ui:NumBranchesControl animatable:true
		BranchesVarParam type:#integer default:0 ui:BranchesVarControl animatable:true
		LengthParam type:#float default:100 ui:LengthControl animatable:true
		LengthVarParam type:#float default:0 ui:LengthVarControl animatable:true
		WidthParam type:#float default:5 ui:WidthControl animatable:true
		ArcOffsetParam type:#float default:10 ui:ArcOffsetControl animatable:true
		FadeMainBoltParam type:#boolean default:false ui:FadeMainBoltControl animatable:false
		FadeChildBoltParam type:#boolean default:false ui:FadeChildBoltControl animatable:false
		ChildBranchWidthMultiplierParam type:#float default:1 ui:ChildBranchWidthMultiplierControl animatable:false
		AnimateArcOffsetParam type:#boolean default:false ui:AnimateArcOffsetControl animatable:false
	)
	
	rollout params "Procedural Lightning" width:162 height:434
	(
		GroupBox GenerateGroup "" pos:[4,3] width:154 height:160
		button GenerateBoltControl "Generate Bolt Keyframe" pos:[17,15] width:127 height:29
		button KillBoltControl "Kill Bolt Keyframe" pos:[17,50] width:127 height:29
		spinner SubdivisionsControl "Subdivisions" pos:[64,90] width:87 height:16 range:[0,12,2] scale:1
		spinner NumBranchesControl "Num Branches" pos:[54,111] width:97 height:16 range:[0,10,0] scale:1
		spinner BranchesVarControl "Num Branches Var" pos:[34,132] width:117 height:16 range:[0,10,0] scale:1
		
		GroupBox MutateGroup "" pos:[4,164] width:154 height:176
		button MutateBoltControl "Mutate Bolt Keyframe" pos:[17,177] width:127 height:29
		spinner LengthControl "Length" pos:[71,213] width:77 height:16 range:[0,10000,100] scale:1 fieldwidth:40
		spinner LengthVarControl "Length Var" pos:[53,233] width:95 height:16 range:[0,10000,0] scale:1 fieldwidth:30
		spinner WidthControl "Width" pos:[77,253] width:71 height:16 range:[0,100,5] scale:0.1 fieldwidth:30
		spinner ChildBranchWidthMultiplierControl "Child Width Multiplier" pos:[19,273] width:129 height:16 range:[0,10,1] scale:0.01 fieldwidth:30
		spinner ArcOffsetControl "Arc Offset" pos:[58,293] width:90 height:16 range:[0,1000,10] scale:0.1 fieldwidth:30
		checkbox AnimateArcOffsetControl "Animate Arc Offset" pos:[28,316] width:113 height:18
		
		GroupBox MiscGroup "Misc" pos:[4,341] width:154 height:61
		checkbox FadeMainBoltControl "Fade Main Bolt" pos:[18,359] width:125 height:16
		checkbox FadeChildBoltControl "Fade Child Bolt" pos:[18,378] width:127 height:16
		
		-- Control handlers
		on GenerateBoltControl pressed do
		(
			with animate on (GenerationSignalParam = true)
		)
		on KillBoltControl pressed do
		(
			with animate on (GenerationSignalParam = false)
		)
		on MutateBoltControl pressed do
		(
			with animate on (MutationSignalParam = not MutationSignalParam)
		)
	)
	
	-- Called when object is created to generate display mesh
	on buildMesh do
	(		
		setMesh mesh \
			verts:#([10,-10,-10], [2.5,0,-2.5], [-10,-10,-10], [-2.5,0,-2.5], [10,-10,10], [2.5,0,2.5], [-10,-10,10], [-2.5,0,2.5]) \
			faces:#([1,3,4], [4,2,1], [5,6,8], [8,7,5], [1,2,6], [6,5,1], [2,4,8], [8,6,2], [4,3,7], [7,8,4], [3,1,5], [5,7,3]) \
		meshop.applyUVWMap mesh #face
	)
	
	-- Called when mouse is clicked to create object
	tool create
	(
		on mousePoint click do
			case click of
			(
				1: nodeTM.translation = gridPoint
				2: #stop
			)
	)
)