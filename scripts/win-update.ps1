Install-PackageProvider -Name NuGet -Force
Install-Module PSWindowsUpdate -Force
Get-WindowsUpdate
Start-Process powershell -Verb runAs "Install-WindowsUpdate -AcceptAll -AutoReboot"
