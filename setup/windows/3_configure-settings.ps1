#Requires -Version 7.2

# just grab it all
Copy-Item -Recurse -Force ../../home/config/.config ~/

# specific items
Copy-Item ../../home/config/.config/PowerShell/Microsoft.PowerShell_profile.ps1 $env:USERPROFILE\OneDrive\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
Copy-Item ../../home/config/.config/PowerShell/Microsoft.PowerShell_profile.ps1 $env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1

Copy-Item -Recurse -Force ../../home/config/.config/alacritty/ $Env:AppData\alacritty
Copy-Item ../../home/config/.config/komorebic/komorebi.json ~/komorebi.json

#install winwal
go install github.com/thefryscorer/schemer2@latest
Remove-Item -Recurse -Force $env:USERPROFILE\.config\winwal
Remove-Item -Recurse -Force $env:USERPROFILE\.config\pywal
git clone https://github.com/mwdavisii/winwal $env:USERPROFILE\.config\winwal
git clone https://github.com/mwdavisii/pywal $env:USERPROFILE\.config\pywal
pip3 install --user $env:USERPROFILE\.config\pywal
Import-Module $env:USERPROFILE\.config\winwal\winwal.psm1