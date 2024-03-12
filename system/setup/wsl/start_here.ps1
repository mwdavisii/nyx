$nixOSWSLdownloadUrl = 'https://github.com/nix-community/NixOS-WSL/releases/download/2311.5.3/nixos-wsl.tar.gz'
$powerlineFontsUrl = 'https://github.com/powerline/fonts.git'

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