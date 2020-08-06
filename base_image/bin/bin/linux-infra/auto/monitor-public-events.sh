#!/bin/bash

# Check "mirror-opensource"'s public events data using Github API
#
# If anything new pops up, log it
# todo send an email

url='https://api.github.com/users/mirror-opensource/events/public'

self_dir=$(dirname $0)
self_name=$(basename $0)
log_dir=$(realpath ${self_dir}/../../)
monitor_dir=$(realpath ${self_dir}/../../repos/mirror-investigation/)

cd $monitor_dir || exit 1

if [ -f public ]; then
    mv public baseline
fi

date="$(date +%Y%m%d-%H:%M:%S)"

rm -f wget-log.txt 2>/dev/null >/dev/null

wget ${url} 2>&1 | tee wget-log.txt

if [ ! -f public ]; then
    monitor_status="wget error"
    echo "${date} - ${monitor_status}"
    cp wget-log.txt ${log_dir}/public-wget-log-${date}.txt
    cat wget-log.txt | mail -s "${monitor_status} from ${self_name} running on $(hostname)" alan.tull@intel.com
    exit 0
fi

diff public baseline >/dev/null 2>/dev/null
if [ $? -eq 0 ]; then
    monitor_status="Nothing new"
    echo "${date} - ${monitor_status}"
    exit 0
fi

cp public ${log_dir}/public-${date}.txt
monitor_status="newness"
echo "${date} - ${monitor_status}"

cat public | mail -s "${monitor_status} from ${self_name} running on $(hostname)" alan.tull@intel.com

exit 0
