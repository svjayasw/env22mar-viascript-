#!/bin/bash

MOD_UTILS="utils.sh"

if [ "$0" != "-bash" ] && [ "$(basename $0)" == "${MOD_UTILS}" ] ; then
    echo "${MOD_UTILS}: error: this is not meant to run as a standalone script"
    echo "Usage: source ${MOD_UTILS}"
    exit 0
fi

function set-title () 
{ 
    if [[ -z "$ORIG" ]]; then
        ORIG=$PS1;
    fi;
    TITLE="\[\e]2;$@\a\]";
    PS1=${ORIG}${TITLE};
    return 0
}

