#!/bin/bash -ex
# This script tags the local git tree with rc1 tag and pushes to internal git
#

cd /home/atull/repos/internal/linux-socfpga
git tag rel_socfpga-4.6_16.06.02_rc2 origin/socfpga-4.6
git tag rel_socfpga-4.1.22-ltsi_16.06.02_rc2 origin/socfpga-4.1.22-ltsi
git tag rel_socfpga-4.1.22-ltsi-rt_16.06.02_rc2 origin/socfpga-4.1.22-ltsi-rt


git push origin rel_socfpga-4.6_16.06.02_rc2:refs/tags/rel_socfpga-4.6_16.06.02_rc2
echo

git push origin rel_socfpga-4.1-ltsi_16.06.02_rc2:refs/tags/rel_socfpga-4.1-ltsi_16.06.02_rc2
echo

git push origin rel_socfpga-4.1-ltsi-rt_16.06.02_rc2:refs/tags/rel_socfpga-4.1-ltsi-rt_16.06.02_rc2
echo

git push origin rel_socfpga-4.1.22-ltsi_16.06.02_rc2:refs/tags/rel_socfpga-4.1.22-ltsi_16.06.02_rc2
echo

git push origin rel_socfpga-4.1.22-ltsi-rt_16.06.02_rc2:refs/tags/rel_socfpga-4.1.22-ltsi-rt_16.06.02_rc2
echo


cd /home/atull/repos/internal/uboot-socfpga
git push origin rel_socfpga_v2013.01.01_16.06.02_rc2:refs/tags/rel_socfpga_v2013.01.01_16.06.02_rc2
echo

git push origin rel_socfpga_v2014.10_arria10_bringup_16.06.02_rc2:refs/tags/rel_socfpga_v2014.10_arria10_bringup_16.06.02_rc2
echo


cd /home/atull/repos/internal/angstrom-socfpga
git push origin rel_angstrom-v2014.12-socfpga_16.06.02_rc2:refs/tags/rel_angstrom-v2014.12-socfpga_16.06.02_rc2
echo


cd /home/atull/repos/internal/meta-altera
git push origin rel_angstrom-v2014.12-yocto1.7_16.06.02_rc2:refs/tags/rel_angstrom-v2014.12-yocto1.7_16.06.02_rc2
echo

git push origin rel_angstrom-v2014.12-yocto1.7_a10_16.06.02_rc2:refs/tags/rel_angstrom-v2014.12-yocto1.7_a10_16.06.02_rc2
echo


cd /home/atull/repos/internal/linux-tags
git tag rel_master_16.06.02_rc2 eae78996118cbf0db4f9fdeb1f26b971d2e2175e
git push origin rel_master_16.06.02_rc2:refs/tags/rel_master_16.06.02_rc2
git push origin rel_master_16.06.02_rc2:refs/heads/master
