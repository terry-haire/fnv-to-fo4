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

PrecacheGeometryCA = attributes "PrecacheGeometrySettings" version:2 attribID:#(0x47ba7c95, 0xa68a3bca)
( 

	parameters NiPSys rollout:params 
	( 
		Consistency		type:#integer default:1		animatable:false	ui:rdoConsistency
		
		KeepPositions	type:#boolean default:false animatable:false    ui:chkKeepPositions
		KeepNormals		type:#boolean default:false animatable:false    ui:chkKeepNormals
		KeepVertColors	type:#boolean default:false animatable:false    ui:chkKeepVertColors
		KeepUVCoords	type:#boolean default:false animatable:false    ui:chkKeepUVCoords
		KeepBoneIndices	type:#boolean default:false animatable:false    ui:chkKeepBoneIndices
		KeepBoneData	type:#boolean default:false animatable:false    ui:chkKeepBoneData

		CompressPositions	type:#boolean default:false animatable:false    ui:chkCompressPositions
		CompressNormals		type:#boolean default:false animatable:false    ui:chkCompressNormals
		CompressVertColors	type:#boolean default:false animatable:false    ui:chkCompressVertColors
		CompressUVCoords	type:#boolean default:false animatable:false    ui:chkCompressUVCoords
		CompressBoneWeights	type:#boolean default:false animatable:false    ui:chkCompressBoneWeights	
	) 

	rollout params "Gamebryo PreCache Params" 
	( 
		label	lblConsistency "Geometry Data Consistency:" align:#left
		radiobuttons rdoConsistency labels:#( "Default","Static (Unchanging)", "Mutable (Seldomly Changes)", "Volatile (Always Changes)") default:1 align:#left
		
		label    lblKeep			"Data to Preserve:" align:#left		offset:[0,10]
		checkbox chkKeepPositions	"Keep Positions"	align:#left
		checkbox chkKeepNormals		"Keep Normals"		align:#left
		checkbox chkKeepVertColors	"Keep Vertex Colors" align:#left
		checkbox chkKeepUVCoords	"Keep UV Coords"	align:#left
		checkbox chkKeepBoneIndices	"Keep Bone Indices" align:#left
		checkbox chkKeepBoneData	"Keep Bone Data"	align:#left

		label    lblCompress			"Data to Compress:"		align:#left		offset:[0,10]
		checkbox chkCompressPositions	"Compress Positions"	align:#left
		checkbox chkCompressNormals		"Compress Normals"		align:#left
		checkbox chkCompressVertColors	"Compress Vertex Colors" align:#left
		checkbox chkCompressUVCoords	"Compress UV Coords"	align:#left
		checkbox chkCompressBoneWeights	"Compress Bone Weights" align:#left
	) 
	

) 


	