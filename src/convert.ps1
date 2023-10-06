$fo4Path = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Wow6432Node\Bethesda Softworks\Fallout4" -Name "installed path" -ErrorAction Stop
$fnvPath = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Wow6432Node\Bethesda Softworks\falloutnv" -Name "installed path" -ErrorAction Stop
$extractedPath = Resolve-Path -Path "${PSScriptRoot}\..\extracted" -ErrorAction Stop
$tempPath = Resolve-Path -Path "${PSScriptRoot}\..\temp" -ErrorAction Stop
$cwd = Resolve-Path -Path "${PSScriptRoot}\models-and-animations\elric\" -ErrorAction Stop
$outputPath = Resolve-Path -Path "${PSScriptRoot}\..\output" -ErrorAction Stop

Start-Process -FilePath "${fo4Path}\Tools\Elric\Elrich.exe" `
    -ArgumentList `
        "`"${cwd}\Settings\PCMeshes.esf`"", `
        "-ElricOptions.ConvertTarget=`"$tempPath`"", `
        "-ElricOptions.OutputDirectory=`"$outputPath`"" `
    -WorkingDirectory $cwd `
    -Wait `
    -ErrorAction Stop

Write-Output $fo4Path
Write-Output $fnvPath
