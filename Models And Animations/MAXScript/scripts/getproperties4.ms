(
	max utility mode -- CollisionGroup Must be open
    local hwndVC = (windows.getChildHWND #max "CollisionGroup")[2]
	child_array = UIAccessor.GetChildWindows hwndVC
	for i = 1 to child_array.count do
	(
		child_name = UIAccessor.GetWindowText child_array[i]
		if child_name == "NullMaterial" then	
		(
			index = 8
			hwnd = child_array[i]
			local WM_COMMAND = 0x111 -- Windows Message: Command
			local CB_SETCURSEL = 0x014E -- ComboBox message: Set current selection
			local CBN_SELCHANGE = 1
			my_id = UIAccessor.getWindowResourceID hwnd
			windows.sendMessage hwnd CB_SETCURSEL index 0 -- set selection
			windows.sendMessage hwndVC WM_COMMAND ((bit.shift CBN_SELCHANGE 16) + my_id) hwnd -- message parent
		)
		if child_name == "Unidentified" then	
		(
			index = 8
			hwnd = child_array[i]
			local WM_COMMAND = 0x111 -- Windows Message: Command
			local CB_SETCURSEL = 0x014E -- ComboBox message: Set current selection
			local CBN_SELCHANGE = 1
			my_id = UIAccessor.getWindowResourceID hwnd
			windows.sendMessage hwnd CB_SETCURSEL index 0 -- set selection
			windows.sendMessage hwndVC WM_COMMAND ((bit.shift CBN_SELCHANGE 16) + my_id) hwnd -- message parent
		)
	)
	UIAccessor.PressButton (windows.getChildHWND hwndVC "Apply To Selected")[1]
)