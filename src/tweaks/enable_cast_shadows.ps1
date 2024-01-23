# List of root paths
$rootPaths = @(
    "C:\Program Files (x86)\Steam\steamapps\common\Fallout 4\Data\materials\new_vegas\ammo",
    "C:\Program Files (x86)\Steam\steamapps\common\Fallout 4\Data\materials\new_vegas\architecture",
    "C:\Program Files (x86)\Steam\steamapps\common\Fallout 4\Data\materials\new_vegas\clutter",
    "C:\Program Files (x86)\Steam\steamapps\common\Fallout 4\Data\materials\new_vegas\furniture",
    "C:\Program Files (x86)\Steam\steamapps\common\Fallout 4\Data\materials\new_vegas\landscape",
    "C:\Program Files (x86)\Steam\steamapps\common\Fallout 4\Data\materials\new_vegas\scol",
    "C:\Program Files (x86)\Steam\steamapps\common\Fallout 4\Data\materials\new_vegas\trees",
    "C:\Program Files (x86)\Steam\steamapps\common\Fallout 4\Data\materials\new_vegas\vehicles"
)

$extension = "*.BGSM"
$fieldName = "bCastShadows"
$newValue = $true

foreach ($rootPath in $rootPaths) {
    Get-ChildItem -Path $rootPath -Recurse -File -Filter $extension | ForEach-Object {
        Write-Host "Processing file: $_.FullName"

        # Read the file content and convert from JSON
        $jsonContent = Get-Content $_.FullName | ConvertFrom-Json

        # Modify the field
        if ($jsonContent.PSObject.Properties.Name -contains $fieldName) {
            $jsonContent.$fieldName = $newValue

            # Convert the object back to JSON and overwrite the file
            $jsonContent | ConvertTo-Json | Set-Content $_.FullName
        }
    }
}
