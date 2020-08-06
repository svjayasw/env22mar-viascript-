#!/bin/bash -ex
# This script tags the local git tree with rc1 tag and pushes to internal git
#

cd /home/atull/repos/internal/linux-socfpga
git tag rel_socfpga-4.6_16.07.01_rc1 f4f6e2cd12ff5026f563ffb857ed507c328229e5
git push origin rel_socfpga-4.6_16.07.01_rc1:refs/tags/rel_socfpga-4.6_16.07.01_rc1
echo

git tag rel_socfpga-4.1.22-ltsi_16.07.01_rc1 cd1c82d32105d12282b10e760f2c4dbff26ba8bd
git push origin rel_socfpga-4.1.22-ltsi_16.07.01_rc1:refs/tags/rel_socfpga-4.1.22-ltsi_16.07.01_rc1
echo

git tag rel_socfpga-4.1.22-ltsi-rt_16.07.01_rc1 4b26b40093e7c48dbd4bfa8178b1b6498fcba026
git push origin rel_socfpga-4.1.22-ltsi-rt_16.07.01_rc1:refs/tags/rel_socfpga-4.1.22-ltsi-rt_16.07.01_rc1
echo


cd /home/atull/repos/internal/uboot-socfpga
git tag rel_socfpga_v2013.01.01_16.07.01_rc1 7dd0473e47ede9fd240969846a42f5646f565ce9
git push origin rel_socfpga_v2013.01.01_16.07.01_rc1:refs/tags/rel_socfpga_v2013.01.01_16.07.01_rc1
echo

git tag rel_socfpga_v2014.10_arria10_bringup_16.07.01_rc1 01e2c2231ba59b7f941e200d500cd5a37fd0a257
git push origin rel_socfpga_v2014.10_arria10_bringup_16.07.01_rc1:refs/tags/rel_socfpga_v2014.10_arria10_bringup_16.07.01_rc1
echo


cd /home/atull/repos/internal/angstrom-socfpga
git tag rel_angstrom-v2014.12-socfpga_16.07.01_rc1 993831b4830af2341ca26cd96e16732fa2d00e19
git push origin rel_angstrom-v2014.12-socfpga_16.07.01_rc1:refs/tags/rel_angstrom-v2014.12-socfpga_16.07.01_rc1
echo


cd /home/atull/repos/internal/meta-altera
git tag rel_angstrom-v2014.12-yocto1.7_16.07.01_rc1 8ec51e440b3f3183da5acd6d0f75a2418a750dac
git push origin rel_angstrom-v2014.12-yocto1.7_16.07.01_rc1:refs/tags/rel_angstrom-v2014.12-yocto1.7_16.07.01_rc1
echo

git tag rel_angstrom-v2014.12-yocto1.7_a10_16.07.01_rc1 67523b0f770d46a4e363f47b19d3a6a453c66b3f
git push origin rel_angstrom-v2014.12-yocto1.7_a10_16.07.01_rc1:refs/tags/rel_angstrom-v2014.12-yocto1.7_a10_16.07.01_rc1
echo


cd /home/atull/repos/internal/linux-tags
git tag rel_master_16.07.01_rc1 2e3c3130d0403726b27a473da147e02d634ec5f1
git push origin rel_master_16.07.01_rc1:refs/tags/rel_master_16.07.01_rc1
git push origin rel_master_16.07.01_rc1:refs/heads/master
