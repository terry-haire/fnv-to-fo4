-- Helper to create portals.
function hvkVision_createVisionPortal ang axis =
(
	newplane = plane lengthsegs:1 widthsegs:1 wirecolor:[255,255,0]
	newplane.name = uniqueName "Portal"
	newplane.material = standard()
	newplane.material.diffuse = color 255 255 0
	newplane.material.selfIllumAmount = 90
	rotate newplane ang axis
	setUserProp newplane "vision_export_as" "portal"
)