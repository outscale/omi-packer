@ECHO OFF

@REM Change policy to execute script
powershell set-executionpolicy unrestricted -f

@REM Launch bootstrap script to configure VM
powershell c:\windows\Outscale\scripts\start.ps1