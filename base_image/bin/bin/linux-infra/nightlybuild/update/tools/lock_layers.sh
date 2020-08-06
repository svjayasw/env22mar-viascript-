#!/bin/bash

# internals
SELF=$(basename $0)
SELFDIR=$(dirname $0)
TMP="clone_target"


# functions
function usage() {

    echo "usage: ${SELF} [-h] <layers file>"
    echo "-h   : this message"

    echo "this script updates the Angstrom layers file, by replacing references"
    echo "to HEAD by the corresponding actual GIT commit ID"
}

function clone_git_repo() {

    local repo="$1"
    local branch="${2:-master}"
    local dir="${3:-clone}"
    local local_branch="${4:-blah}"

    git clone "${repo}" ${dir}
    if [ $? -ne 0 ] ; then
        echo "${SELF}: ${FUNCNAME}: error: could not clone repo (${repo})"
        return 1
    fi
    if [ "${branch}" == "master" ] ; then
        return 0
    fi

    cd ${dir}
    git checkout -b ${local_branch} ${branch} 2>&1 
    if [ $? -ne 0 ] ; then
        echo "${SELF}: ${FUNCNAME}: error: could not checkout branch ${branch}"
        return 1
    fi
    cd -

    return 0

}

function clean_up() {

    rm -rf ${TMP}

}

function trap_clean_up() {

    echo "${SELF}: ${FUNCNAME}: info: removing ${TMP}"
    clean_up
}

function get_head_commit() {

    local clone_dir="$1"
    local head_commit 
    local err

    pushd ${clone_dir} >/dev/null 2>&1
    head_commit=$(git log --oneline --no-abbrev-commit -n1 | awk ' { print $1 } ')
    err=$?
    popd >/dev/null 2>&1

    echo ${head_commit}

    return ${err}
}

function lock_layers () {

    local layers_file="$1"

    cat ${layers_file} | while read line ; do
        repo=$(echo ${line} | awk -F, ' { print $1 } ')
        url=$(echo ${line} | awk -F, ' { print $2 } ')
        branch=$(echo ${line} | awk -F, ' { print $3 } ')
        commit=$(echo ${line} | awk -F, ' { print $4 } ')

        if [ "${commit}" == "HEAD" ] ; then

            echo "${SELF}: ${FUNCNAME}: info: processing ${repo} (${url}, ${branch})"

            clone_git_repo ${url} "origin/${branch}" ${TMP} >/dev/null 2>&1
            if [ $? -ne 0 ] ; then
               echo "${SELF}: ${FUNCNAME}: failed to clone ${repo} (${url}, ${branch})"                  
               return 1
            fi
            
            head_commit=$(get_head_commit ${TMP})
            if [ $? -ne 0 ] ; then
                echo "${SELF}: ${FUNCNAME}: error: failed to get head commit for ${repo}"
                return 2
            fi

            sed -ri 's#('${repo},${url},${branch}'),HEAD#\1,'${head_commit}'#' ${layers_file}
            if [ $? -ne 0 ] ; then
               echo "${SELF}: ${FUNCNAME}: error failed to update commit for ${repo}"
               return 3
           fi

           clean_up
        fi
    done

    return 0
}

# script starts here
if [ -z $1 ] || [[ "$1" =~ ^- ]] ; then
    usage
    exit
fi

LAYERS_FILE="$1"
if [ ! -e ${LAYERS_FILE} ] ; then
    echo "${SELF}: ${LAYERS_FILE}: no such file"
    exit 1
fi

trap trap_clean_up EXIT
lock_layers ${LAYERS_FILE} 
if [ $? -ne 0 ] ; then
    echo "${SELF}: error: failed to lock layers..."
    exit 2
fi


