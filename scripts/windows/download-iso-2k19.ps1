$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

Invoke-WebRequest -Uri "https://oos.eu-west-2.outscale.com/omi/iso/SW_DVD9_Win_Server_STD_CORE_2019_1809.17_64Bit_English_DC_STD_MLF_X22-69933.ISO" -OutFile "C:\windows.iso"