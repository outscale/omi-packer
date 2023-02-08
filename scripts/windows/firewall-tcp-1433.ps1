<#
.SYNOPSIS
    Outscale Script to set inbound firewall rules for MSSQL

.DESCRIPTION
    Powershell cmdlet to set inbound TCP PORT 1433 Windows firewall rule.

.NOTES
    Name of file    : firewall-tcp-1433.ps1
    Author          : Outscale
    Date            : February 8th, 2022
    Version         : 1.0
#>

#Allow default SQL Server TCP port (1433)
Write-Host "Set inbound TCP PORT 1433 Windows firewall rule" -ForegroundColor Green 
New-NetFirewallRule -DisplayName "Port 1433/TCP (MSSQL)" -Direction inbound -Profile Any -Action Allow -LocalPort 1433 -Protocol TCP