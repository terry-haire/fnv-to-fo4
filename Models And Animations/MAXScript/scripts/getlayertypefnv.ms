max modify mode
hwndVC = (windows.getChildHWND #max "Rigid Body Parameters")[2]
child_array = UIAccessor.GetChildWindows hwndVC
hwnd = child_array[3]
(
	local WM_COMMAND = 0x111 -- Windows Message: Command
	local CB_GETCURSEL = 0x0147 -- ComboBox message: Get current selection
	index = (windows.sendMessage hwnd CB_GETCURSEL 0 0) -- set selection
	print index
)
getindexlist = #(0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85)
indexskiplist = #(0,1,undefined,undefined,4,undefined,6,undefined,undefined,9,10,undefined,undefined,undefined,undefined,15,undefined,undefined,undefined,19,undefined,undefined,undefined,undefined,undefined,undefined,undefined,undefined,undefined,undefined,undefined,undefined,undefined,undefined,undefined,undefined,undefined,undefined,undefined,undefined,undefined,undefined,undefined,undefined,undefined,undefined,undefined,undefined,undefined,undefined,undefined,undefined,undefined,undefined,undefined,undefined,undefined,undefined,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85)
indexlist = #(0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,31,30,34)
indexliststringlist = #("Unidentified (O,F3,S)","Static (O,F3,S)","AnimStatic (O,F3,S)","Transparent (O,F3,S)","Clutter (O,F3,S)","Weapon (O,F3,S)","Projectile (O,F3,S)","Spell (O,F3,S)","Biped (O,F3,S)","Tree (O,F3,S)","Prop (O,F3,S)","Water (O,F3,S)","Trigger (O,F3,S)","Terrain (O,F3,S)","Trap (O,F3,S)","NonCollidable (O,F3,S)","CloudTrap (O,F3,S)","Ground (O,F3,S)","Portal (O,F3,S)","Stairs (O,F3)","CharController (O,F3)","AvoidBox (O,F3)","? (O,F3)","? (O,F3)","CameraPick (O,F3)","ItemPick (O,F3)","LineOfSight (O,F3)","PathPick (O,F3)","CustomPick1 (O,F3)","CustomPick2 (O,F3)","SpellExplosion (O,F3)","DroppingPick (O,F3)","Other (O,F3)","Head (O,F3)","Body (O,F3)","Spine1 (O,F3)","Spine2 (O,F3)","LUpperArm (O,F3)","LForeArm (O,F3)","LHand (O,F3)","LThigh (O,F3)","LCalf (O,F3)","LFoot (O,F3)","RUpperArm (O,F3)","RForeArm (O,F3)","RHand (O,F3)","RThigh (O,F3)","RCalf (O,F3)","RFoot (O,F3)","Tail (O,F3)","SideWeapon (O,F3)","Shield (O,F3)","Quiver (O,F3)","BackWeapon (O,F3)","BackWeapon (O,F3)","PonyTail (O,F3)","Wing (O,F3)","Null (O,F3,S)","Debris Small (S)","Debris Large (S)","Acoustic Space (S)","Actor Zone (S)","Projectile Zone (S)","Gas Trap (S)","Shell Casing (S)","Transparent Small (S)","Invisible Wall (S)","Transparent Small Anim (S)","Ward (S)","Char Controller (S)","Stair Helper (S)","Dead Bip (S)","Biped No CC (S)","Avoid Box (S)","Collision Box (S)","Camera Sphere (S)","Door Detection (S)","Cone Projectile (S)","Camera Pick (S)","Item Pick (S)","Line of Sight (S)","Path Pick (S)","Custom Pick 1 (S)","Custom Pick 2 (S)","Spell Explosion (S)","Dropping Pick (S)")
for i = 0 to 85 do
				(
					local WM_COMMAND = 0x111 -- Windows Message: Command
					local CB_SETCURSEL = 0x014E -- ComboBox message: Set current selection
					local CBN_SELCHANGE = 1
					my_id = UIAccessor.getWindowResourceID hwnd
					windows.sendMessage hwnd CB_SETCURSEL i 0 -- set selection
					windows.sendMessage hwndVC WM_COMMAND ((bit.shift CBN_SELCHANGE 16) + my_id) hwnd -- message parent
					print i
					print (UIAccessor.GetWindowText hwnd)
				)