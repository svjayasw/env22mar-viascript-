#!/bin/bash -e
# Install all the Yocto sources and create a folder for poky

LINUX_VERSION=__LINUX_VERSION__
UBOOT_VERSION=__UBOOT_VERSION__

INSTALL_DIR=__INSTALL_PATH__
YOCTO_RELEASE=__YOCTO_RELEASE__
YOCTO=${INSTALL_DIR}/sources/${YOCTO_RELEASE}.tar.gz

DEST_DIR=$1
if [ -z "$DEST_DIR" ]; then
     echo "Usage: $BASH_SOURCE <install directory>"
     exit 1
fi

echo "Installing Yocto to $DEST_DIR"
if [ -d "${DEST_DIR}/${YOCTO_RELEASE}" ]; then
    echo "Directory exists (${DEST_DIR}/${YOCTO_RELEASE}).  Skipping install."
    exit 1
fi
if [ ! -d "$INSTALL_DIR" ]; then
    echo "SoC-FPGA release not found. $INSTALL_DIR does not exist."
    exit 1
fi
for foo in $YOCTO; do
    if [ ! -e "$foo" ]; then
	echo "Error, giving up.  File not found: $foo"
	exit 1
    fi
done

mkdir -p $DEST_DIR
tar -C $DEST_DIR -xf $YOCTO
cp ${INSTALL_DIR}/sources/site.conf.sample $DEST_DIR/meta-altera/conf/site.conf.sample
if [[ "${YOCTO_RELEASE}" == *danny* ]]; then
sed -i '/meta-altera \\/a\ \ ##COREBASE##\/meta-linaro \\' $DEST_DIR/meta-altera/conf/bblayers.conf.sample
fi
if [[ "${YOCTO_RELEASE}" == *dylan* ]]; then
sed -i '/meta-altera \\/a\  ##COREBASE##\/meta-linaro-toolchain \\\n  ##COREBASE##\/toolchain-layer \\' $DEST_DIR/meta-altera/conf/bblayers.conf.sample
fi

# Expand path for local directories which whos location will be placed in scripts
DEST_DIR=`readlink -f $DEST_DIR`

echo "Complete"
echo
echo "To build Linux using Yocto, type the following (assuming you want to build in ${DEST_DIR}/build):"
echo "  source ${DEST_DIR}/altera-init ${DEST_DIR}/build"
echo "  bitbake virtual/kernel virtual/bootloader altera-image"
echo

# dependencies: g++, diffstat, texi2html, makeinfo, svn, chrpath
