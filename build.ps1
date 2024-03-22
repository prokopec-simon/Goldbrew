# Remove cache file
Remove-Item "amalg.cache" -ErrorAction SilentlyContinue 

# Execute Lua scripts
lua -lamalg goldbrew.lua
lua amalg.lua -o "$(Join-Path $PWD 'release\goldbrew.lua')" -s goldbrew.lua -c

# Define paths
$releaseFolderPath = Join-Path $PWD "release"
$releaseGoldbrewPath = Join-Path $releaseFolderPath "goldbrew.lua"

# Read content from files
$prodContent = Get-Content "goldbrew_prod.lua" -Raw
$stubContent = Get-Content "require_stub.lua" -Raw

# Update goldbrew.lua content and copy to WoW addon folder
$goldbrewContent = ((Get-Content $releaseGoldbrewPath -Raw) -replace '-- prod', $prodContent) -replace '(?s)-- dev_start.*?-- dev_end', ""
$finalContent = $stubContent + $goldbrewContent
Set-Content $releaseGoldbrewPath -Value $finalContent
Copy-Item -Path "$releaseFolderPath\*" -Destination "C:\Program Files (x86)\World of Warcraft\_classic_era_\Interface\AddOns\Goldbrew\" -Recurse -Force
