# callbacks that download files

CALLBACK_FILE=callbacks_download

# varibales
# angstrom's repo 
ANGSTROM_REPO=gitolite@at-git:angstrom-socfpga
ANGSTROM_BRANCH=origin/socfpga-1.0
ANGSTROM_TARGET=angstrom_clone
ANGSTROM_CONFIG=~/.oe/environment-angstromv2012.12
ANGSTROM_SOCFPGA_IMAGE=console-image

# GIT Library
source ${LIB_PATH_NIGHTLY}/libgit.sh

function do_init() {
set -x
    echo "${FUNCNAME}: info: starting clone of Angstrom's tree"
    clone_git_repo ${ANGSTROM_REPO} ${ANGSTROM_BRANCH} ${ANGSTROM_TARGET}
    if [ $? -ne 0 ] ; then
        echo "${FUNCNAME}: clone_git failed for ANGSTROM"
        return 1
    fi

    rm -f ${ANGSTROM_CONFIG} &&  echo "${FUNCNAME}: warning: ${ANGSTROM_CONFIG}: file removed"

    cd -

    return 0

}

function do_download() {

    local oebb=./oebb.sh
    echo    "${FUNCNAME}: info: starting the download"

    cd ${ANGSTROM_TARGET}
    echo -e "                 - configuring"
    MACHINE=${MACHINE} ${oebb} config ${MACHINE}
    if [ $? -ne 0 ] ; then
        echo "${FUNCNAME}: error: failed to config for ${MACHINE}"
        return 1
    fi

    echo -e "                 - updating"
    MACHINE=${MACHINE} ${oebb} update
    if [ $? -ne 0 ] ; then
        echo "${FUNCNAME}: error: failed to update"
        return 1
    fi

    echo -e "                 - downloading ${ANGSTROM_SOCFPGA_IMAGE}"
    source ${ANGSTROM_CONFIG}
    bitbake -c fetchall console-image
    if [ $? -ne 0 ] ; then
        echo "${FUNCNAME}: error: failed to download"
        return 1
    fi

    bitbake -c fetchall virtual/kernel
    if [ $? -ne 0 ] ; then
        echo "${FUNCNAME}: error: failed to download the kernel"
        return 1
    fi

    bitbake -c fetchall virtual/bootloader
    if [ $? -ne 0 ] ; then
        echo "${FUNCNAME}: error: failed to download the bootloader"
        return 1
    fi


    cd -
    return 0

}

# do_build actually downloads only
function do_build() {

    do_download 
    return $?

}

function do_tag()  { 

    local tag=${1}

    cd ${TARGET}
    
}
