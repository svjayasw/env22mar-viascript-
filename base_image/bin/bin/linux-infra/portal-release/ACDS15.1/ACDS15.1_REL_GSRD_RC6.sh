#!/bin/bash -e

# param 1  = repo name
# param 2  = (optional) branch
# If branch is specified, will push tag to branch, resetting the head
# If branch not specified, will not push branch
function push_tag()
{
    repo=$1
    echo
    cd ~/repos/internal/$repo
    pwd

    git log -1 --pretty=format:'%h %an : %s' $TAG

    git push portal $TAG:refs/tags/$TAG

    branch=$2
    if [ -n "$branch" ]; then
	git push portal $TAG:refs/heads/$branch
    else
	echo "not pushing branch"
    fi
}

#===================================================================================

declare -r TAG="$(basename $0 | sed 's/.sh//')"

echo $TAG

#====================================
#push tag only
#====================================

#current head
#push_tag linux-socfpga	socfpga-3.10-ltsi
push_tag linux-socfpga

# a few commits behind the HEAD
#push_tag uboot-socfpga	socfpga_v2013.01.01
push_tag uboot-socfpga

# HEAD
#push_tag meta-altera-refdes gsrd-15.1
push_tag meta-altera-refdes

#====================================
# More complicated but ok - push tag and new commits, update head of branch
#====================================

# new commits, fast forward
#push_tag linux-refdesigns socfpga-15.1
push_tag linux-refdesigns

# 3 commits added, fast forward
push_tag meta-altera	angstrom-v2014.12-yocto1.7

# Head stays the same
push_tag angstrom-socfpga	angstrom-v2014.12-socfpga_gsrd15.1

echo Success
exit

