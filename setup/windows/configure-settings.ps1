#Requires -Version 7.2

# just grab it all
Copy-Item -Recurse -Force ../../home/config/.config ~/

# specific items

Copy-Item ../../home/config/.config/PowerShell/Microsoft.PowerShell_profile.ps1 $HOME\OneDrive\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
Copy-Item ../../home/config/.config/PowerShell/Microsoft.PowerShell_profile.ps1 $HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
Copy-Item -Recurse -Force ../../home/config/.config/alacritty/ $Env:AppData\alacritty
Copy-Item ../../home/config/.config/komorebic/komorebi.json ~/komorebi.json
