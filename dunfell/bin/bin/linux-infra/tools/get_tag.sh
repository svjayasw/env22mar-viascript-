#!/bin/bash
set -x

SELF=$(basename $0)

function usage() {
    
    echo "Usage: ${SELF} [-h] -r repo -b branch [-l tag_file ] |  [-p prefix -s suffix]"
    echo "-h         : this message"
    echo "-r repo    : specifies the repo name,e.g. linux-socfpga. Mandatory"
    echo "-b branch  : specifies the branch name, e.g. socfpga-3.12"
    echo "-l tag_file: specifies the tag file to be used. can't be used with -s and -p"
    echo "-p prefix  : specifies the tag prefix to be used. Can't be used with -l. Must be used with -s"
    echo "-s suffix  : specifies the tag suffix to be used. Can't be used with -l. Must be used with -p"

    return 0
}

while [ ! -z "$1" ]; do
    case $1 in
        -h) usage
            exit 0
            ;;
        -r ) repo=$2 ;;
        -b ) branch=$2 ;;
        -p ) prefix=$2 ;;
        -s ) suffix=$2 ;;
        -l ) list=$2 ;;
        *) echo "${SELF}: $1: unknown option!" 
           exit 1 
           ;;
    esac
    shift
    shift
done

if [ -z "$repo" -o -z "$branch" ]; then
    echo "${SELF}: error: repo and branch have always to be specified"
    exit 1
fi

if [ -n "$list" ]; then
    if [ -n "$suffix" -o -n "$prefix" ]; then
        echo "${SELF}: error: list excludes prefix and suffix"
        exit 2
    fi
    tag="$(egrep -e ^${repo}: ${list} | grep ${branch}_  | awk -F: ' { print $2 } ')"
else
    if [ -z "$prefix" -o -z "$suffix" ]; then
        echo "${SELF}: error: prefix and suffix must be specified"
        exit 3
    fi
    tag="${prefix}_${branch}_${suffix}"
fi

if [ "$(echo $tag | wc -w)" != 1 ]; then
    echo "${SELF}: error: only one tag exopected!"
    exit 4
fi

echo ${tag}


