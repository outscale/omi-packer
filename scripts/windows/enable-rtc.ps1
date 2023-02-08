<#
.SYNOPSIS
    Outscale Script to enable TimeZoneInformation registry

.DESCRIPTION
    Powershell cmdlet to enable RealTimeIsUniversal for NTP fallback.

.NOTES
    Name of file    : enable-rtc.ps1
    Author          : Outscale
    Date            : February 8th, 2022
    Version         : 1.0
#>

CMD /c REG.exe add "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\TimeZoneInformation" /v RealTimeIsUniversal /t REG_DWORD /d 1 /f
