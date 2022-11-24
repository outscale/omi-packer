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
    default = "10"
}

variable "region" {
    type = string
    default = "${env("OUTSCALE_REGION")}"
}
variable "username" {
    type = string
    default = "outscale"
}

source "outscale-bsusurrogate" "builder" {
    launch_block_device_mappings {
        delete_on_vm_deletion = true
        device_name = "/dev/xvdf"
        iops = 3000
        volume_size = "${var.volsize}"
        volume_type = "io1"
    }
    omi_name = "${var.omi_name}"
    omi_root_device {
        delete_on_vm_deletion = true
        device_name = "/dev/sda1"
        source_device_name = "/dev/xvdf"
        volume_size = "${var.volsize}"
        volume_type = "standard"
    }
    source_omi = "${var.omi}"
    ssh_interface = "public_ip"
    ssh_username = "${var.username}"
    vm_type = "tinav5.c2r4p1"
}

build {
    sources = [ "source.outscale-bsusurrogate.builder" ]

    provisioner "file" {
        destination = "/tmp/"
        source = "./files/"
    }
    provisioner "shell" {
        execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E -S bash -x '{{ .Path }}'"
        scripts = [ "./scripts/base/${var.script}.sh" ]
        expect_disconnect = true
    }
    provisioner "shell" {
        execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E -S bash -x '{{ .Path }}' '${var.script}'"
        scripts = [
            "./scripts/linux/mount.sh",
            "./scripts/linux/dns.sh",
            "./scripts/linux/rhel-activation.sh",
            "./scripts/linux/packages.sh",
            "./scripts/linux/boot.sh",
            "./scripts/linux/ssh.sh",
            "./scripts/linux/cloud-init.sh",
            "./scripts/linux/selinux.sh",
            "./scripts/linux/cleanup.sh"
        ]
        pause_before = "10s"
    }
    provisioner "file" {
        destination = "./packages-${var.region}-${var.omi_name}"
        direction = "download"
        source = "/tmp/packages"
    }

}
