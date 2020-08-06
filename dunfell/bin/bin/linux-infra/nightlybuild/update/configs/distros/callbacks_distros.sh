# callbacks that implement build from GIT
# no OE, no recipe, plain build

CALLBACK_FILE=callbacks_distros

BINARIES=binaries/
RFS_FILE=rfs.bin
BASE_IMAGE_FILE=base-image.img
RFS_DIR=rfs_src/
RFS_PART=${RFS_PART:-2}
RFS_FORMAT=${RFS_FOMAT:-ext3}

function check_vars() {

    local value
    for var in BASE_IMAGE RFS_URL LATEST_NAME DISTRO; do 
        value=$(eval echo \$$var)
        if [ -z ${value} ] ; then
            echo "${FUNCNAME}: ${var}: error: not set."
            return 1
        fi
    done

    return 0
}

function download() {

    local image="${1}"
    local ofile="${2}"

    echo "${FUNCNAME}: downloading image ${image}..."
    wget --output-document ${ofile} ${image}

    return $?

}

function tar_option() {


    local archive="${1}"
    local archive_type="$(file ${archive} | awk ' { print $2 } ')"
    local tar_opt

    case ${archive_type} in
        POSIX)
              tar_opt="" ;;
        XZ)
              tar_opt="--xz" ;;
        bzip2)
              tar_opt="--bzip2" ;;
        gzip)
	      tar_opt="--gzip" ;;
        *)
              echo "${FUNCNAME}: ${archive_type}: unknown archive type" 1>&2
              return 1
              ;;
    esac

    echo "${tar_opt}"

    return 0
}

function expand_rfs() {

    local rfs_archive="${1}"
    local rfs_src="${2}"
    local tar_compress_opt="$(tar_option ${rfs_archive})"
    
    mkdir ${rfs_src}
    sudo tar -xf ${rfs_archive} ${tar_compress_opt} -C ${rfs_src}
    if [ $? -ne 0 ] ; then
        return 1
    fi

    return 0
}

function do_init() {

    local tagref=${1}
    local kernel_tag

    echo "${FUNCNAME}: info: checking environment..."
    if ! check_vars ; then
        echo "${FUNCNAME}: error: please check your configuration file"
        return 1
    fi
    
    echo "${FUNCNAME}: downloading image ${BASE_IMAGE}..."
    download ${BASE_IMAGE} ${BASE_IMAGE_FILE}
    if [ $? -ne 0 ] ; then
       echo "${FUNCNAME}: error: could not download ${BASE_IMAGE}"
       return 1 
    fi

    echo "${FUNCNAME}: downloading image ${BASE_IMAGE}..."
    download ${RFS_URL} ${RFS_FILE}
    if [ $? -ne 0 ] ; then
       echo "${FUNCNAME}: error: could not download ${BASE_IMAGE}"
       return 1 
    fi
    
    echo "${FUNCNAME}: expanding rfs archive ${RFS_FILE}..."
    expand_rfs ${RFS_FILE} ${RFS_DIR}
    if [ $? -ne 0 ] ; then
        echo "${FUNCNAME}: error: could not expand ${RFS_FILE}"
        return 1
    fi

    rm -f ${RFS_FILE}

    return 0

}

function map_image() {

    local image="${1}"
    local part_offset="${2}"
    local size_limit="${3}"
    local size_limit_arg=""
    local lb_dev

    if [ -n "${size_limit}" ] ; then
        size_limit_arg="--sizelimit ${size_limit}"
    fi

    lb_dev=$(sudo losetup -s -f -o ${part_offset} ${size_limit_arg} ${image})
    if [ $? -ne 0 ] ; then
       return 1
    fi

    echo "${lb_dev}"

    return 0
}

function unmap_image() {
    
    local lb_dev="${1}"

    sudo losetup -d ${lb_dev} >/dev/null 2>&1

    return $?
}

function get_partition_field() {

    local lb_dev="${1}"
    local partition="${2}"
    local field_num="${3}"

    local field

    # /dev/loop0p2           43009     2140161     1048576+  83  Linux
    field=$(sudo fdisk -l ${lb_dev} | grep "$(basename ${lb_dev})p${partition}" | awk ' { print $'${field_num}' } ')  
    if [ $? -ne 0 ] || [ -z "${field}" ] ; then
        return 1
    fi

    echo "${field}"

    return 0
}

function get_partition_offset() {

    local lb_dev="${1}"
    local partition="${2}"
    local offset_sector

    # /dev/loop0p2           43009     2140161     1048576+  83  Linux
    offset_sector=$(get_partition_field ${lb_dev} ${partition} 2)  
    if [ $? -ne 0 ] || [ -z "${offset_sector}" ] ; then
        return 1
    fi

    echo $((512 * ${offset_sector}))

    return 0
}

function get_partition_size() {

    local lb_dev="${1}"
    local partition="${2}"
    local lb_dev
    local offset_start_sector
    local offset_end_sector

    offset_start_sector=$(get_partition_field ${lb_dev} ${partition} 2)  
    if [ $? -ne 0 ] || [ -z "${offset_start_sector}" ] ; then
        return 1
    fi

    offset_end_sector=$(get_partition_field ${lb_dev}  ${partition} 3)
    if [ $? -ne 0 ] || [ -z "${offset_end_sector}" ] ; then
        return 1
    fi

    echo $((512 * (${offset_end_sector} - ${offset_start_sector} + 1)))

    return 0
}


function do_build() {

    local part_offset
    local part_size
    local lb_dev

    echo "${FUNCNAME}: info: computing offset for partiton ${RFS_PART}..."
    lb_dev=$(map_image ${BASE_IMAGE_FILE} 0)
    if [ $? -ne 0 ] ; then
       echo "${FUNCNAME}: error: could not map image"
       return 1
    fi

    part_offset=$(get_partition_offset ${lb_dev} ${RFS_PART})
    if [ $? -ne 0 ] ; then
       echo "${FUNCNAME}: error: could not get partition offset"
       return 1
    fi

    part_size=$(get_partition_size ${lb_dev} ${RFS_PART})
    if [ $? -ne 0 ] ; then
       echo "${FUNCNAME}: error: could not get partition size"
       return 1
    fi

    unmap_image ${lb_dev}
    if [ $? -ne 0 ] ; then
       echo "${FUNCNAME}: error: could not unmap image"
       return 1
    fi

    echo "${FUNCNAME}: info: mapping image @ offset ${part_offset}..."
    lb_dev=$(map_image ${BASE_IMAGE_FILE} ${part_offset} ${part_size})
    if [ $? -ne 0 ] ; then
       echo "${FUNCNAME}: error: could not map image @ offset ${part_offset}"
       return 1
    fi

    echo "${FUNCNAME}: info: formatting partition ${RFS_PART}..."
    sudo mkfs.${RFS_FORMAT} ${lb_dev}
    if [ $? -ne 0 ] ; then
       echo "${FUNCNAME}: error: format failed"
       return 1
    fi

    echo "${FUNCNAME}: info: copying files from ${RFS_DIR}..."
    mkdir rfs_mnt
    if [ $? -ne 0 ] ; then
        echo "${FUNCNAME}: error: could not create mnt point"
        return 1
    fi
    sudo mount ${lb_dev} rfs_mnt
    if [ $? -ne 0 ] ; then
        echo "${FUNCNAME}: error: failed to mount dest rfs"
        return 1
    fi
    sudo cp -ra ${RFS_DIR}/* rfs_mnt/

    sudo umount rfs_mnt/
    if [ $? -ne 0 ] ; then
        echo "${FUNCNAME}: error: failed to umount dest rfs"
        return 1
    fi

    unmap_image ${lb_dev}
    if [ $? -ne 0 ] ; then
        echo "${FUNCNAME}: error: failed to unmap image (${lb_dev})"
        return 1
    fi

    return 0
}

function do_tag()  { 

    local tag=${1}
 
    echo "${FUNCNAME}: info: nada"

    return 0
}

function do_package() {

    local cwd=$(pwd)

    mkdir ${BINARIES} 
    if [ $? -ne 0 ] ; then
       echo "${FUNCNAME}: error: could not create bin directory"
       return 1
    fi

    mv ${BASE_IMAGE_FILE} ${BINARIES}/"sd-image-distro-${DISTRO}.img"

    cd ${cwd}

    return 0
    
}
