RELEASE_NAME=swvp-1.0
MACHINE=stratix10swvp
PACKAGING="swvp_image"
KERNEL_REPO=git://at-git/linux-socfpga
KERNEL_PROT=git
KERNEL_PROVIDER="linux-altera-ltsi-rt"
KERNEL_DEFCONFIG=defconfig
UBOOT_SKIP="yes"
ANGSTROM_VERSION=v2015.12
ANGSTROM_REPO=gitolite@at-git:angstrom-manifest
ANGSTROM_BRANCH=angstrom-v2015.12-yocto2.0
ANGSTROM_IMAGE_TYPE=console-image
# name of symlink to the latest build
LATEST_NAME=latest-${MACHINE}-angstrom-${ANGSTROM_VERSION}-ltsi-rt
TAG_PREFIX=angstrom
# Extra Environment
EXTRA_SOCFPGA_PACKAGES="socfpga-test"
