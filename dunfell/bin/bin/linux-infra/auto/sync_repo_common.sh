#!/bin/bash

# This file is common code that is used by the individual sync job scripts.

# This gets the name of the individual sync job script
SELF="$(basename $0)"
SELF_PATH="$(dirname $0)"

. ${SELF_PATH}/proxyon

# send emails to ${MAINTAINER}@intel.com
MAINTAINER=alan.tull

# Where we have the repo mirror clones
export SYNC_REPOS=~/syncjob/repos/$SELF

# Path to repos on our server
export ALTERA_GIT_SERVER='gitolite@at-git.intel.com:'

# Path to our *external* portal server.  Careful now...
export ROCKETBOARDS_GIT_SERVER='git@github.com:altera-opensource/'

GIT_PUSH="git push -f"
#GIT_PUSH="git push --dry-run --verbose"

export PATH=$PATH:/sbin:/usr/sbin:/usr/bin

if [ ! -d "$SYNC_REPOS" ]; then
    mkdir -p $SYNC_REPOS
fi

#==================================================================================

# Don't allow running more than 1 instance of this script at a time.
# If we succeed in getting the lock, return.  Otherwise, exit.
script_lock()
{
    if [ -z "$lock_filename" ]; then
	echo "ERROR: script_lock needs a lock name"
	exit 1
    fi

    # Lock does not exist, so grab the lock.
    if [ ! -f /tmp/$lock_filename ] ; then
        printf "%s\n%s\n" $$ $CRONLOG > /tmp/$lock_filename
        if [ "$$" = "$(head -1 /tmp/$lock_filename)" ]; then
            return
        fi
    fi

    # the lock file already exists, check to see if script still running.
    LOCK_PID=$(head -1 /tmp/$lock_filename)
    if [ "$(ps --no-header -p $LOCK_PID | wc -l)" = 0 ]; then
        # process not running, but lock file not deleted.
        printf "%s\n%s\n" $$ $CRONLOG > /tmp/$lock_filename
        return
    fi

    # Other instance of sync_repo is still running.
    exit 0
}

unlock_exit()
{
    rm -f /tmp/$lock_filename
    exit
}

error_exit()
{
    if [ -n "$MAINTAINER" ]; then
	echo "Error on or near line ${1}" | mail -s "Error in sync job" $MAINTAINER@intel.com
    fi
    exit 1
}

cd_or_clone()
{
    GIT_UPSTREAM=$1
    echo "Upstream : $GIT_UPSTREAM"
#    whoami
#    set|grep -i proxy

    if [ -z "$GIT_UPSTREAM" ]; then
	echo "Function needs git upstream path"
	exit 1
    fi

    REPO_DIR="${SYNC_REPOS}/$(basename $GIT_UPSTREAM)"

    # If repo exists and is in reasonable shape, do the fetch
    # Note that 'git status' doesn't work on a bare repo, so use 'git branch' to check repo.
    if [ -d "$REPO_DIR" ]; then
	if cd $REPO_DIR && git branch >/dev/null 2>/dev/null; then
            # This failure may be due to the upstream server being monentarily funky.
            # catch this failure so that script won't exit due to "/bin/bash -e" option.
	    echo "git fetch --tags origin"
            if ! git fetch --tags origin; then
		echo "git fetch for $GIT_UPSTREAM failed!"
            fi
	    echo "git fetch origin"
            if ! git fetch origin; then
		echo "git fetch for $GIT_UPSTREAM failed!"
            fi
	else
            # Something wrong with repo, delete and start over.
            rm -rf $REPO_DIR
	fi
    fi

    # Repo doesn't exist or was corrupted and was just deleted.  So clone it.
    if [ ! -d "$REPO_DIR" ]; then
	cd $SYNC_REPOS
	REPO_CMD="git clone --mirror $GIT_UPSTREAM"
	echo "$REPO_CMD"
	$REPO_CMD 2>&1 || error_exit ${LINENO}
	cd $REPO_DIR || error_exit ${LINENO}
    fi
}

push_tags_only()
{
    for repo in $@; do
	echo
	REPO_CMD="$GIT_PUSH --tags ${ALTERA_GIT_SERVER}${repo}.git"
	echo "$REPO_CMD"
	$REPO_CMD 2>&1 | sed '/\033/,/\033/d'
    done
}

push_tags_and_master_branch()
{
    for repo in $@; do
	echo
	REPO_CMD="$GIT_PUSH --tags ${ALTERA_GIT_SERVER}${repo}.git master:master"
	echo "$REPO_CMD"
	$REPO_CMD 2>&1 | sed '/\033/,/\033/d'
    done
}

push_tags_and_master_branch_portal()
{
    for repo in $@; do
	echo
	REPO_CMD="$GIT_PUSH --tags ${ROCKETBOARDS_GIT_SERVER}${repo}.git master:master"
	echo "$REPO_CMD"
	$REPO_CMD 2>&1 | sed '/\033/,/\033/d'
    done
}

# Normally push -f isn't needed, but this is for the poky tree, not linux
push_all_branches()
{
    for branch in $(git branch | sed 's/*/ /'); do
	for repo in $@; do
            echo
            REPO_CMD="$GIT_PUSH ${ALTERA_GIT_SERVER}${repo}.git ${branch}"
            echo "$REPO_CMD"
            $REPO_CMD 2>&1 | sed '/\033/,/\033/d'
	done
    done
}

push_branches_matching()
{
    match=$1
    shift
    for branch in $(git branch | grep "${match}" | sed 's/*/ /'); do
	for repo in $@; do
            echo
            REPO_CMD="$GIT_PUSH ${ALTERA_GIT_SERVER}${repo}.git ${branch}"
            echo "$REPO_CMD"
	    $REPO_CMD 2>&1 | sed '/\033/,/\033/d'
	done
    done
}

push_master_branch_renamed_to()
{
    renamed=$1
    shift
    for repo in $@; do
	echo
	REPO_CMD="$GIT_PUSH -f ${ALTERA_GIT_SERVER}${repo}.git master:refs/heads/${renamed}"
	echo "$REPO_CMD"
	$REPO_CMD 2>&1 | sed '/\033/,/\033/d'
    done
}
