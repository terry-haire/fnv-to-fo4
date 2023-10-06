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
	rollout NiBSPriorityRollout "KF Priority" width:162 height:267
	(
    
        ----------------------------------------------------------------------------
	    -- Utility-wide variables for bone PRIORITY
	    -----------------------------------------------------------------------------
		label lblName "Bethsoft Priority Tool" pos:[28,7] width:125 height:13
		label lblVersion "Version:	1.0" pos:[53,25] width:56 height:13
	    local ActiveBoneRoot = undefined
	    local CurrentMax = 1
	    
		-----------------------------------------------------------------------------
		-- These objects represent the active bone PRIORITY set options.
		-----------------------------------------------------------------------------
		spinner spnPriorityLevel "Priority Level:  " pos:[13,50] width:132 height:16 enabled:false range:[0,100,0] type:#integer fieldwidth:25
		GroupBox grp2 "Priority Settings:" pos:[4,78] width:154 height:90
		checkbutton btnPaintPriorityMode "Priority Paint Mode" pos:[17,97] width:128 height:21 enabled:false highlightColor:(color 255 127.5 0) checked:false
		checkbutton btnAddPaint "Add" pos:[16,123] width:64 height:21 enabled:false across:2 
		checkbutton btnRemovePaint "Remove" pos:[83,123] width:64 height:21 enabled:false checked:false
		checkbox checkBoxChildren "Apply to children" pos:[25,148]
		
	    -----------------------------------------------------------------------------
	    -- Is this object a child of the bone root?
	    -----------------------------------------------------------------------------
	    function IsBoneChild obj =
	    (
		    buffer = GetUserPropBuffer obj
		    if buffer != undefined do
		    (
			    bMatched = matchpattern buffer pattern:"BSPriority#*#*"
			    return bMatched
		    )
		    return false	
	    )
	    
	    
	    -----------------------------------------------------------------------------
	    -- Breaks the input string into the PRIORITY settings
	    -----------------------------------------------------------------------------
	    function ParseBoneProps string =
	    (
		    tokens = filterstring string "#"
		    if tokens.count >= 2 then return (tokens[2] as integer) else return undefined
	    )
	    
	    -----------------------------------------------------------------------------
	    -- Get the PRIORITY value for this bone. Returns 0 if this isn't a valid bone.
	    -----------------------------------------------------------------------------
	    function GetPriority bone =
	    (	
		    if bone == undefined then return 0
		    
		    if (IsBoneChild bone) do
		    (
			    string = GetUserPropBuffer bone
			    priority = ParseBoneProps string
			    if priority != undefined then return priority else return 0
		    )
		    
		    return 0
	    )
		    
	    -----------------------------------------------------------------------------
	    -- Remove the user-property buffer strings relating to bone PRIORITY
	    -----------------------------------------------------------------------------
	    function RemovePriority bone =
	    (
		    buffer = GetUserPropBuffer bone
		    string = ""
		    tokens = filterstring buffer "#"
		    for i = 3 to tokens.count do
		    (
				if i > 3 then string = string + "#"
			    string = string + tokens[i]
		    )
		    buffer = string
		    SetUserPropBuffer bone buffer
		    
			outputString = "Removing priority: " + bone.name
			print outputString
	    )
	    
	    -----------------------------------------------------------------------------
	    -- Set the bone PRIORITY strings on this bone to PRIORITY-value
	    -----------------------------------------------------------------------------
	    function SetPriority bone priority=
	    (
            if priority == undefined then priority = 0
            
            bAddPriority = false
            
            if (GetPriority bone) != priority then
    		(
				RemovePriority bone
				bAddPriority = true
			)
		    
		    if bAddPriority == true then
		    (
				outputString = "Setting priority: " + (priority as string) + " " + bone.name
				print outputString
		    
				buffer = GetUserPropBuffer bone
				if buffer == undefined then buffer = ""
				str = "BSPriority#" + (priority as string) + "#\r\x00A" + buffer
				SetUserPropBuffer bone str
			)
			
			if checkBoxChildren.checked then
			(
				for child in bone.children do SetPriority child priority
			)
	    )
		    
	    -----------------------------------------------------------------------------
	    -- Get the PRIORITY value of the parent bone.
	    -----------------------------------------------------------------------------
	    function GetPriorityMaxParent bone  =
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
	    -- Find the root bone "Bip01" or "Bip02" or "RootBone"
	    -----------------------------------------------------------------------------
	    function FindRootBone node =
	    (
			bNoKids = false
			if rootNode.children == undefined then bNoKids = true
			if rootNode.children != undefined and rootNode.children.count == 0 then bNoKids = true

			if bNoKids == false do
			(
				for child in rootNode.children do
				(
					if child.name == "Bip01" then ActiveBoneRoot = child
					
					if child.name == "Bip02" then ActiveBoneRoot = child

					if child.name == "RootBone" then ActiveBoneRoot = child
				)
				
				if ActiveBoneRoot != undefined then
				(
					outputString = "New Priority Root Bone: " + ActiveBoneRoot.name
					print outputString
				)
			)	
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
	    )
	    
	    -----------------------------------------------------------------------------
	    -- Make an object opaque
	    -----------------------------------------------------------------------------
	    mapped function UnSeeThrough obj =
	    (
		    if obj.Xray == true then obj.xray = false
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
		-- Gamebryo Bone PRIORITY local vars
		-----------------------------------------------------------------------------
        local PreFrozenObjs = #()
        local PreBoxModeObjs = #()
        local PreHiddenObjs = #()
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
            if (obj.isHidden == true) then append PreHiddenObjs obj

            if (obj.isFrozen == true) then append PreFrozenObjs obj

            if (obj.boxmode == true) then append PreBoxModeObjs obj

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

            RecursiveStateCollector rootNode.children

            ActiveBones = #()
            CollectBones ActiveBoneRoot
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
        )

		-----------------------------------------------------------------------------
		-- Make an object see-through if below a particular PRIORITY
		-----------------------------------------------------------------------------
		function Xrayize obj PRIORITY= 
		(
            if ((obj != undefined) and (not isDeleted obj)) do
            (
				myPriority = GetPriority obj
				
				if myPriority >= PRIORITY then
				( 
					UnSeeThrough obj
				)
				else
                (
                    SeeThrough obj
                )
			    
			    for child in obj.children do
			    (
				    Xrayize child PRIORITY
			    )
            )
		)	
        
        -----------------------------------------------------------------------------
		-- Enable/Disable the GUI options based off the scene graph
		-----------------------------------------------------------------------------
		function UpdateUI =
		(
			btnPaintPriorityMode.enabled = false
			btnAddPaint.enabled = false
			btnRemovePaint.enabled = false

			btnPaintPriorityMode.enabled = true
			btnAddPaint.enabled = false
			btnRemovePaint.enabled = false
            spnPriorityLevel.enabled = true		

            Xrayize ActiveBoneRoot spnPriorityLevel.value
		)
		
        -----------------------------------------------------------------------------
		-- Remove all of the handlers for subtractive painting
		-----------------------------------------------------------------------------
		function EndRemovePaint =
        (
            if (CurrentPaintMode == 1) then 
                CurrentPaintMode = -1
            
            btnRemovePaint.checked = false

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
            
            btnAddPaint.checked = true
            btnRemovePaint.checked = false
            CurrentPaintMode = 0
            btnRemovePaint.checked = false

            if (AddChangeHandler == undefined) do
            (
                AddChangeHandler = when select ActiveBones changes id:#AddPaintHandler bone do
                (
                    if (bone.isSelected) do
                    (
                        iCurPriority = spnPriorityLevel.value
                        SetPriority bone iCurPriority
						Xrayize ActiveBoneRoot spnPriorityLevel.value
                        toolmode.commandmode = #SELECT
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

            btnAddPaint.checked = false
        
            if (AddChangeHandler != undefined) do
            (
                deleteChangeHandler AddChangeHandler
                AddChangeHandler = undefined
            )
        )
        
        -----------------------------------------------------------------------------
		-- Setup all of the handlers for subtractive painting
		-----------------------------------------------------------------------------
		function BeginRemovePaint =
        (
            if (CurrentPaintMode == 0) then 
                EndAddPaint()
            
            btnRemovePaint.checked = true
            btnAddPaint.checked = false
            CurrentPaintMode = 1

            if (RemoveChangeHandler == undefined) do
            (
                RemoveChangeHandler = when select ActiveBones changes id:#RemovePaintHandler bone do
                (
                    if (bone.isSelected) do
                    (
                        SetPriority bone 0
                        Xrayize bone spnPriorityLevel.value
                        toolmode.commandmode = #SELECT
                    )
                )
            )
            toolmode.commandmode = #SELECT
        )

        -----------------------------------------------------------------------------
		-- Make an object see-through if below a particular PRIORITY
		-----------------------------------------------------------------------------
		function BeginPaintMode =
        (
            PaintModeEnabled = true
            SaveStates()
            UnFreezeObj ActiveBoneRoot
            for node in rootNode.children do
            (
                if (node != undefined) then UnShow node
            )
            Show ActiveBoneRoot
            DisableBoxMode ActiveBoneRoot
            Xrayize ActiveBoneRoot spnPriorityLevel.value
        )


        -----------------------------------------------------------------------------
		-- Make an object see-through if below a particular PRIORITY
		-----------------------------------------------------------------------------
		function EndPaintMode =
        (
            if (CurrentPaintMode == 0) then EndAddPaint()
            if (CurrentPaintMode == 1) then EndRemovePaint()
            for node in rootNode.children do
            (  
                if (node != undefined) then Show node
            )

            btnPaintPriorityMode.checked = false
            RestoreStates()  
            PaintModeEnabled = false
        )        
        -----------------------------------------------------------------------------
		-- Make an object see-through if below a particular PRIORITY
		-----------------------------------------------------------------------------

		-----------------------------------------------------------------------------
		-- We are now in add paint mode.. any picking made here will add to the 
        -- current PRIORITY
		-----------------------------------------------------------------------------

		-----------------------------------------------------------------------------
		-- We are now in remove paint mode.. any picking made here will remove from 
        -- current PRIORITY
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

            btnPaintPriorityMode.checked = false
		    btnAddPaint.checked = false
		    btnRemovePaint.checked = false
			ActiveBoneRoot = undefined
			FindRootBone rootNode
		)
        		

-----------------------------------------------------------------------------
-- Skin PRIORITY Code
-----------------------------------------------------------------------------
		
		-----------------------------------------------------------------------------
		-- Skin PRIORITY UI Options
		-----------------------------------------------------------------------------

		on NiBSPriorityRollout open do
		(
			RefreshAll()
			UpdateUI()
		)
		on NiBSPriorityRollout close do
		(
		    if (PaintModeEnabled == true) then EndPaintMode()
		    try(callbacks.removeScripts #systemPreReset id:#BSPriorityUtilPreReset);catch()
		)
		on spnPriorityLevel changed value do
		(
		    if not isDeleted ActiveBoneRoot do
		    (
		        Xrayize ActiveBoneRoot spnPriorityLevel.value
		
		        completeredraw()
		    )
		)
		on btnPaintPriorityMode changed state do
		(
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