# Remove the cache file silently
Remove-Item amalg.cache -ErrorAction SilentlyContinue 

# Execute Lua scripts
lua -lamalg goldbrew.lua
lua amalg.lua -o release/goldbrew.lua -s goldbrew.lua -c

# Read content from goldbrew_prod.lua
$prodContent = Get-Content goldbrew_prod.lua -Raw

# Read content from release/goldbrew.lua and perform replacement
$releaseGoldbrewPath = "release/goldbrew.lua"
$releaseGoldbrewContent = Get-Content $releaseGoldbrewPath -Raw
$replacedContent = $releaseGoldbrewContent -replace '-- prod', $prodContent

# Update content in release/goldbrew.lua
Set-Content $releaseGoldbrewPath -Value $replacedContent


# Read the content of the file
$content = Get-Content $releaseGoldbrewPath -Raw

# Define the regex pattern for finding the dev code block
$pattern = '(?s)-- dev_start.*?-- dev_end'

# Remove the dev code block using regex
$newContent = $content -replace $pattern, ""

# Write the modified content back to the file
Set-Content $releaseGoldbrewPath -Value $newContent