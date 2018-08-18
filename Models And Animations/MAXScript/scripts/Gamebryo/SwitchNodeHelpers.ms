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

	rollout NiSwitchNodeRollout "Gamebryo Switch Node"  
	(
		-- Defining the strings that this utility uses
	    local SwitchNode_BASE_NAME = "NiSwitchNode"
	    local SwitchNode_ACTIVE_CHILD = "Index"
	    local SwitchNode_UPDATE_ONLY_ACTIVE = "UpdateOnlyActive"

		-- Defining our active variables
		local ActiveSwitchNodeRoot = undefined
		local SelectedSwitchNodeChild = undefined
		local ActiveSwitchNodeChild = undefined
		local SortedSwitchNodeChildren = undefined
			
		button btnRefreshValues "Refresh Switch Sets" width:128 align:#center
			
		group "Switch Node Set Creation:"
		(
			checkbox cbCenterSwitchNode "Recenter objects when" checked:true width:128 align:#center
			label lblCenterSwitchNode "they are added to a set" width:128 align:#center offset:[19, -4]
			button btnCreateFromSelection "Create From Selection" width:128  align:#center
		)
		
		group "Current Switch Node Set:"
		(
		    dropdownlist comboSetName "Set Name:" enabled:false
			dropdownlist comboActiveChildName "Active Child Name:" enabled:false
			checkbox cbUpdateOnlyActive "Only Update Active Child" enabled:false
			
			label lblSwitchNodeChildren "Child Nodes:" align:#left offset:[0,6]
			listbox lbxSwitchNodeChildren "" height:10 enabled:false offset:[0, -4]
			
			button btnMoveUp "Move Up" width:75 align:#center across:2 enabled:false
			button btnMoveDown "Move Down" width:75 align:#center enabled:false
			
			radiobuttons btnShowState labels:#("Show All","Show Selected Only") enabled:false align:#center offset:[0,6]

			button btnAddToSet "Add Selection To Set" width:128  align:#center enabled:false
			button btnRemoveFromSet "Remove Sel. From Set" width:128 align:#center enabled:false
		)
		
		
		-- Helper functions
		--------------------------------------------------------------------------------------
		function GetRootsFromSelection =
		(
			local SelectedRoots = #()
			for obj in selection do -- values for each selected object 
			(
				local bFound = false
				while obj.parent != undefined do obj = obj.parent 
				for root in SelectedRoots do
				(
					if root == obj then bFound = true
				)
				
				if bFound == false then append SelectedRoots obj
			)
			return SelectedRoots
		)
		
		function IsSwitchNodeRoot root =
		(
			if root == undefined then return false
			local SwitchNodeGroup = GetUserProp root SwitchNode_BASE_NAME
			if SwitchNodeGroup != true then return false else return true	
		)
		
		mapped function Show obj =
		(
			if obj.isHidden then unhide obj
			Show obj.children
		)
		
		function ShowAll =
		(
			print "Showing all..."
			show ActiveSwitchNodeRoot
			show ActiveSwitchNodeRoot.children
			completeRedraw()			
		)
		
		mapped function Unshow obj =
		(
			bShown = obj.isHidden
			bShown = not bShown
			if bShown then hide obj
			UnShow obj.children
		)
				
		function ShowSelectedOnly =
		(
			print "Show Active Only"
			show ActiveSwitchNodeRoot
			show ActiveSwitchNodeRoot.children
			for obj in ActiveSwitchNodeRoot.children do
			(
				if (obj != SelectedSwitchNodeChild and obj.name != ActiveSwitchNodeRoot.name) then 
					unshow obj
			)
			completeRedraw()
		)
		
		function GetActiveSwitchNodeChild root =
		(
			index = getUserProp root SwitchNode_ACTIVE_CHILD
			if index == undefined do
			(
				return undefined
			)
			
			return root.children[index + 1]
			
		)
		
		function SetActiveSwitchNodeChild root activechild =
		(
			i = 1
			for child in root.children do
			(
				if child == activechild then exit
				
				i = i + 1
			)
			
			i = i - 1
			setUserProp root SwitchNode_ACTIVE_CHILD i
		)
		
		function GetUpdateOnlyActiveChild root =
		(
			value = getUserProp root SwitchNode_UPDATE_ONLY_ACTIVE
			if value == undefined do
			(
				return true
			)
			
			return value
			
		)
		
		function SetUpdateOnlyActiveChild root state =
		(
			setUserProp root SwitchNode_UPDATE_ONLY_ACTIVE state
		)
		
		
		function SortBySwitchNode roots =
		(
			local sortedarray = #()
			for root in roots do
			(
				append sortedarray root
			)
			
			return sortedarray
		)
		
		function IsSwitchNodeChild child =
		(
			while child.parent != undefined do
			(
				if IsSwitchNodeRoot child.parent then return true
				child = child.parent
			)
			return false
		)
		
		function GetNonSwitchNodeRootsFromSelection = 
		(
			local aNonSwitchNodeRoots = #()
			SwitchNodeRoots = GetRootsFromSelection()
			for root in SwitchNodeRoots do
			(
				local bAlreadySwitchNode = IsSwitchNodeRoot root
				if bAlreadySwitchNode == false do
				(
					append aNonSwitchNodeRoots root
				)
			)
			return aNonSwitchNodeRoots
		)
		
		function AddNewObjToSwitchNodeSet obj SwitchNodeSet =
		(
			attachObjects SwitchNodeSet obj move:false
			if SortedSwitchNodeChildren == undefined or SortedSwitchNodeChildren.count == 0 do
			(
				SortedSwitchNodeChildren = #(obj)
			)
			
			SortedSwitchNodeChildren = SortBySwitchNode ActiveSwitchNodeRoot.children
		)
		
		function AttachObjToNode obj node bMove =
		(
			attachObjects node obj move:bMove
		)

		function RemoveObjFromSwitchNodeSet obj SwitchNodeSet =
		(
			if IsSwitchNodeChild obj then obj.parent = SwitchNodeSet.parent
		)

		function CalcPosition SwitchNodeRoots =
		(
			local iCount = 0.0
			local returnPos = [0.0, 0.0, 0.0]
			for root in SwitchNodeRoots do
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
		
		
		-- UI Handler Routines
		----------------------------------------------------------------------------------------
		function updateUI = 
		(
			print "Updating UI..."
			if ActiveSwitchNodeRoot == undefined do
			(
				comboSetName.enabled = false 		
				btnAddToSet.enabled = false
				btnRemoveFromSet.enabled = false
				local childArray = #()			
				comboActiveChildName.enabled = false
				comboActiveChildName.items = childArray	
				cbUpdateOnlyActive.enabled = false	
				cbUpdateOnlyActive.checked = true	
				lbxSwitchNodeChildren.enabled = false	
				lbxSwitchNodeChildren.items = childArray
				btnShowState.enabled = false
				
				btnMoveUp.enabled = false
				btnMoveDown.enabled = false

				
			)
			if ActiveSwitchNodeRoot != undefined do
			(
				comboSetName.selection = GetIndex comboSetName.items ActiveSwitchNodeRoot.name
				comboSetName.enabled = true 
				
				btnAddToSet.enabled = true
				btnRemoveFromSet.enabled = true
				
				cbUpdateOnlyActive.enabled = true
				cbUpdateOnlyActive.checked = GetUpdateOnlyActiveChild ActiveSwitchNodeRoot
				
				local childArray = #()			
				SortedSwitchNodeChildren = SortBySwitchNode ActiveSwitchNodeRoot.children
				for root in SortedSwitchNodeChildren do 
				(
					append childArray (root.name as string)
				)
				
				if childArray.count > 0 do
				(
					comboActiveChildName.enabled = true
					comboActiveChildName.items = childArray
					comboActiveChildName.selection = GetIndex comboActiveChildName.items ActiveSwitchNodeChild.name

					lbxSwitchNodeChildren.enabled = true	
					lbxSwitchNodeChildren.items = childArray
					lbxSwitchNodeChildren.selection = GetIndex lbxSwitchNodeChildren.items SelectedSwitchNodeChild.name
					btnShowState.enabled = true
					
					if btnShowState.state == 1 do (ShowAll())
					if btnShowState.state == 2 do (ShowSelectedOnly ())
					
					btnMoveUp.enabled = true
					btnMoveDown.enabled = true
						
					if SelectedSwitchNodeChild == ActiveSwitchNodeRoot.children[1] do
					(
						btnMoveUp.enabled = false
						btnMoveDown.enabled = true
					)
					
					if SelectedSwitchNodeChild == ActiveSwitchNodeRoot.children[ActiveSwitchNodeRoot.children.count] do
					(
						btnMoveUp.enabled = true
						btnMoveDown.enabled = false
					)
					
				)
			)
		)
		
		on btnShowState changed state do
		(
			-- 1) Show All
			-- 2) Show Selected Only
			
			if state == 1 do
			(
				ShowAll()
			)
			
			if state == 2 do
			( 				
				ShowSelectedOnly()
			)
			
		)
		
				
		function RefreshSwitchNodeGroups = 
		(	
			print "Refresh SwitchNode Groups..."
			local root = rootNode
			local SwitchNodeRootCount = 0
			local SwitchNodeRoots = #()
			for child in root.children do
			(
				if IsSwitchNodeRoot child do
				(
				 	append SwitchNodeRoots child.name
					SwitchNodeRootCount = SwitchNodeRootCount + 1
				)
			)
			
			if SwitchNodeRootCount > 0 do
			(
				sort SwitchNodeRoots
				ActiveSwitchNodeRoot = getNodeByName SwitchNodeRoots[1] exact:true
				SelectedSwitchNodeChild = ActiveSwitchNodeRoot.children[1]
				ActiveSwitchNodeChild = GetActiveSwitchNodeChild ActiveSwitchNodeRoot
				print "ActiveSwitchNodeRoot: "
				print ActiveSwitchNodeRoot
				print "ActiveSwitchNodeRoot.children: "
				print ActiveSwitchNodeRoot.children
				print "SelectedSwitchNodeChild: "
				print SelectedSwitchNodeChild
				comboSetName.items = SwitchNodeRoots
				UpdateUI()
			)
			if SwitchNodeRootCount == 0 do
			(
				ActiveSwitchNodeRoot = undefined
				SelectedSwitchNodeChild = undefined
				ActiveSwitchNodeChild = undefined
				UpdateUI()
			)
		)
		
		on btnCreateFromSelection pressed do
		(
			local SwitchNodeRoots = GetNonSwitchNodeRootsFromSelection()
			if SwitchNodeRoots.count == 0 then return false
			local NewSwitchNodeName = uniqueName SwitchNode_BASE_NAME
			local NewSwitchNodePosition = CalcPosition SwitchNodeRoots
			local NewSwitchNode = Dummy name:NewSwitchNodeName pos:NewSwitchNodePosition
			setUserProp NewSwitchNode SwitchNode_BASE_NAME true
			ActiveSwitchNodeRoot = NewSwitchNode	
			local items = AppendToArray comboSetName.items NewSwitchNodeName
			sort items
			comboSetName.items = items
		
			for root in SwitchNodeRoots do 
			(
				AddNewObjToSwitchNodeSet root NewSwitchNode
				if cbCenterSwitchNode.checked do root.pos = NewSwitchNodePosition
			)
			SelectedSwitchNodeChild = SwitchNodeRoots[1]
			ActiveSwitchNodeChild = SelectedSwitchNodeChild
			SetActiveSwitchNodeChild ActiveSwitchNodeRoot ActiveSwitchNodeChild
			SetUpdateOnlyActiveChild ActiveSwitchNodeRoot true
			
			UpdateUI()			
			select NewSwitchNode
			return true
		)
		
		on cbUpdateOnlyActive changed state do 
		(
			SetUpdateOnlyActiveChild ActiveSwitchNodeRoot state
		)
		
		on btnMoveUp pressed do
		(
			childList = #()
			
			for child in ActiveSwitchNodeRoot.children do
			(
				append childList child
				child.parent = undefined
			)
			
			for i = 1 to childList.count do
			(
				bIsCurrent = childList[i] == SelectedSwitchNodeChild
				bIsJustBefore = false
				if i < childList.count do
				(
					bIsJustBefore = childList[i+1] == SelectedSwitchNodeChild
				)
				
				if bIsCurrent == true do
				(
					
				)
				if bIsJustBefore == true do
				(
					attachObjects ActiveSwitchNodeRoot childList[i+1] move:false 
					attachObjects ActiveSwitchNodeRoot childList[i] move:false 
				)
				if bIsCurrent != true and bIsJustBefore != true do
				(
					attachObjects ActiveSwitchNodeRoot childList[i] move:false 
				)
				
			)
			UpdateUI()
		)
		
		on btnMoveDown pressed do
		(
			childList = #()
			
			for child in ActiveSwitchNodeRoot.children do
			(
				append childList child
				child.parent = undefined
			)
			
			for i = 1 to childList.count do
			(
				bIsCurrent = childList[i] == SelectedSwitchNodeChild
				bIsJustAfter = false
				if i > 1 do
				(
					bIsJustAfter = childList[i-1] == SelectedSwitchNodeChild
				)
				
				if bIsCurrent == true do
				(
					attachObjects ActiveSwitchNodeRoot childList[i+1] move:false 
				)
				
				if bIsJustAfter == true do
				(
					attachObjects ActiveSwitchNodeRoot childList[i-1] move:false 
				)
				
				if bIsCurrent != true and bIsJustAfter != true do
				(
					attachObjects ActiveSwitchNodeRoot childList[i] move:false 
				)
				
			)
			UpdateUI()
		)
		
		on btnAddToSet pressed do
		(
			if ActiveSwitchNodeRoot != undefined do
			(
				local SwitchNodeRoots = GetNonSwitchNodeRootsFromSelection()
				if SwitchNodeRoots.count == 0 then return false
				
				for root in SwitchNodeRoots do 
				(
					AddNewObjToSwitchNodeSet root ActiveSwitchNodeRoot 
					if cbCenterSwitchNode.checked do root.pos = ActiveSwitchNodeRoot.pos
				)
				
				UpdateUI()
			)
		)
		
		on btnRemoveFromSet pressed do
		(
			if ActiveSwitchNodeRoot != undefined do
			(
				local SwitchNodeChildren = #()
				for obj in selection do
				(
					while obj.parent != undefined do
					(
						if IsSwitchNodeRoot obj.parent then append SwitchNodeChildren obj 
						obj = obj.parent
					)
				)
				
				if SwitchNodeChildren.count == 0 then return false
				bResetActiveChild = false
				
				for child in SwitchNodeChildren do 
				(
					if child == ActiveSwitchNodeChild then bResetActiveChild = true
					RemoveObjFromSwitchNodeSet child ActiveSwitchNodeRoot 
				)
				SelectedSwitchNodeChild = ActiveSwitchNodeRoot.children[1]
				ActiveSwitchNodeChild = SelectedSwitchNodeChild
				SetActiveSwitchNodeChild ActiveSwitchNodeRoot ActiveSwitchNodeChild
				UpdateUI()
			)
		)
		
		on comboSetName selected item do
		(
			local SwitchNodeName = comboSetName.items[item]
			ActiveSwitchNodeRoot = getNodeByName SwitchNodeName exact:true
			ActiveSwitchNodeChild = GetActiveSwitchNodeChild ActiveSwitchNodeRoot
			SelectedSwitchNodeChild = ActiveSwitchNodeRoot.children[1]
			UpdateUI()
		)
		
		on comboActiveChildName selected item do
		(
			name = comboActiveChildName.items[item]
			tempNode = getNodeByName name exact:true
			if tempNode != undefined do
			(
				ActiveSwitchNodeChild = tempNode
				SetActiveSwitchNodeChild ActiveSwitchNodeRoot ActiveSwitchNodeChild
				UpdateUI()
			)
		)
		
		on lbxSwitchNodeChildren selected item do
		(
			local SwitchNodeName = (SortedSwitchNodeChildren[item]).name
			SelectedSwitchNodeChild = getNodeByName SwitchNodeName exact:true
			select SelectedSwitchNodeChild
			print selection
			UpdateUI()
		)
		
		on NiSwitchNodeRollout open do
		(
			RefreshSwitchNodeGroups()
		)
		
        on NiSwitchNodeRollout close do
        (
            try(callbacks.removeScripts #filePostOpen id:#SwitchNodeUtilPostOpen); catch()
	        try(callbacks.removeScripts #filePreOpen id:#SwitchNodeUtilPreOpen); catch()
            try(callbacks.removeScripts #systemPreReset id:#SwitchNodeUtilPreReset); catch()	        
        )

		on btnRefreshValues pressed do
		(
			RefreshSwitchNodeGroups()		
		)
	)
	