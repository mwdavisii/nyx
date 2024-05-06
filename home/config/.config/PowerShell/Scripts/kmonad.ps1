## This is a login script that will launch kmonad and the tiling manager.

Install-Module VirtualDesktop -Force

## create virtual desktop windows
$vDesktopLimit = 9

$initial = Get-DesktopCount
if ($initial -le 9){
    Do {
        Write-Output "Creating Desktop " + $initial
        New-Desktop
        $initial++
    }
    While ($initial -le $vDesktopLimit)
}
Start-Process -WindowStyle hidden kmonad "$env:USERPROFILE\.config\kmonad\windows\g915-tkl.kbd"