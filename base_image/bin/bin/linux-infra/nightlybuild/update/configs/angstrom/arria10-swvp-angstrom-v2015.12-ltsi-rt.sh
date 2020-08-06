# Mandatory variables
RELEASE_NAME=13.11.01
MACHINE=arria10swvp
PACKAGING="sd_image swvp_image"
KERNEL_REPO=git://at-git/linux-socfpga
KERNEL_PROT=git
KERNEL_PROVIDER="linux-altera-ltsi-rt"
KERNEL_DEFCONFIG=socfpga_defconfig
UBOOT_REPO=git://at-git/uboot-socfpga
UBOOT_BRANCH=socfpga_v2014.10_arria10_bringup
UBOOT_PROT=git
ANGSTROM_VERSION=v2015.12
ANGSTROM_REPO=git://at-git.intel.com/angstrom-manifest
ANGSTROM_BRANCH=angstrom-v2015.12-yocto2.0
ANGSTROM_IMAGE_TYPE=console-image
# name of symlink to the latest build
LATEST_NAME=latest-arria10-angstrom-${ANGSTROM_VERSION}-ltsi-rt
FILE_OVERLAY="arria10-revc-overlay.sh"
TAG_PREFIX=angstrom
# Extra Environment
EXTRA_SOCFPGA_PACKAGES="socfpga-test"
