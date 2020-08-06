#!/bin/bash -ex
# This script tags the local git tree with rc1 tag and pushes to internal git
#

cd /home/atull/repos/internal/linux-socfpga
git tag rel_socfpga-4.3_16.03.01_rc1 5cfcedda974096ed2be90f490879c0b0e1a0171b
git push origin rel_socfpga-4.3_16.03.01_rc1:refs/tags/rel_socfpga-4.3_16.03.01_rc1
echo

git tag rel_socfpga-3.10-ltsi_16.03.01_rc1 28bac3edbcdc74f98b865986be5d340381896192
git push origin rel_socfpga-3.10-ltsi_16.03.01_rc1:refs/tags/rel_socfpga-3.10-ltsi_16.03.01_rc1
echo

git tag rel_socfpga-3.10-ltsi-rt_16.03.01_rc1 5d6c0ba8572262c29ea3d97fe6d1d5b58650b6e5
git push origin rel_socfpga-3.10-ltsi-rt_16.03.01_rc1:refs/tags/rel_socfpga-3.10-ltsi-rt_16.03.01_rc1
echo


cd /home/atull/repos/internal/uboot-socfpga
git tag rel_socfpga_v2013.01.01_16.03.01_rc1 d141e218f3195e305c1521a0d67c81b7cb504b71
git push origin rel_socfpga_v2013.01.01_16.03.01_rc1:refs/tags/rel_socfpga_v2013.01.01_16.03.01_rc1
echo

git tag rel_socfpga_v2014.10_arria10_bringup_16.03.01_rc1 554fc740bb71fa4325847af448c4c38ce41954e1
git push origin rel_socfpga_v2014.10_arria10_bringup_16.03.01_rc1:refs/tags/rel_socfpga_v2014.10_arria10_bringup_16.03.01_rc1
echo


cd /home/atull/repos/internal/angstrom-socfpga
git tag rel_angstrom-v2014.12-socfpga_16.03.01_rc1 bc6ea8d92853abcd09632eb791a2f824f3031b53
git push origin rel_angstrom-v2014.12-socfpga_16.03.01_rc1:refs/tags/rel_angstrom-v2014.12-socfpga_16.03.01_rc1
echo


cd /home/atull/repos/internal/meta-altera
git tag rel_angstrom-v2014.12-yocto1.7_16.03.01_rc1 8d6e9b468630aa4d9d4c946080f5023dea43d891
git push origin rel_angstrom-v2014.12-yocto1.7_16.03.01_rc1:refs/tags/rel_angstrom-v2014.12-yocto1.7_16.03.01_rc1
echo

git tag rel_angstrom-v2014.12-yocto1.7_a10_16.03.01_rc1 67523b0f770d46a4e363f47b19d3a6a453c66b3f
git push origin rel_angstrom-v2014.12-yocto1.7_a10_16.03.01_rc1:refs/tags/rel_angstrom-v2014.12-yocto1.7_a10_16.03.01_rc1
echo


cd /home/atull/repos/internal/linux-tags
git tag rel_master_16.03.01_rc1 38824a08d7faaa19807f020b4e33ca0f16dbbdbc
git push origin rel_master_16.03.01_rc1:refs/tags/rel_master_16.03.01_rc1
git push origin rel_master_16.03.01_rc1:refs/heads/master
