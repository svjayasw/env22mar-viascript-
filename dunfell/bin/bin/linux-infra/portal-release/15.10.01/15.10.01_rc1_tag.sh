#!/bin/bash -ex
# This script tags the local git tree with rc1 tag and pushes to internal git
#

cd /home/atull/repos/internal/linux-socfpga
git tag rel_socfpga-4.1_15.10.01_rc1 186070d46805086fe9b46d95ac6d0e257203e5a4
git push origin rel_socfpga-4.1_15.10.01_rc1:refs/tags/rel_socfpga-4.1_15.10.01_rc1
echo

git tag rel_socfpga-3.10-ltsi_15.10.01_rc1 a111e8ee9f51a1f590d396c1c5ae4ecc3252d7c3
git push origin rel_socfpga-3.10-ltsi_15.10.01_rc1:refs/tags/rel_socfpga-3.10-ltsi_15.10.01_rc1
echo

git tag rel_socfpga-3.10-ltsi-rt_15.10.01_rc1 8a34ee1d8d4d64ae7bf20f7c5104b3cb3f28fe9a
git push origin rel_socfpga-3.10-ltsi-rt_15.10.01_rc1:refs/tags/rel_socfpga-3.10-ltsi-rt_15.10.01_rc1
echo


cd /home/atull/repos/internal/uboot-socfpga
git tag rel_socfpga_v2013.01.01_15.10.01_rc1 4003f38429d308c48773897a1ccf166486b9dd7f
git push origin rel_socfpga_v2013.01.01_15.10.01_rc1:refs/tags/rel_socfpga_v2013.01.01_15.10.01_rc1
echo

git tag rel_socfpga_v2014.10_arria10_bringup_15.10.01_rc1 32d4ff1a3cef7a4e56e72f76999668a20ca7d456
git push origin rel_socfpga_v2014.10_arria10_bringup_15.10.01_rc1:refs/tags/rel_socfpga_v2014.10_arria10_bringup_15.10.01_rc1
echo


cd /home/atull/repos/internal/angstrom-socfpga
git tag rel_angstrom-v2014.12-socfpga_15.10.01_rc1 28881bdf04f230c09a60d4480e8b7d670507f692
git push origin rel_angstrom-v2014.12-socfpga_15.10.01_rc1:refs/tags/rel_angstrom-v2014.12-socfpga_15.10.01_rc1
echo


cd /home/atull/repos/internal/meta-altera
git tag rel_angstrom-v2014.12-yocto1.7_15.10.01_rc1 889cfa0f2a241010b0d4425ccb9bf1bc0bcdbccc
git push origin rel_angstrom-v2014.12-yocto1.7_15.10.01_rc1:refs/tags/rel_angstrom-v2014.12-yocto1.7_15.10.01_rc1
echo

git tag rel_angstrom-v2014.12-yocto1.7_a10_15.10.01_rc1 67523b0f770d46a4e363f47b19d3a6a453c66b3f
git push origin rel_angstrom-v2014.12-yocto1.7_a10_15.10.01_rc1:refs/tags/rel_angstrom-v2014.12-yocto1.7_a10_15.10.01_rc1
echo


cd /home/atull/repos/internal/linux-tags
git tag rel_master_15.10.01_rc1 43ad97aa51286d0f01471f3b483f4cdf36760bf4
git push origin rel_master_15.10.01_rc1:refs/tags/rel_master_15.10.01_rc1
git push origin rel_master_15.10.01_rc1:refs/heads/master
