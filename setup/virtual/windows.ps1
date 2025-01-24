#Requires -Version 7.2
#Requires -RunAsAdministrator

#import shared scripts
Import-Module ..\shared\common.psm1 -Force

$NixPackageVersion = "nixos-25.05"
#$sshPath = "~\.ssh"

function Build-VirtualBox {
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [string] $Name,
        [Parameter(Mandatory=$true, Position=1)]
        [string] $VMPath,
        [Parameter(Mandatory=$true, Position=2)]
        [string] $ISOFileName
    )
    #create disk
    Invoke-ShellCommand -command "VBoxManage" "createvm --name $name --ostype Linux_64 --register --basefolder `"$VMPath`""
    #create memory and network
    write-host "Defining Memory and Network Configuration."
    Invoke-ShellCommand -command "VBoxManage" "modifyvm ${Name} --ioapic on"
    Invoke-ShellCommand -command "VBoxManage" "modifyvm ${Name} --cpuhotplug on"
    Invoke-ShellCommand -command "VBoxManage" "modifyvm ${Name} --cpus 4"
    Invoke-ShellCommand -command "VBoxManage" "modifyvm ${Name} --accelerate3d on"
    Invoke-ShellCommand -command "VBoxManage" "modifyvm ${Name} --memory 4096 --vram 128"
    Invoke-ShellCommand -command "VBoxManage" "modifyvm ${Name} --nic1 nat"
    Invoke-ShellCommand -command "VBoxManage" "modifyvm ${Name} --audioout on"
    Invoke-ShellCommand -command "VBoxManage" "modifyvm ${Name} --clipboard bidirectional"
    Invoke-ShellCommand -command "VBoxManage" "setextradata ${Name} GUI/Fullscreen true"
    write-host "Creating Disks and Storage."
    Invoke-ShellCommand -command "VBoxManage" "createhd --filename `"${VMPath}\${VMName}\${VMName}_DISK.vdi`" --size 40000 --format --property Label=nixos VDI"
    Invoke-ShellCommand -command "VBoxManage" "storagectl ${Name} --name `"SATA Controller`" --add sata --controller IntelAhci"
    Invoke-ShellCommand -command "VBoxManage" "storageattach ${Name} --storagectl `"SATA Controller`" --port 0 --device 0 --type hdd --medium `"${VMPath}`"/${Name}/${Name}_DISK.vdi"
    Invoke-ShellCommand -command "VBoxManage" "storagectl ${Name} --name `"IDE Controller`" --add ide --controller PIIX4"
    Invoke-ShellCommand -command "VBoxManage" "storageattach ${Name} --storagectl `"IDE Controller`" --port 1 --device 0 --type dvddrive --medium `"${VMPath}\${ISOFileName}`""      
    Invoke-ShellCommand -command "VBoxManage" "modifyvm ${Name} --boot1 dvd --boot2 disk --boot3 none --boot4 none"
    Invoke-ShellCommand -command "VBoxManage" "modifyvm ${Name} --vrde on"
    Invoke-ShellCommand -command "VBoxManage" "modifyvm ${Name} --vrdemulticon on --vrdeport 10001"
    #write-host "Attaching SSH Folder"
    #Write-Host "VBoxManage sharedfolder add $sshPath -name .ssh -hostpath $sshPath"
    #Invoke-ShellCommand -command "VBoxManage" "sharedfolder add $sshPath -name .ssh -hostpath $sshPath"
}

#Clear-Host
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
) | ForEach-Object { New-Object System.Management.Automation.Host.ChoiceDescription $_ }

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

Install-ChocoPackage $sys

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
    ) | ForEach-Object { New-Object System.Management.Automation.Host.ChoiceDescription $_ }

$choices=[System.Management.Automation.Host.ChoiceDescription[]]($options)

$decision = $Host.UI.PromptForChoice($title, $question, $choices, 0)

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

$homePath="$env:USERPROFILE\vms".Trim()

if ($dirPath -eq ""){
    $dirPath = $homePath
}

if ($VMName -eq ""){
    $VMName = "NixOS"
}

New-Item -ItemType Directory -Force -Path $dirPath

if (!((test-path "$dirPath\$nixFlavor"))) {
    write-host "Downloading NixOS to $dirPath\$nixFlavor"
    Write-Host "https://channels.nixos.org/${NixPackageVersion}/latest-nixos-${nixFlavor} -OutFile `"$dirPath\$nixFlavor`""
    Invoke-WebRequest "https://channels.nixos.org/${NixPackageVersion}/latest-nixos-${nixFlavor}" -OutFile $dirPath\$nixFlavor
} else{
    write-host "Local copy of ${nixFlavor} found. Skipping download"
}

if ($sys = "virtualbox"){
    Build-VirtualBox -Name "$VMName" -VMPath "$dirPath" -ISOFileName "$nixFlavor"
}


write-host "Done"