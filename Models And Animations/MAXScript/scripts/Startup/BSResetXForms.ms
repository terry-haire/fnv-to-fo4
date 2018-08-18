fn GetXFormModIndex abNode =
(
	--Find XForm modifier on the mod stack
	modIndex = 1
	foundIndex = undefined
	while modIndex <= abNode.modifiers.count and foundIndex == undefined do
	(
		if classOf abNode.modifiers[modIndex] == XForm then foundIndex = modIndex
		modIndex += 1
	)
	
	foundIndex
)

fn ObjOffsetIsIdentity abNode =
(
	bvalid = false
	if abNode != undefined then
	(
		objpos = abNode.objectoffsetpos
		objrot = abNode.objectoffsetrot
		objscale = abNode.objectoffsetscale
		
		bvalid = objpos == [0,0,0] and (isIdentity objrot) and objscale == [1,1,1]
		
		/* For debugging
		if not bvalid then
		(
			print (abNode.name + " " + abNode.INode.handle as string + "\n")
			print (abNode.objectoffsetpos as string + "\n" + abNode.objectoffsetrot as string + "\n" + abNode.objectoffsetscale as string + "\n\n")
		)*/
	)
	
	bvalid
)

fn GetAllInvalidNodes =
(
	invalidList = #()
	invalidList = for o in objects where (not (ObjOffsetIsIdentity o) or (GetXFormModIndex o) != undefined) collect o
)

fn FixXFormOnNode abNode =
(
	--Only run this on 'bad' nodes.
	if abNode != undefined and not (ObjOffsetIsIdentity abNode) then
	(
		print ("Fixing XForm for: " + abNode.name)
		
		--Don't detach from parent so that we reset to the parent space.
		
		--Gather and detach children from this
		local mychildren = #()
		for child in abNode.children do
		(
			append mychildren child
			deleteItem abNode.children child
		)
		
		--Find XForm modifier on the mod stack
		foundIndex = GetXFormModIndex abNode
		
		--If none found, add an xform modifer on this node.
		if foundIndex == undefined then 
		(
			ResetXForm abNode
			foundIndex = 1
		)
		
		--Collapse xform
		maxops.CollapseNodeTo abNode foundIndex true
		
		--Reattach children
		for child in mychildren do (append abNode.children child)
	)
)

fn FixXFormsOnHierarchyRecursive abRoot abFixDescendents:false =
(
	if abRoot != undefined then
	(
		if abRoot != rootnode then
			FixXFormOnNode abRoot
		
		--Run this on children
		if abFixDescendents or abRoot == rootnode then
			for child in abRoot.children do FixXFormsOnHierarchyRecursive child abFixDescendents:abFixDescendents
	)
)

--Use above recursively
fn FixXFormsOnHierarchy abRoot abFixDescendents:false =
(
	--Disable autokey mode (or xform adjustments get baked into keys -- OH NO).
	with animate off
	(
		FixXFormsOnHierarchyRecursive abRoot abFixDescendents:abFixDescendents
	)
)

macroScript BSFixXForms category:"Bethesda" tooltip:"BS FixXForms"
(
	local invalidList = #()
	filteredMap = #()
	rollout RO_BSXForms "Detect and Fix XForms" width:553 height:432
	(
		multiListBox mlbInvalidList "Nodes with invalid XForms:" pos:[23,35] width:240 height:12
		button btnRefresh "Refresh" pos:[33,225] width:220 height:19
		button btnFix "Fix XForms (CANNOT UNDO)" pos:[33,316] width:220 height:33
		radiobuttons rdoFixOptions "Fix Which Nodes:" pos:[37,262] width:65 height:46 labels:#("All", "Selected") default:1 columns:1
		checkbox chkDescendents "Fix All Descendents" pos:[136,282] width:116 height:18
		edittext edtFilter "" pos:[52,10] width:212 height:20
		label lblFilter "Filter:" pos:[23,12] width:29 height:18
		
		local sFilter = ""
		
		fn CompareNodeByNameFN o1 o2 =
		(
			ret = 0
			if o1.name < o2.name then ret = -1
			else if o1.name > o2.name then ret = 1
				
			ret
		)
		
		fn UpdateInvalidList abRefresh:true =
		(
			if abRefresh then
			(
				invalidList = GetAllInvalidNodes()
				qsort invalidList CompareNodeByNameFN
			)
			
			if sFilter != "" then
			(
				filteredMap = #()
				for i = 1 to invalidList.count do
				(
					item = invalidList[i]
					if (findString item.name sFilter != undefined) then
					(
						print item.name
						append filteredMap #(item.name, i)
					)
				)
				
				invalidNames = for tuple in filteredMap collect tuple[1]
			)
			else 
				invalidNames = for o in invalidList collect o.name
			
			if mlbInvalidList.selection.numberSet > 0 then
				mlbInvalidList.selection = #{}
				
			mlbInvalidList.items = invalidNames
		)
		
		on RO_BSXForms open do
		(
			UpdateInvalidList()
		)
		on btnRefresh pressed do
		(
			UpdateInvalidList()
		)
		on edtFilter changed arg do
		(
			sFilter = arg
			UpdateInvalidList abRefresh:false
		)
	)

	if RO_BSXForms.indialog == true then
	(
		destroydialog RO_BSXForms
	)
	
	--createdialog RO_BSXForms width:284 height:360 style:#(#style_border, #style_toolwindow, #style_sysmenu)

	
	FixXFormsOnHierarchy $ abFixDescendents:true
)