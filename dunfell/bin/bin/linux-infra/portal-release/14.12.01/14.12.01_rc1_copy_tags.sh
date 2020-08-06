#!/bin/bash -ex
# This script copies rcN tags to rcN+1 tags in local git
#

cd /home/atull/repos/internal/linux-socfpga
git tag rel_socfpga-3.17_14.12.01_rc2 rel_socfpga-3.17_14.12.01_rc1
echo

git tag rel_socfpga-3.10-ltsi_14.12.01_rc2 rel_socfpga-3.10-ltsi_14.12.01_rc1
echo

git tag rel_socfpga-3.10-ltsi-rt_14.12.01_rc2 rel_socfpga-3.10-ltsi-rt_14.12.01_rc1
echo


cd /home/atull/repos/internal/uboot-socfpga
git tag rel_socfpga_v2013.01.01_14.12.01_rc2 rel_socfpga_v2013.01.01_14.12.01_rc1
echo


cd /home/atull/repos/internal/poky
git tag rel_danny-altera_14.12.01_rc2 rel_danny-altera_14.12.01_rc1
echo


cd /home/atull/repos/internal/angstrom-socfpga
git tag rel_angstrom-v2012.12-socfpga_14.12.01_rc2 rel_angstrom-v2012.12-socfpga_14.12.01_rc1
echo

git tag rel_angstrom-v2013.12-socfpga_14.12.01_rc2 rel_angstrom-v2013.12-socfpga_14.12.01_rc1
echo

git tag rel_angstrom-v2014.06-socfpga_14.12.01_rc2 rel_angstrom-v2014.06-socfpga_14.12.01_rc1
echo


cd /home/atull/repos/internal/meta-altera
git tag rel_angstrom-v2012.12-yocto1.3_14.12.01_rc2 rel_angstrom-v2012.12-yocto1.3_14.12.01_rc1
echo

git tag rel_angstrom-v2013.12-yocto1.5_14.12.01_rc2 rel_angstrom-v2013.12-yocto1.5_14.12.01_rc1
echo

git tag rel_angstrom-v2014.06-yocto1.6_14.12.01_rc2 rel_angstrom-v2014.06-yocto1.6_14.12.01_rc1
echo


cd /home/atull/repos/internal/linux-test
git tag rel_master_14.12.01_rc2 rel_master_14.12.01_rc1
echo


cd /home/atull/repos/internal/linux-infra
git tag rel_tags_v1_14.12.01_rc2 rel_tags_v1_14.12.01_rc1
echo

