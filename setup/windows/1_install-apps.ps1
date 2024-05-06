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

# Winwal
Install-ChocoPackage imagemagick
Install-ChocoPackage go


#python
Remove-Item $env:LOCALAPPDATA\Microsoft\WindowsApps\python.exe
Remove-Item $env:LOCALAPPDATA\Microsoft\WindowsApps\python3.exe

winget install -e -i --id=Python.Python.3.12 --source=winget --scope=machine

$keyPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment"  # System path registry key
$oldValue = Get-ItemProperty -Path $keyPath -Name "Path"
$newPath = "$env:APPDATA\Python\Python312\Scripts"
if ($oldValue.Path -notcontains $newPath) {
  # Append new path with semicolon separator
  $newValue = $oldValue.Path + ";" + $newPath
  Set-ItemProperty -Path $keyPath -Name "Path" -Value $newValue -Type ExpandString
}

# Shell
winget install starship

# komorebi & wkhd
winget install LGUG2Z.komorebi

# Install PS Modules
Install-Module VirtualDesktop

# K8s Tooling
Install-ChocoPackage kubernetes-cli
Install-ChocoPackage flux-cd