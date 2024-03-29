#Requires -Version 7.2
#Requires -RunAsAdministrator

$powerlineFontsUrl = 'https://github.com/powerline/fonts.git'

Import-Module ..\shared\common.psm1



#Check for latest wsl version
write-host "Installing PSGitHub. This is required to determine the latest version of NixOS-WSL"
Install-Module -Name PSGitHub
$release = Get-GitHubRelease -Owner nix-community -Repository NixOS-WSL
$version = $release.tag_name.Split(" ")[0]
Write-Host "The latest release for NixOS-WSL is v$version"
$nixOSWSLdownloadUrl = "https://github.com/nix-community/NixOS-WSL/releases/download/$version/nixos-wsl.tar.gz"


write-host "Updating WSL to the latest version."
wsl --update

set-location ~
#this assumes you have already enabled WSL.
$title = "WSL2 NixOS Configuration Options"  
$question = '
This script requires that git is installed and wsl is enabled.
Select Yes to continue.
Select No to cancel.'

$choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
$choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'))
$choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No'))
$decision = $Host.UI.PromptForChoice($title, $question, $choices, 1)
if ($decision -eq 1) {
    exit
}

$question = '
    This script will install Powerline Fonts to enhance starship and temrinal display icons. 
    Select Yes to install. 
    Select No if they are already installed.
'
$choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
$choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'))
$choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No'))
$decision = $Host.UI.PromptForChoice($title, $question, $choices, 1)
if ($decision -eq 0) {
    write-host "Now the script will install Powerline Fonts."
    git clone $powerlineFontsUrl
    set-location fonts
    ./install.ps1
}

write-host "Downloading NixOS."
set-location ~
Invoke-WebRequest $nixOSWSLdownloadUrl -OutFile nixos-wsl.tar.gz

write-host "Installing NixOS"
New-item NixOS -Type Directory
wsl --import NixOS .\NixOS\ .\nixos-wsl.tar.gz --version 2


$question = 'Set NixOS as default?'
$choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
$choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'))
$choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No'))
$decision = $Host.UI.PromptForChoice($title, $question, $choices, 0)
if ($decision -eq 0) {
    wsl --setdefault NixOS
} 

$question = '
The installation is complete. If you have any issues, please ensure systemd is enabled. => https://devblogs.microsoft.com/commandline/systemd-support-is-now-available-in-wsl/
Select "Yes" to launch the nix terminal and continue the installation.
'
$choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
$choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'))
$choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No'))
$decision = $Host.UI.PromptForChoice($title, $question, $choices, 0)
if ($decision -eq 0) {
    wsl -d NixOS
} 