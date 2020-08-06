# Mandatory variables
RELEASE_NAME=13.11.01
MACHINE=socfpga_arria5
PACKAGING=none
KERNEL_REPO=git://at-git/linux-socfpga
KERNEL_PROT=git
KERNEL_PROVIDER="linux-altera-ltsi-rt"
KERNEL_BRANCH="socfpga-3.10-ltsi-rt"
KERNEL_DEFCONFIG=socfpga_defconfig
UBOOT_REPO=git://at-git/uboot-socfpga
UBOOT_BRANCH=socfpga_v2013.01.01
UBOOT_PROT=git
ANGSTROM_VERSION=v2013.12
ANGSTROM_REPO=git://at-git.intel.com/angstrom-socfpga
ANGSTROM_BRANCH=origin/angstrom-${ANGSTROM_VERSION}-socfpga
ANGSTROM_IMAGE_TYPE=extended-console-image
# name of symlink to the latest build
LATEST_NAME=latest-arria5-angstrom-${ANGSTROM_VERSION}-ltsi-rt
TAG_PREFIX=angstrom
# Extra Environment
EXTRA_SOCFPGA_PACKAGES="socfpga-test vlan"
