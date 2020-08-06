#!/bin/bash -ex
# This script tags the local git tree with rc1 tag and pushes to internal git
#

cd /home/atull/repos/internal/linux-socfpga
git tag rel_socfpga-3.16_14.11.01_rc1 9e70f262ad67bfe59979da9db32c6ffaba4f52c7
git push origin rel_socfpga-3.16_14.11.01_rc1:refs/tags/rel_socfpga-3.16_14.11.01_rc1
git log --pretty=oneline -1 rel_socfpga-3.16_14.11.01_rc1
echo

git tag rel_socfpga-3.10-ltsi_14.11.01_rc1 4ce347478243906d9ac598a23890265a1eb193ac
git push origin rel_socfpga-3.10-ltsi_14.11.01_rc1:refs/tags/rel_socfpga-3.10-ltsi_14.11.01_rc1
git log --pretty=oneline -1 rel_socfpga-3.10-ltsi_14.11.01_rc1
echo

git tag rel_socfpga-3.10-ltsi-rt_14.11.01_rc1 bc5b6fb2e02500130a8f2a4b5e90752adeb1a965
git push origin rel_socfpga-3.10-ltsi-rt_14.11.01_rc1:refs/tags/rel_socfpga-3.10-ltsi-rt_14.11.01_rc1
git log --pretty=oneline -1 rel_socfpga-3.10-ltsi-rt_14.11.01_rc1
echo


cd /home/atull/repos/internal/uboot-socfpga
git tag rel_socfpga_v2013.01.01_14.11.01_rc1 5f58921738debfc7b09d15b08cd0a13a303bc504
git push origin rel_socfpga_v2013.01.01_14.11.01_rc1:refs/tags/rel_socfpga_v2013.01.01_14.11.01_rc1
git log --pretty=oneline -1 rel_socfpga_v2013.01.01_14.11.01_rc1
echo


cd /home/atull/repos/internal/poky
git tag rel_danny-altera_14.11.01_rc1 2ea11347bbdbdab3b5d9bb7a4157f9b7b5607a23
git push origin rel_danny-altera_14.11.01_rc1:refs/tags/rel_danny-altera_14.11.01_rc1
git log --pretty=oneline -1 rel_danny-altera_14.11.01_rc1
echo


cd /home/atull/repos/internal/angstrom-socfpga
git tag rel_angstrom-v2012.12-socfpga_14.11.01_rc1 a7411013b0d87ac0a4596b09a0c19f868e21b667
git push origin rel_angstrom-v2012.12-socfpga_14.11.01_rc1:refs/tags/rel_angstrom-v2012.12-socfpga_14.11.01_rc1
git log --pretty=oneline -1 rel_angstrom-v2012.12-socfpga_14.11.01_rc1
echo

git tag rel_angstrom-v2013.12-socfpga_14.11.01_rc1 86e17311d05ed87f48f296061200e1b4b05a30b7
git push origin rel_angstrom-v2013.12-socfpga_14.11.01_rc1:refs/tags/rel_angstrom-v2013.12-socfpga_14.11.01_rc1
git log --pretty=oneline -1 rel_angstrom-v2013.12-socfpga_14.11.01_rc1
echo

git tag rel_angstrom-v2014.06-socfpga_14.11.01_rc1 4460560c5cada124a6da2ae9306305abcf5f2040
git push origin rel_angstrom-v2014.06-socfpga_14.11.01_rc1:refs/tags/rel_angstrom-v2014.06-socfpga_14.11.01_rc1
git log --pretty=oneline -1 rel_angstrom-v2014.06-socfpga_14.11.01_rc1
echo


cd /home/atull/repos/internal/meta-altera
git tag rel_angstrom-v2012.12-yocto1.3_14.11.01_rc1 b16478f2ddd65afa7821b1937885dfb96eff266f
git push origin rel_angstrom-v2012.12-yocto1.3_14.11.01_rc1:refs/tags/rel_angstrom-v2012.12-yocto1.3_14.11.01_rc1
git log --pretty=oneline -1 rel_angstrom-v2012.12-yocto1.3_14.11.01_rc1
echo

git tag rel_angstrom-v2013.12-yocto1.5_14.11.01_rc1 6b5ff638ad098624a78d1fd5ddd66b1e1a05b750
git push origin rel_angstrom-v2013.12-yocto1.5_14.11.01_rc1:refs/tags/rel_angstrom-v2013.12-yocto1.5_14.11.01_rc1
git log --pretty=oneline -1 rel_angstrom-v2013.12-yocto1.5_14.11.01_rc1
echo

git tag rel_angstrom-v2014.06-yocto1.6_14.11.01_rc1 9fe06573ef9f9a3b284edc66d590cb32b67a2f00
git push origin rel_angstrom-v2014.06-yocto1.6_14.11.01_rc1:refs/tags/rel_angstrom-v2014.06-yocto1.6_14.11.01_rc1
git log --pretty=oneline -1 rel_angstrom-v2014.06-yocto1.6_14.11.01_rc1
echo


cd /home/atull/repos/internal/linux-test
git tag rel_master_14.11.01_rc1 7ffd5a1d1442ea6c1c5379da0b7834f802071674
git push origin rel_master_14.11.01_rc1:refs/tags/rel_master_14.11.01_rc1
git log --pretty=oneline -1 rel_master_14.11.01_rc1
echo


cd /home/atull/repos/internal/linux-infra
git tag rel_tags_v1_14.11.01_rc1 c6207f411e7aea045d089058893ea9f7e3b4689c
git push origin rel_tags_v1_14.11.01_rc1:refs/tags/rel_tags_v1_14.11.01_rc1
git log --pretty=oneline -1 rel_tags_v1_14.11.01_rc1
echo


cd /home/atull/repos/internal/linux-tags
git tag rel_master_14.11.01_rc1 65b377206b6d6ba65963205204b57fdc715c6224
git push origin rel_master_14.11.01_rc1:refs/tags/rel_master_14.11.01_rc1
git push origin rel_master_14.11.01_rc1:refs/heads/master
