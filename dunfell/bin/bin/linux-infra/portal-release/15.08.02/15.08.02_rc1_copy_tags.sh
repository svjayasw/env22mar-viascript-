#!/bin/bash -ex
# This script copies rcN tags to rcN+1 tags in local git
#

cd /home/atull/repos/internal/linux-socfpga
# 186070d4 Dinh Nguyen : FogBugz #317771: Fix all the memory leaks
git tag rel_socfpga-4.1_15.08.02_rc2 186070d46805086fe9b46d95ac6d0e257203e5a4
echo

git tag rel_socfpga-3.10-ltsi_15.08.02_rc2 rel_socfpga-3.10-ltsi_15.08.02_rc1
echo

git tag rel_socfpga-3.10-ltsi-rt_15.08.02_rc2 rel_socfpga-3.10-ltsi-rt_15.08.02_rc1
echo


cd /home/atull/repos/internal/uboot-socfpga
git tag rel_socfpga_v2013.01.01_15.08.02_rc2 rel_socfpga_v2013.01.01_15.08.02_rc1
echo

git tag rel_socfpga_v2014.10_arria10_bringup_15.08.02_rc2 rel_socfpga_v2014.10_arria10_bringup_15.08.02_rc1
echo


cd /home/atull/repos/internal/angstrom-socfpga
git tag rel_angstrom-v2014.12-socfpga_15.08.02_rc2 rel_angstrom-v2014.12-socfpga_15.08.02_rc1
echo


cd /home/atull/repos/internal/meta-altera
git tag rel_angstrom-v2014.12-yocto1.7_15.08.02_rc2 rel_angstrom-v2014.12-yocto1.7_15.08.02_rc1
echo

git tag rel_angstrom-v2014.12-yocto1.7_a10_15.08.02_rc2 rel_angstrom-v2014.12-yocto1.7_a10_15.08.02_rc1
echo

