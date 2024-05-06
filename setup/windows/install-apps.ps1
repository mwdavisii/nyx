#Requires -Version 7.2
#Requires -RunAsAdministrator

#import shared scripts
Import-Module ..\shared\common.psm1

# enable long paths
Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' -Name 'LongPathsEnabled' -Value 1

Install-ChocoPackage git
Install-ChocoPackage sublimetext4
Install-ChocoPackage win32yank
Install-ChocoPackage vscode
Install-ChocoPackage discord
Install-ChocoPackage docker-desktop
Install-ChocoPackage winrar
Install-ChocoPackage nerdfont-hack
Install-ChocoPackage alacritty
# K8s Tooling
Install-ChocoPackage kubernetes-cli
Install-ChocoPackage flux-cd
# Shell
winget install starship

# komorebi & wkhd
winget install LGUG2Z.komorebi
winget install LGUG2Z.whkd

# Install PS Modules
Install-Module VirtualDesktop
