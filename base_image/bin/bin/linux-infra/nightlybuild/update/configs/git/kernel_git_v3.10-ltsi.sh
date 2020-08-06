# test config
RELEASE_NAME=13.10.01
MACHINE=socfpga
PACKAGING=none
KERNEL_REPO=gitolite@at-git:linux-socfpga
KERNEL_BRANCH=origin/socfpga-3.10-ltsi
KERNEL_CONFIG=socfpga_defconfig
LATEST_NAME=latest-ltsi
# KERNEL STUFF
export CROSS_COMPILE=/opt/altera-linux/linaro/gcc-linaro-4.9.4-2017.01-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-
export ARCH=arm
