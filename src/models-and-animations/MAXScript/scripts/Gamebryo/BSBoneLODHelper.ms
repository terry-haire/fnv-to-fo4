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

   -----------------------------------------------------------------------------
	-- The Bone-centric rollout for this utility
	-----------------------------------------------------------------------------
	rollout NiBSBoneLODRollout "Bethsoft Bone LOD" width:162 height:267
	(
    
        ----------------------------------------------------------------------------
	    -- Utility-wide variables for bone LOD
	    -----------------------------------------------------------------------------
		label lblName "Bethsoft Bone LOD Tool" pos:[19,7] width:125 height:13
		label lblVersion "Version:	1.0" pos:[53,25] width:56 height:13
	    local BoneRoots = #()
	    local ActiveBoneRoot = undefined
	    local CurrentMax = 1
	    
	    -----------------------------------------------------------------------------
	    -- Does this object have a skin modifier attached
	    -----------------------------------------------------------------------------
	    function IsSkinned obj =
	    (
		    if obj == rootNode then return false
		    if obj.modifiers != undefined do
		    (
			    for modifier in obj.modifiers do
			    (
				    modclass = classof modifier
				    modname = modclass as string
				    if modname == "Skin" do
				    (
					    return true
				    )
			    )
		    )
		    return false
	    )
	    
	    -----------------------------------------------------------------------------
	    -- Does this object have a physique modifier attached
	    -----------------------------------------------------------------------------
	    function IsPhysiqued obj =
	    (
		    if obj == rootNode then return false
		    if obj.modifiers == undefined then return false
		    for modifier in obj.modifiers do
		    (
			    modclass = classof modifier
			    modname = modclass as string
			    if modname == "Physique" do
			    (
				    return true	
			    )
		    )
		    return false
	    )

	    -----------------------------------------------------------------------------
	    -- Is this object a bone LOD root?
	    -----------------------------------------------------------------------------
	    function isBoneRoot obj =
	    (
		    if obj == rootNode then return false
		    buffer = GetUserPropBuffer obj
		    if buffer != undefined do
		    (
			    bMatched = matchpattern buffer pattern:"BSBoneLOD#BoneRoot#*"
			    return bMatched
		    )
		    return false
	    )
	    
	    -----------------------------------------------------------------------------
	    -- Is this object a child of the bone root?
	    -----------------------------------------------------------------------------
	    function isBoneChild obj =
	    (
		    buffer = GetUserPropBuffer obj
		    if buffer != undefined do
		    (
			    bMatched = matchpattern buffer pattern:"BSBoneLOD#Bone#*#*"
			    return bMatched
		    )
		    return false	
	    )
	    
	    
	    -----------------------------------------------------------------------------
	    -- Breaks the input string into the LOD settings
	    -----------------------------------------------------------------------------
	    function ParseBoneProps string =
	    (
		    tokens = filterstring string "#"
		    if tokens.count >= 3 then return (tokens[3] as integer) else return undefined
	    )
	    
	    -----------------------------------------------------------------------------
	    -- Get the LOD value for this bone. Returns undefined if this isn't a valid bone.
	    -----------------------------------------------------------------------------
	    function GetBoneLOD bone =
	    (	
		    if bone == undefined then return 0
		    if (isbonechild bone) do
		    (
			    string = GetUserPropBuffer bone
			    LOD = ParseBoneProps string
			    if LOD != undefined then return LOD
		    )
		    
		    max = -1
		    for child in bone.children do
		    (
			    LOD = GetBoneLOD child
			    if LOD > max then max = LOD
		    )
		    if max == -1 then return undefined else return max
	    )
		    
	    -----------------------------------------------------------------------------
	    -- Remove the user-property buffer strings relating to bone LOD
	    -----------------------------------------------------------------------------
	    function RemoveBoneLOD bone =
	    (
		    buffer = GetUserPropBuffer bone
		    string = ""
		    tokens = filterstring buffer "#"
		    for i = 4 to tokens.count do
		    (
			    if i > 4 then string = string + "#"
			    string = string + tokens[i]
		    )
		    buffer = string
		    SetUserPropBuffer bone buffer
            print "Remove Bone LOD"
            print buffer
	    )
	    
	    -----------------------------------------------------------------------------
	    -- Set the bone LOD strings on this bone to LOD-value
	    -----------------------------------------------------------------------------
	    function SetBoneLOD bone LOD=
	    (
            print "SetBoneLOD"
            print LOD
            print bone
            if LOD == undefined then LOD = 0
		    if (isBoneChild bone) do
		    (
    		    if (GetBoneLOD bone) == LOD then return true
			    RemoveBoneLOD bone
		    )
		    
		    buffer = GetUserPropBuffer bone
		    if buffer == undefined then buffer = ""
		    print "Setting bone lod on Bone:"
		    str = "BSBoneLOD#Bone#" + (LOD as string) + "#\r\x00A" + buffer
		    SetUserPropBuffer bone str
	    )
		    
	    -----------------------------------------------------------------------------
	    -- Get the LOD value of the parent bone.
	    -----------------------------------------------------------------------------
	    function GetBoneLODMaxParent bone  =
	    (
		    parent = bone.parent
		    while parent != undefined do
		    (
			    if (IsBoneChild parent) do
			    (
				    return parent
				    exit
			    )
			    parent = parent.parent
		    )
		    return undefined
	    )
	    
	    -----------------------------------------------------------------------------
	    -- Get the maximum LOD value for the child bones
	    -----------------------------------------------------------------------------
	    function GetChildBoneLODMax bone =
	    (
		    if bone == undefined then return 0
		    if bone.children == undefined then return 0
		    if bone.children.count == 0 then return 0
		    
		    curMax = 0
		    maxLod = -1
		    for child in bone.children do
		    (
                iTempVal = 0
                if (IsBoneChild child) then 
                (
                    iTempVal = GetBoneLOD child
                )
                else
                (
                    iTempVal = GetChildBoneLODMax child
                )


                if (iTempVal > curMax) then curMax = iTempVal
		    )

            return curMax
	    )	
	    
	    -----------------------------------------------------------------------------
	    -- Find all bone roots in a subgraph
	    -----------------------------------------------------------------------------
        mapped function VerifySubTreeIsTagged node =
        (
            if (not IsBoneChild node) do
            (
                maxValue = GetChildBoneLODMax node 
                SetBoneLOD node maxValue 
            )

            VerifySubTreeIsTagged node.children
        )	
	    -----------------------------------------------------------------------------
	    -- Find all bone roots in a subgraph
	    -----------------------------------------------------------------------------
	    function FindBoneRoots node =
	    (
		    if (IsBoneRoot node) do
		    (
			    append BoneRoots node
                VerifySubTreeIsTagged node.children
			    return true
		    )
		    
		    for child in node.children do
		    (
			    FindBoneRoots child
		    )
		    return true
	    )
	    
	    -----------------------------------------------------------------------------
	    -- Set all nodes in the subgraph to zero
	    -----------------------------------------------------------------------------
	    function RecursivelySetLevelZero node =
	    (
		    bNoKids = false
		    if node.children == undefined then bNoKids = true
		    if node.children != undefined and node.children.count == 0 then bNoKids = true

		    if bNoKids == false do
		    (
			    for child in node.children do
			    (
				    RecursivelySetLevelZero child
			    )
		    )	
		    bAdd = true
		    if (IsBoneRoot node) then bAdd = false
		    if (IsBoneChild node) then bAdd = false
	    
		    if (bAdd == true) do (SetBoneLOD node 0)  
	    )
	    
	    -----------------------------------------------------------------------------
	    -- Add the bone root to the list. Set all of the values in the scene graph to 0.
	    -----------------------------------------------------------------------------
	    function AddBoneRoot obj =
	    (
		    if (IsBoneRoot obj) then return true
		    buffer = GetUserPropBUffer obj
		    if buffer == undefined then buffer = ""
		    buffer = "BSBoneLOD#BoneRoot#\r\x00A" + buffer
		    SetUserPropBuffer obj buffer
		    RecursivelySetLevelZero obj
            append BoneRoots obj
	    )
	    
	    -----------------------------------------------------------------------------
	    -- Recursively remove all bone LOD tags from the sub graph
	    -----------------------------------------------------------------------------
	    function RecursiveRemoveBoneLODs obj =
	    (
		    RemoveBoneLOD obj
		    for child in obj.children do
		    (
			    RecursiveRemoveBoneLODs child
		    )
	    )
	    
	    -----------------------------------------------------------------------------
	    -- Remove the bone root tags. Recursively remove all bone tags.
	    -----------------------------------------------------------------------------
	    function RemoveBoneRoot obj =
	    (
		    if not (IsBoneRoot obj) then return true
		    buffer = GetUserPropBuffer obj
		    if buffer == undefined then return true
		    string = ""
		    tokens = filterstring buffer "#"
		    for i = 3 to tokens.count do
		    (
			    if i > 3 then string = string + "#"
			    string = string + tokens[i]
		    )
		    buffer = string
		    SetUserPropBuffer obj buffer
		    RecursiveRemoveBoneLODs obj
	    )
	    

	    -----------------------------------------------------------------------------
	    -- Show an object
	    -----------------------------------------------------------------------------
	    mapped function Show obj =
	    (
		    if obj.isHidden then unhide obj
		    Show obj.children
	    )
	    
	    -----------------------------------------------------------------------------
	    -- Make an object transparent
	    -----------------------------------------------------------------------------
	    mapped function SeeThrough obj =
	    (
		    if obj.Xray == false then obj.xray = true
		    seethrough obj.children
	    )
	    
	    -----------------------------------------------------------------------------
	    -- Make an object opaque
	    -----------------------------------------------------------------------------
	    mapped function UnSeeThrough obj =
	    (
		    if obj.Xray == true then obj.xray = false
		    unseethrough obj.children
	    )
	    
	    -----------------------------------------------------------------------------
	    -- Show all objects from a root down
	    -----------------------------------------------------------------------------
	    function ShowAll root =
	    (
		    show root
		    completeRedraw()			
	    )
	    
	    -----------------------------------------------------------------------------
	    -- Hide all objects from a root down
	    -----------------------------------------------------------------------------
	    mapped function Unshow obj =
	    (
		    bShown = obj.isHidden
		    bShown = not bShown
		    if bShown then hide obj
		    UnShow obj.children
	    )

        -----------------------------------------------------------------------------
	    -- Make an object transparent
	    -----------------------------------------------------------------------------
	    mapped function EnableBoxMode obj =
	    (
            if obj.boxmode == false then obj.boxmode = true
		    enableBoxMode obj.children
	    )
	    
    
	    -----------------------------------------------------------------------------
	    -- Make an object opaque
	    -----------------------------------------------------------------------------
	    mapped function FreezeObj obj =
	    (
		    if obj.isfrozen == false then (freeze obj)
		    FreezeObj obj.children
	    )
	    
	    -----------------------------------------------------------------------------
	    -- Make an object transparent
	    -----------------------------------------------------------------------------
	    mapped function UnFreezeObj obj =
	    (
            if obj.isFrozen == true then print obj.name
		    if obj.isfrozen == true then (unfreeze obj)
		    UnFreezeObj obj.children
	    )
	    
	    -----------------------------------------------------------------------------
	    -- Make an object opaque
	    -----------------------------------------------------------------------------
	    mapped function DisableBoxMode obj =
	    (
		    if obj.boxmode == true then obj.boxmode = false
		    DisableBoxMode obj.children
	    )
    			    
	
		-----------------------------------------------------------------------------
		-- Gamebryo Bone LOD local vars
		-----------------------------------------------------------------------------
		local ActiveBoneLODRoot = undefined
        local PreFrozenObjs = #()
        local PreBoxModeObjs = #()
        local PreHiddenObjs = #()
        local PreXrayObjs = #()
        local ActiveBones = #()
        local AddChangeHandler = undefined
        local RemoveChangeHandler = undefined
        local PaintModeEnabled = false
        local CurrentPaintMode = undefined
	
        

        -----------------------------------------------------------------------------
		-- Save the pre-existing states for this object
		-----------------------------------------------------------------------------
		mapped function RecursiveStateCollector obj =
        (
            print obj.name

            if (obj.isHidden == true) then append PreHiddenObjs obj

            if (obj.isFrozen == true) then append PreFrozenObjs obj

            if (obj.boxmode == true) then append PreBoxModeObjs obj

            if (obj.xray == true) then append PreXrayObjs obj

            RecursiveStateCollector obj.children
        )

        -----------------------------------------------------------------------------
		-- Save the bones in the hierarchy
		-----------------------------------------------------------------------------
		mapped function CollectBones bone =
        (
            append ActiveBones bone
            CollectBones bone.children
        )
        
        -----------------------------------------------------------------------------
		-- Save the pre-existing states for this scene
		-----------------------------------------------------------------------------
		function SaveStates = 
        (
            PreFrozenObjs = #()
            PreBoxModeObjs = #()
            PreHiddenObjs = #()
            PreXrayObjs = #()

            
            print "Recursively saving states"
            RecursiveStateCollector rootNode.children

            print "Pre-Hidden Objs:"
            print PreHiddenObjs
            
            print "Pre-Frozen Objs:"
            print PreFrozenObjs
            
            print "Pre-boxmode Objs:"
            print PreBoxModeObjs

            ActiveBones = #()
            CollectBones ActiveBoneRoot.children
        )

        -----------------------------------------------------------------------------
		-- Restore the previously stored states for this object
		-----------------------------------------------------------------------------
		mapped function RecursiveStateRestorer obj =
        (
            if (not isDeleted obj) do
            (
                index = findItem PreHiddenObjs obj
                if (index != 0) then UnShow obj else Show obj

                index = findItem PreFrozenObjs obj
                if (index != 0) then FreezeObj obj else UnFreezeObj obj

                index = findItem PreBoxModeObjs obj
                if (index != 0) then EnableBoxMode obj else DisableBoxMode obj

                index = findItem PreXrayObjs obj
                if (index != 0) then SeeThrough obj else UnSeeThrough obj

                RecursiveStateRestorer obj.children
            )
        )

        -----------------------------------------------------------------------------
		-- Save the pre-existing states for this object
		-----------------------------------------------------------------------------
        function RestoreStates =
        (
            RecursiveStateRestorer rootNode.children
            PreFrozenObjs = #()
            PreBoxModeObjs = #()
            PreHiddenObjs = #()
            PreXrayObjs = #()
        )
		-----------------------------------------------------------------------------
		-- A filtering method for the Add LOD Root button.
		-----------------------------------------------------------------------------
		function pickRootFilter obj =
		(
			if (IsSkinned obj) then return false
			if (IsPhysiqued obj) then return false
			if (obj == ActiveBoneRoot) then return false
			parent = obj.parent
			child = obj
            while parent != undefined do
			(
                child = parent
				parent = parent.parent
			)

            if (IsBoneRoot child) then return false else return true
		)

    	-----------------------------------------------------------------------------
		-- A filtering method for the Add bone to LOD button.
		-----------------------------------------------------------------------------
	    function pickBoneFilter obj =
        (
            print obj.name
        	if (IsSkinned obj) then return false
			if (IsPhysiqued obj) then return false
			if (obj == ActiveBoneRoot) then return false
			parent = obj.parent
			child = obj
            while parent != undefined do
			(
                child = parent
				parent = parent.parent
			)

            if (ActiveBoneRoot == child) then return true else return false
        )


		-----------------------------------------------------------------------------
		-- These objects represent the active bone LOD set options.
		-----------------------------------------------------------------------------
		GroupBox grp1 "Current BoneLOD Set:" pos:[4,43] width:154 height:91
		dropdownList comboSetName "Actor LOD Root:" pos:[13,62] width:136 height:40 enabled:false
		pickbutton btnAddRoot "Add" pos:[16,107] width:64 height:21 enabled:false
-- message:"Select the root of a bone hierarchy " filter:pickRootFilter() toolTip:"Select the root of a bone hierarchy" across:2
		button btnRemoveRoot "Remove" pos:[83,107] width:64 height:21 enabled:false	
		spinner spnLODLevel "Current LOD Level:  " pos:[13,149] width:132 height:16 enabled:false range:[0,100,0] type:#integer fieldwidth:25
			
		GroupBox grp2 "Current Bone LOD Settings:" pos:[4,184] width:154 height:72
		checkbutton btnPaintLODMode "LOD Level Paint Mode" pos:[17,203] width:128 height:21 enabled:false highlightColor:(color 255 127.5 0) checked:false
		checkbutton btnAddPaint "Add" pos:[16,229] width:64 height:21 enabled:false across:2 
		checkbutton btnRemovePaint "Remove" pos:[83,229] width:64 height:21 enabled:false checked:false
		
			

		-----------------------------------------------------------------------------
		-- Make an object see-through if below a particular LOD
		-----------------------------------------------------------------------------
		function Xrayize obj LOD= 
		(
            if ((obj != undefined) and (not isDeleted obj)) do
            (
			    if (IsBoneChild obj) do
			    (
				    myLOD = GetBoneLOD obj
				    
				    if myLOD < LOD do
				    ( 
					    seethrough obj
					    return true
				    )

                    if myLOD >= LOD do
                    (
                        UnSeeThrough obj
                    )
			    )
			    
			    for child in obj.children do
			    (
				    xrayize child LOD
			    )
            )
		)	
        
        -----------------------------------------------------------------------------
		-- Select the new active bone root
		-----------------------------------------------------------------------------
		function ChangeActiveBoneRoot root =
		(
            if (not isDeleted root) do
            (
			    if ActiveBoneRoot == root then return true
			    ActiveBoneRoot = root
                xrayize ActiveBoneRoot spnLODLevel.value
			    return true
            )
            return false
		)		
        
        
        -----------------------------------------------------------------------------
		-- Enable/Disable the GUI options based off the scene graph
		-----------------------------------------------------------------------------
		function UpdateUI =
		(
			btnPaintLODMode.enabled = false
			btnAddPaint.enabled = false
			btnRemovePaint.enabled = false

            if (ActiveBoneRoot != undefined and isDeleted ActiveBoneRoot) do ActiveBoneRoot = undefined
             
			if ActiveBoneRoot != undefined do
			(
				comboSetName.enabled = true
				items = #()
				index = -1
				for i = 1 to BoneRoots.count do
				(
                    if not isDeleted BoneRoots[i] do
                    ( 
					    root = BoneRoots[i]
					    if root == ActiveBoneRoot then index = i
					    append items (root.name as string)
                    )
				) 
				comboSetName.items = items
				comboSetName.selection = index
				btnRemoveRoot.enabled = true
				
				btnPaintLODMode.enabled = true
			    btnAddPaint.enabled = false
			    btnRemovePaint.enabled = false
                spnLODLevel.enabled = true		
			)
			btnAddRoot.enabled = true

			if ActiveBoneRoot == undefined do
			(
				comboSetName.enabled = false
				comboSetName.items = #()
				spnLODLevel.enabled = false
                btnRemoveRoot.enabled = false

			)

            xrayize ActiveBoneRoot spnLODLevel.value
		)
		
		
		-----------------------------------------------------------------------------
		-- Change the currently active bone root
		-----------------------------------------------------------------------------
		
		-----------------------------------------------------------------------------
		-- A new root has been selected, add it to the list
		-----------------------------------------------------------------------------

		
        -----------------------------------------------------------------------------
		-- Remove all of the handlers for subtractive painting
		-----------------------------------------------------------------------------
		function EndRemovePaint =
        (
            if (CurrentPaintMode == 1) then 
                CurrentPaintMode = -1
            
            print "EndRemovePaint"
            btnRemovePaint.checked = false
            print "btnRemovePaint.checked = false"

            if (RemoveChangeHandler != undefined) do
            (
                deleteChangeHandler RemoveChangeHandler
                RemoveChangeHandler = undefined
            )
        )

        -----------------------------------------------------------------------------
		-- Setup all of the handlers for additive painting
		-----------------------------------------------------------------------------
		function BeginAddPaint =
        (
            if (CurrentPaintMode == 1) then EndRemovePaint()
            print "BeginAddPaint"
            btnAddPaint.checked = true
            btnRemovePaint.checked = false
            CurrentPaintMode = 0

            print "btnAddPaint.checked = true"
            btnRemovePaint.checked = false

            if (AddChangeHandler == undefined) do
            (
                AddChangeHandler = when select ActiveBones changes id:#AddPaintHandler bone do
                (
                    if (bone.isSelected) do
                    (
                        iCurLOD = spnLODLevel.value
                        iTempLOD = GetBoneLOD bone

                        if (iTempLOD < iCurLOD) do
                        (
                            SetBoneLOD bone iCurLOD
                            parent = bone.parent
                            bContinue = true
                            while (bContinue == true) do
                            (
                                if (parent == undefined) then bContinue = false
                                if (parent != undefined) do
                                (
                                    iLOD = GetBoneLOD parent
                                    if (iLOD < iCurLOD) then (SetBoneLOD parent iCurLOD) else (bContinue = false)
                                    parent = parent.parent
                                )
                            )

                            xrayize ActiveBoneRoot spnLODLevel.value
                            toolmode.commandmode = #SELECT
                        )
                    )
                )
            )
            toolmode.commandmode = #SELECT
        )

        -----------------------------------------------------------------------------
		-- Remove all of the handlers for additive painting
		-----------------------------------------------------------------------------
		function EndAddPaint =
        (
            if (CurrentPaintMode == 0) then 
                CurrentPaintMode = -1

            print "EndAddPaint"
            btnAddPaint.checked = false
            print "btnAddPaint.checked = false"
        
            if (AddChangeHandler != undefined) do
            (
                deleteChangeHandler AddChangeHandler
                AddChangeHandler = undefined
            )
        )
        
        -----------------------------------------------------------------------------
		-- Make sure that no child has a value greater than the current LOD level
		-----------------------------------------------------------------------------
		mapped function PropagateDownwards bone iLODLevel =
        (
            iCompLevel = GetBoneLOD bone
            if (iCompLevel > iLODLevel) do
            (
                SetBoneLOD bone iLODLevel
                PropagateDownwards bone.children iLODLevel
            )
        )

        -----------------------------------------------------------------------------
		-- Setup all of the handlers for subtractive painting
		-----------------------------------------------------------------------------
		function BeginRemovePaint =
        (
            if (CurrentPaintMode == 0) then 
                EndAddPaint()
            
            print "BeginRemovePaint"
            btnRemovePaint.checked = true
            btnAddPaint.checked = false
            CurrentPaintMode = 1
            print "btnRemovePaint.checked = true"

            if (RemoveChangeHandler == undefined) do
            (
                RemoveChangeHandler = when select ActiveBones changes id:#RemovePaintHandler bone do
                (
                    if (bone.isSelected) do
                    (
                        iCurLevel = GetBoneLOD bone
                        iLODLevel = GetChildBoneLODMax bone 
                        print "Selected:"
                        print bone
                        print iCurLevel
                        print iLODLevel

                        if (iCurLevel == iLODLevel) do
                        (
                            iLODLevel = spnLODLevel.value - 1
                            print "Updateing..."
                            print iLODLevel
                        )

                        if (iLODLevel < 0) then iLODLevel = 0

                        SetBoneLOD bone iLODLevel
                        PropagateDownwards bone.children iLODLevel
                        xrayize bone spnLODLevel.value
                        toolmode.commandmode = #SELECT
                    )
                )
            )
            toolmode.commandmode = #SELECT
        )

        -----------------------------------------------------------------------------
		-- Make an object see-through if below a particular LOD
		-----------------------------------------------------------------------------
		function BeginPaintMode =
        (
            PaintModeEnabled = true
            print "BeginPaintMode"
            SaveStates()
            UnFreezeObj ActiveBoneRoot
            for node in rootNode.children do
            (
                if (node != undefined) then UnShow node
            )
            Show ActiveBoneRoot
            DisableBoxMode ActiveBoneRoot
            xrayize ActiveBoneRoot spnLODLevel.value
        )


        -----------------------------------------------------------------------------
		-- Make an object see-through if below a particular LOD
		-----------------------------------------------------------------------------
		function EndPaintMode =
        (
            if (CurrentPaintMode == 0) then EndAddPaint()
            if (CurrentPaintMode == 1) then EndRemovePaint()
            print "EndPaintMode"
            for node in rootNode.children do
            (  
                if (node != undefined) then Show node
            )

            btnPaintLODMode.checked = false
            RestoreStates()  
            PaintModeEnabled = false
        )        
        -----------------------------------------------------------------------------
		-- Make an object see-through if below a particular LOD
		-----------------------------------------------------------------------------

		-----------------------------------------------------------------------------
		-- We are now in add paint mode.. any picking made here will add to the 
        -- current LOD
		-----------------------------------------------------------------------------

		-----------------------------------------------------------------------------
		-- We are now in remove paint mode.. any picking made here will remove from 
        -- current LOD
		-----------------------------------------------------------------------------
		
		-----------------------------------------------------------------------------
		-- Search through the scene graph to reflect changes
		-----------------------------------------------------------------------------
		function RefreshAll= 
		(
            if (PaintModeEnabled == true) do
            (
                if (btnAddPaint.checked == true) then EndAddPaint()
                if (btnRemovePaint.checked == true) then EndRemovePaint()                  
                EndPaintMode()
            )

            btnPaintLODMode.checked = false
		    btnAddPaint.checked = false
		    btnRemovePaint.checked = false
			ActiveBoneRoot = undefined
			BoneRoots = #()
			FindBoneRoots rootNode
			if BoneRoots.count > 0 do
			(
				print "Bone Roots:"
				print BoneRoots
				ChangeActiveBoneRoot BoneRoots[1] 
			)
	
		)
        		
        -----------------------------------------------------------------------------
		-- The current bone root has been deleted, refresh the list
		-----------------------------------------------------------------------------
                		



-----------------------------------------------------------------------------
-- Skin LOD Code
-----------------------------------------------------------------------------
		
		
		-----------------------------------------------------------------------------
		-- Callback method for picking a skin
		-----------------------------------------------------------------------------
		function pickskin obj =
		(
			for skin in TheSkins do
			(
				if obj == skin then return false				
			)
			if (IsSkinned obj) then return true
			if (IsPhysiqued obj) then return true
			return false
		)
		
		-----------------------------------------------------------------------------
		-- Skin LOD UI Options
		-----------------------------------------------------------------------------

		on NiBSBoneLODRollout open do
		(
			RefreshAll()
			UpdateUI()
		)
		on NiBSBoneLODRollout close do
		(
		    if (PaintModeEnabled == true) then EndPaintMode()
		    try(callbacks.removeScripts #systemPreReset id:#BSBoneLODUtilPreReset);catch()
		)
		on comboSetName selected item do
		(
			if BoneRoots[item] != ActiveBoneRoot do
			(
				ChangeActiveBoneRoot BoneRoots[item]
				UpdateUI()
			)
		)
		on btnAddRoot picked obj do
		( 
		    AddBoneRoot obj
			ChangeActiveBoneRoot obj
			UpdateUI()
		)
		on btnRemoveRoot pressed do
		(
			RemoveBoneRoot ActiveBoneRoot
			RefreshAll()
			UpdateUI()
		)
		on spnLODLevel changed value do
		(
		    if not isDeleted ActiveBoneRoot do
		    (
		        xrayize ActiveBoneRoot spnLODLevel.value
		
		        completeredraw()
		    )
		)
		on btnPaintLODMode changed state do
		(
		    print "on btnPaintLODMode changed state do"
		    if (state == true) do
		    (
		        btnAddPaint.enabled = true
			    btnRemovePaint.enabled = true
		        btnAddPaint.checked = true
		
		        BeginPaintMode()
		        BeginAddPaint()
		    )
		
		    if (state == false) do
		    (
		        
		
		        btnAddPaint.checked = false
		        btnRemovePaint.checked = false
		        btnAddPaint.enabled = false
			    btnRemovePaint.enabled = false 
		           
		        EndPaintMode()
		    )
		)
		on btnAddPaint changed state do
		(
		    print "on btnAddPaint changed state do  "
		    if (state == true) do
		    (
		        BeginAddPaint()
		    )
		
		    if (state == false) do
		    (
		        BeginRemovePaint()  
		    )
		)
		on btnRemovePaint changed state do
		(
		    print "on btnRemovePaint changed state do  "
		    if (state == true) do
		    (
		        BeginRemovePaint()
		    )
		
		    if (state == false) do
		    (
		        BeginAddPaint()  
		    )
		)
	)	