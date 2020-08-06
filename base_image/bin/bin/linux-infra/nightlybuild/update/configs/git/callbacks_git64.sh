# callbacks that implement build from GIT
# no OE, no recipe, plain build

CALLBACK_FILE=rt_callbacks

# varibales

# KERNEL_REPO
TARGET=kernel_clone
KERNEL_IMAGE=Image
BINARIES=bin/
export BUILD_BASE_DIR=$(pwd)

# libraries
source ${LIB_PATH_NIGHTLY}/libgit.sh
source ${LIB_PATH_NIGHTLY}/libtag.sh

TAGS_REPO="git://at-git/linux-tags"
TAGS_BRANCH=${TAGS_BRANCH:-"master"}   
TAGS_TARGET="$(pwd)/tags_list"

function check_vars() {

    local value
    for var in CROSS_COMPILE ARCH KERNEL_CONFIG KERNEL_BRANCH KERNEL_REPO; do 
        value=$(eval echo \$$var)
        if [ -z ${value} ] ; then
            echo "${FUNCNAME}: ${var}: error: not set."
            return 1
        fi
    done

    return 0
}

function do_init() {

    local tagref=${1}
    local kernel_tag

    echo "${FUNCNAME}: info: checking environment..."
    if ! check_vars ; then
        echo "${FUNCNAME}: error: please check your configuration file"
        return 1
    fi
    
    echo "${FUNCNAME}: info: init'ing tags..."
    do_init_tags ${TAGS_REPO} ${TAGS_BRANCH} ${tagref}
    if [ $? -ne 0 ] ; then
        echo "${FUNCNAME}: error: could not initialize tag manager"
        return 1
    fi
    
    echo "${FUNCNAME}: info: cloning kernel..."
    clone_git_repo ${KERNEL_REPO} ${KERNEL_BRANCH} ${TARGET}
    if [ $? -ne 0 ] ; then
        echo "${FUNCNAME}: clone_git failed"
        return 1
    fi

    kernel_tag=$(get_tag_for_repo $(get_repo_from_url ${KERNEL_REPO}) $(simplify_branch_name ${KERNEL_BRANCH}))
    rebase_repo_to_tag ${TARGET} ${kernel_tag}
    if [ $? -ne 0 ] ; then
        echo "${FUNCNAME}: error: could not reset the kernel tree to ${angstrom_tag}"
        return 1
    fi
set -x
    if [ "${KERNEL_PATCH}" != "" ] ; then
        cd ${TARGET}

        for p in $(echo ${KERNEL_PATCH} | sed 's/,/ /g') ; do
            p=${BASEDIR}/configs/git/${p}
            if [ ! -e ${p} ] ; then
	        echo "${FUNCNAME}: ${p}: no patch found"
                return 1
            fi
            
	    patch -p1 < ${p}
            if [ $? -ne 0 ] ; then
		echo "${FUNCNAME}: error: could not apply ${p}"
                return 1
            fi
        done

        cd -
    fi

    return 0

}

function get_num_cpus() {

    echo $(lscpu | egrep "^CPU\(s\):" | awk -F: ' { print $2 } ' | sed -e 's/^ *//')

    return
}
 
function do_build() {

    echo "${FUNCNAME}: info: buildling the kernel"
    cd ${TARGET}
    make ARCH=${ARCH} ${KERNEL_CONFIG}
    if [ $? -ne 0 ] ; then
        echo "${FUNCNAME}: error: failed to pick the default configuration"
        return 1
    fi

    make -j$((2*$(get_num_cpus))) ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} ${KERNEL_IMAGE}
    if [ $? -ne 0 ] ; then
        echo "${FUNCNAME}: error: failed to build the kernel"
        return 1
    fi
    make -j$((2*$(get_num_cpus))) ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} modules
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} dtbs
    cd -

    return 0

}

function do_tag()  { 

    local tag=${1}
 
    echo "${FUNCNAME}: info: nada"

    return 0
}

function do_package() {

    local cwd=$(pwd)

    mkdir ${BINARIES} 
    if [ $? -ne 0 ] ; then
       echo "${FUNCNAME}: error: could not create bin directory"
       return 1
    fi

    cd ${TARGET}

    krel=$(make ARCH=${ARCH} kernelrelease)
    cp arch/${ARCH}/boot/${KERNEL_IMAGE} ${cwd}/${BINARIES}/${KERNEL_IMAGE}-${krel}-${ARCH}
    ln -s ${cwd}/${BINARIES}/${KERNEL_IMAGE}-${krel}-${ARCH} ${cwd}/${BINARIES}/${KERNEL_IMAGE}
    cp vmlinux ${cwd}/${BINARIES}/vmlinux-${krel}-${ARCH} 
    ln -s ${cwd}/${BINARIES}/vmlinux-${krel}-${ARCH} ${cwd}/${BINARIES}/vmlinux
    make INSTALL_MOD_PATH=${cwd}/${BINARIES}/ modules_install
    cp arch/${ARCH}/boot/dts/altera/*.dtb ${cwd}/${BINARIES}
    cd ${cwd}/${BINARIES}
    tar cf modules.tar lib
    cd ${cwd}

    return 0
    
}

