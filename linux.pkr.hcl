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

variable "volume_size" {
    type = string
    default = "${env("VOL_SIZE")}"
}

variable "region" {
    type = string
    default = "${env("OUTSCALE_REGION")}"
}
variable "username" {
	type = string
	default = "outscale"
}

source "osc-bsusurrogate" "centos8" {
    launch_block_device_mappings {
        delete_on_vm_deletion = true
        device_name = "/dev/xvdf"
        iops = 3000
        volume_size = "${var.volume_size}"
        volume_type = "io1"
    }
    omi_name = "${var.omi_name}"
    omi_root_device {
        delete_on_vm_deletion = true
        device_name = "/dev/sda1"
        source_device_name = "/dev/xvdf"
        volume_size = "${var.volume_size}"
        volume_type = "standard"
    }
    omi_virtualization_type = "hvm"
    source_omi = "${var.omi}"
    ssh_interface = "public_ip"
    ssh_username = "${var.username}"
    vm_type = "tinav4.c2r4p1"
}

build {
    sources = [ "source.osc-bsusurrogate.centos8" ]

    provisioner "file" {
        destination = "/tmp/"
        source = "./files/"
    }
    provisioner "shell" {
        execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E -S bash -x '{{ .Path }}' '${var.script}'"
        scripts = [
            "./scripts/base/${var.script}.sh",
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
    }
    provisioner "file" {
        destination = "/usr/local/packer/logs/packages/${var.region}-${var.omi_name}"
        direction = "download"
        source = "/tmp/packages"
    }

}
