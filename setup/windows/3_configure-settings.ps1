#Requires -Version 7.2


#Lets set up 9 virtual desktops
$vDesktopLimit = 8

$initial = Get-DesktopCount
if ($initial -le $vDesktopLimit){
    Do {
        New-Desktop
        $initial++
    }
    While ($initial -le $vDesktopLimit)
}

if ($initial -ge $vDesktopLimit){
    Do {
        Remove-Desktop -Desktop ($initial -1)
        $initial--
    }
    While ($initial -ge $vDesktopLimit)
}

# just grab it all
Copy-Item -Recurse -Force ../../home/config/.config ~/

# specific items
Copy-Item ../../home/config/.config/PowerShell/Microsoft.PowerShell_profile.ps1 $env:USERPROFILE\OneDrive\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
Copy-Item ../../home/config/.config/PowerShell/Microsoft.PowerShell_profile.ps1 $env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1

Copy-Item -Recurse -Force ../../home/config/.config/alacritty/ $Env:AppData\alacritty
Copy-Item ../../home/config/.config/komorebic/komorebi.json ~/komorebi.json

# set startup items
Copy-Item ..\..\home\config\.config\autohotkey\main.ahk "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"

#install winwal
go install github.com/thefryscorer/schemer2@latest
Remove-Item -Recurse -Force $env:USERPROFILE\.source\winwal
Remove-Item -Recurse -Force $env:USERPROFILE\.source\pywal
git clone https://github.com/mwdavisii/winwal $env:USERPROFILE\.source\winwal
git clone https://github.com/mwdavisii/pywal $env:USERPROFILE\.source\pywal
pip3 install --user $env:USERPROFILE\.config\pywal

Import-Module $env:USERPROFILE\.source\winwal\winwal.psm1