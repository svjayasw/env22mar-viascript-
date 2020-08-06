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

# add 2 patches
push_tag  angstrom-socfpga    angstrom-v2014.12-socfpga_gsrd15.1

# NOT TAGGED but branch has not changed since RC1 so will tag RC4
push_tag  linux-refdesigns    socfpga-15.1

# add 2 patches
push_tag  linux-socfpga       socfpga-3.10-ltsi

# add one patch
push_tag  meta-altera         angstrom-v2014.12-yocto1.7

# add 2 patches
push_tag  meta-altera-refdes  gsrd-15.1

# Tag is behind the existing head on portal
#push_tag  uboot-socfpga        socfpga_v2013.01.01
push_tag  uboot-socfpga

