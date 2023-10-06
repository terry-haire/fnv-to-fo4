	 if getnodebyname "bhkRigidBody" != undefined then
	 (
		select(getnodebyname "bhkRigidBody")
		max modify mode
		hwndVC = (windows.getChildHWND #max "Rigid Body Parameters")[2]
		child_array = UIAccessor.GetChildWindows hwndVC
		--for j = 1 to child_array.count do
		(
			--child_name = UIAccessor.GetWindowText child_array[j]
			index = -1
			child_name = UIAccessor.GetWindowText child_array[3]
			if child_name == "Static (O,F3,S)" then index = 1
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
			if index == -1 then 
			(
				if queryBox ("Unknown layer detected. Continue ?") title:"Warning" == false then exit
			)
		)
	)
						/*max utility mode 
						UtilityPanel.OpenUtility collsiongroup -- CollisionGroup Must be open
						hwndVC = (windows.getChildHWND #max "CollisionGroup")[2]
						child_array = UIAccessor.GetChildWindows hwndVC
						--for j = 1 to child_array.count do
						for j = 0 to 37 do
						(
								--print j
								hwnd = child_array[6]
								local WM_COMMAND = 0x111 -- Windows Message: Command
								local CB_SETCURSEL = 0x014E -- ComboBox message: Set current selection
								local CBN_SELCHANGE = 1
								my_id = UIAccessor.getWindowResourceID hwnd
								windows.sendMessage hwnd CB_SETCURSEL j 0 -- set selection
								windows.sendMessage hwndVC WM_COMMAND ((bit.shift CBN_SELCHANGE 16) + my_id) hwnd -- message parent
								print (UIAccessor.GetWindowText child_array[6])
						
						)*/
/*
for i = 0 to 57 do
(
hwnd = child_array[3]
local WM_COMMAND = 0x111 -- Windows Message: Command
local CB_SETCURSEL = 0x014E -- ComboBox message: Set current selection
local CBN_SELCHANGE = 1
my_id = UIAccessor.getWindowResourceID hwnd
windows.sendMessage hwnd CB_SETCURSEL i 0 -- set selection
windows.sendMessage hwndVC WM_COMMAND ((bit.shift CBN_SELCHANGE 16) + my_id) hwnd -- message parent
print (UIAccessor.GetWindowText child_array[3])
)
*/
/*
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
if child_name == "Stairs (O,F3)"                  then index = 19
if child_name == "CharController (O,F3)"          then index = 20
if child_name == "AvoidBox (O,F3)"                then index = 21
if child_name == "? (O,F3)"                       then index = 22
if child_name == "? (O,F3)"                       then index = 23
if child_name == "CameraPick (O,F3)"              then index = 24
if child_name == "ItemPick (O,F3)"                then index = 25
if child_name == "LineOfSight (O,F3)"             then index = 26
if child_name == "PathPick (O,F3)"                then index = 27
if child_name == "CustomPick1 (O,F3)"             then index = 28
if child_name == "CustomPick2 (O,F3)"             then index = 29
if child_name == "SpellExplosion (O,F3)"          then index = 30
if child_name == "DroppingPick (O,F3)"            then index = 31
if child_name == "Other (O,F3)"                   then index = 32
if child_name == "Head (O,F3)"                    then index = 33
if child_name == "Body (O,F3)"                    then index = 34
if child_name == "Spine1 (O,F3)"                  then index = 35
if child_name == "Spine2 (O,F3)"                  then index = 36
if child_name == "LUpperArm (O,F3)"               then index = 37
if child_name == "LForeArm (O,F3)"                then index = 38
if child_name == "LHand (O,F3)"                   then index = 39
if child_name == "LThigh (O,F3)"                  then index = 40
if child_name == "LCalf (O,F3)"                   then index = 41
if child_name == "LFoot (O,F3)"                   then index = 42
if child_name == "RUpperArm (O,F3)"               then index = 43
if child_name == "RForeArm (O,F3)"                then index = 44
if child_name == "RHand (O,F3)"                   then index = 45
if child_name == "RThigh (O,F3)"                  then index = 46
if child_name == "RCalf (O,F3)"                   then index = 47
if child_name == "RFoot (O,F3)"                   then index = 48
if child_name == "Tail (O,F3)"                    then index = 49
if child_name == "SideWeapon (O,F3)"              then index = 50
if child_name == "Shield (O,F3)"                  then index = 51
if child_name == "Quiver (O,F3)"                  then index = 52
if child_name == "BackWeapon (O,F3)"              then index = 53
if child_name == "BackWeapon (O,F3)"              then index = 54
if child_name == "PonyTail (O,F3)"                then index = 55
if child_name == "Wing (O,F3)"                    then index = 56
if child_name == "Null (O,F3,S)"                  then index = 57

"Unidentified"                                  0
"Static"                                        1
"Anim Static"                                   2
"Transparent"                                   3
"Clutter"                                       4
"Weapon"                                        5
"Projectile"                                    6
"Spell"                                         7
"Biped"                                         8
"Tree"                                          9
"Prop"                                          10
"Water"                                         11
"Trigger"                                       12
"Terrain"                                       13
"Trap"                                          14
"NonCollidable"                                 15
"CloudTrap"                                     16
"Ground"                                        17
"Portal"                                        18
"Small Debris"                                  19
"Large Debris"                                  20
"Acoustic Space"                                21
"ActorZone"                                     22
"ProjectileZone"                                23
"GasTrap"                                       24
"ShellCasing"                                   25
"Transparent Small"                             26
"Invisible Wall"                                27
"Transparent Small Anim"                        28
"Clutter Large"                                 29
"Character Controller"                          30
"Stair Helper"                                  31
"FX Collider"                                   32
"Falling Trap"                                  33
"NavMesh Cut"                                   34
"Critter"                                       35
"spellTrigger"                                  36
"Clutter NoNavCut"                              37
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
if child_name == "? (O,F3)"                       then index = 22
if child_name == "? (O,F3)"                       then index = 23
if child_name == "CameraPick (O,F3)"              then index = 24
if child_name == "ItemPick (O,F3)"                then index = 25
if child_name == "LineOfSight (O,F3)"             then index = 26
if child_name == "PathPick (O,F3)"                then index = 27
if child_name == "CustomPick1 (O,F3)"             then index = 28
if child_name == "CustomPick2 (O,F3)"             then index = 29
if child_name == "SpellExplosion (O,F3)"          then index = 30
if child_name == "DroppingPick (O,F3)"            then index = 31
if child_name == "Other (O,F3)"                   then index = 32
if child_name == "Head (O,F3)"                    then index = 33
if child_name == "Body (O,F3)"                    then index = 34
if child_name == "Spine1 (O,F3)"                  then index = 35
if child_name == "Spine2 (O,F3)"                  then index = 36
if child_name == "LUpperArm (O,F3)"               then index = 37
if child_name == "LForeArm (O,F3)"                then index = 38
if child_name == "LHand (O,F3)"                   then index = 39
if child_name == "LThigh (O,F3)"                  then index = 40
if child_name == "LCalf (O,F3)"                   then index = 41
if child_name == "LFoot (O,F3)"                   then index = 42
if child_name == "RUpperArm (O,F3)"               then index = 43
if child_name == "RForeArm (O,F3)"                then index = 44
if child_name == "RHand (O,F3)"                   then index = 45
if child_name == "RThigh (O,F3)"                  then index = 46
if child_name == "RCalf (O,F3)"                   then index = 47
if child_name == "RFoot (O,F3)"                   then index = 48
if child_name == "Tail (O,F3)"                    then index = 49
if child_name == "SideWeapon (O,F3)"              then index = 50
if child_name == "Shield (O,F3)"                  then index = 51
if child_name == "Quiver (O,F3)"                  then index = 52
if child_name == "BackWeapon (O,F3)"              then index = 53
if child_name == "BackWeapon (O,F3)"              then index = 54
if child_name == "PonyTail (O,F3)"                then index = 55
if child_name == "Wing (O,F3)"                    then index = 56
if child_name == "Null (O,F3,S)"                  then index = 57