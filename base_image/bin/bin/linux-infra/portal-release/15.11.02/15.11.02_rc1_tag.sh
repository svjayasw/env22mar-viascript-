#!/bin/bash -ex
# This script tags the local git tree with rc1 tag and pushes to internal git
#

cd /home/atull/repos/internal/linux-socfpga
git tag rel_socfpga-4.2_15.11.02_rc1 e7c206510d7606d38f71ad70bad377e390734958
git push origin rel_socfpga-4.2_15.11.02_rc1:refs/tags/rel_socfpga-4.2_15.11.02_rc1
echo

git tag rel_socfpga-3.10-ltsi_15.11.02_rc1 bcf9c6441ec6e785ec1c829b4650a582b5e7559e
git push origin rel_socfpga-3.10-ltsi_15.11.02_rc1:refs/tags/rel_socfpga-3.10-ltsi_15.11.02_rc1
echo

git tag rel_socfpga-3.10-ltsi-rt_15.11.02_rc1 ef8b7fee9f81be67c97e461aa138a1b066f5e0a4
git push origin rel_socfpga-3.10-ltsi-rt_15.11.02_rc1:refs/tags/rel_socfpga-3.10-ltsi-rt_15.11.02_rc1
echo


cd /home/atull/repos/internal/uboot-socfpga
git tag rel_socfpga_v2013.01.01_15.11.02_rc1 4003f38429d308c48773897a1ccf166486b9dd7f
git push origin rel_socfpga_v2013.01.01_15.11.02_rc1:refs/tags/rel_socfpga_v2013.01.01_15.11.02_rc1
echo

git tag rel_socfpga_v2014.10_arria10_bringup_15.11.02_rc1 f6d86c31d18b0efc445982c7d79eeed72ae8151f
git push origin rel_socfpga_v2014.10_arria10_bringup_15.11.02_rc1:refs/tags/rel_socfpga_v2014.10_arria10_bringup_15.11.02_rc1
echo


cd /home/atull/repos/internal/angstrom-socfpga
git tag rel_angstrom-v2014.12-socfpga_15.11.02_rc1 28881bdf04f230c09a60d4480e8b7d670507f692
git push origin rel_angstrom-v2014.12-socfpga_15.11.02_rc1:refs/tags/rel_angstrom-v2014.12-socfpga_15.11.02_rc1
echo


cd /home/atull/repos/internal/meta-altera
git tag rel_angstrom-v2014.12-yocto1.7_15.11.02_rc1 45c0f230fc35b809e32f848105fbcddb2ebfdd3d
git push origin rel_angstrom-v2014.12-yocto1.7_15.11.02_rc1:refs/tags/rel_angstrom-v2014.12-yocto1.7_15.11.02_rc1
echo

git tag rel_angstrom-v2014.12-yocto1.7_a10_15.11.02_rc1 67523b0f770d46a4e363f47b19d3a6a453c66b3f
git push origin rel_angstrom-v2014.12-yocto1.7_a10_15.11.02_rc1:refs/tags/rel_angstrom-v2014.12-yocto1.7_a10_15.11.02_rc1
echo


cd /home/atull/repos/internal/linux-tags
git tag rel_master_15.11.02_rc1 57c9be8cbaefb490613a74d7b79342da547d95c0
git push origin rel_master_15.11.02_rc1:refs/tags/rel_master_15.11.02_rc1
git push origin rel_master_15.11.02_rc1:refs/heads/master
