#!/bin/bash -ex
# This script tags the local git tree with rc1 tag and pushes to internal git
#

cd /home/atull/repos/internal/linux-socfpga
git tag rel_socfpga-4.4_16.05.01_rc1 84eb65f84ea7a15cd73766fb16e6a868dc7a734b
git push origin rel_socfpga-4.4_16.05.01_rc1:refs/tags/rel_socfpga-4.4_16.05.01_rc1
echo

git tag rel_socfpga-4.1-ltsi_16.05.01_rc1 451753c4c96a111696cc6d8154ad58a079dadb5a
git push origin rel_socfpga-4.1-ltsi_16.05.01_rc1:refs/tags/rel_socfpga-4.1-ltsi_16.05.01_rc1
echo

git tag rel_socfpga-4.1-ltsi-rt_16.05.01_rc1 33676422bf8d512f7c2957bcd901513daa78df2b
git push origin rel_socfpga-4.1-ltsi-rt_16.05.01_rc1:refs/tags/rel_socfpga-4.1-ltsi-rt_16.05.01_rc1
echo


cd /home/atull/repos/internal/uboot-socfpga
git tag rel_socfpga_v2013.01.01_16.05.01_rc1 7dd0473e47ede9fd240969846a42f5646f565ce9
git push origin rel_socfpga_v2013.01.01_16.05.01_rc1:refs/tags/rel_socfpga_v2013.01.01_16.05.01_rc1
echo

git tag rel_socfpga_v2014.10_arria10_bringup_16.05.01_rc1 a4e19a83f21b0d71e1cf799403529daf5942f548
git push origin rel_socfpga_v2014.10_arria10_bringup_16.05.01_rc1:refs/tags/rel_socfpga_v2014.10_arria10_bringup_16.05.01_rc1
echo


cd /home/atull/repos/internal/angstrom-socfpga
git tag rel_angstrom-v2014.12-socfpga_16.05.01_rc1 993831b4830af2341ca26cd96e16732fa2d00e19
git push origin rel_angstrom-v2014.12-socfpga_16.05.01_rc1:refs/tags/rel_angstrom-v2014.12-socfpga_16.05.01_rc1
echo


cd /home/atull/repos/internal/meta-altera
git tag rel_angstrom-v2014.12-yocto1.7_16.05.01_rc1 8d6e9b468630aa4d9d4c946080f5023dea43d891
git push origin rel_angstrom-v2014.12-yocto1.7_16.05.01_rc1:refs/tags/rel_angstrom-v2014.12-yocto1.7_16.05.01_rc1
echo

git tag rel_angstrom-v2014.12-yocto1.7_a10_16.05.01_rc1 67523b0f770d46a4e363f47b19d3a6a453c66b3f
git push origin rel_angstrom-v2014.12-yocto1.7_a10_16.05.01_rc1:refs/tags/rel_angstrom-v2014.12-yocto1.7_a10_16.05.01_rc1
echo


cd /home/atull/repos/internal/linux-tags
git tag rel_master_16.05.01_rc1 bcaa6c6b89533ea97bd181982514d6290f5f973e
git push origin rel_master_16.05.01_rc1:refs/tags/rel_master_16.05.01_rc1
git push origin rel_master_16.05.01_rc1:refs/heads/master
