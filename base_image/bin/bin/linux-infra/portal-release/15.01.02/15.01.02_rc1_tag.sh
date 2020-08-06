#!/bin/bash -ex
# This script tags the local git tree with rc1 tag and pushes to internal git
#

cd /home/atull/repos/internal/linux-socfpga
git tag rel_socfpga-3.17_15.01.02_rc1 1cd4171e4b895b6d1c8edfecef41863712b91673
git push origin rel_socfpga-3.17_15.01.02_rc1:refs/tags/rel_socfpga-3.17_15.01.02_rc1
echo

git tag rel_socfpga-3.10-ltsi_15.01.02_rc1 95ac4d3f1098a12e94c95bc432fed81227084042
git push origin rel_socfpga-3.10-ltsi_15.01.02_rc1:refs/tags/rel_socfpga-3.10-ltsi_15.01.02_rc1
echo

git tag rel_socfpga-3.10-ltsi-rt_15.01.02_rc1 7ea94617cfae6a62ee963adc1ae340196dbe2b34
git push origin rel_socfpga-3.10-ltsi-rt_15.01.02_rc1:refs/tags/rel_socfpga-3.10-ltsi-rt_15.01.02_rc1
echo


cd /home/atull/repos/internal/uboot-socfpga
git tag rel_socfpga_v2013.01.01_15.01.02_rc1 32c1d91bc0d10beca54c2dfc5b475d4ffeffc15a
git push origin rel_socfpga_v2013.01.01_15.01.02_rc1:refs/tags/rel_socfpga_v2013.01.01_15.01.02_rc1
echo


cd /home/atull/repos/internal/poky
git tag rel_danny-altera_15.01.02_rc1 2ea11347bbdbdab3b5d9bb7a4157f9b7b5607a23
git push origin rel_danny-altera_15.01.02_rc1:refs/tags/rel_danny-altera_15.01.02_rc1
echo


cd /home/atull/repos/internal/angstrom-socfpga
git tag rel_angstrom-v2012.12-socfpga_15.01.02_rc1 a7411013b0d87ac0a4596b09a0c19f868e21b667
git push origin rel_angstrom-v2012.12-socfpga_15.01.02_rc1:refs/tags/rel_angstrom-v2012.12-socfpga_15.01.02_rc1
echo

git tag rel_angstrom-v2013.12-socfpga_15.01.02_rc1 65417bcfd8d2859fd74ce5d5358fc26152db9991
git push origin rel_angstrom-v2013.12-socfpga_15.01.02_rc1:refs/tags/rel_angstrom-v2013.12-socfpga_15.01.02_rc1
echo

git tag rel_angstrom-v2014.06-socfpga_15.01.02_rc1 4460560c5cada124a6da2ae9306305abcf5f2040
git push origin rel_angstrom-v2014.06-socfpga_15.01.02_rc1:refs/tags/rel_angstrom-v2014.06-socfpga_15.01.02_rc1
echo


cd /home/atull/repos/internal/meta-altera
git tag rel_angstrom-v2012.12-yocto1.3_15.01.02_rc1 b16478f2ddd65afa7821b1937885dfb96eff266f
git push origin rel_angstrom-v2012.12-yocto1.3_15.01.02_rc1:refs/tags/rel_angstrom-v2012.12-yocto1.3_15.01.02_rc1
echo

git tag rel_angstrom-v2013.12-yocto1.5_15.01.02_rc1 fe61959bc970fc393e6cab020fda0fbabe807222
git push origin rel_angstrom-v2013.12-yocto1.5_15.01.02_rc1:refs/tags/rel_angstrom-v2013.12-yocto1.5_15.01.02_rc1
echo

git tag rel_angstrom-v2014.06-yocto1.6_15.01.02_rc1 9fe06573ef9f9a3b284edc66d590cb32b67a2f00
git push origin rel_angstrom-v2014.06-yocto1.6_15.01.02_rc1:refs/tags/rel_angstrom-v2014.06-yocto1.6_15.01.02_rc1
echo


cd /home/atull/repos/internal/linux-test
git tag rel_master_15.01.02_rc1 853b5b2609ba5a0f3ee1bcf656b75c6f7d633c80
git push origin rel_master_15.01.02_rc1:refs/tags/rel_master_15.01.02_rc1
echo


cd /home/atull/repos/internal/linux-infra
git tag rel_tags_v1_15.01.02_rc1 c6207f411e7aea045d089058893ea9f7e3b4689c
git push origin rel_tags_v1_15.01.02_rc1:refs/tags/rel_tags_v1_15.01.02_rc1
echo


cd /home/atull/repos/internal/linux-tags
git tag rel_master_15.01.02_rc1 861a37c993c9bfd31b1dcc131f93f98fbbe9eaeb
git push origin rel_master_15.01.02_rc1:refs/tags/rel_master_15.01.02_rc1
git push origin rel_master_15.01.02_rc1:refs/heads/master
