#!/bin/bash -ex
# This script tags the local git tree with rc1 tag and pushes to internal git
#

cd /home/atull/repos/internal/linux-socfpga
git tag rel_socfpga-4.3_16.01.02_rc1 36cbe30c34b0736af66d3d7f2c19279e84560dbe
git push origin rel_socfpga-4.3_16.01.02_rc1:refs/tags/rel_socfpga-4.3_16.01.02_rc1
echo

git tag rel_socfpga-3.10-ltsi_16.01.02_rc1 22e8856f546423a4f45613c9fb0428ff9e395c7e
git push origin rel_socfpga-3.10-ltsi_16.01.02_rc1:refs/tags/rel_socfpga-3.10-ltsi_16.01.02_rc1
echo

git tag rel_socfpga-3.10-ltsi-rt_16.01.02_rc1 0de1eb3661f943e3ddf54cdac9f6ade0fcb9a8ad
git push origin rel_socfpga-3.10-ltsi-rt_16.01.02_rc1:refs/tags/rel_socfpga-3.10-ltsi-rt_16.01.02_rc1
echo


cd /home/atull/repos/internal/uboot-socfpga
git tag rel_socfpga_v2013.01.01_16.01.02_rc1 d141e218f3195e305c1521a0d67c81b7cb504b71
git push origin rel_socfpga_v2013.01.01_16.01.02_rc1:refs/tags/rel_socfpga_v2013.01.01_16.01.02_rc1
echo

git tag rel_socfpga_v2014.10_arria10_bringup_16.01.02_rc1 570a0b52a7aa40514dc4a6ffc26400b84448992c
git push origin rel_socfpga_v2014.10_arria10_bringup_16.01.02_rc1:refs/tags/rel_socfpga_v2014.10_arria10_bringup_16.01.02_rc1
echo


cd /home/atull/repos/internal/angstrom-socfpga
git tag rel_angstrom-v2014.12-socfpga_16.01.02_rc1 bc6ea8d92853abcd09632eb791a2f824f3031b53
git push origin rel_angstrom-v2014.12-socfpga_16.01.02_rc1:refs/tags/rel_angstrom-v2014.12-socfpga_16.01.02_rc1
echo


cd /home/atull/repos/internal/meta-altera
git tag rel_angstrom-v2014.12-yocto1.7_16.01.02_rc1 8d6e9b468630aa4d9d4c946080f5023dea43d891
git push origin rel_angstrom-v2014.12-yocto1.7_16.01.02_rc1:refs/tags/rel_angstrom-v2014.12-yocto1.7_16.01.02_rc1
echo

git tag rel_angstrom-v2014.12-yocto1.7_a10_16.01.02_rc1 67523b0f770d46a4e363f47b19d3a6a453c66b3f
git push origin rel_angstrom-v2014.12-yocto1.7_a10_16.01.02_rc1:refs/tags/rel_angstrom-v2014.12-yocto1.7_a10_16.01.02_rc1
echo


cd /home/atull/repos/internal/linux-tags
git tag rel_master_16.01.02_rc1 530787cfcc9bef3b97ab24607741e4ee10220dcf
git push origin rel_master_16.01.02_rc1:refs/tags/rel_master_16.01.02_rc1
git push origin rel_master_16.01.02_rc1:refs/heads/master
