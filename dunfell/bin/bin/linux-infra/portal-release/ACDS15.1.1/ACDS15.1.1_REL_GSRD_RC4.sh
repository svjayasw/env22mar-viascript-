#!/bin/bash -e

# param 1  = tag name
# param 2  = repo name
# param 3  = (optional) branch
# If branch is specified, will push tag to branch, resetting the head
# If branch not specified, will not push branch
function push_tag()
{
    local tag=$1
    local repo=$2
    local branch=$3

    echo
    cd ~/repos/internal/$repo
    pwd

    git log -1 --pretty=format:'%h %an : %s' $tag

    git push portal $tag:refs/tags/$tag

    if [ -n "$branch" ]; then
	git push portal $tag:refs/heads/$branch
    else
	echo "not pushing branch"
    fi
}

#===================================================================================

declare -r TAG="$(basename $0 | sed 's/.sh//')"

echo $TAG

{
	#====================================
	# push tag only
	#====================================

	#push_tag angstrom-socfpga	angstrom-v2014.12-socfpga_gsrd15.1
	#ACDS15.1.1_REL_GSRD_RC1 == ACDS15.1_REL_GSRD_PR
	push_tag $TAG angstrom-socfpga

	#push_tag linux-refdesigns socfpga-15.1
	#ACDS15.1.1_REL_GSRD_RC1 == ACDS15.1_REL_GSRD_PR
	push_tag $TAG linux-refdesigns

	#push_tag linux-socfpga	socfpga-3.10-ltsi
	push_tag $TAG linux-socfpga

	push_tag $TAG meta-altera	angstrom-v2014.12-yocto1.7
	#push_tag $TAG meta-altera

	#push_tag meta-altera-refdes gsrd-15.1
	#ACDS15.1.1_REL_GSRD_RC1 == ACDS15.1_REL_GSRD_PR
	push_tag $TAG meta-altera-refdes

	#push_tag uboot-socfpga	socfpga_v2013.01.01
	push_tag $TAG uboot-socfpga

	#====================================
	# More complicated but ok - push tag and new commits, update head of branch
	#====================================
	# None

	echo Success
} 2>&1 | tee ${TAG}-log.txt

exit

