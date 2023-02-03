 <#
.SYNOPSIS
    Outscale Script for installing and Fedora Project VirtIO drivers

.DESCRIPTION
    Powershell script which will download, install and VirtIO drivers.
    This script will be ran from the Packer HCL file during the build process.

.NOTES
    Name of file    : virtio.ps1
    Author          : Outscale
    Date            : February 3rd, 2022
    Version         : 1.0
#>

#VirtIO msi file URL
$MsiURL = "https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/virtio-win-0.1.229-1/virtio-win-gt-x64.msi"

#Downloaded msi file name
$MsiName = "virtio-win.msi"

#Local working directory
$WorkingDir = "C:\\Windows\\Outscale\\virtio"

#msi file location
$MsiFile = "$WorkingDir\\$MsiName"

#Test the working directory
if (!(Test-Path $WorkingDir)){
    New-Item -ItemType Directory -Force -Path $WorkingDir
}

#If MSI package not present, download it
if (!(Test-Path $MsiFile)){
    write-host "Downloading VirtIO package File..."
    Invoke-WebRequest -Uri $MsiURL -OutFile $MsiFile
    Write-Host "VirtIO File download complete" -ForegroundColor Green
}
else {
    write-host "Located the VirtIO package, moving on to install..."
}

write-host "Starting VirtIO drivers install..."

Install-Package -Name $MsiFile -force

Write-Host "VirtIO drivers installation complete..." -ForegroundColor Green

#Cleanup, Delete VirtIO files and folder
Write-Host "Cleaning up - Removing VirtIO files and folder"
Get-ChildItem -Path $WorkingDir -Recurse | Remove-Item -force -recurse
Remove-Item $WorkingDir -Force -ErrorAction SilentlyContinue

Write-Host "End of VirtIO Installation script..."