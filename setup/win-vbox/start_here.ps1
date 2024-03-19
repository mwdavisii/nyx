#Requires -Version 7.2


#PS Check for Admin Rights
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if ($isAdmin) {
    write-host "This script needs admin rights to continue. Please run as administrator."
    { Exit }
}


function Install-ChocoPackage {
# Code from https://rafaelmedeiros94.medium.com/installing-tools-using-powershell-and-chocolatey-windows-60d02ff7a7b9
    [cmdletbinding()]
    param(
        [String]$PackageName
    )

    $ChocoLibPath = "C:\ProgramData\chocolatey\lib"

    if(-not(test-path $ChocoLibPath)){
        Set-ExecutionPolicy Bypass -Scope Process -Force; 
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
        iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    }
    
    #Test if the package folder exists on Choco Lib folder
    if (!((test-path "$ChocoLibPath\$PackageName"))) {

        Write-Host "[INFO]Installing $PackageName..." -ForegroundColor Yellow
        $start_time = Get-Date
        #Install the package without confirmation prompt
        choco install -y -v $PackageName 
        Write-Host "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"

    }
    else {

        Write-host  "[INFO]$PackageName is already installed." -ForegroundColor Green
    }
}


Install-ChocoPackage -PackageName virtualbox