#!/bin/bash

SELF=$(basename $0)
SELF_DIR=$(dirname $0)

CONST_UB_12045="12.04.5"
CONST_UB_14042="14.04.2"
CONST_FE_21="21"
CONST_CE_701406="7.0.1406"

function usage() {

    echo "Usage: ${SELF} [-h|--help] [--version v]"

    echo "--version    : overrides the distro version"

    return 0

}

function get_distro_name() {

    local distro_name=$(lsb_release -d | \
                        awk -F: ' { print $2 } ' | \
                        sed -r 's/^\s+//' | \
                        sed 's/ /_/g')

    echo "${distro_name}"

    return 0
}

function do_deb() {

    local distro="${1}"
    local package_list=""
    local log_file="${SELF}.log"

    case "${distro}" in 
        "${CONST_UB_12045}")
            package_list="dos2unix finger diffstat wget unzip cscope"
            package_list="${package_list} uboot-mkimage lsb python-beautifulsoup"
            package_list="${package_list} gawk wget git-core diffstat unzip texinfo"
            package_list="${package_list} gcc-multilib build-essential chrpath socat"
            package_list="${package_list} libsdl1.2-dev xterm curl"
            ;;
        "${CONST_UB_14042}")
            package_list="dos2unix finger diffstat wget unzip cscope"
            package_list="${package_list} uboot-mkimage lsb python-beautifulsoup"
            package_list="${package_list} gawk wget git-core diffstat unzip texinfo"
            package_list="${package_list} gcc-multilib build-essential chrpath socat"
            package_list="${package_list} libsdl1.2-dev xterm curl"
            ;;
        *)
            echo "${SELF}: ${FUNCNAME}: internal error: ${distro}: invalid value"
            return 1
            ;;
    esac

    for package in ${package_list} ; do
        aptitude -y install ${package} 2>&1 >>${log_file}
        if [ $? -ne 0 ] ; then
            echo "${SELF}: ${FUNCNAME}: ${package}: failed to install. See ${log_file}."
            return 1
        fi
        echo -e "\n#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%\n\n" >>${log_file}
    done

    return 0
}

function do_rpm() {


    local distro="${1}"
    local package_list=""
    local group_package_list=""

    local log_file="${SELF}.log"

    case "${distro}" in 
        "${CONST_FE_21}")
            package_list="texi2html texinfo glibc-devel chrpath"
            package_list="${package_list} glibc.i686 libgcc.i686 libstdc++.i686"
            package_list="${package_list} glibc-devel.i686 ncurses-libs.i686 zlib.i686"
	    package_list="${package_list} curl"
            group_package_list="Development Tools"
            ;;
        "${CONST_CE_701406}")
            package_list="texi2html texinfo glibc-devel chrpath"
            package_list="${package_list} glibc.i686 libgcc.i686 libstdc++.i686"
            package_list="${package_list} glibc-devel.i686 ncurses-libs.i686 zlib.i686"
            group_package_list="Development Tools"
            ;;
        *)
            echo "${SELF}: ${FUNCNAME}: internal error: ${distro}: invalid value"
            return 1
            ;;
    esac

    for package in ${package_list} ; do
        yum install -y ${package} 2>&1 >>${log_file}
        if [ $? -ne 0 ] ; then
            echo "${SELF}: ${FUNCNAME}: ${package}: failed to install. See ${log_file}."
            return 1
        fi
        echo -e "\n#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%\n\n" >>${log_file}
    done

    for gpackage in ${group_package_list} ; do
        yum groupinstall -y "${gpackage}" 2>&1 >>${log_file}
        if [ $? -ne 0 ] ; then
            echo "${SELF}: ${FUNCNAME}: ${gpackage}: failed to group install. See ${log_file}."
            return 1
        fi
        echo -e "\n#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%#%\n\n" >>${log_file}
    done
   
}


if [ ${UID} -ne 0 ] ; then
    echo "${SELF}: error: only root can do this"
    exit 1
fi

while [ $# -gt 0 ] ; do

    case $1 in
        -h|--help)
             usage; exit ;;

        --version)
             echo "${SELF}: warning: --version ignored"
             ;;

        *)
             print "$1: unknown option" "error"; usage ; exit -1 ;;
    esac

    shift

done

DISTRO="$(get_distro_name)"
echo "${SELF}: info: setting up distribution ${DISTRO}"

case "${DISTRO}" in
    Ubuntu_12.04.5_LTS)
        do_deb "${CONST_UB_12045}"
        err=$?
        ;;
    Ubuntu_14.04.2_LTS)
        do_deb "${CONST_UB_14042}"
        err=$?
        ;;
    Fedora_release_21*)
        do_rpm "${CONST_FE_21}"
        err=$?
        ;;
    CentOS_Linux_release_7.0.1406_(Core)_)
        do_rpm "${CONST_CE_701406}"
        err=$?
        ;;
    *)
        echo "${SELF}: error: ${DISTRO}: unsupported distro!"
        exit 1
        ;;
esac

if [ ${err} -ne 0 ] ; then
    echo "${SELF}: failed to setup ${DISTRO}"
    exit ${err}
fi

echo "${SELF}: info: success"
exit 0

