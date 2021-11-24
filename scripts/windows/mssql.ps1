 <#
.SYNOPSIS
    Outscale Script for installing and configuring Microsoft SQL Server (2019 64 Bits English)

.DESCRIPTION
    Powershell script which will download, install and configure SQL Server during first startup of an Outscale Instance
    This script will be ran from user-data section.

.NOTES
    Name of file    : mssql-install.ps1
    Author          : Outscale
    Date            : November 2021
    Version         : 1.0

    #>



#SQL Server ISO file URL (Source : Outscale)
$IsoURL = "https://oos.eu-west-2.outscale.com/omi/iso/SW_DVD9_NTRL_SQL_Svr_Standard_Edtn_2019Dec2019_64Bit_English_OEM_VL_X22-22109.ISO"

#SSMS .exe file URL (Microsoft)
$SSMSURL = "https://aka.ms/ssmsfullsetup"

#Local working directory
$WorkingDir = "C:\\Windows\\Outscale\\SQLSERVER"

#ISO file location
$SQLIsoFile = "$WorkingDir\\SQLServer.iso"

#Configuration file location
$configfile = "$WorkingDir\\ConfigurationFile.ini"

# Set file and folder path for SSMS installer .exe
$SSMSfilepath="$WorkingDir\\SSMS-Setup-ENU.exe"

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
$command =  "C:\\Windows\\Outscale\\SQLSERVER\\PsExec.exe /accepteula -s $ISOLetter" + ":\\setup.exe /ConfigurationFile=$($configfile)"
 
#Run the install command
write-host "Beginning MS SQL Server 2019 Std install..."
Invoke-Expression -Command $command
Write-Host "---- MS SQL install complete ----" -ForegroundColor Green

#Dismount the ISO File
#write-host "Dismounting the ISO file..."
Dismount-DiskImage -ImagePath $SQLIsoFile

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
Get-ChildItem -Path $WorkingDir -Recurse | Remove-Item -force -recurse
Remove-Item $WorkingDir -Force

#Allow default SQL Server TCP port (1433)
New-NetFirewallRule -DisplayName "ALLOW TCP PORT 1433" -Direction inbound -Profile Any -Action Allow -LocalPort 1433 -Protocol TCP