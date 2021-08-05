variable "omi" {
    type = string
    default = "${env("SOURCE_OMI")}"
}

variable "win_version" {
    type = string
    default = "w10"
}

source "osc-bsu" "windows" {
    communicator = "winrm"
    launch_block_device_mappings {
        delete_on_vm_deletion = true
        device_name = "/dev/sda1"
        iops = 3000
        volume_size = "50"
        volume_type = "io1"
    }
    omi_name = "windows${var.win_version}-wim"
    omi_virtualization_type = "hvm"
    source_omi = "${var.omi}"
    vm_type = "tinav4.c4r4p2"
    force_deregister = true
    force_delete_snapshot = true

    ssh_interface = "public_ip"
    user_data_file = "scripts/windows/userdata"
    winrm_insecure = true
    winrm_use_ssl = true
    winrm_username = "Administrator"
}

build {
    sources = [ "source.osc-bsu.windows" ]

    provisioner "powershell" {
        environment_vars = ["WINVERSION=${var.win_version}"]
        scripts = [ 
            "scripts/windows/download-iso-${var.win_version}.ps1",
            "scripts/windows/slipstream-virtio-wim.ps1" 
        ]
    }

    provisioner "file" {
        source = "C:/boot.wim"
        destination = "boot-${var.win_version}.wim"
        direction = "download"
    }
}
