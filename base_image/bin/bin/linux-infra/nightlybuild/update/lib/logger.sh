#  This is a library, do not run
#
#  Logger
ME=$(basename $0)
if [ "${ME}" == "logger.sh" ] ; then
    echo "$ME: error: can't run this script standalone"
    exit -1
fi

# Constants
CONST_LOG_STYLE_LOGGER=logger
CONST_LOG_STYLE_FILE=file
 
DO_LOG=no
LOG_DATA=""
LOG_STYLE=""

function enable_log() {

    local logger=$1
    
    case ${logger} in
        -f) LOG_DATA=$2 ; LOG_STYLE=${CONST_LOG_STYLE_FILE} ;;
        -l) LOG_DATA=$2 ; LOG_STYLE=${CONST_LOG_STYLE_LOGGER} ;;  
        *)  echo "${ME}: error: ${logger}: illegal option" ; exit -100 ;;
    esac

    if [ "X${LOG_DATA}" == "X" ] ; then
        echo "${ME}: error: no argument given"
	exit -101
    fi

    DO_LOG=yes
}

function disable_log() {

    LOG_DATA=""
    LOG_STYLE=""
    DO_LOG=no
}

function log() {
     
    local ret=0

    if [ ${DO_LOG} == "yes" ] ; then
        case ${LOG_STYLE} in
          ${CONST_LOG_STYLE_LOGGER})
                logger -t ${LOG_DATA} $@  ; ret=$? ;;
          ${CONST_LOG_STYLE_FILE})
                case ${LOG_DATA} in
                  stdout) echo $@ >&1 ; ret=$? ;;
                  stderr) echo $@ >&2 ; ret=$? ;; 
                  *) echo $@ >> ${LOG_DATA} ; ret=$? ;;
                esac ;;
          *)
                echo "${ME}: error: ${LOG_STYLE}: unknown log mode. Not logging."  ; ret=1 ;;
        esac
    fi

    return ${ret}

}

#  same as log, but reads from stdin
function log_in() {

    local ret=0

    if [ ${DO_LOG} == "yes" ] ; then
        case ${LOG_STYLE} in
          ${CONST_LOG_STYLE_LOGGER})
                logger -t ${LOG_DATA} ; ret=$? ;;
          ${CONST_LOG_STYLE_FILE})
                case ${LOG_DATA} in
                  stdout) cat >&1 ; ret=$? ;;
                  stderr) cat >&2 ; ret=$? ;;
                  *) cat >> ${LOG_DATA} ; ret=$? ;;
                esac ;;

          *)
                echo "${ME}: error: ${LOG_STYLE}: unknown log mode. Not logging." ; ret=1 ;;
        esac
    fi

    return ${ret}
}

