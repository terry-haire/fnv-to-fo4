set ElricLoc=E:\SteamLibrary\steamapps\common\Fallout 4\Tools\Elric\
set Input=D:\Games\Fallout New Vegas\FNVFo4 Converted\Data\
cd /d "%ElricLoc%"
"%ElricLoc%Elrich.exe" "%ElricLoc%Settings\PCMeshes.esf" -ElricOptions.ConvertTarget="%Input%Meshes\new_vegas" -ElricOptions.OutputDirectory="%Input%ElricProcessed"