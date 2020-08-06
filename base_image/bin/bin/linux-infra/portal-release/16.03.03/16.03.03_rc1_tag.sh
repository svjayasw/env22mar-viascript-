#!/bin/bash -ex
# This script tags the local git tree with rc1 tag and pushes to internal git
#

cd /home/atull/repos/internal/linux-socfpga
git tag rel_socfpga-4.4_16.03.03_rc1 5c260da338b2e1b19dd9a67611186e0d817a7cd3
git push origin rel_socfpga-4.4_16.03.03_rc1:refs/tags/rel_socfpga-4.4_16.03.03_rc1
echo

git tag rel_socfpga-3.10-ltsi_16.03.03_rc1 28bac3edbcdc74f98b865986be5d340381896192
git push origin rel_socfpga-3.10-ltsi_16.03.03_rc1:refs/tags/rel_socfpga-3.10-ltsi_16.03.03_rc1
echo

git tag rel_socfpga-3.10-ltsi-rt_16.03.03_rc1 5d6c0ba8572262c29ea3d97fe6d1d5b58650b6e5
git push origin rel_socfpga-3.10-ltsi-rt_16.03.03_rc1:refs/tags/rel_socfpga-3.10-ltsi-rt_16.03.03_rc1
echo

git tag rel_socfpga-4.1-ltsi_16.03.03_rc1 983d349c9458aae3416b3820bfb5bdf5f0230fda
git push origin rel_socfpga-4.1-ltsi_16.03.03_rc1:refs/tags/rel_socfpga-4.1-ltsi_16.03.03_rc1
echo


cd /home/atull/repos/internal/uboot-socfpga
git tag rel_socfpga_v2013.01.01_16.03.03_rc1 e552a7f90788460e00f15fadbebd66606d0a6db4
git push origin rel_socfpga_v2013.01.01_16.03.03_rc1:refs/tags/rel_socfpga_v2013.01.01_16.03.03_rc1
echo

git tag rel_socfpga_v2014.10_arria10_bringup_16.03.03_rc1 be90353cf6a510281f22e15b9f4625e0be16ecb3
git push origin rel_socfpga_v2014.10_arria10_bringup_16.03.03_rc1:refs/tags/rel_socfpga_v2014.10_arria10_bringup_16.03.03_rc1
echo


cd /home/atull/repos/internal/angstrom-socfpga
git tag rel_angstrom-v2014.12-socfpga_16.03.03_rc1 0a2c33dbc636dc02049cfb77f73132d70b36c183
git push origin rel_angstrom-v2014.12-socfpga_16.03.03_rc1:refs/tags/rel_angstrom-v2014.12-socfpga_16.03.03_rc1
echo


cd /home/atull/repos/internal/meta-altera
git tag rel_angstrom-v2014.12-yocto1.7_16.03.03_rc1 8d6e9b468630aa4d9d4c946080f5023dea43d891
git push origin rel_angstrom-v2014.12-yocto1.7_16.03.03_rc1:refs/tags/rel_angstrom-v2014.12-yocto1.7_16.03.03_rc1
echo

git tag rel_angstrom-v2014.12-yocto1.7_a10_16.03.03_rc1 67523b0f770d46a4e363f47b19d3a6a453c66b3f
git push origin rel_angstrom-v2014.12-yocto1.7_a10_16.03.03_rc1:refs/tags/rel_angstrom-v2014.12-yocto1.7_a10_16.03.03_rc1
echo


cd /home/atull/repos/internal/linux-tags
git tag rel_master_16.03.03_rc1 b62f4f01bb144e4049bdeb548fb34604f02f2ccd
git push origin rel_master_16.03.03_rc1:refs/tags/rel_master_16.03.03_rc1
git push origin rel_master_16.03.03_rc1:refs/heads/master
