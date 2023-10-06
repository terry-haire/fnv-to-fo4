function gettype selection =
(
	max modify mode
	hwndVC = (windows.getChildHWND #max "Rigid Body Parameters")[2]
	child_array = UIAccessor.GetChildWindows hwndVC
	index = -1
	child_name = UIAccessor.GetWindowText child_array[3]
	if child_name == "Unidentified (O,F3,S)"          then index = 0
	if child_name == "Static (O,F3,S)"                then index = 1
	if child_name == "AnimStatic (O,F3,S)"            then index = 2
	if child_name == "Transparent (O,F3,S)"           then index = 3
	if child_name == "Clutter (O,F3,S)"               then index = 4
	if child_name == "Weapon (O,F3,S)"                then index = 5
	if child_name == "Projectile (O,F3,S)"            then index = 6
	if child_name == "Spell (O,F3,S)"                 then index = 7
	if child_name == "Biped (O,F3,S)"                 then index = 8
	if child_name == "Tree (O,F3,S)"                  then index = 9
	if child_name == "Prop (O,F3,S)"                  then index = 10
	if child_name == "Water (O,F3,S)"                 then index = 11
	if child_name == "Trigger (O,F3,S)"               then index = 12
	if child_name == "Terrain (O,F3,S)"               then index = 13
	if child_name == "Trap (O,F3,S)"                  then index = 14
	if child_name == "NonCollidable (O,F3,S)"         then index = 15
	if child_name == "CloudTrap (O,F3,S)"             then index = 16
	if child_name == "Ground (O,F3,S)"                then index = 17
	if child_name == "Portal (O,F3,S)"                then index = 18
	if child_name == "Stairs (O,F3)"                  then index = 31
	if child_name == "CharController (O,F3)"          then index = 30
	if child_name == "AvoidBox (O,F3)"                then index = 34
	if index == -1 OR index == 0 then 
	(
		if queryBox ("Unknown layer detected. Continue ?") title:"Warning" == false then exit
	)
	skiplist = #(2,3,5,7,8,11,12,13,14,15,16,17,18,30,31,34)
	for i = 1 to skiplist.count do
	(
		if index == i then
		(
			Exit
		)
	)
	delete selection
	--else queryBox ("No bhkRigidBody Detected. Continue ?") title:"Warning" == false then exit()
	
	first = true
)

function getmaterial selection =
(
	/*if first == false then 
	(
		MultipleRigidBodyWarning = queryBox ("Multiple Rigid Bodies have been detected. Continue ?") title:"Warning"				
	)
	if (MultipleRigidBodyWarning) then first = true
	else
	(
		return()
	)*/
	index2 = -1
	indexlist = #(0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,31,30,34)
	if selection[1].modifiers[#bhkRigidBodyModifier].material == -1 then index2 = 1 -- Generic
	if selection[1].modifiers[#bhkRigidBodyModifier].material == 0 then  index2 = 57 -- Stone
	if selection[1].modifiers[#bhkRigidBodyModifier].material == 1 then  index2 = 25 -- Cloth
	if selection[1].modifiers[#bhkRigidBodyModifier].material == 2 then  index2 = 29 -- Dirt
	if selection[1].modifiers[#bhkRigidBodyModifier].material == 3 then  index2 = 31 -- Glass
	if selection[1].modifiers[#bhkRigidBodyModifier].material == 4 then  index2 = 33 -- Grass
	if selection[1].modifiers[#bhkRigidBodyModifier].material == 5 then  index2 = 39 -- Metal
	if selection[1].modifiers[#bhkRigidBodyModifier].material == 6 then  index2 = 46 -- Organic
	if selection[1].modifiers[#bhkRigidBodyModifier].material == 7 then  index2 = 52 -- Skin
	if selection[1].modifiers[#bhkRigidBodyModifier].material == 8 then  index2 = 66 -- Water
	if selection[1].modifiers[#bhkRigidBodyModifier].material == 9 then  index2 = 78 -- Wood
	if selection[1].modifiers[#bhkRigidBodyModifier].material == 10 then index2 = 64 -- Heavy Stone
	if selection[1].modifiers[#bhkRigidBodyModifier].material == 11 then index2 = 41 -- Heavy Metal
	if selection[1].modifiers[#bhkRigidBodyModifier].material == 12 then index2 = 81 -- Heavy Wood
	if selection[1].modifiers[#bhkRigidBodyModifier].material == 13 then index2 = 24 -- Chain
	if selection[1].modifiers[#bhkRigidBodyModifier].material == 14 then index2 = 55 -- Snow
	if selection[1].modifiers[#bhkRigidBodyModifier].material == 15 then index2 = 65 -- Stone Stairs
	if selection[1].modifiers[#bhkRigidBodyModifier].material == 16 then index2 = 32 -- Cloth Stairs
	if selection[1].modifiers[#bhkRigidBodyModifier].material == 17 then index2 = 30 -- Dirt Stairs
	if selection[1].modifiers[#bhkRigidBodyModifier].material == 18 then index2 = 32 -- Glass Stairs
	if selection[1].modifiers[#bhkRigidBodyModifier].material == 19 then index2 = 34 -- Grass Stairs
	if selection[1].modifiers[#bhkRigidBodyModifier].material == 20 then index2 = 32 -- Metal Stairs
	if selection[1].modifiers[#bhkRigidBodyModifier].material == 21 then index2 = 32 -- Organic Stairs
	if selection[1].modifiers[#bhkRigidBodyModifier].material == 22 then index2 = 32 -- Skin Stairs
	if selection[1].modifiers[#bhkRigidBodyModifier].material == 23 then index2 = 32 -- Water Stairs
	if selection[1].modifiers[#bhkRigidBodyModifier].material == 24 then index2 = 83 -- Wood Stairs
	if selection[1].modifiers[#bhkRigidBodyModifier].material == 25 then index2 = 65 -- Heavy Stone Stairs
	if selection[1].modifiers[#bhkRigidBodyModifier].material == 26 then index2 = 32 -- Heavy Metal Stairs
	if selection[1].modifiers[#bhkRigidBodyModifier].material == 27 then index2 = 83 -- Heavy Wooden Stairs
	if selection[1].modifiers[#bhkRigidBodyModifier].material == 28 then index2 = 32 -- Chain Stairs
	if selection[1].modifiers[#bhkRigidBodyModifier].material == 29 then index2 = 56 -- Snow Stairs
	if selection[1].modifiers[#bhkRigidBodyModifier].material == 30 then index2 = 39 -- Elevator
	if selection[1].modifiers[#bhkRigidBodyModifier].material == 31 then index2 = 46 -- Rubber
	if index2 == undefined then if queryBox ("No bhkRigidBody Detected. Continue ?") title:"Warning" == false then exit()
	/* --Skyrim
	if selection[1].modifiers[#bhkRigidBodyModifier].material == 0 then index2 = 57 -- Barrel
	if selection[1].modifiers[#bhkRigidBodyModifier].material == 0 then index2 = 57 -- Bottle
	if selection[1].modifiers[#bhkRigidBodyModifier].material == 0 then index2 = 57 -- Broken Stone
	if selection[1].modifiers[#bhkRigidBodyModifier].material == 0 then index2 = 57 -- Dragon
	if selection[1].modifiers[#bhkRigidBodyModifier].material == 0 then index2 = 57 -- Gravel
	if selection[1].modifiers[#bhkRigidBodyModifier].material == 0 then index2 = 57 -- Ice
	if selection[1].modifiers[#bhkRigidBodyModifier].material == 0 then index2 = 57 -- Light Wood
	if selection[1].modifiers[#bhkRigidBodyModifier].material == 0 then index2 = 57 -- Armor Heavy
	if selection[1].modifiers[#bhkRigidBodyModifier].material == 0 then index2 = 57 -- Armor Light
	if selection[1].modifiers[#bhkRigidBodyModifier].material == 0 then index2 = 57 -- Arrow
	if selection[1].modifiers[#bhkRigidBodyModifier].material == 0 then index2 = 57 -- Axe 1Hand
	if selection[1].modifiers[#bhkRigidBodyModifier].material == 0 then index2 = 57 -- Basket
	if selection[1].modifiers[#bhkRigidBodyModifier].material == 0 then index2 = 57 -- Blade 1 Hand
	if selection[1].modifiers[#bhkRigidBodyModifier].material == 0 then index2 = 57 -- Blade 1 Hand Small
	if selection[1].modifiers[#bhkRigidBodyModifier].material == 0 then index2 = 57 -- Blade 2 Hand
	if selection[1].modifiers[#bhkRigidBodyModifier].material == 0 then index2 = 57 -- Blunt 2 Hand
	if selection[1].modifiers[#bhkRigidBodyModifier].material == 0 then index2 = 57 -- Bone
	if selection[1].modifiers[#bhkRigidBodyModifier].material == 0 then index2 = 57 -- Book
	if selection[1].modifiers[#bhkRigidBodyModifier].material == 0 then index2 = 57 -- Bottle Small
	if selection[1].modifiers[#bhkRigidBodyModifier].material == 0 then index2 = 57 -- Boulder Large
	if selection[1].modifiers[#bhkRigidBodyModifier].material == 0 then index2 = 57 -- Boulder Medium
	if selection[1].modifiers[#bhkRigidBodyModifier].material == 0 then index2 = 57 -- Boulder Small
	if selection[1].modifiers[#bhkRigidBodyModifier].material == 0 then index2 = 57 -- Bows Staves
	if selection[1].modifiers[#bhkRigidBodyModifier].material == 0 then index2 = 57 -- Carpet
	if selection[1].modifiers[#bhkRigidBodyModifier].material == 0 then index2 = 57 -- Ceramic Medium
	if selection[1].modifiers[#bhkRigidBodyModifier].material == 0 then index2 = 57 -- Chain Metal
	if selection[1].modifiers[#bhkRigidBodyModifier].material == 0 then index2 = 57 -- Coin
	if selection[1].modifiers[#bhkRigidBodyModifier].material == 0 then index2 = 57 -- Shield Heavy
	if selection[1].modifiers[#bhkRigidBodyModifier].material == 0 then index2 = 57 -- Shield Light
	if selection[1].modifiers[#bhkRigidBodyModifier].material == 0 then index2 = 57 -- Skin Large
	if selection[1].modifiers[#bhkRigidBodyModifier].material == 0 then index2 = 57 -- Skin Small
	if selection[1].modifiers[#bhkRigidBodyModifier].material == 0 then index2 = 57 -- Mud
	if selection[1].modifiers[#bhkRigidBodyModifier].material == 0 then index2 = 57 -- Sand
	*/
)