Start-Process powershell -Verb runAs
Invoke-WebRequest -Uri https://go.microsoft.com/fwlink/?linkid=853015 -OutFile C:\\Windows\\Temp\\SQLServer2017-SSEI-Eval.exe
C:\\Windows\\Temp\\SQLServer2017-SSEI-Eval.exe /q /ACTION=Install /IACCEPTSQLSERVERLICENSETERMS
