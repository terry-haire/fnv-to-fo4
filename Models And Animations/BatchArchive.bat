@echo off
setlocal enabledelayedexpansion
set Archive2Loc=C:\Program Files (x86)\Steam\steamapps\common\Fallout 4\Tools\Archive2\
set Input=C:\Users\TheHa\Desktop\FNVConvExtracted
for /D %%f in ("*") do (
	set Format=General
	set Compression=None
	echo "FalloutNV - %%f.ba2"
	if /i "%%f"=="Materials" (
		echo %%f
		set Format=General
		set Compression=Default
	)
	if /i "%%f"=="Meshes" (
		echo %%f
		set Format=General
		set Compression=Default
	)
	if /i "%%f"=="Music" (
		echo %%f
		set Format=General
		set Compression=None
	)
	if /i "%%f"=="Sound" (
		echo %%f
		set Format=General
		set Compression=None
	)
	if /i "%%f"=="Textures" (
		echo %%f
		set Format=DDS
		set Compression=Default
	)
	echo !Format!
	"%Archive2Loc%Archive2.exe" "%Input%\%%f" -create="FalloutNV - %%f.ba2" -root="%Input%" -format=!Format! -compression=!Compression! -maxSizeMB=1500 -tempFiles
)
pause
