#!/bin/bash

function cleanup {
	rm -rf fs tmp
	exit
}

trap 'cleanup' INT TERM

mkdir fs || cleanup
cd fs || cleanup
sudo tar -xf ../altera-image-socfpga_cyclone5.tar.gz
cd .. || cleanup
ln -fs socfpga_cyclone5.dtb socfpga.dtb
/home/root/bin/linux-infra/tools/make_sdimage.sh \
        -k zImage,socfpga.dtb \
        -p u-boot-spl-socfpga_cyclone5.bin \
        -b u-boot-socfpga_cyclone5.img \
        -r fs \
        -o sd_image.bin
mv preloader_image.bin u-boot-spl-socfpga_cyclone5.img
cleanup
