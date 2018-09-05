@echo off
setlocal enabledelayedexpansion

rem If Laptop
rem set Archive2Loc=C:\Program Files (x86)\Steam\steamapps\common\Fallout 4\Tools\Archive2\
rem set Input=C:\Users\TheHa\Desktop\FNVConvExtracted

rem If Desktop
set Archive2Loc=E:\SteamLibrary\steamapps\common\Fallout 4\Tools\Archive2\
rem don't forget to remove the last "\"
set Input=D:\Games\Fallout New Vegas\FNVFo4 Converted\Data

rem set rootFolder="Input"

rem Change to input folder so that archives while be created there (does not seem to work)
cd %Input%
for /D %%f in ("%Input%\*") do (
	set bProcess=False
	set Format=General
	set Compression=None
	echo "FalloutNV - %%~nxf.ba2"
	echo %%~nxf
	if /i "%%~nxf"=="Materials" (
		echo %%~nxf
		set Format=General
		set Compression=Default
		set bProcess=True
	)
	if /i "%%~nxf"=="Meshes" (
		echo %%~nxf
		set Format=General
		set Compression=Default
		set bProcess=True
	)
	if /i "%%~nxf"=="Music" (
		echo %%~nxf
		set Format=General
		set Compression=None
		set bProcess=True
	)
	if /i "%%~nxf"=="Sound" (
		echo %%~nxf
		set Format=General
		set Compression=None
		set bProcess=True
	)
	if /i "%%~nxf"=="Textures" (
		echo %%~nxf
		set Format=DDS
		set Compression=Default
		set bProcess=True
	)
	echo !Format!
	if !bProcess!==True (
		"%Archive2Loc%Archive2.exe" "%Input%\%%~nxf" -create="FalloutNV - %%~nxf.ba2" -root="%Input%" -format=!Format! -compression=!Compression! -maxSizeMB=1500 -tempFiles
	)
)
pause
