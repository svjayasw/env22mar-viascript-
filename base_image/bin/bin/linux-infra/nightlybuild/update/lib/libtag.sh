
function get_distro_short_name() {

    local distro=$(lsb_release -i | awk -F: ' { print $2 } ' | sed -e 's/^\t//')
    local short_name

    case ${distro} in
        Angstrom)
		short_name='A' ;;
        Ubuntu) 
		short_name='U' ;;
        Fedora)
		short_name='F' ;;
	CentOS)
		short_name='C' ;;
	*)
		short_name='X' ;;
    esac

    echo ${short_name}

    return 0
}

function get_distro_bits() {


    local tmp=$(uname -m)

    case ${tmp} in
        x86_64)
                echo amd64 ;;
        i686)
                echo x86 ;;
        armv7l)
                echo armv7 ;;
        *)
                echo unknown ;;
    esac

    return 0
}

function get_distro_version() {

    local version=$(lsb_release -r | awk -F: ' { print $2 } ' | sed -e 's/^\t//g')

    echo ${version}
    
    return 0
}

function make_tag() {

    local prefix=${1}
    local LSBR=$(which lsb_release)

    if [ -z ${LSBR} ] ; then
        echo "${FUNCNAME}: fatal: lsb_release is not available."
        exit -10
    fi

    if [ ! -z ${prefix} ] ; then
        prefix="_${prefix}_"
    else
        prefix=_
    fi

    tag=$(echo nb${prefix}$(get_distro_short_name)$(get_distro_version)_$(get_distro_bits)_$(date +%F_%H-%M-%S))

    echo ${tag}

    return 0

}


function do_init_tags() {

    local tag_repo="$1"
    local tag_branch="$2"
    local tag_ref="$3"

    if [ -z "${tagref}" ] ; then
        echo "${FUNCNAME}: info: using HEAD as tag reference"
        echo "yes" > ${BUILD_BASE_DIR}/hyn.tmp
        return 0
    fi

    echo "no" > ${BUILD_BASE_DIR}/hyn.tmp
    echo "${FUNCNAME}: info: cloning ${TAGS_REPO}"
    clone_git_repo ${TAGS_REPO} ${TAGS_BRANCH} ${TAGS_TARGET}
    if  [ $? -ne 0 ] ; then
        echo "${FUNCNAME}: clone_git failed for TAGS"
        return 1
    fi
    rebase_repo_to_tag ${TAGS_TARGET} ${tag_ref}
    if  [ $? -ne 0 ] ; then
        echo "${FUNCNAME}: error: failed to rebase ${TAGS_REPO} to ${tag_ref}"
        return 1
    fi

    return 0
}
 
function get_tag_for_repo() {

    local repo=${1}
    local branch=${2}

    if [ "$(cat ${BUILD_BASE_DIR}/hyn.tmp)" == "yes" ] ; then
        echo ""
        return 0
    fi

    get_tag.sh -r ${repo} -b ${branch} -l ${TAGS_TARGET}/linux-altera-tags
    return $?
}
