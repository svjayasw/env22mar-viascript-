# QEMU Nadder build

CALLBACK_FILE="callbacks_nadder_qemu.sh"

# Vars
QEMU_CLONE_TARGET="qemu-clone"
QEMU_BINARY_DIR="binaries/"
QEMU_ARM=./arm-softmmu/qemu-system-arm

# Libs
source ${LIB_PATH_NIGHTLY}/libgit.sh

# Callbacks
function check_vars() {

    local value
    for var in QEMU_REPO QEMU_BRANCH ; do 
        value=$(eval echo \$$var)
        if [ -z ${value} ] ; then
             echo "${FUNCNAME}: ${var}: error: not set."
             return 1
        fi
    done

   return 0
}

function do_init() {

    echo "${FUNCNAME}: info: cloning GIT repos..." 
    if ! check_vars ; then
        echo "${FUNCNAME}: error: please check your configuration file"
        return 1
    fi

    clone_git_repo ${QEMU_REPO} ${QEMU_BRANCH} ${QEMU_CLONE_TARGET}
    if [ $? -ne 0 ] ; then
        echo "${FUNCNAME}: clone_git failed"
        return 1
    fi

    echo "${FUNCNAME}: info: done cloning"

    return 0
}

function get_num_cpus() {

    echo $(lscpu | egrep "^CPU\(s\):" | awk -F: ' { print $2 } ' | sed -e 's/^ *//')

    return
}

function do_build() {

    echo "${FUNCNAME}: info: start building..."
    cd ${QEMU_CLONE_TARGET}
    ./configure
    if [ $? -ne 0 ] ; then
        echo "${FUNCNAME}: error: failed to configure."
        return 1
    fi

    make -j$((2*$(get_num_cpus)))
    if [ $? -ne 0 ] ; then
        echo "${FUNCNAME}: error: failed to make."
        return 1
    fi

    cd -
}

function do_tag() {

    local tag=${1}

#    cd ${TARGET}
#
#    tag_repo_and_push ${tag}
#    if [ $? -ne 0 ] ; then
#        echo "${FUNCNAME}: error: tailed to tag"
#        return 1
#    fi
#
#    cd -
    
    return 0
}

function do_package() {
    local cwd=$(pwd)

    echo "${FUNCNAME}: info: start copy..."

    mkdir ${QEMU_BINARY_DIR} 
    if [ $? -ne 0 ] ; then
       echo "${FUNCNAME}: error: could not create bin directory"
       return 1
    fi

    cd ${QEMU_CLONE_TARGET}
    # cp stuff here 
    cp ${QEMU_ARM}  ${cwd}/${QEMU_BINARY_DIR}
    if [ $? -ne 0 ] ; then
        echo "${FUNCNAME}: error: failed to copy ${QEMU_ARM}."
        return 1
    fi

    echo "${FUNCNAME}: info: done with copy."

    cd ${cwd}

    return 0
}
