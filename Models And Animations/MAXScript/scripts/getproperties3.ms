(
	local hwndVC = (windows.getChildHWND #max "Parameters")[2]
	print hwndVC
	child_array = UIAccessor.GetChildWindows hwndVC
	for i = 1 to child_array.count do
	(
		--print(UIAccessor.GetWindowText child_array[i])
		--print(UIAccessor.GetWindowClassName child_array[i])
		dropdown = UIAccessor.GetWindowText child_array[i]
		if dropdown != undefined then
		(
			print i
			print dropdown
		)
	)
	dropdown = UIAccessor.GetWindowText child_array[16]
	print dropdown
	dropdown = UIAccessor.GetWindowText child_array[20]
	print dropdown
	dropdown = UIAccessor.GetWindowText child_array[24]
	print dropdown
	dropdown = UIAccessor.GetWindowText child_array[29]
	print dropdown
	dropdown = UIAccessor.GetWindowText child_array[34]
	print dropdown
	dropdown = UIAccessor.GetWindowText child_array[39]
	print dropdown
	dropdown = UIAccessor.GetWindowText child_array[44]
	print dropdown
	dropdown = UIAccessor.GetWindowText child_array[49]
	print dropdown
)