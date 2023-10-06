@echo off
rem fuzer may work with ogg
rem Voice
set ffmpegloc=%UserProfile%\OneDrive\Portable Programs\ffmpeg\bin
set fo4loc=E:\SteamLibrary\steamapps\common\Fallout 4
for /R "sound\voice\" %%f in ("*.ogg") do (
"%ffmpegloc%\ffmpeg.exe" -loglevel warning -hide_banner -y -i "%%~f" "%%~pf%%~nf.wav"
"%fo4loc%\Tools\Audio\xwmaencode.exe" "%%~pf%%~nf.wav" "%%~pf%%~nf.xwm"
rem "%fo4loc%\Tools\LipGen\LipFuzer\LIPFuzer.exe" -"%%~pf%%~nf.xwm" "%%~pf%%~nf.fuz"
del "%%~pf%%~nf.ogg"
del "%%~pf%%~nf.wav"
rem del "%%~pf%%~nf.xwm"
rem del "%%~pf%%~nf.lip"
)
"%fo4loc%\Tools\LipGen\LipFuzer\LIPFuzer.exe" -s "%cd%\sound\voice" -d "%cd%\sound\voice" -v 0
for /R "sound\voice\" %%f in ("*.lip") do (
del "%%~pf%%~nf.lip"
)
for /R "sound\voice\" %%f in ("*.xwm") do (
del "%%~pf%%~nf.xwm"
)
rem "%fo4loc%\Tools\LipGen\LipFuzer\LIPFuzer.exe" "%%~pf%%~nf.xwm" "%%~pf%%~nf.fuz"

rem Music And Songs
for /R "sound\songs\" %%f in ("*.ogg") do (
"%ffmpegloc%\ffmpeg.exe" -loglevel warning -hide_banner -y -i "%%~f" "%%~pf%%~nf.wav"
"%fo4loc%\Tools\Audio\xwmaencode.exe" "%%~pf%%~nf.wav" "%%~pf%%~nf.xwm"
del "%%~pf%%~nf.ogg"
del "%%~pf%%~nf.wav"
)
for /R "sound\songs\" %%f in ("*.mp3") do (
IF EXIST "%%~pf%%~nf.wav" (
"%fo4loc%\Tools\Audio\xwmaencode.exe" "%%~pf%%~nf.wav" "%%~pf%%~nf.xwm"
del "%%~pf%%~nf.mp3"
) ELSE (
"%ffmpegloc%\ffmpeg.exe" -loglevel warning -hide_banner -y -i "%%~f" "%%~pf%%~nf.wav"
"%fo4loc%\Tools\Audio\xwmaencode.exe" "%%~pf%%~nf.wav" "%%~pf%%~nf.xwm"
del "%%~pf%%~nf.mp3"
del "%%~pf%%~nf.wav"
)
)
for /R "Music\" %%f in ("*.mp3") do (
"%ffmpegloc%\ffmpeg.exe" -loglevel warning -hide_banner -y -i "%%~f" "%%~pf%%~nf.wav"
"%fo4loc%\Tools\Audio\xwmaencode.exe" "%%~pf%%~nf.wav" "%%~pf%%~nf.xwm"
del "%%~pf%%~nf.mp3"
del "%%~pf%%~nf.wav"
)
rem fx
for /R "sound\fx\" %%f in ("*.ogg") do (
"%ffmpegloc%\ffmpeg.exe" -loglevel warning -hide_banner -y -i "%%~f" "%%~pf%%~nf.wav"
del "%%~pf%%~nf.ogg"
)
pause