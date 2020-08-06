#!/bin/bash -e

dry_run_and_push()
{
    repo=$1
    branch=$2
    tag=$3
    commit=$4
       
    echo "branch   $repo"
    echo "branch   $branch"
    echo "tag      $tag"
    echo "commit   $commit"
    echo
    if [ -z "$commit" ]; then
       exit
    fi

    cd ~/repos/internal/${repo}
    pwd
    tagged_sha=$(git log --pretty=format:%H -1 $tag)
    if [ "$tagged_sha" != "$commit" ]; then
	echo "does not match"
	exit
    fi
    
    git push --dry-run portal $tag:refs/tags/$tag
    git push --dry-run portal $tag:refs/heads/$branch
    echo

    git push portal $tag:refs/tags/$tag
    git push portal $commit:refs/heads/$branch
    echo
}

#========================================================

dry_run_and_push \
    arm-trusted-firmware \
    socfpga_v1.4 \
    rel_socfpga_stratix10_soceds_18.0 \
    af6d180b04899dba714481e2a1688176f635760c

dry_run_and_push \
    uefi-socfpga \
    socvp_socfpga_udk2015 \
    rel_socfpga_stratix10_soceds_18.0 \
    f4a07f98f4af745e40bc1e672e28500b6f6090c8
