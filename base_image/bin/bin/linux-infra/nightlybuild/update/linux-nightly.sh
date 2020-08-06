#!/bin/bash  

#  TODO
#!  add logging

# internals
SELF=$(basename $0)
SELF_DIR=$(readlink -e $(dirname $0))

# constants

# default values for variables
LOG_FILE_DEFAULT="stdout"
DEBUG_LEVEL_DEFAULT=0
WORKDIR_DEFAULT=.
PATH_NIGHTLY=${SELF_DIR}/tools:${SELF_DIR}/../../tools
export PATH=${PATH}:${PATH_NIGHTLY}
export BASEDIR=$(readlink -f ${SELF_DIR})

# environment
if [ -z ${LIB_PATH_NIGHTLY} ] ; then
    export LIB_PATH_NIGHTLY=$(readlink -f ${SELF_DIR}/lib)
fi

if [ -z ${CONFIG_PATH_NIGHTLY} ] ; then
    export CONFIG_PATH_NIGHTLY=$(readlink -f ${SELF_DIR}/configs)
fi

# update PATH
export PATH=${PATH}:${PATH_NIGHTLY}

# include libraries
source ${LIB_PATH_NIGHTLY}/logger.sh
source ${LIB_PATH_NIGHTLY}/linux-nightly-defaults.sh
source ${LIB_PATH_NIGHTLY}/libtag.sh

# functions
function usage() {
    echo "usage: ${SELF} -c cfg [-w dir] [-l log] [-d] [-h]"
    echo "-c cfg: configuration file. required. no default"
    echo "-f cbs: callbacks. reqiored. no default"
    echo "-l log: log file. optional. no default. Path relative to -w"
    echo "-w dir: working directory. Default: ${WORKDIR_DEFAULT}"
    echo "-t    : tag reference to use for the build process."
    echo "-d    : debug messages." 
    echo "-h    : this help message."
    echo 
    echo "      ${SELF} -e"
    echo "-e    : dump the environment"

}

#  sources the configuration file and checks for the mandatory variables
#! input
#!  $1=configuration file
#! output
#!  environment updated
#! return
#!  non-zero on sucksess, 0 on success
function read_and_check_config() {

    local cfg_file="$1"
    local callbacks="$2"

    # TODO: redirect to log file
    source ${cfg_file}
    if [ $? -ne 0 ] ; then
      log  "${FUNCNAME}: error: failed to source config file (${cfg_file})"
      return 1
    fi

    # check for mandatory env settings
    if [ -z "${MACHINE}" ] ; then
        log  "${FUNCNAME}: error: MACHINE must be set"
        return 1
    fi

    if [ -z "${RELEASE_NAME}" ] ; then
        log  "${FUNCNAME}: error: RELEASE_NAME must be set"
        return 1
    fi

    if [ -z "${PACKAGING}" ] ; then
        log  "${FUNCNAME}: error: PACKAGING must be set"
        return 1
    fi

    if [ ! -e ${callbacks} ] ; then
        log  "${FUNCNAME}: error: ${callbacks}: no such file"
        return 1
    fi

    # redirect output
    source ${callbacks} # | log_in 
    if [ $? -ne 0 ] ; then
        log  "${FUNCNAME}: error: could not source CALLBACKS"
        return 1
    fi
    if ! check_for_mandatory_funcs ; then
	log "${FUNCNAME}: error: could not check for all mandatory functions"
        return 1
    fi

    return 0
}

function is_func() 
{ 
    tmp=$(type -t ${1})
    [ "${tmp}" == "function" ] && return 0
    return 1
}

function fexists() {

    is_func $1
    return $?

}

function check_for_mandatory_funcs() {

# TODO: change to a loop
    if ! is_func do_init ; then
        log "${FUNCNAME}: error: do_init: mandatory function not found"
        return 1
    fi


    if ! is_func do_build ; then
        log "${FUNCNAME}: error: do_build: mandatory function not found"
        return 1
    fi

    if ! is_func do_package ; then
        log "${FUNCNAME}: error: do_package: mandatory function not found"
        return 1
    fi


    return 0
}

function do_link_latest() {

    local link_name=$1
    local target_name=$2

    rm -f ${link_name}
    ln -s ${target_name} ${link_name}
    if [ $? -ne 0 ] ; then
        log "${FUNCNAME}: error: could not create link!"   
        return 1
    fi

    return 0 
}

#  this function will sequence the build by calling each callback in sequence
#! input
#!  ????
#! output
#!  ????
#! return
#!  0 on success, non-zero on success
function sequence_build_process() {

    local working_dir="$1"
    local build_dir=build
    local cfg_file=$2
    local callbacks=$3
    local log_file=$4
    local tagref=${5}

    # If this is run in a container and uid of host user isn't the same as uid of the
    # user in the container (i.e. 1000) then there can be permissions problems.
    # The workaround is to 'chmod 777' the directory on the host.
    if [ ! -w "${working_dir}" ]; then
        log "${FUNCNAME}: error: working dir is not writable by me (${working_dir})"
        log "${FUNCNAME}: user may need to do this: chmod 777 ${working_dir}"
        return 1
    fi

    cd ${working_dir}

    # If the permissions are not 777 and this is run in a container, it
    # could be hard to clean up without sudo (if uid of host user isn't
    # the same as uid of the user in the container, i.e. 1000).
    mkdir -m 777 ${build_dir}
    if [ $? -ne 0 ] ; then
        log "${FUNCNAME}: error: could not create build directory...."
        return 1
    fi
    cd ${build_dir}

    # log_file=$(readlink -f ${working_dir}/${build_dir}/${log_file})

    # enable logging
    enable_log -f ${log_file}
    
    # build information
    echo -e "${FUNCNAME}: info: working dir ${working_dir}" | tee >(log_in) 
    echo -e "${FUNCNAME}: info: running build ${build_dir}" | tee >(log_in) 

    # source the config file and check for mandatory settings
    read_and_check_config ${cfg_file} ${callbacks}
    if [ $? -ne 0 ] ; then
        log  "error: ${build_dir}: could not set environment"
        exit -2
    fi

    log "${FUNCNAME}: info: running do_init()..."
    do_init ${tagref} 2>&1 | log_in
    if [ ${PIPESTATUS[0]} -ne 0 ] ; then
        log "${FUNCNAME}: error: ${build_dir}: do_init failed"
        return 1
    fi

    log "${FUNCNAME}: info: running do_build()..."
    do_build ${tagref} 2>&1 | log_in
    if [ ${PIPESTATUS[0]} -ne 0 ] ; then
        log "${FUNCNAME}: error: ${build_dir}: do_build failed"
        return 1
    fi

    do_package ${tagref} 2>&1 | log_in
    if [ ${PIPESTATUS[0]} -ne 0 ] ; then
        log "${FUNCNAME}: ${build_dir}: error: do_package failed"
        return 1
    fi

    if fexists do_notify ; then
        do_notify 2>&1 | log_in
    fi

    cd ${working_dir}

    do_link_latest ${LATEST_NAME} ${build_dir}
    if [ $? -ne 0 ] ; then
        log "${FUNCNAME}: error: ${build_dir}: do_link_latest failed"
        return 1
    fi

    echo "${FUNCNAME}: info: ${build_dir}: build successful" | tee >(log_in)

    disable_log 

    return 0
}

function dump_env() {

    echo    "${SELF}: environment:"
    echo -e "\tPATH:${PATH}"
    echo -e "\tLIB_PATH_NIGHTLY:${LIB_PATH_NIGHTLY}"
    echo -e "\tCONFIG_PATH_NIGHTLY:${CONFIG_PATH_NIGHTLY}"
    echo -e "\tBASEDIR:${BASEDIR}"

    return 0
}

# variables
LOG_FILE=${LOG_FILE_DEFAULT}
DEBUG_LEVEL=${DEBUG_LEVEL_DEFAULT}
CFG_FILE=""
WORKDIR=${WORKDIR_DEFAULT}
CALLBACKS=""

# script starts here
if [ $# -eq 0 ]; then
    usage
    exit 0
fi

while [ $# -gt 0 ] ; do
    case $1 in
        -h) usage; exit ;;
        -c) CFG_FILE=$(readlink -f $2) ; shift ;;
        -e) dump_env ; exit 0 ;;
        -f) CALLBACKS=$2 ; shift ;;
        -d) DEBUG_LEVEL=$2 ; shift ;;
        -l) LOG_FILE=$2 ; shift ;;
        -w) WORKDIR=$2 ; shift ;;
        -t) TAGREF=$2 ; shift ;;
        *)  echo "error: $1: unknown option" ; usage ; exit -1 ;;
    esac
    shift
done

# create work space
if [ -z ${WORKDIR} ] ; then
    echo "${SELF}: error: WORKDIR not set. Use -w"
    usage
    exit -1
fi
if [ ! -e ${WORKDIR} -o ! -d ${WORKDIR} ] ; then
    echo "${SELF}: error: ${WORKDIR}: no such directory"
    exit -1
fi

# check what the user specified
if [ -z "${CFG_FILE}" ] ; then
    echo "error: a configuration file must be specified"
    usage
    exit -1
else
    if [ ! -e "${CFG_FILE}" ] ; then
        echo  "error: ${CFG_FILE}: no such file"
        exit -2
    fi
fi

if [ -z "${TAGREF}" ] ; then
    echo "info: no tag specified"
fi

sequence_build_process $(readlink -f ${WORKDIR}) $(readlink -f ${CFG_FILE}) $(readlink -f ${CALLBACKS}) ${LOG_FILE} ${TAGREF}
if [ $? -ne 0 ] ; then
    log "error: failure with sequence_build_process"
    cd ${ORIGINDIR}
    exit -3
fi

 
# disable logging
disable_log

