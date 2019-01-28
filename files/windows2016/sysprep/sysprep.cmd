@ECHO OFF

@REM Delete all logs files
del /F /Q "C:\Windows\Outscale\logs\*"

@REM Delete tmp folder in Outscale directory
rmdir /S /Q C:\Windows\Outscale\tmp

@REM Copy file for next bootstrap script at startup
CMD /c copy C:\Windows\Outscale\scripts\SetupComplete.cmd "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp"

@REM Disable RDP before sysprep for security reasons
CMD /c REG.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 1 /f

@REM Launch sysprep with unattend file
CMD /c C:\Windows\System32\sysprep\sysprep.exe /generalize /oobe /shutdown /unattend:C:\Windows\Outscale\sysprep\sysprep.xml
