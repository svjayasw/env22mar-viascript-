#!/bin/bash -ex
# This script tags the local git tree with rc1 tag and pushes to internal git
#

cd /home/atull/repos/internal/linux-socfpga
git tag rel_socfpga-4.5_16.05.02_rc1 ffea805b5209e0e6ad8645217f5ab742455a066b
git push origin rel_socfpga-4.5_16.05.02_rc1:refs/tags/rel_socfpga-4.5_16.05.02_rc1
echo

git tag rel_socfpga-4.1-ltsi_16.05.02_rc1 11fc4600c61cc937b44f9bb15ffed6a2a2bd0eb8
git push origin rel_socfpga-4.1-ltsi_16.05.02_rc1:refs/tags/rel_socfpga-4.1-ltsi_16.05.02_rc1
echo

git tag rel_socfpga-4.1-ltsi-rt_16.05.02_rc1 33676422bf8d512f7c2957bcd901513daa78df2b
git push origin rel_socfpga-4.1-ltsi-rt_16.05.02_rc1:refs/tags/rel_socfpga-4.1-ltsi-rt_16.05.02_rc1
echo


cd /home/atull/repos/internal/uboot-socfpga
git tag rel_socfpga_v2013.01.01_16.05.02_rc1 7dd0473e47ede9fd240969846a42f5646f565ce9
git push origin rel_socfpga_v2013.01.01_16.05.02_rc1:refs/tags/rel_socfpga_v2013.01.01_16.05.02_rc1
echo

git tag rel_socfpga_v2014.10_arria10_bringup_16.05.02_rc1 5b78d5ae52baeb3b10b182dfba9cf639c680b8f2
git push origin rel_socfpga_v2014.10_arria10_bringup_16.05.02_rc1:refs/tags/rel_socfpga_v2014.10_arria10_bringup_16.05.02_rc1
echo


cd /home/atull/repos/internal/angstrom-socfpga
git tag rel_angstrom-v2014.12-socfpga_16.05.02_rc1 993831b4830af2341ca26cd96e16732fa2d00e19
git push origin rel_angstrom-v2014.12-socfpga_16.05.02_rc1:refs/tags/rel_angstrom-v2014.12-socfpga_16.05.02_rc1
echo


cd /home/atull/repos/internal/meta-altera
git tag rel_angstrom-v2014.12-yocto1.7_16.05.02_rc1 8d6e9b468630aa4d9d4c946080f5023dea43d891
git push origin rel_angstrom-v2014.12-yocto1.7_16.05.02_rc1:refs/tags/rel_angstrom-v2014.12-yocto1.7_16.05.02_rc1
echo

git tag rel_angstrom-v2014.12-yocto1.7_a10_16.05.02_rc1 67523b0f770d46a4e363f47b19d3a6a453c66b3f
git push origin rel_angstrom-v2014.12-yocto1.7_a10_16.05.02_rc1:refs/tags/rel_angstrom-v2014.12-yocto1.7_a10_16.05.02_rc1
echo


cd /home/atull/repos/internal/linux-tags
git tag rel_master_16.05.02_rc1 2d56fa1d01be1353145e0d02e8b065db54a0c27d
git push origin rel_master_16.05.02_rc1:refs/tags/rel_master_16.05.02_rc1
git push origin rel_master_16.05.02_rc1:refs/heads/master
