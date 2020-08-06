#!/bin/bash -ex
# This script tags the local git tree with rc1 tag and pushes to internal git
#

cd /home/atull/repos/internal/linux-socfpga
git push origin rel_socfpga-3.18_15.03.01_rc2:refs/tags/rel_socfpga-3.18_15.03.01_rc2
echo

git push origin rel_socfpga-3.10-ltsi_15.03.01_rc2:refs/tags/rel_socfpga-3.10-ltsi_15.03.01_rc2
echo

git push origin rel_socfpga-3.10-ltsi-rt_15.03.01_rc2:refs/tags/rel_socfpga-3.10-ltsi-rt_15.03.01_rc2
echo


cd /home/atull/repos/internal/uboot-socfpga
git push origin rel_socfpga_v2013.01.01_15.03.01_rc2:refs/tags/rel_socfpga_v2013.01.01_15.03.01_rc2
echo


cd /home/atull/repos/internal/poky
git push origin rel_danny-altera_15.03.01_rc2:refs/tags/rel_danny-altera_15.03.01_rc2
echo


cd /home/atull/repos/internal/angstrom-socfpga
git push origin rel_angstrom-v2012.12-socfpga_15.03.01_rc2:refs/tags/rel_angstrom-v2012.12-socfpga_15.03.01_rc2
echo

git push origin rel_angstrom-v2013.12-socfpga_15.03.01_rc2:refs/tags/rel_angstrom-v2013.12-socfpga_15.03.01_rc2
echo

git push origin rel_angstrom-v2014.06-socfpga_15.03.01_rc2:refs/tags/rel_angstrom-v2014.06-socfpga_15.03.01_rc2
echo

git push origin rel_angstrom-v2014.12-socfpga_15.03.01_rc2:refs/tags/rel_angstrom-v2014.12-socfpga_15.03.01_rc2
echo


cd /home/atull/repos/internal/meta-altera
git push origin rel_angstrom-v2012.12-yocto1.3_15.03.01_rc2:refs/tags/rel_angstrom-v2012.12-yocto1.3_15.03.01_rc2
echo

git push origin rel_angstrom-v2013.12-yocto1.5_15.03.01_rc2:refs/tags/rel_angstrom-v2013.12-yocto1.5_15.03.01_rc2
echo

git push origin rel_angstrom-v2014.06-yocto1.6_15.03.01_rc2:refs/tags/rel_angstrom-v2014.06-yocto1.6_15.03.01_rc2
echo

git push origin rel_angstrom-v2014.12-yocto1.7_15.03.01_rc2:refs/tags/rel_angstrom-v2014.12-yocto1.7_15.03.01_rc2
echo

git push origin rel_angstrom-v2014.12-yocto1.7_a10_15.03.01_rc2:refs/tags/rel_angstrom-v2014.12-yocto1.7_a10_15.03.01_rc2
echo


cd /home/atull/repos/internal/linux-test
git push origin rel_master_15.03.01_rc2:refs/tags/rel_master_15.03.01_rc2
echo


cd /home/atull/repos/internal/linux-infra
git push origin rel_updated_nightly_15.03.01_rc2:refs/tags/rel_updated_nightly_15.03.01_rc2
echo


cd /home/atull/repos/internal/linux-tags
git tag rel_master_15.03.01_rc2 a1bbbb100e63f5a395df7b4b5c3df473a8a2b6bb
git push origin rel_master_15.03.01_rc2:refs/tags/rel_master_15.03.01_rc2
git push origin rel_master_15.03.01_rc2:refs/heads/master
