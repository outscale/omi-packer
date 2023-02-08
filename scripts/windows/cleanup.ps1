<#
.SYNOPSIS
    Outscale Script to cleanup logs and files used pre-build

.DESCRIPTION
    Powershell cmdlet to cleanup logs and files used pre-build.

.NOTES
    Name of file    : cleanup.ps1
    Author          : Outscale
    Date            : February 8th, 2022
    Version         : 1.0
#>

Write-Host "Running cleanup script"
if (Test-Path "C:\Windows\Outscale\") {
  Write-Host "Removing Windows Outscale folder"
  Remove-Item "C:\Windows\Outscale\*" -Verbose -Recurse -Force -ErrorAction SilentlyContinue
}

if (Test-Path "C:\\Users\\Administrator\\AppData\\Roaming\\Microsoft\\Windows\\Start Menu\\Programs\\Startup\\SetupComplete.cmd") {
  Write-Host "Removing Admin SetupComplete.cmd"
  Remove-Item -Recurse -Force "C:\\Users\\Administrator\\AppData\\Roaming\\Microsoft\\Windows\\Start Menu\\Programs\\Startup\\SetupComplete.cmd"
}

if (Test-Path "C:\\Users\\Default\\AppData\\Roaming\\Microsoft\\Windows\\Start Menu\\Programs\\Startup\\SetupComplete.cmd") {
  Write-Host "Removing Default User SetupComplete.cmd"
  Remove-Item -Recurse -Force "C:\\Users\\Default\\AppData\\Roaming\\Microsoft\\Windows\\Start Menu\\Programs\\Startup\\SetupComplete.cmd"
}
Write-Host "Exit cleanup script"
