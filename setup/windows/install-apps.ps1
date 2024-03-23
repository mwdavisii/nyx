#Requires -Version 7.2
#Requires -RunAsAdministrator

#import shared scripts
Import-Module ..\shared\common.psm1

Install-ChocoPackage git
Install-ChocoPackage sublimetext4
Install-ChocoPackage win32yank
Install-ChocoPackage vscode
Install-ChocoPackage discord
Install-ChocoPackage docker-desktop
Install-ChocoPackage winrar


