@echo off
cls
setlocal EnableDelayedExpansion
set "cmd=findstr /R /N "^^" *.csv | find /C ":""

for /f %%a in ('!cmd!') do set number=%%a
echo %number%
PAUSE