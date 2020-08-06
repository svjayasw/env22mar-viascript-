#!/bin/bash -ex
# This script tags the local git tree with rc1 tag and pushes to internal git
#

cd /home/atull/repos/internal/linux-socfpga
git tag rel_socfpga-3.18_15.03.02_rc1 b3ed7574b9790575634f0900ea5ee4a7c21bb04c
git push origin rel_socfpga-3.18_15.03.02_rc1:refs/tags/rel_socfpga-3.18_15.03.02_rc1
echo

git tag rel_socfpga-3.10-ltsi_15.03.02_rc1 018fe6cee69fe06d57eac2d270c760ac2e243e2d
git push origin rel_socfpga-3.10-ltsi_15.03.02_rc1:refs/tags/rel_socfpga-3.10-ltsi_15.03.02_rc1
echo

git tag rel_socfpga-3.10-ltsi-rt_15.03.02_rc1 629162a27e4dd5383e6cc86116343df769e057e0
git push origin rel_socfpga-3.10-ltsi-rt_15.03.02_rc1:refs/tags/rel_socfpga-3.10-ltsi-rt_15.03.02_rc1
echo


cd /home/atull/repos/internal/uboot-socfpga
git tag rel_socfpga_v2013.01.01_15.03.02_rc1 32c1d91bc0d10beca54c2dfc5b475d4ffeffc15a
git push origin rel_socfpga_v2013.01.01_15.03.02_rc1:refs/tags/rel_socfpga_v2013.01.01_15.03.02_rc1
echo


cd /home/atull/repos/internal/poky
git tag rel_danny-altera_15.03.02_rc1 2ea11347bbdbdab3b5d9bb7a4157f9b7b5607a23
git push origin rel_danny-altera_15.03.02_rc1:refs/tags/rel_danny-altera_15.03.02_rc1
echo


cd /home/atull/repos/internal/angstrom-socfpga
git tag rel_angstrom-v2012.12-socfpga_15.03.02_rc1 a7411013b0d87ac0a4596b09a0c19f868e21b667
git push origin rel_angstrom-v2012.12-socfpga_15.03.02_rc1:refs/tags/rel_angstrom-v2012.12-socfpga_15.03.02_rc1
echo

git tag rel_angstrom-v2013.12-socfpga_15.03.02_rc1 65417bcfd8d2859fd74ce5d5358fc26152db9991
git push origin rel_angstrom-v2013.12-socfpga_15.03.02_rc1:refs/tags/rel_angstrom-v2013.12-socfpga_15.03.02_rc1
echo

git tag rel_angstrom-v2014.06-socfpga_15.03.02_rc1 4460560c5cada124a6da2ae9306305abcf5f2040
git push origin rel_angstrom-v2014.06-socfpga_15.03.02_rc1:refs/tags/rel_angstrom-v2014.06-socfpga_15.03.02_rc1
echo

git tag rel_angstrom-v2014.12-socfpga_15.03.02_rc1 e8f1e58d981f0640d7cdd581c8621d019e6fd480
git push origin rel_angstrom-v2014.12-socfpga_15.03.02_rc1:refs/tags/rel_angstrom-v2014.12-socfpga_15.03.02_rc1
echo


cd /home/atull/repos/internal/meta-altera
git tag rel_angstrom-v2012.12-yocto1.3_15.03.02_rc1 b16478f2ddd65afa7821b1937885dfb96eff266f
git push origin rel_angstrom-v2012.12-yocto1.3_15.03.02_rc1:refs/tags/rel_angstrom-v2012.12-yocto1.3_15.03.02_rc1
echo

git tag rel_angstrom-v2013.12-yocto1.5_15.03.02_rc1 1090ffbbee1f3b6e45647591d369423ef9b2e41e
git push origin rel_angstrom-v2013.12-yocto1.5_15.03.02_rc1:refs/tags/rel_angstrom-v2013.12-yocto1.5_15.03.02_rc1
echo

git tag rel_angstrom-v2014.06-yocto1.6_15.03.02_rc1 9fe06573ef9f9a3b284edc66d590cb32b67a2f00
git push origin rel_angstrom-v2014.06-yocto1.6_15.03.02_rc1:refs/tags/rel_angstrom-v2014.06-yocto1.6_15.03.02_rc1
echo

git tag rel_angstrom-v2014.12-yocto1.7_15.03.02_rc1 95d38e0d45d418da8cc44f6deeabef08165a2288
git push origin rel_angstrom-v2014.12-yocto1.7_15.03.02_rc1:refs/tags/rel_angstrom-v2014.12-yocto1.7_15.03.02_rc1
echo

git tag rel_angstrom-v2014.12-yocto1.7_a10_15.03.02_rc1 4e05529d826b43428ccdb8e984de2d8ee64a7f02
git push origin rel_angstrom-v2014.12-yocto1.7_a10_15.03.02_rc1:refs/tags/rel_angstrom-v2014.12-yocto1.7_a10_15.03.02_rc1
echo


cd /home/atull/repos/internal/linux-tags
git tag rel_master_15.03.02_rc1 7e2b6b2e23e2f8b2e9911fe62d60d9403d3d1700
git push origin rel_master_15.03.02_rc1:refs/tags/rel_master_15.03.02_rc1
git push origin rel_master_15.03.02_rc1:refs/heads/master
