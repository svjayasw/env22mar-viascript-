# Mandatory variables
RELEASE_NAME=13.11.01
MACHINE=cyclone5
PACKAGING=none
KERNEL_REPO=git://at-git/linux-socfpga
KERNEL_PROT=git
KERNEL_PROVIDER="linux-altera-ltsi"
KERNEL_DEFCONFIG=socfpga_defconfig
UBOOT_REPO=git://at-git/uboot-socfpga
UBOOT_PROT=git
ANGSTROM_VERSION=v2015.12
# TODO TODO: make sure we have this on at-git
ANGSTROM_REPO=git://at-git.intel.com/angstrom-manifest
#ANGSTROM_REPO=git://github.com/Angstrom-distribution/angstrom-manifest
ANGSTROM_BRANCH=angstrom-v2015.12-yocto2.0
ANGSTROM_IMAGE_TYPE=console-image
# name of symlink to the latest build
LATEST_NAME=latest-cyclone5-angstrom-${ANGSTROM_VERSION}-ltsi
TAG_PREFIX=angstrom
# Extra Environment
EXTRA_SOCFPGA_PACKAGES="socfpga-test"
