# test config
RELEASE_NAME=13.10.01
# if unset, it's not used
RELEASE_CANDIDATE=
MACHINE=socfpga
PACKAGING=none
KERNEL_REPO=gitolite@at-git:linux-socfpga
KERNEL_BRANCH=origin/socfpga-3.11
KERNEL_CONFIG=3c120_defconfig
# if TAG is unset, HEAD will be used
KERNEL_TAG=
UBOOT_REPO=gitolite@at-git:uboot-socfpga
UBOOT_BRANCH=meh
# if TAG is unset, HEAD will be used
UBOOT_TAG=
# name of symlink to the latest build
LATEST_NAME=latest-nios-stable

# KERNEL STUFF
export CROSS_COMPILE=/opt/sourceryg++-2013.05/bin/nios2-linux-gnu-
export ARCH=nios2

