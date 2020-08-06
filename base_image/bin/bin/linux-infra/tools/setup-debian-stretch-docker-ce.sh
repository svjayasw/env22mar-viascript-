#!/bin/bash 

declare -r SELF="$(basename $0)" 
declare -r SELF_LOG="${SELF}-$$.log" 

# base commands
declare -r PKG_MGR="$(which aptitude)"

function check_requirements() {

	if [ ${UID} -ne 0 ] ; then
		echo "${SELF}: ${FUNCNAME}: error: only root can run ${SELF}..."
		return 1
	fi

	if [ -z "${PKG_MGR}" ] ; then
		echo "${SELF}: ${FUNCNAME}: error: aptitude not installed"
		return 1
	fi

	return 0
}

function prepare() {


        check_requirements
        if [ $? -ne 0 ] ; then
        	return 1
        fi

	rm -f "${SELF_LOG}"

	aptitude update 2>&1 
	if [ $? -ne 0 ] ; then
		echo "${SELF}: ${FUNCNAME}: warning: failed to update local package repos"
	fi

	return 0
}

function install_packages() {

	local packages="$@"

	if [ -z "${packages}" ] ; then
		return 0
	fi

	aptitude install -y ${packages} 2>&1 
	return $?
}

function install_docker-ce() {

	declare -r DOCKER_OLD_PACKAGES="docker docker-engine docker.io"
	declare -r DOCKER_DEPS="apt-transport-https ca-certificates curl gnupg2 software-properties-common"
	declare -r DEBIAN_ID=$(. /etc/os-release; echo "$ID")
	declare -r DOCKER_DEBIAN_REPO_KEY="https://download.docker.com/linux/${DEBIAN_ID}/gpg"

	echo "${SELF}: ${FUNCNAME}: purging any old docker installation"
	apt-get remove ${DOCKER_OLD_PACKAGES} 2>&1 

	echo "${SELF}: ${FUNCNAME}: installing docker's dependencies"
	install_packages ${DOCKER_DEPS}
	if [ $? -ne 0 ] ; then
		echo "${SELF}:${FUNCNAME}: error: failed to install DOCKER_DEPS"
		return 1
	fi
	
	echo "${SELF}: ${FUNCNAME}: installing docker-ce"
	curl -fsSL ${DOCKER_DEBIAN_REPO_KEY} | apt-key add -
	if [ $? -ne 0 ] ; then
		echo "${SELF}: ${FUNCNAME}: error: failed to add DOcker's debian GPG key"
		return 2
	fi

	add-apt-repository \
	       "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
	       $(lsb_release -cs) \
	       stable"
	if [ $? -ne 0 ] ; then
		echo "${SELF}: ${FUNCNAME}: error: failed to add Docker's debian repo..."
		return 3
	fi

	( aptitude update && aptitude install docker-ce ) 2>&1 
	if [ $? -ne 0 ] ; then
		echo "${SELF}: ${FUNCNAME}: error: failed to install docker-ce"
		return 4
	fi

	echo "${SELF}: ${FUNCNAME}: testing installation"
	docker run hello-world 2>&1 | tee -a "${SELF_LOG}"
	if [ $? -ne 0 ] ; then
		echo "${SELF}: ${FUNCNAME}: error: docker could not run test image"
		return 5
	fi

	echo "${SELF}: ${FUNCNAME}: user management"
	groupadd docker
	usermod -aG docker "${D_USER}"

	return 0
}

function usage() {

    cat <<EOT
    Installs docker CE on a debian based distro

    usage: ${SELF} -u <user name>
    -u : user name to be added to the group 'docker'. Mandatory.

EOT
    return 0
}

# options and switches
while [ $# -gt 0 ] ; do

    case $1 in
        -h|--help)
             usage ; exit 0 ;;

        -u|--user)
             D_USER="${2}"  
             shift
             ;;

        *)
             ( echo "${SELF}: error: $1: unknown option" ; usage )  >&2
             exit -1
             ;;
    esac

    shift

done

if [ -z ${D_USER} ] ; then
    ( echo "${SELF}: error: no user specified" ; usage ) >&2
    exit -1
fi
export D_USER

# Script starts here
if ! prepare ; then
	exit 1
fi

echo "${SELF}: info: installing base packages"
install_docker-ce
if [ $? -ne 0 ] ; then
	exit 3
fi

