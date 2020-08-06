#!/bin/bash 

# internals
SELF=$(basename $0)
SELF_DIR=$(dirname $0)

# constants
CONST_RESULT_FORMAT_NUMS=numbers
CONST_RESULT_FORMAT_BIN=yesno

# defaults
DEF_RESULT_FORMAT=${CONST_RESULT_FORMAT_NUMS}
DEF_ONLINER=no

# variables
TRACE_FILE=
FUNCTION_FILE=
RESULT_FORMAT=${DEF_RESULT_FORMAT}
ONELINER=${DEF_ONLINER}

# functions
function help() {

	echo "usage: ${SELF} -t <trace file> -f <list of functions> [-c]"
	echo "-t file: specifies the trace file to use. No default"
	echo "-f file: specifies the list of functions (reference). No default"
        echo "-c     : shows yes or no for each function. Default is ${DEF_RESULT_FORMAT}"
	echo "-h     : this lovely message"

	return
}

function proc() {

        local dest="$1"

        if [ "${dest}" == "null" ] ; then
            cat >/dev/null
        else
            cat
        fi

        return
}

# option parsing
# script starts here
while [ $# -gt 0 ] ; do
    case $1 in
        -h) help; exit 0 ;;
        -c) RESULT_FORMAT=${CONST_RESULT_FORMAT_BIN} ;; 
        -d) ONELINER=yes ;; 
        -f) FUNCTION_FILE=$2 ; shift ;;
        -t) TRACE_FILE=$2 ; shift ;;
        *)  echo "${SELF}: error: unknown option ${1}" ; help ; exit ;;
    esac
    shift
done

# error checks
if [ -z "${FUNCTION_FILE}" ] ; then
    echo "${SELF}: error: no function file specified."
    help
    exit -1
else
    if [ ! -f "${FUNCTION_FILE}" -o ! -e "${FUNCTION_FILE}" ] ; then
        echo "${SELF}: ${FUNCTION_FILE}: no such file."
        exit -2
    fi
fi

if [ -z "${TRACE_FILE}" ] ; then
    echo "${SELF}: error: no trace file specified."
    help
    exit -1
else
    if [ ! -f "${TRACE_FILE}" -o ! -e "${TRACE_FILE}" ] ; then
        echo "${SELF}: ${TRACE_FILE}: no such file."
        exit -2
    fi
fi

# check going on
TRACE=$(egrep -v -e '^#' ${TRACE_FILE} | awk ' { print $4 } ')
if [ $? -ne 0 ] ; then
    echo "${SELF}: error: could not get the trace"
    exit -3
fi

FUNCTIONS=$(cat ${FUNCTION_FILE} | egrep -v -e "^#" | sort)
if [ $? -ne 0 ] ; then
    echo "${SELF}: error: could not get the functions"
    exit -3
fi

# we iterate over each function from the list and check the call count
if [ "${ONELINER}" == "yes" ] ; then
    dest=null
fi

not_called=1
for func in ${FUNCTIONS} ; do
    hits=$(grep -c ${func} ${TRACE_FILE})
    if [ -z ${hits} ] ; then
        hits=0
    fi
    if [ "${RESULT_FORMAT}" == "${CONST_RESULT_FORMAT_NUMS}" ] ; then
        echo ${func}:${hits}
        if [ ${hits} -eq 0 ] ; then
            not_called=1
        fi
    else
        if [ ${hits} -gt 0 ] ; then
            echo ${func}:yes
        else
            echo ${func}:no
            not_called=1
        fi
    fi
done | proc ${dest}






