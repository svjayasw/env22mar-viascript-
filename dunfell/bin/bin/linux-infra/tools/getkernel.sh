#!/bin/bash
# Internals
SELF=`basename $0`

# Defaults
DEF_KERNEL="arch/arm/boot/zImage"
DEF_OUTPUT=kernel-arm
DEF_KEEP_COMPRESSED=no
DEF_ASK=yes

# Variables
KERNEL=${DEF_KERNEL}
OFFSET=${DEF_OFFSET}
OUTPUT=${DEF_OUTPUT}
KEEP_COMPRESSED=${DEF_KEEP_COMPRESSED}
ASK=${DEF_ASK}

# functions
function usage() {

    echo     "Extracts the kernel code from a zImage."
    echo     "usage: ${SELF} [-h] [-k zImage] [-o offset] [-w output] [-n] [-y]" 
    echo -e  "\t-k kernel: location of the zImage. Default is ${DEF_KERNEL}."
    echo -e  "\t-o offset: offset. Overrides the computation"
    echo -e  "\t-w output: uncompressed kernel file name. Default is ${DEF_OUTPUT}."
    echo -e  "\t-n       : keep the kernel compressed. Default is ${DEF_KEEP_COMPRESSED}."
    echo -e  "\t-y       : do not ask questions."
}

# od -t x1 arch/arm/boot/zImage -Ad | grep "1f 8b" | head -1 | awk ' { print $1 } '
function getOffset() {

    local kernel=$1
    local offset

    offset=$(od -t x1 -Ad ${kernel} | grep "1f 8b" | head -1 | awk ' { print $1 } ')

    echo ${offset}
}

# Here we parse options
while [ $# -gt 0 ] ; do
    case $1 in
        -h) usage ; exit 0 ;;
        -k) KERNEL=$2 ; shift ;;        
        -o) OFFSET=$2 ; shift ;;
        -w) OUTPUT=$2 ; shift ;;
        -y) ASK=no ;;
        -n) KEEP_COMPRESSED=yes ;;
        *)  echo "${SELF}: error: unknown option" ; usage ; exit ;;
    esac
    shift
done

# checks
if [ ${ASK} == "yes" ] ; then
    if [ -e ${OUTPUT} ] ; then
       echo -n "${SELF}: warning: output file ${OUTPUT} exists. Continue? (y|n) "
       read yes_or_no
       if [ ! ${yes_or_no} == "y" ] ; then
           echo " Bye."
           exit 0
       fi
    fi
fi

if [ ! -f ${KERNEL} ] ; then
    echo "$SELF: error: ${KERNEL}: no such file"
    exit -1
fi

# dd if=arch/arm/boot/zImage of=blob.gz bs=1 skip=18480
OFFSET=$(getOffset ${KERNEL})
echo "${SELF}: info: extracting kernel (offset=${OFFSET})"
if [ ${KEEP_COMPRESSED} == "no" ] ; then
    dd if=${KERNEL} skip=${OFFSET} bs=1 | gunzip > ${OUTPUT}
else
    dd if=${KERNEL} skip=${OFFSET} of=${OUTPUT} bs=1
fi

