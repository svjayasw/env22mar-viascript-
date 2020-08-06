#!/bin/bash

# These utils are used in several linux-infra scripts.  Change them carefully
# or you will break the sync job and other scripts.

# Don't allow running more than 1 instance of this script at a time.
# If we succeed in getting the lock, return.  Otherwise, exit.
script_lock()
{
	# Lock does not exist, so grab the lock.
	if [ ! -f /tmp/${SELF}.lock ] ; then
		printf "%s\n%s\n" $$ $CRONLOG > /tmp/${SELF}.lock
		if [ "$$" = "$(head -1 /tmp/${SELF}.lock)" ]; then
			return
		fi
	fi

	# the lock file already exists, check to see if script still running.
	LOCK_PID=$(head -1 /tmp/${SELF}.lock)
	if [ "$(ps --no-header -p $LOCK_PID | wc -l)" = 0 ]; then
		# process not running, but lock file not deleted.
		printf "%s\n%s\n" $$ $CRONLOG > /tmp/${SELF}.lock
		return
	fi

	# Other instance of sync_repo is still running.
	exit 0
}

unlock_exit()
{
	rm -f /tmp/${SELF}.lock
	exit
}

get_repo_setting()
{
    repo_name=$1
    setting_name=$2
    if [ -z "$REPO_SETTINGS" ]; then
	echo "Don't know path to repo settings!"
	exit 1
    fi
    if [ ! -f "${REPO_SETTINGS}/${repo_name}" ]; then
	echo "No repos settings for this repo"
	exit 1
    fi
    grep ${setting_name}: ${REPO_SETTINGS}/${repo_name} | cut -d' ' -f2
}

cd_to_clone()
{
    cloned_repos_dir=$1
    git_upstream=$2

    if [ -z "$cloned_repos_dir" ] || [ -z "$git_upstream" ]; then
	echo "Function needs git upstream path"
	exit 1
    fi

    if echo $git_upstream | grep -sq gitolite; then
        REPO_DIR="${cloned_repos_dir}/$(echo $git_upstream | cut -d: -f2)"
    else
        REPO_DIR="${cloned_repos_dir}/$(basename $git_upstream)"
    fi

    cd $REPO_DIR
}

update_or_clone_repo()
{
    cloned_repos_dir=$1
    git_upstream=$2

    if [ -z "$cloned_repos_dir" ] || [ -z "$git_upstream" ]; then
	echo "Function needs git upstream path"
	exit 1
    fi

    if echo $git_upstream | grep -sq gitolite; then
        REPO_DIR="${cloned_repos_dir}/$(echo $git_upstream | cut -d: -f2)"
    else
        REPO_DIR="${cloned_repos_dir}/$(basename $git_upstream)"
    fi

    # If repo exists and is in reasonable shape, do the fetch
    # Note that 'git status' doesn't work on a bare repo, so use 'git branch' to check repo.
    if [ -d "$REPO_DIR" ]; then
	if cd $REPO_DIR && git branch >/dev/null 2>/dev/null; then
	    # This failure may be due to the upstream server being monentarily funky.
	    # catch this failure so that script won't exit due to "/bin/bash -e" option.
	    if ! git fetch --tags origin || ! git fetch origin; then
		echo "git fetch for $git_upstream failed!"
	    fi
	else
	    # Something wrong with repo, delete and start over.
	    rm -rf $REPO_DIR
	fi
    fi

    # Repo doesn't exist or was corrupted and was just deleted.  So clone it.
    if [ ! -d "$REPO_DIR" ]; then
	cd $cloned_repos_dir
	REPO_CMD="git clone --mirror $git_upstream"
	echo "$REPO_CMD"
	$REPO_CMD
	cd $REPO_DIR
    fi
}

# Allow us to run w/o actually doing pushing
do_cmd()
{
	REPO_CMD="$@"
	echo "$REPO_CMD"
	if [ -z "$DRY_RUN" ]; then
	    $REPO_CMD
	fi
}

push_tags_only()
{
    dest_git_server=$1
    shift
    for repo in $@; do
	echo
	do_cmd "git push --tags ${dest_git_server}:${repo}.git"
    done
}

push_upstream_tags_regex()
{
    regex=$1
    dest_git_server=$2
    shift; shift
    for tag in $(git tag | grep -v tree | egrep $regex); do
	for repo in $@; do
	    echo
	    do_cmd "git push ${dest_git_server}:${repo}.git ${tag}:refs/tags/${tag}"
	done
    done
}

push_tags_and_master_branch()
{
    dest_git_server=$1
    shift
    for repo in $@; do
	echo
	do_cmd "git push --tags ${dest_git_server}:${repo}.git master:master"
    done
}

# for the stable kernel, we want to grab the linux-3.xxxx branches for
# current development
push_linux3xx_branches()
{
    dest_git_server=$1
    shift
    for branch in $(git branch | grep linux-3 | sed 's/*/ /'); do
	for repo in $@; do
	    echo
	    do_cmd "git push ${dest_git_server}:${repo}.git ${branch}"
	done
    done
}

# Normally push -f isn't needed, but this is for the poky tree, not linux
push_all_branches()
{
    dest_git_server=$1
    shift
    for branch in $(git branch | sed 's/*/ /'); do
	for repo in $@; do
	    echo
	    do_cmd "git push -f ${dest_git_server}:${repo}.git ${branch}"
	done
    done
}

push_tag_to_branch()
{
    rel_tag=$1
    shift
    rel_branch=$1
    shift
    dest_git_server=$1
    shift
    for repo in $@; do
	echo
	do_cmd "git push ${dest_git_server}:${repo}.git ${rel_tag}:refs/tags/${rel_tag}"
	do_cmd "git push ${dest_git_server}:${repo}.git ${rel_tag}:refs/heads/${rel_branch}"
    done
}

push_tag()
{
    rel_tag=$1
    shift
    dest_git_server=$1
    shift
    for repo in $@; do
	echo
	do_cmd "git push ${dest_git_server}:${repo}.git ${rel_tag}:refs/tags/${rel_tag}"
    done
}

push_branch()
{
    rel_branch=$1
    shift
    dest_git_server=$1
    shift
    for repo in $@; do
	echo
	do_cmd "git push ${dest_git_server}:${repo}.git ${rel_branch}:refs/heads/${rel_branch}"
    done
}

tag_repo()
{
    rel_tag=$1
    rel_branch=$2
    do_cmd "git tag $rel_tag $rel_branch"
}

check_for_tag()
{
    rel_tag=$1
    rel_branch=$2

    ret="$(git tag | grep "^${rel_tag}$")"
    if [ $? -ne 0 ] || [ "$rel_tag" != "$ret" ]; then
	echo "Tag $rel_tag not found for repo $(basename $PWD)"
	return 1
    fi

    if ! git branch | grep -sq "^  ${rel_branch}$"; then
	echo "Branch $rel_branch not found for repo $(basename $PWD)"
	return 1
    fi

    if ! git branch --contains $rel_tag | grep -sq "^  ${rel_branch}$"; then
	echo "Tag $rel_tag not on branch $rel_branch for repo $(basename $PWD)"
	return 1
    fi
    
    return 0
}