Invoke-Expression (&starship init powershell)
Import-Module $env:USERPROFILE\.config\winwal\winwal.psm1


function Set-RandomWallpaper {
    if (-not (Get-Module winwal)) {
        Import-Module $env:USERPROFILE\.config\winwal\winwal.psm1
    }
    $env:Path += ';$env:APPDATA\Python\Python312\Scripts;$env:APPDATA\python\python312\site-packages'
    $wallpaperDir = Get-ChildItem $env:USERPROFILE\.config\wallpapers
    $randomIndex = Get-Random -Maximum $wallpaperDir.Count
    # Get the file at the random index
    $image = $wallpaperDir[$randomIndex]
    Set-AllDesktopWallpapers -Path $image
    # Set Colors with pywal
    Update-WalTheme
}

function Set-DefaultWallpaper {
    if (-not (Get-Module winwal)) {
        Import-Module $env:USERPROFILE\.config\winwal\winwal.psm1
    }
    $env:Path += ';$env:APPDATA\Python\Python312\Scripts;$env:APPDATA\python\python312\site-packages'
    $wallpaperDir = Get-ChildItem $env:USERPROFILE\.config\wallpapers
    $randomIndex = 1
    # Get the file at the random index
    $image = $wallpaperDir[$randomIndex]
    Set-AllDesktopWallpapers -Path $image
    # Set Colors with pywal
    Update-WalTheme
}

function Enable-Tiling{
    komorebic start
}

function Disable-Tiling{
    komorebic stop
}