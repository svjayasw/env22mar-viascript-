#!/bin/bash -ex
# This script tags the local git tree with rc1 tag and pushes to internal git
#

cd /home/atull/repos/internal/linux-socfpga
git tag -d rel_socfpga-4.0_15.06.01_rc1
git push origin :refs/tags/rel_socfpga-4.0_15.06.01_rc1
echo

git tag -d rel_socfpga-3.18_15.06.01_rc1
git push origin :refs/tags/rel_socfpga-3.18_15.06.01_rc1
echo

git tag -d rel_socfpga-3.10-ltsi_15.06.01_rc1
git push origin :refs/tags/rel_socfpga-3.10-ltsi_15.06.01_rc1
echo

git tag -d rel_socfpga-3.10-ltsi-rt_15.06.01_rc1
git push origin :refs/tags/rel_socfpga-3.10-ltsi-rt_15.06.01_rc1
echo


cd /home/atull/repos/internal/uboot-socfpga
git tag -d rel_socfpga_v2013.01.01_15.06.01_rc1
git push origin :refs/tags/rel_socfpga_v2013.01.01_15.06.01_rc1
echo

git tag -d rel_socfpga_v2014.10_arria10_bringup_15.06.01_rc1
git push origin :refs/tags/rel_socfpga_v2014.10_arria10_bringup_15.06.01_rc1
echo


cd /home/atull/repos/internal/angstrom-socfpga
git tag -d rel_angstrom-v2014.12-socfpga_15.06.01_rc1
git push origin :refs/tags/rel_angstrom-v2014.12-socfpga_15.06.01_rc1
echo


cd /home/atull/repos/internal/meta-altera
git tag -d rel_angstrom-v2014.12-yocto1.7_15.06.01_rc1
git push origin :refs/tags/rel_angstrom-v2014.12-yocto1.7_15.06.01_rc1
echo

git tag -d rel_angstrom-v2014.12-yocto1.7_a10_15.06.01_rc1
git push origin :refs/tags/rel_angstrom-v2014.12-yocto1.7_a10_15.06.01_rc1
echo

