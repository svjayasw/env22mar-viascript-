# test config
RELEASE_NAME=13.10.01
# if unset, it's not used
RELEASE_CANDIDATE=
MACHINE=socfpga
PACKAGING=none
KERNEL_REPO=gitolite@at-git:linux-socfpga
KERNEL_BRANCH=origin/socfpga-3.11
KERNEL_CONFIG=socfpga_defconfig
# if TAG is unset, HEAD will be used
KERNEL_TAG=
UBOOT_REPO=gitolite@at-git:uboot-socfpga
UBOOT_BRANCH=meh
# if TAG is unset, HEAD will be used
UBOOT_TAG=
# name of symlink to the latest build
LATEST_NAME=latest-stable


# KERNEL STUFF
export CROSS_COMPILE=/opt/altera-linux/linaro/gcc-linaro-arm-linux-gnueabihf-4.7-2012.11-20121123_linux/bin/arm-linux-gnueabihf-
export ARCH=arm

