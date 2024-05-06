## This is a login script that will launch kmonad and the tiling manager.

Install-Module VirtualDesktop -Force

## create virtual desktop windows
$vDesktopLimit = 9

$initial = Get-DesktopCount
Do {
    Write-Output "Creating Desktop " + $initial
    New-Desktop
    $initial++
}
While ($initial -le $vDesktopLimit)

Start-Process AutoHotKey C:\Users\mwdav\.config\autohotkey\main.ahk
Start-Process -WindowStyle hidden kmonad $HOME\.config\kmonad\windows\g915-tkl.kbd
komorebic start