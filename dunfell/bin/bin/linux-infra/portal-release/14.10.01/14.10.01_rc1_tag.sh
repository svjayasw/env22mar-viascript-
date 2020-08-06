#!/bin/bash -ex
# This script tags the local git tree with rc1 tag and pushes to internal git
#

cd /home/atull/repos/internal/linux-socfpga
git tag rel_socfpga-3.16_14.10.01_rc1 73b8057eedd623269600b233f82d4378631dba8c
git push origin rel_socfpga-3.16_14.10.01_rc1:refs/tags/rel_socfpga-3.16_14.10.01_rc1
git log --pretty=oneline -1 rel_socfpga-3.16_14.10.01_rc1
echo

git tag rel_socfpga-3.10-ltsi_14.10.01_rc1 8beef1b8853317a29df139ca4bb71c03c55227c1
git push origin rel_socfpga-3.10-ltsi_14.10.01_rc1:refs/tags/rel_socfpga-3.10-ltsi_14.10.01_rc1
git log --pretty=oneline -1 rel_socfpga-3.10-ltsi_14.10.01_rc1
echo

git tag rel_socfpga-3.10-ltsi-rt_14.10.01_rc1 37a12476091c71bfe7b023dae534424437116e64
git push origin rel_socfpga-3.10-ltsi-rt_14.10.01_rc1:refs/tags/rel_socfpga-3.10-ltsi-rt_14.10.01_rc1
git log --pretty=oneline -1 rel_socfpga-3.10-ltsi-rt_14.10.01_rc1
echo


cd /home/atull/repos/internal/uboot-socfpga
git tag rel_socfpga_v2013.01.01_14.10.01_rc1 890e22efc69956237fc19baa75962db11df6e10e
git push origin rel_socfpga_v2013.01.01_14.10.01_rc1:refs/tags/rel_socfpga_v2013.01.01_14.10.01_rc1
git log --pretty=oneline -1 rel_socfpga_v2013.01.01_14.10.01_rc1
echo


cd /home/atull/repos/internal/poky
git tag rel_danny-altera_14.10.01_rc1 2ea11347bbdbdab3b5d9bb7a4157f9b7b5607a23
git push origin rel_danny-altera_14.10.01_rc1:refs/tags/rel_danny-altera_14.10.01_rc1
git log --pretty=oneline -1 rel_danny-altera_14.10.01_rc1
echo


cd /home/atull/repos/internal/angstrom-socfpga
git tag rel_angstrom-v2012.12-socfpga_14.10.01_rc1 a7411013b0d87ac0a4596b09a0c19f868e21b667
git push origin rel_angstrom-v2012.12-socfpga_14.10.01_rc1:refs/tags/rel_angstrom-v2012.12-socfpga_14.10.01_rc1
git log --pretty=oneline -1 rel_angstrom-v2012.12-socfpga_14.10.01_rc1
echo

git tag rel_angstrom-v2013.12-socfpga_14.10.01_rc1 86e17311d05ed87f48f296061200e1b4b05a30b7
git push origin rel_angstrom-v2013.12-socfpga_14.10.01_rc1:refs/tags/rel_angstrom-v2013.12-socfpga_14.10.01_rc1
git log --pretty=oneline -1 rel_angstrom-v2013.12-socfpga_14.10.01_rc1
echo

git tag rel_angstrom-v2014.06-socfpga_14.10.01_rc1 4460560c5cada124a6da2ae9306305abcf5f2040
git push origin rel_angstrom-v2014.06-socfpga_14.10.01_rc1:refs/tags/rel_angstrom-v2014.06-socfpga_14.10.01_rc1
git log --pretty=oneline -1 rel_angstrom-v2014.06-socfpga_14.10.01_rc1
echo


cd /home/atull/repos/internal/meta-altera
git tag rel_angstrom-v2012.12-yocto1.3_14.10.01_rc1 b16478f2ddd65afa7821b1937885dfb96eff266f
git push origin rel_angstrom-v2012.12-yocto1.3_14.10.01_rc1:refs/tags/rel_angstrom-v2012.12-yocto1.3_14.10.01_rc1
git log --pretty=oneline -1 rel_angstrom-v2012.12-yocto1.3_14.10.01_rc1
echo

git tag rel_angstrom-v2013.12-yocto1.5_14.10.01_rc1 d536811edb414cd85778eaf8fbec9ad0fc480ab1
git push origin rel_angstrom-v2013.12-yocto1.5_14.10.01_rc1:refs/tags/rel_angstrom-v2013.12-yocto1.5_14.10.01_rc1
git log --pretty=oneline -1 rel_angstrom-v2013.12-yocto1.5_14.10.01_rc1
echo

git tag rel_angstrom-v2014.06-yocto1.6_14.10.01_rc1 9fe06573ef9f9a3b284edc66d590cb32b67a2f00
git push origin rel_angstrom-v2014.06-yocto1.6_14.10.01_rc1:refs/tags/rel_angstrom-v2014.06-yocto1.6_14.10.01_rc1
git log --pretty=oneline -1 rel_angstrom-v2014.06-yocto1.6_14.10.01_rc1
echo


cd /home/atull/repos/internal/linux-test
git tag rel_master_14.10.01_rc1 6752c00d38ea7cca61f178b9d4d2e5fd9c096b4c
git push origin rel_master_14.10.01_rc1:refs/tags/rel_master_14.10.01_rc1
git log --pretty=oneline -1 rel_master_14.10.01_rc1
echo


cd /home/atull/repos/internal/linux-infra
git tag rel_tags_v1_14.10.01_rc1 0551b6170588be6d7281cf8cdd530295118c3435
git push origin rel_tags_v1_14.10.01_rc1:refs/tags/rel_tags_v1_14.10.01_rc1
git log --pretty=oneline -1 rel_tags_v1_14.10.01_rc1
echo


cd /home/atull/repos/internal/linux-tags
git tag rel_master_14.10.01_rc1 16195cd68e6bdd5ef95878a7c0c559a5dcce7153
git push origin rel_master_14.10.01_rc1:refs/tags/rel_master_14.10.01_rc1
git push origin rel_master_14.10.01_rc1:refs/heads/master
