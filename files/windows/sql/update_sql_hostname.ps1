$DBHostName = (Invoke-sqlcmd -query "select @@SERVERNAME" | ConvertTo-Csv -NoTypeInformation | select -Skip 1).Trim('"')
$HostName = [System.Net.DNS]::GetHostByName('').HostName.Trim()
Invoke-Sqlcmd -Query "EXEC sp_dropserver '$DBHostName';"
Invoke-Sqlcmd -Query "EXEC sp_addserver '$HostName','local';"
net stop MSSQLSERVER
net start MSSQLSERVER
