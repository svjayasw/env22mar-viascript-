#!/bin/bash -ex
# This script tags the local git tree with rc1 tag and pushes to internal git
#

cd /home/atull/repos/internal/linux-socfpga
git tag rel_socfpga-3.18_15.03.01_rc1 2093c64c3a64acd20c76e903043a228c627193bd
git push origin rel_socfpga-3.18_15.03.01_rc1:refs/tags/rel_socfpga-3.18_15.03.01_rc1
echo

git tag rel_socfpga-3.10-ltsi_15.03.01_rc1 aeb52dd352e986a3e20490238729bfde9703f7c3
git push origin rel_socfpga-3.10-ltsi_15.03.01_rc1:refs/tags/rel_socfpga-3.10-ltsi_15.03.01_rc1
echo

git tag rel_socfpga-3.10-ltsi-rt_15.03.01_rc1 7ea94617cfae6a62ee963adc1ae340196dbe2b34
git push origin rel_socfpga-3.10-ltsi-rt_15.03.01_rc1:refs/tags/rel_socfpga-3.10-ltsi-rt_15.03.01_rc1
echo


cd /home/atull/repos/internal/uboot-socfpga
git tag rel_socfpga_v2013.01.01_15.03.01_rc1 32c1d91bc0d10beca54c2dfc5b475d4ffeffc15a
git push origin rel_socfpga_v2013.01.01_15.03.01_rc1:refs/tags/rel_socfpga_v2013.01.01_15.03.01_rc1
echo


cd /home/atull/repos/internal/poky
git tag rel_danny-altera_15.03.01_rc1 2ea11347bbdbdab3b5d9bb7a4157f9b7b5607a23
git push origin rel_danny-altera_15.03.01_rc1:refs/tags/rel_danny-altera_15.03.01_rc1
echo


cd /home/atull/repos/internal/angstrom-socfpga
git tag rel_angstrom-v2012.12-socfpga_15.03.01_rc1 a7411013b0d87ac0a4596b09a0c19f868e21b667
git push origin rel_angstrom-v2012.12-socfpga_15.03.01_rc1:refs/tags/rel_angstrom-v2012.12-socfpga_15.03.01_rc1
echo

git tag rel_angstrom-v2013.12-socfpga_15.03.01_rc1 65417bcfd8d2859fd74ce5d5358fc26152db9991
git push origin rel_angstrom-v2013.12-socfpga_15.03.01_rc1:refs/tags/rel_angstrom-v2013.12-socfpga_15.03.01_rc1
echo

git tag rel_angstrom-v2014.06-socfpga_15.03.01_rc1 4460560c5cada124a6da2ae9306305abcf5f2040
git push origin rel_angstrom-v2014.06-socfpga_15.03.01_rc1:refs/tags/rel_angstrom-v2014.06-socfpga_15.03.01_rc1
echo


cd /home/atull/repos/internal/meta-altera
git tag rel_angstrom-v2012.12-yocto1.3_15.03.01_rc1 b16478f2ddd65afa7821b1937885dfb96eff266f
git push origin rel_angstrom-v2012.12-yocto1.3_15.03.01_rc1:refs/tags/rel_angstrom-v2012.12-yocto1.3_15.03.01_rc1
echo

git tag rel_angstrom-v2013.12-yocto1.5_15.03.01_rc1 1090ffbbee1f3b6e45647591d369423ef9b2e41e
git push origin rel_angstrom-v2013.12-yocto1.5_15.03.01_rc1:refs/tags/rel_angstrom-v2013.12-yocto1.5_15.03.01_rc1
echo

git tag rel_angstrom-v2014.06-yocto1.6_15.03.01_rc1 9fe06573ef9f9a3b284edc66d590cb32b67a2f00
git push origin rel_angstrom-v2014.06-yocto1.6_15.03.01_rc1:refs/tags/rel_angstrom-v2014.06-yocto1.6_15.03.01_rc1
echo


cd /home/atull/repos/internal/linux-test
git tag rel_master_15.03.01_rc1 853b5b2609ba5a0f3ee1bcf656b75c6f7d633c80
git push origin rel_master_15.03.01_rc1:refs/tags/rel_master_15.03.01_rc1
echo


cd /home/atull/repos/internal/linux-infra
git tag rel_tags_v1_15.03.01_rc1 c6207f411e7aea045d089058893ea9f7e3b4689c
git push origin rel_tags_v1_15.03.01_rc1:refs/tags/rel_tags_v1_15.03.01_rc1
echo


cd /home/atull/repos/internal/linux-tags
#git tag rel_master_15.03.01_rc1 c3608264190d32dc0782fcaecea7221cc9b95f4b
# updated to:
git tag rel_master_15.03.01_rc1 d170ffff77c48883596ff5ceed65dd96bd435d5c
git push origin rel_master_15.03.01_rc1:refs/tags/rel_master_15.03.01_rc1
git push origin rel_master_15.03.01_rc1:refs/heads/master
