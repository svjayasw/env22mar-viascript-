CALLBACK_FILE="callbacks_klocwork_linux_socfpga"

# libraries
source ${LIB_PATH_NIGHTLY}/libgit.sh
source ${LIB_PATH_NIGHTLY}/kw-common.sh

function __build() {

    local config="${1}"

    local threads="$(nproc)"
    let threads+=threads

    echo "${SELF}: ${FUNCNAME}: cleaning"
    if ! kwshell make mrproper ; then
        echo "${SELF}: ${FUNCNAME}: failed"
	chmod -R 777 .kwlp .kwps
        return 1
    fi

    echo "${SELF}: ${FUNCNAME}: configuring"
    if ! kwshell make "${config}" ; then
        echo "${SELF}: ${FUNCNAME}: failed"
	chmod -R 777 .kwlp .kwps
        return 1
    fi

    echo "${SELF}: ${FUNCNAME}: building kernel"
    if ! kwshell make -j${threads} Image ; then
        echo "${SELF}: ${FUNCNAME}: failed"
	chmod -R 777 .kwlp .kwps
        return 1
    fi

    echo "${SELF}: ${FUNCNAME}: building kernel modules"
    if ! kwshell make -j${threads} modules; then
        echo "${SELF}: ${FUNCNAME}: failed"
	chmod -R 777 .kwlp .kwps
        return 1
    fi

    chmod -R 777 .kwlp .kwps
    return 0
}

function do_build() {
    local tagref=${1}

set -x
    cd ${SOURCE_CLONE}

    # Generate file name for results file
    local kw_version="$(kwcheck --version | head -1 | egrep -o -e '\([0-9\.]*\)' | tr -d '()')"
    local KERNEL_VERSION="$(make kernelversion)"
    local scan_date="$(date +%F_%H%M%S)"
    local head="$(git log -n1 --pretty=format:%h)"
    local gcc_version="$(${CROSS_COMPILE}gcc -dumpversion)"
    local raw_result_file="klocwork-${kw_version}_linux-socfpga-${KERNEL_VERSION}_${machine}_${ARCH}_gcc-${gcc_version}_${scan_date}_${head}.txt"

    # some vars are ${MACHINE} specific
    case "${MACHINE}" in
        stratix10)
             # TODO: kernel version and all
             KERNEL_CFG="defconfig"
             ARCH="arm64"
             CROSS_COMPILE="aarch64-linux-gnu-"
             ;;
        cyclone5|arria5|arria10)
             KERNEL_CFG="socfpga_defconfig"
             ARCH="arm"
             CROSS_COMPILE="arm-linux-gnueabihf-"
             ;;
        nios2)
             # TODO: update container to add nios2-gcc
             KERNEL_CFG="10m50_defconfig"
             ARCH="nios2"
             CROSS_COMPILE=""
             ;;
        *)
             echo "${SELF}: ${FUNCNAME}: error: ${MACHINE}: unsupported machine"
             return 1
             ;;
    esac
    export KERNEL_CFG ARCH CROSS_COMPILE

    if ! __build "${KERNEL_CFG}" ; then
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

# Result is one kw scan result per line.  Also cleans up the one blank space ' ' that
# Klockwork leaves at the end of lines.
# could be:
#   cat raw_results.txt | egrep -v '^(Summary: .*|[0-9]+ Total Issue.*)' | \
#        sed -r -z 's/\n([^0-9])/ \1/g' | sed -r -z 's/\n\n/\n/g' > att.txt
# 
function unwrap_kw_results() {

    declare -r NEW_BLOCK="new-block"
    declare -r INFO_LINE="info-line"

    local kw_results_only_file="${1}"
    local kw_results_one_per_line="${2}"

    local status="${NEW_BLOCK}"
    local accu=""
    local line_counter=1

    cat "${kw_results_only_file}" | while read line ; do

        case "${status}" in
            ${NEW_BLOCK} )
                 if [[ ${line} =~ ^[0-9] ]] ; then
                     status="${INFO_LINE}"
                     accu="${line}"
                 else
                     if [[ ${line} =~ Summary ]] ; then
                         echo "${FUNCNAME}: info: we've hit the last line" >&2
                         break
                     else
                         echo "${FUNCNAME}: error: expected a new block on line ${line_counter}" >&2
                         return 1
                     fi
                 fi
                 ;;

            ${INFO_LINE} )
                 if [[ ${line} =~ ^$ ]] ; then
                     status="${NEW_BLOCK}"
                     echo "${accu}"
                 else
                     accu="${accu} ${line}"
                 fi
		 ;;

            *)
                echo "${FUNCNAME}: error: ${status}: we should never be here! line ${line_counter}" >&2
                return 1
		;;
        esac
        line_counter=$(( ${line_counter} + 1 ))
    done >"${kw_results_one_per_line}"

    return 0
}

# Search git log for author of a line of code for a given range of commits.
# Returns nothing if that line wasn't changed in the commit range.
function get_author_in_range() {

   local file="${1}"
   local line="${2}"
   local range="${3}"

   git log --format="%an" -L${line},${line}:${file} ${range} | head -1

   return $?
}

# We are only interested in scanning code that hasn't been accepted upstream.
# Filter out Klocwork hits that outside a specified commit range.
# The remaining hits are listed with the author of the line of code.
function filter_kw_hits() {

    local kw_file="${1}"
    local result_file="${2}"
    local range="${3}"

    local number
    local hit
    local hit_file
    local hit_line
    local issue
    local author

    pushd ${SOURCE_CLONE}

    cat "${kw_file}" | while read line ; do
        number="$(echo ${line} | cut -d' ' -f1)"
        hit="$(echo ${line} | cut -d' ' -f3)"
        hit_file="$(echo ${line} | cut -d' ' -f3 | cut -d: -f1)"
        hit_line="$(echo ${line} | cut -d' ' -f3 | cut -d: -f2)"
        issue="$(echo ${line} | cut -d' ' -f4-)"

        echo "Processing line ${number} -- ${hit}" >&2
        author="$(get_author_in_range ${hit_file} ${hit_line} ${range})"
        [ -z ${author} ] && continue

        echo "${author:-???} -- ${hit} -- ${issue}"
    done >"${result_file}"

    popd
}

function do_package() {
    local tagref=${1}
    local kw_results_only_file="${BUILD_BASE_DIR}/kw-results-only.txt"
    local kw_results_one_per_line="${BUILD_BASE_DIR}/kw-results-unwrapped.txt"
    local kw_results_file="${BUILD_BASE_DIR}/kw-results-filtered.txt"
set -x

    cd ${SOURCE_CLONE}
    if [ -z "${COMMIT_RANGE}" ]; then
	COMMIT_RANGE="$(git describe --abbrev=0)..HEAD"
    fi

    remove_build_lines "${kw_results_only_file}" && \
    unwrap_kw_results "${kw_results_only_file}" "${kw_results_one_per_line}" && \
    filter_kw_hits "${kw_results_one_per_line}" "${kw_results_file}" "${COMMIT_RANGE}"

    chmod 777 ${kw_results_only_file}
    chmod 777 ${kw_results_one_per_line}
    chmod 777 ${kw_results_file}

    return $?
}
