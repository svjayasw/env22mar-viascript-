#!/bin/bash -ex
# This script tags the local git tree with rc1 tag and pushes to internal git
#

cd /home/atull/repos/internal/linux-socfpga
git tag rel_socfpga-4.3_16.01.01_rc1 5938523338cab45f68bc89e033e50d0a68d1772f
git push origin rel_socfpga-4.3_16.01.01_rc1:refs/tags/rel_socfpga-4.3_16.01.01_rc1
echo

git tag rel_socfpga-3.10-ltsi_16.01.01_rc1 2f92cf4437acf506b48d02e2075288e4f6e249d2
git push origin rel_socfpga-3.10-ltsi_16.01.01_rc1:refs/tags/rel_socfpga-3.10-ltsi_16.01.01_rc1
echo

git tag rel_socfpga-3.10-ltsi-rt_16.01.01_rc1 60a76aa2263ad809131c39181cc2c97c2949ecad
git push origin rel_socfpga-3.10-ltsi-rt_16.01.01_rc1:refs/tags/rel_socfpga-3.10-ltsi-rt_16.01.01_rc1
echo


cd /home/atull/repos/internal/uboot-socfpga
git tag rel_socfpga_v2013.01.01_16.01.01_rc1 d141e218f3195e305c1521a0d67c81b7cb504b71
git push origin rel_socfpga_v2013.01.01_16.01.01_rc1:refs/tags/rel_socfpga_v2013.01.01_16.01.01_rc1
echo

git tag rel_socfpga_v2014.10_arria10_bringup_16.01.01_rc1 4d0bff7a1dc0bfe17a25ab8b233b4e53e4e7420f
git push origin rel_socfpga_v2014.10_arria10_bringup_16.01.01_rc1:refs/tags/rel_socfpga_v2014.10_arria10_bringup_16.01.01_rc1
echo


cd /home/atull/repos/internal/angstrom-socfpga
git tag rel_angstrom-v2014.12-socfpga_16.01.01_rc1 bc6ea8d92853abcd09632eb791a2f824f3031b53
git push origin rel_angstrom-v2014.12-socfpga_16.01.01_rc1:refs/tags/rel_angstrom-v2014.12-socfpga_16.01.01_rc1
echo


cd /home/atull/repos/internal/meta-altera
git tag rel_angstrom-v2014.12-yocto1.7_16.01.01_rc1 8d6e9b468630aa4d9d4c946080f5023dea43d891
git push origin rel_angstrom-v2014.12-yocto1.7_16.01.01_rc1:refs/tags/rel_angstrom-v2014.12-yocto1.7_16.01.01_rc1
echo

git tag rel_angstrom-v2014.12-yocto1.7_a10_16.01.01_rc1 67523b0f770d46a4e363f47b19d3a6a453c66b3f
git push origin rel_angstrom-v2014.12-yocto1.7_a10_16.01.01_rc1:refs/tags/rel_angstrom-v2014.12-yocto1.7_a10_16.01.01_rc1
echo


cd /home/atull/repos/internal/linux-tags
git tag rel_master_16.01.01_rc1 37024636e69b566e19f954cc835dd0cd6c3cf421
git push origin rel_master_16.01.01_rc1:refs/tags/rel_master_16.01.01_rc1
git push origin rel_master_16.01.01_rc1:refs/heads/master
