rollout accessTest "access test"
(
	button one "press"
	checkbutton two "Check"
 
	on one pressed do print "One pressed!"
	on two changed state do 
		(
		if state ==true then
		(print "check on")
		else print "check off"
		)
 
)
createDialog accessTest