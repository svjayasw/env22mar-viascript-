#!/bin/bash 

# READ
#! - this script relies on scp to copy the flag from a build server
#!   to the file server. Make sure proper public SSH keys are registered
#!   on the build server(s)
# Internals
SELF=$(basename $0)

# constants
# TODO: move these to a common location, since the same
#! values are used by other scripts...
CONST_RETRY_MAX_COUNT=10

# returns 0 if the flag has been raised
#! Input
#!  $1 = location of the flag, SSH URL
#! Output
#!  stderr for errors
#! Return
#!  0 is flag is raised, 1 if not
function is_flag_raised() {
    local flag="$1" 

    scp ${flag} /tmp 1>/dev/null 2>&1
    if [ $? -ne 0 ] ; then
        return 1
    fi

    return 0
}

# help!
function usage() {

    echo "Usage: ${SELF} flag server dir dest [-h]"
    echo " -h: prints this message"

    return
}

# get the list of latest Angstrom builds on server
function list_latest_builds() {

    local server="$1"
    local remote_dir="$2"

    ssh ${server} find ${remote_dir} -type l -maxdepth 1 2>/dev/null | grep "angstrom"
    if [ $? -ne 0 ] ; then
        return 1
    fi

    return 0
}

function clean_up_dest() {

    local dest="$1"

    rm -rf ${dest}
    mkdir ${dest}
    if [ $? -ne 0 ] ; then
        echo "${SELF}: ${FUNCNAME}: error: could not clean up ${dest}..."
        exit 1
    fi

    return 0
}

function copy_blob() {

    local server="$1"
    local blob="$2"
    local local_dir="$3"
    local exclude_list="$4" # exclude_list is a regex

    local list=$(ssh ${server} find ${blob}/binaries -type f -maxdepth 1 | egrep -v -e '${exclude_list}')
    for item in ${list} ; do
       scp -r ${server}:${item} ${local_dir} >/dev/null 2>&1
    done
}

# copy blobs to this machine
function copy_blobs() {

    local server="$1"
    local remote_dir="$2"
    local local_dir="$3"
    
    # clean up destination directory please
    clean_up_dest ${local_dir}

    # latest_builds= list of absolute paths, links
    latest_builds=$(list_latest_builds ${server} ${remote_dir})
    # for each link, we need to copy the directory to $DEST
    for build in ${latest_builds} ; do
        link=$(basename ${build})
        echo "${SELF}:${FUNCNAME}: info: processing ${link}..."
        # get the absolute path of links's target
        # atarget = absolute path
        # target = relative path
        atarget=$(ssh ${server} readlink -e ${build})
        if [ $? -ne 0 ] ; then
            echo "${SELF}: ${FUNCNAME}: could not readlink ${build}..."
            return 1
        fi
        target=$(basename ${atarget})
        # now we copy
        mkdir -p ${local_dir}/${target}
        copy_blob ${server} ${atarget} ${local_dir}/${target} "rfs"
        if [ $? -ne 0 ] ; then
            echo "${SELF}: ${FUNCNAME}: error: failed to copy ${atarget}"
            return 1
        fi

        # create local symlink
        ln -s ${local_dir}/${target} ${local_dir}/${link}
        if [ $? -ne 0 ] ; then
            echo "${SELF}: ${FUNCNAME}: ln: failed"
            return 1
        fi
    done

    return 0
}

if [ "$1" == "-h" ] ; then
    usage
    exit 0
fi

FLAG="$1"
SERVER="$2"
DIR="$3"
DEST="$4"
if [ -z ${DIR} -o -z ${DEST} ] ; then
    usage
    exit 1
fi

if [ -z ${FLAG} -o -z ${SERVER} ] ; then
    usage
    exit 1
fi

retry_count=0
while [ 1 ] ; do

    echo "${SELF}: info: checking flag is present (attempt ${retry_count})"
    if is_flag_raised ${SERVER}:${DIR}/${FLAG} ; then
        break
    fi
    retry_count=$(( ${retry_count} + 1 ))
    if [ ${retry_count} -eq ${CONST_RETRY_MAX_COUNT} ] ; then
        echo "${SELF}: error: timeout on flag"
        exit 1
    fi
    sleep 5

done

# now we can copy the binaries over here
copy_blobs ${SERVER} ${DIR} ${DEST}
if [ $? -ne 0 ] ; then
    echo ${SELF}: failed to copy builds from ${SERVER}
    exit 1
fi

exit 0

