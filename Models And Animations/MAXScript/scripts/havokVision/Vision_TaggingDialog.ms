fn CheckInput elem label rangeStart rangeEnd =
(
	szRangeS = rangeStart as string
	szRangeE = rangeEnd as string
  content_string = elem.text as string

	-- Check for dot in number
	coma_index = findString content_string "."
	if coma_index == undefined then
	(
		coma_index = findString content_string ","
	)

	-- Check for number
	item = elem.text as Integer
	if item != undefined and coma_index == undefined then
	(
		if item >= rangeStart and item <= rangeEnd then
		(
			return true
		)
		else
		(
			szMessage = "The value of "
			append szMessage label.text
			append szMessage " is not within the allowed range of "
			append szMessage szRangeS 
			append szMessage " and "
			append szMessage szRangeE
			append szMessage "."
			messagebox szMessage
		)
	)
	else
	(
		szMessage = " The "
		append szMessage label.text 
		append szMessage " does not contain an integer number, though it is an integer parameter!\n"
		messagebox szMessage
	)

	false 
)

fn CheckInputFloat elem label rangeStart rangeEnd =
(
	szRangeS = rangeStart as string
	szRangeE = rangeEnd as string

	-- Check for number
	item = elem.text as Float
	if item != undefined then
	(
		if item >= rangeStart and item <= rangeEnd then
		(
			return true
		)
		else
		(
			szMessage = "The value of "
			append szMessage label.text
			append szMessage " is not within the allowed range of "
			append szMessage szRangeS 
			append szMessage " and "
			append szMessage szRangeE
			append szMessage "."
			messagebox szMessage
		)
	)
	else
	(
		szMessage = " The "
		append szMessage label.text
		append szMessage " does not contain a number, though it is a numerical parameter!\n"
		messagebox szMessage
	)
	false
)

rollout roExportTags "Vision" width:477 height:494
(
    pickButton btn11 "Node" pos:[3,6] width:471 height:17 enabled:false
    dropDownList ddl2 "Export as" pos:[12,26] width:462 height:40 items:#("default", "unoptimized", "nothing", "renderMesh", "colMesh", "colBBox", "portal")
    
    pickButton btn2 "Geometry Info" pos:[3,70] width:471 height:17 enabled:false
    
    editText editName "" pos:[110,95] width:360 height:15
    label lbl14 "Name" pos:[12,95] width:102 height:13
    
    editText editTag "" pos:[110,115] width:360 height:15
    label lbl17 "Tag ID" pos:[12,115] width:94 height:13
    
    editText edtUserFlags "" pos:[110,135] width:360 height:15
    label lbl18 "User flags" pos:[12,135] width:94 height:13
    
    editText edtVisMask "" pos:[110,155] width:360 height:15
    label lbl4 "Visibility mask" pos:[12,155] width:94 height:13
    
    editText edtLightMask "" pos:[110,175] width:360 height:15
    label lbl5 "Light mask" pos:[12,175] width:94 height:13
    
    editText edtTraceMask "" pos:[110,195] width:360 height:15
    label lbl6 "Trace mask" pos:[12,195] width:94 height:13

    editText edtNearClip "" pos:[110,215] width:360 height:15
    label lblnc "Near Clip" pos:[12,215] width:94 height:13

    editText edtFarClip "" pos:[110,235] width:360 height:15
    label lblfc "Far Clip" pos:[12,235] width:94 height:13

    editText edtLodIndex "" pos:[110,255] width:360 height:15
    label lblli "LOD Index" pos:[12,255] width:94 height:13

    pickButton btn7 "Havok Physics" pos:[3,280] width:471 height:17 enabled:false
    
    editText txtDynFriction "" pos:[110,305] width:100 height:15
    label lbl11 "Friction" pos:[12,305] width:94 height:13
    
    editText txtRestitution "" pos:[110,325] width:100 height:15
    label lbl12 "Restitution" pos:[12,325] width:72 height:13

	dropDownList cmbPhyGroup "Collision Layer" pos:[12,345] width:208 height:40 items:#( "0", "Dynamic", "Static", "Terrain", "Controller", "5","6","Ragdoll","Attachments","Foot_IK","10","Debris","Decoration","13","14","15","16","17","18","19","20","21","22","23","24","25","26","Custom0","Custom1","Custom2","Custom3","Custom4")
    
    editText txtUserData "" pos:[370,305] width:100 height:15
    label lbl16 "User data" pos:[268,305] width:72 height:13
    
    editText txtSubsystemID "" pos:[370,325] width:100 height:15
    label lblHavokID2 "Subsystem ID" pos:[268,325] width:72 height:13

	editText txtDontCollideID "" pos:[370,345] width:100 height:15
    label lbl8 "Don't collide with" pos:[268,345] width:88 height:13

    editText txtSysGroup "" pos:[370,365] width:100 height:15
    label lbl9 "System group" pos:[268,365] width:72 height:13
    
    pickButton btn8 "Portal" pos:[3,390] width:471 height:17 enabled:false

    checkbox chkSingleSidedPortal "Single Sided" pos:[12,415] width:123 height:20
    checkbox chkLeadsToOutsidePortal "Leads To Outside" pos:[12,435] width:123 height:20

    button btnOk "Ok" pos:[128,460] width:104 height:24
    button btnCancel "Cancel" pos:[240,460] width:104 height:24

  on roExportTags open do
	(
		selArray = selection as array
		if selArray.count >0 then
		(
			-- Get all the tags and fill up the dialog with possibly existing data

			item = getUserProp selArray[1] "vision_export_as"
			if item != undefined then
			(
				for i=1 to ddl2.items.count do
				(
					cbIt = ddl2.items[i]
					if cbIt == item then
					(
						ddl2.selection = i
					)
				)
			)
			else
			(
				ddl2.selection = 1 -- default
			)
      
      item = getUserProp selArray[1] "vision_mesh_name"
      if item != undefined then
      (
        editName.Text = item as string
      )
      else
      (
        editName.Text = ""
      )

			item = getUserProp selArray[1] "vision_mesh_tag"
			if item != undefined then
			(
				editTag.Text = item as string
			)
			else
			(
				editTag.Text = ""
			)

			item = getUserProp selArray[1] "vision_mesh_userFlags"
			if item != undefined then
			(
				edtUserFlags.Text = item as string
			)
			else
			(
				edtUserFlags.Text =	""
			)

			havokLayer = getUserProp selArray[1] "vision_physics_colLayer"
			if havokLayer != undefined then
			(
				cmbPhyGroup.selection = havokLayer + 1	-- Max-Arrays are 1-based
			)
			else
			(
				cmbPhyGroup.selection = 3 -- layer 2
			)

			item = getUserProp selArray[1] "vision_mesh_traceMask"
			if item != undefined then
			(
				edtTraceMask.Text = item as string
			)
			else
			(
				edtTraceMask.Text = "65535"
			)

			item = getUserProp selArray[1] "vision_mesh_visMask"
			if item != undefined then
			(
				edtVisMask.Text = item as string
			)
			else
			(
				edtVisMask.Text = "65535"
			)

			item = getUserProp selArray[1] "vision_mesh_lightMask"
			if item != undefined then
			(
				edtLightMask.Text = item as string
			)
			else
			(
				edtLightMask.Text = "65535"
			)

			item = getUserProp selArray[1] "vision_near_clip"
			if item != undefined then
			(
				edtNearClip.Text = item as string
			)
			else
			(
				edtNearClip.Text = "1.0"
			)

			item = getUserProp selArray[1] "vision_far_clip"
			if item != undefined then
			(
				edtFarClip.Text = item as string
			)
			else
			(
				edtFarClip.Text = "100000.0"
			)

			item = getUserProp selArray[1] "vision_lod_index"
			if item != undefined then
			(
				edtLodIndex.Text = item as string
			)
			else
			(
				edtLodIndex.Text = "-1"
			)
            
			item = getUserProp selArray[1] "vision_physics_colSubsysID"
			if item != undefined then
			(
				txtSubsystemID.Text = item as string
			)
			else
			(
				txtSubsystemID.Text = "0"
			)

			item = getUserProp selArray[1] "vision_physics_colNotSubsysID"
			if item != undefined then
			(
				txtDontCollideID.Text = item as string
			)
			else
			(
				txtDontCollideID.Text = "0"
			)

			item = getUserProp selArray[1] "vision_physics_colSystemGroup" 
			if item != undefined then
			(
				txtSysGroup.Text = item as string
			)
			else
			(
				txtSysGroup.Text = "0"
			)

			item = getUserProp selArray[1] "vision_physics_restitution" 
			if item != undefined then
			(
				txtRestitution.Text = item as string
			)
			else
			(
				txtRestitution.Text = "1.0"
			)

			item = getUserProp selArray[1] "vision_physics_dynamicFriction" 
			if item != undefined then
			(
				txtDynFriction.Text = item as string
			)
			else
			(
				txtDynFriction.Text = "1.0"
			)

			item = getUserProp selArray[1] "vision_physics_userData" 
			if item != undefined then
			(
				txtUserData.Text = item as string
			)
			else
			(
				txtUserData.Text = ""
			)

			item = getUserProp selArray[1] "vision_portal_singleSided"
			if item != undefined then
			(
				chkSingleSidedPortal.triState = item as integer
			)
			else
			(
				chkSingleSidedPortal.triState = 0
			)

			item = getUserProp selArray[1] "vision_portal_leadsToOutside"
			if item != undefined then
			(
				chkLeadsToOutsidePortal.triState = item as integer
			)
			else
			(
				chkLeadsToOutsidePortal.triState = 0
			)

		)
		else
		(
			messageBox "Nothing selected! Please select a node to set the tags to."
			destroyDialog roExportTags
		)
	)


	on btnOk pressed do
	(
		--Set the entered values as tags to the selected node
		selArray = selection as array
		if selArray.count >0 then
		(
			--set the values

			setUserProp selArray[1] "vision_export_as" ddl2.items[ddl2.selection]

			setUserProp selArray[1] "vision_mesh_tag" editTag.Text

			setUserProp selArray[1] "vision_mesh_userFlags" edtUserFlags.Text
      
      setUserProp selArray[1] "vision_mesh_name" editName.Text

			ret = CheckInput edtTraceMask lblTraceMask 0 65535
			if ret == false then
				return false

			setUserProp selArray[1] "vision_mesh_traceMask" edtTraceMask.Text

			ret = CheckInput edtVisMask lblVisMask 0 65535
			if ret == false then
				return false

			setUserProp selArray[1] "vision_mesh_visMask" edtVisMask.Text

			ret = CheckInput edtLightMask lblLightMask 0 65535
			if ret == false then
				return false

			setUserProp selArray[1] "vision_mesh_lightMask" edtLightMask.Text

			ret = CheckInputFloat edtNearClip lblnc 0.0 100000.0
			if ret == false then
				return false

			setUserProp selArray[1] "vision_near_clip" edtNearClip.Text

			ret = CheckInputFloat edtFarClip lblfc 0.0 100000.0
			if ret == false then
				return false

			setUserProp selArray[1] "vision_far_clip" edtFarClip.Text

			ret = CheckInput edtLodIndex lblli -1 20
			if ret == false then
				return false

			setUserProp selArray[1] "vision_lod_index" edtLodIndex.Text

			setUserProp selArray[1] "vision_physics_colLayer" (cmbPhyGroup.selection - 1)	--Max-Arrays are 1-based

			ret = CheckInput txtSubsystemID lblHavokID2 0 32
			if ret == false then
				return false

			setUserProp selArray[1] "vision_physics_colSubsysID" txtSubsystemID.Text

			ret = CheckInput txtDontCollideID lblNotCollideID 0 32
			if ret == false then
				return false

			setUserProp selArray[1] "vision_physics_colNotSubsysID" txtDontCollideID.Text

			ret = CheckInput txtSysGroup lblSysGroup 0 32767
			if ret == false then
				return false

			setUserProp selArray[1] "vision_physics_colSystemGroup" txtSysGroup.Text

			ret = CheckInputFloat txtRestitution lblRestitution 0.0 1.0
			if ret == false then
				return false

			setUserProp selArray[1] "vision_physics_restitution" txtRestitution.Text

			ret = CheckInputFloat txtDynFriction lblDynFriction 0.0 1.0
			if ret == false then
				return false

			setUserProp selArray[1] "vision_physics_dynamicFriction" txtDynFriction.Text

			setUserProp selArray[1] "vision_physics_userData" txtUserData.Text

			setUserProp selArray[1] "vision_portal_singleSided" chkSingleSidedPortal.triState

			setUserProp selArray[1] "vision_portal_leadsToOutside" chkLeadsToOutsidePortal.triState

		)
		else
		(
			messageBox "No object selected!"
		)
		destroyDialog roExportTags
	)

	on btnCancel pressed do
	(
		destroyDialog roExportTags
	)
)

createDialog roExportTags escapeEnabled:true modal:true

