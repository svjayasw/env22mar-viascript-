#!/bin/bash

source $(dirname $0)/sync_repo_common.sh

function check_logs()
{
    echo
    date
    echo
    status='all ok'
    for logfile in $(ls log-*-sync.txt 2>/dev/null); do
	file_fail=

	fail_git=$(egrep -ic 'git.*fail|fail.*git' ${logfile} | cut -d: -f2)
	fail_denied=$(egrep -ic 'DENIED' ${logfile} | cut -d: -f2)
	fail_fetch=$(egrep -ic 'fetch.*fail|fail.*fetch' ${logfile} | cut -d: -f2)
	fail_push=$(egrep -ic 'push.*fail|fail.*push' ${logfile} | cut -d: -f2)
	fail_time=$(egrep -ic 'timed out' ${logfile} | cut -d: -f2)

	if [ $fail_denied -ne 0 ]; then
	    echo "${logfile} git fails (access DENIED) : ${fail_denied}"
	    file_fail=1
	    status='fail'
	fi
	if [ $fail_git -ne 0 ]; then
	    echo "${logfile} git fails : ${fail_git}"
	    file_fail=1
	    status='fail'
	fi
	if [ $fail_fetch -ne 0 ]; then
	    echo "${logfile} fetch fails : ${fail_fetch}"
	    file_fail=1
	    status='fail'
	fi
	if [ $fail_push -ne 0 ]; then
	    echo "${logfile} push fails : ${fail_push}"
	    file_fail=1
	    status='fail'
	fi
	if [ $fail_time -ne 0 ]; then
	    echo "${logfile} timed out : ${fail_time}"
	    file_fail=1
	    status='fail'
	fi
	if [ -z "$file_fail" ]; then
	    echo "${logfile} OK"
	fi
	echo
	
    done

    echo "subject:syncjob on $(hostname) report - ${status}"
}

function usage()
{
    echo "$(basename 0) [--email]"
}

#========================================================================

cd ~/syncjob || exit 1

EMAIL=
while [ -n "$1" ]; do
    case "$1" in
	--email ) EMAIL=1;;
	* ) usage;;
    esac
    shift
done

check="$(check_logs)"

if [ -z "${EMAIL}" ]; then
    echo "$check"
else
    if [ -n "${MAINTAINER}" ]; then
	subject=`echo "${check}" | grep 'subject:' | head -1 | cut -d: -f2`
	echo "$check" | \
	    grep -v 'subject:' | \
	    mail -s "${subject}" ${MAINTAINER}@intel.com
    fi
fi

exit 0
