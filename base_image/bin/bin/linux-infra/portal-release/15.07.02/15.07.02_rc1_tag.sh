#!/bin/bash -ex
# This script tags the local git tree with rc1 tag and pushes to internal git
#

cd /home/atull/repos/internal/linux-socfpga
git tag rel_socfpga-4.0_15.07.02_rc1 5d36469775e2b77a33e778d1b606edfc5ed13bd4
git push origin rel_socfpga-4.0_15.07.02_rc1:refs/tags/rel_socfpga-4.0_15.07.02_rc1
echo

git tag rel_socfpga-3.10-ltsi_15.07.02_rc1 51a839398fdcdda7b283b7ac27425011c436525d
git push origin rel_socfpga-3.10-ltsi_15.07.02_rc1:refs/tags/rel_socfpga-3.10-ltsi_15.07.02_rc1
echo

git tag rel_socfpga-3.10-ltsi-rt_15.07.02_rc1 ed5a99ca83527c807b288361c50cb265c181ef0f
git push origin rel_socfpga-3.10-ltsi-rt_15.07.02_rc1:refs/tags/rel_socfpga-3.10-ltsi-rt_15.07.02_rc1
echo


cd /home/atull/repos/internal/uboot-socfpga
git tag rel_socfpga_v2013.01.01_15.07.02_rc1 5a47f31c98e6c70185f3423bc82f3414cb25ca2c
git push origin rel_socfpga_v2013.01.01_15.07.02_rc1:refs/tags/rel_socfpga_v2013.01.01_15.07.02_rc1
echo

git tag rel_socfpga_v2014.10_arria10_bringup_15.07.02_rc1 65fa9d0ca579016f28fa5ee5c2915642ca917615
git push origin rel_socfpga_v2014.10_arria10_bringup_15.07.02_rc1:refs/tags/rel_socfpga_v2014.10_arria10_bringup_15.07.02_rc1
echo


cd /home/atull/repos/internal/angstrom-socfpga
git tag rel_angstrom-v2014.12-socfpga_15.07.02_rc1 380baf43477eb1a994eae009f748d26607a39532
git push origin rel_angstrom-v2014.12-socfpga_15.07.02_rc1:refs/tags/rel_angstrom-v2014.12-socfpga_15.07.02_rc1
echo


cd /home/atull/repos/internal/meta-altera
git tag rel_angstrom-v2014.12-yocto1.7_15.07.02_rc1 d69775cb2a01301535579e41aecce9d659ad1431
git push origin rel_angstrom-v2014.12-yocto1.7_15.07.02_rc1:refs/tags/rel_angstrom-v2014.12-yocto1.7_15.07.02_rc1
echo

git tag rel_angstrom-v2014.12-yocto1.7_a10_15.07.02_rc1 1d88fd24533505129b2c352fb1b66616e2aacc6a
git push origin rel_angstrom-v2014.12-yocto1.7_a10_15.07.02_rc1:refs/tags/rel_angstrom-v2014.12-yocto1.7_a10_15.07.02_rc1
echo


cd /home/atull/repos/internal/linux-tags
git tag rel_master_15.07.02_rc1 76083f2a40b902a3473ce1903996abdb1e10e3f7
git push origin rel_master_15.07.02_rc1:refs/tags/rel_master_15.07.02_rc1
git push origin rel_master_15.07.02_rc1:refs/heads/master
