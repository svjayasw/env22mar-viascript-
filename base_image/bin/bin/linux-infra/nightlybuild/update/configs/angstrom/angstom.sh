# Mandatory variables
RELEASE_NAME=13.11.01
MACHINE=socfpga_cyclone5
PACKAGING=none
KERNEL_REPO=git://at-git/linux-socfpga
KERNEL_BRANCH=socfpga-3.13
KERNEL_PROT=git
KERNEL_PROVIDER="linux-altera"
KERNEL_DEFCONFIG=socfpga_defconfig
UBOOT_REPO=git://at-git/uboot-socfpga
UBOOT_BRANCH=socfpga_v2013.01.01
UBOOT_PROT=git
ANSGTROM_IMAGE_TYPE=console-image
# name of symlink to the latest build
LATEST_NAME=latest-cyclone5-angstrom
TAG_PREFIX=angstrom
# Extra Environment
EXTRA_SOCFPGA_PACKAGES="socfpga-test vlan"
