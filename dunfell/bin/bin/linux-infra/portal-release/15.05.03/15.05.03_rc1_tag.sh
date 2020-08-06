#!/bin/bash -ex
# This script tags the local git tree with rc1 tag and pushes to internal git
#

cd /home/atull/repos/internal/linux-socfpga
git tag rel_socfpga-4.0_15.05.03_rc1 87d1ba3efad71072786c2ff6c29ccb499f29dd7a
git push origin rel_socfpga-4.0_15.05.03_rc1:refs/tags/rel_socfpga-4.0_15.05.03_rc1
git push origin rel_socfpga-4.0_15.05.03_rc1:refs/tags/rel_socfpga-4.0_15.05.03_rc2
echo

git tag rel_socfpga-3.10-ltsi_15.05.03_rc1 d37310fa5250c484c508a519aac929cc0329c81a
git push origin rel_socfpga-3.10-ltsi_15.05.03_rc1:refs/tags/rel_socfpga-3.10-ltsi_15.05.03_rc1
git push origin ACDS15.0_REL_GSRD_RC2:refs/tags/rel_socfpga-3.10-ltsi_15.05.03_rc2
echo

git tag rel_socfpga-3.10-ltsi-rt_15.05.03_rc1 ed7a8e3483f8fff038afe0d73ef9a781043f7d0e
git push origin rel_socfpga-3.10-ltsi-rt_15.05.03_rc1:refs/tags/rel_socfpga-3.10-ltsi-rt_15.05.03_rc1
git push origin rel_socfpga-3.10-ltsi-rt_15.05.03_rc1:refs/tags/rel_socfpga-3.10-ltsi-rt_15.05.03_rc2
echo


cd /home/atull/repos/internal/uboot-socfpga
git tag rel_socfpga_v2013.01.01_15.05.03_rc1 32c1d91bc0d10beca54c2dfc5b475d4ffeffc15a
git push origin rel_socfpga_v2013.01.01_15.05.03_rc1:refs/tags/rel_socfpga_v2013.01.01_15.05.03_rc1
git push origin rel_socfpga_v2013.01.01_15.05.03_rc1:refs/tags/rel_socfpga_v2013.01.01_15.05.03_rc2
echo

git tag rel_socfpga_v2014.10_arria10_bringup_15.05.03_rc1 eed1ab6bb894b8d1e0740735283d97ff8a3a7957
git push origin rel_socfpga_v2014.10_arria10_bringup_15.05.03_rc1:refs/tags/rel_socfpga_v2014.10_arria10_bringup_15.05.03_rc1
git push origin rel_socfpga_v2014.10_arria10_bringup_15.05.03_rc1:refs/tags/rel_socfpga_v2014.10_arria10_bringup_15.05.03_rc2
echo


cd /home/atull/repos/internal/angstrom-socfpga
git tag rel_angstrom-v2014.12-socfpga_15.05.03_rc1 380baf43477eb1a994eae009f748d26607a39532
git push origin rel_angstrom-v2014.12-socfpga_15.05.03_rc1:refs/tags/rel_angstrom-v2014.12-socfpga_15.05.03_rc1
git push origin rel_angstrom-v2014.12-socfpga_15.05.03_rc1:refs/tags/rel_angstrom-v2014.12-socfpga_15.05.03_rc2
echo


cd /home/atull/repos/internal/meta-altera
git tag rel_angstrom-v2014.12-yocto1.7_15.05.03_rc1 856638668ca3f869b0de5de4f290cecdab1bad98
git push origin rel_angstrom-v2014.12-yocto1.7_15.05.03_rc1:refs/tags/rel_angstrom-v2014.12-yocto1.7_15.05.03_rc1
git push origin rel_angstrom-v2014.12-yocto1.7_15.05.03_rc1:refs/tags/rel_angstrom-v2014.12-yocto1.7_15.05.03_rc2
echo

git tag rel_angstrom-v2014.12-yocto1.7_a10_15.05.03_rc1 4f812794851c029759fce308249e6fe09d4babce
git push origin rel_angstrom-v2014.12-yocto1.7_a10_15.05.03_rc1:refs/tags/rel_angstrom-v2014.12-yocto1.7_a10_15.05.03_rc1
git push origin rel_angstrom-v2014.12-yocto1.7_a10_15.05.03_rc1:refs/tags/rel_angstrom-v2014.12-yocto1.7_a10_15.05.03_rc2
echo


cd /home/atull/repos/internal/linux-tags
git tag rel_master_15.05.03_rc1 6e66f4b49ffb8a0077f0957ba35e97271127ff31
git push origin rel_master_15.05.03_rc1:refs/tags/rel_master_15.05.03_rc1
git push origin rel_master_15.05.03_rc1:refs/heads/master
