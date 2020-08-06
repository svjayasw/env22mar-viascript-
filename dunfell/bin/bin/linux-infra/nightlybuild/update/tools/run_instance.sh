#!/bin/bash

SELF=$(basename $0)

NAME=vagrant_hashicorp_precise64
BOX=${NAME}.box
V_REPO=gitolite@at-git:vagrant
V_BRANCH=master
V_BOX_SERVER="137.57.160.198"
BOX_URL="http://${V_BOX_SERVER}/vagrant/${BOX}"

#TODO: make this robust
INSTANCE="${1}"

function print() {

    local message="${1}"
    local level=${2:-"info"}

    echo "${SELF}: ${level}: ${message}"

    return 0
}


print "setting up instance ${INSTANCE} for VM ${NAME}"
print "creating dir ${INSTANCE}"
mkdir -p ${INSTANCE}
if [ $? -ne 0 ] ; then
    print "could not create directory ${INSTANCE}" "error"
    exit 1
fi

pushd ${INSTANCE} >/dev/null 2>&1

print "getting default vagrant config file"
git clone ${V_REPO} config
if [ $? -ne 0 ] ; then
    print "could not clone from ${V_REPO}" "error"
    popd >/dev/null 2>&1
    exit 1
fi

pushd config >/dev/null 2>&1
print "updating the vagrant config file for instance ${INSTANCE}"
sed -i -r 's#(config\.vm\.box = ).*#\1"'${INSTANCE}'"\nconfig.vm.box_url = "'${BOX_URL}'"#' Vagrantfile
if [ $? -ne 0 ] ; then
    print "could not update config file..." "error"
    popd >/dev/null 2>&1
    popd >/dev/null 2>&1
    exit 1
fi

print "starting instance"
vagrant up

popd >/dev/null 2>&1
popd >/dev/null 2>&1
