# test config
RELEASE_NAME=13.11.01
# if unset, it's not used
RELEASE_CANDIDATE=
MACHINE=socfpga
PACKAGING=none
KERNEL_REPO=gitolite@at-git:linux-socfpga
KERNEL_BRANCH=origin/socfpga-3.16
KERNEL_CONFIG=socfpga_defconfig
# name of symlink to the latest build
LATEST_NAME=latest-3.16-yves-was-here
KERNEL_PATCH="files/0001-dts-change.patch"



# KERNEL STUFF
export CROSS_COMPILE=/opt/altera-linux/linaro/gcc-linaro-arm-linux-gnueabihf-4.7-2012.11-20121123_linux/bin/arm-linux-gnueabihf-
export ARCH=arm

