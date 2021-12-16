#-- Powershell cmdlet to set inbound TCP PORT 1433 Windows firewall rule
#--


#Allow default SQL Server TCP port (1433)
Write-Host "Set inbound TCP PORT 1433 Windows firewall rule" -ForegroundColor Green 
New-NetFirewallRule -DisplayName "Port 1433/TCP (MSSQL)" -Direction inbound -Profile Any -Action Allow -LocalPort 1433 -Protocol TCP