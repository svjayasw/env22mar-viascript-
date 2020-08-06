RELEASE_NAME=swvp-1.1
MACHINE=stratix10swvp
PACKAGING="sd_image swvp_image"
KERNEL_REPO=git://at-git/linux-socfpga
KERNEL_PROT=git
KERNEL_PROVIDER="linux-altera"
KERNEL_DEFCONFIG=defconfig
UBOOT_SKIP="yes"
ANGSTROM_VERSION=v2014.12
ANGSTROM_REPO=gitolite@at-git:angstrom-socfpga
ANGSTROM_BRANCH=origin/angstrom-${ANGSTROM_VERSION}-socfpga
ANGSTROM_IMAGE_TYPE=extended-console-image
#ANGSTROM_ALTERA_LAYER_BRANCH=angstrom-v2014.12-yocto1.7_s10
#FILE_OVERLAY="arria10-reva-overlay.sh"
# name of symlink to the latest build
LATEST_NAME=latest-${MACHINE}-angstrom-${ANGSTROM_VERSION}
TAG_PREFIX=angstrom
# Extra Environment
EXTRA_SOCFPGA_PACKAGES="socfpga-test"
