#!/bin/bash -ex
# This script tags the local git tree with rc1 tag and pushes to internal git
#

cd /home/atull/repos/internal/linux-socfpga
git tag rel_socfpga-3.18_15.04.02_rc1 0e9c1d95078974567db80f9e88f68483fc50034a
git push origin rel_socfpga-3.18_15.04.02_rc1:refs/tags/rel_socfpga-3.18_15.04.02_rc1
echo

git tag rel_socfpga-3.10-ltsi_15.04.02_rc1 512a3b04906cb51bb65850a91c5cbdfe00aae8bb
git push origin rel_socfpga-3.10-ltsi_15.04.02_rc1:refs/tags/rel_socfpga-3.10-ltsi_15.04.02_rc1
echo

git tag rel_socfpga-3.10-ltsi-rt_15.04.02_rc1 e9fcb0a7dc922763ec1a11641b0792dfa12dcebf
git push origin rel_socfpga-3.10-ltsi-rt_15.04.02_rc1:refs/tags/rel_socfpga-3.10-ltsi-rt_15.04.02_rc1
echo


cd /home/atull/repos/internal/uboot-socfpga
git tag rel_socfpga_v2013.01.01_15.04.02_rc1 32c1d91bc0d10beca54c2dfc5b475d4ffeffc15a
git push origin rel_socfpga_v2013.01.01_15.04.02_rc1:refs/tags/rel_socfpga_v2013.01.01_15.04.02_rc1
echo

git tag rel_socfpga_v2014.10_arria10_bringup_15.04.02_rc1 35f437edc7b5fa30e39f03b0fc636e38b4e375c5
git push origin rel_socfpga_v2014.10_arria10_bringup_15.04.02_rc1:refs/tags/rel_socfpga_v2014.10_arria10_bringup_15.04.02_rc1
echo


cd /home/atull/repos/internal/poky
git tag rel_danny-altera_15.04.02_rc1 2ea11347bbdbdab3b5d9bb7a4157f9b7b5607a23
git push origin rel_danny-altera_15.04.02_rc1:refs/tags/rel_danny-altera_15.04.02_rc1
echo


cd /home/atull/repos/internal/angstrom-socfpga
git tag rel_angstrom-v2012.12-socfpga_15.04.02_rc1 a7411013b0d87ac0a4596b09a0c19f868e21b667
git push origin rel_angstrom-v2012.12-socfpga_15.04.02_rc1:refs/tags/rel_angstrom-v2012.12-socfpga_15.04.02_rc1
echo

git tag rel_angstrom-v2013.12-socfpga_15.04.02_rc1 65417bcfd8d2859fd74ce5d5358fc26152db9991
git push origin rel_angstrom-v2013.12-socfpga_15.04.02_rc1:refs/tags/rel_angstrom-v2013.12-socfpga_15.04.02_rc1
echo

git tag rel_angstrom-v2014.06-socfpga_15.04.02_rc1 4460560c5cada124a6da2ae9306305abcf5f2040
git push origin rel_angstrom-v2014.06-socfpga_15.04.02_rc1:refs/tags/rel_angstrom-v2014.06-socfpga_15.04.02_rc1
echo

git tag rel_angstrom-v2014.12-socfpga_15.04.02_rc1 3990895ae9f2256377b62b343e4d7a27b51c0266
git push origin rel_angstrom-v2014.12-socfpga_15.04.02_rc1:refs/tags/rel_angstrom-v2014.12-socfpga_15.04.02_rc1
echo


cd /home/atull/repos/internal/meta-altera
git tag rel_angstrom-v2012.12-yocto1.3_15.04.02_rc1 b16478f2ddd65afa7821b1937885dfb96eff266f
git push origin rel_angstrom-v2012.12-yocto1.3_15.04.02_rc1:refs/tags/rel_angstrom-v2012.12-yocto1.3_15.04.02_rc1
echo

git tag rel_angstrom-v2013.12-yocto1.5_15.04.02_rc1 1090ffbbee1f3b6e45647591d369423ef9b2e41e
git push origin rel_angstrom-v2013.12-yocto1.5_15.04.02_rc1:refs/tags/rel_angstrom-v2013.12-yocto1.5_15.04.02_rc1
echo

git tag rel_angstrom-v2014.06-yocto1.6_15.04.02_rc1 9fe06573ef9f9a3b284edc66d590cb32b67a2f00
git push origin rel_angstrom-v2014.06-yocto1.6_15.04.02_rc1:refs/tags/rel_angstrom-v2014.06-yocto1.6_15.04.02_rc1
echo

git tag rel_angstrom-v2014.12-yocto1.7_15.04.02_rc1 95d38e0d45d418da8cc44f6deeabef08165a2288
git push origin rel_angstrom-v2014.12-yocto1.7_15.04.02_rc1:refs/tags/rel_angstrom-v2014.12-yocto1.7_15.04.02_rc1
echo

git tag rel_angstrom-v2014.12-yocto1.7_a10_15.04.02_rc1 28888cd94a4afd88a67929f47b895f0b0c65699e
git push origin rel_angstrom-v2014.12-yocto1.7_a10_15.04.02_rc1:refs/tags/rel_angstrom-v2014.12-yocto1.7_a10_15.04.02_rc1
echo


cd /home/atull/repos/internal/linux-tags
git tag rel_master_15.04.02_rc1 d9e9fad782748157fe9cfbc3bf7f4ab654fd7528
git push origin rel_master_15.04.02_rc1:refs/tags/rel_master_15.04.02_rc1
git push origin rel_master_15.04.02_rc1:refs/heads/master
