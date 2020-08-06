# Common code to include in klocwork callbacks files

# BUILD_BASE_DIR is created by linux-nightly.sh
#  == ${WORKDIR}/build
#  == /home/build/code/build
export BUILD_BASE_DIR=$(pwd)

export KW_SERVER="klocwork-jf25.devtools.intel.com"
export KW_SERVER_URL="https://${KW_SERVER}:8195"
export KW_PROJECT="${KW_SERVER_URL}/${PROJECT_NAME}"

export KW_LOG_FILE="${BUILD_BASE_DIR}/kw-results-raw.txt"

function check_vars() {

    local value
    for var in SOURCE_BRANCH SOURCE_REPO MACHINE SOURCE_CLONE; do
        value=$(eval echo \$$var)
        if [ -z ${value} ] ; then
            echo "${FUNCNAME}: ${var}: error: not set."
            return 1
        fi
    done

    return 0
}

function do_init() {
    local tagref=${1}

    echo "${FUNCNAME}: info: checking environment..."
    if ! check_vars ; then
        echo "${FUNCNAME}: error: please check your configuration file"
        return 1
    fi

    # check for token
    echo "${SELF}: ${FUNCNAME}: checking for..."
    echo -e "ltoken "
    if [ -f ~/.klocwork/ltoken ] ; then
       echo "[OK]"
    else
       echo "[NOT FOUND]"
       return 1
    fi

set -x
    if [[ ${SOURCE_REPO} =~ ^file: ]] ; then
	echo "running scan on existing repo at ${SOURCE_CLONE}"
    elif [ ! -d "${SOURCE_CLONE}" ]; then
	echo "running scan on cloned repo at ${SOURCE_CLONE}"
        clone_git_repo ${SOURCE_REPO} origin/${SOURCE_BRANCH} ${SOURCE_CLONE} ${SOURCE_BRANCH}
        if [ $? -ne 0 ] ; then
            echo "${FUNCNAME}: clone_git_repo failed"
            return 1
        fi
    else
	echo "cleaning cloned repo to scan at ${SOURCE_CLONE}"
        clean_git_repo ${SOURCE_CLONE}
        if [ $? -ne 0 ] ; then
            echo "${FUNCNAME}: update_git_repo failed"
            return 1
        fi

    	echo "updating cloned repo to scan at ${SOURCE_CLONE}"
        update_git_repo ${SOURCE_CLONE}
        if [ $? -ne 0 ] ; then
            echo "${FUNCNAME}: update_git_repo failed"
            return 1
        fi

    	echo "checking out branch ${SOURCE_BRANCH} on cloned repo to scan at ${SOURCE_CLONE}"
        checkout_git_repo_branch ${SOURCE_CLONE} origin/${SOURCE_BRANCH} ${SOURCE_BRANCH}
        if [ $? -ne 0 ] ; then
            echo "${FUNCNAME}: update_git_repo failed"
            return 1
        fi
    fi

    if [ ! -d "${SOURCE_CLONE}" ] ; then
        echo "${SELF}: ${FUNCNAME}: ${SOURCE_CLONE}: no such directory"
        return 1
    fi

    if [ ! -w "${SOURCE_CLONE}" ] ; then
        echo "${SELF}: ${FUNCNAME}: ${SOURCE_CLONE}: directory is not writable from container."
        return 1
    fi

    cd ${SOURCE_CLONE}
    rm -rf .kw*

    echo "${SELF}: kwcheck info:"
    kwcheck info
    echo
    echo "${SELF}: project is ${KW_PROJECT}"
    if ! kwcheck create --url "${KW_PROJECT}" ; then
        echo "${SELF}: ${FUNCNAME}: kwcheck: failed"
        return 1
    fi

    # Make it a bit easier to clean up .kwlp and .kwps
    chmod -R 777 .kwlp .kwps
    
    return 0
}

function __kw_run() {
    kwcheck run 2>&1
    ret=$?
    chmod -R 777 .kwlp .kwps
    return ${ret}
}

# Klocwork's raw results will have the build logging first, followed by the actual
# Klocwork scan results.  Find the first line of the scan results and delete all the
# build stuff that comes before it.
function remove_build_lines() {

    local kw_results_only_file="${1}"

    local first_results_line_num="$(grep -n -e '^1 (Local)' ${KW_LOG_FILE} | cut -d: -f1 )"
    local last_build_line=$((${first_results_line_num} - 1))

    sed 1,${last_build_line}d "${KW_LOG_FILE}" > "${kw_results_only_file}"
    ret=$?

    if [ $ret -ne 0 ]; then
	echo "${FUNCNAME}: error: failed to truncate ${KW_LOG_FILE}"
    fi

    return $ret
}
