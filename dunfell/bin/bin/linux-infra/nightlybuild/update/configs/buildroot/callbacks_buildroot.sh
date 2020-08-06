
# Constants
BUILDROOT_DIR="buildroot"
KERNEL_DIR="kernel"
KERNEL_IMAGE="vmImage"
ARCH="nios2"
UBOOT_DIR="uboot"
UBOOT_FIXUP_PATCH="0001-Add-3c120-dev-board-support.patch?t=1417032392"
UBOOT_FIXUP_PATCH_URL="http://www.rocketboards.org/pub/Documentation/NiosIILinuxUserManualForCycloneIII/${UBOOT_FIXUP_PATCH}"
NIOS2_DTB="3c120_devboard.dtb"

CROSS_COMPILE="nios2-linux-gnu-"

BINARIES="binaries"
ROOTFS="rootfs.tar"

# GIT Library
source ${LIB_PATH_NIGHTLY}/libgit.sh

function get_num_cpus() {

    echo $(lscpu | egrep "^CPU\(s\):" | awk -F: ' { print $2 } ' | sed -e 's/^ *//')

    return
}

function check_env() {

    local gcc

    for var in ARCH CROSS_COMPILE BUILDROOT_REPO BUILDROOT_BRANCH BUILDROOT_CFG ; do
        value=$(eval echo \$$var)
        if [ "${var}" == "ARCH" -a "${value}" != "nios2" ] ; then
            echo "${SELF}: error: ARCH is not nios2 (but ${ARCH})"
            return 3
        fi
        if [ -z ${value} ] ; then
           echo "${SELF}: ${FUNCNAME}: error: ${var} is not set"
           return 1
        fi
    done
    
    gcc=$(which ${CROSS_COMPILE}gcc)
    if [ -z ${gcc} ] ; then
        echo "${SELF}: ${FUNCNAME}: error: ${CROSS_COMPILE}gcc not on path..."
        return 2
    fi

    return 0
}

function do_init() {

    # clone buildroot
    clone_git_repo ${BUILDROOT_REPO} ${BUILDROOT_BRANCH} ${BUILDROOT_DIR}
    if [ $? -ne 0 ] ; then
        echo "${FUNCNAME}: clone_git (${BUILDROOT_REPO}) failed"
        return 1
    fi

    # kernel
    clone_git_repo ${KERNEL_REPO} ${KERNEL_BRANCH} ${KERNEL_DIR}
    if [ $? -ne 0 ] ; then
        echo "${FUNCNAME}: clone_git (${KERNEL_REPO}) failed"
        return 1
    fi

    # uboot
    clone_git_repo ${UBOOT_REPO} ${UBOOT_BRANCH} ${UBOOT_DIR}
    if [ $? -ne 0 ] ; then
        echo "${FUNCNAME}: clone_git (${UBOOT_REPO}) failed"
        return 1
    fi
    # Fix up UBOOT
    cd ${UBOOT_DIR}
    wget ${UBOOT_FIXUP_PATCH_URL}
    if [ $? -ne 0 ] ; then
        echo "${FUNCNAME}: ${UBOOT_FIXUP_PATCH}: failed to download"
        return 1
    fi
    patch -p1 < ${UBOOT_FIXUP_PATCH}
    if [ $? -ne 0 ] ; then
        echo "${FUNCNAME}: ${UBOOT_FIXUP_PATCH}: failed to apply"
        return 1
    fi
    cd -

    return 0
}

function do_build() {

    echo "${FUNCNAME}: building ${BUILDROOT_CFG}..."

    # PATH update for cross compiler. This may need update if run on another machine.
    echo "${FUNCNAME}: updating PATH with cross compiler version ${CROSS_COMPILE_VERSION}"
    export PATH=${PATH}:/opt/sourceryg++-${CROSS_COMPILE_VERSION}/bin/
    echo "${FUNCNAME}: info: CROSS_COMPILE=${CROSS_COMPILE}"
    export ARCH

    pushd ${BUILDROOT_DIR} >/dev/null 2>&1
    make ${BUILDROOT_CFG}
    if [ $? -ne 0 ] ; then
       echo "${SELF}: ${FUNCNAME}: error: buildroot make failed"
       return 1
    fi
    make -j$((2*$(get_num_cpus)))
    popd >/dev/null 2>&1

    echo "${FUNCNAME}: building kernel..."
    pushd ${KERNEL_DIR} >/dev/null 2>&1
    make ARCH=${ARCH} ${KERNEL_CONFIG}
    if [ $? -ne 0 ] ; then
       echo "${SELF}: ${FUNCNAME}: error: kernel config make failed"
       return 1
    fi
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} ${KERNEL_IMAGE}
    if [ $? -ne 0 ] ; then
       echo "${SELF}: ${FUNCNAME}: error: kernel make failed"
       return 1
    fi
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} modules
    if [ $? -ne 0 ] ; then
       echo "${SELF}: ${FUNCNAME}: error: kernel make failed"
       return 1
    fi
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} ${NIOS2_DTB}
    if [ $? -ne 0 ] ; then
       echo "${SELF}: ${FUNCNAME}: error: kernel make failed"
       return 1
    fi
    popd >/dev/null 2>&1

    echo "${FUNCNAME}: building uboot..."
    export CROSS_COMPILE
    pushd ${UBOOT_DIR} >/dev/null 2>&1
    make CROSS_COMPILE=${CROSS_COMPILE} ${UBOOT_CONFIG}
    if [ $? -ne 0 ] ; then
       echo "${SELF}: ${FUNCNAME}: error: uboot config make failed"
       return 1
    fi
    make 
    if [ $? -ne 0 ] ; then
       echo "${SELF}: ${FUNCNAME}: error: uboot make failed"
       return 1
    fi
    popd >/dev/null 2>&1

}

function do_tag() {

    echo "${FUNCNAME}: empty"

    return 0
}

function do_package() {

    echo "${FUNCNAME}: copying binaries to ${BINARIES}..."
    mkdir ${BINARIES}
    if [ $? -ne 0 ] ; then
        echo "${FUNCNAME}: ${BINARIES}: could not create directory..."
        return 1
    fi
    # Absolute path is required for the next steps
    BINARIES=$(readlink -e ${BINARIES}) 

    kernel_suffix=$(echo ${KERNEL_BRANCH} | sed -e 's/origin\///')

    cp ${BUILDROOT_DIR}/output/images/* ${BINARIES}
    cd ${KERNEL_DIR}
    cp arch/${ARCH}/boot/${KERNEL_IMAGE} ${BINARIES}/${KERNEL_IMAGE}-${kernel_suffix}
    make ARCH=${ARCH} INSTALL_MOD_PATH=${BINARIES} modules_install
    cp arch/${ARCH}/boot/${NIOS2_DTB} ${BINARIES}
    cd -
    cd ${BINARIES} 
    ln -s ${KERNEL_IMAGE}-${kernel_suffix} ${KERNEL_IMAGE}
    cd -
    cp ${UBOOT_DIR}/u-boot.bin ${BINARIES}

    return 0
}
