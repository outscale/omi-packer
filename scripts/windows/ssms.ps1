 <#
.SYNOPSIS
    Outscale Script for installing Microsoft SQL Server Management Studio,

.DESCRIPTION
    Powershell script which will download and install Microsoft SQL Server Management Studio (SSMS)
    This script will be ran from the Packer HCL file during the build process.

.NOTES
    Name of file    : ssms-install.ps1
    Author          : Outscale
    Date            : November 2021
    Version         : 1.0

    #>



#SSMS .exe file URL (Microsoft)
$SSMSURL = "https://aka.ms/ssmsfullsetup"

#Local working directory
$WorkingDir = "C:\\Windows\\Outscale\\SQLSERVER"

# Set file and folder path for SSMS installer .exe
$SSMSfilepath="$WorkingDir\\SSMS-Setup-ENU.exe"

#Test the working directory
if (!(Test-Path $WorkingDir)){
    New-Item -ItemType Directory -Force -Path $WorkingDir
}

#If SSMS install package not present, download it
if (!(Test-Path $SSMSfilepath)){
    write-host "Downloading SQL Server SSMS..."
    Invoke-WebRequest -Uri $SSMSURL -OutFile $SSMSfilepath
    Write-Host "SSMS installer download complete" -ForegroundColor Green
}
else {
    write-host "Located the SQL SSMS Installer binaries, moving on to install..."
}
 
#Start the SSMS installer
write-host "Beginning SSMS 18.10 install..."
$Parms = " /Install /Quiet /Norestart /Logs log.txt"
$Prms = $Parms.Split(" ")
& "$SSMSfilepath" $Prms | Out-Null
Write-Host "---- SSMS install complete ----" -ForegroundColor Green

Start-Sleep -s 30

#Delete uploaded SQLSERVER folder
Write-Host "Removing SQLSERVER folder"
Get-ChildItem -Path $WorkingDir -Recurse | Remove-Item -force -recurse
Remove-Item $WorkingDir -Force