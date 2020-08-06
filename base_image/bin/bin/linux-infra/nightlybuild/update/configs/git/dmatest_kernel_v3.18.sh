# test config
RELEASE_NAME=whatisthis
# if unset, it's not used
RELEASE_CANDIDATE=
MACHINE=socfpga
PACKAGING=none
KERNEL_REPO=gitolite@at-git:linux-socfpga
KERNEL_BRANCH=origin/socfpga-3.18
KERNEL_CONFIG=socfpga_defconfig
# name of symlink to the latest build
LATEST_NAME=latest-dmatest-v3.18
KERNEL_PATCH="files/0001-Config-changes-for-DMA-modules-in-3.18.patch"



# KERNEL STUFF
export CROSS_COMPILE=/opt/altera-linux/linaro/gcc-linaro-arm-linux-gnueabihf-4.7-2012.11-20121123_linux/bin/arm-linux-gnueabihf-
export ARCH=arm

