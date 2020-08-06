# callbacks that implement build from GIT
# no OE, no recipe, plain build

# varibales

# KERNEL_REPO
TARGET=uboot_clone
BINARIES=binaries/

# libraries
source ${LIB_PATH_NIGHTLY}/libgit.sh
source ${LIB_PATH_NIGHTLY}/libtag.sh

# tools
## EEEEK, ugly! Add to PATH
MKPIMAGE=/opt/altera/13.1/embedded/host_tools/altera/mkpimage/mkpimage
SD_IMAGER=$(which make_sdimage.py)
PRELOADER_IMG="u-boot-spl-${MACHINE}.img"

TAGS_REPO="git://at-git/linux-tags"
TAGS_BRANCH=${TAGS_BRANCH:-"master"}   
TAGS_TARGET="$(pwd)/tags_list"

BUILD_BASE_DIR=$(pwd)

function check_vars() {

    local value
    for var in CROSS_COMPILE ARCH UBOOT_BRANCH UBOOT_REPO UBOOT_CONFIG; do 
        value=$(eval echo \$$var)
        if [ -z ${value} ] ; then
            echo "${FUNCNAME}: ${var}: error: not set."
            return 1
        fi
    done

    return 0
}

function do_init() {
set -x
    local tagref=${1}
    local uboot_tag
    
    echo "@@@@@@@@ " $(pwd)
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
    
    echo "${FUNCNAME}: info: cloning u-boot..."
    clone_git_repo ${UBOOT_REPO} ${UBOOT_BRANCH} ${TARGET}
    if [ $? -ne 0 ] ; then
        echo "${FUNCNAME}: clone_git failed"
        return 1
    fi

    echo "@@@@@@@@ " $(pwd)
    uboot_tag=$(get_tag_for_repo $(get_repo_from_url ${UBOOT_REPO}) $(simplify_branch_name ${UBOOT_BRANCH}))
    rebase_repo_to_tag ${TARGET} ${uboot_tag}
    if [ $? -ne 0 ] ; then
        echo "${FUNCNAME}: error: could not reset the uboot tree to ${uboot_tag}"
        return 1
    fi

    if [ "${UBOOT_PATCH}" != "" ] ; then
        cd ${TARGET}
        echo "@@@@@@@@ " $(pwd)
        for p in $(echo ${UBOOT_PATCH} | sed 's/,/ /g') ; do
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
set -x
    echo "${FUNCNAME}: info: buildling the uboot"
    export CROSS_COMPILE

    cd ${TARGET}
    make -j$((2*$(get_num_cpus))) CROSS_COMPILE=${CROSS_COMPILE} ${UBOOT_CONFIG}
    if [ $? -ne 0 ] ; then
        echo "${FUNCNAME}: error: failed to apply the configuration ${UBOOT_CONFIG}"
        return 1
    fi

    make -j$((2*$(get_num_cpus))) CROSS_COMPILE=${CROSS_COMPILE}
    if [ $? -ne 0 ] ; then
        echo "${FUNCNAME}: error: failed to build"
        return 1
    fi

    echo "@@@@@@@@ " $(pwd)
    # Post process the preloader
    ${MKPIMAGE} -o ${PRELOADER_IMG} spl/u-boot-spl.bin
    if [ $? -ne 0 ] ; then
        echo "${FUNCNAME}: error: failed to create the preloader image"
        return 1
    fi

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
    BINARIES=$(readlink -e ${BINARIES})




    cd ${TARGET}
    for binary in u-boot.bin u-boot.img System.map u-boot.map spl/u-boot-spl spl/u-boot-spl.bin ${PRELOADER_IMG} ; do
        echo "${FUNCNAME}: info: cp'ing ${binary}..."
        cp ${binary} ${BINARIES}
    done 


    case "${PACKAGING}" in
      SOF)
            if ! do_sof "${BINARIES}" spl.bin ; then
               "echo complain"
            fi
            ;;
      *)
            echo "error: ${PACKAGING}: unsupported"
            return 1
            ;;
            
     esac 


    return 0
}
