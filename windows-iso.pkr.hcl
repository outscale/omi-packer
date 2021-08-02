variable "omi_name" {
    type = string
    default = "${env("OMI_NAME")}"
}

variable "omi" {
    type = string
    default = "${env("SOURCE_OMI")}"
}

variable "script" {
    type = string
    default = "${env("SCRIPT_BASE")}"
}

variable "volsize" {
    type = string
    default = "50"
}

variable "region" {
    type = string
    default = "${env("OUTSCALE_REGION")}"
}
variable "username" {
    type = string
    default = "outscale"
}
variable "win_version" {
    type = string
    default = "10"
}

source "osc-bsusurrogate" "centos" {
    launch_block_device_mappings {
        delete_on_vm_deletion = true
        device_name = "/dev/xvdf"
        iops = 3000
        volume_size = "10"
        volume_type = "io1"
    }
    omi_name = "windows${var.win_version}-iso-${formatdate("YYYYMMDD", timestamp())}"
    omi_root_device {
        delete_on_vm_deletion = true
        device_name = "/dev/sda1"
        source_device_name = "/dev/xvdf"
        volume_size = "10"
        volume_type = "standard"
    }
    omi_virtualization_type = "hvm"
    source_omi = "${var.omi}"
    ssh_interface = "public_ip"
    ssh_username = "${var.username}"
    vm_type = "tinav4.c2r4p2"
}

build {
    sources = [ "source.osc-bsusurrogate.centos" ]

    provisioner "shell" {
        execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E -S bash -x '{{ .Path }}'"
        scripts = [
            "./scripts/base-windows/windows${var.win_version}.sh"
        ]
    }

    provisioner "file" {
        source = "./scripts/windows/autounattend_windows${var.win_version}.xml"
        destination = "/mnt/hdd/autounattend.xml"
    }

    provisioner "file" {
        source = "./scripts/windows/setup.ps1"
        destination = "/mnt/hdd/setup.ps1"
    }
}
