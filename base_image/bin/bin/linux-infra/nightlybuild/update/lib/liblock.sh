#!/bin/bash

# Goal
#   provide an API to lock on a system resource.
# 
# API
#   grab lock, synch or asynchronous
#   release lock.
#
# The implementation relies on the lockfile-{create, touch, remove} utilities.
#

# Internals
declare -r LOCK_API_VERSION="0.5.0"
declare -r LOCK_API_SELF="liblock.sh"
# LOCK_DB is the list of locks. A lock is defined
# as a pair of lock file and a pid
# - the lock file is the resource name provided by an application
# - each lock file is under the 'supervision' of an instance of lockfile-touch
#   running in the background. The PID of lockfile-touch associated with the lock file
#   is saved here.
# The format is [lock file name] [pid]
declare -r LOCK_DB="/tmp/lock_db"
declare -r LOCK_DB_LOCK="/tmp/lock_db_lock"


# This file is a library, not a standalone executable
if [ "$(basename $0)" == "${LOCK_API_SELF}" ] ; then
    (
     echo "${LOCK_API_SELF}: error: this file is not meant to be a standalone executable" 
     usage_liblock
     exit 1
    )>&2
fi

# reset any alias...
unalias lockfile-create lockfile-touch lockfile-check lockfile-remove 2>/dev/null

###############################################################################
# Usage 
###############################################################################
function usage_liblock() {

    echo "${LOCK_API_SELF}, version ${LOCK_API_VERSION}"
    echo "Usage: source ${LOCK_API_SELF}"
    echo 
    echo " User functions:"
    echo "    grab_lock()"
    echo "    release_lock()"

    return
}

###############################################################################
# Internal Functions
###############################################################################
# function __lock_remove()
# Kill the touch process for the given lock and remove the lock file.
# Does not return anything.
function __lock_remove() {

    local lock_file="$1"
    local lock_pid="$2"

    kill -9 ${lock_pid}
    wait ${lock_pid} 2>/dev/null
    lockfile-remove ${lock_file}

    return $?
}

# function __lock_create()
# Create the lock, start a background thread to touch the lock once a minute.
# Return the pid of the lockfile-touch thread
function __lock_create() {

    local lock_file="$1"
    local err

    lockfile-create ${lock_file}
    if [ $? -ne 0 ] ; then
        return 1
    fi

    # The lock file needs to be touched periodically
    # in order to keep it valid.
    # The process is run in the background
    # Note: redirection to avoid to stall of caller
    lockfile-touch ${lock_file} >/dev/null 2>&1 & 
    err=$?

    echo $!     # return pid

    return ${err}
}

# function __save_lock_to_db()
# Saves a lock to the database of locks
# Access to the database is protected 
function __save_lock_to_db() {

    local lock_file="$1"
    local lock_pid="$2"

    local pid

    # grab the database lock
    pid=$(__lock_create ${LOCK_DB_LOCK})
    if [ $? -ne 0 ] ; then
        echo "${LOCK_API_SELF}: ${FUNCNAME}: internal error: failed to grab lock database" >&2
        __lock_remove ${LOCK_DB_LOCK} ${pid}
        return 1
    fi

    # Let's check if the lock is already in the database,
    # if that's the case, then something's wrong!
    # To search for the exact lock_file, a space is added to the search
    # pattern
    if [ -f ${LOCK_DB} ] &&
       grep -q "^${lock_file} " ${LOCK_DB} ; then
        echo "${LOCK_API_SELF}: ${FUNCNAME}: internal error: lock ${lock_file} already grabbed!" >&2
	__lock_remove ${LOCK_DB_LOCK} ${pid}
        return 1
    fi

    # Add lock file and pid to the lock db file
    echo "${lock_file} ${lock_pid}" >> ${LOCK_DB}

    # release the database lock
    __lock_remove ${LOCK_DB_LOCK} ${pid}

    return $?
}

# function __remove_lock_from_db()
# Removes a lock from the database of locks
# Access to the database is protected 
# Returns the PID of the touch process attached to the lock removed
function __remove_lock_from_db() {

    local lock_file="$1"

    local lock_pid
    local pid

    # grab the database lock
    pid=$(__lock_create ${LOCK_DB_LOCK})
    if [ $? -ne 0 ] ; then
        echo "${LOCK_API_SELF}: ${FUNCNAME}: internal error: failed to grab lock database" >&2
        __lock_remove ${LOCK_DB_LOCK} ${pid}
        return 1
    fi

    # now, let's check that the lock is in the DB!
    # To search for the exact lock_file, a space is added to the search
    # pattern
    if ! grep -q "^${lock_file} " ${LOCK_DB} ; then
        echo "${LOCK_API_SELF}: ${FUNCNAME}: internal error: lock ${lock_file} not grabbed!" >&2
        __lock_remove ${LOCK_DB_LOCK} ${pid}
        return 1
    fi

    lock_pid=$(grep "${lock_file} " ${LOCK_DB} | awk ' { print $2 } ')
    if [ -z ${lock_pid} ] ; then
        echo "${LOCK_API_SELF}: ${FUNCNAME}: internal error: failed to get pid for lock ${lock_file}" >&2
	__lock_remove ${LOCK_DB_LOCK} ${pid}
        return 1
    fi

    # Remove the one line from lock database file which has the lock and pid
    sed -i -r 's#^'${lock_file} '.*$##' ${LOCK_DB}
    sed -i '/^ *$/d' ${LOCK_DB}

    # return the pid to caller
    echo ${lock_pid}
 
    # release the lock on database
    __lock_remove ${LOCK_DB_LOCK} ${pid}

    return $?
}

###############################################################################
# User Functions
###############################################################################

# function grab_lock()
#  $1 = lock file to be used
#
#  returns 0 on success, something else on failure
#
function grab_lock() {

    local lock_file="$1"
    local pid

    # now go grab the lock
    # we may sleep here of the lock is already taken
    pid=$(__lock_create ${lock_file})
    if [ $? -ne 0 ] ; then
        echo "${LOCK_API_SELF}: ${FUNCNAME}: error: could not grab lock ${lock_file}" >&2
        __lock_remove ${lock_file} ${pid} 
        return 1
    fi

    # now we need to keep track of the pid/lock combination
    __save_lock_to_db "${lock_file}" "${pid}"
    if [ $? -ne 0 ] ; then
        echo "${LOCK_API_SELF}: ${FUNCNAME}: internal error: failed to save lock/pid!" >&2
	__lock_remove ${lock_file} ${pid}
        return 2
    fi

    return 0
}

# function release_lock()
#  $1 = lock file to be used
#
#  returns 0 on success, something else on failure
#
function release_lock() {

    local lock_file="$1"
    local lock_pid

    lock_pid=$(__remove_lock_from_db "${lock_file}")
    if [ $? -ne 0 ] ; then
        echo "${LOCK_API_SELF}: ${FUNCNAME}: internal error: failed to remove ${lock_file} from db" >&2
        return 1
    fi

    __lock_remove ${lock_file} ${lock_pid}

    return 0
}
