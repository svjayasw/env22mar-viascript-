#!/bin/bash 

# Internals
SELF=$(basename $0)
CWD=$(pwd)

# Layers file
CONST_SOURCE_DIR="sources"
if [ ! -d ${CONST_SOURCE_DIR} ] ; then
    echo "${SELF}: error: ${CONST_SOURCE_DIR}: no such directory" >&2
    exit 1
fi

cd ${CONST_SOURCE_DIR}
CONST_DEF_LAYERS="layers.txt" 
if [ ! -f ${CONST_DEF_LAYERS} ] ; then
    echo "${SELF}: error: ${CONST_DEF_LAYERS}: no such file" >&2
    exit 1
fi

list_of_layers_with_head=$(grep HEAD ${CONST_DEF_LAYERS})
if  [ -z "${list_of_layers_with_head}" ] ; then
    echo "${SELF}: warning: nothing found to be locked in ${CONST_DEF_LAYERS}" >&2
    exit 0
fi

for layer in ${list_of_layers_with_head} ; do
    echo "${SELF}: info: processing layer ${layer_name}"
    layer_name=$(echo ${layer} | awk -F, ' { print $1 } ')
    url=$(echo ${layer} | awk -F, ' { print $2 } ')
    version=$(echo ${layer} | awk -F, ' { print $3 } ')
    commit=$(echo ${layer} | awk -F, ' { print $4 } ')

    if [ ! -d ${layer_name} ] ; then
        (
          echo "${SELF}: error: ${layer_name}: no such directory"
          echo "${SELF}: error: make sure you run oebb.sh first!"
        ) >&2
        exit 1
    fi

    pushd ${layer_name} >/dev/null 2>&1
    lock_commit=$(git log -n 1 --oneline --no-abbrev-commit | awk ' { print $1 } ')
    popd #>/dev/null 2>&1

    sed -ri 's#('${layer_name}','${url}','${version}'),HEAD#\1,'${lock_commit}'#' ${CONST_DEF_LAYERS}
    if [ $? -ne 0 ] ; then
        echo "${SELF}: error: failed to update ${CONST_DEF_LAYERS} for ${layer} against ${lock_commit}." >&2
        exit 1
    fi
done
cd ${CWD}

echo "${SELF}: info: ${CONST_DEF_LAYERS} is ready to be committed"
