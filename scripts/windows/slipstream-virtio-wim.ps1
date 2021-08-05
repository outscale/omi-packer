$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

Invoke-WebRequest -Uri "https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso" -OutFile "C:\virtio.iso"

New-Item -Path C:\wim -ItemType "directory"

$windowsDrive = Mount-DiskImage -ImagePath "C:\windows.iso" -PassThru
$windowsDriveLetter = ($windowsDrive | Get-Volume).DriveLetter
Copy-Item "${windowsDriveLetter}:\sources\boot.wim" -Destination "C:\boot.wim"
Set-ItemProperty -Path C:\boot.wim -Name IsReadOnly -Value $false
Dismount-DiskImage -ImagePath "C:\windows.iso"

$virtioDrive = Mount-DiskImage -ImagePath "C:\virtio.iso"
$virtioDriveLetter = ($virtioDrive | Get-Volume).DriveLetter
Dism /Get-ImageInfo /imagefile:C:\boot.wim
Dism /Mount-Wim /WimFile:C:\boot.wim /Index:2 /MountDir:C:\wim
Dism /Image:C:\wim /Add-Driver /Driver:${virtioDriveLetter}:\amd64\$Env:WINVERSION /Recurse
Dism /Image:C:\wim /Add-Driver /Driver:${virtioDriveLetter}:\NetKVM\$Env:WINVERSION\amd64 /Recurse
Dism /Unmount-Wim /MountDir:C:\wim /Commit
Dismount-DiskImage -ImagePath "C:\virtio.iso" 
Get-Item c:\boot.wim