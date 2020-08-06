# library of GIT functions

#  clone a repo
#! input
#!  $1 = repository in the form of prot://user@server:repo
#!  $2 = branch. Default value = master.  Probably needs to be origin/<remote branch name>
#!  $3 = target directory. Default value = clone
#!  $4 = local branch name
#!
#! For $2, note that if you don't specify 'origin/' it is checkout out a local branch,
#! not the latest that has been fetched.  In most cases (branch name is not master) this
#! will not work.
function clone_git_repo() {

    local repo="$1"
    local branch="${2:-origin/master}"
    local target_dir="${3:-clone}"
    local local_branch="${4:-blah}"

    git clone ${repo} ${target_dir} 
    if [ $? -ne 0 ] ; then
        log "${FUNCNAME}: error: could not clone repo (${repo})"
        return 1
    fi

    cd ${target_dir}
    if [ $? -ne 0 ] ; then
        log "${FUNCNAME}: error: could not cd to git repo at ${target_dir}"
        return 1
    fi

    git checkout -B ${local_branch} ${branch} 2>&1 | log_in 
    if [ $? -ne 0 ] ; then
        log "${FUNCNAME}: error: could not checkout branch ${branch}"
        return 1
    fi
    cd -

    return 0
}

#  clean and reset a cloned git repo
#  assumes repo has been cloned to 'dir'
#! input
#!  $1 = repository directory
function clean_git_repo() {

    local repo_dir="$1"

    cd ${repo_dir}
    if [ $? -ne 0 ] ; then
        log "${FUNCNAME}: error: could not cd to git repo at ${repo_dir}"
        return 1
    fi

    git clean -fdxq
    if [ $? -ne 0 ] ; then
        log "${FUNCNAME}: error: could not clean git repo at ${repo_dir}"
        return 1
    fi

    git reset --hard
    if [ $? -ne 0 ] ; then
        log "${FUNCNAME}: error: could not reset git repo at ${repo_dir}"
        return 1
    fi

    cd -
    
    return 0
}

#  update (fetch only) a cloned git repo
#  assumes repo has been cloned to 'dir'
#! input
#!  $1 = repository directory
function update_git_repo() {

    local repo_dir="$1"

    cd ${repo_dir}
    if [ $? -ne 0 ] ; then
        log "${FUNCNAME}: error: could not cd to git repo at ${repo_dir}"
        return 1
    fi

    git fetch origin
    if [ $? -ne 0 ] ; then
        log "${FUNCNAME}: error: could not fetch git repo at ${repo_dir}"
        return 1
    fi

    cd -

    return 0
}


#  check out branch
#! input
#!  $1 = repository directory
#!  $2 = branch
#!  $3 = local branch name
function checkout_git_repo_branch() {

    local repo_dir="$1"
    local branch="$2"
    local local_branch="$3"

    cd ${repo_dir}
    if [ $? -ne 0 ] ; then
        log "${FUNCNAME}: error: could not cd to git repo at ${repo_dir}"
        return 1
    fi

    git checkout -B ${local_branch} ${branch}
    if [ $? -ne 0 ] ; then
        log "${FUNCNAME}: error: could not checkout branch ${branch} at git repo at ${repo_dir}"
        return 1
    fi

    cd -

    return 0
}


#  this function assumes the repo has been cloned
#! and you are in the right directory
function tag_repo() {

    local tag=${1}

    git tag ${tag}
    return $?
}


function tag_repo_and_push() {

    local tag=${1}

    tag_repo ${tag}
    if [ $? -ne 0 ] ; then
        return 1
    fi
 
    git push origin refs/tags/${tag}
    return $?
    
}

function rebase_repo_to_tag() {
     
     local clone_dir=$1
     local tag=$2
     local err=0

     cd ${clone_dir}
     git reset --hard ${tag}
     if [ $? -ne 0 ] ; then
         echo "${FUNCNAME}: error: could not rebase repo to ${tag}"
         err=1         
     fi
     cd -

     return ${err}
}

function get_repo_from_url() {

    local url=$1

    if [[ "${url}" =~ ^gitolite ]] ; then
        repo=$(echo $url | awk -F: ' { print $2 } ')
    else if [[ "${url}" =~ ^git:|^http: ]] ; then
            echo $(basename ${url})
         else
            echo ${url}
         fi
    fi

    echo $repo

    return 0

}

function simplify_branch_name() {

    local branch="$1"

    echo ${branch} | sed -e 's/origin\///'

}
