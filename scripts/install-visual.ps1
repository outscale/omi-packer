Start-Process powershell -Verb runAs
Invoke-WebRequest -Uri https://aka.ms/vs/15/release/vc_redist.x64.exe -OutFile C:\\Windows\\Temp\\vc_redist.x64.exe
C:\\Windows\\Temp\\vc_redist.x64.exe /q /ACTION=Install /IACCEPTSQLSERVERLICENSETERMS
