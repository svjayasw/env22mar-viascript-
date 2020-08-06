#!/bin/bash

usage()
{
    echo "$(basename $0) [-f]"
    echo " by default, saves off logs > 2M"
    echo " -f = save off all logs"
}

#===============================================

maxsize="-size +2M"
while [ -n "$1" ]; do
    case "$1" in
	-f ) maxsize="";;
	* ) usage ; exit 0;;
    esac
    shift
done

log_dir=~/syncjob

cd $log_dir || exit 1

datest="$(date -I)"

if [ ! -d 'olde' ]; then
    mkdir olde
fi
if [ ! -d "olde/${datest}" ]; then
    mkdir olde/${datest}
fi

biglogs="$(find . -maxdepth 1 -name 'log*.txt' $maxsize) $(find . -maxdepth 1 -name 'public*.txt' $maxsize)"
for log in $biglogs; do
    mv $log olde/${datest}/
done
