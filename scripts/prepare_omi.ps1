<#
  .SYNOPSIS
      Outscale Script for update, clean and sysprep an Windows OMI
  .DESCRIPTION
      Powershell script which will replace scripts, update/patch, clean and sysprep
  .NOTES
      Name of file    : PrepareOMI.ps1
      Author          : Outscale
      Date            : December 2016
      Version         : 1.2
      #>

Param([string]$updatescript)

      #Adds the date/timestamp to WriteLog for logging
      function WriteLogToConsole {
       param([string]$data)

       $date = $([DateTime]::Now.ToString("G"))
       Write-Host "$date : $data"
       #Out-File -InputObject "$date : $data" -FilePath $pathLogFile -Append

       $port= new-Object System.IO.Ports.SerialPort COM1,115200,None,8,one
       $port.open()
       $port.WriteLine($date + " : " + $data)
       $port.Close()
     }

     #Determines the Status of Windows Updates that are being installed
     function Get-WIAStatusValue($value)
     {
       switch -exact ($value)
       {
        0   {"NotStarted"}
        1   {"InProgress"}
        2   {"Succeeded"}
        3   {"SucceededWithErrors"}
        4   {"Failed"}
        5   {"Aborted"}
      }
    }

    function New-SWRandomPassword
    {
      [CmdletBinding(DefaultParameterSetName='FixedLength',ConfirmImpact='None')]
      [OutputType([String])]
      Param
      (
        # Specifies minimum password length
        [Parameter(Mandatory=$false,
         ParameterSetName='RandomLength')]
        [ValidateScript({$_ -gt 0})]
        [Alias('Min')]
        [int]$MinPasswordLength = 8,

        # Specifies maximum password length
        [Parameter(Mandatory=$false,
         ParameterSetName='RandomLength')]
        [ValidateScript({
          if($_ -ge $MinPasswordLength){$true}
          else{Throw 'Max value cannot be lesser than min value.'}})]
        [Alias('Max')]
        [int]$MaxPasswordLength = 12,

        # Specifies a fixed password length
        [Parameter(Mandatory=$false,
         ParameterSetName='FixedLength')]
        [ValidateRange(1,2147483647)]
        [int]$PasswordLength = 8,

        # Specifies an array of strings containing charactergroups from which the password will be generated.
        # At least one char from each group (string) will be used.
        [String[]]$InputStrings = @('abcdefghijkmnpqrstuvwxyz', 'ABCEFGHJKLMNPQRSTUVWXYZ', '123456789'),

        # Specifies a string containing a character group from which the first character in the password will be generated.
        # Useful for systems which requires first char in password to be alphabetic.
        [String] $FirstChar,

        # Specifies number of passwords to generate.
        [ValidateRange(1,2147483647)]
        [int]$Count = 1
        )
Begin {
  Function Get-Seed{
    # Generate a seed for randomization
    $RandomBytes = New-Object -TypeName 'System.Byte[]' 4
    $Random = New-Object -TypeName 'System.Security.Cryptography.RNGCryptoServiceProvider'
    $Random.GetBytes($RandomBytes)
    [BitConverter]::ToUInt32($RandomBytes, 0)
  }
}
Process {
  For($iteration = 1;$iteration -le $Count; $iteration++){
    $Password = @{}
    # Create char arrays containing groups of possible chars
    [char[][]]$CharGroups = $InputStrings

    # Create char array containing all chars
    $AllChars = $CharGroups | ForEach-Object {[Char[]]$_}

    # Set password length
    if($PSCmdlet.ParameterSetName -eq 'RandomLength')
    {
      if($MinPasswordLength -eq $MaxPasswordLength) {
        # If password length is set, use set length
        $PasswordLength = $MinPasswordLength
      }
      else {
        # Otherwise randomize password length
        $PasswordLength = ((Get-Seed) % ($MaxPasswordLength + 1 - $MinPasswordLength)) + $MinPasswordLength
      }
    }

    # If FirstChar is defined, randomize first char in password from that string.
    if($PSBoundParameters.ContainsKey('FirstChar')){
      $Password.Add(0,$FirstChar[((Get-Seed) % $FirstChar.Length)])
    }
    # Randomize one char from each group
    Foreach($Group in $CharGroups) {
      if($Password.Count -lt $PasswordLength) {
        $Index = Get-Seed
        While ($Password.ContainsKey($Index)){
          $Index = Get-Seed
        }
        $Password.Add($Index,$Group[((Get-Seed) % $Group.Count)])
      }
    }

    # Fill out with chars from $AllChars
    for($i=$Password.Count;$i -lt $PasswordLength;$i++) {
      $Index = Get-Seed
      While ($Password.ContainsKey($Index)){
        $Index = Get-Seed
      }
      $Password.Add($Index,$AllChars[((Get-Seed) % $AllChars.Count)])
    }
    Write-Output -InputObject $(-join ($Password.GetEnumerator() | Sort-Object -Property Name | Select-Object -ExpandProperty Value))
  }
}
}

# Search, Download and Install Microsoft Windows Update
function updateInstance
{
  $UpdateSession = New-Object -ComObject Microsoft.Update.Session
  $UpdateSearcher = $UpdateSession.CreateUpdateSearcher()

  WriteLogToConsole " - Searching for Updates"
  $SearchResult = $UpdateSearcher.Search("IsHidden=0 and IsInstalled=0")

  if ($SearchResult.Updates.count -eq 0)
  {
    WriteLogToConsole " - No updates found"

    # Deactivate AutoLogon
    $RegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
    Set-ItemProperty $RegPath "AutoAdminLogon" -Value "0" -type String
    Remove-ItemProperty $RegPath "DefaultPassword" -ErrorAction SilentlyContinue

    # Delete script from startup boot
    Remove-Item -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\*" -Force -Recurse -Confirm:$false -ErrorAction SilentlyContinue
  }
  else {
    WriteLogToConsole " - Found [$($SearchResult.Updates.count)] Updates to Download and Install"
    $i=0    #Initializes counter -- used to track number of update
    foreach($Update in $SearchResult.Updates)
    {
     $i++ #Increments counter
     # Add Update to Collection
     $UpdatesCollection = New-Object -ComObject Microsoft.Update.UpdateColl
     if ( $Update.EulaAccepted -eq 0 ) { $Update.AcceptEula() }
     $UpdatesCollection.Add($Update) | out-null

     # Download
     WriteLogToConsole " - Downloading [$i of $($SearchResult.Updates.count)] $($Update.Title)"
     $UpdatesDownloader = $UpdateSession.CreateUpdateDownloader()
     $UpdatesDownloader.Updates = $UpdatesCollection
     $DownloadResult = $UpdatesDownloader.Download()
     $Message = "   - Download {0}" -f (Get-WIAStatusValue $DownloadResult.ResultCode)
     WriteLogToConsole $message

     # Install
     WriteLogToConsole "   - Installing Update"
     $UpdatesInstaller = $UpdateSession.CreateUpdateInstaller()
     $UpdatesInstaller.Updates = $UpdatesCollection
     $InstallResult = $UpdatesInstaller.Install()
     $Message = "   - Install {0}" -f (Get-WIAStatusValue $DownloadResult.ResultCode)
     WriteLogToConsole $message
   }
   # Reboot and Continue Script

   try {
    $tempPassword = New-SWRandomPassword
    ([adsi]"WinNT://$env:COMPUTERNAME/Administrator").SetPassword($tempPassword)
    $RegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
    Set-ItemProperty $RegPath "AutoAdminLogon" -Value "1" -type String
    Set-ItemProperty $RegPath "DefaultUserName" -Value "Administrator" -type String
    Set-ItemProperty $RegPath "DefaultPassword" -Value $tempPassword -type String
    Set-ItemProperty $RegPath "DefaultDomainName" -Value $env:COMPUTERNAME -type String
    Set-ItemProperty $RegPath "AutoLogonCount" -Value 1

    # Copy the batch file to reexecute script after reboot
    Copy-Item "C:\Windows\Outscale\tmp\PrepareOMI.cmd" "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\"

  }
  catch [Exception]{
    WriteLogToConsole "ERROR -> $_"
  }
  WriteLogToConsole "### REBOOT - SCRIPT WILL RESUME ###"
  Restart-Computer -Force
  Start-Sleep -s 10
}
}

# Cleanup
function cleanUpInstance
{
  #Cleanup Profile Usage Information
  WriteLogToConsole " - Cleanup Profile Usage Information"
  Remove-Item -Path "C:\Users\Administrator\AppData\Roaming\Microsoft\Windows\Recent\*" -Force -Recurse -Confirm:$false -ErrorAction SilentlyContinue
  Remove-Item -Path "C:\Users\Administrator\AppData\Local\Temp\*" -Force -Recurse -Confirm:$false -ErrorAction SilentlyContinue
  Remove-Item -path "C:\Windows\System32\sysprep\Panther\setupact.log" -Force -Recurse -Confirm:$false -ErrorAction SilentlyContinue
  Remove-Item -path "C:\Windows\System32\sysprep\Panther\setuperr.log" -Force -Recurse -Confirm:$false -ErrorAction SilentlyContinue
  Remove-Item -Path "C:\Windows\System32\sysprep\Panther\IE\setupact.log" -Force -Recurse -Confirm:$false -ErrorAction SilentlyContinue
  remove-item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\UserAssist\*" -Force -Recurse -Confirm:$false -ErrorAction SilentlyContinue
  Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\TypedPaths" -Name * -Confirm:$false -ErrorAction SilentlyContinue
  remove-item -Path "C:\Documents and Settings\Administrator\Recent\*" -Force -Recurse -Confirm:$false -ErrorAction SilentlyContinue
  remove-item -Path "C:\Documents and Settings\Administrator\Local Settings\Temp\*" -Force -Recurse -Confirm:$false -ErrorAction SilentlyContinue
  remove-item -Path "C:\Users\Administrator\AppData\Roaming\Microsoft\Windows\Recent\*" -Force -Recurse -Confirm:$false -ErrorAction SilentlyContinue
  Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Applets\Regedit\" -Name "LastKey" -ErrorAction SilentlyContinue
  Remove-Item -Path "C:\Users\Administrator\AppData\Local\microsoft_corporation\powershell_ise.exe_StrongName_lw2v2vm3wmtzzpebq33gybmeoxukb04w\3.0.0.0\user.config" -Force -Confirm:$false -ErrorAction SilentlyContinue

  #Clears Start Menu Run History
  WriteLogToConsole " - Cleanup Start Menu Run History"
  foreach ($item in (Get-ChildItem -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\UserAssist)){Clear-Item -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\UserAssist\$($item.PSChildName)\Count}

  #Clears Explorer Run History
  WriteLogToConsole " - Cleanup Explorer Run History"
  Clear-Item -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU  -Force -Confirm:$false -ErrorAction SilentlyContinue

  #Clear IE history
  WriteLogToConsole " - Cleanup IE History"
  RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 255
  RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 1
  RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 2
  RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 8
  RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 16
  RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 32

  Start-Sleep -s 10

  #Removes Temporary Files
  WriteLogToConsole " - Delete Temporary Files"
  remove-item -Path "C:\Windows\Temp\*" -Force -Recurse -Confirm:$false -ErrorAction SilentlyContinue

  #Removes old EC2Config Log
  WriteLogToConsole " - Delete Logs Files"
  remove-item -Path "C:\Windows\Outscale\logs\*" -Force -Confirm:$false -ErrorAction SilentlyContinue

  #Removes any UserData Scripts
  WriteLogToConsole " - Delete UserData Scripts"
  Remove-Item -Path "C:\Windows\Outscale\userdata\*" -Force -Recurse -Confirm:$false -ErrorAction SilentlyContinue

  #Removes Temporary Outscale Files
  WriteLogToConsole " - Delete Outscale Temp Files"
  Remove-Item -Path "C:\Windows\Outscale\tmp\*" -Force -Recurse -Confirm:$false -ErrorAction SilentlyContinue

  #Clear event logs
  WriteLogToConsole " - Cleanup EventLog"
  Clear-EventLog Application
  Clear-EventLog System
  Clear-EventLog Security

}

# Sysprep Phase
function sysprep() {
  #Checks licensed status prior to running Sysprep
  foreach ($item in (gwmi SoftwareLicensingProduct)) {
    if ($item.LicenseStatus -eq 1) {
      WriteLogToConsole " - Windows is Licensed"
      WriteLogToConsole " - Running Sysprep"
      Start-Process "C:\Windows\Outscale\sysprep\sysprep.cmd"
      WriteLogToConsole " - Instance will stop, then create OMI with CLI/Cockpit"
      break
    }
    else {
      WriteLogToConsole " * Windows is NOT Licensed, unable to run Sysprep"
      WriteLogToConsole "### SYSPREP ABORTED ###"
      WriteLogToConsole ""
      break
    }
  }
}

function isServerUp() {
  Param([string]$url)
  $request = Invoke-WebRequest $url
  if ($request.StatusCode -eq "200") { return $true }
  else { return $false }
}

function downloadFile() {
  Param([string]$url,[string]$pathToSave)

  try {
    Invoke-WebRequest -Uri $url -OutFile $pathToSave | Out-Null
    "Downloading file OK"
    return $true
  }
  catch [Exception]{
   WriteLogToConsole "Error while downloading the file -> $_"
   return $false
 }
}

function getFileNameToDownload() {
  Param([string]$filter,[string]$urlBucket)

  $contentBucket = (Invoke-WebRequest -Uri $urlBucket).Content
  #Write-Host $contentBucket

  $regex = [regex] '(?<=<Key>)(.+?)(?=</Key>)'
  $matchdetails = $regex.Match($contentBucket)

  while ($matchdetails.Success) {
    if ($matchdetails.Value -like $filter) {
      $fileToDownload = $matchdetails.Value
      return $fileToDownload
    }
    $matchdetails = $matchdetails.NextMatch()
  }
}

function extractFiles() {
  Param([string]$fromPath,[string]$toPath)
  #Extract files
  Add-Type -AssemblyName 'System.IO.Compression.Filesystem'
  [System.IO.Compression.ZipFile]::ExtractToDirectory($fromPath, $toPath)
}

function updateVersion () {
  $rootPath = "C:\Windows\Outscale\"

  $pathToSave = "C:\Windows\Outscale\tmp\"
  if (!(Test-Path $pathToSave)) { New-Item $pathToSave -Type Directory | Out-Null }

  $osuEndpoint = "http://osu.eu-west-2.outscale.com"
  $bucketName = "windows-scripts"
  $urlBucket = $osuEndpoint + "/" + $bucketName

  if (isServerUp($osuEndpoint)) {
   WriteLogToConsole ' - Server OSU Up and Running'
   WriteLogToConsole ' - Looking for scripts archive in bucket'

   $fileToDownload = getFileNameToDownload "bootstrap-winsv-*" $urlBucket
   $urlFileToDownload = $urlBucket + '/' + $fileToDownload

   $pathFile = $pathToSave+$fileToDownload

   if ($fileToDownload -ne $null) {
    try {
     WriteLogToConsole " - File found - $fileToDownload"
     WriteLogToConsole " - Trying to download file..."
     if (!(Test-Path $pathFile)) {
       if (downloadFile $urlFileToDownload $pathFile) {

         WriteLogToConsole " - Extracting files in tmp directory..."
         extractFiles $pathFile $pathToSave

         $pathExtractedFolder = (Get-ChildItem $pathToSave -Directory).FullName
         $tmp = Get-ChildItem $pathExtractedFolder -Recurse -Directory

         WriteLogToConsole " - Removing all previous scripts and files..."
         dir $rootPath | ?{ $_.fullname -notmatch "\\tmp\\?" } | ?{ $_.fullname -notmatch "\\logs\\?"} | Remove-Item -Recurse -Force

         WriteLogToConsole " - Copying new bootstrap scripts..."
         Copy-Item $tmp.FullName $rootPath -Recurse -Exclude "logs"
         dir $rootPath -Filter "*.gitignore" -Recurse | Remove-Item
         WriteLogToConsole " - Cleaning files..."
       }
       else {
         WriteLogToConsole " - Download failed"
         WriteLogToConsole " - Local scripts will be launched..."
       }
     }
     else { WriteLogToConsole " - Files already downloaded...Exiting !" break}
   }
   catch [Exception] {
     WriteLogToConsole "ERROR -> $_"
   }
 }
 else {
   WriteLogToConsole " - No files have been found with the specified filter...Exiting!"
 }
}
else {
 WriteLogToConsole " - Server OSU is Down -> $_"
 WriteLogToConsole " - Local scripts have not been updated"
}
}

####################################################################
# Start of Script
####################################################################
if ($updatescript -eq 1) {
    WriteLogToConsole "### DOWNLOAD AND REPLACE SCRIPTS FROM BUCKET ###"
  try {
    updateVersion
  }
  catch [Exception]{
    WriteLogToConsole "ERROR -> $_"
  }
  WriteLogToConsole "### END OF SCRIPT ###"

  WriteLogToConsole ""
  WriteLogToConsole ""
}

######################################################################

WriteLogToConsole "### STARTING OF UPDATE WINDOWS / CLEANING / SYSPREP ###"
WriteLogToConsole ""

WriteLogToConsole "### SEARCHING FOR UPDATES ###"
try {
  updateInstance
}
catch [Exception]{
  WriteLogToConsole "ERROR -> $_"
}
WriteLogToConsole "### UPDATES DONE ###"
WriteLogToConsole ""

WriteLogToConsole "### CLEANING INSTANCE ###"
try {
  cleanUpInstance
}
catch [Exception]{
  WriteLogToConsole "ERROR -> $_"
}
WriteLogToConsole "### CLEANING DONE ###"
WriteLogToConsole ""

WriteLogToConsole "### PREPARING FOR SYSPREP ###"
try {
  sysprep
}
catch [Exception]{
  WriteLogToConsole "ERROR -> $_"
}
WriteLogToConsole "### END OF SCRIPT ###"

Remove-Item (Get-PSReadlineOption).HistorySavePath -Force

####################################################################
# End of Script
####################################################################
