#!/bin/bash

sync_dir=~/syncjob
sync_logs=${sync_dir}
sync_infra=${sync_dir}/linux-infra/auto

function usage()
{
    echo "$(basename $0) [-h][-l][--all][list of repos]"
    echo " -l    : list projects available for sync"
    echo " --all : sync all projects"
    echo " or specify one or more projects to sync."
}

function list_repos()
{
    cd $sync_infra || exit 1
    ls -1 *-sync | sed 's/-sync//'
}

function add_sync_repo()
{
    # can be specified with or without -sync
    project=$(echo ${1} | sed 's/-sync//')
    
    # translation table for some repo names
    case "$project" in
	linux-socfpga ) project='linux-kernel' ;;
	uboot* ) project='uboot uboot-socfpga' ;;
	* )
	    if [ ! -e "${sync_infra}/${project}-sync" ]; then
		echo "Error: expecting a repo name here, got $1"
		exit 1
	    fi ;;
    esac

    sync_repos="${sync_repos} ${project}"
}

function add_all_repos()
{
    sync_repos="$(list_repos)"
}

sync_repos=
while [ -n "$1" ]; do
    case "$1" in
	-h ) usage; exit;;
	-l ) list_repos; exit;;
	--all ) add_all_repos ;;
	* )  add_sync_repo $1;;
    esac
    shift
done

for repo in ${sync_repos}; do
    echo ${repo}

    # ~/syncjob/linux-infra/auto/linux-kernel-sync 2>&1 | tee -a ~/syncjob/log-linux-kernel-sync.txt

    ${sync_infra}/${repo}-sync 2>&1 | tee -a ${sync_logs}/log-${repo}-sync.txt

    echo
done

exit 0
