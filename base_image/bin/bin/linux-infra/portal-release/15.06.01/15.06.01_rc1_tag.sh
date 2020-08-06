#!/bin/bash -ex
# This script tags the local git tree with rc1 tag and pushes to internal git
#

cd /home/atull/repos/internal/linux-socfpga
git tag rel_socfpga-4.0_15.06.01_rc1 61562cb0553bfb1101e09cc6079480fc4d0435bd
git push origin rel_socfpga-4.0_15.06.01_rc1:refs/tags/rel_socfpga-4.0_15.06.01_rc1
echo

git tag rel_socfpga-3.10-ltsi_15.06.01_rc1 6b87444d65d9070c0ed331af1e7fc865a7493d2b
git push origin rel_socfpga-3.10-ltsi_15.06.01_rc1:refs/tags/rel_socfpga-3.10-ltsi_15.06.01_rc1
echo

git tag rel_socfpga-3.10-ltsi-rt_15.06.01_rc1 1bc90b32e7d1fe054d3b94af5885169abe307705
git push origin rel_socfpga-3.10-ltsi-rt_15.06.01_rc1:refs/tags/rel_socfpga-3.10-ltsi-rt_15.06.01_rc1
echo


cd /home/atull/repos/internal/uboot-socfpga
git tag rel_socfpga_v2013.01.01_15.06.01_rc1 da11abaa41a757ca164f147d0ef8ff3cfccf900c
git push origin rel_socfpga_v2013.01.01_15.06.01_rc1:refs/tags/rel_socfpga_v2013.01.01_15.06.01_rc1
echo

git tag rel_socfpga_v2014.10_arria10_bringup_15.06.01_rc1 108bb2e7512e84bfb825d0cc60abefff59c6f905
git push origin rel_socfpga_v2014.10_arria10_bringup_15.06.01_rc1:refs/tags/rel_socfpga_v2014.10_arria10_bringup_15.06.01_rc1
echo


cd /home/atull/repos/internal/angstrom-socfpga
git tag rel_angstrom-v2014.12-socfpga_15.06.01_rc1 380baf43477eb1a994eae009f748d26607a39532
git push origin rel_angstrom-v2014.12-socfpga_15.06.01_rc1:refs/tags/rel_angstrom-v2014.12-socfpga_15.06.01_rc1
echo


cd /home/atull/repos/internal/meta-altera
git tag rel_angstrom-v2014.12-yocto1.7_15.06.01_rc1 856638668ca3f869b0de5de4f290cecdab1bad98
git push origin rel_angstrom-v2014.12-yocto1.7_15.06.01_rc1:refs/tags/rel_angstrom-v2014.12-yocto1.7_15.06.01_rc1
echo

git tag rel_angstrom-v2014.12-yocto1.7_a10_15.06.01_rc1 1d88fd24533505129b2c352fb1b66616e2aacc6a
git push origin rel_angstrom-v2014.12-yocto1.7_a10_15.06.01_rc1:refs/tags/rel_angstrom-v2014.12-yocto1.7_a10_15.06.01_rc1
echo


cd /home/atull/repos/internal/linux-tags
git tag rel_master_15.06.01_rc1 d06b486df76090374d7a8c2c7d52489f75f1630d
git push origin rel_master_15.06.01_rc1:refs/tags/rel_master_15.06.01_rc1
git push origin rel_master_15.06.01_rc1:refs/heads/master
