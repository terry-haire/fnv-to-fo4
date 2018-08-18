--print (getUserPropBuffer selection[1])
--print (getUserProp selection[1] "ColGroupLastMat")
--setUserProp selection[1] "\r\nColGroupLastMat" "Generic"
 parent_hwnd = for c in windows.getChildrenHWND #max where c[4] == "ModifyTask" do exit with c[1]
	 print parent_hwnd
child_array = UIAccessor.GetChildWindows parent_hwnd
for i = 1 to child_array.count do
(
	--print child_array[i]
	child_name = UIAccessor.GetWindowText child_array[i]
	print child_name
	if child_name == "Sets" then	
	(
		print(UIAccessor.GetParentWindow child_array[i])
	)
	if child_name == "Sets" then	exit
	--if child_array[i].tooltip != undefined then button_name = child_array[i].tooltip
	--print button_name
	j = UIAccessor.IsWindow child_array[i]
	if j == false then print "false"
	--if child_name == "CustButton" then UIAccessor.PressButton child_array[i] --child_array[i].tooltip
	--if child_name == "CustButton" then exit
)