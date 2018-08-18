DialogMonitorOPS.unRegisterNotification id:#eyeInTheSky
 
fn dmnotification =
(
 WindowHandle = DialogMonitorOPS.GetWindowHandle()
 format "Dialog Window Handle: %\n" WindowHandle
 format "Dialog Name: %\n" (UIAccessor.GetWindowText WindowHandle)
 format "Window Class Name: %\n" (UIAccessor.GetWindowClassName WindowHandle)
 format "Window Resource ID: %\n" (UIAccessor.GetWindowResourceID WindowHandle)
 format "Is Window: %\n" (UIAccessor.isWindow WindowHandle)
 format "Window DLL Filename: %\n" (UIAccessor.GetWindowDllFileName WindowHandle)
 format "Window DLL Description: %\n" (UIAccessor.GetWindowDllDescription WindowHandle)
 UIAccessor.SetWindowText WindowHandle" All Your Windows Are Belong To Us"
 format "=====================\n"
 true
)
DialogMonitorOPS.RegisterNotification dmnotification id:#eyeInTheSky
DialogMonitorOPS.Enabled = true
DialogMonitorOPS.ShowNotification()