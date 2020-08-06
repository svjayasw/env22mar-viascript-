#!/bin/bash -x

#========================================================================
# Automated Klocwork scans
# Runs scans on branches listed in linux-tags/release-branch-config.sh
# Working directories are relative to linux-infra:
# repos cloned in             : linux-infra/../repos
# results in                  : linux-infra/../results
# hash and other project info : linux-infra/../results/*/project-source.txt
# creates this file when done : linux-infra/../results/done
# log in                      : linux-infra/../logs
#========================================================================

# Globals

# send emails to ${MAINTAINER}@intel.com
export MAINTAINER=thor.thayer

# Path to internel git server
export ALTERA_GIT_SERVER='gitolite@at-git.intel.com'

#==========================================================================

function usage()
{
    echo "$(basename $0) [--dev]"
    echo "  --dev  : --dev param is passed to kw-scan.py for development"
}

# Don't allow running more than 1 instance of this script at a time.
# If we succeed in getting the lock, return.  Otherwise, exit.
function script_lock()
{
    if [ -z "${lock_filename}" ]; then
	echo "ERROR: script_lock needs a lock name"
	exit 1
    fi

    # Lock does not exist, so grab the lock.
    if [ ! -f /tmp/${lock_filename} ] ; then
        printf "%s\n" $$ > /tmp/${lock_filename}
        if [ "$$" = "$(head -1 /tmp/${lock_filename})" ]; then
            return
        fi
    fi

    # the lock file already exists, check to see if script still running.
    LOCK_PID=$(head -1 /tmp/${lock_filename})
    if [ "$(ps --no-header -p $LOCK_PID | wc -l)" = 0 ]; then
        # process not running, but lock file not deleted.
        printf "%s\n" $$ > /tmp/${lock_filename}
        return
    fi

    if [ -n "${MAINTAINER}" ]; then
	{
	    echo "Another job already running"
	    echo "${SELF}: Error on or near line ${LINENO}"
	    ps ax
	} 2>&1 | mail -s "${HOSTNAME}: Error in automated kw job" ${MAINTAINER}@intel.com
    fi

    # Other instance of sync_repo is still running.
    exit 1
}

function unlock_exit()
{
    rm -f /tmp/${lock_filename}
    exit
}

function error_exit()
{
    if [ -n "${MAINTAINER}" ]; then
	echo "${SELF}: Error on or near line ${1}" | \
	    mail -s "${HOSTNAME}: Error in automated kw job" ${MAINTAINER}@intel.com
    fi
    exit 1
}

function team_post_filtering()
{
    local project=$1
    local output_dir_full=$2

    case ${project} in
	'intel_rsu' )
	    ;;
	'linux_socfpga' )
	    ${infra_dir}/tools/kw-filter-by-name.py \
		--in ${output_dir_full}/kw-results-filtered.txt \
		--out ${output_dir_full}/kw-results-filtered-for-team.txt
	    chmod 777 ${output_dir_full}/kw-results-filtered-for-team.txt
	    ;;
    esac
}

#====================================================================
# Functions that get release configuration info from linux-tags repo
#====================================================================
function get_release_branches()
{
    local project=${1}

    local CONFIG_FILE=${kw_repos_dir}/linux-tags/release-branch-config.sh

    grep "${project}=" ${CONFIG_FILE} | \
	cut -d, -f3- | tr -d \' | tr ',' ' '
}

function get_project_repo_name()
{
    local project=$1

    local CONFIG_FILE=${kw_repos_dir}/linux-tags/release-branch-config.sh

    grep "${project}=" ${CONFIG_FILE} | \
	cut -d: -f2|cut -d, -f1
}

# Todo get this info from linux-tags
function get_scan_projects()
{
    echo "intel_rsu linux_socfpga"
}

# Todo get this info from linux-tags
function get_project_machines()
{
    local project=$1
    local br=$2
    case ${project} in
	'intel_rsu' )
	    echo "stratix10"
	    ;;
	'linux_socfpga' )
	    echo "stratix10 cyclone5"
	    ;;
    esac
}

#==================================================================================

export lock_filename="$(basename $0 | sed 's/.sh//')"
script_lock

# Send email if there is an error exit
trap 'error_exit ${LINENO}' ERR

develop=
while [ -n "${1}" ]; do
    case "${1}" in
	--dev ) develop=$1 ;;
	* ) usage; exit 0;;
    esac
    shift
done

# Kill all dangling processes that are running the 'callbacks-kw-*' scripts
ps ax|grep callbacks-kw-|grep -v grep|cut -d' ' -f1 | xargs -n1 kill -9

SELF=$(basename $0)
SELF_PATH=$(realpath ${0} | xargs dirname)

. ${SELF_PATH}/proxyon

# linux-infra is either BASE/linux-infra or BASE/repos/linux-infra
infra_dir=$(echo ${SELF_PATH}/../.. | xargs realpath)

# Base dir, contains 'repos' dir
if echo ${infra_dir} | grep -sq 'repos'; then
    kw_auto_base=$(echo ${infra_dir}/../.. | xargs realpath)
else
    kw_auto_base=$(echo ${infra_dir}/.. | xargs realpath)
fi

kw_repos_dir=${kw_auto_base}/repos
kw_results_output=${kw_auto_base}/results
kw_script_logs=${kw_auto_base}/logs

export PATH=$PATH:/sbin:/usr/sbin:/usr/bin

# Clean out previous scan results and logs
rm -rf ${kw_results_output} && \
    mkdir ${kw_results_output} && \
    chmod 777 ${kw_results_output} || \
    error_exit ${LINENO}

rm -rf ${kw_script_logs} && \
    mkdir ${kw_script_logs} && \
    chmod 777 ${kw_script_logs} || \
    error_exit ${LINENO}

SCRIPT_LOG=${kw_script_logs}/kw-auto-log.txt

if [ -d "${kw_repos_dir}" ]; then
    rm -rf ${kw_repos_dir}/build || \
    error_exit ${LINENO}
else
    mkdir ${kw_repos_dir} && \
    chmod 777 ${kw_repos_dir} || \
    error_exit ${LINENO}
fi

# Get clean clone of linux-tags
cd ${kw_repos_dir} || error_exit ${LINENO}
rm -rf ${kw_repos_dir}/linux-tags
git clone ${ALTERA_GIT_SERVER}:linux-tags 2>&1 || tee -a ${SCRIPT_LOG}

scan_projects="$(get_scan_projects)"
for project in ${scan_projects}; do
    project_branches="$(get_release_branches ${project})"
    repo_name="$(get_project_repo_name ${project})"
    kw_project="${repo_name}"

    for branch in ${project_branches}; do
	cloned=
	if [ -d ${kw_repos_dir}/${repo_name} ]; then
	    cloned='--cloned'
	fi
	echo | tee -a ${SCRIPT_LOG}
	machines="$(get_project_machines ${project} ${branch})"
	for machine in ${machines}; do
	    date
	    output_dir="${repo_name}_${branch}_${machine}"
	    echo "project    : ${project}"
	    echo "kw_project : ${kw_project}"
	    echo "repo name  : ${repo_name}"
	    echo "branch     : ${branch}"
	    echo "machine    : ${machine}"
	    echo "output dir : ${output_dir}"
	    echo
	    scan_cmd="${infra_dir}/tools/kw-scan.py -f ${develop} ${cloned} \
		       -p ${kw_project} \
                       -b ${branch} \
		       -m ${machine} \
                       -v ${kw_repos_dir} \
		       -o ${kw_results_output}/${output_dir}"
	    echo "${scan_cmd}" | tr '\t' ' ' | tr -s ' '
	    ${scan_cmd}
	    if [ $? -ne 0 ]; then
		error_exit ${LINENO}
	    fi
	    team_post_filtering ${project} ${kw_results_output}/${output_dir}

	    cd ${kw_repos_dir}/${repo_name}
	    commit_hash=$(git log -1 --format=%H)
	    {
		echo "repo:${repo_name}"
		echo "git_server:${ALTERA_GIT_SERVER}"
		echo "machine:${machine}"
		echo "branch:${branch}"
		echo "hash:${commit_hash}"
	    } > ${kw_results_output}/${output_dir}/project-source.txt

	    # Save nightly build config file
	    mv ${kw_repos_dir}/config-kw.sh ${kw_results_output}/${output_dir}

	    # clean up
	    rm -f ${kw_repos_dir}/latest-KW*
	done
	echo
    done
    echo
done 2>&1 | tee -a ${SCRIPT_LOG}

# clean up
rm -rf ${kw_repos_dir}/linux-tags

#TODO# Some scans are for branches, some are for tags
date | tee -a ${SCRIPT_LOG}
echo Done! | tee -a ${SCRIPT_LOG}
touch ${kw_results_output}/done

exit 0
