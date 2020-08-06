#!/bin/bash

INSTALL_DIR=/opt/altera-linux

echo "SoC-FPGA Source Code Release __RELEASE_NUMBER__"
echo
echo "Self-Extracting Installer"
echo

if [ -n "$1" ]; then
    INSTALL_DIR=$1
else
    printf "Please enter directory for source installation [hit enter to default to %s] " $INSTALL_DIR
    read answer
    if [ -n "$answer" ]; then
	INSTALL_DIR=`eval "echo $answer"`
    fi
fi

echo
if [ -d "$INSTALL_DIR" ]; then
    echo "Directory exists ($INSTALL_DIR), skipping install."
    exit 1
fi

# print the eula.
sed -r -n '/^__EULA_BELOW__/,/^__ARCHIVE_BELOW__/p' $0 | \
    egrep -v '__(EULA|ARCHIVE)_BELOW__' | more -d

printf "Press Enter to continue"
read answer

mkdir -p $INSTALL_DIR
chmod a+r $INSTALL_DIR

# Expand path for local directories which whos location will be placed in scripts
INSTALL_DIR=`readlink -f $INSTALL_DIR`

echo
echo "Installing to ${INSTALL_DIR}"

ARCHIVE=`awk '/^__ARCHIVE_BELOW__/ {print NR + 1; exit 0; }' $0`
tail -n+$ARCHIVE $0 | tar --no-same-owner -xv -C ${INSTALL_DIR}

echo "Installing Linaro toolchain to ${INSTALL_DIR}/linaro"

# install the linaro toolchain
mkdir ${INSTALL_DIR}/linaro
tar -xjf ${INSTALL_DIR}/sources/gcc-linaro-arm-linux-gnueabihf-4.7-2012.11-20121123_linux.tar.bz2 -C ${INSTALL_DIR}/linaro

# update the install path in the install script
sed -i "s,__INSTALL_PATH__,$INSTALL_DIR," ${INSTALL_DIR}/bin/install_altera_socfpga_src.sh
sed -i "s,__INSTALL_PATH__,$INSTALL_DIR," ${INSTALL_DIR}/sources/site.conf.sample


echo
echo "Now run this command (NOT as root) to install Yocto:"
echo "${INSTALL_DIR}/bin/install_altera_socfpga_src.sh ~/yocto"
echo

exit 0

# DO NOT add anything including blank lines after this next line:
__EULA_BELOW__
