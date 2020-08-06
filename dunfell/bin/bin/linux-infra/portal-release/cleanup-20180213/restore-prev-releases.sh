#!/bin/bash

cd ~/repos/internal/linux-socfpga || exit 1
pwd

let tag_cnt=0
let br_cnt=0
for line in $(grep '^branch:' ~/bin/linux-infra/portal-release/cleanup-20180213/portal-status-20180213.txt) \
		$(grep '^tag:' ~/bin/linux-infra/portal-release/cleanup-20180213/portal-status-20180213.txt); do

    what=$(echo ${line} | cut -d: -f1)
    descr=$(echo ${line} | cut -d: -f2)
    name=$(echo ${line} | cut -d: -f3 | sed 's#origin/##')
    
    if [ -z "${what}" ] || [ -z "${descr}" ] || [ -z "${name}" ]; then
        echo "error: ${line} : what=${what}  descr=${descr} name=${name}"
	exit
    fi

    case ${what} in
	'tag' )
	    dest='tags'
	    let tag_cnt=tag_cnt+1
	    ;;
	'branch' )
	    dest='heads'
	    let br_cnt=br_cnt+1
	    ;;
	* ) print "$line"; print 'what?' ; exit 1
    esac

    echo
    echo "${br_cnt} branches ; ${tag_cnt} tags"
    echo "git push --dry-run portal ${descr}:refs/${dest}/${name}"
    continue
    git push --dry-run portal ${descr}:refs/${dest}/${name}
    if [ $? -ne 0 ]; then
	echo error
	exit
    fi
    
done
echo
echo 'Done'
