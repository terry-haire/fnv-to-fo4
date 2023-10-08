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
Write-Host "Extracting meshes... [DONE]" -ForegroundColor Green

Write-Host "Extracting textures... " -NoNewline
Start-Process `
    -FilePath "${PSScriptRoot}\..\bin\bsab\bsab.exe" `
    -ArgumentList `
        "-e", `
        "-f", `
        "textures", `
        "`"$fnvPath\Data\Fallout - Textures.bsa`"", `
        "`"$fnvPath\Data\Fallout - Textures2.bsa`"", `
        "`"$fnvPath\Data\Update.bsa`"", `
        "`"$outputPath`"" `
    -Wait `
    -NoNewWindow `
    -ErrorAction Stop
Write-Host "Extracting textures... [DONE]" -ForegroundColor Green

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
        "`"${cwd}\Settings\PCMeshes.esf`"", `
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
