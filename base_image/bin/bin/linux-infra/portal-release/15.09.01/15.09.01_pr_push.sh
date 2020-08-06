#!/bin/bash -ex
# This script copies rcN tags to rcN+1 tags in local git,
# pushes them to internal and external git
#

cd /home/atull/repos/internal/angstrom-socfpga
git tag rel_angstrom-v2014.12-socfpga_15.09.01_pr rel_angstrom-v2014.12-socfpga_15.09.01_rc2
git push origin rel_angstrom-v2014.12-socfpga_15.09.01_pr:refs/tags/rel_angstrom-v2014.12-socfpga_15.09.01_pr
echo

git push portal rel_angstrom-v2014.12-socfpga_15.09.01_pr:refs/heads/angstrom-v2014.12-socfpga
git push portal rel_angstrom-v2014.12-socfpga_15.09.01_pr:refs/tags/rel_angstrom-v2014.12-socfpga_15.09.01_pr
echo


cd /home/atull/repos/internal/meta-altera
git tag rel_angstrom-v2014.12-yocto1.7_15.09.01_pr rel_angstrom-v2014.12-yocto1.7_15.09.01_rc2
git push origin rel_angstrom-v2014.12-yocto1.7_15.09.01_pr:refs/tags/rel_angstrom-v2014.12-yocto1.7_15.09.01_pr
echo

git push portal rel_angstrom-v2014.12-yocto1.7_15.09.01_pr:refs/heads/angstrom-v2014.12-yocto1.7
git push portal rel_angstrom-v2014.12-yocto1.7_15.09.01_pr:refs/tags/rel_angstrom-v2014.12-yocto1.7_15.09.01_pr
echo

git tag rel_angstrom-v2014.12-yocto1.7_a10_15.09.01_pr rel_angstrom-v2014.12-yocto1.7_a10_15.09.01_rc2
git push origin rel_angstrom-v2014.12-yocto1.7_a10_15.09.01_pr:refs/tags/rel_angstrom-v2014.12-yocto1.7_a10_15.09.01_pr
echo

git push portal rel_angstrom-v2014.12-yocto1.7_a10_15.09.01_pr:refs/heads/angstrom-v2014.12-yocto1.7_a10
git push portal rel_angstrom-v2014.12-yocto1.7_a10_15.09.01_pr:refs/tags/rel_angstrom-v2014.12-yocto1.7_a10_15.09.01_pr
echo


cd /home/atull/repos/internal/linux-tags
git tag rel_master_15.09.01_pr d5ec90f27d2ebb57b661122f65723bc7c7c802cc
git push origin rel_master_15.09.01_pr:refs/tags/rel_master_15.09.01_pr
git push origin rel_master_15.09.01_pr:refs/heads/master
