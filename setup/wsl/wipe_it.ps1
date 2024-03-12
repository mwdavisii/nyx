$title = "WSL2 NixOS Configuration Options"  
$question = '
This script will wipe your NixOS WSL2 installation. Select No to cancel. 
Select Yes to continue.
Select No to cancel.'

$choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
$choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'))
$choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No'))
$decision = $Host.UI.PromptForChoice($title, $question, $choices, 1)
if ($decision -eq 1) {
    exit
}
wsl --shutdown
wsl --unregister NixOS
Remove-Item ~/NixOS
Remove-Item ~/nixos-wsl.tar.gz

