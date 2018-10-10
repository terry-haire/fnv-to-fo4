in coordsys world
(
	--$.pos = $.pos - $.center
	$.pos.z = $.pos.z - $.center.z
	$.pos.z = $.pos.z + (($.max.z - $.min.z) / 2)
	--$.pivot = $.center
)
--($.max.z - $.min.z) / 2
--$.pos.z = $.pos.z + (($.max.z - $.min.z) / 2)
$.rotation = (quat 0 0 0 0)