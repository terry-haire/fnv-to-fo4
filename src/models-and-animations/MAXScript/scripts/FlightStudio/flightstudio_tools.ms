rollout flightstudio_tools_rollout ~FLIGHTSTUDIO_TOOLS_ROLLOUT_CAPTION~ width:318 height:531
(
	slider campos_slider "" pos:[23,247] width:266 height:25
	spinner camerapos "" pos:~CAMERAPOS_POSITION~ width:86 height:16
	button launch_app1 ~LAUNCH_APP1_CAPTION~ pos:~LAUNCH_APP1_POSITION~ width:~LAUNCH_APP1_WIDTH~ height:22
	edittext app_edit1 "" pos:~APP_EDIT1_POSITION~ width:158 height:23
	button set_app1 ~SET_APP1_CAPTION~ pos:~SET_APP1_POSITION~ width:~SET_APP1_WIDTH~ height:22
	button lod_more ~LOD_MORE_CAPTION~ pos:[98,195] width:48 height:22
	button lod_most ~LOD_MOST_CAPTION~ pos:[31,195] width:48 height:22
	button lod_less ~LOD_LESS_CAPTION~ pos:[165,195] width:48 height:22
	button lod_least ~LOD_LEAST_CAPTION~ pos:[232,195] width:~LOD_LEAST_WIDTH~ height:22
	label lbl5 ~LBL5_CAPTION~ pos:~LBL5_POSITION~ width:~LBL5_WIDTH~ height:34
	label lbl10 ":" pos:~LBL10_POSITION~ width:~LBL10_WIDTH~ height:18
	button launch_app2 ~LAUNCH_APP2_CAPTION~ pos:~LAUNCH_APP2_POSITION~ width:~LAUNCH_APP2_WIDTH~ height:22
	edittext app_edit2 "" pos:~APP_EDIT2_POSITION~ width:158 height:23
	button set_app2 ~SET_APP2_CAPTION~ pos:~SET_APP2_POSITION~ width:~SET_APP2_WIDTH~ height:22
	label lbl11 ":" pos:~LBL11_POSITION~ width:~LBL11_WIDTH~ height:18
	button launch_app3 ~LAUNCH_APP3_CAPTION~ pos:~LAUNCH_APP3_POSITION~ width:~LAUNCH_APP3_WIDTH~ height:22
	edittext app_edit3 "" pos:~APP_EDIT3_POSITION~ width:158 height:23
	button set_app3 ~SET_APP3_CAPTION~ pos:~SET_APP3_POSITION~ width:~SET_APP3_WIDTH~ height:22
	label lbl12 ":" pos:~LBL12_POSITION~ width:~LBL12_WIDTH~ height:18
	button launch_app4 ~LAUNCH_APP4_CAPTION~ pos:~LAUNCH_APP4_POSITION~ width:~LAUNCH_APP4_WIDTH~ height:22
	edittext app_edit4 "" pos:~APP_EDIT4_POSITION~ width:158 height:23
	button set_app4 ~SET_APP4_CAPTION~ pos:~SET_APP4_POSITION~ width:~SET_APP4_WIDTH~ height:22
	label lbl13 ":" pos:~LBL13_POSITION~ width:~LBL13_WIDTH~ height:18
	button launch_browser ~LAUNCH_BROWSER_CAPTION~ pos:[16,14] width:~LAUNCH_BROWSER_WIDTH~ height:22
	button launch_fltout ~LAUNCH_FLTOUT_CAPTION~ pos:~LAUNCH_FLTOUT_POSITION~ width:~LAUNCH_FLTOUT_WIDTH~ height:22
	button launch_fltin ~LAUNCH_FLTIN_CAPTION~ pos:~LAUNCH_FLTIN_POSITION~ width:~LAUNCH_FLTIN_WIDTH~ height:22
	GroupBox grp2 ~GRP2_CAPTION~ pos:~GRP2_POSITION~ width:~GRP2_WIDTH~ height:113
	GroupBox grp4 ~GRP4_CAPTION~ pos:~GRP4_POSITION~ width:~GRP4_WIDTH~ height:213
	edittext load_this_file "" pos:~LOAD_THIS_FILE_POSITION~ width:215 height:23
	checkbox usedefaultfile ~USEDEFAULTFILE_CAPTION~ pos:~USEDEFAULTFILE_POSITION~ width:~USEDEFAULTFILE_WIDTH~ height:18
	button set_file_button ~SET_FILE_BUTTON_CAPTION~ pos:~SET_FILE_BUTTON_POSITION~ width:~SET_FILE_BUTTON_WIDTH~ height:22
	label lbl9 ~LBL9_CAPTION~ pos:[31,227] width:~LBL9_WIDTH~ height:21
	
	-- set inifile to the exact location of the fstools.ini
	-- leave blank if location unknown
	-- example: inifile = "c:\\3dsmax6\\scripts\\tools.ini"
	local inifile = ""
	
	fn resetLODs =
	(
		current = flightstudio.getloddistance()
		flightstudio.lodmostdetail()
		mostdist = flightstudio.getloddistance()
		flightstudio.lodleastdetail()
		leastdist = flightstudio.getloddistance()
		flightstudio.setloddistance current
		camerapos.range = [mostdist,leastdist,current]
		camerapos.value = current
		campos_slider.range = [mostdist,leastdist,current]
		campos_slider.value = current
	)
	
	fn newImportFile =
	(		
		resetLODs()
		if(usedefaultfile.state == true) then
		(
			t3 = flightstudio.getlastimport()
			load_this_file.text = "\"" + t3 + "\""
		)
	)
	

	
	checkbox chk5 ~CHK5_CAPTION~ pos:~CHK5_POSITION~ width:~CHK5_WIDTH~ height:17 checked:true
	checkbox chk6 ~CHK6_CAPTION~ pos:~CHK6_POSITION~ width:~CHK6_WIDTH~ height:17 checked:true
	checkbox chk7 ~CHK7_CAPTION~ pos:~CHK7_POSITION~ width:48 height:17 checked:true
	checkbox chk12 ~CHK12_CAPTION~ pos:~CHK12_POSITION~ width:~CHK12_WIDTH~ height:17 checked:true
	checkbox chk13 ~CHK13_CAPTION~ pos:~CHK13_POSITION~ width:~CHK13_WIDTH~ height:17 checked:true
	checkbox chk14 ~CHK14_CAPTION~ pos:~CHK14_POSITION~ width:53 height:17 checked:true
	checkbox chk15 ~CHK15_CAPTION~ pos:~CHK15_POSITION~ width:~CHK15_WIDTH~ height:17 checked:true
	checkbox chk16 ~CHK16_CAPTION~ pos:~CHK16_POSITION~ width:~CHK16_WIDTH~ height:17 checked:true
	checkbox chk17 "Cat" pos:~CHK17_POSITION~ width:45 height:17 checked:true
	checkbox chk18 "BSP" pos:~CHK18_POSITION~ width:~CHK18_WIDTH~ height:17 checked:true
	checkbox chk30 ~CHK30_CAPTION~ pos:~CHK30_POSITION~ width:~CHK30_WIDTH~ height:17 checked:true
	checkbox chk31 ~CHK31_CAPTION~ pos:~CHK31_POSITION~ width:~CHK31_WIDTH~ height:17 checked:true
	GroupBox grp8 ~GRP8_CAPTION~ pos:~GRP8_POSITION~ width:~GRP8_WIDTH~ height:116
	checkbox chk71 ~CHK71_CAPTION~ pos:~CHK71_POSITION~ width:~CHK71_WIDTH~ height:17 checked:true
	checkbox chk72 ~CHK72_CAPTION~ pos:~CHK72_POSITION~ width:~CHK72_WIDTH~ height:17 checked:true
	on flightstudio_tools_rollout open do
	(
		format ~FLIGHT_STUDIO_TOOLS_CAPTION~
		
		resetLODs()
		
		if(inifile == "") then
			inifile = scriptspath + "\\fstools.ini"
		if(doesfileexist(inifile) == false) then
		(
			f = getOpenFileName caption:~GETOPENFILENAME_CAPTION~ types:~GETOPENFILENAME_TYPES~ 
			if( f != undefined ) then  
	 			inifile = f
			else
				inifile = "fstools.ini"			
		)
		format "inifile %\n" inifile
				
		app_edit1.text = getinisetting inifile "FlightStudioTools" "App1"
		app_edit2.text = getinisetting inifile  "FlightStudioTools" "App2"
		app_edit3.text = getinisetting inifile  "FlightStudioTools" "App3"
		app_edit4.text = getinisetting inifile  "FlightStudioTools" "App4"
		t1 = getinisetting inifile  "FlightStudioTools" "UseCurrent"
		if(t1 == "0") then 
		(
			t2 = getinisetting inifile  "FlightStudioTools" "LoadThisFile"
			load_this_file.text = "\"" + t2 + "\""
			usedefaultfile.state = false
		)
		else
		(
			t4 = flightstudio.getlastimport()
			load_this_file.text = "\"" + t4 + "\""
			load_this_file.enabled = false
			usedefaultfile.state = true
			set_file_button.enabled = false
		)
	
		callbacks.removescripts #postImport
		callbacks.addscript #postImport "flightstudio_tools_rollout.newImportFile()" 	
	)
	on flightstudio_tools_rollout close do
	(
		setinisetting inifile  "FlightStudioTools" "App1" app_edit1.text
		setinisetting inifile  "FlightStudioTools" "App2" app_edit2.text
		setinisetting inifile  "FlightStudioTools" "App3" app_edit3.text
		setinisetting inifile  "FlightStudioTools" "App4" app_edit4.text
		if(usedefaultfile.state == false) then
			setinisetting inifile  "FlightStudioTools" "UseCurrent" "0"
		else
			setinisetting inifile  "FlightStudioTools" "UseCurrent" "1"
		setinisetting inifile  "FlightStudioTools" "LoadThisFile" load_this_file.text
	)
	on campos_slider changed val do
	(
		camerapos.value = val
		flightstudio.setloddistance camerapos.value
	)
	on camerapos changed val do
	(
		flightstudio.setloddistance val
		campos_slider.value = val
	)
	on launch_app1 pressed do
	( 
		shelllaunch app_edit1.text load_this_file.text
	)
	on set_app1 pressed do
	(
		f = getOpenFileName caption:~GETOPENFILENAME_EXE_CAPTION~ types:~GETOPENFILENAME_EXE_TYPES_CAPTION~ 
		if( f != undefined ) then  (
	 		app_edit1.text = f
		)
	)
	on lod_more pressed do
	(
		FlightStudio.LodMoreDetail()
		dist = flightstudio.getloddistance()
		camerapos.value = dist
		campos_slider.value = dist
	)
	on lod_most pressed do
	(
		FlightStudio.LodMostDetail()
		dist = flightstudio.getloddistance()
		camerapos.value = dist
		campos_slider.value = dist
	)
	on lod_less pressed do
	(
		FlightStudio.LodLessDetail()
		dist = flightstudio.getloddistance()
		camerapos.value = dist
		campos_slider.value = dist
	)
	on lod_least pressed do
	(
		FlightStudio.LodLeastDetail()
		dist = flightstudio.getloddistance()
		camerapos.value = dist
		campos_slider.value = dist
	)
	on launch_app2 pressed do
	( 
		shelllaunch app_edit2.text load_this_file.text
	)
	on set_app2 pressed do
	(
		f = getOpenFileName caption:~GETOPENFILENAME_EXE2__CAPTION~ types:~GETOPENFILENAME_EXE2_TYPES_CAPTION~ 
		if( f != undefined ) then  (
	 		app_edit2.text = f
		)
	)
	on launch_app3 pressed do
	( 
		shelllaunch app_edit3.text load_this_file.text
	)
	on set_app3 pressed do
	(
		f = getOpenFileName caption:~GETOPENFILENAME_EXE2_CAPTION~ types:~GETOPENFILENAME_EXE2_TYPES2_CAPTION~ 
		if( f != undefined ) then  (
	 		app_edit3.text = f
		)
	)
	on launch_app4 pressed do
	( 
		shelllaunch app_edit4.text load_this_file.text
	)
	on set_app4 pressed do
	(
		f = getOpenFileName caption:~GETOPENFILENAME_EXE3_CAPTION~ types:~GETOPENFILENAME_EXE3_TYPES_CAPTION~ 
		if( f != undefined ) then  (
	 		app_edit4.text = f
		)
	)
	on launch_browser pressed do
	(
		FlightStudio.Browser()
	)
	on launch_fltout pressed do
	(
		f = getSaveFileName caption:~GETSAVEFILENAME_CAPTION~ types:~GETSAVEFILENAME_TYPES_CAPTION~ 
			if( f != undefined ) then  (
			deletefile f
	 		exportFile f
		)
	)
	on launch_fltin pressed do
	( 
		resetmaxfile #noprompt
		f = getOpenFileName caption:~GETOPENFILENAME_OPENFLIGHT_CAPTION~ types:~GETOPENFILENAME_OPENFLIGHT_TYPES~ 
		if( f != undefined ) then  (
	 		importFile f
		)
	)
	on usedefaultfile changed t3 do
	(
		if(t3 == true) then
		(
			load_this_file.text = "\"" + flightstudio.getlastimport() + "\""
			load_this_file.enabled = false
			set_file_button.enabled = false
		)
		else
		(
			load_this_file.enabled = true
			set_file_button.enabled = true
		)
	)
	on set_file_button pressed do
	(
		f = getOpenFileName caption:~GETOPENFILENAME_FLT_CAPTION~ types:~GETOPENFILENAME_FLT_TYPES_CAPTION~ 
		if( f != undefined ) then  (
	 		load_this_file.text = "\"" + f + "\""
		)	
	)
	on chk5 changed state do
	(
		flightstudioimport.setignorematerials (not chk5.state)
		format ~SET_IGNORE_MATERIALS_CAPTION~ (not chk5.state)
	)
	on chk6 changed state do
	(
		flightstudioimport.setignoretextures (not chk6.state)
		format ~SET_IGNORE_TEXTURES_CAPTION~ (not chk6.state)
	)
)
-- 
--
createdialog flightstudio_tools_rollout 


