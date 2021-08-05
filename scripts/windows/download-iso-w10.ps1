$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

Invoke-WebRequest -Uri "https://oos.eu-west-2.outscale.com/omi/iso/en_windows_10_enterprise_ltsc_2019_x64_dvd_5795bb03.iso" -OutFile "C:\windows.iso"