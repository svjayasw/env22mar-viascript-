#!/bin/bash

function usage()
{
    echo "$(basename $0) [--type <release type>] [--rel <release num>][--continue]"
    echo "  check that all of pr release is reachable via gitweb"
    echo "  --continue  -  test all url's even if there are failures"
}

#===================================================================

rel_type='Linux'
keep_going=
while [ -n "${1}" ]; do
    case "${1}" in
	-h ) usage; exit ;;
	--type ) rel_type=$2; shift;;
	--continue ) keep_going=1 ;;
	--rel ) rel=$2; shift;;
	* ) echo what? ; usage ; exit ;;
    esac
    shift
done

tempdir=$(basename $0)-${RANDOM}${RANDOM}${RANDOM}${RANDOM}

if [ -z "${rel}" ]; then
    rel=$(grep '^rel=' ~/.portal-update-${rel_type}.conf | cut -d= -f2)
fi
rel_num=$(echo $rel | cut -d_ -f1)
log=~/bin/linux-infra/portal-release/${rel_num}/${rel}-log.txt

echo "release : $rel"
echo "rel num : $rel_num"
echo "log     : $log"
echo

mkdir /tmp/$tempdir || exit 1
cd /tmp/$tempdir || exit 1

let errs=0
while read line; do
    if echo $line | grep -sqE 'https'; then
	echo "$line"
	echo "----------------------------------------------------------------------"
	url=$(echo $line |cut -d: -f2-)
        echo "wget $url"
	wget $url
	if [ $? -ne 0 ]; then
	    let errs=errs+1
	    echo "Error wget $url"
	    if [ -z "${keep_going}" ]; then
		exit 1
	    fi
	else
	    echo OK
	fi
	echo "==========================================================================="
    fi
done < $log

case "$errs" in
    0 ) echo "Success!";;
    * ) echo "Errors: $errs";;
esac

cd ~
rm -rf /tmp/$tempdir

exit

