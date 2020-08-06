#!/bin/bash -e

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

#new branch
push_tag  angstrom-socfpga    angstrom-v2014.12-socfpga_gsrd15.1

#new branch
push_tag  linux-refdesigns    socfpga-15.1

#tag adds 4 commits
push_tag  linux-socfpga       socfpga-3.10-ltsi

#tag adds commits
push_tag  meta-altera         angstrom-v2014.12-yocto1.7

#new branch
push_tag  meta-altera-refdes  gsrd-15.1

# Tag is behind the existing head on portal
#push_tag  uboot-socfpga        socfpga_v2013.01.01
push_tag  uboot-socfpga

