
global hvkCommonInitialized

if (hvkCommonInitialized == undefined) then
(
	fileIn "havokCommon/hvkCommon_Utils.ms"
	fileIn "havokCommon/hvkCommon_UI.ms"
	hvkCommonInitialized = true
)