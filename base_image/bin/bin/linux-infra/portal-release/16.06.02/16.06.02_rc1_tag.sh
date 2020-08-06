#!/bin/bash -ex
# This script tags the local git tree with rc1 tag and pushes to internal git
#

cd /home/atull/repos/internal/linux-socfpga
git tag rel_socfpga-4.5_16.06.02_rc1 091b0c145676d926977c64dce3f34631a8caa12d
git push origin rel_socfpga-4.5_16.06.02_rc1:refs/tags/rel_socfpga-4.5_16.06.02_rc1
echo

git tag rel_socfpga-4.1-ltsi_16.06.02_rc1 43492a7a9649e30826e4c79a9308ab2850259c26
git push origin rel_socfpga-4.1-ltsi_16.06.02_rc1:refs/tags/rel_socfpga-4.1-ltsi_16.06.02_rc1
echo

git tag rel_socfpga-4.1-ltsi-rt_16.06.02_rc1 8b4890ed684b422689394156f8a555d522aaf5db
git push origin rel_socfpga-4.1-ltsi-rt_16.06.02_rc1:refs/tags/rel_socfpga-4.1-ltsi-rt_16.06.02_rc1
echo


cd /home/atull/repos/internal/uboot-socfpga
git tag rel_socfpga_v2013.01.01_16.06.02_rc1 7dd0473e47ede9fd240969846a42f5646f565ce9
git push origin rel_socfpga_v2013.01.01_16.06.02_rc1:refs/tags/rel_socfpga_v2013.01.01_16.06.02_rc1
echo

git tag rel_socfpga_v2014.10_arria10_bringup_16.06.02_rc1 09174d6dbceecd1d9502aa5e2f9b9314ea146448
git push origin rel_socfpga_v2014.10_arria10_bringup_16.06.02_rc1:refs/tags/rel_socfpga_v2014.10_arria10_bringup_16.06.02_rc1
echo


cd /home/atull/repos/internal/angstrom-socfpga
git tag rel_angstrom-v2014.12-socfpga_16.06.02_rc1 993831b4830af2341ca26cd96e16732fa2d00e19
git push origin rel_angstrom-v2014.12-socfpga_16.06.02_rc1:refs/tags/rel_angstrom-v2014.12-socfpga_16.06.02_rc1
echo


cd /home/atull/repos/internal/meta-altera
git tag rel_angstrom-v2014.12-yocto1.7_16.06.02_rc1 8d6e9b468630aa4d9d4c946080f5023dea43d891
git push origin rel_angstrom-v2014.12-yocto1.7_16.06.02_rc1:refs/tags/rel_angstrom-v2014.12-yocto1.7_16.06.02_rc1
echo

git tag rel_angstrom-v2014.12-yocto1.7_a10_16.06.02_rc1 67523b0f770d46a4e363f47b19d3a6a453c66b3f
git push origin rel_angstrom-v2014.12-yocto1.7_a10_16.06.02_rc1:refs/tags/rel_angstrom-v2014.12-yocto1.7_a10_16.06.02_rc1
echo


cd /home/atull/repos/internal/linux-tags
git tag rel_master_16.06.02_rc1 ffa67a6adc6ea8d641fdf8032311e7ca74ff0290
git push origin rel_master_16.06.02_rc1:refs/tags/rel_master_16.06.02_rc1
git push origin rel_master_16.06.02_rc1:refs/heads/master
