#!/bin/bash -e

cd ~/klocwork-cronjob

cronjob_dir=~/klocwork-cronjob
repos_dir=${cronjob_dir}/repos
results_dir=${cronjob_dir}/results

echo results:
ls ${results_dir}
echo

for foo in $(ls ${repos_dir}); do
    if [ -d ${repos_dir}/${foo}/.git ]; then
	repo=$(basename $PWD)
	if [ ${repo} == 'linux-tags' ]; then
	    continue
	fi
	cd ${repos_dir}/${foo}
	pwd
	git branch | grep '^*' | cut -c3-
    fi
done

exit 0
