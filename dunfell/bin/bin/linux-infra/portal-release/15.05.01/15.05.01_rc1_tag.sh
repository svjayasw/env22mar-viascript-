#!/bin/bash -ex
# This script tags the local git tree with rc1 tag and pushes to internal git
#

cd /home/atull/repos/internal/linux-socfpga
git tag rel_socfpga-3.18_15.05.01_rc1 53fa39141c538d8fa6e56ff05afcce90e7eedf31
git push origin rel_socfpga-3.18_15.05.01_rc1:refs/tags/rel_socfpga-3.18_15.05.01_rc1
echo

git tag rel_socfpga-3.10-ltsi_15.05.01_rc1 55fdf0eb86584d48100f2c718f6fb4a7d03a70b7
git push origin rel_socfpga-3.10-ltsi_15.05.01_rc1:refs/tags/rel_socfpga-3.10-ltsi_15.05.01_rc1
echo

git tag rel_socfpga-3.10-ltsi-rt_15.05.01_rc1 bae4561739f76250578c8446e671b85b358b502f
git push origin rel_socfpga-3.10-ltsi-rt_15.05.01_rc1:refs/tags/rel_socfpga-3.10-ltsi-rt_15.05.01_rc1
echo


cd /home/atull/repos/internal/uboot-socfpga
git tag rel_socfpga_v2013.01.01_15.05.01_rc1 32c1d91bc0d10beca54c2dfc5b475d4ffeffc15a
git push origin rel_socfpga_v2013.01.01_15.05.01_rc1:refs/tags/rel_socfpga_v2013.01.01_15.05.01_rc1
echo

git tag rel_socfpga_v2014.10_arria10_bringup_15.05.01_rc1 90ce61bf419a62381cb59470f4a4ba9e2f8e3b4e
git push origin rel_socfpga_v2014.10_arria10_bringup_15.05.01_rc1:refs/tags/rel_socfpga_v2014.10_arria10_bringup_15.05.01_rc1
echo


cd /home/atull/repos/internal/angstrom-socfpga
git tag rel_angstrom-v2012.12-socfpga_15.05.01_rc1 a7411013b0d87ac0a4596b09a0c19f868e21b667
git push origin rel_angstrom-v2012.12-socfpga_15.05.01_rc1:refs/tags/rel_angstrom-v2012.12-socfpga_15.05.01_rc1
echo

git tag rel_angstrom-v2013.12-socfpga_15.05.01_rc1 65417bcfd8d2859fd74ce5d5358fc26152db9991
git push origin rel_angstrom-v2013.12-socfpga_15.05.01_rc1:refs/tags/rel_angstrom-v2013.12-socfpga_15.05.01_rc1
echo

git tag rel_angstrom-v2014.06-socfpga_15.05.01_rc1 4460560c5cada124a6da2ae9306305abcf5f2040
git push origin rel_angstrom-v2014.06-socfpga_15.05.01_rc1:refs/tags/rel_angstrom-v2014.06-socfpga_15.05.01_rc1
echo

git tag rel_angstrom-v2014.12-socfpga_15.05.01_rc1 3990895ae9f2256377b62b343e4d7a27b51c0266
git push origin rel_angstrom-v2014.12-socfpga_15.05.01_rc1:refs/tags/rel_angstrom-v2014.12-socfpga_15.05.01_rc1
echo


cd /home/atull/repos/internal/meta-altera
git tag rel_angstrom-v2012.12-yocto1.3_15.05.01_rc1 b16478f2ddd65afa7821b1937885dfb96eff266f
git push origin rel_angstrom-v2012.12-yocto1.3_15.05.01_rc1:refs/tags/rel_angstrom-v2012.12-yocto1.3_15.05.01_rc1
echo

git tag rel_angstrom-v2013.12-yocto1.5_15.05.01_rc1 1090ffbbee1f3b6e45647591d369423ef9b2e41e
git push origin rel_angstrom-v2013.12-yocto1.5_15.05.01_rc1:refs/tags/rel_angstrom-v2013.12-yocto1.5_15.05.01_rc1
echo

git tag rel_angstrom-v2014.06-yocto1.6_15.05.01_rc1 9fe06573ef9f9a3b284edc66d590cb32b67a2f00
git push origin rel_angstrom-v2014.06-yocto1.6_15.05.01_rc1:refs/tags/rel_angstrom-v2014.06-yocto1.6_15.05.01_rc1
echo

git tag rel_angstrom-v2014.12-yocto1.7_15.05.01_rc1 95d38e0d45d418da8cc44f6deeabef08165a2288
git push origin rel_angstrom-v2014.12-yocto1.7_15.05.01_rc1:refs/tags/rel_angstrom-v2014.12-yocto1.7_15.05.01_rc1
echo

git tag rel_angstrom-v2014.12-yocto1.7_a10_15.05.01_rc1 28888cd94a4afd88a67929f47b895f0b0c65699e
git push origin rel_angstrom-v2014.12-yocto1.7_a10_15.05.01_rc1:refs/tags/rel_angstrom-v2014.12-yocto1.7_a10_15.05.01_rc1
echo


cd /home/atull/repos/internal/linux-tags
git tag rel_master_15.05.01_rc1 b64ae0bbe7ff68acd449cdafe478318ddda83425
git push origin rel_master_15.05.01_rc1:refs/tags/rel_master_15.05.01_rc1
git push origin rel_master_15.05.01_rc1:refs/heads/master
