@echo off
echo "/h for hard link"
set fullpath=scripts
set displayname="C:\Program Files\Autodesk\3ds Max 2013\%fullpath%"
set fullpath="%~dp0%fullpath%"
echo %fullpath%
rem set displayname=%displayname%
rem echo %displayname%
mklink /j %displayname% %fullpath%
Pause