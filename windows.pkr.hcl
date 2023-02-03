variable "omi_name" {
    type    = string
    default = "${env("OMI_NAME")}"
}

variable "base_name" {
    type    = string
    default = "${env("BASE_NAME")}"
}

variable "volsize" {
    type    = string
    default = "50"
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
    force_delete_snapshot = true
    bsu_optimized = true
    launch_block_device_mappings {
        delete_on_vm_deletion = true
        device_name = "/dev/sda1"
        volume_size = "${var.volsize}"
        volume_type = "gp2"
    }
    source_omi_filter {
        filters = {
            image-name = "${var.base_name}-GOLDEN"
        }
        owners = [ "Outscale" ]
    }
    ssh_interface = "public_ip"
    user_data_file = "scripts/windows/userdata"
    vm_type = "tinav5.c4r8p1"
    winrm_insecure = true
    winrm_use_ssl = true
    winrm_username = "Administrator"
}

build {
    sources = [ "source.outscale-bsu.windows" ]

    provisioner "windows-update" {}
    provisioner "powershell" {
        scripts = [
            "scripts/windows/virtio.ps1",
            "scripts/windows/enable-rtc.ps1",
            "scripts/windows/cleanup.ps1"
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
