
# OMI Builder
This project creates fully working Outscale Machine Images using Packer and shell scripts.

It requires an already working CentOS 8 image on the destination Outscale Region (for Linux images) or a working Windows Golden Image in the corresponding version of wanted Windows image (for Windows images).

## Requirements
 * [Packer](https://www.packer.io/downloads) (>= 1.7.8)

## Usage
Set the following environment variables:
```bash
export OUTSCALE_ACCESSKEYID=<ACCESS_KEY>
export OUTSCALE_SECRETKEYID=<SECRET_KEY>
export OUTSCALE_REGION=eu-west-2 # Outscale Region
export OMI_NAME=<OMI_NAME>
```
And, for Linux images only:
```bash
export SCRIPT_BASE=centos8 # Any script located in ./script/base/ without .sh extension
export SOURCE_OMI=ami-0dd0ab23 # A working CentOS 8 image
```
And, for Windows image only:
```bash
export BASE_NAME=Windows-10 # Base name, only required for Windows OMI, see below
export PKR_VAR_volsize=50 # Size in GB of produced OMI
```
You can then build the image using:
```bash
packer init -upgrade config.pkr.hcl
packer build linux.pkr.hcl # for Linux image
packer build windows.pkr.hcl # for Windows image
```

### Optional parameters
```bash
export PKR_VAR_volsize=<SIZE> # OMI root volume size in GB, default is 10
export PKR_VAR_username=outscale # Builder VM SSH Username
```

## Available images
### Linux
Linux images requires a working CentOS 8 or equivalent image present on destination Region, with a username "outscale".   
This username can be changed by setting `PKR_VAR_username` environment variable to a different username.

The following Linux scripts are provided and can be used in `SCRIPT_BASE`:

 * centos7 (CentOS 7)
 * centos8 (CentOS 8)
 * rhel7 (RedHat Enterprise Linux 7 without license)
 * rhel8 (RedHat Enterprise Linux 8 without license)
 * rhel7csp (RedHat Enterprise Linux 7)
 * rhel8csp (RedHat Enterprise Linux 8)
 * rocky8 (Rocky Linux 8)
 * ubuntu2004 (Ubuntu 20.04)
 * debian10 (Debian 10)
 * debian11 (Debian 11)
 * arch (ArchLinux)

**Beware:** CSP images (rhel7csp and rhel8csp) requires edition of ./files/cloudinit-specific/05_rhel7.cfg or ./files/cloudinit-specific/05_rhel8.cfg to set a proper RedHat Satellite Server owned and configured by the customer itself.
Failing to do so will result in a violation of Outscale Terms and Conditions.

### Windows
Windows images are required to be named `<BASE_NAME>-GOLDEN` in order to be recognized by the Packer scripts (eg. `Windows-10-GOLDEN`).  
This behaviour can be changed in `windows.pkr.hcl`.
