CALLBACK_FILE="callbacks_klocwork_intel_rsu"

# libraries
source ${LIB_PATH_NIGHTLY}/libgit.sh
source ${LIB_PATH_NIGHTLY}/kw-common.sh

# Open Source Library used for building intel-rsu
ZLIB="zlib-1.2.11"

# Download zlib and build it.  We didn't write it, so it's not part of the scan.
function set_up_zlib() {
    local threads="$(nproc)"
    echo "Downloading and building ${ZLIB}"
    pushd ${BUILD_BASE_DIR}
    wget https://zlib.net/${ZLIB}.tar.gz
    tar xfz ${ZLIB}.tar.gz
    cd ${ZLIB}/
    CC=${CROSS_COMPILE}gcc ./configure
    make -j${threads}
    cp libz.so ${SOURCE_CLONE}/lib/
    cp zlib.h ${SOURCE_CLONE}/include/
    cp zconf.h ${SOURCE_CLONE}/include/
    popd
    rm -rf ${BUILD_BASE_DIR}/${ZLIB}.tar.gz ${BUILD_BASE_DIR}/${ZLIB}/
}

function __build() {
    local threads="$(nproc)"

    cd ${SOURCE_CLONE}/lib
    make clean
    cd ${SOURCE_CLONE}/example
    make clean

    cd ${SOURCE_CLONE}
    set_up_zlib ${SOURCE_CLONE}

    cd ${SOURCE_CLONE}/lib
    echo "${SELF}: ${FUNCNAME}: building intel-rsu/lib/"
    if ! kwshell make -j${threads} all ; then
	chmod -R 777 .kwlp .kwps
        echo "${SELF}: ${FUNCNAME}: failed"
        return 1
    fi

    cd ${SOURCE_CLONE}/example
    echo "${SELF}: ${FUNCNAME}: building intel-rsu/example/"
    if ! kwshell make -j${threads} all ; then
	chmod -R 777 .kwlp .kwps
        echo "${SELF}: ${FUNCNAME}: failed"
        return 1
    fi

    chmod -R 777 .kwlp .kwps
    return 0
}

function do_build() {
    local tagref=${1}
    echo "${FUNCNAME}..."
set -x
    cd ${SOURCE_CLONE}
    ARCH="arm64"
    CROSS_COMPILE="aarch64-linux-gnu-"

    # Generate file name for results file
    local kw_version="$(kwcheck --version | head -1 | egrep -o -e '\([0-9\.]*\)' | tr -d '()')"
    local scan_date="$(date +%F_%H%M%S)"
    local head="$(git log -n1 --pretty=format:%h)"
    local gcc_version="$(${CROSS_COMPILE}gcc -dumpversion)"
    local raw_result_file="klocwork-${kw_version}_intel-rsu_${ARCH}_gcc-${gcc_version}_${scan_date}_${head}.txt"

    export CROSS_COMPILE

    if ! __build ; then
       echo "${SELF}: ${FUNCNAME}: error: giving up"
       return 1
    fi

    # a single file name KW_LOG_FILE, pointing to the actual file
    cd ${SOURCE_CLONE}
    touch ${raw_result_file}
    chmod 777 ${raw_result_file}
    ln -rs "${raw_result_file}" "${KW_LOG_FILE}"

    if ! __kw_run | tee "${raw_result_file}" ; then
       echo "${SELF}: ${FUNCNAME}: error: giving up"
       return 1
    fi

    return 0
}

function do_package() {
    local kw_results_file="${BUILD_BASE_DIR}/kw-results-filtered.txt"
set -x
    remove_build_lines "${kw_results_file}"

    chmod 777 ${kw_results_file}

    return $?
}
