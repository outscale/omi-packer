variable "omi_name" {
    type    = string
    default = "${env("OMI_NAME")}"
}

variable "base_name" {
    type    = string
    default = "${env("BASE_NAME")}"
}

packer {
    required_plugins {
        windows-update = {
            version = ">=0.14.0"
            source = "github.com/rgl/windows-update"
        }
    }
}

source "outscale-bsu" "windows" {
    communicator = "winrm"
    disable_stop_vm = true
    omi_name = "${var.omi_name}"
    source_omi_filter {
        filters = {
            image-name = "${var.base_name}-GOLDEN"
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
    sources = [ "source.outscale-bsu.windows" ]

    provisioner "windows-update" {}
    provisioner "powershell" {
        inline = [
            "Remove-Item -Recurse -Force C:\\Windows\\Outscale\\",
            "Remove-Item -Recurse -Force 'C:\\Users\\Administrator\\AppData\\Roaming\\Microsoft\\Windows\\Start Menu\\Programs\\Startup\\SetupComplete.cmd'",
            "Remove-Item -Recurse -Force 'C:\\Users\\Default\\AppData\\Roaming\\Microsoft\\Windows\\Start Menu\\Programs\\Startup\\SetupComplete.cmd'"
        ]
    }
    provisioner "file" {
        destination = "C:\\Windows\\Outscale\\"
        source = "files/windows/"
    }
    provisioner "powershell" {
        scripts = [ "scripts/windows/sysprep.ps1" ]
    }
}
