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

# angstrom-socfpga
# 0a2c33dbc636dc02049cfb77f73132d70b36c183 FogBugz #338393: PCIe: Update meta-altera-refdes commit ID
# - origin/angstrom-v2014.12-socfpga

	push_tag $TAG angstrom-socfpga	angstrom-v2014.12-socfpga
#	push_tag $TAG angstrom-socfpga

# linux-refdesigns
# 89acc83e9e3a66920e7bf949c60a9898419e946b FogBugz #338130: add dma transfer modules
# - origin/socfpga-16.0

	push_tag $TAG linux-refdesigns	socfpga-16.0
#	push_tag $TAG linux-refdesigns

# linux-socfpga
# 28bac3edbcdc74f98b865986be5d340381896192 FogBugz #350137: Fix A10SyCon Button Export Crash
# - origin/socfpga-3.10-ltsi
# - portal/socfpga-3.10-ltsi

#	push_tag $TAG linux-socfpga		socfpga-3.10-ltsi
	push_tag $TAG linux-socfpga

# meta-altera
# 8d6e9b468630aa4d9d4c946080f5023dea43d891 Support for the kernel v4.3
# - origin/angstrom-v2014.12-yocto1.7
# - portal/angstrom-v2014.12-yocto1.7

#	push_tag $TAG meta-altera	angstrom-v2014.12-yocto1.7
	push_tag $TAG meta-altera

# meta-altera-refdes
# 660224209baf74937656cc7d6be92fa7d2765acb FogBugz #338393: Add fio package to PCIe reference design
# - origin/gsrd-15.1
# - origin/gsrd-16.0
# - portal/gsrd-15.1

	push_tag $TAG meta-altera-refdes gsrd-16.0
#	push_tag $TAG meta-altera-refdes

# uboot-socfpga
# e552a7f90788460e00f15fadbebd66606d0a6db4 FogBugz #359965: Enforce full SDRAM ECC init when ECC is enabled
# - origin/socfpga_v2013.01.01

	push_tag $TAG uboot-socfpga	socfpga_v2013.01.01
#	push_tag $TAG uboot-socfpga

#========================================================================
#A10 branches
#	A10_TAG=ACDS15.1.1_REL_A10_GSRD_PR	

#	push_tag $A10_TAG uboot-socfpga	socfpga_v2014.10_arria10_bringup
#	push_tag $A10_TAG uboot-socfpga

	echo Success
} 2>&1 | tee -a ${TAG}-log.txt

exit

