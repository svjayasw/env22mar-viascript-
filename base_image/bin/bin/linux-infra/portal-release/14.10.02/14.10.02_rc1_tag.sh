#!/bin/bash -ex
# This script tags the local git tree with rc1 tag and pushes to internal git
#

cd /home/atull/repos/internal/linux-socfpga
git tag -f rel_socfpga-3.16_14.10.02_rc1 14cef3b4c21ed3bd2445f1d592b0e54a3af4b3e8
git push origin rel_socfpga-3.16_14.10.02_rc1:refs/tags/rel_socfpga-3.16_14.10.02_rc1
git log --pretty=oneline -1 rel_socfpga-3.16_14.10.02_rc1
echo

git tag rel_socfpga-3.10-ltsi_14.10.02_rc1 4cadc1da3dde817f97e7884679fc32c20f98a7a7
git push origin rel_socfpga-3.10-ltsi_14.10.02_rc1:refs/tags/rel_socfpga-3.10-ltsi_14.10.02_rc1
git log --pretty=oneline -1 rel_socfpga-3.10-ltsi_14.10.02_rc1
echo

git tag rel_socfpga-3.10-ltsi-rt_14.10.02_rc1 83084408e11f1072946c06acd2901556f2e4b2d3
git push origin rel_socfpga-3.10-ltsi-rt_14.10.02_rc1:refs/tags/rel_socfpga-3.10-ltsi-rt_14.10.02_rc1
git log --pretty=oneline -1 rel_socfpga-3.10-ltsi-rt_14.10.02_rc1
echo


cd /home/atull/repos/internal/uboot-socfpga
git tag rel_socfpga_v2013.01.01_14.10.02_rc1 93815696dce132ff8abc4ab2f4c195339ff821a0
git push origin rel_socfpga_v2013.01.01_14.10.02_rc1:refs/tags/rel_socfpga_v2013.01.01_14.10.02_rc1
git log --pretty=oneline -1 rel_socfpga_v2013.01.01_14.10.02_rc1
echo


cd /home/atull/repos/internal/poky
git tag rel_danny-altera_14.10.02_rc1 2ea11347bbdbdab3b5d9bb7a4157f9b7b5607a23
git push origin rel_danny-altera_14.10.02_rc1:refs/tags/rel_danny-altera_14.10.02_rc1
git log --pretty=oneline -1 rel_danny-altera_14.10.02_rc1
echo


cd /home/atull/repos/internal/angstrom-socfpga
git tag rel_angstrom-v2012.12-socfpga_14.10.02_rc1 a7411013b0d87ac0a4596b09a0c19f868e21b667
git push origin rel_angstrom-v2012.12-socfpga_14.10.02_rc1:refs/tags/rel_angstrom-v2012.12-socfpga_14.10.02_rc1
git log --pretty=oneline -1 rel_angstrom-v2012.12-socfpga_14.10.02_rc1
echo

git tag rel_angstrom-v2013.12-socfpga_14.10.02_rc1 86e17311d05ed87f48f296061200e1b4b05a30b7
git push origin rel_angstrom-v2013.12-socfpga_14.10.02_rc1:refs/tags/rel_angstrom-v2013.12-socfpga_14.10.02_rc1
git log --pretty=oneline -1 rel_angstrom-v2013.12-socfpga_14.10.02_rc1
echo

git tag rel_angstrom-v2014.06-socfpga_14.10.02_rc1 4460560c5cada124a6da2ae9306305abcf5f2040
git push origin rel_angstrom-v2014.06-socfpga_14.10.02_rc1:refs/tags/rel_angstrom-v2014.06-socfpga_14.10.02_rc1
git log --pretty=oneline -1 rel_angstrom-v2014.06-socfpga_14.10.02_rc1
echo


cd /home/atull/repos/internal/meta-altera
git tag rel_angstrom-v2012.12-yocto1.3_14.10.02_rc1 b16478f2ddd65afa7821b1937885dfb96eff266f
git push origin rel_angstrom-v2012.12-yocto1.3_14.10.02_rc1:refs/tags/rel_angstrom-v2012.12-yocto1.3_14.10.02_rc1
git log --pretty=oneline -1 rel_angstrom-v2012.12-yocto1.3_14.10.02_rc1
echo

git tag rel_angstrom-v2013.12-yocto1.5_14.10.02_rc1 6b5ff638ad098624a78d1fd5ddd66b1e1a05b750
git push origin rel_angstrom-v2013.12-yocto1.5_14.10.02_rc1:refs/tags/rel_angstrom-v2013.12-yocto1.5_14.10.02_rc1
git log --pretty=oneline -1 rel_angstrom-v2013.12-yocto1.5_14.10.02_rc1
echo

git tag rel_angstrom-v2014.06-yocto1.6_14.10.02_rc1 9fe06573ef9f9a3b284edc66d590cb32b67a2f00
git push origin rel_angstrom-v2014.06-yocto1.6_14.10.02_rc1:refs/tags/rel_angstrom-v2014.06-yocto1.6_14.10.02_rc1
git log --pretty=oneline -1 rel_angstrom-v2014.06-yocto1.6_14.10.02_rc1
echo


cd /home/atull/repos/internal/linux-test
git tag rel_master_14.10.02_rc1 31acc7d3ba8d732e7dd3a1bb5e3166dfa72ef6f6
git push origin rel_master_14.10.02_rc1:refs/tags/rel_master_14.10.02_rc1
git log --pretty=oneline -1 rel_master_14.10.02_rc1
echo


cd /home/atull/repos/internal/linux-infra
git tag rel_tags_v1_14.10.02_rc1 c6207f411e7aea045d089058893ea9f7e3b4689c
git push origin rel_tags_v1_14.10.02_rc1:refs/tags/rel_tags_v1_14.10.02_rc1
git log --pretty=oneline -1 rel_tags_v1_14.10.02_rc1
echo


cd /home/atull/repos/internal/linux-tags
git tag rel_master_14.10.02_rc1 5787a53a7085c2489cb8e57521f92d229be4286b
git push origin rel_master_14.10.02_rc1:refs/tags/rel_master_14.10.02_rc1
git push origin rel_master_14.10.02_rc1:refs/heads/master
