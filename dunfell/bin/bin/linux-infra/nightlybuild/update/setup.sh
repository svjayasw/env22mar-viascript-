#!/bin/bash -xe

# Set up for automatic klocwork scans

mkdir ~/klocwork-cronjob
cd ~/klocwork-cronjob
git clone gitolite@at-git.intel.com:linux-infra

echo "need to:"
echo " crontab ~/klocwork-cronjob/linux-infra/nightlybuild/update/cronjob-kw"

echo "Done"
