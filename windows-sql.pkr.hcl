variable "omi_name" {
    type    = string
    default = "${env("OMI_NAME")}"
}

variable "iso" {
    type    = string
    default = "${env("ISO_URL")}"
}

packer {
    required_plugins {
        windows-update = {
            version = ">=0.14.0"
            source = "github.com/rgl/windows-update"
        }
    }
}

source "osc-bsu" "windows" {
    communicator = "winrm"
    disable_stop_vm = true
    omi_name = "${var.omi_name}"
    source_omi_filter {
        filters = {
            image-name = "WindowsServer-2019-GOLDEN"
        }
        owners = [ "Outscale" ]
    }
    ssh_interface = "public_ip"
    user_data_file = "scripts/windows/userdata"
    vm_type = "tinav4.c4r4p1"
    winrm_insecure = true
    winrm_use_ssl = true
    winrm_username = "Administrator"
}

build {
    sources = [ "source.osc-bsu.windows" ]

    provisioner "windows-update" {}
    provisioner "powershell" {
        inline = [
            "Remove-Item -Recurse -Force C:\\Windows\\Outscale\\",
            "Remove-Item -Recurse -Force 'C:\\Users\\Administrator\\AppData\\Local\\Microsoft_Corporation'"
        ]
    }
    provisioner "file" {
        destination = "C:\\Windows\\Outscale\\"
        source = "files/windows/"
    }
    provisioner "powershell" {
        environment_vars = ["ISO_URL=${var.iso}"]
        scripts = [ 
            "scripts/windows/mssql.ps1",
            "scripts/windows/ssms.ps1",
            "scripts/windows/firewall-tcp-1433.ps1"
        ]
    }
    provisioner "powershell" {
        scripts = [ "scripts/windows/sysprep.ps1" ]
    }
}
