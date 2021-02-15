@ECHO off
color 71
echo -------------------------------------------------------------------------------
echo                Create OMI Script
echo                     Outscale
echo -------------------------------------------------------------------------------
echo (English)  This script will automatically run the sysprep for the creation of an OMI from this instance. 
echo This process disconnects the RDP access to your instance. Once the instance is stopped, you can create the OMI with API calls / Cockpit Portal.
echo.
echo (Francais) Ce script permet de lancer automatiquement le sysprep pour la creation d'une OMI depuis cette instance. 
echo Ce processus coupera l'acces RDP a votre instance. Des que l'instance sera stoppee, vous pourrez creer l'OMI avec un call API / Portail Cockpit.
echo.
set /p input=Do you want to continue? / Voulez-vous continuer? (y/n) : 
if %input% EQU y (
	echo The process will begin in 20 seconds / Le processus commencera dans 20 secondes
	ping 1.1.1.1 -n 1 -w 20000 >nul
	CMD /c C:\Windows\Outscale\sysprep\sysprep.cmd
	)