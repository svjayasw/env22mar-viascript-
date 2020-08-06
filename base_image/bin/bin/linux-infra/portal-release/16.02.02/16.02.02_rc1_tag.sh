#!/bin/bash -ex
# This script tags the local git tree with rc1 tag and pushes to internal git
#

cd /home/atull/repos/internal/linux-socfpga
git tag rel_socfpga-4.3_16.02.02_rc1 4380e64695fdfa149cc82c423f3ece666531d79e
git push origin rel_socfpga-4.3_16.02.02_rc1:refs/tags/rel_socfpga-4.3_16.02.02_rc1
echo

git tag rel_socfpga-3.10-ltsi_16.02.02_rc1 28bac3edbcdc74f98b865986be5d340381896192
git push origin rel_socfpga-3.10-ltsi_16.02.02_rc1:refs/tags/rel_socfpga-3.10-ltsi_16.02.02_rc1
echo

git tag rel_socfpga-3.10-ltsi-rt_16.02.02_rc1 5d6c0ba8572262c29ea3d97fe6d1d5b58650b6e5
git push origin rel_socfpga-3.10-ltsi-rt_16.02.02_rc1:refs/tags/rel_socfpga-3.10-ltsi-rt_16.02.02_rc1
echo


cd /home/atull/repos/internal/uboot-socfpga
git tag rel_socfpga_v2013.01.01_16.02.02_rc1 d141e218f3195e305c1521a0d67c81b7cb504b71
git push origin rel_socfpga_v2013.01.01_16.02.02_rc1:refs/tags/rel_socfpga_v2013.01.01_16.02.02_rc1
echo

git tag rel_socfpga_v2014.10_arria10_bringup_16.02.02_rc1 570a0b52a7aa40514dc4a6ffc26400b84448992c
git push origin rel_socfpga_v2014.10_arria10_bringup_16.02.02_rc1:refs/tags/rel_socfpga_v2014.10_arria10_bringup_16.02.02_rc1
echo


cd /home/atull/repos/internal/angstrom-socfpga
git tag rel_angstrom-v2014.12-socfpga_16.02.02_rc1 bc6ea8d92853abcd09632eb791a2f824f3031b53
git push origin rel_angstrom-v2014.12-socfpga_16.02.02_rc1:refs/tags/rel_angstrom-v2014.12-socfpga_16.02.02_rc1
echo


cd /home/atull/repos/internal/meta-altera
git tag rel_angstrom-v2014.12-yocto1.7_16.02.02_rc1 8d6e9b468630aa4d9d4c946080f5023dea43d891
git push origin rel_angstrom-v2014.12-yocto1.7_16.02.02_rc1:refs/tags/rel_angstrom-v2014.12-yocto1.7_16.02.02_rc1
echo

git tag rel_angstrom-v2014.12-yocto1.7_a10_16.02.02_rc1 67523b0f770d46a4e363f47b19d3a6a453c66b3f
git push origin rel_angstrom-v2014.12-yocto1.7_a10_16.02.02_rc1:refs/tags/rel_angstrom-v2014.12-yocto1.7_a10_16.02.02_rc1
echo


cd /home/atull/repos/internal/linux-tags
git tag rel_master_16.02.02_rc1 59df9e22f0262bbb005d4fbd6fbdbff54d88d53e
git push origin rel_master_16.02.02_rc1:refs/tags/rel_master_16.02.02_rc1
git push origin rel_master_16.02.02_rc1:refs/heads/master
