@echo off
set cnt=0

rem LAPTOP
rem set FNVExtracted=C:\Games\FalloutNV\Extracted\Data\
rem set FNVConverted=C:\Games\FalloutNV\Converted\Data\

rem DESKTOP
set FNVExtracted=D:\Games\Fallout New Vegas\FNVExtracted\Data\
set FNVConverted=D:\Games\Fallout New Vegas\FNVFo4 Converted\Data\

for /R "%FNVExtracted%meshes" %%A in (*.nif) do set /a cnt+=1
set /a cnt = cnt/483
echo File count = %cnt%

rem set iStart to 0 for normal operation
rem set iStart to 30 for object lods
set iStart=0

rem delete lodlist only if starting from 0
IF %iStart%==0 (
	echo "Deleting LODList.csv..."
	del "%FNVConverted%Meshes\Terrain\LODList.csv"
	echo "Deleting LOD Groups..."
	FOR /D %%f in ("%FNVConverted%Meshes\Terrain\*") DO (
		rem rmdir /q /s "%%f\objects\groups"
		rmdir /q /s "%%f\objects"
	)
)

FOR /L %%B IN (%iStart%,1,%cnt%) DO (
  ECHO %%B
  rem -silent might be the cause of crashes
  rem
  rem -mi
  rem 	Starts 3ds Max in a minimized mode – but never allows you to open the window for interactive usage. 
  rem
  rem -silent 
  rem 	Comparable to the MAXScript command, setSilentMode, this switch suppresses all MAXScript and 3ds Max UI dialogs so that batch scripts specified by the –U command do not get interrupted.
  rem
  rem -q 
  rem 	Suppresses the splash screen
  rem
  "C:\Program Files\Autodesk\3ds Max 2013\3dsmax.exe" -q -mi -mxs "batchstart = @\"%%B\";global outputdir = @\"c:\\tttobj\\export\";filein @\"C:\\Program Files\\Autodesk\\3ds Max 2013\\scripts\\autoexportnif3_noprompt.ms\""
)
rem "C:\Program Files\Autodesk\3ds Max 2013\3dsmax.exe" -mxs "global batchstart = @"%cnt%";filein @"\C:\Program Files\Autodesk\3ds Max 2013\scripts\autoexportnif3_noprompt.ms\""
rem "C:\Program Files\Autodesk\3ds Max 2013\3dsmax.exe" -mxs "batchstart = @\"%cnt%\";global outputdir = @\"c:\\tttobj\\export\";filein @\"C:\\Program Files\\Autodesk\\3ds Max 2013\\scripts\\autoexportnif3_noprompt.ms\""
pause