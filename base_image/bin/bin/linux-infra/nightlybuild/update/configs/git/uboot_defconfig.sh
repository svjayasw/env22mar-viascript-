RELEASE_NAME="13.01.01"
MACHINE="socfpga_cyclone5"
PACKAGING="none"
UBOOT_REPO="gitolite@at-git:uboot-socfpga"
UBOOT_BRANCH="origin/socfpga_v2013.01.01"
CROSS_COMPILE="/opt/altera-linux/linaro/gcc-linaro-arm-linux-gnueabihf-4.7-2012.11-20121123_linux/bin/arm-linux-gnueabihf-"
SPL_CONFIG_UPDATES="CONFIG_PRELOADER_BOOT_FROM_QSPI=1,CONFIG_PRELOADER_BOOT_FROM_SDMMC=0,CONFIG_PRELOADER_BOOT_FROM_NAND=0,CONFIG_PRELOADER_BOOT_FROM_RAM=0"
LATEST_NAME="uboot-${MACHINE}-defconfig"

