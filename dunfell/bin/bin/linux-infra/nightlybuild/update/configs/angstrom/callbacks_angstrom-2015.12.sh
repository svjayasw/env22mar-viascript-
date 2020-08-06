# callbacks that implement build from GIT
# no OE, no recipe, plain build

CALLBACK_FILE=callbacks_angstrom

# variables
# angstrom's repo  clone
ANGSTROM_TARGET=angstrom_clone
ANGSTROM_FEED_ENTRY="/media/big_storage/"
# TODO: change to name once DNS is up
NIGHTLY_BINARY_SERVER="http://Build-Server-2"
ANGSTROM_FEED_SERVER="${NIGHTLY_BINARY_SERVER}"
ANGSTROM_FEED_FOLDER=${ANGSTROM_FEED_FOLDER-.}
KERNEL_PROVIDER=${KERNEL_PROVIDER:-linux-altera-ltsi}

echo "KERNEL_PROVIDER ${KERNEL_PROVIDER}"

export BUILD_BASE_DIR=$(pwd)

if [ -n "${FILE_OVERLAY}" ] ; then
    FILE_OVERLAY="$(readlink -f ${BASEDIR}/configs/angstrom/${FILE_OVERLAY})"
fi

function get_cc_prefix() {

    local machine="${1}"
    local cc

    case "${machine}" in
	stratix10swvp)
 		cc="aarch64-linux-gnu-"
		;;
        arria*|cyclone*)
                cc="arm-linux-gnueabihf-"
		;;
        *)
                return 1
                ;;
    esac

    echo "${cc}"

    return 0
}

function get_swvp_machine() {

    local machine="${1}"
    local swvp_machine

    case "${machine}" in
        arria10swvp) swvp_machine="arria10" ;;
        stratix10swvp) swvp_machine="stratix10" ;;
        *) 
           echo "${FUNCNAME}: machine ${machine} has no support for SWVP!" 
           return 1
    esac

    echo "${swvp_machine}"

    return 0
}

function get_lava_machine() {
    
    local machine=${1}
    local lava_machine=""
     
    case ${machine} in
        socfpga_cyclone5|cyclone5)
            lava_machine="cyclonev"
            ;;
        socfpga_arria5|arria5)
            lava_machine="arriav"
            ;;
        arria10)
            lava_machine="arriax"
            ;;
	arria10swvp)
	    lava_machine="arriaxswvp"
	    ;;
	stratix10swvp)
	    lava_machine="stratixxswvp"
	    ;;
        *)
             echo "${FUNCNAME}: error: ${machine}: unknown machine..."
             ;;
    esac

    echo "${lava_machine}"

    return 0
}
  
function get_isa_from_machine() {

    local machine=${1}
    local isa=""
     
    case ${machine} in
        socfpga_cyclone5|cyclone5|socfpga_arria5|arria5)
	    case ${ANGSTROM_VERSION} in
                2012.12|2013.12|2014.06)
                    isa="armv7a-vfp-neon" 
                    ;;
                2014.12)
                    isa="armv7at2hf-vfp-neon" 
                    ;;
            esac
            ;;        
        arria10|arria10swvp)
	    case ${ANGSTROM_VERSION} in
                2012.12|2013.12|2014.06)
                    echo "${FUNCNAME}: error: ${machine} not supported with ${ANGSTROM_VERSION}"
                    return 1 
                    ;;
                2014.12)
                    isa="armv7at2hf-vfp-neon" 
                    ;;
            esac
            ;;
        stratix10|stratix10swvp)
	    case ${ANGSTROM_VERSION} in
                2012.12|2013.12|2014.06)
                    echo "${FUNCNAME}: error: ${machine} not supported with ${ANGSTROM_VERSION}"
                    return 1 
                    ;;
                2014.12)
                    isa="aarch64"
                    ;;
            esac
            
            ;;
        *)
             echo "${FUNCNAME}: error: ${machine}: unknown machine..."
             return 1
             ;;
    esac

    echo "${isa}"

    return 0
}

function get_mkpimage_flags() {

    local machine=${1}
    local flags=""

    case ${machine} in
        socfpga_cyclone5|cyclone5|socfpga_arria5|arria5)
            flags="-hv 0"
            ;;
        arria10|arria10swvp)
            flags="-hv 1"
            ;;
        *)
            echo "${FUNCNAME}: error: ${machine}: unknown machine..."
            return 1
            ;;
    esac

    echo "${flags}"

    return 0
}

# SoCFPGA specific variables
export LINUX_TEST_REPO="git://at-git.intel.com/linux-test"
export LINUX_TEST_BRANCH="master"

# GIT Library
source ${LIB_PATH_NIGHTLY}/libgit.sh
source ${LIB_PATH_NIGHTLY}/libtag.sh

function check_requirements() {

    local do_uboot="UBOOT_REPO"
    if [ "${UBOOT_SKIP}" == "yes" ] ; then
        do_uboot=""
    fi

    
    echo "${FUNCNAME}: info: checking the socfpga specific variables..."
    for var in ANGSTROM_IMAGE_TYPE KERNEL_REPO KERNEL_PROT\
               KERNEL_DEFCONFIG ${do_uboot} ; do
        eval tmp=\$${var}
        if [ -z ${tmp} ] ; then
            echo "${FUNCNAME}: ${var}: mandatory variable not set."
            return 2
        fi
    done

    if [ -z "${SD_IMAGER}" ] ; then
        echo "${FUNCNAME}: error: no SD card imager found!"    
        return 2
    fi

    if [ -z "${IPKG_INDEX}" ] ; then
        echo "${$FUNCNAME}: error: no ipk index tool found!"
        return 2
    fi

    if [ -z "${PRELOADER_IMAGER}" ] ; then
       echo "${FUNCNAME}: error: no mkpimage found!"
       return 2
    else
        version=$(${PRELOADER_IMAGER} --version 2>/dev/null | awk ' { print $3 } ')
        if [ $? -ne 0 ] ; then # we assume an older version here
             echo "${FUNCNAME}: error: ${PRELOADER_IMAGER} version unidentified"
             return 2
       else 
           good_version=$(echo "${version} >= 15.0" | bc -l)
           if [ ${good_version} -ne 1 ] ; then
               echo "${FUNCNAME}: error: ${PRELOADER_IMAGER}'s version too old (${version})"
               return 2
           fi
       fi
    fi

    # check for repo, only for 2015.12 and (probably) onwards
    case ${ANGSTROM_VERSION} in 
        2015.12)
            if [ -z "${REPO}" ] ; then
                echo "${FUNCNAME}: error: the command repo was not found!"
                echo "  please download it from google and add it to our path"
                echo "  curl http://commondatastorage.googleapis.com/git-repo-downloads/repo > ~/bin/repo"
                return 2 
            fi
            return 2
           ;;
    esac

    return 0
}      

function get_num_cpus() {

     local lscpu
     local num_cpus

     # some platforms do not have lscpu
     lscpu="$(which lscpu)"
     if [ -n ${lscpu} ] ; then
         num_cpus=$(${lscpu} | egrep -e "^CPU\(s\)" | awk -F: ' { print $2 } ' | sed -re 's/^\s*//g')
     else
        # reverting to /proc/cpuinfo if available
        if [ -f /proc/cpuinfo ] ; then
            num_cpus=$(cat /proc/cpuinfo | grep "BogoMIPS" | wc -l)
            if [ ${num_cpus} -eq 0 ] ; then
                num_cpus=$(cat /proc/cpuinfo | grep "cpu cores" | \
                           awk -F: ' { print $2 } ' | sed -re 's/^\s*//g')
            fi
        fi
     fi

     echo ${num_cpus}

     return 0
 }


# TODO: make this a weak assignment
ANGSTROM_ALTERA_LAYER="meta-altera"

case ${ANGSTROM_VERSION} in
    v2012.12)
          ANGSTROM_LIBC=eglibc
          ANGSTROM_CONFIG=~/.oe/environment-angstromv2012.12 
          ANGSTROM_BINARY_DIR=${ANGSTROM_TARGET}/build/tmp-angstrom_v2012_12-eglibc/deploy
          manifest=${ANGSTROM_BINARY_DIR}/licenses/Angstrom-${ANGSTROM_IMAGE_TYPE}-eglibc-ipk-v2012.12-${MACHINE}/license.manifest
          ANGSTROM_ALTERA_LAYER_BRANCH=${ANGSTROM_ALTERA_LAYER_BRANCH:-"angstrom-v2012.12-yocto1.3"}
          ANGSTROM_FS_ARCHIVE_TYPE="tar.gz"
          ANGSTROM_LAYERS=${ANGSTROM_TARGET}/sources/layers.txt
	  KERNEL_MACHINE="${MACHINE}"
	  UBOOT_LAYER_DIR="sources/${ANGSTROM_ALTERA_LAYER}/recipes-bsp/uboot/u-boot-socfpga"
	  KERNEL_LAYER_DIR="sources/${ANGSTROM_ALTERA_LAYER}/recipes-kernel/linux/${KERNEL_PROVIDER}"
          ;;
    v2013.12)
          ANGSTROM_LIBC=eglibc
          ANGSTROM_CONFIG=environment-angstrom-v2013.12 
          ANGSTROM_BINARY_DIR=${ANGSTROM_TARGET}/deploy/eglibc
          ANGSTROM_ALTERA_LAYER_BRANCH=${ANGSTROM_ALTERA_LAYER_BRANCH:-"angstrom-v2013.12-yocto1.5"}
    	  manifest=${ANGSTROM_BINARY_DIR}/licenses/Angstrom-${ANGSTROM_IMAGE_TYPE}-eglibc-ipk-v2013.12-${MACHINE}/license.manifest
          ANGSTROM_FS_ARCHIVE_TYPE="tar.gz"
          ANGSTROM_LAYERS=${ANGSTROM_TARGET}/sources/layers.txt
	  KERNEL_MACHINE="${MACHINE}"
	  UBOOT_LAYER_DIR="sources/${ANGSTROM_ALTERA_LAYER}/recipes-bsp/uboot/u-boot-socfpga"
	  KERNEL_LAYER_DIR="sources/${ANGSTROM_ALTERA_LAYER}/recipes-kernel/linux/${KERNEL_PROVIDER}"
	  ;;
    v2014.06)
          ANGSTROM_LIBC=eglibc
          ANGSTROM_CONFIG=environment-angstrom-v2014.06
          ANGSTROM_BINARY_DIR=${ANGSTROM_TARGET}/deploy/eglibc
          ANGSTROM_ALTERA_LAYER_BRANCH=${ANGSTROM_ALTERA_LAYER_BRANCH:-"angstrom-v2014.06-yocto1.6"}
    	  manifest=${ANGSTROM_BINARY_DIR}/licenses/Angstrom-${ANGSTROM_IMAGE_TYPE}-eglibc-ipk-v2014.06-${MACHINE}/license.manifest
          ANGSTROM_FS_ARCHIVE_TYPE="tar.xz"
          ANGSTROM_LAYERS=${ANGSTROM_TARGET}/sources/layers.txt
	  KERNEL_MACHINE="${MACHINE}"
	  UBOOT_LAYER_DIR="sources/${ANGSTROM_ALTERA_LAYER}/recipes-bsp/uboot/u-boot-socfpga"
	  KERNEL_LAYER_DIR="sources/${ANGSTROM_ALTERA_LAYER}/recipes-kernel/linux/${KERNEL_PROVIDER}"
	  ;;
    v2014.12)
          ANGSTROM_LIBC=glibc
          ANGSTROM_CONFIG=environment-angstrom-v2014.12
          ANGSTROM_BINARY_DIR=${ANGSTROM_TARGET}/deploy/glibc
          ANGSTROM_ALTERA_LAYER_BRANCH=${ANGSTROM_ALTERA_LAYER_BRANCH:-"angstrom-v2014.12-yocto1.7"}
    	  manifest=${ANGSTROM_BINARY_DIR}/licenses/${MACHINE}/Angstrom-${ANGSTROM_IMAGE_TYPE}-glibc-ipk-v2014.12-${MACHINE}/license.manifest
          ANGSTROM_FS_ARCHIVE_TYPE="tar.xz"
          ANGSTROM_LAYERS=${ANGSTROM_TARGET}/sources/layers.txt
	  KERNEL_MACHINE="socfpga_${MACHINE}"
	  UBOOT_LAYER_DIR="sources/${ANGSTROM_ALTERA_LAYER}/recipes-bsp/u-boot/u-boot-socfpga"
	  KERNEL_LAYER_DIR="sources/${ANGSTROM_ALTERA_LAYER}/recipes-kernel/linux/${KERNEL_PROVIDER}"
          BAD_LAYERS="meta-kde4 meta-java meta-mono meta-gumstix-community meta-smartphone"
	  SDK_BASE_DIR=/opt/oecore-x86_64/2014.12
          CC="$(get_cc_prefix ${MACHINE})"
	  ;;
    v2015.12)
          ANGSTROM_LIBC=glibc
          ANGSTROM_CONFIG=setup-environment
	  ANGSTROM_BINARY_DIR=${ANGSTROM_TARGET}/deploy/glibc
          ANGSTROM_ALTERA_LAYER_BRANCH=${ANGSTROM_ALTERA_LAYER_BRANCH:-"master"}
          manifest=${ANGSTROM_BINARY_DIR}/licenses/${MACHINE}/Angstrom-${ANGSTROM_IMAGE_TYPE}-glibc-ipk-v2015.12-${MACHINE}/license.manifest
	  ANGSTROM_FS_ARCHIVE_TYPE="tar.xz"
	  KERNEL_MACHINE="socfpga_${MACHINE}"
	  UBOOT_LAYER_DIR="sources/${ANGSTROM_ALTERA_LAYER}/recipes-bsp/u-boot/u-boot-socfpga"
	  KERNEL_LAYER_DIR="sources/${ANGSTROM_ALTERA_LAYER}/recipes-kernel/linux/${KERNEL_PROVIDER}"
	  BAD_LAYERS="meta-ti meta-kde4 meta-java meta-mono meta-gumstix-community meta-smartphone meta-atmel meta-uav meta-edison meta-telephony"
          CC="$(get_cc_prefix ${MACHINE})"
          ;;
    *)
          echo "error: ${ANGSTROM_VERSION}: unknown Angstrom version!"
          return 1
         ;;
esac

# Angstrom's specifics
ANGSTROM_PACKAGES=${ANGSTROM_BINARY_DIR}/ipk
ANGSTROM_IMAGES=${ANGSTROM_BINARY_DIR}/images/${MACHINE}


# Packages to be built
ANGSTROM_SOCFPGA_PACKAGES="${EXTRA_SOCFPGA_PACKAGES}"
ANGSTROM_SOCFPGA_BASE_PACKAGES="virtual/kernel ${ANGSTROM_IMAGE_TYPE}"

# locations for the binaries
BINARIES="binaries"
TMP_ANGSTROM_RFS="rfs"

TAGS_REPO="git://at-git.intel.com/linux-tags"
TAGS_BRANCH=${TAGS_BRANCH:-"master"}   
TAGS_TARGET="$(pwd)/tags_list"

# SWVP
SWVP_MACHINE="$(get_swvp_machine ${MACHINE})"

# tools
#TODO: make sure PATH is OK!
SD_IMAGER=$(which make_sdimage.py)
IPKG_INDEX=$(which opkg-make-index)
PRELOADER_IMAGER=/opt/altera/15.1/embedded/host_tools/altera/mkpimage/mkpimage
REPO=$(which repo)

function do_init() {

    local tagref=${1}

    case ${ANGSTROM_VERSION} in
        v2012.12|v2013.12|v2014.06|v2014.12)
            do_init_legacy ${tagref}
            return $?
            ;;
        v2015.12)
            do_init_new ${tagref}
            return $?
            ;;
        *)
            echo "${FUNCNAME}: internal error: ${ANGSTROM_VERSION} is not supported"
            echo "                             this should have been caught earlier!"
            return 1
    esac
}

function do_init_new() {

    local tagref=${1}

    check_requirements
    if [ $? -ne 0 ] ; then
       echo "${FUNCNAME}: error: this configuration does not meet the requirements"
        return 1
    fi

    do_init_tags ${TAGS_REPO} ${TAGS_BRANCH} ${tagref}
    if [ $? -ne 0 ] ; then
        echo "${FUNCNAME}: error: could not initialize tag manager"
        return 1
    fi

    # now the fun with repo
    # repo init -u git://github.com/Angstrom-distribution/angstrom-manifest
    mkdir ${ANGSTROM_TARGET} && cd ${ANGSTROM_TARGET}

    ${REPO} init -u ${ANGSTROM_REPO} -b ${ANGSTROM_BRANCH}
    if [ $? -ne 0 ] ; then
        echo "${FUNCNAME}: error: repo init failed"
        return 1
    fi
    # here we need to insert the local manifest for the additional 
    # repos and the repo replacements
    mkdir -p .repo/local_manifests
    if [ $? -ne 0 ] ; then
        echo "${FUNCNAME}: error: failed to add local manifest"
        return 1
    fi
    cat <<EOT >.repo/local_manifests/somemore.xml
<?xml version="1.0" encoding="UTF-8"?>
<manifest>

  <default revision="master" sync-j="4"/>

  <remote fetch="git://at-git.intel.com/" name="howdy"/>
  <remove-project name="kraj/meta-altera" />

  <project remote="howdy"  name="meta-altera-misc" path="sources/meta-altera-misc"/>
  <project remote="howdy"  name="meta-altera" path="sources/meta-altera" revision="angstrom-v2015.12-yocto2.0-test-nightly-build"/>

EOT
   for layer in ${BAD_LAYERS} ; do 
      project="$(egrep -o -e "name=\"([a-zA-Z0-9_/\-]*)${layer}\"" .repo/manifest.xml)" 
      echo '  <remove-project '"${project}"' />'
   done >>.repo/local_manifests/somemore.xml

   cat <<EOT >>.repo/local_manifests/somemore.xml
</manifest>
EOT

    ${REPO} sync
    if [ $? -ne 0 ] ; then
        echo "${FUNCNAME}: error: repo sync failed"
        return 1
    fi

  
    #TODO: How do we handle tags?
    echo "${FUNCNAME}: info: forget the tags, not handled here... for now."  

    cd -
}

function do_init_legacy() {

    local tagref=${1}
    local cpus

    echo "${FUNCNAME}: @@@@@@@@ ${BUILD_DIR}"
    check_requirements
    if [ $? -ne 0 ] ; then
       echo "${FUNCNAME}: error: this configuration does not meet the requirements"
        return 1
    fi

    do_init_tags ${TAGS_REPO} ${TAGS_BRANCH} ${tagref}
    if [ $? -ne 0 ] ; then
        echo "${FUNCNAME}: error: could not initialize tag manager"
        return 1
    fi
    
    echo "${FUNCNAME}: info: starting clone of Angstrom's tree"
    clone_git_repo ${ANGSTROM_REPO} ${ANGSTROM_BRANCH} ${ANGSTROM_TARGET}
    if [ $? -ne 0 ] ; then
        echo "${FUNCNAME}: clone_git failed for ANGSTROM"
        return 1
    fi
    angstrom_tag=$(get_tag_for_repo $(get_repo_from_url ${ANGSTROM_REPO}) $(simplify_branch_name ${ANGSTROM_BRANCH}))
    if [ $? -ne 0 ] ; then
       echo "${FUNCNAME}: error: could not find tag for Ansgtrom"
       return 1
    fi
    rebase_repo_to_tag ${ANGSTROM_TARGET} ${angstrom_tag}
    if [ $? -ne 0 ] ; then
        echo "${FUNCNAME}: error: could not rebase Angstrom to ${angstrom_tag}"
        return 1
    fi
   
    # TODO: this is no longer required for the newer versions of Angstrom
    # Move this code to the big case statement @ the top. If the variable
    # ANGSTROM_USE_CPUS is not set, then we don't need to edit the local.conf file
    # let's speed things up
    cpus=$(get_num_cpus)
    if [ $? -ne 0 ] ; then
        echo "${FUNCNAME}: warning: could not determine the number of CPU's. Assuming 2"
        cpus=2
    fi
    sed -ri 's/(BB_NUMBER_THREADS = )"2"/\1"'${cpus}'"/' ${ANGSTROM_TARGET}/conf/local.conf

    # we have to update the layers.txt file, to use our internal repo and the right tag!
    socfpga_layer_tag=$(get_tag_for_repo $(get_repo_from_url ${ANGSTROM_ALTERA_LAYER})  ${ANGSTROM_ALTERA_LAYER_BRANCH})
    if [ $? -ne 0 ] ; then
        echo "${FUNCNAME}: error: could not find tag for ${ANGSTROM_ALTERA_LAYER}"
        return 1
    fi
    socfpga_layer_tag=${socfpga_layer_tag:-HEAD}
    # TODO: how about other layers like meta-refdes?
    sed -i '/^'${ANGSTROM_ALTERA_LAYER}'/d' ${ANGSTROM_LAYERS} && \
    echo "${ANGSTROM_ALTERA_LAYER},git://at-git.intel.com/${ANGSTROM_ALTERA_LAYER},${ANGSTROM_ALTERA_LAYER_BRANCH},${socfpga_layer_tag}" >> ${ANGSTROM_LAYERS}
    

    # we do not need all of the layers listed in sources.txt and bblayers.conf
    # since some of those unused/non-required layers come from repos having 
    # reliability issues.
    # TODO: move this to a function
    for bad_layer in ${BAD_LAYERS} ; do
        sed -i '/^'"${bad_layer}"'/d' ${ANGSTROM_LAYERS}
        if [ $? -ne 0 ] ; then
            echo "${FUNCNAME}: warning: could not remove ${bad_layer} from ${ANGSTROM_LAYERS}"
        fi
       
        sed -i '/'"${bad_layer}"'/d' ${ANGSTROM_TARGET}/conf/bblayers.conf
        if [ $? -ne 0 ] ; then
            echo "${FUNCNAME}: error: could not remove ${bad_layer} from ${ANGSTROM_TARGET}/conf/bblayers.conf"
            return 1
        fi
    done
    # TODO: remove this: useless since we start from scratch
    rm -f ${ANGSTROM_CONFIG} &&  echo "${FUNCNAME}: warning: ${ANGSTROM_CONFIG}: file removed"

    cd -

    return 0
}
 
# TODO: move these functions to the top of the file, gather them at one place
function get_kernel_image_name() {

    local kernel_machine="${1}"
    local kernel

    case ${kernel_machine} in

        socfpga_cyclone5|socfpga_arria5|socfpga_arria10|socfpga_arria10swvp)
            kernel="zImage"
            ;;
        socfpga_nadder|socfpga_stratix10swvp)
            kernel="Image"
             ;;
        *)
            return 1
            ;;
    esac

    echo "${kernel}"

    return 0

}

function get_version_from_layer() {

    local recipe_base_name=${1}
    local provider=$(basename ${recipe_base_name})
    local recipe_dir=$(dirname ${recipe_base_name})
    local version_suffix

    echo "@@@@@@@@@@@@@@@@@@@@@@@@@ ${FUNCNAME}:  MACHINE=${MACHINE}" >&2

    pushd ${recipe_dir} >/dev/null 2>&1

    if [[ "${provider}" =~ ^linux-altera ]] ; then
        version_suffix=$(echo ${provider} | sed -e 's/linux-altera//')
    else
        version_suffix=""
    fi

    latest_recipe=$(ls -1 ${provider}_* | sort --sort 'version' | tail -1)

    tmp=$(echo ${latest_recipe} | awk -F_ ' { print $2 } ' | sed -e 's/\.bb//')
    echo ${tmp}${version_suffix}
    
    popd >/dev/null 2>&1

    echo "@@@@@@@@@@@@@@@@@@@@@@@@@ ${FUNCNAME}:  MACHINE=${MACHINE}" >&2

    return 0
}

function do_build() {

    local tagref=${1}

    case ${ANGSTROM_VERSION} in
        v2012.12|v2013.12|v2014.06|v2014.12)
            do_build_legacy ${tagref}
            return $?
            ;;
        v2015.12)
            do_build_new ${tagref}
            return $?
            ;;
        *)
            echo "${FUNCNAME}: internal error: ${ANGSTROM_VERSION} is not supported"
            echo "                             this should have been caught earlier!"
            return 1
    esac
}

ADD_BSPLAYERS="meta-altera-misc"

function do_add_bsplayers() {

    echo "${FUNCNAME}: info: adding bsp layers to bblayers.conf"
    for bsp_layer in ${ADD_BSPLAYERS} ; do
	sed -i '/BSPLAYERS ?= " \\/a\  ${TOPDIR}/sources/'"${bsp_layer}"' \\' conf/bblayers.conf
        if [ $? -ne 0 ] ; then
            echo "${FUNCNAME}: error: could not add ${bsp_layer} to conf/bblayers.conf"
            return 1
        fi
    done
}

function do_build_new() {

    cd ${ANGSTROM_TARGET}

    MACHINE=${MACHINE} source setup-environment
    if [ $? -ne 0 ] ; then
        echo "${FUNCNAME}: error: failed to source environment..."
        return 1
    fi

    echo "${FUNCNAME}: info: removing layers known to cause issues..."
    # there are a few layers known to be flaky, let's remove them
    for bad_layer in ${BAD_LAYERS} ; do
        sed -i '/'"${bad_layer}"'/d' conf/bblayers.conf
        if [ $? -ne 0 ] ; then
            echo "${FUNCNAME}: error: could not remove ${bad_layer} from conf/bblayers.conf"
            return 1
        fi
    done  

    do_add_bsplayers

    # TODO: TAGS TAGS TAGS!
    echo "${FUNCNAME}: info: tags are the least of our concern... for now."

    # VARS and stuff
    # PUT this back in the list: KERNEL_TAG, UBOOT_TAG, LINUX_TEST_TAG 
    for var in  UBOOT_REPO UBOOT_PROT \
                KERNEL_REPO KERNEL_PROT KERNEL_PROVIDER KERNEL_DEFCONFIG \
                LINUX_TEST_REPO LINUX_TEST_BRANCH ; do
        eval tmp=\$${var}
        if [ -n "${tmp}" ] ; then
            export ${var}
            export BB_ENV_EXTRAWHITE="${BB_ENV_EXTRAWHITE} ${var}"
        fi
    done

    # some more setup to do:
    #  some platforms don't have U-Boot enabled. The bootloader build
    #! can be skipped by adding "UBOOT_SKIP=yes" to the configuration
    if [ -z "${UBOOT_SKIP}" -o "${UBOOT_SKIP}" == "no" ] ; then
        BOOTLOADER_PACKAGE="virtual/bootloader"
    else
        BOOTLOADER_PACKAGE=""
    fi

    if [ "${ENV_ADDITIONAL_VARS}" != "" ] ; then
        export ${ENV_ADDITIONAL_VARS}
        export BB_ENV_EXTRAWHITE="${BB_ENV_EXTRAWHITE} ${ENV_ADDITIONAL_VARS}"   
    fi

    echo "${FUNCNAME}: environment: BB_ENV_EXTRAWHITE = ${BB_ENV_EXTRAWHITE}"

    # Now we build...
    echo "environment is $(env)"
    bitbake ${ANGSTROM_SOCFPGA_BASE_PACKAGES} ${BOOTLOADER_PACKAGE} ${ANGSTROM_SOCFPGA_PACKAGES}
    if [ $? -ne 0 ] ; then
        echo "${FUNCNAME}: error: failed to build ${package}"
        return 1
    fi
    
    cd -
}

function do_build_legacy() {

# TODO: this is where the big clean up will happen!
    local oebb=./oebb.sh

    echo    "${FUNCNAME}: info: buildling the kernel"
    cd ${ANGSTROM_TARGET}
    echo -e "                 - configuring"
    MACHINE=${MACHINE} ${oebb} config ${MACHINE}
    if [ $? -ne 0 ] ; then
        echo "${FUNCNAME}: error: failed to config for ${MACHINE}"
        return 1
    fi

    #  Now that we have all of the repos cloned, we can get the 
    #! tags for the kernel and u-boot
    kernel_branch="origin/socfpga-"$(get_version_from_layer "${KERNEL_LAYER_DIR}" )
    KERNEL_TAG=$(get_tag_for_repo $(get_repo_from_url ${KERNEL_REPO}) $(simplify_branch_name ${kernel_branch}))

    uboot_branch="origin/socfpga_v"$(get_version_from_layer "${UBOOT_LAYER_DIR}" )
    UBOOT_TAG=$(get_tag_for_repo $(get_repo_from_url ${UBOOT_REPO}) $(simplify_branch_name ${uboot_branch}))
 
    LINUX_TEST_TAG=$(get_tag_for_repo $(get_repo_from_url ${LINUX_TEST_REPO}) ${LINUX_TEST_BRANCH})

    # now we can use bitbake directly
    source ${ANGSTROM_CONFIG}

    # we have to update BB_ENV_EXTRAWHITE for our own stuff!
    # setup the environment
    export MACHINE
    export KERNEL_REPO KERNEL_PROT KERNEL_DEFCONFIG KERNEL_PROVIDER
    export UBOOT_REPO UBOOT_PROT
    export LINUX_TEST_REPO LINUX_TEST_BRANCH

    # Bitbake starting with Yocto 1.7 passes uninitialized variables, which makes the 
    # weak settting fail.
    # e.g. if KERNEL_TAG is set to "" (that is empty), KERNEL_TAG ?= ${AUTOREV} will not happen
    #      which will lead to a kernel BUILD failure as the reference "" is obviously
    #      not found
    for var in UBOOT_TAG UBOOT_REPO UBOOT_PROT \
               KERNEL_TAG KERNEL_REPO KERNEL_PROT KERNEL_PROVIDER KERNEL_DEFCONFIG \
               LINUX_TEST_TAG LINUX_TEST_REPO LINUX_TEST_BRANCH ; do
        eval tmp=\$${var}
        if [ -n "${tmp}" ] ; then
            export ${var}
            export BB_ENV_EXTRAWHITE="${BB_ENV_EXTRAWHITE} ${var}"
        fi
    done

    #  some platforms don't have U-Boot enabled. The bootloader build
    #! can be skipped by adding "UBOOT_SKIP=yes" to the configuration
    if [ -z "${UBOOT_SKIP}" -o "${UBOOT_SKIP}" == "no" ] ; then
        BOOTLOADER_PACKAGE="virtual/bootloader"
    else
        BOOTLOADER_PACKAGE=""
    fi

    if [ "${ENV_ADDITIONAL_VARS}" != "" ] ; then
        export ${ENV_ADDITIONAL_VARS}
        export BB_ENV_EXTRAWHITE="${BB_ENV_EXTRAWHITE} ${ENV_ADDITIONAL_VARS}"   
    fi

    echo "${FUNCNAME}: environment: BB_ENV_EXTRAWHITE = ${BB_ENV_EXTRAWHITE}"


    bitbake ${ANGSTROM_SOCFPGA_BASE_PACKAGES} ${BOOTLOADER_PACKAGE} ${ANGSTROM_SOCFPGA_PACKAGES}
    if [ $? -ne 0 ] ; then
        echo "${FUNCNAME}: error: failed to build ${package}"
        return 1
    fi
    
    cd -

    return 0
}

# TODO: second phase: remove this function and the need to call it,
# it's never been used
function do_tag()  { 

    local tag=${1}
    
}

function get_kernel_version_from_branch() {

    local branch="$1"
    # we assume the standard somename-3.13
    # will this be broken with the GSRD??
    local version=$(echo ${branch} | awk -F- ' { print $2 } ')

    echo $version
     
    return 0
}



function do_notify_test_server() {

    local sd_image="$1"
    local angstrom_feed="$2"
    local message_file="$3"
    local lava_machine="$4"
    local test=$(basename $(pwd))

    cat <<EOT >"${message_file}"
job_name:"SD CARD update, Angstrom=${ANGSTROM_VERSION}"
machine: ${lava_machine}
http_location:${BINARIES}
update: sd_image,angstrom_feed
sd_image: ${sd_image},/dev/mmcblk0
angstrom_feed : ${angstrom_feed},/etc/opkg/${lava_machine}-feed.conf
EOT
    if [ $? -ne 0 ] ; then
        echo "${FUNCNAME}: warning: could not create the notification file"
        return 1
    fi
    
    return 0
}

# This function will update the package feed
# If required, the directory structure will be created
# The FEED is ${ANGSTROM_FEED}
function do_copy_ipks() {
 
    local angstrom_feed="${1}"
    local package=""
    local err=0
   
    echo "${FUNCNAME}: info: updating the Angstrom package feed..."
    echo "${FUNCNAME}: info: location: ${angstrom_feed}"
    echo "${FUNCNAME}: info: packages: ${ANGSTROM_SOCFPGA_PACKAGES}"
    mkdir -p ${angstrom_feed}
    if [ $? -ne 0 ] ; then
        echo "${FUNCNAME}: error: could not create feed directory (${angstrom_feed})"
        return 1
    fi

    for package in ${ANGSTROM_SOCFPGA_PACKAGES} ; do
        echo "${FUNCNAME}: info: processing package ${package}..."
        find ${ANGSTROM_PACKAGES} -type f | \
           egrep -e '\.ipk$' | grep ${package} | \
           xargs -n1 -i%% cp %% ${angstrom_feed}
        if [ ${PIPESTATUS[3]} -ne 0 ] ; then
            echo "${FUNCNAME}: error: could not copy one or more files for package ${package}"
            err=1
        fi
    done

    if [ ${err} -eq 0 ] ; then
        rm -f ${angstrom_feed}/Packages{,.gz}
        ${IPKG_INDEX} -p ${angstrom_feed}/Packages ${angstrom_feed}
        if [ $? -ne 0 ] ; then
            echo "${FUNCNAME}: error: failed to update feed ${angstrom_feed}"
            return 1
        fi
    fi

    return ${err}
    
}


# returns the dtb file name from the machine name
# and the kernel version
# this is the 'input' dtb file name, the file created by the build
#TODO: update to match different boards?
function get_dtb_in_name() {

    local kernel_branch=$1
    local machine=$2

    local dtb
    case ${ANGSTROM_VERSION} in
        v2012.12|v2013.12|v2014.06|v2014.12)
            case ${machine} in
                socfpga_cyclone5|socfpga_arria5)
                    # from 3.13 on, the name of the dtb has changed...
                    kernel_version=$(get_kernel_version_from_branch ${kernel_branch})
                    # threshold will be 1 if the kernel is more recent than 3.12
                    threshold=$(echo "${kernel_version} > 3.12" | bc -l -q)
                    if [ ${threshold} -eq 1 ] ; then
                        # our kernel is newer than 3.12
                       dtb=${machine}_socdk.dtb
                    else
                       dtb=${machine}.dtb
                     fi
                     ;;
                socfpga_arria10)
                   dtb="socfpga_arria10_socdk_sdmmc.dtb"
                   ;;
                socfpga_arria10swvp)
                   dtb="socfpga_arria10_swvp.dtb"
          	   ;;
                socfpga_stratix10swvp)
                   dtb="stratix10_swvp.dtb"
          	   ;;
                socfpga_nadder)
                   dtb=""
                   ;;
                *)
                   echo "${FUNCNAME}: error: ${machine}: unknown kernel machine..."
                   return 1
                   ;;
            esac
	    ;;
        v2015.12)
            case ${machine} in
                socfpga_cyclone5|socfpga_arria5)
                   dtb=zImage-${machine}_socdk.dtb
                   ;;
                socfpga_arria10)
                   dtb=zImage-${machine}_socdk_sdmmc.dtb
                   ;;
                socfpga_arria10swvp)
                   dtb="zImage-socfpga_arria10_swvp.dtb"
          	   ;;
                socfpga_stratix10swvp)
                   dtb="Image-stratix10_swvp.dtb"
          	   ;;
                socfpga_nadder)
                   dtb=""
                   ;;
                *)
                   echo "${FUNCNAME}: error: ${machine}: unknown kernel machine..."
                   return 1
                   ;;
             esac
             ;;
    esac

    echo ${dtb}
 
    return 0
}

# returns the dtb file name from the machine name
# this is the 'output' dtb file name, the file name
# used on the sd image
function get_dtb_out_name() {

    local machine=$1

    local dtb

    case ${machine} in
        socfpga_cyclone5|socfpga_arria5|cyclone5|arria5)
            dtb="socfpga.dtb"
            ;;
        socfpga_arria10|arria10)
            dtb="socfpga_arria10_socdk.dtb"
            ;;
        socfpga_arria10swvp|arria10swvp)
            dtb="socfpga_arria10_swvp.dtb"
            ;;
        socfpga_stratix10swvp|stratix10swvp)
            dtb="socfpga_stratix10_swvp.dtb"
            ;;
        socfpga_nadder|nadder)
           dtb=""
           ;;
        *)
           echo "${FUNCNAME}: error: ${machine}: unknown kernel machine..."
           return 1
           ;;
    esac

    echo ${dtb}
 
    return 0
}


function get_list_of_binaries() {

    echo "@@@@@@@@@@@@@@@@@@@@@@@@@ ${FUNCNAME}:  MACHINE=${MACHINE}" >&2
    local machine="${1}"
    echo "@@@@@@@@@@@@@@@@@@@@@@@@@ ${FUNCNAME}:  MACHINE=${MACHINE}" >&2
    
    local list=""

    case ${machine} in
        socfpga_cyclone5|socfpga_arria5|cyclone5|arria5)
            echo "@@@@@@@@@@@@@@@@@@@@@@@@@ ${FUNCNAME}:  MACHINE=${MACHINE}" >&2
            list="u-boot-spl-${machine}.bin u-boot-${machine}.img zImage"    
            ;;
        arria10|arria10swvp)
	    list="u-boot-dtb.bin u-boot.dtb zImage"
            ;;
        socfpga_nadder|stratix10swvp)
             list="Image"
             ;;
        *)
            return 1 
            ;;
    esac

    echo "${list}"

    return 0

}

function put_file_in() {

    local f="${1}"
    local d="${2}"

    local f_dn="$(dirname $f)"
    local f_bn="$(basename $f)"
    local f_prot="$(echo $f | sed -re 's#([a-z]+)://.*#\1#')"

    local err=0

    case ${f_prot} in
        file|http)
            curl -o ${d}/${f_bn} ${f} >/dev/null 2>&1
            err=$?
            ;;
        *)  # we assume we do plain copy
            cp ${f} ${d}/${f_bn} >/dev/null 2>&1
            err=$?
            ;;
    esac

    return ${err}
}

function copy_overlay_files() {

    local overlay_list="${2}"
    local binaries="${1}"

    if [ -z "${overlay_list}" ] ; then
        return 0
    fi

    source "${overlay_list}"

    (set -o posix ; set ) | grep OVERLAY_ | \
    while read overlay_spec ; do

        partition_dir=${binaries}/$(echo $overlay_spec | awk -F= ' { print $1 } ' | \
                                    awk -F_ ' { print $2 } ' | tr '[:upper:]' '[:lower:]')
        files="$(echo ${overlay_spec} | awk -F = ' { print $2 } ' | sed -e 's/,/ /g' )"
 
        # create partition dir
        mkdir ${partition_dir}
        if [ $? -ne 0 ] ; then
            echo "${FUNCNAME}: ${partition_dir}: failed to mkdir"
            return 1
        fi

        # process files
        # the files are listed as a Comma separated list
        for f in $(echo ${files} ) ; do

            put_file_in ${f} ${partition_dir}
            if [ $? -ne 0 ] ; then
                echo "${FUNCNAME}: failed to put file in ${partition_dir}"
                return 1
            fi

        done
    done

    return 0
}

function copy_files_to_bin() {

   
    local binaries="$1"
    echo "@@@@@@@@@@@@@@@@@@@@@@@@@ ${FUNCNAME}:  MACHINE=${MACHINE}" 1>&2
    local list_of_binaries="$(get_list_of_binaries ${MACHINE} )"
    echo "@@@@@@@@@@@@@@@@@@@@@@@@@ ${FUNCNAME}:  MACHINE=${MACHINE}" 1>&2
    local kernel_branch="origin/socfpga-"$(get_version_from_layer "${ANGSTROM_TARGET}/sources/${ANGSTROM_ALTERA_LAYER}/recipes-kernel/linux/${KERNEL_PROVIDER}" )
    echo "@@@@@@@@@@@@@@@@@@@@@@@@@ ${FUNCNAME}:  MACHINE=${MACHINE}" 1>&2
    local dtb="$(get_dtb_in_name ${kernel_branch} ${KERNEL_MACHINE})"
    echo "@@@@@@@@@@@@@@@@@@@@@@@@@ ${FUNCNAME}:  MACHINE=${MACHINE}" 1>&2
    local dtb_out="$(get_dtb_out_name ${KERNEL_MACHINE})"

    ANGSTROM_BUILD=${ANGSTROM_BINARY_DIR}/images/${MACHINE}
    echo "@@@@@@@@@@@@@@@@@@@@@@@@@ ${FUNCNAME}:  MACHINE=${MACHINE}" 1>&2
set -x
    for file in ${list_of_binaries} ${ANGSTROM_IMAGE_TYPE}-${MACHINE}.${ANGSTROM_FS_ARCHIVE_TYPE} ${dtb} ; do
        cp -aL ${ANGSTROM_BUILD}/$file ${binaries}
        if [ $? -ne 0 ] ; then
            echo "${FUNCNAME}: error: $file: no such file" >&2
            exit -1
        fi

        case "${file}" in
            "${dtb}")
    	        cp -aL ${ANGSTROM_BUILD}/$file ${binaries}/${dtb_out}
                if [ $? -ne 0 ] ; then
                    echo "${FUNCNAME}: error: $file: no such file" >&2
                    return 1
                fi
                ;;
            "u-boot-${MACHINE}.img"|"u-boot-socfpga_${MACHINE}.img")
                # Todo: FILL in UBOOT short name
                cp -aL ${ANGSTROM_BUILD}/$file ${binaries}/u-boot.img
                if [ $? -ne 0 ] ; then
                     echo "${FUNCNAME}: error: $file: no such file" >&2
                     return 1
                fi
                ;;
        esac 
    done

    if [ -e ${ANGSTROM_BUILD}/${ANGSTROM_IMAGE_TYPE}-${MACHINE}.cpio ] ; then
        cp -aL ${ANGSTROM_BUILD}/${ANGSTROM_IMAGE_TYPE}-${MACHINE}.cpio ${binaries}
        if [ $? -ne 0 ] ; then
            echo  "${FUNCNAME}: error: ${ANGSTROM_IMAGE_TYPE}-${MACHINE}.cpio: no such file" >&2
            return 1
        fi
    fi
set +x
    return 0
}

function make_preloader_image() {

    local spl="$1"
    local machine="$2"

    local spl_h=${spl}.img
    local flags=$(get_mkpimage_flags "${machine}")

    # stuff from SoCEDS
    ${PRELOADER_IMAGER} ${flags} -o ${spl_h} ${spl} 
    if [ $? -ne 0 ] ; then
        echo "${FUNCNAME}: error: failed to make boot image image" >&2
        exit -1
    fi

    echo ${spl_h}
}



function get_a2_par_size_from_machine() {

    local machine="${1}"
    local size

    case ${machine} in
        socfpga_cyclone5|cyclone5|socfpga_arria5|arria5)
            size="512k"
            ;;

         arria10|arria10swvp)
            size="2M"
            ;;
         stratix10swvp)
	    size="2M"
            ;;
         *)
            echo "${FUNCNAME}: error: ${machine}: unknown machine"
            return 1
            ;;
    esac

    echo "${size}"

    return 0
}

# call when in ${BINARIES}
function do_sdimage() {

    local machine="$1"
    local sd_image_name="$2"
    local binaries_a="$3"
    local overlay_dirs="$4"
    local raw_part_size=$(get_a2_par_size_from_machine "${machine}")
    local boot_image

    local dtb_out="$(get_dtb_out_name ${machine})"

    pushd ${binaries_a} >/dev/null 2>&1

    cwd="$(pwd)"
    echo "do_sdimage cwd is ${cwd}"

    # did we have an overlay?
    if [ -d p1 ] ; then
       echo "there is a p1 overlay"
       p1="$(readlink -f p1/)"
       echo "containing ${p1}"
    fi

    if [ -d p2 ] ; then
       p2="$(readlink -f p2/)"
    fi

    if [ -d p3 ] ; then
       p3="$(readlink -f p3/)"
    fi

    case ${machine} in
        socfpga_cyclone5|socfpga_arria5|cyclone5|arria5)
            boot_image=$(make_preloader_image u-boot-spl-${machine}.bin "${machine}")

            p1_data="zImage,u-boot.img,${dtb_out}"
            if [ -n "${p1}" ] ; then
                p1_data="$(echo ${p1_data},${p1})"
            fi

            p2_data="$(readlink -f ${TMP_ANGSTROM_RFS})"
            if [ -n "${p2}" ] ; then
                p2_data="$(echo ${p2_data},${p2})"
            fi

            p3_data="${boot_image}"
            if [ -n "${p3}" ] ; then
                p3_data="$(echo ${p3_data},${p3})"
            fi

            sudo ${SD_IMAGER} \
            -P "${p3_data}",num=3,type=a2,format=raw,size=${raw_part_size} \
            -P "${p1_data}",num=1,format=vfat,size=20M \
            -P "${p2_data}",num=2,format=ext3,size=1G \
            -s 2G -n ${sd_image_name}
            if [ $? -ne 0 ] ; then
                echo "${FUNCNAME}: error: failed to create image"
                return 1
            fi
            ;;

        arria10|arria10swvp)
            boot_image=$(make_preloader_image u-boot-dtb.bin "${machine}")

            p1_data="zImage,${dtb_out}"
            if [ -n "${p1}" ] ; then
                p1_data="$(echo ${p1_data},${p1})"
            fi

            p2_data="$(readlink -f ${TMP_ANGSTROM_RFS})"
            if [ -n "${p2}" ] ; then
                p2_data="$(echo ${p2_data},${p2})"
            fi

            p3_data="${boot_image}"
            if [ -n "${p3}" ] ; then
                p3_data="$(echo ${p3_data},${p3})"
            fi
            #TODO: add RBF!
            sudo ${SD_IMAGER} \
            -P "${p3_data}",num=3,type=a2,format=raw,size=${raw_part_size} \
            -P "${p1_data}",num=1,format=vfat,size=20M \
            -P "${p2_data}",num=2,format=ext3,size=1G \
            -s 2G -n ${sd_image_name}
            if [ $? -ne 0 ] ; then
                echo "${FUNCNAME}: error: failed to create image"
                return 1
            fi
            ;;

        stratix10swvp)
            p1_data="Image,${dtb_out}"
            if [ -n "${p1}" ] ; then
                p1_data="$(echo ${p1_data},${p1})"
            fi

            p2_data="$(readlink -f ${TMP_ANGSTROM_RFS})"
            if [ -n "${p2}" ] ; then
                p2_data="$(echo ${p2_data},${p2})"
            fi

            sudo ${SD_IMAGER} \
            -P "${p1_data}",num=1,format=vfat,size=50M \
            -P "${p2_data}",num=2,format=ext3,size=1G \
            -s 2G -n ${sd_image_name}
            if [ $? -ne 0 ] ; then
                echo "${FUNCNAME}: error: failed to create image"
                return 1
            fi
            ;;

    esac

    popd >/dev/null 2>&1
    return 0
}

function do_expand_rfs() {

    local binaries_a="${1}"
    
    pushd ${binaries_a} 2>/dev/null 1>&2
    echo "${FUNCNAME}: info: expanding RFS"
    mkdir ${TMP_ANGSTROM_RFS}

    case ${ANGSTROM_FS_ARCHIVE_TYPE} in 
         "tar.gz")
              TAR_OPT="xfz" 
              ;;
         "tar.xz")
              TAR_OPT="xfJ" 
              ;;
         *)
              echo "${FUNCNAME}: ${ANGSTROM_FS_ARCHIVE_TYPE}: error: unknown type"
              return 1
              ;;
    esac

    sudo tar ${TAR_OPT} ${ANGSTROM_IMAGE_TYPE}-${MACHINE}.${ANGSTROM_FS_ARCHIVE_TYPE} \
         -C ${TMP_ANGSTROM_RFS}
    if [ $? -ne 0 ] ; then
        echo "${FUNCNAME}: ${ANGSTROM_IMAGE_TYPE}-${MACHINE}.${ANGSTROM_FS_ARCHIVE_TYPE}: \
error: could not expand RFS..."
        return 1
    fi
    popd >/dev/null 2>&1

    return 0
}

# TODO: move these @ the top or better to a configuration file?
PACKAGE_SWVP_GIT="git://at-git.intel.com/swvp-infra"
PACKAGE_SWVP_BRANCH=${PACKAGE_SWVP_BRANCH:-"origin/mentor-vista-4.1"}
PACKAGE_SWVP_GIT_TARGET="swvp"
PACKAGE_SWVP_PARAMETERS="parameters.txt"
PACKAGE_SWVP_LABEL_SDIMG="%%SDIMAGE%%"
PACKAGE_SWVP_LABEL_ELFIMG="%%ELFIMAGE%%"
PACKAGE_SWVP_ELFIMG="linux-system.elf"
PACKAGE_SWVP_TAR="swvp-linux-${MACHINE}-${kernel_branch}-angstrom-${ANGSTROM_VERSION}.tgz"
function do_swvp_package() {
set -x
    local binaries="${1}"
    local kernel="${2}"
    local dtb="${3}"
    local sd_img="${4}"
    local elf_img="${5}"
    local swvp_package="${6}"
    local package_swvp_dir="Software/${SWVP_MACHINE}/linux"

    if [ -z "${CC}" ] ; then
        echo "${FUNCNAME}: error: SWVP not supported with this version of Angstrom (${ANGSTROM_VERSION})"
        return 1
    fi

    pushd ${binaries} >/dev/null 2>&1
    
    # go get the swvp infra scripts and files
    clone_git_repo ${PACKAGE_SWVP_GIT} ${PACKAGE_SWVP_BRANCH} ${PACKAGE_SWVP_GIT_TARGET}
    if [ $? -ne 0 ] ; then
        echo "${FUNCNAME}: error: failed to clone ${PACKAGE_SWVP_GIT}"
        return 1
    fi 
 
    # location of the binaries
    mkdir -p ${package_swvp_dir}
    if [ $? -ne 0 ] ; then
        echo "${FUNCNAME}: error: could not make ${package_swvp_dir}"
        return 1
    fi

    # let's get to work
    cd ${PACKAGE_SWVP_GIT_TARGET}/${SWVP_MACHINE}/
    #TODO: add the name of the QSPI image once available
    
    # now let's generate the elf image
    cd sw/

    # build.sh [-h] <zImage> <dtb> <elf>
    for f in ${kernel} ${dtb} ; do
        cp ${binaries}/${f} . 
    done
    ./build.sh ${kernel} ${dtb} \
               ${binaries}/${package_swvp_dir}/${elf_img} \
	       ${CC}      
    if [ $? -ne 0 ] ; then
        echo "${FUNCNAME}: error: failed to build the swvp elf image"
        return 1
    fi

    cd -

    # let's update the parameters file 
    sed -r -e 's/'${PACKAGE_SWVP_LABEL_SDIMG}'/'${sd_img}'/' ${PACKAGE_SWVP_PARAMETERS} \
           -e 's/'${PACKAGE_SWVP_LABEL_ELFIMG}'/'${elf_img}'/' ${PACKAGE_SWVP_PARAMETERS} \
           > ${binaries}/${PACKAGE_SWVP_PARAMETERS}
    if [ $? -ne 0 ] ; then
        echo "${FUNCNAME}: error: failed to update ${PACKAGE_SWVP_PARAMETERS}"
        return 1
    fi

    # let's package up things nicely for users
    cd ${binaries}
    cp ${sd_img} ${package_swvp_dir}/
    if [ $? -ne 0 ] ; then
        echo "${FUNCNAME}: error: could not copy ${sd_img}"
        return 1
    fi
    cd ${binaries}
    tar cfz ${swvp_package} ${PACKAGE_SWVP_PARAMETERS} \
            ${package_swvp_dir}/${sd_img} ${package_swvp_dir}/${elf_img}
    if [ $? -ne 0 ] ; then
        echo "${FUNCNAME}: error: failed to package linux binaries for the SWVP"
        popd >/dev/null 2>&1
        return 1
    fi

    # let's clean up
    rm -rf ${package_swvp_dir}

    popd >/dev/null 2>&1

    return 0    
}


# Ugly ugly ugly temporary solution for the S10 SWVP
function do_s10_swvp_package() {
set -x
    local binaries="${1}"
    local kernel="${2}"
    local dtb="${3}"
    local initrd_img="${4}"
    local elf_img="${5}"
    local swvp_package="${6}"
    local package_swvp_dir="."

    if [ -z "${CC}" ] ; then
        echo "${FUNCNAME}: error: SWVP not supported with this version of Angstrom (${ANGSTROM_VERSION})"
        return 1
    fi

    pushd ${binaries} >/dev/null 2>&1
    
    # go get the swvp infra scripts and files
    clone_git_repo ${PACKAGE_SWVP_GIT} ${PACKAGE_SWVP_BRANCH} ${PACKAGE_SWVP_GIT_TARGET}
    if [ $? -ne 0 ] ; then
        echo "${FUNCNAME}: error: failed to clone ${PACKAGE_SWVP_GIT}"
        return 1
    fi 
 
    # location of the binaries
    #mkdir -p ${package_swvp_dir}
    #if [ $? -ne 0 ] ; then
    #    echo "${FUNCNAME}: error: could not make ${package_swvp_dir}"
    #    return 1
    #fi

    # let's get to work
    cd ${PACKAGE_SWVP_GIT_TARGET}/${SWVP_MACHINE}/
    #TODO: add the name of the QSPI image once available
    
    # now let's generate the elf image
    cd sw/

    for f in ${kernel} ${dtb} ${initrd_img} ; do
        cp ${binaries}/${f} . 
    done
    gzip -c ${initrd_img} > ${initrd_img}.gz
    ./build.sh ${kernel} ${dtb} ${initrd_img}.gz \
               ${binaries}/${package_swvp_dir}/${elf_img} \
	       ${CC}

    if [ $? -ne 0 ] ; then
        echo "${FUNCNAME}: error: failed to build the swvp elf image"
        return 1
    fi

    cd ${binaries}
    tar cfz ${swvp_package} \
            ${package_swvp_dir}/${elf_img}
    if [ $? -ne 0 ] ; then
        echo "${FUNCNAME}: error: failed to package linux binaries for the SWVP"
        popd >/dev/null 2>&1
        return 1
    fi

    # let's clean up
    rm -rf ${package_swvp_dir}

    popd >/dev/null 2>&1

    return 0    
}

function do_package() {

    local tagref="$1"
    local kernel_branch=socfpga-"$(get_version_from_layer ${ANGSTROM_TARGET}/sources/${ANGSTROM_ALTERA_LAYER}/recipes-kernel/linux/${KERNEL_PROVIDER} )"
    local angstrom_feed_local="angstrom/feeds/${ANGSTROM_VERSION}/ipk/${ANGSTROM_LIBC}/$(get_isa_from_machine ${MACHINE})/${ANGSTROM_FEED_FOLDER}/${tagref}/${kernel_branch}/machine/${MACHINE}"
    local angstrom_feed_http="${ANGSTROM_FEED_SERVER}/${angstrom_feed_local}"
    local lava_machine="$(get_lava_machine ${MACHINE})"
    local sd_card_image="sd-angstrom-${ANGSTROM_VERSION}-${MACHINE}.img"
    local package_swvp_tar=\
"linux-${MACHINE}-${kernel_branch}-angstrom-${ANGSTROM_VERSION}-${RELEASE_NAME}.tgz"

    BINARIES_A="$(readlink -f ${BINARIES})"
    mkdir ${BINARIES_A}
    if [ $? -ne 0 ] ; then
        echo "${FUNCNAME}: error: ${BINARIES_A}: failed to create directory"
        return 1
    fi

    angstrom_feed="${BINARIES_A}/${angstrom_feed_local}"

    # addressing the legacy use of PACKAGING
    if [ -z "${PACKAGING}" ] || [ "${PACKAGING}" == "none" ] ; then
        PACKAGING="sd_image"
    fi
   
    # check if we have to copy the binaries to a remote server
    if [ -n "${NB_REMOTE_COPY}" ] ; then
        PACKAGING="${PACKAGING} remote_copy"
    fi

    for package in local_copy overlay tagref expand_rfs message \
                   manifest ${PACKAGING} ; do

        case "${package}" in
            local_copy)
                copy_files_to_bin ${BINARIES_A}
                if [ $? -ne 0 ] ; then
                    echo "${FUNCNAME}: error: failed to copy files..."
                    return 1
                fi
		do_copy_ipks ${angstrom_feed}
                if [ $? -ne 0 ] ; then
                    echo "${FUNCNAME}: error: could not update the package feed"
                    return 1
                fi
		;;

            overlay)
                echo "binaries_a ${BINARIES_A} file_overlay ${FILE_OVERLAY}"
                overlay_list_dir="$(copy_overlay_files ${BINARIES_A} ${FILE_OVERLAY} )"
                if [ $? -ne 0 ] ; then
                   echo "${FUNCNAME}: error: failed to process overlay"
                   return 1
                fi
		;;

	    # this should be the last thing to do.
	    remote_copy)
                # we do not copy the expanded rfs, as it contains a lot of
		# symlinks causing issues
                remote_user=$(echo ${NB_REMOTE_COPY} | awk -F: ' { print $1 } ')
                remote_dest=$(echo ${NB_REMOTE_COPY} | awk -F: ' { print $2 } ')
		tar cf - ${BINARIES}/* --exclude=rfs | \
                ssh ${remote_user} tar xf - -C ${remote_dest}
                if [ ${PIPESTATUS[0]} -ne 0 -o ${PIPESTATUS[1]} -ne 0 ] ; then
                    echo "${FUNCNAME}: error: failed to scp to remote (${NB_REMOTE_COPY})"
                    return 1
                fi
		;;

	    sd_image)
                do_sdimage "${MACHINE}" "${sd_card_image}" "${BINARIES_A}" "${overlay_list_dir}"
                if [ $? -ne 0 ] ; then
                    echo "${FUNCNAME}: error: failed to process binaries"
                    return 1
                fi
		;;

	   swvp_image)
set -x
                if [ "${MACHINE}" == "stratix10swvp" ] ; then
                    img="${ANGSTROM_IMAGE_TYPE}-${MACHINE}.cpio"
                    do_s10_swvp_package "${BINARIES_A}" "$(get_kernel_image_name ${KERNEL_MACHINE})" "$(get_dtb_in_name ${kernel_branch} ${KERNEL_MACHINE})" \
                                        "${img}" "linux-system-sd.elf" "${package_swvp_tar}"
                    if [ $? -ne 0 ] ; then
                        echo "${FUNCNAME}: error: failed to create the svwp image for s10"
                        return 1
                    fi
                else
    		    do_swvp_package "${BINARIES_A}" "$(get_kernel_image_name ${KERNEL_MACHINE})" "$(get_dtb_in_name ${kernel_branch} ${KERNEL_MACHINE})" \
                                    "${sd_card_image}" "linux-system-sd.elf" "${package_swvp_tar}"  	
      		    if [ $? -ne 0 ] ; then
		        echo "${FUNCNAME}: error: do_swvp_package failed"
		        return 1
                    fi
                fi
set +x
		;;

	   message)
set -x
		message_file="${BINARIES_A}/message_${MACHINE}_${kernel_branch}_Angstrom_${ANGSTROM_VERSION}-${lava_machine}.txt"
		do_notify_test_server "${sd_card_image}" \
				      "${angstrom_feed_local}" \
				      "${message_file}" \
				      "${lava_machine}"
                if [ $? -ne 0 ] ; then
                    echo "${FUNCNAME}: error: failed to create message file"
                    return 1
                fi

		;;

	   expand_rfs)
		do_expand_rfs ${BINARIES_A}
		if [ $? -ne 0 ] ; then
		    echo "${FUNCNAME}: error: failed to expand rfs"
                    return 1
                fi
		;;    
	    
	    tagref)
                echo "${TAGS_REPO}:${tagref}" >${BINARIES_A}/tagref.txt
		;;

    	    manifest)
	        cp ${manifest} ${BINARIES_A}
		;;

	    *)
		echo "${FUNCNAME}: ${package}: invalid packaging option"
		return 1
		;;
        esac
    done

    return 0
                             
}

