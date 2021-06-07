<#
.SYNOPSIS
    Outscale Script for configuring a Windows VM at first boot
.DESCRIPTION
    Powershell script which will configure and apply differents settings at Windows Boot VM
.NOTES
    Name of file    : start.ps1
    Author          : Outscale
    Date            : December 2016
    Version         : 1.3
    #>

    <# Functions #>
    # Return a string from an URL paramater
    Function ReadInfoURL()
    {
      Param([string]$data)
      $wc = new-object System.Net.WebClient
      $webpage = $wc.DownloadString($data)
      return $webpage
    }

    # Allows us to write directly on the VM console ouput
    Function SerialWrite()
    {
      Param([string]$data)
      $time = Get-Date
      $port= new-Object System.IO.Ports.SerialPort COM1,115200,None,8,one
      $port.open()
      $port.WriteLine($time.ToString() + " : " + $data)
      $port.Close()
    }

    # Set password
    Function InitPasswd()
    {
      Param([string]$url,[string]$user)
      $pwd = ReadInfoURL $url
      $account = [ADSI]("WinNT://./$user,user")
      $account.SetPassword($pwd)
    }

    # Return an object with the configuration of the ini file
    Function IniParser()
    {
      Param([string]$data)
      $ini = @{}
      switch -regex -file $data
      {
        "^\[(.+)\]$"
        {
          $section = $matches[1]
          $ini[$section] = @{}
        }
        "(.+)=(.+)"
        {
          $name,$value = $matches[1..2]
          $ini[$section][$name] = $value
        }
      }

      return $ini
    }

    # Remove everything in folder startup to avoid script execution more than once, and lock the session
    Function cleanLogoff() {
      remove-item -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\*" -Force -Recurse -Confirm:$false -ErrorAction SilentlyContinue
      shutdown /l /f
    }

    # Return current zone
    Function Zone()
    {
      Param ([string]$data)
      $z=ReadInfoURL $data
      return $z.split('.')[1]
    }

    # Returns all the information necessary to the console output at the end of the script execution
    Function ConsoleOutput()
    {
      Param([string]$Option)

      $amiID = ReadInfoURL $($config['URL']['UrlMetadata'] + $config['URL']['UrlAmiID'])
      $instanceID = ReadInfoURL $($config['URL']['UrlMetadata'] + $config['URL']['UrlInstanceID'])

      SerialWrite("==============================================")
      SerialWrite("OS : Microsoft Windows NT " + (Get-WmiObject -class Win32_OperatingSystem).Version)
      SerialWrite("OsVersion : " + (Get-WmiObject -class Win32_OperatingSystem).Version)
      SerialWrite("OsProductName : " + (Get-WmiObject -class Win32_OperatingSystem).Caption)
      SerialWrite("Language : " + (Get-WmiObject -class Win32_OperatingSystem).MUILanguages)
      SerialWrite("AMI-ID : "+ $amiID)
      SerialWrite("Instance-ID : " + $instanceID)
      SerialWrite("Username : Administrator")
      switch ($Option)
      {
        0
        {
          $windowsEncryptedPassword = ReadInfoURL $($config['URL']['UrlMetadata'] + $config['URL']['UrlWindowsEncrypted'])
          SerialWrite("Password : " + $windowsEncryptedPassword)
        }
        1
        {
          SerialWrite("Password : Defined by user script")
        }
      }
      SerialWrite("Message : Windows is ready to use")
    }

    # Write formatted logs
    function WriteLog
    {
     param([string]$data)

     $date = $([DateTime]::Now.ToString("G"))
     Write-Host "$date : $data"
     Out-File -InputObject "$date : $data" -FilePath $pathLogFile -Append
   }

   # Return Windows License Status
   function Get-ActivationStatus
   {
    [CmdletBinding()]
    param(
      [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
      [string]$DNSHostName = $Env:COMPUTERNAME
      )
    process {
      try {
        $wpa = Get-WmiObject SoftwareLicensingProduct -ComputerName $DNSHostName `
        -Filter "ApplicationID = '55c92734-d682-4d71-983e-d6ec3f16059f'" `
        -Property LicenseStatus -ErrorAction Stop
        } catch {
          $status = New-Object ComponentModel.Win32Exception ($_.Exception.ErrorCode)
          $wpa = $null
        }
        $out = New-Object psobject -Property @{
          ComputerName = $DNSHostName;
          Status = [string]::Empty;
        }
        if ($wpa) {
          :outer foreach($item in $wpa) {
            switch ($item.LicenseStatus) {
              0 {$out.Status = "Unlicensed"}
              1 {$out.Status = "Licensed"; break outer}
              2 {$out.Status = "Out-Of-Box Grace Period"; break outer}
              3 {$out.Status = "Out-Of-Tolerance Grace Period"; break outer}
              4 {$out.Status = "Non-Genuine Grace Period"; break outer}
              5 {$out.Status = "Notification"; break outer}
              6 {$out.Status = "Extended Grace"; break outer}
              default {$out.Status = "Unknown value"}
            }
          }
          } else {$out.Status = $status.Message}
          $out
        }
      }


####### START OF SCRIPT #######

# Log file configuration
$logPath = "C:\Windows\Outscale\logs\"

if (!(Test-Path $logPath)) { New-Item $logPath -Type Directory | Out-Null }

$logName = "$(Get-Date -Format "MMddyyyy_hhmmss") - $(gc env:computername).log"
$pathLogFile = $logPath + $logName

WriteLog "*******************************************************************************"
WriteLog "               Windows VM - First Boot Configuration                           "
WriteLog "*******************************************************************************"

<# Datas #>
# Load config from ini file
try {
  WriteLog "### START OF SCRIPT ###"
  WriteLog "Loading Configuration INI File"
  $config=IniParser 'C:\Windows\Outscale\conf\config.ini'
  WriteLog "INI File successfully loaded"

  # Cloud Zone
  WriteLog "URL Meta-Data = $($config['URL']['UrlMetadata'])"
  $UrlZone=$config['URL']['UrlMetadata']+$config['URL']['UrlZone']
  $Zone=Zone $UrlZone
  WriteLog "Zone = $Zone"

  # KMS
  WriteLog "Loading KMS Configuration"

  $Win32_OperatingSystem = Get-WmiObject -class Win32_OperatingSystem
  if ($Win32_OperatingSystem.Caption.Contains('Server'))
  {
    $key = $config['KMS']['server-'+ $Win32_OperatingSystem.Version.split(".")[0] + '-' + $Win32_OperatingSystem.Version.split(".")[1]]
    WriteLog "Server Edition Detected - Getting KMS Client Key"
    WriteLog "KMS Client Key = $key"
  }
  else
  {
    $key=$config['KMS']['workstation-'+ $Win32_OperatingSystem.Version.split(".")[0] + '-' + $Win32_OperatingSystem.Version.split(".")[1]]
    WriteLog "Workstation Edition Detected - Getting KMS Client Key"
    WriteLog "KMS Client Key = $key"
  }
  $KmsServer="169.254.169.254:1688"
  WriteLog "KMS Server = $KmsServer"

  # UserData
  $UrlUserData=$config['URL']['UrlUserdata']
  WriteLog "URL User-Data = $UrlUserdata"

  $PsFile=$config['UserScript']['PsFile']
  WriteLog "Path to Powershell User Script = $PsFile"

  $VbsFile=$config['UserScript']['VbsFile']
  WriteLog "Path to VisualBasic User Script = $VbsFile"

  # Set Password
  $UrlWindowsPassword=$config['URL']['UrlMetadata']+$config['URL']['UrlWindowsPasswordNoLog']
  WriteLog "URL Password = $UrlWindowsPassword"
  $WindowsUser=$config['Other']['user']

  # NTP
  $ntp='"' + "ntp1.$Zone.compute.internal ntp2.$Zone.compute.internal" + '"'
  WriteLog "NTP Servers = $ntp"
}

catch [Exception]{
  WriteLog "### FAILED ### -> $_"
  WriteLog "*******************************************************************************"
}

<#
Processing
#>
# Registry
WriteLog "*******************************************************************************"
WriteLog "Applying Registry Configuration"
try {
  Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Applets\Regedit\" -Name "LastKey" -ErrorAction SilentlyContinue
  try
  {
    Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" | Select-Object -ExpandProperty SoftwareSASGeneration -ErrorAction Stop | Out-Null
  }
  catch
  {
    New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "SoftwareSASGeneration" -PropertyType DWord -Value 1 | Out-Null
  }
  Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Value 0 | Out-Null
  Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value 5 | Out-Null
  WriteLog "Registry Configuration Complete"
}
catch [Exception]{
  WriteLog "### FAILED ### -> $_"
  WriteLog "*******************************************************************************"
}

try {
  WriteLog "*******************************************************************************"

  # Timezone
  WriteLog "Setting UTC Zone Time"
  Start-Process -filepath "c:\Windows\System32\cmd.exe" -argumentlist "/c tzutil /s UTC" -nonewwindow

  # NTP Server
  WriteLog "Applying NTP Configuration"
  Set-Service W32Time -StartupType "Automatic"
  Start-Service W32Time
  Start-Process -filepath "c:\Windows\System32\cmd.exe" -argumentlist "/c w32tm /config /syncfromflags:manual /manualpeerlist:$ntp" -wait -nonewwindow
  Start-Process -filepath "c:\Windows\System32\cmd.exe" -argumentlist "/c w32tm /resync" -wait -nonewwindow

  # Power Management
  WriteLog "Applying Power Management Configuration"
  Start-Process -filepath "c:\Windows\System32\cmd.exe" -argumentlist "/c powercfg.exe -h off" -nonewwindow
  Start-Process -filepath "c:\Windows\System32\cmd.exe" -argumentlist "/c powercfg.exe -s 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c" -nonewwindow

  # BootFailure Ignore
  WriteLog "Applying BootFailure Configuration"
  Start-Process -filepath "c:\Windows\System32\cmd.exe" -argumentlist "/c bcdedit /set '{current}' bootstatuspolicy ignoreallfailures" -nonewwindow

  # Windows Activation
  WriteLog "Applying Windows Configuration"
  WriteLog "Setting KMS IP Address = $KmsServer"
  Start-Process -filepath "c:\Windows\System32\cscript.exe" -argumentlist "c:\Windows\System32\slmgr.vbs -skms $KmsServer" -wait -nonewwindow
  WriteLog "Setting KMS Client Key = $key"
  Start-Process -filepath "c:\Windows\System32\cscript.exe" -argumentlist "c:\Windows\System32\slmgr.vbs -ipk $key" -wait -nonewwindow
  WriteLog "Trying to activate Windows..."
  Start-Process -filepath "c:\Windows\System32\cscript.exe" -argumentlist "c:\Windows\System32\slmgr.vbs -ato" -wait -nonewwindow
  WriteLog "Windows Activation Status = $(Get-ActivationStatus | Select -ExpandProperty Status)"

  # MTU
  WriteLog "Updating MTU Ethernet Configuration"
  # Network Interface
  Disable-NetAdapterBinding -InterfaceAlias "Ethernet" -ComponentID ms_tcpip6
  Disable-NetAdapterBinding -InterfaceAlias Ethernet -ComponentID ms_tcpip6

  $netAdapter=Get-NetAdapterAdvancedProperty -Name "Ethernet"
  $mtu = $netAdapter | Where-Object {$_.DisplayName -eq "Init.MTUSize"}

  if ($mtu.DisplayValue -ne 8950)
  {
    Set-NetAdapterAdvancedProperty -Name "Ethernet" -DisplayName "Init.MTUSize" -DisplayValue 8950
  }

  $adapterList = Get-ChildItem -Path 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\NetworkCards\'
  $adapter = Get-ItemProperty -Path Registry::$adapterList -Name ServiceName
  $path = $adapter.ServiceName
  try
  {
    Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\services\Tcpip\Parameters\Interfaces\$path\" | Select-Object -ExpandProperty MTU -ErrorAction Stop | Out-Null
  }
  catch
  {
    New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\services\Tcpip\Parameters\Interfaces\$path\" -Name "MTU" -Value 9000 -PropertyType "DWord" | Out-Null
  }

  WriteLog "Enable Remote Desktop"
  # Registry
  Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0
  Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Keyboard Layout" -Name "IgnoreRemoteKeyboardLayout" -Value 0
  set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -name "UserAuthentication" -Value 1

  # RDP Firewall Connection
  Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

  # Cleanup
  Set-ExecutionPolicy RemoteSigned -Force
}

catch [Exception]{
  WriteLog "### FAILED ### -> $_"
  WriteLog  "*******************************************************************************"
}

try {
  WriteLog  "*******************************************************************************"
  WriteLog "User Data & Password Init"

  $UserData=ReadInfoURL $UrlUserData

  # User Script & Init Password
  if ($UserData -match '(?ism)# autoexecutepowershellnopasswd(.*)# autoexecutepowershellnopasswd') {

    WriteLog "Executing Powershell user script"
    # Return the matches of regex
    $matches[1] > $PsFile
    WriteLog "Password Set by the user script"
    WriteLog "Writing Info to Console"
    ConsoleOutput 1
    WriteLog "*******************************************************************************"
    WriteLog "### END OF SCRIPT ###"
    Start-Process -filepath "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -argumentlist "-File $PsFile" -Wait
    cleanLogoff
    Break
  }
  if ($UserData -match '(?ism)# autoexecutepowershell(.*)# autoexecutepowershell') {
    WriteLog "Executing Powershell user script"
    $matches[1] > $PsFile
    WriteLog "Init Password for current user"
    InitPasswd $UrlWindowsPassword $WindowsUser
    WriteLog "Writing Info to Console"
    ConsoleOutput 0
    WriteLog "*******************************************************************************"
    WriteLog "### END OF SCRIPT ###"
    Start-Process -filepath "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -argumentlist "-File $PsFile" -Wait
    cleanLogoff
    Break
  }
  if ($UserData -match '(?ism)# autoexecutevbs(.*)# autoexecutevbs') {
    WriteLog "Executing VisualBasic user script"
    $matches[1] > $VbsFile
    WriteLog "Init Password for current user"
    Initpasswd $UrlWindowsPassword $WindowsUser
    WriteLog "Writing Info to Console"
    ConsoleOutput 0
    WriteLog "*******************************************************************************"
    WriteLog "### END OF SCRIPT ###"
    Start-Process -filepath "c:\Windows\System32\cscript.exe" -argumentlist "-File $VbsFile" -Wait
    cleanLogoff
    Break
  }

  WriteLog "Init Password for current user"
  Initpasswd $UrlWindowsPassword $WindowsUser
  ConsoleOutput 0
  WriteLog "*******************************************************************************"
  WriteLog "### END OF SCRIPT ###"
  cleanLogoff
}
catch [Exception]{
  WriteLog "### FAILED ### -> $_"
}
