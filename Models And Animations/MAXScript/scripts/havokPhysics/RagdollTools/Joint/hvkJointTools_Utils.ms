
-- Utilities used by the tools

fileIn "havokPhysics/ragdollTools/hvkTools_Globals.ms"

--
-- Definition of a template struct
--

struct hkStructTemplate (modifierType, propValueList)

-- MAXScript is nasty in the sense that assigning arrays does not actually copy them
-- We make a deep copy by converting the template into a string and evaluating it
function hvkJointTools_cloneTemplate original =
(
	local newTemplate = execute (original as string)
	
	return newTemplate
)

--
-- UI Utilities
--

-- Refresh the drop down
function hvkJointTools_updateDropDown =
(
	local fileList = getFiles (hvkGlobal_templatesFolder+"/*.txt")

	local templateList = #()
	for fileName in fileList do
	(
		append templateList (getFileNameFile fileName)		
	)
	
	hvkJointTools.ddlJointType.items = templateList
	
)

--
-- CONVERSTION BETWEEN AXIS CONFIGURATIONS
--

-- We consider X main axis (pointing out), -Z bending axis to be the "standard"

function hvkJointTools_enumerateAxis id =
(
	case id of
	(
		1: return Point3 1 0 0
		2: return Point3 -1 0 0
		3: return Point3 0 1 0
		4: return Point3 0 -1 0
		5: return Point3 0 0 1
		6: return Point3 0 0 -1
		default:
		(
			print "Unknown Axis :" + (id as String)
			return Point3 1 0 0
		)
	)
)

-- Max uses row matrices so we use the "blahToBleh" convention rather than "blehFromBlah" (which we would use for column matrices)
function hvkJointTools_getStandardToUserTransform =
(

	local userMainAxis = hvkJointTools_EnumerateAxis hvkGlobal_mainAxis
	local userBendAxis = hvkJointTools_EnumerateAxis hvkGlobal_bendAxis
	local userOtherAxis = cross userMainAxis userBendAxis

	-- we consider the standard to be X main axis, -Z bend axis, and Y = X x (-Z)  the third axis
	standardToUserMatrix = Matrix3 userMainAxis userOtherAxis  (-userBendAxis) [0,0,0]
	
	return standardToUserMatrix
)

function hvkJointTools_getUserToStandardTransform =
(
	standardToUserMatrix = hvkJointTools_getStandardToUserTransform()
	
	userToStandardMatrix = inverse standardToUserMatrix
	
	return userToStandardMatrix
)

--
-- Parent / Child selection
--

-- Return nodeA and nodeB ordered as [child, parent]. Make sure they are linked
-- Returns undefined on failure
function hvkJointTools_orderParentChild nodeA nodeB parentNodes =
(
	if (undefined == nodeA) or (undefined == nodeB) then return undefined
	
	if (nodeA.parent == nodeB) then return #(nodeB, nodeA)
	
	if (nodeB.parent == nodeA) then return #(nodeA, nodeB)
	
	local assNodeA = hvkTools_getAssociatedBoneOrStartChain nodeA
	local assNodeB = hvkTools_getAssociatedBoneOrStartChain nodeB
	
	-- Try to guess the parenting from their associated bones
	if (assNodeA != undefined) and (assNodeB != undefined) then
	(
		if (hvkCommon_isDescendantOf assNodeA assNodeB) then
		(
			if (parentNodes) then nodeA.parent = nodeB
			return #(nodeB, nodeA)
		)
	
		if (hvkCommon_isDescendantOf assNodeB assNodeA) then
		(
			if (parentNodes) then nodeB.parent = nodeA
			return #(nodeA, nodeB)
		)
	)
		
	return undefined
)

-- Find the constraint modifier associated with this node. Expects only one - returns undefined otherwise
function hvkJointTools_findConstraintModifier theNode =
(
	local havokConstraintModifierTypes = hvkPhysics_getHavokConstraintModifierTypes ()
	
	constraintModifiers = #()
	
	for i=theNode.modifiers.count to 1 by -1 do
	(
		local theModifier = theNode.modifiers[i]
		if (findItem havokConstraintModifierTypes (classOf theModifier)) != 0 then
		(
			append constraintModifiers theModifier
		)
	)

	-- If there is none, or more than one, return undefined
	if (constraintModifiers.count != 1 ) then return undefined
	
	return constraintModifiers[1]
)


	
-- Returns true if a constraint can be created between both rigid bodies
function hvkJointTools_canCreateConstraint nodeA nodeB =
(
	if not (hvkPhysics_isRigidBody nodeA) then return false
	if not (hvkPhysics_isRigidBody nodeB) then return false
	
	local parentChild = hvkJointTools_orderParentChild nodeA nodeB false
	
	if (parentChild != undefined) then
	(
		local childConstMod = hvkJointTools_findConstraintModifier parentChild[2]
		
		if (childConstMod != undefined) then
		(
			-- If the child already is constrained, do not allowed more constraints
			return false
		)
	)
	return true
)

--
-- TEMPLATE UTILITIES
--

-- Looks for an specific property value in the template
function hvkJointTools_getTemplatePropertyValue theTemplate theProperty =
(
	for propValue in theTemplate.propValueList do
	(
		if (propValue[1] == theProperty) then return propValue[2]
	)
	
	return undefined
)

-- Sets an specific property in the template
function hvkJointTools_setTemplatePropertyValue theTemplate theProperty theValue =
(
	for propValue in theTemplate.propValueList do
	(
		if (propValue[1] == theProperty) then 
		(
			propValue[2] = theValue
			return true
		)
	)
	
	return false

)

-- Convers the spaces in a template 
function hvkJointTools_convertSpacesInTemplate theTemplate oldToNew =
(
	local lockTranslation = hvkJointTools_getTemplatePropertyValue theTemplate "parentSpaceTranslationLocked"
	local lockRotation = hvkJointTools_getTemplatePropertyValue theTemplate "parentSpaceRotationLocked"
	local parentRotation = hvkJointTools_getTemplatePropertyValue theTemplate "parentSpaceRotation"
	local parentTranslation = hvkJointTools_getTemplatePropertyValue theTemplate "parentSpaceTranslation"
	local childRotation = hvkJointTools_getTemplatePropertyValue theTemplate "childSpaceRotation"
	local childTranslation = hvkJointTools_getTemplatePropertyValue theTemplate "childSpaceTranslation"
	
	if ((lockTranslation == undefined) or (lockRotation == undefined) or (parentRotation == undefined) \
		or (parentTranslation == undefined) or (childRotation == undefined) or (childTranslation == undefined)) then
	(
		print "Warning : Invalid Template"
		return false
	)
	
	newChildRotation = childRotation * oldToNew
	hvkJointTools_setTemplatePropertyValue theTemplate "childSpaceRotation" newChildRotation

	newChildTranslation = childTranslation * oldToNew
	hvkJointTools_setTemplatePropertyValue theTemplate "childSpaceTranslation" newChildTranslation
	
	-- We only convert the parent space if it's unlocked
	if (not lockRotation) then
	(
		newParentRotation = parentRotation * oldToNew
		hvkJointTools_setTemplatePropertyValue theTemplate "parentSpaceRotation" newParentRotation
	)

	-- We only convert the parent space if it's unlocked
	if (not lockTranslation) then
	(
		newParentTranslation = parentTranslation * oldToNew
		hvkJointTools_setTemplatePropertyValue theTemplate "parentSpaceTranslation" newParentTranslation
	)	
)


-- We want the name to be language independant
function hvkJointTools_getInternalModifierTypeName modifierType =
(
	if modifierType == hkHingeConstraintModifier then return "hkHingeConstraintModifier"
	if modifierType == hkBallAndSocketConstraintModifier then return "hkBallAndSocketConstraintModifier"
	if modifierType == hkRagdollConstraintModifier then return "hkRagdollConstraintModifier"
	if modifierType == hkStiffSpringConstraintModifier then return "hkStiffSpringConstraintModifier"
	if modifierType == hkPrismaticConstraintModifier then return "hkPrismaticConstraintModifier"
	if modifierType == hkWheelConstraintModifier then return "hkWheelConstraintModifier"
	if modifierType == hkFixedConstraintModifier then return "hkFixedConstraintModifier"
	
	return undefined
)

-- Fills a template from a modifier
function hvkJointTools_getTemplateFromModifier theModifier =
(
	local havokConstraintModifierTypes = hvkPhysics_getHavokConstraintModifierTypes ()
	
	local modType = classOf theModifier
	
	if (findItem havokConstraintModifierTypes modType) == 0 then return undefined
	
	-- get a list of properties + value
	
	-- we ignore some of the properties (see EXP-563)
	local ignoreProperties = #("parent","constrainTo","childSpaceInWorld","parentSpaceInWorld")
	
	local pList = getPropNames theModifier
	
	local pvList = #()
	
	for prop in pList do
	(
		propStr = prop as string
		value = getProperty theModifier prop
		if (findItem ignoreProperties propStr) == 0 then
		(
			append pvList #(propStr,value)
		)
	)
		
	local theTemplate = hkStructTemplate modifierType:modType propValueList:pvList

	-- Convert the template to "standard" coordinates
	local userToStandard = hvkJointTools_getUserToStandardTransform ()
	hvkJointTools_convertSpacesInTemplate theTemplate userToStandard
	
	return theTemplate
)

-- Convert a template to a text buffer
function hvkJointTools_templateToText theTemplate =
(
	local modifierName = hvkJointTools_getInternalModifierTypeName theTemplate.modifierType
	
	local txt = modifierName + "\n"
	
	for pv in theTemplate.propValueList do
	(
		prop = pv[1]
		value = pv[2]
		txt = txt + prop + "\n"
		txt = txt + (value as string) + "\n"
	)
	
	return txt
)

-- Convert a text buffer to a template
function hvkJointTools_textToTemplate txt = 
(
	local template = #()
	
	local txtStream = txt as StringStream
	
	-- readline() in 3DS Max 2013 returns empty string on line endings. This differs from 
	-- previous versions. As a temporary fix, consume empty strings during normal processing, 
	-- but break on EOF
	local modifierName = ""
	do 
	(
		if (eof txtStream) then exit
		modifierName = readline txtStream
	) while (modifierName == "")

	local modType = execute modifierName 
	
	local pvList = #()
	
	while not eof txtStream do
	(
		local prop = ""
		do 
		(
			if (eof txtStream) then exit
			prop = readline txtStream
		) while (prop == "")
		
		local valueStr = ""
		do 
		(
			if (eof txtStream) then exit
			valueStr = readline txtStream
		) while (valueStr == "")
		
		local value = execute valueStr
		append pvList #(prop,value)
	)
	
	local theTemplate = hkStructTemplate modifierType:modType propValueList:pvList
	
	return theTemplate
)

--
-- Apply a constraint template to an object (child)
--
function hvkJointTools_createConstraintFromTemplate theTemplate parentNode childNode=
(
	local theModifier = execute ((theTemplate.modifierType as string) + "()")
	
	if (theModifier == undefined) then return undefined
	
	theModifier.constrainTo = 1
	theModifier.parent = parentNode
	
	-- Get a list of current valid properties
	-- getPropNAmes returns the properties as names (#mass) rather than strings ("mass") so we convert
	-- We also ignore some properties that may have mistakenly saved in the template (EXP-563)
	local ignoreProperties = #("parent","constrainTo","childSpaceInWorld","parentSpaceInWorld")
	local applicableProperties = #()
	for propName in (getPropNames theModifier) do
	(
		local propStr = (propName as string)
		if (findItem ignoreProperties propStr) == 0 then
		(
			append applicableProperties propStr
		)
	)
	
	-- (!) Important : We do a copy of the template since max uses object references and we don't want to modify the original
	local templateCopy = hvkJointTools_cloneTemplate theTemplate
	
	-- Convert the template to "standard" coordinates
	local standardToUser = hvkJointTools_getStandardToUserTransform ()
	hvkJointTools_convertSpacesInTemplate templateCopy standardToUser
	
	-- Hack : We apply the properties twice to avoid problems with lock/unlock updates
	for i=1 to 2 do
	(
		-- apply the rest of properties
		for pv in templateCopy.propValueList do
		(
			local prop = pv[1]
			local value = pv[2]
			
			-- make sure the property is still there
			if (findItem applicableProperties prop) == 0 then
			(
				print ("Cannot apply property : <"+prop+">\n")
			)
			else
			(
				setProperty theModifier prop value
			)
		)
	)
			
	-- Add the modifier
	addModifier childNode theModifier
	
	return theModifier
)

--
-- Save / Load Template
--
function hvkJointTools_saveTemplate template =
(
	local initialPath = hvkGlobal_templatesFolder+"/*.txt"
	local filename = getSaveFileName caption:"Save Template As" filename:initialPath types:"Templates (*.txt)|(*.txt)"
	
	if (undefined != filename) then
	(
		if (getFileNameType filename) != ".txt" then 
		(
			filename = filename + ".txt"
			
			-- EXP-231 : Always warn before overwriting
			if (doesFileExist filename) then
			(
				okToOverwrite = queryBox (filename + " already exists.\nDo you want to replace it?") title:"Save Template As"
				if (not okToOverwrite) then
				(
					-- Try again
					return (hvkJointTools_saveTemplate template) 
				)				
			)
		)
	
		local theFile = openFile filename mode:"wt"
		
		if (undefined != theFile) then
		(
			local templateTxt = hvkJointTools_templateToText template

			format templateTxt to:theFile

			close theFile 
			
			return filename
		)
	)
	
	return undefined
)


function hvkJointTools_loadTemplate filename = 
(
	
	if (undefined == filename) then
	(
		local initialPath = hvkGlobal_templatesFolder+"/*.txt"
		filename = getOpenFileName caption:"Load Template" filename:initialPath types:"Templates (*.txt)|(*.txt)"
	)
	
	if (undefined != filename) then
	(
		if (getFileNameType filename) != ".txt" then filename = filename + ".txt"

		local theFile = openFile filename mode:"rt"
		
		if (undefined != theFile) then
		(
			-- max size of template : 8k
			local templateTxt = readChars theFile 8192 errorAtEOF:false
			
			local template = hvkJointTools_textToTemplate templateTxt
			
			close theFile
			
			return template
		)
	)

	return undefined
		
)


-- Get selected template in UI
function hvkJointTools_GetSelectedTemplate =
(
	local templateName = hvkJointTools.ddlJointType.selected
	
	local filename = hvkGlobal_templatesFolder + "/"+templatename+".txt"
	
	local template = hvkJointTools_loadTemplate filename
	
	return template
)



































