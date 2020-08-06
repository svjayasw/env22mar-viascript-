#!/bin/bash

# internals
SELF=$(basename $0)

# defaults
DEF_BUILD_ENTRY_DIR=angstrom_clone
DEF_BIN_DIR=binaries
DEF_COMPRESS_IMAGE="no"
DEF_MACHINE=socfpga
DEF_IMAGE_NAME=sd_image_angstrom_${DEF_MACHINE}.bin

# constants
CONST_RFS_DIR=rfs
CONST_PRELOADER_IMAGER=/opt/altera/13.1/embedded/host_tools/altera/mkpimage/mkpimage
CONST_SDIMAGER=/home/build/nfs_night_build/bin/linux-infra/tools/make_sdimage.py

# usage
function usage() {

    echo "usage: $0 -t dir -d bindir -i name [-c] [-p exe]"
    echo "-t: specifies the entry dir of the build. Default=${DEF_BUILD_ENTRY_DIR}"
    echo "-d: where the binaries need to be copied. Default=${DEF_BIN_DIR}"
    echo "-dtb: device tree file to use. No Default."
    echo "-i: image name. Default=sd_image_angstrom_${DEF_MACHINE}.bin"
    echo "-m: machine. Default=${DEF_MACHINE}"
    return
}

# copy files from the build into the BIN_DIR
# when called, the destination dir exists
# $# = list of files to copy
# We assume the build location is 
function copy_files_to_bin() {

    local dtb="$1"
    # relative to BUILD_ENTRY_DIR
    ANGSTROM_BUILD=${BUILD_ENTRY_DIR}/build/tmp-angstrom_v2012_12-eglibc/deploy/images/${MACHINE}

    for file in u-boot-spl-${MACHINE}.bin u-boot-${MACHINE}.img ${dtb} zImage \
                console-image-${MACHINE}.tar.gz ; do
        cp -aL ${ANGSTROM_BUILD}/$file ${BIN_DIR}
        if [ $? -ne 0 ] ; then
            echo "${SELF}: ${FUNCNAME}: error: $file: no such file"
            exit -1
        fi
### CHANGE dtb TO ${MACHINE}!!
        case "${file}" in 
            "${dtb}")
    	        cp -aL ${ANGSTROM_BUILD}/$file ${BIN_DIR}/socfpga.dtb
                if [ $? -ne 0 ] ; then
                    echo "${SELF}: ${FUNCNAME}: error: $file: no such file"
                    exit -1
                fi
                ;;
            "u-boot-${MACHINE}.img")
                # Todo: FILL in UBOOT short name
                cp -aL ${ANGSTROM_BUILD}/$file ${BIN_DIR}/u-boot.img
                if [ $? -ne 0 ] ; then
                     echo "${SELF}: ${FUNCNAME}: error: $file: no such file"
                     exir -1
                fi
                ;;
        esac 
    done

}

# preloader image
function make_preloader_image() {

    local spl=$1
    local spl_h=${spl}.img

    # stuff from SoCEDS
    ${CONST_PRELOADER_IMAGER} -o ${spl_h} ${spl} 
    if [ $? -ne 0 ] ; then
        echo "${SELF}: ${FUNCNAME}: error: failed to make spl image" 1>/dev/null 1>&2
        exit -1
    fi

    echo ${spl_h}
}


# start
echo "${SELF}: info: starting"

# script starts here
if [ $# -eq 0 ]; then
    usage
    exit 0
fi

# init variables...
BUILD_ENTRY_DIR=${DEF_BUILD_ENTRY_DIR}
BIN_DIR=${DEF_BIN_DIR}
IMAGE_NAME=${DEF_IMAGE_NAME}
COMPRESS_IMAGE=${DEF_COMPRESS_IMAGE}
MACHINE=${DEF_MACHINE}
LIST_OF_FILES=${DEF_LIST_OF_FILES}
IMAGER=${CONST_SDIMAGER}
DTB= 

while [ $# -gt 0 ] ; do
    case $1 in
        -h) usage; exit ;;
        -t) BUILD_ENTRY_DIR=$2 ; shift ;;
        -d) BIN_DIR=$2 ; shift ;;
        -dtb) DTB=$2 ; shift ;;
        -i) IMAGE_NAME=$2 ; shift ;;
        -c) COMPRESS_IMAGE="yes" ;;
        -m) MACHINE=$2 ; shift ;;
        *)  echo "error: $1: unknown option" ; usage ; exit -1 ;;
    esac
    shift
done

# make paths absolute
BIN_DIR=$(readlink -f ${BIN_DIR})
BUILD_ENTRY_DIR=$(readlink -f ${BUILD_ENTRY_DIR})

if [ ! -d ${BUILD_ENTRY_DIR} ] ; then
    echo "${SELF}: error: ${BUILD_ENTRY_DIR}: no such directory"
    exit -1
fi

if [ ! -d ${BIN_DIR} ] ; then
    echo "${SELF}: info: mkdir ${BIN_DIR}"
    mkdir ${BIN_DIR}
    if [ $? -ne 0 ] ; then
        echo "${SELF}: error: ${BIN_DIR}: failed to create directory"
        exit -1
    fi
else
    echo "${SELF}: warning: ${BIN_DIR}: contents will be overridden"
fi

# copy files to ${BIN_DIR}, easier to find than in the burried Angstrom location
echo "${SELF}: info: copy files to ${BIN_DIR}..."
copy_files_to_bin ${DTB}

# let's create the image now
pushd ${BIN_DIR} 2>/dev/null 1>&2

echo "${SELF}: info: expanding RFS"
mkdir ${CONST_RFS_DIR}
tar xfz console-image-${MACHINE}.tar.gz -C ${CONST_RFS_DIR}
if [ $? -ne 0 ] ; then
    echo "${SELF}: error: could not expand RFS..."
    exit -1
fi

echo "${SELF}: info: assembling image for machine ${MACHINE}"
${IMAGER} \
-P $(make_preloader_image u-boot-spl-${MACHINE}.bin),num=3,type=a2,format=raw,size=512k \
-P zImage,u-boot.img,socfpga.dtb,num=1,format=vfat,size=5M \
-P ${CONST_RFS_DIR},num=2,format=ext3,size=1G \
-s 2G -n ${IMAGE_NAME}
if [ $? -ne 0 ] ; then
    echo "${SELF}: error: failed to create image"
    exit -1
fi

echo "${SELF}: info: done"

