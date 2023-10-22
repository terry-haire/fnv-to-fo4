param(
    [string]$game
)

Write-Host "Get / create paths... " -NoNewline

# Initialize an ArrayList
$argumentListMeshes = New-Object 'System.Collections.ArrayList'
$argumentListTextures = New-Object 'System.Collections.ArrayList'

# Add static items
[void]$argumentListMeshes.Add("-e")
[void]$argumentListMeshes.Add("-f")
[void]$argumentListMeshes.Add("meshes")

[void]$argumentListTextures.Add("-e")
[void]$argumentListTextures.Add("-f")
[void]$argumentListTextures.Add("textures")

# Get paths.
$fo4Path = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Wow6432Node\Bethesda Softworks\Fallout4" -Name "installed path" -ErrorAction Stop

# FO3.
if ($game -eq "fo3") {
    $gamePath = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Wow6432Node\Bethesda Softworks\fallout3" -Name "installed path" -ErrorAction Stop
    $xEditMode = "-FO3"
    $xEditPlugin = "Fallout3.esm"

    [void]$argumentListMeshes.Add("`"$gamePath\Data\Fallout - Meshes.bsa`"")

    [void]$argumentListTextures.Add("`"$gamePath\Data\Fallout - Textures.bsa`"")
# FNV.
} else {
    $gamePath = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Wow6432Node\Bethesda Softworks\falloutnv" -Name "installed path" -ErrorAction Stop
    $xEditMode = "-FNV"
    $xEditPlugin = "FalloutNV.esm"

    [void]$argumentListMeshes.Add("`"$gamePath\Data\Fallout - Meshes.bsa`"")
    [void]$argumentListMeshes.Add("`"$gamePath\Data\Update.bsa`"")

    [void]$argumentListTextures.Add("`"$gamePath\Data\Fallout - Textures.bsa`"")
    [void]$argumentListTextures.Add("`"$gamePath\Data\Fallout - Textures2.bsa`"")
    [void]$argumentListTextures.Add("`"$gamePath\Data\Update.bsa`"")
}

$elricWorkingDirectory = Resolve-Path -Path "${PSScriptRoot}\models-and-animations\elric\" -ErrorAction Stop
$nifSkopeConverterPath = "${PSScriptRoot}\..\build\nifskope_converter\release\NifSkope.exe"
$nifSkopeConverterDebugPath = "${PSScriptRoot}\..\build\nifskope_converter\debug\NifSkope.exe"

# if (Test-Path $nifSkopeConverterDebugPath) {
#     $nifSkopeConverterPath = $nifSkopeConverterDebugPath
# }

# Create paths.
$tempPath = New-Item -Path "${PSScriptRoot}\..\temp" -ItemType Directory -Force
$extractedPath = New-Item -Path "${PSScriptRoot}\..\extracted" -ItemType Directory -Force
$outputPath = New-Item -Path "${PSScriptRoot}\..\output" -ItemType Directory -Force
$outputPathTextures = New-Item -Path "${PSScriptRoot}\..\output\textures" -ItemType Directory -Force
$elricOutputPath = New-Item -Path "$outputPath\meshes" -ItemType Directory -Force

[void]$argumentListMeshes.Add("`"$extractedPath`"")
[void]$argumentListTextures.Add("`"$outputPathTextures`"")

Write-Host "[DONE]" -ForegroundColor Green

Write-Host "Extracting meshes... " -NoNewline
Start-Process `
    -FilePath "${PSScriptRoot}\..\bin\bsab\bsab.exe" `
    -ArgumentList $argumentListMeshes `
    -Wait `
    -NoNewWindow `
    -ErrorAction Stop
Write-Host "Extracting meshes... " -NoNewline
Write-Host "[DONE]" -ForegroundColor Green

Write-Host "Extracting textures... " -NoNewline
Rename-Item -Path "$outputPathTextures\new_vegas" -NewName "textures" -ErrorAction Ignore
Start-Process `
    -FilePath "${PSScriptRoot}\..\bin\bsab\bsab.exe" `
    -ArgumentList $argumentListTextures `
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
        "`"$extractedPath`"", `
        "`"$extractedPath`"" `
    -Wait `
    -ErrorAction Stop
Write-Host "[DONE]" -ForegroundColor Green

# Remove meshes which crash elric.
if ($game -eq "fo3") {
    $files = @(
        "meshes\new_vegas\architecture\megaton\megatonrampstraightreg.nif",
        "meshes\new_vegas\architecture\megaton\megatonrampstraightreg02.nif",
        "meshes\new_vegas\architecture\megaton\megatonrampstraightsml.nif",
        "meshes\new_vegas\architecture\megaton\megatonrampturn180reg.nif",
        "meshes\new_vegas\architecture\urban\streetdressing\busshelter01.nif",
        "meshes\new_vegas\architecture\urban\streetdressing\busshelter02.nif",
        "meshes\new_vegas\armor\eulogyjones\hateulogyjonesgo.nif",
        "meshes\new_vegas\armor\headgear\antagonizer\helmetantagonizergo.nif",
        "meshes\new_vegas\armor\headgear\chinesecommando\hatchinesecommandogo.nif",
        "meshes\new_vegas\armor\headgear\clownmask\m\clownmaskgo.nif",
        "meshes\new_vegas\armor\headgear\enclaveofficer\hatenclaveofficergo.nif",
        "meshes\new_vegas\armor\headgear\eyebothelmet\m\eyebothelmetgo.nif",
        "meshes\new_vegas\armor\headgear\hat1950slady\hat1950sladygo.nif",
        "meshes\new_vegas\armor\headgear\helmetraider02\helmetraider02go.nif",
        "meshes\new_vegas\armor\headgear\hat1950scap\hat1950sadultcapgo.nif",
        "meshes\new_vegas\armor\headgear\hockeymask\m\hockeymaskgo.nif",
        "meshes\new_vegas\armor\headgear\hoodoasisdruid\hoodoaisisdruidgo.nif",
        "meshes\new_vegas\armor\headgear\mechanist\helmetmechanistgo.nif",
        "meshes\new_vegas\armor\headgear\metalarmor\helmetmetalarmorfgo.nif",
        "meshes\new_vegas\armor\headgear\metalarmor\helmetmetalarmormgo.nif",
        "meshes\new_vegas\armor\headgear\partyhat\m\partyhatgo.nif",
        "meshes\new_vegas\armor\headgear\wastelandchild05\hatbaseballcapadultgo.nif",
        "meshes\new_vegas\armor\headgear\wastelandclothing01\helmetwastelandclothing01go.nif",
        "meshes\new_vegas\armor\headgear\wastelandclothing02\hatwastelandclothing02fgo.nif",
        "meshes\new_vegas\armor\headgear\wastelandclothing03\m\goggleswastelandclothing03go.nif",
        "meshes\new_vegas\armor\headgear\wastelandclothing04\f\goggleswastelandclothing04fgo.nif",
        "meshes\new_vegas\armor\headgear\wastelandclothing04\m\goggleswastelandclothing04mgo.nif",
        "meshes\new_vegas\armor\headgear\wastelandmerchant\hatwastelandmerchantgo.nif",
        "meshes\new_vegas\characters\hair\glassesblackrimmedgo.nif",
        "meshes\new_vegas\characters\hair\glassesdrligo.nif",
        "meshes\new_vegas\characters\hair\glassestortoiseshellgo.nif",
        "meshes\new_vegas\characters\hair\powderedwiggo.nif",
        "meshes\new_vegas\clutter\operatinglight01.nif",
        "meshes\new_vegas\clutter\babycarriage\babycarriageclean01.nif",
        "meshes\new_vegas\clutter\babycarriage\babycarriagedirty01.nif",
        "meshes\new_vegas\clutter\billiards\triangle.nif",
        "meshes\new_vegas\clutter\food\apple01.nif",
        "meshes\new_vegas\clutter\questitems\mq04tranquilitypod01.nif",
        "meshes\new_vegas\dungeons\metro\exterior\metrotunneltransdoorload01.nif",
        "meshes\new_vegas\dungeons\vault\halls\vdoor01.nif",
        "meshes\new_vegas\dungeons\vault\room\vrmoverseerdesk01.nif",
        "meshes\new_vegas\dungeons\vaultruined\clutter\operatinglightr01.nif",
        "meshes\new_vegas\dungeons\vaultruined\doors\vdoorr01.nif",
        "meshes\new_vegas\dungeons\vaultruined\room\vrmoverseerdeskr01.nif",
        "meshes\new_vegas\vehicles\truck01.nif",
        "meshes\new_vegas\vehicles\truck02.nif",
        "meshes\new_vegas\vehicles\truck03.nif",
        "meshes\new_vegas\vehicles\truck04.nif",
        "meshes\new_vegas\vehicles\truck05.nif",
        "meshes\new_vegas\vehicles\truck06.nif",
        "meshes\new_vegas\weapons\1handminedrop\minefrag.nif"
    )

    foreach ($file in $files) {
        if (Test-Path -Path "$tempPath\$file") {
            Remove-Item -Path "$tempPath\$file"
        }
    }
}

Write-Host "Optimizing meshes... " -NoNewline

for ($i=0; $i -lt 100; $i++) {
    Start-Process `
        -FilePath "${fo4Path}\Tools\Elric\Elrich.exe" `
        -ArgumentList `
            "`".\Settings\PCMeshes.esf`"", `
            "-ElricOptions.ConvertTarget=`"$tempPath\meshes`"", `
            "-ElricOptions.OutputDirectory=`"$elricOutputPath`"" `
        -WorkingDirectory $elricWorkingDirectory `
        -Wait `
        -ErrorAction Stop

    $sourceFiles = Get-ChildItem -Path "$tempPath\meshes" -Recurse -File
    $failed = $false

    $existingFiles = @()

    # Loop through each file and check if it exists in the destination directory
    foreach ($file in $sourceFiles) {
        $relativePath = $file.FullName.Substring("$tempPath\meshes".Length)
        $destPath = Join-Path -Path "$outputPath\meshes" -ChildPath $relativePath

        if (-not (Test-Path -Path $destPath -PathType Leaf)) {
            if (-not $failed) {
                Write-Host "[FAILED]" -ForegroundColor Red
            }

            Write-Host "meshes$relativePath" -ForegroundColor Red

            Remove-Item -Path $file

            $failed = $true

            Break
        }

        $existingFiles += $file
    }

    foreach ($file in $existingFiles) {
        Remove-Item -Path $file.FullName
    }

    if (-not $failed) {
        break
    }
}

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
        $xEditMode, `
        "-script:Extract", `
        "-plugin:$xEditPlugin", `
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

$file = "$outputPath\FalloutNV.esm"
$fileInfo = Get-Item $file

if ($fileInfo.Length -lt 10MB) {
    Write-Host "FalloutNV.esm is not the right size. Please check the Fallout 4 Data folder for another esm file and rename it to FalloutNV.esm" -ForegroundColor Red
} else {
    Write-Host "All steps completed"
}
