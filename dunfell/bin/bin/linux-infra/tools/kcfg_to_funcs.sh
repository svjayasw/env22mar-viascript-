#!/bin/bash  
# internals
SELF=$(basename $0)
SELF_DIR=$(dirname $0)

# constants

# default values
DEF_KERNEL_CONFIG_FILE=socfpga_defconfig
DEF_KERNEL_PATH=.
DEF_KERNEL_ARCH=arm
DEF_REPORT_FORMAT=short

# variables
KERNEL_CONFIG_FILE=${DEF_KERNEL_CONFIG_FILE}
KERNEL_PATH=${DEF_KERNEL_PATH}
KBUILD_PATH=
KERNEL_ARCH=${DEF_KERNEL_ARCH}
KERNEL_CONFIG=
REPORT_FORMAT=${DEF_REPORT_FORMAT}

# functions
function help() {

	echo "This script returns to stdout the list of functions associated with a kernel CONFIG option"
	echo
	echo "Usage: ${SELF} [-c kernel config] [-k kernel source tree] [-a arch] [-h|--help] -z CONFIG_XXX"
        echo "-b <kbuild>       : specifies the path to the kbuild directory. If not specified, default kernel path used."
	echo "-c <kernel config>: specifies the architecture specific kernel config file. Default is ${DEF_KERNEL_CONFIG_FILE}"
	echo "-k <path>         : specifies the path to the top of the kernel source tree. Default is ${DEF_KERNEL_PATH}"
	echo "-a <arch>         : specifies the kernel architecture to use. Default is ${DEF_KERNEL_ARCH}"
	echo "-z CONFIG_XXXX    : specifies the kernel config to use. No default"
	echo "-l                : produces a detailed report. Default is ${DEF_REPORT_FORMAT}"
        echo "-h|--help         : prints this lovely message"
	echo

	return
}

# script starts here
while [ $# -gt 0 ] ; do
    case $1 in
        -h|--help) help; exit 0 ;;
        -a) KERNEL_ARCH=$2 ; shift ;;
	-c) KERNEL_CONFIG_FILE=$2 ; shift ;;
	-k) KERNEL_PATH=$2 ; shift ;;
	-b) KBUILD_PATH=$2 ; shift ;;
	-z) KERNEL_CONFIG=$2 ; shift ;; 
        -l) REPORT_FORMAT=long ; shift ;;
        *)  echo "${SELF}: error: unknown option ${1}" ; usage ; exit ;;
    esac
    shift
done

# checks
if [ -z ${KERNEL_CONFIG} ] ; then
	echo "${SELF}: error: no kernel config specified."
	help
	exit -1
fi

if [ -z ${KBUILD_PATH} ] ; then
    KBUILD_PATH=${KERNEL_PATH}
fi

# transform all paths to absolute paths
KERNEL_PATH=$(readlink -f ${KERNEL_PATH})
KBUILD_PATH=$(readlink -f ${KBUILD_PATH})

# now, go grab all the CONFIG's associated with ${KERNEL_CONFIG}
CONFIGS=$(grep ${KERNEL_CONFIG} ${KERNEL_PATH}/arch/${KERNEL_ARCH}/configs/${KERNEL_CONFIG_FILE}| egrep -v -e '^#' | awk -F= ' { printf $1 " " } ')

# now go grab the files
# BUNDLE = <path to make file>:<list of object files
for config in $CONFIGS ; do 
    find ${KERNEL_PATH} -type f -name Makefile | xargs grep $config | 
    while read line ; do
        obj_files=$(echo ${line} | awk -F= ' { print $2 } ' | sed -e 's/^ //')
        if [ -z "${obj_files}" ] ; then
            continue
        fi

        obj_path=$(dirname $(echo $line | awk -F: ' { print $1 } ' | sed 's@'${KERNEL_PATH}'@'${KBUILD_PATH}'@'))

        for obj_file in ${obj_files} ; do

            if ! echo ${obj_file} | egrep -e '\.o$' > /dev/null ; then
                continue
            fi

            if [ ! -f ${obj_path}/$obj_file ] ; then
                echo "${SELF}: error: $obj_file: no such file or firectory."
                exit -2
            fi

            if [ "${REPORT_FORMAT}" = "short" ] ; then
                nm ${obj_path}/${obj_file} | egrep '^[0-9a-f]{8} [tT] [a-zA-Z]' | awk ' { print $3 } '
            else
                nm ${obj_path}/${obj_file} | egrep '^[0-9a-f]{8} [tT] [a-zA-Z]'
            fi
        done
    done
done | sort | uniq



