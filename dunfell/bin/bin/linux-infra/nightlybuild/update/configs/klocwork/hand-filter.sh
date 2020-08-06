#!/bin/bash

SELF=$(basename $0)

# Do the post processing for linux-socfpga projects
if [ ! -f '/.dockerenv' ]; then
    echo "$SELF: run script in a container.  For development purposes only."
    exit 1
fi

export WORKDIR=/home/build/code
export BUILD_BASE_DIR=${WORKDIR}/build
rm -rf $BUILD_BASE_DIR
mkdir $BUILD_BASE_DIR

export LIB_PATH_NIGHTLY=${WORKDIR}/linux-infra/nightlybuild/update/lib
export SOURCE_CLONE=${WORKDIR}/linux-socfpga

#-------------------------------------------------------------------------------------
cd ${SOURCE_CLONE} || exit 0

export raw_result_file="${WORKDIR}/linux-socfpga"/$(ls -tr klocwork-* | tail -1)
export KW_LOG_FILE="${BUILD_BASE_DIR}/kw-results-raw.txt"
ln -rs "${raw_result_file}" "${KW_LOG_FILE}"

#-------------------------------------------------------------------------------------
cd ${BUILD_BASE_DIR}
source ${WORKDIR}/config-kw.sh
source ${WORKDIR}/linux-infra/nightlybuild/update/configs/klocwork/callbacks-kw-linux-socfpga.sh
time do_package
