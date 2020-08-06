#!/bin/bash -ex
# This script copies rcN tags to rcN+1 tags in local git
#

cd /home/atull/repos/internal/linux-socfpga
git tag rel_socfpga-4.5_16.06.02_rc2 rel_socfpga-4.5_16.06.02_rc1
echo

git tag rel_socfpga-4.1-ltsi_16.06.02_rc2 rel_socfpga-4.1-ltsi_16.06.02_rc1
echo

git tag rel_socfpga-4.1-ltsi-rt_16.06.02_rc2 rel_socfpga-4.1-ltsi-rt_16.06.02_rc1
echo


cd /home/atull/repos/internal/uboot-socfpga
git tag rel_socfpga_v2013.01.01_16.06.02_rc2 rel_socfpga_v2013.01.01_16.06.02_rc1
echo

git tag rel_socfpga_v2014.10_arria10_bringup_16.06.02_rc2 rel_socfpga_v2014.10_arria10_bringup_16.06.02_rc1
echo


cd /home/atull/repos/internal/angstrom-socfpga
git tag rel_angstrom-v2014.12-socfpga_16.06.02_rc2 rel_angstrom-v2014.12-socfpga_16.06.02_rc1
echo


cd /home/atull/repos/internal/meta-altera
git tag rel_angstrom-v2014.12-yocto1.7_16.06.02_rc2 rel_angstrom-v2014.12-yocto1.7_16.06.02_rc1
echo

git tag rel_angstrom-v2014.12-yocto1.7_a10_16.06.02_rc2 rel_angstrom-v2014.12-yocto1.7_a10_16.06.02_rc1
echo

