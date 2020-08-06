#!/bin/bash -ex
# This script tags the local git tree with rc1 tag and pushes to internal git
#

cd /home/atull/repos/internal/linux-socfpga
git push origin rel_socfpga-4.3_16.02.02_rc2:refs/tags/rel_socfpga-4.3_16.02.02_rc2
echo

git push origin rel_socfpga-3.10-ltsi_16.02.02_rc2:refs/tags/rel_socfpga-3.10-ltsi_16.02.02_rc2
echo

git push origin rel_socfpga-3.10-ltsi-rt_16.02.02_rc2:refs/tags/rel_socfpga-3.10-ltsi-rt_16.02.02_rc2
echo


cd /home/atull/repos/internal/uboot-socfpga
git push origin rel_socfpga_v2013.01.01_16.02.02_rc2:refs/tags/rel_socfpga_v2013.01.01_16.02.02_rc2
echo

git push origin rel_socfpga_v2014.10_arria10_bringup_16.02.02_rc2:refs/tags/rel_socfpga_v2014.10_arria10_bringup_16.02.02_rc2
echo


cd /home/atull/repos/internal/angstrom-socfpga
git push origin rel_angstrom-v2014.12-socfpga_16.02.02_rc2:refs/tags/rel_angstrom-v2014.12-socfpga_16.02.02_rc2
echo


cd /home/atull/repos/internal/meta-altera
git push origin rel_angstrom-v2014.12-yocto1.7_16.02.02_rc2:refs/tags/rel_angstrom-v2014.12-yocto1.7_16.02.02_rc2
echo

git push origin rel_angstrom-v2014.12-yocto1.7_a10_16.02.02_rc2:refs/tags/rel_angstrom-v2014.12-yocto1.7_a10_16.02.02_rc2
echo


cd /home/atull/repos/internal/linux-tags
git tag rel_master_16.02.02_rc2 d18127248b5a7d3e0eaee36adde0c8dad83fe085
git push origin rel_master_16.02.02_rc2:refs/tags/rel_master_16.02.02_rc2
git push origin rel_master_16.02.02_rc2:refs/heads/master
