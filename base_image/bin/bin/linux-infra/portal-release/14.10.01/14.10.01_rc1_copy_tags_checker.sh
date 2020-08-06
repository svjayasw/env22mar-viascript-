#!/bin/bash -ex
# This script copies rcN tags to rcN+1 tags in local git
#

cd /home/atull/repos/internal/linux-socfpga
git log --pretty=oneline -1 rel_socfpga-3.16_14.10.01_rc1
git log --pretty=oneline -1 rel_socfpga-3.16_14.10.01
echo

git log --pretty=oneline -1 rel_socfpga-3.10-ltsi_14.10.01_rc1
git log --pretty=oneline -1 rel_socfpga-3.10-ltsi_14.10.01
echo

git log --pretty=oneline -1 rel_socfpga-3.10-ltsi-rt_14.10.01_rc1
git log --pretty=oneline -1 rel_socfpga-3.10-ltsi-rt_14.10.01
echo


cd /home/atull/repos/internal/uboot-socfpga
git log --pretty=oneline -1 rel_socfpga_v2013.01.01_14.10.01_rc1
git log --pretty=oneline -1 rel_socfpga_v2013.01.01_14.10.01
echo


cd /home/atull/repos/internal/poky
git log --pretty=oneline -1 rel_danny-altera_14.10.01_rc1
git log --pretty=oneline -1 rel_danny-altera_14.10.01
echo


cd /home/atull/repos/internal/angstrom-socfpga
git log --pretty=oneline -1 rel_angstrom-v2012.12-socfpga_14.10.01_rc1
git log --pretty=oneline -1 rel_angstrom-v2012.12-socfpga_14.10.01
echo

git log --pretty=oneline -1 rel_angstrom-v2013.12-socfpga_14.10.01_rc1
git log --pretty=oneline -1 rel_angstrom-v2013.12-socfpga_14.10.01
echo

git log --pretty=oneline -1 rel_angstrom-v2014.06-socfpga_14.10.01_rc1
git log --pretty=oneline -1 rel_angstrom-v2014.06-socfpga_14.10.01
echo


cd /home/atull/repos/internal/meta-altera
git log --pretty=oneline -1 rel_angstrom-v2012.12-yocto1.3_14.10.01_rc1
git log --pretty=oneline -1 rel_angstrom-v2012.12-yocto1.3_14.10.01
echo

git log --pretty=oneline -1 rel_angstrom-v2013.12-yocto1.5_14.10.01_rc1
git log --pretty=oneline -1 rel_angstrom-v2013.12-yocto1.5_14.10.01
echo

git log --pretty=oneline -1 rel_angstrom-v2014.06-yocto1.6_14.10.01_rc1
git log --pretty=oneline -1 rel_angstrom-v2014.06-yocto1.6_14.10.01
echo


cd /home/atull/repos/internal/linux-test
git log --pretty=oneline -1 rel_master_14.10.01_rc1
git log --pretty=oneline -1 rel_master_14.10.01
echo


cd /home/atull/repos/internal/linux-infra
git log --pretty=oneline -1 rel_tags_v1_14.10.01_rc1
git log --pretty=oneline -1 rel_tags_v1_14.10.01
echo

