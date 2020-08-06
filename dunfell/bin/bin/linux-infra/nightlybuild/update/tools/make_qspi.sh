#!/bin/bash -x

MACHINE=arria10
RFS="rfs/"
KERNEL="zImage"
DTB="socfpga.dtb"
JFFS2_IMAGE="angstrom-some-rfs-${MACHINE}"
QSPI_IMAGE="${MACHINE}-qspi.img"

case "${MACHINE}" in
    arria10|arria10-swvp)
	QSPI_CHIP_SIZE=$((128*1024*1024))
	QSPI_CHIP_ERASE="64KiB"
	QSPI_CHIP_PAGE_SIZE=256
        BOOTLOADER_OFFSET=0x00000000
        BOOTLOADER_SIZE=0x000FFFFF
	DTB_OFFSET=0x00100000
        DTB_SIZE=0x0001FFFF
        KERNEL_OFFSET=0x00120000
        KERNEL_SIZE=0x600000
	RBF_OFFSET=0x00720000
	RBF_SIZE=0x1400000
	RFS_OFFSET=0x01B20000
	RFS_SIZE=0x08000000
        ;;
    *)
        echo "Unsupported Machine!" ;;
esac

# 1 we create the RFS image
mkfs.jffs2 -s ${QSPI_CHIP_PAGE_SIZE} \
           -e "${QSPI_CHIP_ERASE}"   \
           --root "${RFS}"           \
           -o "${JFFS2_IMAGE}"
if [ $? -ne 0 ] ; then
    echo "error: could not create JFFS2 image"
    exit 1
fi

# 2 try to generate the entire QSPI image
dd of="${QSPI_IMAGE}" seek=${QSPI_CHIP_SIZE} bs=1 count=0
if [ $? -ne 0 ] ; then
    echo "error: failed to create QSPI image file"
    exit 1
fi

# now map a loopback device
LB=$(losetup -s -f "${QSPI_IMAGE}")
if [ $? -ne 0 ] ; then
    echo "error: failed to map loopback device"
    exit 1
fi

# and now, we stuff
for i in 0 1 2 3 ; do
    dd if=u-boot-dtb.bin.img of="${LB}" \
	    bs=262144 \
            seek=${i}
done

losetup -d ${LB}

LB=$(losetup -s -f --offset ${DTB_OFFSET} --sizelimit ${DTB_SIZE} "${QSPI_IMAGE}")
if [ $? -ne 0 ] ; then
    echo "error: failed to map loopback device"
    exit 1
fi

dd if=${DTB} of=${LB}

losetup -d ${LB}

LB=$(losetup -s -f --offset ${KERNEL_OFFSET} --sizelimit ${KERNEL_SIZE} "${QSPI_IMAGE}")
if [ $? -ne 0 ] ; then
    echo "error: failed to map loopback device"
    exit 1
fi

dd if=${KERNEL} of=${LB}

losetup -d ${LB}

LB=$(losetup -s -f --offset ${RFS_OFFSET} --sizelimit ${RFS_SIZE} "${QSPI_IMAGE}")
if [ $? -ne 0 ] ; then
    echo "error: failed to map loopback device"
    exit 1
fi

dd if="${JFFS2_IMAGE}" of=${LB}
if [ $? -ne 0 ] ; then
    echo "error: failed to dd RFS"
    exit 1
fi

losetup -d ${LB}

