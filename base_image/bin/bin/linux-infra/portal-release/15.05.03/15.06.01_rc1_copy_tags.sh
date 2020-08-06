#!/bin/bash -ex
# This script copies rcN tags to rcN+1 tags in local git
#

cd /home/atull/repos/internal/linux-socfpga
git tag rel_socfpga-4.0_15.06.01_rc2 rel_socfpga-4.0_15.06.01_rc1
echo

git tag rel_socfpga-3.18_15.06.01_rc2 rel_socfpga-3.18_15.06.01_rc1
echo

git tag rel_socfpga-3.10-ltsi_15.06.01_rc2 rel_socfpga-3.10-ltsi_15.06.01_rc1
echo

git tag rel_socfpga-3.10-ltsi-rt_15.06.01_rc2 rel_socfpga-3.10-ltsi-rt_15.06.01_rc1
echo


cd /home/atull/repos/internal/uboot-socfpga
git tag rel_socfpga_v2013.01.01_15.06.01_rc2 rel_socfpga_v2013.01.01_15.06.01_rc1
echo

git tag rel_socfpga_v2014.10_arria10_bringup_15.06.01_rc2 rel_socfpga_v2014.10_arria10_bringup_15.06.01_rc1
echo


cd /home/atull/repos/internal/angstrom-socfpga
git tag rel_angstrom-v2014.12-socfpga_15.06.01_rc2 rel_angstrom-v2014.12-socfpga_15.06.01_rc1
echo


cd /home/atull/repos/internal/meta-altera
git tag rel_angstrom-v2014.12-yocto1.7_15.06.01_rc2 rel_angstrom-v2014.12-yocto1.7_15.06.01_rc1
echo

git tag rel_angstrom-v2014.12-yocto1.7_a10_15.06.01_rc2 rel_angstrom-v2014.12-yocto1.7_a10_15.06.01_rc1
echo

