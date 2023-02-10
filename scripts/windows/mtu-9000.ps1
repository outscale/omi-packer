<#
.SYNOPSIS
    Outscale Script to configure Ethernet device MTU

.DESCRIPTION
    Powershell script which will set ethernet MTU value to 9000.
    This script will be ran from the Packer HCL file during the build process.

.NOTES
    Name of file    : mtu-9000.ps1
    Author          : Outscale
    Date            : February 10th, 2022
    Version         : 1.1
#>

try {
    # MTU
    Write-Host  "*******************************************************************************"
    Write-Host "Updating MTU Ethernet Configuration"

    # Network Interface
    Disable-NetAdapterBinding -InterfaceAlias "Ethernet" -ComponentID ms_tcpip6
    Disable-NetAdapterBinding -InterfaceAlias Ethernet -ComponentID ms_tcpip6

    $netAdapter=Get-NetAdapterAdvancedProperty -Name "Ethernet"

    # Get Windows version
    $os_version = (Get-WmiObject -class Win32_OperatingSystem).Caption
    if ($os_version.contains("2019")) {
      $mtu = $netAdapter | Where-Object {$_.DisplayName -eq "Init.MTUSize"}
      if ($mtu.DisplayValue -ne 8950) {
        Set-NetAdapterAdvancedProperty -Name "Ethernet" -DisplayName "Init.MTUSize" -DisplayValue 8950
        Write-Host "Set-NetAdapterAdvancedProperty Ethernet Init.MTUSize 8950"
      } else {
        Write-Host "NetAdapterAdvancedProperty Ethernet Init.MTUSize 8950 already set"
      }
    }

    $mtu = (Get-NetIPInterface -InterfaceAlias "Ethernet").NlMtu
    if ($mtu -ne 8950) {
      Set-NetIPInterface -InterfaceAlias "Ethernet" -NlMtuBytes 8950
      Write-Host "Set-NetIPInterface Ethernet NlMtuBytes 8950"
    } else {
      Write-Host "Set-NetIPInterface Ethernet NlMtuBytes 8950 already set"
    }

    $adapterList = Get-ChildItem -Path 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\NetworkCards\'
    $adapter = Get-ItemProperty -Path Registry::$adapterList -Name ServiceName
    $path = $adapter.ServiceName
    try {
      Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\services\Tcpip\Parameters\Interfaces\$path\" | Select-Object -ExpandProperty MTU | Out-Null
      Write-Host "Registry ItemProperty Ethernet MTU 9000 already set"
     }
     catch
     {
      New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\services\Tcpip\Parameters\Interfaces\$path\" -Name "MTU" -Value 9000 -PropertyType "DWord" | Out-Null
      Write-Host "Applied Registry New-ItemProperty Ethernet MTU 9000"
     }
}
catch [Exception] {
   Write-Host "### FAILED ### -> $_"
  }
Write-Host  "*******************************************************************************"
