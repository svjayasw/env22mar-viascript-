#!/bin/bash -ex
# This script copies rcN tags to rcN+1 tags in local git
#

cd /home/atull/repos/internal/linux-socfpga
git tag rel_socfpga-4.2_15.11.01_rc3 rel_socfpga-4.2_15.11.01_rc2
echo

git tag rel_socfpga-3.10-ltsi_15.11.01_rc3 rel_socfpga-3.10-ltsi_15.11.01_rc2
echo

git tag rel_socfpga-3.10-ltsi-rt_15.11.01_rc3 rel_socfpga-3.10-ltsi-rt_15.11.01_rc2
echo


cd /home/atull/repos/internal/uboot-socfpga
git tag rel_socfpga_v2013.01.01_15.11.01_rc3 rel_socfpga_v2013.01.01_15.11.01_rc2
echo

git tag rel_socfpga_v2014.10_arria10_bringup_15.11.01_rc3 rel_socfpga_v2014.10_arria10_bringup_15.11.01_rc2
echo


cd /home/atull/repos/internal/angstrom-socfpga
git tag rel_angstrom-v2014.12-socfpga_15.11.01_rc3 rel_angstrom-v2014.12-socfpga_15.11.01_rc2
echo


cd /home/atull/repos/internal/meta-altera
git tag rel_angstrom-v2014.12-yocto1.7_15.11.01_rc3 rel_angstrom-v2014.12-yocto1.7_15.11.01_rc2
echo

git tag rel_angstrom-v2014.12-yocto1.7_a10_15.11.01_rc3 rel_angstrom-v2014.12-yocto1.7_a10_15.11.01_rc2
echo

