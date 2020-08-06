#!/bin/bash
#
# git portal tests
#  * clone using git:// and http://
#  * check time it takes to clone
#

# All time units in this script are integer seconds.  So if a
# repo clones in < 1 seconds, that's 0 seconds.

#========================================================================
# Constants

declare -r SELF=$(basename $0)

# For reference I just did a http clone of linux-socfpga in 14.9 minutes
# (894 seconds)
declare -r CLONE_TIME_LIMIT=1800

# Note that linux-tags is an internal repo, so use gitolite for it only.
declare -r LINUX_TAGS_REPO_PATH=gitolite@at-git:linux-tags
declare -r RELEASE_CONFIG=$PWD/linux-tags/release-branch-config.sh

# Note that bash has a built in 'time' function. We don't want that.
# We want to use the one on the filesystem as it has more parameters.
declare -r TIME="$(which time)"
if [ -z "$TIME" ]; then
    echo "FAIL - time is not installed in this distribution."
    exit 1
fi

#========================================================================
# functions

usage()
{
cat <<EOF
usage: $SELF [-d]

-d = Development mode (run faster)
EOF
exit 1
}

function do_timeout() {
    local pid=$1
    local timeout=$CLONE_TIME_LIMIT

    while true; do
	kill -s 0 $pid >/dev/null 2>/dev/null
	if [ $? -ne 0 ]; then
	    # pid finished before timeout. Use 'wait' to get return code.
	    wait $pid
	    #echo "process return code was $?"
	    if [ $? -eq 0 ]; then
		return 0
	    fi

	    return 2
	fi

	let timeout=timeout-1
	if [ "$timeout" -le 0 ]; then
	    #echo "timeout"
	    kill -9 $pid >/dev/null 2>&1
	    return 1
	fi

	sleep 1
    done
}

time_clone()
{
    local repo_path=$1
    local repo_name=$2
    local clone_to_dir=$3

    declare -i time_limit_sec=$CLONE_TIME_LIMIT
    declare -i clone_time

    CMD="git clone $repo_path $clone_to_dir"
    echo "$CMD"
    $CMD &
    do_timeout $!
    case $? in
	2 ) echo "FAIL - git clone failed: $repo_path"
	    status_fail=1
	    ;;
	1 ) echo "FAIL - git clone timed out: $repo_path"
	    status_fail=1
	    ;;
	0 ) ;;
    esac
}

#==========================================================================
status_fail=0

DEVELOPMENT_TEST_FASTER=

while [ -n "$1" ]; do
    case $1 in
	# For if I'm developing and want to skip cloning the larger repos...
	-d ) DEVELOPMENT_TEST_FASTER=1 ;;
	* ) usage ;;
    esac
    shift
done

# Clone linux-tags repo so we know what to clone and
# path to each repo
echo "Cloning linux-tags:"
time_clone $LINUX_TAGS_REPO_PATH linux-tags linux-tags
# Can't run the rest of the test if this clone failed
if [ $status_fail -ne 0 ] ; then
    exit 1
fi
. $RELEASE_CONFIG

mkdir http git

# Clone each repo using git:// and http://, check how
# long it takes
for repo in $(echo $repo_list|tr -s ',' ' '); do
    # get gitolite address from config file.  Format is gitolite@SERVER:REPO
    portal_gitolite="$(grep ^$repo $RELEASE_CONFIG | cut -d',' -f2)"
    if [ -z "$portal_gitolite" ]; then
	echo "Skipping non-portal repo: $repo"
	continue
    fi
    if [ -n "$DEVELOPMENT_TEST_FASTER" ] && [[ "$repo" =~ 'socfpga' ]]; then
	echo "Skipping repo: $repo"
	continue
    fi

    portal_server="$(echo $portal_gitolite|sed 's,gitolite@,,'|cut -d: -f1)"
    portal_repo="$(echo $portal_gitolite|sed 's,gitolite@,,'|cut -d: -f2)"

    portal_http="http://${portal_server}/${portal_repo}.git"
    portal_git="git://${portal_server}/${portal_repo}"

    echo "Cloning portal repo using http: $portal_repo"
    time_clone $portal_http $portal_repo http/${portal_repo}
    echo

    echo "Cloning portal repo using git: $portal_repo"
    time_clone $portal_git $portal_repo git/${portal_repo}
    echo
done

# Cleanup
echo "Cleaning up..."
rm -rf http git linux-tags time-*.txt

echo
if [ $status_fail -ne 0 ]; then
    echo "${SELF}: test failed!"
else
    echo "${SELF}: test pass"
fi
exit $status_fail
