# test config
RELEASE_NAME=none
# if unset, it's not used
RELEASE_CANDIDATE=
MACHINE=arm64-generic
PACKAGING=none
KERNEL_REPO=gitolite@at-git:linux-bringup
KERNEL_BRANCH=origin/socfpga_nadder
KERNEL_CONFIG=defconfig
KERNEL_IMAGE=Image
# name of symlink to the latest build
LATEST_NAME=latest-${MACHINE}


# KERNEL STUFF
export CROSS_COMPILE=/opt/gcc-linaro-aarch64-linux-gnu-4.8-2014.01_linux/bin/aarch64-linux-gnu-
export ARCH=arm64

