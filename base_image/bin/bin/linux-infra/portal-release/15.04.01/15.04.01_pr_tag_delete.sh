#!/bin/bash -x
# This script copies rcN tags to rcN+1 tags in local git,
# pushes them to internal and RBO git
#

cd /home/atull/repos/internal/linux-socfpga
git tag -d rel_socfpga-3.18_15.04.01_pr
echo

echo

git tag -d rel_socfpga-3.10-ltsi_15.04.01_pr
echo

echo

git tag -d rel_socfpga-3.10-ltsi-rt_15.04.01_pr
echo

echo


cd /home/atull/repos/internal/uboot-socfpga
git tag -d rel_socfpga_v2013.01.01_15.04.01_pr
echo

echo

git tag -d rel_socfpga_v2014.10_arria10_bringup_15.04.01_pr
echo

echo


cd /home/atull/repos/internal/poky
git tag -d rel_danny-altera_15.04.01_pr
echo

echo


cd /home/atull/repos/internal/angstrom-socfpga
git tag -d rel_angstrom-v2012.12-socfpga_15.04.01_pr
echo

echo

git tag -d rel_angstrom-v2013.12-socfpga_15.04.01_pr
echo

echo

git tag -d rel_angstrom-v2014.06-socfpga_15.04.01_pr
echo

echo

git tag -d rel_angstrom-v2014.12-socfpga_15.04.01_pr
echo

echo


cd /home/atull/repos/internal/meta-altera
git tag -d rel_angstrom-v2012.12-yocto1.3_15.04.01_pr
echo

echo

git tag -d rel_angstrom-v2013.12-yocto1.5_15.04.01_pr
echo

echo

git tag -d rel_angstrom-v2014.06-yocto1.6_15.04.01_pr
echo

echo

git tag -d rel_angstrom-v2014.12-yocto1.7_15.04.01_pr
echo

echo

git tag -d rel_angstrom-v2014.12-yocto1.7_a10_15.04.01_pr
echo

