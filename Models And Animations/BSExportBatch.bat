@echo off
set cnt=0
set FNVExtracted=C:\Games\FalloutNV\Extracted\Data\
set FNVConverted=C:\Games\FalloutNV\Converted\Data\
for /R "%FNVExtracted%meshes" %%A in (*.nif) do set /a cnt+=1
set /a cnt = cnt/483
rem set iStart to 0 for normal operation
del "%FNVConverted%Meshes\Terrain\LODList.csv"
set iStart=21
echo File count = %cnt%
FOR /L %%B IN (%iStart%,1,%cnt%) DO (
  ECHO %%B
  "C:\Program Files\Autodesk\3ds Max 2013\3dsmax.exe" -silent -mxs "batchstart = @\"%%B\";global outputdir = @\"c:\\tttobj\\export\";filein @\"C:\\Program Files\\Autodesk\\3ds Max 2013\\scripts\\autoexportnif3_noprompt.ms\""
)
rem "C:\Program Files\Autodesk\3ds Max 2013\3dsmax.exe" -mxs "global batchstart = @"%cnt%";filein @"\C:\Program Files\Autodesk\3ds Max 2013\scripts\autoexportnif3_noprompt.ms\""
rem "C:\Program Files\Autodesk\3ds Max 2013\3dsmax.exe" -mxs "batchstart = @\"%cnt%\";global outputdir = @\"c:\\tttobj\\export\";filein @\"C:\\Program Files\\Autodesk\\3ds Max 2013\\scripts\\autoexportnif3_noprompt.ms\""
pause