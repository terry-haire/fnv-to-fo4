Write-Host "Get / create paths... " -NoNewline

# Get paths.
$fo4Path = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Wow6432Node\Bethesda Softworks\Fallout4" -Name "installed path" -ErrorAction Stop
$fnvPath = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Wow6432Node\Bethesda Softworks\falloutnv" -Name "installed path" -ErrorAction Stop
$elricWorkingDirectory = Resolve-Path -Path "${PSScriptRoot}\models-and-animations\elric\" -ErrorAction Stop
$nifSkopeConverterPath = "${PSScriptRoot}\..\build\nifskope_converter\release\NifSkope.exe"
$nifSkopeConverterDebugPath = "${PSScriptRoot}\..\build\nifskope_converter\debug\NifSkope.exe"

if (Test-Path $nifSkopeConverterDebugPath) {
    $nifSkopeConverterPath = $nifSkopeConverterDebugPath
}

# Create paths.
$tempPath = New-Item -Path "${PSScriptRoot}\..\temp" -ItemType Directory -Force
$extractedPath = New-Item -Path "${PSScriptRoot}\..\extracted" -ItemType Directory -Force
$outputPath = New-Item -Path "${PSScriptRoot}\..\output" -ItemType Directory -Force
$outputPathTextures = New-Item -Path "${PSScriptRoot}\..\output\textures" -ItemType Directory -Force
$elricOutputPath = New-Item -Path "$outputPath\meshes" -ItemType Directory -Force

Write-Host "[DONE]" -ForegroundColor Green

Write-Host "Extracting meshes... " -NoNewline
Start-Process `
    -FilePath "${PSScriptRoot}\..\bin\bsab\bsab.exe" `
    -ArgumentList `
        "-e", `
        "-f", `
        "meshes", `
        "`"$fnvPath\Data\Fallout - Meshes.bsa`"", `
        "`"$fnvPath\Data\Update.bsa`"", `
        "`"$extractedPath`"" `
    -Wait `
    -NoNewWindow `
    -ErrorAction Stop
Write-Host "Extracting meshes... " -NoNewline
Write-Host "[DONE]" -ForegroundColor Green

Write-Host "Extracting textures... " -NoNewline
Rename-Item -Path "$outputPathTextures\new_vegas" -NewName "textures" -ErrorAction Ignore
Start-Process `
    -FilePath "${PSScriptRoot}\..\bin\bsab\bsab.exe" `
    -ArgumentList `
        "-e", `
        "-f", `
        "textures", `
        "`"$fnvPath\Data\Fallout - Textures.bsa`"", `
        "`"$fnvPath\Data\Fallout - Textures2.bsa`"", `
        "`"$fnvPath\Data\Update.bsa`"", `
        "`"$outputPathTextures`"" `
    -Wait `
    -NoNewWindow `
    -ErrorAction Stop
takeown /f "$outputPathTextures\textures"
Rename-Item -Path "$outputPathTextures\textures" -NewName "new_vegas"
Write-Host "Extracting textures... " -NoNewline
Write-Host "[DONE]" -ForegroundColor Green

Write-Host "Converting meshes... " -NoNewline
Start-Process `
    -FilePath $nifSkopeConverterPath `
    -ArgumentList `
        "--convert", `
        "`"$tempPath`"", `
        "`"$fnvPath\Data`"", `
        "`"$extractedPath`"" `
    -Wait `
    -ErrorAction Stop
Write-Host "[DONE]" -ForegroundColor Green

Write-Host "Optimizing meshes... " -NoNewline
Start-Process `
    -FilePath "${fo4Path}\Tools\Elric\Elrich.exe" `
    -ArgumentList `
        "`".\Settings\PCMeshes.esf`"", `
        "-ElricOptions.ConvertTarget=`"$tempPath\meshes`"", `
        "-ElricOptions.OutputDirectory=`"$elricOutputPath`"" `
    -WorkingDirectory $elricWorkingDirectory `
    -Wait `
    -ErrorAction Stop
Write-Host "[DONE]" -ForegroundColor Green

Write-Host "Moving materials... " -NoNewline
Move-Item -Path "$tempPath\materials" -Destination "$outputPath\materials"
Write-Host "[DONE]" -ForegroundColor Green

Write-Host "Copying data files... " -NoNewline
Copy-Item -Path "${PSScriptRoot}\data\*" -Destination "$outputPath" -Recurse -Force
Write-Host "[DONE]" -ForegroundColor Green

Write-Host "Export FNV data... " -NoNewline
Start-Process `
    -FilePath "${PSScriptRoot}\..\build\xedit_converter\xEdit.exe" `
    -ArgumentList `
        "-FNV", `
        "-script:Extract", `
        "-plugin:FalloutNV.esm", `
        "-nobuildrefs", `
        "-autoload", `
        "-autoexit", `
        "-IKnowWhatImDoing" `
    -WorkingDirectory "${PSScriptRoot}\..\build\xedit_converter" `
    -Wait `
    -ErrorAction Stop
Write-Host "[DONE]" -ForegroundColor Green

Write-Host "Import FNV data... " -NoNewline
Start-Process `
-FilePath "${PSScriptRoot}\..\build\xedit_converter\xEdit.exe" `
    -ArgumentList `
        "-FO4", `
        "-script:Import", `
        "-plugin:Fallout4.esm", `
        "-nobuildrefs", `
        "-autoload", `
        "-autoexit", `
        "-IKnowWhatImDoing" `
    -WorkingDirectory "${PSScriptRoot}\..\build\xedit_converter" `
    -Wait `
    -ErrorAction Stop
Write-Host "[DONE]" -ForegroundColor Green

Move-Item -Path "$fo4Path\Data\FalloutNV.esm" -Destination $outputPath
