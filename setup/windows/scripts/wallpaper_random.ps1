Import-Module $env:USERPROFILE\.config\winwal\winwal.psm1
$env:Path += ';$env:APPDATA\Python\Python312\Scripts;$env:APPDATA\python\python312\site-packages'
$files = Get-ChildItem $env:USERPROFILE\.config\wallpapers
$randomIndex = Get-Random -Maximum $files.Count
# Get the file at the random index
$image = $files[$randomIndex]
Set-AllDesktopWallpapers -Path $image
# Set Colors with pywal
Update-WalTheme