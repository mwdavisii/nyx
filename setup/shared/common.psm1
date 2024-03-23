#Requires -RunAsAdministrator

function Invoke-ShellCommand {
    param(    
        [Parameter(Mandatory=$true)]
        [string] $command,
        [Parameter(Mandatory=$false)]
        [string[]] $Args
    )
    
    $path = (get-command $command).Path
    
    Write-Host "Start-Process -FilePath '"$path"' $args -Wait"
    $process = Start-Process -FilePath `"$path`" -ArgumentList $Args -PassThru -Wait
    
    if ($process.ExitCode -ne 0) {
        Write-Error "Command '$command' failed with exit code $process.ExitCode."
        exit $process.ExitCode
    }
}
Export-ModuleMember -Function Invoke-ShellCommand

function Install-ChocoPackage () {
# Code from https://rafaelmedeiros94.medium.com/installing-tools-using-powershell-and-chocolatey-windows-60d02ff7a7b9
    [cmdletbinding()]
    param(
        [String]$PackageName
    )

    $ChocoLibPath = "C:\ProgramData\chocolatey\lib"

    if(-not(test-path $ChocoLibPath)){
        Set-ExecutionPolicy Bypass -Scope Process -Force; 
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    }
    
    #Test if the package folder exists on Choco Lib folder
    if (!((test-path "$ChocoLibPath\$PackageName"))) {

        Write-Host "[INFO]Installing $PackageName..." -ForegroundColor Yellow
        $start_time = Get-Date
        #Install the package without confirmation prompt
        Invoke-ShellCommand "choco" "install -y -v $PackageName"
        Write-Host "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"

    }
    else {

        Write-host  "[INFO]$PackageName is already installed." -ForegroundColor Green
    }
}


Export-ModuleMember -Function Install-ChocoPackage 