# test config
RELEASE_NAME=13.10.01
MACHINE=socfpga
PACKAGING=none
KERNEL_REPO=gitolite@at-git:linux-socfpga
KERNEL_BRANCH=origin/socfpga-3.10-ltsi
KERNEL_CONFIG=socfpga_defconfig
UBOOT_REPO=gitolite@at-git:uboot-socfpga
UBOOT_BRANCH=meh
KERNEL_RT_PATCH=patch-3.10.10-rt7.patch.gz
LATEST_NAME=latest-ltsi-rt

# KERNEL STUFF
export CROSS_COMPILE=/opt/altera-linux/linaro/gcc-linaro-arm-linux-gnueabihf-4.7-2012.11-20121123_linux/bin/arm-linux-gnueabihf-
export ARCH=arm
