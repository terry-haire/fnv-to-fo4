/*******************************************************************************
* Lists Styles in a max file
* Author: Attila Szabo
* Date: Nov.23.2006
*******************************************************************************/

/******************************************************************************
* Lists categories and styles to the Listener
*******************************************************************************/
MacroScript ListStylesASCII
	ButtonText:~LISTSTYLESASCII_BUTTONTEXT~
	Category:"DWG.Interop" 
	internalCategory:"DWG.Interop" 
	Tooltip:~LISTSTYLESASCII_TOOLTIP~ 
(
-- constants
strIndent = "  "

function ListStyle aStyle aStyleIndent = 
(
	format "%%\n" aStyleIndent aStyle.name
	
	components = #()
	aStyle.getComponents &components
	for i=1 to components.count do 
	(
		ListStyle components[i] (aStyleIndent + strIndent)
	)
)

function ListStyles aCategory aStyleIndent = 
(
	styles = #()
	aCategory.getStyles &styles
	for i=1 to styles.count do 
	(
		ListStyle styles[i] aStyleIndent
	)
)

function ListCategories = 
(
	format ~FORMATTED_CATEGORIES_CAPTION~ styleMgr.numCategories
	categories =#()
	styleMgr.GetCategories &categories
	for i=1 to categories.count do 
	(
		format "\n%\n" categories[i].name
		ListStyles categories[i] (strIndent + strIndent)
	)
)

function ListStyleMgr = 
(
	format ~FORMATTED_LIST_OF_STYLES_CAPTION~ (maxFilePath + "\\" + maxFileName)
	ListCategories()
)
	
On Execute Do 
(
	ListStyleMgr()
)

)


/*******************************************************************************
* Lists styles to a Tree View
********************************************************************************/
MacroScript ListStylesGUI
	ButtonText:~LISTSTYLESGUI_BUTTONTEXT~
	Category:"DWG.Interop" 
	internalCategory:"DWG.Interop" 
	Tooltip:~LISTSTYLESGUI_TOOLTIP~ 
(

-- indentation in pixels
kIndentation = 10
kRolloutWidth = 200
kRolloutHeight = 400

rollout theRollout ~ROLLOUT_ADT_STYLES_BROWSER~
(
-- Methods that fill in the tree view with ADT styles	
function AddStyle aTVNode aStyle = 
(
	newTVNode = aTVNode.Nodes.add aStyle.name 
	
	components = #()
	aStyle.getComponents &components
	for i=1 to components.count do 
	(
		AddStyle newTVNode components[i]
	)
)

function AddStyles aTVNode aCategory =
(
	styles = #()
	aCategory.getStyles &styles
	for i=1 to styles.count do 
	(
		AddStyle aTVNode styles[i] 
	)
)

function AddCategories aTVNode = 
(
	categories =#()
	styleMgr.GetCategories &categories
	for i=1 to categories.count do 
	(
		newTVNode = aTVNode.Nodes.add categories[i].name
		AddStyles newTVNode categories[i] 
	)
)

function AddStylesMgr aTreeView =
(
	AddCategories (aTreeView.Nodes.add ~ADT_STYLES~)
)


-- Tree view methods

dotNetControl theTreeView "TreeView" width: (kRolloutWidth-10) height: (kRolloutHeight-10) align:#center
	
function clearTreeView tv = 
(
	tv.Nodes.Clear()
)

function initTreeView tv =
(
	tv.Indent= kIndentation 
	--the default style already has root lines.
)

function FillTreeView aTreeView =
(
	clearTreeView aTreeView
	InitTreeView aTreeView 
	AddStylesMgr aTreeView
)

on theTreeView Click arg do 
(
	--First get the TreeView node below the mouse cursor
	--The arg argument has properties .x and .y with the current pos.
	--Use showProperties arg to see what is available...
	--We use the TreeView method GetNodeAt to see what was clicked:
	hitNode = theTreeView.GetNodeAt (dotNetObject "System.Drawing.Point" arg.x arg.y)
	if hitNode != undefined do --if a TreeView node was clicked,
	(
		-- do something
	)
)

on theRollout open do 
(
	FillTreeView theTreeView
)

on theRollout close do 
(
	callbacks.removeScripts #systemPostReset id:#systemPostResetID
	callbacks.removeScripts #systemPostNew id:#systemPostNewID
	callbacks.removeScripts #filePostOpen id:#filePostOpenID
	callbacks.removeScripts #postImport id:#postImportID
	callbacks.removeScripts #fileLinkPostAttach id:#fileLinkPostAttachID
)

) -- rollout

try 
(
  destroyDialog theRollout
  unRegisterViewWindow theRollout
)
catch()

createDialog theRollout kRolloutWidth kRolloutHeight
registerViewWindow theRollout
callbacks.addScript #systemPostReset "theRollout.FillTreeView theRollout.theTreeView" id:#systemPostResetID
callbacks.addScript #systemPostNew "theRollout.FillTreeView theRollout.theTreeView" id:#systemPostNewID
callbacks.addScript #filePostOpen "theRollout.FillTreeView theRollout.theTreeView" id:#filePostOpenID
callbacks.addScript #postImport "theRollout.FillTreeView theRollout.theTreeView" id:#postImportID
callbacks.addScript #fileLinkPostAttach "theRollout.FillTreeView theRollout.theTreeView" id:#fileLinkPostAttachID
)

-- EOF


