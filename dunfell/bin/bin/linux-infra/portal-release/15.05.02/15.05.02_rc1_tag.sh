#!/bin/bash -ex
# This script tags the local git tree with rc1 tag and pushes to internal git
#

cd /home/atull/repos/internal/linux-socfpga
git tag rel_socfpga-3.18_15.05.02_rc1 034e7cbef5db4a259e9658939e16c53909fc1f34
git push origin rel_socfpga-3.18_15.05.02_rc1:refs/tags/rel_socfpga-3.18_15.05.02_rc1
echo

git tag rel_socfpga-3.10-ltsi_15.05.02_rc1 77c9b87c1fad21d2382d6d208ecda1a3def16c55
git push origin rel_socfpga-3.10-ltsi_15.05.02_rc1:refs/tags/rel_socfpga-3.10-ltsi_15.05.02_rc1
echo

git tag rel_socfpga-3.10-ltsi-rt_15.05.02_rc1 56adec96ecbc3df5e4320d409c515b9a568cfe7b
git push origin rel_socfpga-3.10-ltsi-rt_15.05.02_rc1:refs/tags/rel_socfpga-3.10-ltsi-rt_15.05.02_rc1
echo


cd /home/atull/repos/internal/uboot-socfpga
git tag rel_socfpga_v2013.01.01_15.05.02_rc1 32c1d91bc0d10beca54c2dfc5b475d4ffeffc15a
git push origin rel_socfpga_v2013.01.01_15.05.02_rc1:refs/tags/rel_socfpga_v2013.01.01_15.05.02_rc1
echo

git tag rel_socfpga_v2014.10_arria10_bringup_15.05.02_rc1 f036048565eeaa2ed5717b1d2798dab329442c38
git push origin rel_socfpga_v2014.10_arria10_bringup_15.05.02_rc1:refs/tags/rel_socfpga_v2014.10_arria10_bringup_15.05.02_rc1
echo


cd /home/atull/repos/internal/angstrom-socfpga
git tag rel_angstrom-v2012.12-socfpga_15.05.02_rc1 a7411013b0d87ac0a4596b09a0c19f868e21b667
git push origin rel_angstrom-v2012.12-socfpga_15.05.02_rc1:refs/tags/rel_angstrom-v2012.12-socfpga_15.05.02_rc1
echo

git tag rel_angstrom-v2013.12-socfpga_15.05.02_rc1 b5eabfbc4d1d7da4f2cd8ee34025ce40d657f661
git push origin rel_angstrom-v2013.12-socfpga_15.05.02_rc1:refs/tags/rel_angstrom-v2013.12-socfpga_15.05.02_rc1
echo

git tag rel_angstrom-v2014.06-socfpga_15.05.02_rc1 4460560c5cada124a6da2ae9306305abcf5f2040
git push origin rel_angstrom-v2014.06-socfpga_15.05.02_rc1:refs/tags/rel_angstrom-v2014.06-socfpga_15.05.02_rc1
echo

git tag rel_angstrom-v2014.12-socfpga_15.05.02_rc1 380baf43477eb1a994eae009f748d26607a39532
git push origin rel_angstrom-v2014.12-socfpga_15.05.02_rc1:refs/tags/rel_angstrom-v2014.12-socfpga_15.05.02_rc1
echo


cd /home/atull/repos/internal/meta-altera
git tag rel_angstrom-v2012.12-yocto1.3_15.05.02_rc1 b16478f2ddd65afa7821b1937885dfb96eff266f
git push origin rel_angstrom-v2012.12-yocto1.3_15.05.02_rc1:refs/tags/rel_angstrom-v2012.12-yocto1.3_15.05.02_rc1
echo

git tag rel_angstrom-v2013.12-yocto1.5_15.05.02_rc1 0d7c7de5a35a34ab3c6154b51f362815e5405900
git push origin rel_angstrom-v2013.12-yocto1.5_15.05.02_rc1:refs/tags/rel_angstrom-v2013.12-yocto1.5_15.05.02_rc1
echo

git tag rel_angstrom-v2014.06-yocto1.6_15.05.02_rc1 9fe06573ef9f9a3b284edc66d590cb32b67a2f00
git push origin rel_angstrom-v2014.06-yocto1.6_15.05.02_rc1:refs/tags/rel_angstrom-v2014.06-yocto1.6_15.05.02_rc1
echo

git tag rel_angstrom-v2014.12-yocto1.7_15.05.02_rc1 95d38e0d45d418da8cc44f6deeabef08165a2288
git push origin rel_angstrom-v2014.12-yocto1.7_15.05.02_rc1:refs/tags/rel_angstrom-v2014.12-yocto1.7_15.05.02_rc1
echo

git tag rel_angstrom-v2014.12-yocto1.7_a10_15.05.02_rc1 2f5c57c03f1b2a9aa1343d6b5ddf00202a3381a5
git push origin rel_angstrom-v2014.12-yocto1.7_a10_15.05.02_rc1:refs/tags/rel_angstrom-v2014.12-yocto1.7_a10_15.05.02_rc1
echo


cd /home/atull/repos/internal/linux-tags
git tag rel_master_15.05.02_rc1 9880222c9dc9ace65dc54aa555f285be00f15dd3
git push origin rel_master_15.05.02_rc1:refs/tags/rel_master_15.05.02_rc1
git push origin rel_master_15.05.02_rc1:refs/heads/master
