#!/bin/bash

# Kill all processes running klocwork scans on this machine

killall -9 kw-auto.sh
killall -9 kw-auto.sh
killall -9 kw-scan.py
killall -9 kw-scan.py
sleep 2
for process in $(ps -ef|tr -s ' '|grep callbacks-kw|grep -v grep|cut -d' ' -f2); do
    echo ${process}
    kill -9 ${process}
done

echo Done!
exit 0
