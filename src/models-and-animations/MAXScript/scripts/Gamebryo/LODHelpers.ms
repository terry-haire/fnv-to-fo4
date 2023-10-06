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

rollout NiLODRollout "Gamebryo Level-Of-Detail"  
(
	local root = rootNode   -- root node of the scene
	local LODRootCount = 0	-- # of LODRoot dummy objects found in the scene.
	local LODRoots = #()	-- Array of LODRoot dummy object names

	-- Defining the strings that this utility uses
	local LOD_BASE_NAME = "LODGroup"
	local LOD_DISTANCE = "LODDistance"
	local LOD_MINIMUM_VALUE = 0.0
	
	-- Defining our active variables
	local ActiveLODRoot = undefined
	local ActiveLODChild = undefined
	local SortedLODChildren = undefined
	
	local lastPos = [0.0,0.0,0.0]
	global RefreshLODHelpersUI

	button btnRefreshValues "Refresh LOD Sets" width:128 align:#center
		
	group "Level-of-Detail Set Creation:"
	(
		checkbox cbCenterLOD "Recenter objects when" checked:false width:128 align:#center
		label lblCenterLOD "they are added to a set" width:128 align:#center offset:[19, -4]
		button btnCreateFromSelection "Create From Selection" width:128  align:#center
		timer ViewMatchTimer interval:250 active:false
	)
	
	group "Current Level-Of-Detail Set:"
	(
		dropdownlist comboSetName "Set Name:" enabled:false
		label lblLODChildren "LOD (Start View Distance*):" align:#left offset:[0,6]
		listbox lbxLODChildren "" height:10 enabled:false offset:[0, -4]
		radiobuttons btnShowState labels:#("Show All","Show Active Only","Match Active Viewport") enabled:false align:#left
		button btnAddToSet "Add Selection To LODs" width:128  align:#center enabled:false
		button btnRemoveFromSet "Remove Sel. From Set" width:128 align:#center enabled:false
		button btnAttachToActiveLOD "Make Sel. Child Of LOD" width:128  align:#center enabled:false
		label lblLODDistMetric "* All distances in world units" align:#left offset:[0,6]
	)
	
	group "Current Active LOD:"
	(
		label lblLODNameTag "LOD Name: " across:2 align:#left enabled:false
		label lblLODName "None" align:#left offset:[-10, 0] enabled:false		
		spinner spnLODDist "Start Distance: " type:#float range:[0, 999999, 0] fieldwidth:58 enabled:false align:#right width:128 
		button btnFromViewport "Use Distance From Viewport" enabled:false
	)
	
	function GetLODDistance lodChild =
	(
		local minValue = getUserProp lodChild LOD_DISTANCE
		if minValue == undefined then return LOD_MINIMUM_VALUE else return minValue
	)

	function sortbyloddistance roots =
	(
		local sortedarray = #()
		local sorteddistances = #()
		local fLastLOD = -1.0
		local index = 1
		local fLastMin = -1.0
		for root in roots do
		(
			fDist = GetLODDistance root
			append sorteddistances fDist
		)
		
		sort sorteddistances
		
		for distance in sorteddistances do
		(
			for root in roots do
			(
				fDist = GetLODDistance root
				if fDist == distance then append sortedarray root
			)
		)
		
		return sortedarray
	)
	
	function SetLODDistance lodChild value =
	(
		setUserProp lodChild LOD_DISTANCE value
		sortedLODChildren = sortbyloddistance ActiveLODRoot.children
	)
	
	function GetRootsFromSelection =
	(
		local SelectedRoots = #()
		for obj in selection do -- values for each selected object 
		(
			local bFound = false
			for root in SelectedRoots do
			(
				if root == obj then bFound = true
			)
			
			if bFound == false then append SelectedRoots obj
		)
		return SelectedRoots
	)
	
	function IsLODRoot root =
	(
		if root == undefined then return false
		local lodGroup = GetUserProp root LOD_BASE_NAME
		if lodGroup != true then return false else return true	
	)
	
	
	
	mapped function Show obj =
	(
		if obj.isHidden then unhide obj
		Show obj.children
	)
	
	function ShowAll =
	(
		ViewMatchTimer.active = false
		print "Showing all..."
		show ActiveLODRoot
		show ActiveLODRoot.children
		completeRedraw()			
	)
	
	mapped function Unshow obj =
	(
		bShown = obj.isHidden
		bShown = not bShown
		if bShown then hide obj
		UnShow obj.children
	)
			
	function ShowActiveOnly =
	(
		ViewMatchTimer.active = false
		print "Show Active Only"
		show ActiveLODRoot
		show ActiveLODRoot.children
		for obj in ActiveLODRoot.children do
		(
			if (obj != ActiveLODChild and obj.name != ActiveLODRoot.name) then 
				unshow obj
		)
		completeRedraw()
	)
	
	function MatchViewport =
	(
		lastPos = [0.0,0.0,0.0]
		ViewMatchTimer.active = true
	)
	
	function IsLODChild child =
	(
		while child.parent != undefined do
		(
			if IsLODRoot child.parent then return true
			child = child.parent
		)
		return false
	)
	
	function GetNonLODRootsFromSelection = 
	(
		local aNonLODRoots = #()
		lodRoots = GetRootsFromSelection()
		for root in lodRoots do
		(
			local bAlreadyLOD = IsLodRoot root
			if bAlreadyLOD == false do
			(
				append aNonLODRoots root
			)
		)
		return aNonLODRoots
	)
	
	function AddNewObjToLODSet obj LODSet =
	(
		if obj.parent != undefined do local myParentNode = obj.Parent
			attachObjects LODSet obj move:false
		
		local bParentInGroup = false
		for myChild in LODSet.children do
			if myChild == myParentNode do bParentInGroup = true
			
		if (myParentNode != undefined) and (bParentInGroup == false) do
		(
			if isGroupHead myParentNode == true do
			(
				setGroupMember LODSet true
				for myChild in LODSet.children do setGroupMember myChild true
			)
			
			attachObjects myParentNode LODSet move:false
		)
		bSetDist = false
		distance = 0.0
		if SortedLODChildren == undefined or SortedLODChildren.count == 0 do
		(
			bSetDist = true
			SortedLODChildren = #(obj)
		)
		if bSetDist == false do
		(
			currentmax = SortedLODChildren[SortedLODChildren.count]
			distance = GetLODDistance currentmax
			distance = distance + 50
		)
		
		setUserProp obj LOD_DISTANCE distance
		SortedLODChildren = SortByLODDistance ActiveLODRoot.children
	)
	
	function AttachObjToNode obj node bMove =
	(
		attachObjects node obj move:bMove
	)

	function RemoveObjFromLODSet obj LODSet =
	(
		if IsLODChild obj then obj.parent = LODSet.parent
	)

	function CalcPosition lodRoots =
	(
		local iCount = 0.0
		local returnPos = [0.0, 0.0, 0.0]
		for root in lodRoots do
		(
			if root.pos != undefined do
			(
				returnPos = root.pos + returnPos
				iCount = iCount + 1.0
			)
		)
		
		if iCount > 1 do
		(
			returnPos = returnPos / iCount
		)
		
		return returnPos
	)
	
	function AppendToArray items newItem = 
	(
		local array = #()
		for item in items do append array item
		append array newItem
		return array
	)
	
	function MakeLodString name distance =
	(
		return name + " (" + distance + ")"
	)
	
	function GetIndex array item = 
	(
		local index = 1
		for obj in array do
		(
			if obj == item then 
				return index 
			else 
				index = index + 1
		)
		return undefined
	)
	
	function updateUI = 
	(
		if IsValidNode ActiveLODRoot == false then
		(
			ActiveLODRoot = undefined
			comboSetName.selection = comboSetName.items.count
		)
					
		TempItemsArray = #()
		for i = comboSetName.items.count to 1 by -1 do
		(
			if isValidNode(getNodeByName(comboSetName.items[i])) == false then
			(
				deleteItem comboSetName.items i			
			)
		)
		
		-- Have to do this hacked array-copy-copy because the .items array doesn't seem to want to reflect the fact 
		-- that an entry as been deleted.
		TempItemsArray = comboSetName.items
		comboSetName.items = #()
		comboSetName.items = TempItemsArray
		
		--If the ActiveLODRoot still exists set the combo box to it. Else set it to the highest index in the array
		try
		(
			comboSetName.selection = GetArrayIndex comboSetName.items ActiveLODRoot.name
		)
		catch
		(
			comboSetName.selection = comboSetName.items.count
		)
		if ActiveLODRoot == undefined do
		(
			comboSetName.enabled = false 
			btnAddToSet.enabled = false
			btnRemoveFromSet.enabled = false
			local childArray = #()			
			lbxLODChildren.enabled = false	
			lbxLODChildren.items = childArray
			btnShowState.enabled = false
			lblLODNameTag.enabled = false
			lblLODName.enabled = false
			spnLODDist.enabled = false
   			btnAttachToActiveLOD.enabled = false
			btnFromViewport.enabled = false
		)
		if ActiveLODRoot != undefined do
		(
			comboSetName.enabled = true 
			comboSetName.selection = GetIndex comboSetName.items ActiveLODRoot.name
			btnAddToSet.enabled = true
			btnRemoveFromSet.enabled = true
			btnAttachToActiveLOD.enabled = true
			
			local childArray = #()			
			SortedLODChildren = SortByLODDistance ActiveLODRoot.children
			for root in SortedLODChildren do 
			(
				dist = (GetLODDistance root) as string
				name = root.name 
				value = MakeLODString name dist
				append childArray value
			)
			
			if childArray.count > 0 do
			(
				spnLODDist.enabled = true
				spnLODDist.value = GetLODDistance ActiveLODChild
				lbxLODChildren.enabled = true	
				lbxLODChildren.items = childArray
				value = MakeLODString ActiveLODChild.name (spnLODDist.value as string)
				lbxLODChildren.selection = GetIndex lbxLODChildren.items value
				btnShowState.enabled = true
				lblLODNameTag.enabled = true
				lblLODName.enabled = true
				lblLODName.caption = ActiveLODChild.name
				btnFromViewport.enabled = true
				
				if btnShowState.state == 1 do (ShowAll())
				if btnShowState.state == 2 do (ShowActiveOnly ())
				if btnShowState.state == 3 do (MatchViewport())
			)
		)
	)
	
	on btnCreateFromSelection pressed do
	(
		for i = 1 to selection.count do
		(
			if selection[i].parent != undefined do
			(
				myParent = selection[i].parent
				for  j = i+1 to selection.count do
				(
					if (selection[j].parent != myParent) and (selection[j].parent != selection[i]) do
					(
						messageBox "The selected objects are not related.\r\nThey can not be in the same LODGroup." title:"LODHelpers"
						return false
					)
				)
			)
		)
		
		local lodRoots = GetNonLODRootsFromSelection()	-- this is an array
        if lodRoots.count == 0 then return false
		local NewLODName = uniqueName LOD_BASE_NAME
		local NewLODPosition = CalcPosition lodRoots
		local NewLOD = Dummy name:NewLODName pos:NewLODPosition
		setUserProp NewLOD LOD_BASE_NAME true
		ActiveLODRoot = NewLOD	
		local items = AppendToArray comboSetName.items NewLODName
		sort items
		comboSetName.items = items
	
		for root in lodRoots do 
		(
			AddNewObjToLODSet root NewLOD
			if cbCenterLOD.checked do root.pos = NewLODPosition
		)
		ActiveLODChild = lodRoots[1]
		UpdateUI()			
		select NewLOD
		if isGroupMember NewLOD == true do
		(
			myGroupHead = NewLOD.parent
			if isOpenGroupHead myGroupHead == true do
			(
				setGroupOpen myGroupHead false
				setGroupOpen myGroupHead true
			)
		)
			
		return true
	)
	
	on btnAddToSet pressed do
	(
		if ActiveLODRoot != undefined do
		(
			local lodRoots = GetNonLODRootsFromSelection()
			if lodRoots.count == 0 then return false
			
			for root in lodRoots do 
			(
				AddNewObjToLODSet root ActiveLODRoot 
				if cbCenterLOD.checked do root.pos = ActiveLODRoot.pos
			)
			
			UpdateUI()
		)
	)
	
	on btnRemoveFromSet pressed do
	(
		if ActiveLODRoot != undefined do
		(
			local lodChildren = #()
			for obj in selection do
			(
				while obj.parent != undefined do
				(
					if IsLODRoot obj.parent then append lodChildren obj 
					obj = obj.parent
				)
			)
			
			if lodChildren.count == 0 then return false
			
			for child in lodChildren do 
			(
				RemoveObjFromLODSet child ActiveLODRoot 
			)
			ActiveLODChild = ActiveLODRoot.children[1]
			UpdateUI()
		)
	)
	
	on  btnAttachToActiveLOD pressed do
	(
		for obj in selection do
		(
			AttachObjToNode obj ActiveLODChild cbCenterLOD.checked 
		)
	)
	
	on comboSetName selected item do
	(
		local LODName = comboSetName.items[item]
		ActiveLODRoot = getNodeByName LODName exact:true
		ActiveLODChild = ActiveLODRoot.children[1]
		UpdateUI()
	)
	
	on lbxLODChildren selected item do
	(
		local LODName = (SortedLODChildren[item]).name
		ActiveLODChild = getNodeByName LODName exact:true
		select ActiveLODChild
		print selection
		UpdateUI()
	)
	
	
	on btnShowState changed state do
	(
		-- 1) Show All
		-- 2) Show Active Only
		
		if state == 1 do
		(
			ShowAll()
		)
		
		if state == 2 do
		( 				
			ShowActiveOnly()
		)
		
		if state == 3 do
		(
			MatchViewport()
		)
	)
	
	on spnLODDist changed value do
	(
		print ActiveLODChild
		print SortedLODChildren
		if ActiveLODChild == undefined then return false
		
		curDist =  GetLODDistance ActiveLODChild
		if value == curDist then 
			return true
		
		bCanAdd = false
		index = 0
		for i = 1 to SortedLODChildren.count do
		(
			node = SortedLODChildren[i]
			
			nodeDist = GetLODDistance node
			if nodeDist == value do
			(
				message = "You cannot have LODs appear at exactly the same distance!"
				messagebox message title:"LOD Distance Error"
				spnLODDist.value = curDist
				return false
			)
			
			if node == ActiveLODChild do
			( 
				index = i
				exit
			)
		)
		if index != 0 do
		(
			minValue = -0.00001
			maxValue = 999999999.0
						
			if (value > minValue and value < maxValue) do
			(
				SetLODDistance ActiveLODChild value
				UpdateUI()
				bCanAdd = true					
			)
			if bCanAdd == false then spnLODDist.value = curDist
		)
	)
	
	function CalculateDistanceFromActiveView obj =
	(
		if viewport.numViews == 0 then return undefined
		local coordSysTM = Inverse(getViewTM()) 
		-- get the view position from this matrix 
		local viewPt = coordSysTM.row4 
		

		local objPt = in coordsys world obj.transform.translationpart
		d = distance viewPt objPt
		print "CalculateDistanceFromActiveView..."
		print "Object:"
		print obj
		print "Positions:"
		print viewPt
		print objPt
		print "Distance: "
		print d
		return d
	)
	
	function GetLODChildMatchingDistance distance = 
	(
		ChildStart = undefined
		for i = 1 to sortedLODChildren.count do
		(
			child = sortedLODChildren[i]
			if child != undefined do
			(
				childdist = GetLODDistance child
				if childdist <= distance then ChildStart = child
				if childdist > distance then exit
			)
		)
		
		return ChildStart
	)
	
	on btnFromViewport pressed do
	(
		sortedLODChildren = sortbyloddistance ActiveLODRoot.children
		print "btnfromviewport.."
		print sortedlodchildren
		print "calc distance"
		local distance = CalculateDistanceFromActiveView ActiveLODRoot
		print "perusing distances..."
		if distance != undefined do
		(
			for child in SortedLODChildren do
			(
				if child != ActiveLODChild do
				(
					tempdist = GetLODDistance child
					diff = tempdist - distance
					diff = abs diff
					if diff <= 0.001 do
					(
						print "distance collision.." 
						distance = distance + 1.0
						print distance
					)
				)
			)
			print "setting distance.."
			print distance
			SetLODDistance ActiveLODChild distance
			UpdateUI()
		)
	)
	
	
	function RefreshLODGroups myParent = 
	(	
		print "Refresh LOD Groups..."
		for child in myParent.children do
		(
			if IsLODRoot child do
			(
				append LODRoots child.name
				LODRootCount = LODRootCount + 1
			)
			if child.children.count > 0 do	RefreshLODGroups child
		)
	)
	
	function PopulateSetName = 
	(
		if LODRootCount > 0 do
		(
			sort LODRoots
			ActiveLODRoot = getNodeByName LODRoots[1] exact:true
			ActiveLODChild = ActiveLODRoot.children[1]
			print "ActiveLODRoot: "
			print ActiveLODRoot
			print "ActiveLODRoot.children: "
			print ActiveLODRoot.children
			print "ActiveLODChild: "
			print ActiveLODChild
			comboSetName.items = LODRoots
			UpdateUI()
		)
		if LODRootCount == 0 do
		(
			ActiveLODRoot = undefined
			ActiveLODChild = undefined
			UpdateUI()
		)
	)
	
	on ViewMatchTimer tick do
	(
		if viewport.numViews == 0 then return false
		local coordSysTM = Inverse(getViewTM()) 
		local viewPt = coordSysTM.row4 
		if viewPt == lastPos then return false
		lastPos = viewPt
		local distance = CalculateDistanceFromActiveView ActiveLODRoot
		TempLODChild = GetLODChildMatchingDistance distance
		if TempLODChild != undefined do
		( 
			show ActiveLODRoot
			show ActiveLODRoot.children
			for obj in ActiveLODRoot.children do
			(
				if (obj != TempLODChild and obj.name != ActiveLODRoot.name) then 
					unshow obj
			)
		)
		completeRedraw()
	)
	
	on NiLODRollout open do
	(
		--Reset LODRootCount and LODRoots before starting to regather them.
		LODRootCount = 0
		LODRoots = #()
		
		RefreshLODGroups root
		PopulateSetName()
	)
	
    on NiLODRollout close do
    (
        try(callbacks.removeScripts id:#LODUtilityCallbacks); catch()
    )

	on btnRefreshValues pressed do
	(
		--Reset LODRootCount and LODRoots before starting to regather them.
		LODRootCount = 0
		LODRoots = #()
		
		RefreshLODGroups root
		PopulateSetName()
	)
	
	function ResetUtility =
	(
	    LODUtility.root = rootNode
	    LODUtility.LODRootCount = 0
	    LODUtility.LODRoots.count = 0
	    LODUtility.ActiveLODRoot = undefined
	    LODUtility.ActiveLODChild = undefined
	    LODUtility.SortedLODChildren = undefined
	    LODUtility.UpdateUI()
	    LODUtility.RefreshLODGroups rootNode
	)
)
