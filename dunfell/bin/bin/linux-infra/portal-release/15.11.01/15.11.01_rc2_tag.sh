#!/bin/bash -ex
# This script tags the local git tree with rc1 tag and pushes to internal git
#

cd /home/atull/repos/internal/linux-socfpga
git push origin rel_socfpga-4.2_15.11.01_rc2:refs/tags/rel_socfpga-4.2_15.11.01_rc2
echo

git push origin rel_socfpga-3.10-ltsi_15.11.01_rc2:refs/tags/rel_socfpga-3.10-ltsi_15.11.01_rc2
echo

git push origin rel_socfpga-3.10-ltsi-rt_15.11.01_rc2:refs/tags/rel_socfpga-3.10-ltsi-rt_15.11.01_rc2
echo


cd /home/atull/repos/internal/uboot-socfpga
git push origin rel_socfpga_v2013.01.01_15.11.01_rc2:refs/tags/rel_socfpga_v2013.01.01_15.11.01_rc2
echo

git push origin rel_socfpga_v2014.10_arria10_bringup_15.11.01_rc2:refs/tags/rel_socfpga_v2014.10_arria10_bringup_15.11.01_rc2
echo


cd /home/atull/repos/internal/angstrom-socfpga
git push origin rel_angstrom-v2014.12-socfpga_15.11.01_rc2:refs/tags/rel_angstrom-v2014.12-socfpga_15.11.01_rc2
echo


cd /home/atull/repos/internal/meta-altera
git push origin rel_angstrom-v2014.12-yocto1.7_15.11.01_rc2:refs/tags/rel_angstrom-v2014.12-yocto1.7_15.11.01_rc2
echo

git push origin rel_angstrom-v2014.12-yocto1.7_a10_15.11.01_rc2:refs/tags/rel_angstrom-v2014.12-yocto1.7_a10_15.11.01_rc2
echo


cd /home/atull/repos/internal/linux-tags
git tag rel_master_15.11.01_rc2 997b569f6e63ccb796e244461678f97f2638410d
git push origin rel_master_15.11.01_rc2:refs/tags/rel_master_15.11.01_rc2
git push origin rel_master_15.11.01_rc2:refs/heads/master