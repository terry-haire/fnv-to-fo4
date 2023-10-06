set ElricLoc=C:\Program Files (x86)\Steam\steamapps\common\Fallout 4\Tools\Elric\
set Input=C:\Users\TheHa\projects\fallout-related\converter_output\
cd /d "%ElricLoc%"
"%ElricLoc%Elrich.exe" "%ElricLoc%Settings\PCMeshes.esf" -ElricOptions.ConvertTarget="%Input%Meshes\new_vegas" -ElricOptions.OutputDirectory="%Input%ElricProcessed"