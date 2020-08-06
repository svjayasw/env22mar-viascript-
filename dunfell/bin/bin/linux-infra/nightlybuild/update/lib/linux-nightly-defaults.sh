
function do_def_tag() {

    local tag=$1

    tag_repo_and_push ${tag}
    if [ $? -ne 0 ] ; then
        echo "${FUNCNAME}: error: tag_repo_and_push failed"
        return 1
    fi

    return 0

}
