 <#
.SYNOPSIS
    Outscale Script for installing and configuring Microsoft SQL Server (Standard Edition 2019 64 Bits English)

.DESCRIPTION
    Powershell script which will download, install and configure SQL Server.
    This script will be ran from the Packer HCL file during the build process.

.NOTES
    Name of file    : mssql-install.ps1
    Author          : Outscale
    Date            : November 2021
    Version         : 1.5

    #>



#SQL Server ISO file URL
$IsoURL = $Env:ISO_URL

#Downloaded ISO file name
$IsoName = "MSSqlSrv2019En.iso"

#Local working directory
$WorkingDir = "C:\\Windows\\Outscale\\sql"

#ISO file location
$SQLIsoFile = "$WorkingDir\\$IsoName"

#Configuration file location
$configfile = "$WorkingDir\\ConfigurationFile.ini"

#Test the working directory
if (!(Test-Path $WorkingDir)){
    New-Item -ItemType Directory -Force -Path $WorkingDir
}

#If ISO file not present, download it
if (!(Test-Path $SQLIsoFile)){
    write-host "Downloading MS SQL ISO File..."
    Invoke-WebRequest -Uri $IsoURL -OutFile $SQLIsoFile
    Write-Host "MS SQL ISO File download complete" -ForegroundColor Green
}
else {
    write-host "Located the MS SQL ISO File, moving on to install..."
}

#Mount the SQL ISO file
#write-host "Mounting the ISO file..."
$MountISO = Mount-DiskImage -ImagePath $SQLIsoFile -StorageType ISO -PassThru

#Retrieve the ISO drive letter
$ISOLetter = ($MountISO | Get-Volume).DriveLetter

#MS SQL Install command
$command =  "C:\\Windows\\Outscale\\sql\\PsExec.exe /accepteula -s $ISOLetter" + ":\\setup.exe /ConfigurationFile=$($configfile)"
 
#Run the install command
write-host "Beginning MS SQL Server 2019 install..."
Invoke-Expression -Command $command
Write-Host "---- MS SQL install complete ----" -ForegroundColor Green

#Dismount the ISO File
#write-host "Dismounting the ISO file..."
Dismount-DiskImage -ImagePath $SQLIsoFile