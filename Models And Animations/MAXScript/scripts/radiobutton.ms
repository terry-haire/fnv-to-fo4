--useless
--UIAccessor.PressButton
hwndVC = ((windows.getChildHWND #max "Utilities")[2])
UIAccessor.GetWindowClassName hwnd
hwndlist = (UIAccessor.GetChildWindows hwndVC)
for i = 1 to hwndlist.count do 
	(
		--print (UIAccessor.GetWindowText hwndlist[i])
		if (UIAccessor.GetWindowText hwndlist[i]) == "CollsionGroup" then 
		(
			print "DETECTED"
			print hwndlist[i]
			hwnd = hwndlist[i]
			print (UIAccessor.GetWindowClassName hwnd)
			state = true
			local BN_CLICKED = 0 -- clicky message ID
			local BM_SETCHECK = 0x00F1 
			local BM_SETSTATE = 0x00F3
			local WM_COMMAND = 0x111
			local BN_HILITE = 2
			local BN_PUSHED = BN_HILITE
			local BST_CHECKED = 0
			local id = UIAccessor.getWindowResourceID hwnd
						windows.sendMessage hwnd BM_SETCHECK (if state then 1 else 0) 0
						windows.sendMessage hwndVC WM_COMMAND ((bit.shift BN_PUSHED 16) + id) hwnd
			--UIAccessor.PressButton hwndlist[i]
		)
	)
--hwndVC = (windows.getChildHWND #max "CollisionGroup")[2]
--for i = 1 to hwndlist.count do print UIAccessor.GetWindowText hwndlist[i]
--UIAccessor.PressButton (windows.getChildHWND hwnd "CollisionGroup")[1]
--UIAccessor.PressButton (windows.getChildHWND hwndVC "Apply To Selected")[1]
			--			windows.sendMessage btn[1] BM_SETCHECK (if state then 1 else 0) 0
				--		windows.sendMessage parent WM_COMMAND ((bit.shift BN_CLICKED 16) + id) btn[1]