#Requires -Version 7.2

#import shared scripts
Import-Module ..\shared\common.ps1

$NixPackageVersion = "nixos-23.11"
$NixURL = "https://channels.nixos.org/${NixPackageVersion}latest-nixos-"

$sshPath = "~\.ssh"
$nixFlavor = "gnome-x86_64-linux.iso"

Check-Admin-Rights()


function Build-VirtualBox {
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Name,
        [Parameter(Mandatory=$true, Position=1)]
        [string]$VMPath,
        [Parameter(Mandatory=$true, Position=2)]
        [string]$ISOFileName
    )

    #create disk
    VBoxManage createvm --name $name --ostype "Linux_64" --register --basefolder `$dirPath`
    #create memory and network
    write-host "Defining Memory and Network Configuration."
    Execute-Shell-Command -command "VBoxManage modifyvm ${Name} --ioapic on"
    Execute-Shell-Command -command "VBoxManage modifyvm ${Name} --memory 2048 --vram 128"
    Execute-Shell-Command -command "VBoxManage modifyvm ${Name} --nic1 nat"
    write-host "Creating Disks and Storage."
    Execute-Shell-Command -command "VBoxManage createhd --filename "${VMPath}"/${VMName}/${VMName}_DISK.vdi --size 40000 --format VDI"
    Execute-Shell-Command -command "VBoxManage storagectl ${Name} --name "SATA Controller" --add sata --controller IntelAhci"
    Execute-Shell-Command -command "VBoxManage storageattach ${Name} --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium  "${VMPath}"/${Name}/${Name}_DISK.vdi"
    Execute-Shell-Command -command "VBoxManage storagectl ${Name} --name "IDE Controller" --add ide --controller PIIX4"
    Execute-Shell-Command -command "VBoxManage storageattach ${Name} --storagectl "IDE Controller" --port 1 --device 0 --type dvddrive --medium "${VMPath}"/${ISOFileName}"       
    Execute-Shell-Command -command "VBoxManage modifyvm ${Name} --boot1 dvd --boot2 disk --boot3 none --boot4 none"
    Execute-Shell-Command -command "VBoxManage modifyvm ${Name} --vrde on"
    Execute-Shell-Command -command "VBoxManage modifyvm ${Name} --vrdemulticon on --vrdeport 10001"
    write-host "Launching VM."
    EExecute-Shell-Command -command "VBoxHeadless --startvm ${Name} "
    write-host "Attaching SSH Folder"
    Execute-Shell-Command -command "VBoxManage sharedfolder add $sshPath -name ".ssh" -hostpath $sshPath"
}

Clear-Host
###
### Prompt for VM Platform
$title = "Virtual Machine Options"  
$question = '
    This script supports two 3rd party virtualization options.
    - VMWare Workstation Player (default)
    - Oracle Virtual Box
    '

$options=@(
    ("&1 vmware","1"),
    ("&2 oraclevbox","2"),
    #("&hyperv","hyperv"),
    ("&Quit","Quit")
) | % { New-Object System.Management.Automation.Host.ChoiceDescription $_ }

$choices=[System.Management.Automation.Host.ChoiceDescription[]]($options)

$decision = $Host.UI.PromptForChoice($title, $question, $choices, 1)

switch ($decision)
{
    0 {
        $sys = "vmware-workstation-player"
        break
      };
    1 { 
        $sys = "virtualbox"
        break
        };
    2 {
        exit
    }
}

Install-ChocoPackage -PackageName $sys

#Prompt for Version
$title = "NixOS Versions"  
$question = '
    Which version of NixOS do you want? 
    '

$options=@(
    ("&1. gnome_x86_64", "gnome_x86_64"),
    ("&2. gnome_aarch64"),
    ("&3. kde_x86_64"),
    ("&4. kde_aarch64"),
    ("&5. minimal_x86_64"),
    ("&6. minimal_aarch64"),
    ("&Quit")
    ) | % { New-Object System.Management.Automation.Host.ChoiceDescription $_ }

$choices=[System.Management.Automation.Host.ChoiceDescription[]]($options)

$decision = $Host.UI.PromptForChoice($title, $question, $choices, 1)

switch ($decision)
{
    0 {
        $nixFlavor = "gnome-x86_64-linux.iso"
        break
      };
    1 { 
        $nixFlavor = "gnome-aarch64-linux.iso"
        break
        };
    2 {
        $nixFlavor = "plasma5-x86_64-linux.iso"
        break
      };
    3 {
        $nixFlavor = "plasma5-aarch64-linux.iso"
        break
      };
    4 {
        $nixFlavor = "minimal-x86_64-linux.iso"
        break
      };
    5 {
        $nixFlavor = "minimal-aarch64-linux.iso"
        break
      };
    6 {
        exit
      };
}


$dirPath = Read-Host "Please enter the storage location for your VM files (default = $env:USERPROFILE\vms ) "

$VMName = Read-Host "Please enter a unique name for your VM (default = NixOS) "

if ($dirPath -eq ""){
    $dirPath = "$env:USERPROFILE\vms"
}

if ($VMName -eq ""){
    $VMName = "NixOS"
}

Write-Host "VMName = $VMName"

if (!((test-path "${$dirPath}\${nixFlavor}"))) {
    write-host "Downloading NixOS."
    #write-host "https://channels.nixos.org/${NixPackageVersion}/latest-nixos-${nixFlavor}"
    Invoke-WebRequest "https://channels.nixos.org/${NixPackageVersion}/latest-nixos-${nixFlavor}" -OutFile "${$dirPath}\${nixFlavor}"
} else{
    write-host "Local copy of ${nixFlavor}.iso found. Skipping download"
}

Build-VirtualBox -Name "$VMName" -VMPath "$dirPath" -ISOFileName "$nixFlavor"