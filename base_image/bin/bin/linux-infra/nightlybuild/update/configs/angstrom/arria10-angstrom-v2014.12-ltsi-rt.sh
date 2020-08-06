RELEASE_NAME=13.11.01
MACHINE=arria10
PACKAGING=none
KERNEL_REPO=git://at-git/linux-socfpga
KERNEL_PROT=git
KERNEL_PROVIDER="linux-altera-ltsi-rt"
KERNEL_BRANCH="socfpga-3.16"
KERNEL_DEFCONFIG=socfpga_defconfig
UBOOT_REPO=git://at-git/uboot-socfpga
UBOOT_BRANCH=socfpga_v2014.10_arria10_bringup
UBOOT_PROT=git
ANGSTROM_VERSION=v2014.12
ANGSTROM_REPO=git://at-git.intel.com/angstrom-socfpga
ANGSTROM_BRANCH=origin/angstrom-${ANGSTROM_VERSION}-socfpga
ANGSTROM_IMAGE_TYPE=extended-console-image
ANGSTROM_ALTERA_LAYER_BRANCH=angstrom-v2014.12-yocto1.7
FILE_OVERLAY="arria10-reva-overlay.sh"
# name of symlink to the latest build
LATEST_NAME=latest-${MACHINE}-angstrom-${ANGSTROM_VERSION}
TAG_PREFIX=angstrom
# Extra Environment
EXTRA_SOCFPGA_PACKAGES="socfpga-test"
ENV_ADDITIONAL_VARS="UBOOT_BRANCH"       # temporary as we're bringing up
