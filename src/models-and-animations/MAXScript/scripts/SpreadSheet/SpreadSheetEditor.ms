macroScript SpreadSheetEditor

	category:"Bobo_s Tools" 
	buttontext:"SpreadSheet"
	tooltip:"SpreadSheet Editor"
(
---------------------------------------------------------------------
--SPREADSHEET EDITOR
--Beta 0.6.0
--Started: 05/01/2002
--Edited : 12/09/2004
--Code by Borislav Petrov
--bobo@franticfilms.com
---------------------------------------------------------------------
--SHORT DESCRIPTION:
--SpreadSheet view and control over common object properties
--Flexible & expandable core system.
---------------------------------------------------------------------
--New in 0.6.0
--*BUG FIX AND BIG CHANGE: Fixed the typo in the global Layour array - "SpreadSeet" has been fixed to "SpreadSheet".
--Note that you will have to manually edit your own Layouts to the new correct name. Sorry for the trouble!
--*Changed the installation folder to be a sub-folder of the /Scripts directory. 
--This also means that all calls to Filters from inside of Layouts should use the new path "\Scripts\SpreadSheet\Filters\..."
--*BUG FIX: Fixed the Column Width setting code to respect the first column width (Object Name) from the Layout.
--In previous versions, the first column had always a fixed width.
--*Added HELP item to the Menu linking to the SSE WebPage, Boboland and ScriptSpot.com
--*BUG FIX: Fixed Dialog Style bug to work in Max 6 and 7

--New in 0.5.2
--*Added (a rather hacked) support for Get/Set Function Calls!!!
--*Older versions of SSE supported GETTING but not settting of values via function calls 
--using () in the property name. 
--
--*This goes a step further and works as follows:
--If you want to use two different functions to get and set values that
--are not .properties of the object, you can create your own functions,
--and tell SSE to use them. 
--The get function should start with the characters "Get" and will be passed the
--Object to get the value from. 
--The set function MUST start with the characters "Set" and will be passed the
--Object to get and the value to set.
--
--For example, to get and set an Object User Property called "Bobo", you could create
--the following functions in the beginning of the Layout accessing them:
--
--fn getUserPropBobo obj = (getUserProp obj "Bobo")
--fn setUserPropBobo obj val = (setUserProp obj "Bobo" val)
--
--Now in the Layout, you can call these functions using {} brackets.
--
--global SpreadSheet_Property_Editing = #(
--#("Object", "Object", " ", " ", 120, false),
--#("UserProp Bobo", "<UserProp Bobo>", "getUserPropBobo{}", "Float", 100, true)
--)
--You can have the value type as Boolean or Float just like any other property.
--SSE will first look for "{}" and if it finds them, it will know it has to call an external
--function. In the case of Getting a value, it will strip off the string from the "{}" first, then
--call the function by passing the current object.
--In the case of setting the value, it will first strip off the string from the "{}", then it
--will replace the first 3 characters ("get") with "set" and then call the result by passing
--the object and the value.
---------------------------------------------------------------------
--New in 0.5.1
--*Changed rollout sizing for max 5
---------------------------------------------------------------------
--New in 0.4.2
--*Better sorting of "--" entries (handled as lowest value now)
--*Reload Layout menu implementation was missing, fixed.
--*Fixed loading order so Layout will load first, then the last Filter will be applied
--overwriting the Layout's filter defaults.
---------------------------------------------------------------------
--New in 0.4.1
--*4.2 compatible! (UI might flicker when updating)
--*Fixed a crasher when showing selected with no filters available.
--*Made the "New Layout" function shadowGenerator - aware.
--*Column Highlight now persistent after Sorting and Filtering operations
--*Layout property can now be a function - add "()" to the end of the 3rd element to 
--evaluate as function instead of a property. See "Class" example in "General Object Props"
--*Filters can now be associated with Layouts so that Light Lister can filter Lights etc.
---------------------------------------------------------------------
--New in 0.3.2
--*Fixed crash when sorting non-existing values
---------------------------------------------------------------------
--New in 0.3.1
--*Added support for the ShadowGenerator property in lights. 
--*Fixed the nasty flickering of the selection
--*New menu bar provides space for much more options 
--*Sorting by name and properties
--*Selection synchronizing
--*Highlight column when selected 
---------------------------------------------------------------------
--New in 0.2.2
--*Relative property changes through UI and Mouse
--*Max Objects limit
--*Built-in selection filtering
--*Docking in Viewport, optional UI docking (remarked, see end of file)
--*Lots of cosmetic changes and bug fixes
---------------------------------------------------------------------



-----------------------
--Define some globals--
-----------------------
global spreadsheet_editor_rollout
global spreadsheet_object_data_array = #()
global SpreadSheet_Object_To_Change = undefined
global Spreadsheet_filter_function  

------------------------------------
--Define a default filter function--
------------------------------------
fn spreadsheet_filter_function obj =
(
	true
)

---------------------------
--Define a default layout--
---------------------------
global SpreadSheet_Property_Editing = #(
	#("Objects","Objects","Name","String",100,false),
	#("Hidden","HIDE","IsHidden","BooleanClass",65,true),
	#("Frozen","FREEZE","IsFrozen","BooleanClass",65,true)
)

-------------------------------
--Define some local variables--
-------------------------------
local rollout_pos = [100,200]
local rollout_size = [800,400]
local rollout_layout_mode = "None"
local rollout_filter_mode = "None"
local rollout_max_nodes = 100
local use_selection_mode = true

local last_header = 1
local sort_key_index = 1
local CheckRcMenuItems 

local filter_functions_list = #()
local filter_names_list = #()

local layout_functions_list = #()
local layout_names_list = #()

local sort_key_array = #()
local last_sort_key = 0
local last_sort_mode = 1


--------------------------------
--GENERAL FUNCTION DEFINITIONS--
--------------------------------

	fn uiLog txt =
	(
		spreadsheet_editor_rollout.ui_status.text = txt
	)
	
	fn getFilterFileNames =
	(
		filter_functions_list = GetFiles ((GetDir #maxroot)+"/Scripts/SpreadSheet/Filters/*.filter")
		filter_names_list = for i in filter_functions_list collect getfilenamefile i
	)

	fn getLayoutFileNames =
	(
		layout_functions_list = GetFiles ((GetDir #maxroot)+"/Scripts/SpreadSheet/Layouts/*.layout")
		layout_names_list = for i in layout_functions_list collect getfilenamefile i
	)

	----------------------------------------------------------
	--Defines the appearance of the ListView ActiveX control--
	----------------------------------------------------------
	fn initListView lv =
	(
		enableAccelerators = false
		lv.ListItems.clear()
		lv.Arrange = #lvwAutoLeft 
		lv.View =  #lvwList 			--( #lvwIcon | #lvwSmallIcon | #lvwList | #lvwReport )
		lv.Appearance = #cc3D 			--: AppearanceConstants( #ccFlat | #cc3D )
		lv.BorderStyle = 	#ccNone 	--: BorderStyleConstants( #ccNone | #ccFixedSingle )
		lv.FlatScrollBar = false 
		lv.HoverSelection = false
		lv.TextBackground = #lvwOpaque 	--: ListTextBackgroundConstants( #lvwTransparent | #lvwOpaque )
		
		lv.gridLines = true
		lv.view = #lvwReport
		lv.fullRowSelect = true
		lv.multiSelect = true
		lv.labelEdit = #lvwManual
		lv.hideSelection = false
		lv.sorted = false
		lv.sortorder = #lvwAscending
		lv.hideColumnHeaders = false
		lv.allowColumnReorder = true
		lv.HotTracking = false
		lv.checkboxes = false
		textColor = ((colorman.getColor #text)*255) as color
		windowColor = ((colorman.getColor #window)*255) as color
		lv.backColor = (color windowColor.b windowColor.g windowColor.r)
		lv.foreColor = (color textColor.b textColor.g textColor.r)

		cnt = lv.ColumnHeaders.count
		for i = 1 to cnt do
		(
			lv.ColumnHeaders.remove 1
		)

		for i in SpreadSheet_Property_Editing do
		(
			column = lv.ColumnHeaders.add()
			column.text = i[1]
		)
		
		LVM_FIRST = 0x1000
		LVM_SETCOLUMNWIDTH = (LVM_FIRST + 30)
		windows.sendMessage lv.hwnd LVM_SETCOLUMNWIDTH  0 100
		for i = 1 to SpreadSheet_Property_Editing.count do
		(
			windows.sendMessage lv.hwnd LVM_SETCOLUMNWIDTH  (i-1) (SpreadSheet_Property_Editing[i][5])
		)
	)
	
	fn getSelection lv =
	(
		sel = #()
		for i in 1 to lv.listItems.count do
		(
			li = lv.ListItems[i]
			if li.selected do append sel i
		)
		sel
	)
	
	fn collectObjectData use_selection=
	(
		spreadsheet_object_data_array = #()
		sort_key_array = #()		
		cnt = 0
		if use_selection then 
		(
			obj_array = selection as array 
			total_count = obj_array.count	
			if total_count > rollout_max_nodes then 
			(
				total_count = rollout_max_nodes
				UiLog ("Scanning first "+ rollout_max_nodes as string +" Selected Object(s)...")
			)	
			else	
			(
				UiLog ("Scanning "+ total_count as string +" Selected Object(s)...")
			)	
		)	
		else 
		(
			obj_array = objects as array 
			total_count = obj_array.count	
			if total_count > rollout_max_nodes then 
			(
				total_count = rollout_max_nodes
				UiLog ("Scanning first "+ rollout_max_nodes as string +" Scene Object(s)...")
			)	
			else	
			(
				UiLog ("Scanning "+ total_count as string +" Scene Object(s)...")
			)	
		)			
		for i = 1 to total_count do 
		(
			spreadsheet_editor_rollout.ui_progress.value = 100.0*i/total_count 
			if spreadsheet_filter_function obj_array[i] then
			(
				properties_array = #(obj_array[i])
				cnt += 1
				append sort_key_array cnt
				for j in SpreadSheet_Property_Editing do
				(
					SpreadSheet_Object_To_Change = obj_array[i]
					try
					(
						isFunction = findstring j[3] "()"
						isGetSetMethod = findstring j[3] "{}"
						if isFunction != undefined then
							current_value = execute ((substring j[3] 1 (isFunction-1)) +" SpreadSheet_Object_To_Change")
						else
							if isGetSetMethod != undefined then
								current_value = execute ((substring j[3] 1 (isGetSetMethod-1)) +" SpreadSheet_Object_To_Change")
							else
								current_value = execute ("SpreadSheet_Object_To_Change."+j[3])
					)
					catch
					(
						current_value = "--"
					)
					append properties_array current_value
				)
				deleteItem properties_array 2
				append spreadsheet_object_data_array properties_array
			)
		)--end i loop
	)
	

	fn fillInSpreadSheet lv =
	(
		spreadsheet_editor_rollout.lvSpreadSheet.ListItems.clear()
		total_count = spreadsheet_object_data_array.count
		UiLog ("Populating editor with "+ total_count as string +" Object(s)...")
		for i = 1 to total_count  do
		(
			index = sort_key_array[i]
			spreadsheet_editor_rollout.ui_progress.value = 100.0*i/total_count 
			li = lv.ListItems.add()
			li.text = spreadsheet_object_data_array[index][1].name
			for j = 2 to spreadsheet_object_data_array[index].count do
			(
				li2 = li.ListSubItems.add()
				li2.text = spreadsheet_object_data_array[index][j] as string 
			)	
		)
		UiLog ("Populated editor with "+ total_count as string +" Object(s).")
		spreadsheet_editor_rollout.ui_progress.value = 0.0		
	)
	
	fn compareNameFNUp v1 v2 valArray: =
	(
		try(if valArray[v1][1].name > valArray[v2][1].name then return 1 else return -1)catch(1)
	)

	fn compareNameFNDown v1 v2 valArray: =
	(
		try(if valArray[v1][1].name < valArray[v2][1].name then return 1 else return -1)catch(1)
	)
	
	
	
	fn compareStringFNUp v1 v2 valArray: =
	(
		val1 = valArray[v1][sort_key_index] as string
		if val1 == "--" then return -1
		val2 = valArray[v2][sort_key_index] as string
		if val2 == "--" then return 1
		try(if val1 > val2 then return 1 else return -1)catch(1)
		
--		try(if valArray[v1][sort_key_index] > valArray[v2][sort_key_index] then return 1 else return -1)catch(1)
	)

	fn compareStringFNDown v1 v2 valArray: =
	(
		val1 = valArray[v1][sort_key_index] as string
		if val1 == "--" then return 1
		val2 = valArray[v2][sort_key_index] as string
		if val2 == "--" then return -1
		try(if val1 < val2 then return 1 else return -1)catch(1)
	)
	
	
	
	fn compareValueFNUp v1 v2 valArray: =
	(
		try(if valArray[v1][sort_key_index] > valArray[v2][sort_key_index] then return 1 else return -1)catch(1)
	)

	fn compareValueFNDown v1 v2 valArray: =
	(
		val1 = valArray[v1][sort_key_index]
		if val1 == "--" then return 1
		val2 = valArray[v2][sort_key_index]		
		if val2 == "--" then return -1
		try(if val1 < val2 then return 1 else return -1)catch(1)
	)	



	fn resetSortKeyArray =
	(
		sort_key_array = #()
		for i = 1 to spreadsheet_object_data_array.count do append sort_key_array i
	)

	fn SortObjectDatabase sort_mode sort_key =
	(
		resetSortKeyArray()
		if sort_key == 0 then return OK
		sort_key_index = sort_key
		if sort_key_index == 1 then
		(
			case sort_mode of
			(
				1: qsort sort_key_array compareNameFNUp   valArray:spreadsheet_object_data_array 
				2: qsort sort_key_array compareNameFNDown valArray:spreadsheet_object_data_array 
			)
		)
		else
		(
			class_to_sort = SpreadSheet_Property_Editing[sort_key_index][4]
			if class_to_sort == "Float" or class_to_sort == "Integer" then
			(
				case sort_mode of
				(
					1: qsort sort_key_array compareValueFNUp   valArray:spreadsheet_object_data_array 
					2: qsort sort_key_array compareValueFNDown valArray:spreadsheet_object_data_array 
				)
			)	
			else
			(
				case sort_mode of
				(
					1: qsort sort_key_array compareStringFNUp   valArray:spreadsheet_object_data_array 
					2: qsort sort_key_array compareStringFNDown valArray:spreadsheet_object_data_array 
				)
			)	
		)	
--		fillInSpreadSheet spreadsheet_editor_rollout.lvSpreadSheet
	)	
		

	fn SynchSelectionFromScene mode =
	(
		if mode == 1 then fillInSpreadSheet spreadsheet_editor_rollout.lvSpreadSheet
		sel_set = selection as array
		for i = 1 to spreadsheet_object_data_array.count do
		(
			if findItem sel_set spreadsheet_object_data_array[sort_key_array[i]][1] > 0 then
			(
				spreadsheet_editor_rollout.lvSpreadSheet.selectedItem = spreadsheet_editor_rollout.lvSpreadSheet.ListItems[i] 
			)	
		)	
	)

	fn SelectAll =
	(
		for i = 1 to spreadsheet_object_data_array.count do
		(
			spreadsheet_editor_rollout.lvSpreadSheet.selectedItem = spreadsheet_editor_rollout.lvSpreadSheet.ListItems[i] 
		)	
	)


	fn updateValueToEdit lvSpreadSheet header index =
	(
		if header > 1 then
		(
			SpreadSheet_Object_To_Change = spreadsheet_object_data_array[sort_key_array[index]][1]
				if isValidNode SpreadSheet_Object_To_Change then 
				(
					try
					(
						val = execute  ("SpreadSheet_Object_To_Change."+SpreadSheet_Property_Editing[header][3])
						case ((classof val) as string) of
						(
							"Integer": spreadsheet_editor_rollout.lv_integer.value = val
							"Float": spreadsheet_editor_rollout.lv_float.value = val
							"BooleanClass": spreadsheet_editor_rollout.lv_boolean.state = val
							"Color": spreadsheet_editor_rollout.lv_color.color = val
						)
						--uiLog ("Value ["+ val as string +"] Acquired")				
					)catch()				
				)--end if valid	
		)
	)
	
	
	fn paintColumn column_index new_color bold_mode=
	(
		if column_index > 0 then
		(
			for i = 1 to spreadsheet_object_data_array.count do
			(
				spreadsheet_editor_rollout.lvSpreadSheet.ListItems[i].ListSubItems[column_index].forecolor = new_color
				spreadsheet_editor_rollout.lvSpreadSheet.ListItems[i].ListSubItems[column_index].bold = bold_mode
				
			)	
		)	
	)
	
	fn EditListContent lvSpreadSheet header item prop_class =
	(
		if header > 1 and SpreadSheet_Property_Editing[header][6] then
		(
			changed_counter = 0
			selected_items = getSelection lvSpreadSheet
			Property_name_to_change = SpreadSheet_Property_Editing[header][1]			
			
			if prop_class == "ShadowGenerator" then
			(
				case item of
				(
					1: shad_gen = "Area_Shadows()"
					2: shad_gen = "Adv__Ray_Traced()"
					3: shad_gen = "shadowMap()"
					4: shad_gen = "raytraceShadow()"
				)
			)	

			for i in selected_items do
			(
	  			SpreadSheet_Object_To_Change = spreadsheet_object_data_array[sort_key_array[i]][1]
				if isValidNode SpreadSheet_Object_To_Change then 
				(
					if prop_class == "ShadowGenerator" then
					(
						try
						(
							result = execute  ("SpreadSheet_Object_To_Change."+SpreadSheet_Property_Editing[header][3]+"= "+ shad_gen)
							spreadsheet_object_data_array[sort_key_array[i]][header] = result 
							lvSpreadSheet.listItems[i].ListSubItems[header-1].text = spreadsheet_object_data_array[sort_key_array[i]][header] as string 
							changed_counter += 1						
						)catch()				
					)
				)--end if valid	
			)--end i loop
			uiLog ("["+Property_name_to_change+"] Assigned ["+ shad_gen +"] in "+changed_counter as string + " of " + selected_items.count as string+" Object(s).")
		)--end if header > 1	
		
	)--end fn

	fn EditItemValue lvSpreadSheet header val rel_mode=
	(
		if header > 1 and SpreadSheet_Property_Editing[header][6] then
		(
			changed_counter = 0
			selected_items = getSelection lvSpreadSheet
			Property_name_to_change = SpreadSheet_Property_Editing[header][1]			
			total_count = selected_items.count
			cnt = 0
			uiLog ("Updating ["+Property_name_to_change+"] in " + total_count as string+" Object(s).")
			for i in selected_items do
			(
				cnt += 1
				spreadsheet_editor_rollout.ui_progress.value = 100.0*cnt/total_count 
	  			SpreadSheet_Object_To_Change = spreadsheet_object_data_array[sort_key_array[i]][1]
				if isValidNode SpreadSheet_Object_To_Change then 
				(
					if rel_mode == 1 then
					(
						try
						(
							isGetSetMethod = findstring SpreadSheet_Property_Editing[header][3] "{}"
							if isGetSetMethod != undefined then
							(
								new_set_method = substring SpreadSheet_Property_Editing[header][3] 1 (isGetSetMethod-1)
								new_set_method = "Set"+ substring new_set_method 4 1000
								execute  (new_set_method +" SpreadSheet_Object_To_Change " + val as string)
								spreadsheet_object_data_array[sort_key_array[i]][header] = val 
								lvSpreadSheet.listItems[i].ListSubItems[header-1].text = spreadsheet_object_data_array[sort_key_array[i]][header] as string 
								changed_counter += 1						
							)
							else
							(							
								execute  ("SpreadSheet_Object_To_Change."+SpreadSheet_Property_Editing[header][3]+"= "+val as string)
								spreadsheet_object_data_array[sort_key_array[i]][header] = val 
								lvSpreadSheet.listItems[i].ListSubItems[header-1].text = spreadsheet_object_data_array[sort_key_array[i]][header] as string 
								changed_counter += 1						
							)	
						)catch()				
					)
					if rel_mode == 2 then
					(
						try
						(
							isGetSetMethod = findstring SpreadSheet_Property_Editing[header][3] "{}"
							if isGetSetMethod != undefined then
							(
								get_method = substring SpreadSheet_Property_Editing[header][3] 1 (isGetSetMethod-1)
								old_value = execute  (get_method +" SpreadSheet_Object_To_Change ")
								print old_value
								new_set_method = "Set"+ substring get_method 4 1000
								print new_set_method
								execute  (new_set_method +" SpreadSheet_Object_To_Change " + (val+old_value) as string)
								spreadsheet_object_data_array[sort_key_array[i]][header] = (val+old_value)
								print spreadsheet_object_data_array[sort_key_array[i]][header] 
								lvSpreadSheet.listItems[i].ListSubItems[header-1].text = spreadsheet_object_data_array[sort_key_array[i]][header] as string 
								changed_counter += 1						
							)
							else
							(							
								execute  ("SpreadSheet_Object_To_Change."+SpreadSheet_Property_Editing[header][3]+" += "+val as string)
								spreadsheet_object_data_array[sort_key_array[i]][header] += val 
								lvSpreadSheet.listItems[i].ListSubItems[header-1].text = spreadsheet_object_data_array[sort_key_array[i]][header] as string 
								changed_counter += 1						
							)	
						)catch()				
					)
					if rel_mode == 3 then
					(
						try
						(
							isGetSetMethod = findstring SpreadSheet_Property_Editing[header][3] "{}"
							if isGetSetMethod != undefined then
							(
								get_method = substring SpreadSheet_Property_Editing[header][3] 1 (isGetSetMethod-1)
								old_value = execute  (get_method +" SpreadSheet_Object_To_Change ")
								new_set_method = "Set"+ substring get_method 4 1000
								execute  (new_set_method +" SpreadSheet_Object_To_Change " + (old_value-val) as string)
								spreadsheet_object_data_array[sort_key_array[i]][header] = (old_value-val)
								lvSpreadSheet.listItems[i].ListSubItems[header-1].text = spreadsheet_object_data_array[sort_key_array[i]][header] as string 
								changed_counter += 1						
							)
							else
							(							
						
								execute  ("SpreadSheet_Object_To_Change."+SpreadSheet_Property_Editing[header][3]+" -= "+val as string)
								spreadsheet_object_data_array[sort_key_array[i]][header] -= val 
								lvSpreadSheet.listItems[i].ListSubItems[header-1].text = spreadsheet_object_data_array[sort_key_array[i]][header] as string 
								changed_counter += 1						
							)	
						)catch()				
					)				
				)--end if valid	
			)--end i loop
			case rel_mode of
			(
				1:	mode_string = " Changed to"
				2:	mode_string = " Increased by"
				3:	mode_string = " Reduced by"
			)	
			uiLog ("["+Property_name_to_change+"]" + mode_string +" ["+ val as string  +"] in "+changed_counter as string + " of " + total_count as string+" Object(s).")
			spreadsheet_editor_rollout.ui_progress.value = 0.0
		)--end if header > 1	
	)

	fn ChangeItemValue lvSpreadSheet header MouseButton MouseShift MouseDelta=
	(
		with redraw off
		(
		if  header > 1 and SpreadSheet_Property_Editing[header][6] then
		(
			selected_items = getSelection lvSpreadSheet
			changed_counter = 0
			Property_name_to_change = SpreadSheet_Property_Editing[header][1]
			for i in selected_items do
			(
				SpreadSheet_Object_To_Change = spreadsheet_object_data_array[sort_key_array[i]][1]
				if isValidNode SpreadSheet_Object_To_Change then
				(
				if MouseButton == 2 then
				(
					if SpreadSheet_Property_Editing[header][4] == "BooleanClass" then
					(
					case MouseShift of
					(
						0:
						(
							try
							(
								isGetSetMethod = findstring SpreadSheet_Property_Editing[header][3] "{}"
								if isGetSetMethod != undefined then
								(
									get_method = substring SpreadSheet_Property_Editing[header][3] 1 (isGetSetMethod-1)
									old_value = execute  (get_method +" SpreadSheet_Object_To_Change ")
									new_set_method = "Set"+ substring get_method 4 1000
									execute  (new_set_method +" SpreadSheet_Object_To_Change " + (not old_value) as string)
									spreadsheet_object_data_array[sort_key_array[i]][header] = (not old_value)
									lvSpreadSheet.listItems[i].ListSubItems[header-1].text = spreadsheet_object_data_array[sort_key_array[i]][header] as string 
									changed_counter += 1						
								)
								else
								(							
									execute  ("SpreadSheet_Object_To_Change."+SpreadSheet_Property_Editing[header][3]+"= Not SpreadSheet_Object_To_Change."+SpreadSheet_Property_Editing[header][3])
									spreadsheet_object_data_array[sort_key_array[i]][header] = not spreadsheet_object_data_array[sort_key_array[i]][header]
									lvSpreadSheet.listItems[i].ListSubItems[header-1].text = spreadsheet_object_data_array[sort_key_array[i]][header] as string 
									changed_counter += 1
								)	
							)catch()
						)
						2: 
						(
							try
							(
								isGetSetMethod = findstring SpreadSheet_Property_Editing[header][3] "{}"
								if isGetSetMethod != undefined then
								(
									get_method = substring SpreadSheet_Property_Editing[header][3] 1 (isGetSetMethod-1)
									new_set_method = "Set"+ substring get_method 4 1000
									execute  (new_set_method +" SpreadSheet_Object_To_Change " + (false) as string)
									spreadsheet_object_data_array[sort_key_array[i]][header] = false
									lvSpreadSheet.listItems[i].ListSubItems[header-1].text = spreadsheet_object_data_array[sort_key_array[i]][header] as string 
									changed_counter += 1						
								)
								else
								(							
									execute  ("SpreadSheet_Object_To_Change."+SpreadSheet_Property_Editing[header][3]+"=False")
									spreadsheet_object_data_array[sort_key_array[i]][header] = false	
									lvSpreadSheet.listItems[i].ListSubItems[header-1].text = spreadsheet_object_data_array[sort_key_array[i]][header] as string 
									changed_counter += 1
								)	
							)catch()
						)					
						1: 
						(
							try
							(
								isGetSetMethod = findstring SpreadSheet_Property_Editing[header][3] "{}"
								if isGetSetMethod != undefined then
								(
									get_method = substring SpreadSheet_Property_Editing[header][3] 1 (isGetSetMethod-1)
									new_set_method = "Set"+ substring get_method 4 1000
									execute  (new_set_method +" SpreadSheet_Object_To_Change " + (false) as string)
									spreadsheet_object_data_array[sort_key_array[i]][header] = false
									lvSpreadSheet.listItems[i].ListSubItems[header-1].text = spreadsheet_object_data_array[sort_key_array[i]][header] as string 
									changed_counter += 1						
								)
								else
								(							
									execute  ("SpreadSheet_Object_To_Change."+SpreadSheet_Property_Editing[header][3]+"=True")
									spreadsheet_object_data_array[sort_key_array[i]][header] = true
									lvSpreadSheet.listItems[i].ListSubItems[header-1].text = spreadsheet_object_data_array[sort_key_array[i]][header] as string 
									changed_counter += 1
								)	
							)catch()
						)
					)--end case shift
					)--end if boolean
					
					if SpreadSheet_Property_Editing[header][4] == "Float" then
					(
							if MouseShift == 1 then MouseDelta *= 10.0
							if MouseShift == 2 then MouseDelta *= 0.1
							try
							(
								isGetSetMethod = findstring SpreadSheet_Property_Editing[header][3] "{}"
								if isGetSetMethod != undefined then
								(
									get_method = substring SpreadSheet_Property_Editing[header][3] 1 (isGetSetMethod-1)
									old_value = execute  (get_method +" SpreadSheet_Object_To_Change ")
									new_set_method = "Set"+ substring get_method 4 1000
									execute  (new_set_method +" SpreadSheet_Object_To_Change " + (old_value+MouseDelta) as string)
									spreadsheet_object_data_array[sort_key_array[i]][header] = (old_value+MouseDelta)
									lvSpreadSheet.listItems[i].ListSubItems[header-1].text = spreadsheet_object_data_array[sort_key_array[i]][header] as string 
									changed_counter += 1						
								)
								else
								(							
						
									execute  ("SpreadSheet_Object_To_Change."+SpreadSheet_Property_Editing[header][3]+"+= "+(MouseDelta as string))
									spreadsheet_object_data_array[sort_key_array[i]][header] += MouseDelta
									lvSpreadSheet.listItems[i].ListSubItems[header-1].text = spreadsheet_object_data_array[sort_key_array[i]][header] as string 
									changed_counter += 1
								)	
							)catch()
					)
				)--end mbutton
				)--end if valid object	
			)--end i loop
			lvSpreadSheet.Refresh()
			if MouseButton == 2 then 
				uiLog ("["+Property_name_to_change +"] Changed in "+changed_counter as string + " of " + selected_items.count as string+" Object(s).")
		)--end if header
		)--end redraw off
		redrawviews()
	)--end fn


---------------------------------------------------------------
--MENU                                                       --
---------------------------------------------------------------
local SpreadSheetEditorRCMenu

RcMenu SpreadSheetEditorRCMenu
(
	subMenu "Layout"
	(
		menuItem sserc_layout_new "New Layout..."
		separator sserc_sep1
		menuItem sserc_layout_edit "Edit Current Layout"
		menuItem sserc_layout_reload "Reload Current Layout"
	)
	subMenu "Filter"
	(
		menuItem sserc_filter_new "New Filter..."
		separator sserc_sep2
		menuItem sserc_filter_edit "Edit Current Filter"
		menuItem sserc_reapply "Reapply Current Filter"
		menuItem sserc_selected "Toggle Show Selection Only"
	)
	SubMenu "Sort"
	(
		menuItem sserc_unsorted "Unsorted In Scene Order"
		separator sserc_sep3
		menuItem sserc_sort_ascending  "Ascending By Object Name"
		menuItem sserc_sort_descending "Descending By Object Name"
		separator sserc_sep4
		menuItem sserc_sort_prop_ascending  "Ascending By Active Property"
		menuItem sserc_sort_prop_descending "Descending By Active Property"
		
	)
	SubMenu "Select"
	(
		menuItem sserc_select_all "Select All In Editor"
		separator sserc_sep5
		menuItem sserc_add_from_scene "Add Selection From Scene"
		menuItem sserc_synch_to_scene "Synch Selection From Editor"
	)
	SubMenu "Help"
	(
		menuItem sserc_help "SpreadSheet Editor Webpage..."
		separator sserc_sep6			
		menuItem sserc_boboland "More MAXScripts from Boboland..."
		menuItem sserc_scriptspot "More MAXScripts from ScriptSpot..."
--		separator sserc_help_sep2		
--		menuItem sserc_about "About SpreadSheet Editor..."
	)

	on sserc_help picked do
	(
		shellLaunch "http://www.scriptspot.com/bobo/darkmoon/sse/" ""
	)	
	
	on sserc_boboland picked do
	(
		shellLaunch "http://www.scriptspot.com/bobo/" ""
	)		

	on sserc_scriptspot picked do
	(
		shellLaunch "http://www.scriptspot.com/" ""
	)		

	
	on sserc_layout_new picked do spreadsheet_editor_rollout.createNewLayout()
	on sserc_layout_edit picked do spreadsheet_editor_rollout.layout_edit()
	on sserc_layout_reload picked do spreadsheet_editor_rollout.ReloadLayout spreadsheet_editor_rollout.lv_layouts.selection
	
	on sserc_filter_new picked do spreadsheet_editor_rollout.createNewFilter()
	on sserc_filter_edit picked do spreadsheet_editor_rollout.filter_edit()
	on sserc_reapply picked do spreadsheet_editor_rollout.ReapplyFilter()
	on sserc_selected picked do 
	(
		spreadsheet_editor_rollout.use_selection.checked = not spreadsheet_editor_rollout.use_selection.checked
		spreadsheet_editor_rollout.ReapplyFilter()
		spreadsheet_editor_rollout.storeIniFile ()
	)		

fn CheckRcMenuItems =
(
/*
	sserc_unsorted.checked = (last_sort_mode == 1 and last_sort_key == 0)
	sserc_sort_ascending.checked = (last_sort_mode == 1 and last_sort_key == 1)
	sserc_sort_descending.checked = (last_sort_mode == 2 and last_sort_key == 1)
	sserc_sort_prop_ascending.checked = (last_sort_mode == 1 and last_sort_key > 1)
	sserc_sort_prop_descending.checked = (last_sort_mode == 2 and last_sort_key > 1)
*/	
spreadsheet_editor_rollout.storeIniFile ()
)	

	on sserc_unsorted picked do 
	(
		resetSortKeyArray()
		last_sort_mode = 1
		last_sort_key = 0
		fillInSpreadSheet spreadsheet_editor_rollout.lvSpreadSheet
		paintColumn (last_header-1) (color 0 0 255)	true	
		spreadsheet_editor_rollout.lvSpreadSheet.refresh()
		CheckRcMenuItems ()
	)	
	on sserc_sort_ascending picked do 
	(
		SortObjectDatabase 1 1
		last_sort_mode = 1
		last_sort_key = 1
		fillInSpreadSheet spreadsheet_editor_rollout.lvSpreadSheet
		paintColumn (last_header-1) (color 0 0 255)	true	
		spreadsheet_editor_rollout.lvSpreadSheet.refresh()
		CheckRcMenuItems ()
	)	
	on sserc_sort_descending picked do 
	(
		SortObjectDatabase 2 1
		last_sort_mode = 2
		last_sort_key = 1
		fillInSpreadSheet spreadsheet_editor_rollout.lvSpreadSheet
		paintColumn (last_header-1) (color 0 0 255)	true	
		spreadsheet_editor_rollout.lvSpreadSheet.refresh()
		CheckRcMenuItems ()
	)	
	on sserc_sort_prop_ascending picked do 
	(
		SortObjectDatabase 1 last_header
		last_sort_mode = 1
		last_sort_key = last_header
		fillInSpreadSheet spreadsheet_editor_rollout.lvSpreadSheet
		paintColumn (last_header-1) (color 0 0 255)	true	
		spreadsheet_editor_rollout.lvSpreadSheet.refresh()
		CheckRcMenuItems ()
	)	
	on sserc_sort_prop_descending picked do 
	(
		SortObjectDatabase 2 last_header
		last_sort_mode = 2
		last_sort_key = last_header
		fillInSpreadSheet spreadsheet_editor_rollout.lvSpreadSheet
		paintColumn (last_header-1) (color 0 0 255)	true	
		spreadsheet_editor_rollout.lvSpreadSheet.refresh()
		CheckRcMenuItems ()
	)	
	
	
	on sserc_select_all picked do SelectAll()
	on sserc_add_from_scene picked do SynchSelectionFromScene 2
	on sserc_synch_to_scene picked do spreadsheet_editor_rollout.selectInScene()

)--end RCmenu



	
-----------------------	
--MACROSCRIPT ROLLOUT--	
-----------------------
	
rollout spreadsheet_editor_rollout "SpreadSheet Editor v0.6.0" 
(
	dropdownlist lv_layouts  items:#() width:200 pos:[5,1]
	dropdownlist lv_filters items:#() width:200 pos:[5,24]
	
	checkbutton use_selection "Sel." pos:[205,24] highlightcolor:(color 200 255 200) tooltip:"Search SELECTED Objects Only"
	button lv_filters_reapply "R" width:28 height:43 pos:[240,2] tooltip:"REAPPLY Current Filter / RELOAD All Properties"

	spinner lv_integer "Abs." pos:[275,5] fieldwidth:50 range:[-1000000,1000000,0] type:#integer
	spinner lv_float "Abs." pos:[275,5] fieldwidth:50 range:[-1000000.0,1000000.0,0.0]
	colorpicker lv_color "Abs." pos:[280,2] fieldwidth:50 color:(color 255 255 255 255)
	checkbutton lv_boolean "Toggle" pos:[290,2] width:70
	dropdownlist lv_list pos:[270,2] width:90 items:#()
	
	spinner lv_integer_rel "Rel." pos:[277,28] fieldwidth:50 range:[-1000000,1000000,0] type:#integer
	spinner lv_float_rel "Rel." pos:[277,28] fieldwidth:50 range:[-1000000.0,1000000.0,0.0]
	colorpicker lv_color_rel "Rel." pos:[282,25] fieldwidth:50 color:(color 0 0 0 0)
	button lv_boolean_rel "Invert" pos:[290,25] width:70	

	button lv_apply "APPLY" width:41 pos:[360,2] tooltip:"Apply ABSOLUTE Value to Selected Objects/Properties"
	button lv_apply_rel "+" width:20 pos:[360,25] tooltip:"ADD RELATIVE Value to Selected Objects/Properties"
	button lv_sub_rel "--" width:20 pos:[381,25] tooltip:"SUBTRACT RELATIVE Value from Selected Objects/Properties"

	label ui_status "Ready." pos:[410,3] align:#left
	progressbar ui_progress value:0.0 pos:[410,21] height:6 width:115
	spinner max_nodes "Max Objects:" pos:[410,30] fieldwidth:40 range:[1,1000,100] type:#integer
	
	activeXControl lvSpreadSheet "MSComctlLib.ListViewCtrl" width:1000 height:1000 pos:[0,48]


------------------
--EVENT HANDLERS--
------------------

	on lv_apply pressed do
	(
		if lv_color.enabled then EditItemValue lvSpreadSheet last_header lv_color.color 1
		if lv_float.enabled then EditItemValue lvSpreadSheet last_header lv_float.value 1
		if lv_integer.enabled then EditItemValue lvSpreadSheet last_header lv_integer.value 1
		if lv_boolean.enabled then EditItemValue lvSpreadSheet last_header lv_boolean.state 1
	)

	on lv_apply_rel pressed do
	(
		if lv_float_rel.enabled then EditItemValue lvSpreadSheet last_header lv_float_rel.value 2
		if lv_integer_rel.enabled then EditItemValue lvSpreadSheet last_header lv_integer_rel.value 2
		if lv_color_rel.enabled then EditItemValue lvSpreadSheet last_header lv_color_rel.color 2
	)

	on lv_sub_rel pressed do
	(
		if lv_float_rel.enabled then EditItemValue lvSpreadSheet last_header lv_float_rel.value 3
		if lv_integer_rel.enabled then EditItemValue lvSpreadSheet last_header lv_integer_rel.value 3
		if lv_color_rel.enabled then EditItemValue lvSpreadSheet last_header lv_color_rel.color 3
	)

	on lv_list selected itm do
	(
		EditListContent lvSpreadSheet last_header itm SpreadSheet_Property_Editing[last_header][4]
	)	
	
	on lv_float changed val do
	(
		EditItemValue lvSpreadSheet last_header val 1
	)	

	on lv_integer changed val do
	(
		EditItemValue lvSpreadSheet last_header val 1
	)	
	
	on lv_boolean changed val do
	(
		EditItemValue lvSpreadSheet last_header val 1
	)	

	on lv_color changed col do
	(
		EditItemValue lvSpreadSheet last_header col 1
	)


	
	on lv_boolean_rel pressed do
	(
		ChangeItemValue lvSpreadSheet last_header 2 0 0.0
	)	


------------------------------------------
--Manage visibility of property controls--
------------------------------------------
	
	fn enablePropertyControls classString =
	(
		lv_color.pos = [0,-1000]
		lv_float.pos = [0,-1000]
		lv_integer.pos = [0,-1000]
		lv_boolean.pos = [0,-1000]	
		lv_color_rel.pos = [0,-1000]
		lv_float_rel.pos = [0,-1000]
		lv_integer_rel.pos = [0,-1000]
		lv_boolean_rel.pos = [0,-1000]	
		lv_list.pos = [0,-1000]	
		lv_color.enabled = false
		lv_float.enabled = false
		lv_integer.enabled = false
		lv_boolean.enabled = false	
		lv_color_rel.enabled = false
		lv_float_rel.enabled = false
		lv_integer_rel.enabled = false
		lv_boolean_rel.enabled = false
		lv_list.enabled = false
		
		case classString of
		(
			"Float": (
						lv_float.enabled = true
						lv_float_rel.enabled = true
						lv_float.pos = [345,5]
						lv_float_rel.pos = [345,28]
						)	
			"Integer": (
						lv_integer.enabled= true
						lv_integer_rel.enabled= true
						lv_integer.pos = [345,5]
						lv_integer_rel.pos = [345,28]
						)						
			"BooleanClass": (
						lv_boolean.enabled = true	
						lv_boolean_rel.enabled= true	
						lv_boolean.pos = [290,2]
						lv_boolean_rel.pos = [290,25]
						)
			"Color": (
						lv_color.enabled = true
						lv_color_rel.enabled = true
						lv_color.pos = [307,2]
						lv_color_rel.pos = [307,25]
					)	
			"ShadowGenerator": (
						lv_list.items=#("Area","Adv.RayT","ShadowMap","Raytraced")
						lv_list.enabled= true
						lv_list.pos = [270,2]
					)			
			)
	)--end fn 
	
	fn ReapplyFilter =
	(
		if lv_filters.items.count > 0 then
		(
			file_name = filter_functions_list[lv_filters.selection]
			fileIn file_name
		)	
		collectObjectData use_selection.state
		SortObjectDatabase last_sort_mode last_sort_key 
		fillInSpreadSheet lvSpreadSheet 
		paintColumn (last_header-1) (color 0 0 255)	true
		lvSpreadSheet.refresh()
		SpreadSheetEditorRCMenu.CheckRcMenuItems()
	)
	
	
	
	
	fn storeIniFile =
	(
		setIniFile = CreateFile ((GetDir #maxroot)+"/Scripts/SpreadSheet/SpreadSheet.ini")
		format "%\n" rollout_pos  to:setIniFile 
		format "%\n" rollout_size to:setIniFile 
		format "%\n" rollout_layout_mode to:setIniFile 
		format "%\n" rollout_filter_mode to:setIniFile 
		format "%\n" use_selection.state to:setIniFile 
		format "%\n" rollout_max_nodes to:setIniFile 
		format "%\n" last_sort_key to:setIniFile 
		format "%\n" last_sort_mode to:setIniFile 
		close setIniFile 
	)
	
	fn createNewFilter =
	(
		class_list = #()
		for o in selection do
		(
			if findItem class_list (classof o) == 0 then append class_list (classof o)
		)	
		if selection.count > 0 then 
			new_filter_name = ""
		else
			new_filter_name = "NewFilter"
		for o in class_list do
		(
			if new_filter_name.count < 100 then new_filter_name += o as string
		)
		new_file_name = GetSaveFileName filename:((GetDir #maxRoot)+"SpreadSheet/Filters/"+new_filter_name) types:"SpreadSheed Filters (*.filter)|*.filter" caption:"Save New SpreadSheet Filter"
		if new_file_name != undefined then
		(
			new_script = createFile new_file_name 
			format "gloabl fn spreadsheet_filter_function obj = \n(\n" to:new_script 
			if selection.count == 0 then format "true" to:new_script 
			for o = 1 to class_list.count do
			(
				format "classof obj == %" (class_list[o] as string) to:new_script 
				if o < class_list.count then 
				(
				format " and " to:new_script 
				)
			)
			format "\n)\n" to:new_script 
			close new_script
			getFilterFileNames()
			lv_filters.items = filter_names_list
			lv_filters.selection = FindItem filter_names_list (getFileNameFile new_file_name)
			ReapplyFilter()
			uiLog ("NEW Filter ["+getfilenamefile new_file_name +"] CREATED!")
		)
		else
		(
			uiLog "New Filter Creation ABORTED!"
		)
	)
	
	
	fn createNewLayout =
	(
		new_file_name = GetSaveFileName filename:((GetDir #maxRoot)+"SpreadSheet/Layouts/NewLayout") types:"SpreadSheed Layouts (*.layout)|*.layout" caption:"Save New SpreadSheet Layout"
		if new_file_name != undefined then
		(
			new_script = createFile new_file_name 
			all_props = #()
			value_list = #()
			format "global SpreadSheet_Property_Editing = #(\n" to:new_script
			format "#(\"Object\", \"Object\", \" \", \" \", 120, false),\n" to:new_script
			for o in selection do
			(
				props = GetPropNames o
				for p in props do
				(
					if findItem all_props p == 0 then 
					(
						append all_props p
						append value_list (getProperty o p)
					)	
				)
			)	
			for i = 1 to all_props.count do 
			(
				nam = all_props[i] as string
				class_string = (classof value_list[i])as string
				if findstring (nam as string) "shadowgenerator" != undefined then class_string ="ShadowGenerator"
				new_col = #(nam, "<"+nam+">", nam, class_string, 70, true)
				format "%" new_col to:new_script
				if i < all_props.count then format ",\n" to:new_script
			)--end i loop
			format "\n)\n" to:new_script 
			close new_script
			uiLog ("NEW Layout ["+getfilenamefile new_file_name +"] CREATED!")
			getLayoutFileNames()
			lv_layouts.items = layout_names_list
			lv_layouts.selection = FindItem layout_names_list (getFileNameFile new_file_name)
			file_name = layout_functions_list[layout_names_list.count]
			fileIn file_name
			initListView lvSpreadSheet 
			collectObjectData use_selection.state
			fillInSpreadSheet lvSpreadSheet 
		)
		else
		(
			uiLog "New Layout Creation ABORTED!"
		)
	)--end fn

	fn filter_edit =
	(
		try(edit (filter_functions_list[lv_filters.selection]))catch()
	)
	
	fn layout_edit =
	(
		try(edit (layout_functions_list[lv_layouts.selection]))catch()
	)	
	
	on lv_filters selected itm do
	(
		ReapplyFilter()
		rollout_filter_mode = filter_functions_list[itm]
		storeIniFile ()
		uiLog ("Filter switched to ["+ lv_filters.selected +"]")
	)
	
	on lv_filters_reapply pressed do
	(
		ReapplyFilter()
	)
	
	on use_selection changed state do
	(
		ReapplyFilter()
		storeIniFile ()		
	)

	fn ReloadLayout itm =
	(
		file_name = layout_functions_list[itm]
		fileIn file_name
		last_header = 1
		initListView lvSpreadSheet 
		collectObjectData use_selection.state		
		sortObjectDatabase last_sort_mode last_sort_key
		fillInSpreadSheet lvSpreadSheet 
		rollout_layout_mode = layout_functions_list[itm]
		storeIniFile ()
		uiLog ("Layout switched to ["+ lv_layouts.selected +"]")
	)
	
	on lv_layouts selected itm do
	(
		ReloadLayout itm
	)
	
	fn selectInScene =
	(
		sel_indices= (getSelection lvSpreadSheet)
		with redraw off
		(
			max select none
			selection_count = 0
			for i in sel_indices do 
			(
			  obj = spreadsheet_object_data_array[sort_key_array[i]][1]
			  if isValidNode obj then 
			  (
			  	selectMore obj
				selection_count += 1
			  )	
			)
		)
		redrawViews()	
		uiLog ("SELECTED "+selection_count as string + " of " + sel_indices.count as string+" Object(s).")
		if sel_indices.count == 1 then
		(
			updateValueToEdit lvSpreadSheet last_header sel_indices[1]
		)
	)
	
	on lvSpreadSheet DblClick do 
	( 
		selectInScene()
	)
	
	on spreadsheet_editor_rollout resized new_size do 
	(
		rollout_size = new_size
		lvSpreadSheet.size = new_size - [0,48]
		storeIniFile ()
	)
	
	on spreadsheet_editor_rollout moved new_pos do 
	(
		rollout_pos = new_pos
		storeIniFile ()
	)
	
	on max_nodes changed value do
	(
		rollout_max_nodes = value
		storeIniFile ()		
	)
	
	local last_my = 0.0
	local isMouseDown = False

	on lvSpreadSheet mouseDown mButton mShift mx my do
	(
		ChangeItemValue lvSpreadSheet last_header mButton mShift 0.0
		last_my = my
		isMouseDown = True
	) 
	
	on lvSpreadSheet mouseUp mButton mShift mx my do
	(
		isMouseDown = False
	) 
	on lvSpreadSheet mouseMove mButton mShift mx my do
	(
		if isMouseDown and mButton == 2 then
		(
			delta_my = last_my-my
			ChangeItemValue lvSpreadSheet last_header mButton mShift delta_my
			last_my = my
		)	
	) 
	
	on lvSpreadSheet columnClick headerObject do
	(
		textColor = ((colorman.getColor #text)*255) as color
		paintColumn (last_header-1) (color textColor.b textColor.g textColor.r) false			
		last_header = headerObject.index
		for i = 1 to lvSpreadSheet.ColumnHeaders.count do
		(
			lvSpreadSheet.ColumnHeaders[i].text = SpreadSheet_Property_Editing[i][1]
		)
		lvSpreadSheet.ColumnHeaders[last_header].text = SpreadSheet_Property_Editing[last_header][2]
		if last_header > 1 then
			uiLog ("Property ["+ SpreadSheet_Property_Editing[last_header][1] +"] enabled for editing.")
		else
			uiLog ("Property editing disabled.")
			

		enablePropertyControls SpreadSheet_Property_Editing[last_header][4]
		sel_indices= (getSelection lvSpreadSheet)
		if sel_indices.count > 0 then
		(
			updateValueToEdit lvSpreadSheet last_header sel_indices[1]
		)
		paintColumn (last_header-1) (color 0 0 255)	true	
		lvSpreadSheet.refresh()
	)
	
	fn EnableFilter filter_mode =
	(
		test_for_existing_filter = FindItem	filter_functions_list filter_mode
		if test_for_existing_filter > 0 then
		(
			file_name = filter_functions_list[test_for_existing_filter]
			fileIn file_name
			lv_filters.selection = test_for_existing_filter
		)	
	)	
)


makedir ((GetDir #maxroot)+"/Scripts/SpreadSheet")
makedir ((GetDir #maxroot)+"/Scripts/SpreadSheet/Layouts")
makedir ((GetDir #maxroot)+"/Scripts/SpreadSheet/Filters")

max_version = maxversion()
max_version = max_version[1] / 1000


--Read INI file 
try
(
	getIniFile = OpenFile ((GetDir #maxroot)+"/Scripts/SpreadSheet/SpreadSheet.ini")
	str = readline getIniFile 
	rollout_pos = execute str
	if max_version != 5 then rollout_pos -= [6,41]
	str = readline getIniFile 
	rollout_size = execute str
	if max_version != 5 then rollout_size += [4,-4]
	rollout_layout_mode = readline getIniFile 
	rollout_filter_mode = readline getIniFile 
	use_selection_mode = execute (readline getIniFile)
	rollout_max_nodes = execute (readline getIniFile)
	last_sort_key = execute (readline getIniFile)
	last_sort_mode = execute (readline getIniFile)
)
catch()
try(close getIniFile)catch()



--Purge memory just in case - clears undo buffer!!!
gc()

--Remove the remarks below to make the window dockable!
--try(cui.unregisterDialogBar spreadsheet_editor_rollout)catch()

try(unregisterViewWindow spreadsheet_editor_rollout)catch()
destroyDialog spreadsheet_editor_rollout
createDialog spreadsheet_editor_rollout rollout_size.x rollout_size.y rollout_pos.x rollout_pos.y style:#(#style_minimizebox, #style_maximizebox, #style_resizing, #style_titlebar, #style_border, #style_sysmenu) menu:SpreadSheetEditorRCMenu

--cui.registerDialogBar spreadsheet_editor_rollout minSize:[400,300] maxSize:[-1,-1] 

registerViewWindow spreadsheet_editor_rollout 


--Hide all property controls
spreadsheet_editor_rollout.enablePropertyControls ""

--Set selection mode and max. nodes from INI file
spreadsheet_editor_rollout.use_selection.state = use_selection_mode
spreadsheet_editor_rollout.max_nodes.value = rollout_max_nodes 




--Update Layout
getLayoutFileNames()
spreadsheet_editor_rollout.lv_layouts.items = layout_names_list
if layout_functions_list.count > 0 then 
(
	test_for_existing_layout = FindItem	layout_functions_list rollout_layout_mode
	if  test_for_existing_layout  > 0 then
	(
		file_name = layout_functions_list[test_for_existing_layout]
		fileIn file_name
		spreadsheet_editor_rollout.lv_layouts.selection = test_for_existing_layout
	)	
)	

--Update Filters
getFilterFileNames()
spreadsheet_editor_rollout.lv_filters.items = filter_names_list
if filter_functions_list.count > 0 then 
(
	spreadsheet_editor_rollout.EnableFilter(rollout_filter_mode)
)	


--Update Display and Populate with objects
initListView spreadsheet_editor_rollout.lvSpreadSheet 
collectObjectData spreadsheet_editor_rollout.use_selection.state
sortObjectDatabase last_sort_mode last_sort_key
fillInSpreadSheet spreadsheet_editor_rollout.lvSpreadSheet 
)