rollout testddl_rollout "Dropdownlist Handler"
(
  dropdownlist ddl_someList items:#("1","2","3")--this is the dropdownlist
  button btn_select1 "Select 1"--these buttons will set the list
  button btn_select2 "Select 2"--by calling the custom function that
  button btn_select3 "Select 3"--replaces the on selected() handler
 
  --this is the custom function that performs the operations normally done --inside the on selected() event handler:
  fn ddl_someList_Selected itm =--we pass the argument passed to the handler
  (
    format "You selected %\n" itm--and do something inside
  )
  --now we can call this custom function from the event hander itself
  on ddl_someList selected itmdo ddl_someList_Selected itm
  --and from any other event handlers that want to affect the dropdownlist
  on btn_select1 pressed do ddl_someList_Selected (ddl_someList.selection = 1)
  on btn_select2 pressed do ddl_someList_Selected (ddl_someList.selection = 2)
  on btn_select3 pressed do ddl_someList_Selected (ddl_someList.selection = 3)
)
createDialog testddl_rollout