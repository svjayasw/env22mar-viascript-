#!/bin/bash 

# TODO
#  - add options

# max 5 days old
OLDEST=10

# DEF_BUILD_DIR
DEF_BUILD_DIR="/media/big_storage/nightly_build/"

if [ -z $1 ] ; then
    BUILD_DIR=${DEF_BUILD_DIR}
else
    BUILD_DIR="$1"
fi

echo $(basename $0): cleaning up old build ${OLDEST} days old
find ${BUILD_DIR}/14*.*.* -maxdepth 0 -type d -mtime +${OLDEST} 2>/dev/null | xargs -n1 rm -rf

# clean up any broken links
find ${BUILD_DIR}/* -maxdepth 0 -type l | while read link ; do
    readlink -e $link >/dev/null 2>&1 
    if [ $? -ne 0 ] ; then 
        echo link $link broken 
        rm $link 
    fi
done

