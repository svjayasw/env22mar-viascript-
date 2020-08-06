#!/bin/bash -ex
# This script tags the local git tree with rc1 tag and pushes to internal git
#

cd /home/atull/repos/internal/linux-socfpga
git tag rel_socfpga-4.0_15.06.02_rc1 5b33a144c2d51023aceac8f8ce290c5bebd17f57
git push origin rel_socfpga-4.0_15.06.02_rc1:refs/tags/rel_socfpga-4.0_15.06.02_rc1
echo

git tag rel_socfpga-3.10-ltsi_15.06.02_rc1 cd06bd579836ce5dcca6af718c1b09f7a3d6b214
git push origin rel_socfpga-3.10-ltsi_15.06.02_rc1:refs/tags/rel_socfpga-3.10-ltsi_15.06.02_rc1
echo

git tag rel_socfpga-3.10-ltsi-rt_15.06.02_rc1 272f5cbe8cadd7723bc3512d67f44e70e2339d9d
git push origin rel_socfpga-3.10-ltsi-rt_15.06.02_rc1:refs/tags/rel_socfpga-3.10-ltsi-rt_15.06.02_rc1
echo


cd /home/atull/repos/internal/uboot-socfpga
git tag rel_socfpga_v2013.01.01_15.06.02_rc1 5a47f31c98e6c70185f3423bc82f3414cb25ca2c
git push origin rel_socfpga_v2013.01.01_15.06.02_rc1:refs/tags/rel_socfpga_v2013.01.01_15.06.02_rc1
echo

git tag rel_socfpga_v2014.10_arria10_bringup_15.06.02_rc1 3f9fc625524d79e2746d50935026ff12a9bde5be
git push origin rel_socfpga_v2014.10_arria10_bringup_15.06.02_rc1:refs/tags/rel_socfpga_v2014.10_arria10_bringup_15.06.02_rc1
echo


cd /home/atull/repos/internal/angstrom-socfpga
git tag rel_angstrom-v2014.12-socfpga_15.06.02_rc1 380baf43477eb1a994eae009f748d26607a39532
git push origin rel_angstrom-v2014.12-socfpga_15.06.02_rc1:refs/tags/rel_angstrom-v2014.12-socfpga_15.06.02_rc1
echo


cd /home/atull/repos/internal/meta-altera
git tag rel_angstrom-v2014.12-yocto1.7_15.06.02_rc1 d69775cb2a01301535579e41aecce9d659ad1431
git push origin rel_angstrom-v2014.12-yocto1.7_15.06.02_rc1:refs/tags/rel_angstrom-v2014.12-yocto1.7_15.06.02_rc1
echo

git tag rel_angstrom-v2014.12-yocto1.7_a10_15.06.02_rc1 1d88fd24533505129b2c352fb1b66616e2aacc6a
git push origin rel_angstrom-v2014.12-yocto1.7_a10_15.06.02_rc1:refs/tags/rel_angstrom-v2014.12-yocto1.7_a10_15.06.02_rc1
echo


cd /home/atull/repos/internal/linux-tags
git tag rel_master_15.06.02_rc1 0c2effe1afe20354b2f9d3d24f62e53830fbde44
git push origin rel_master_15.06.02_rc1:refs/tags/rel_master_15.06.02_rc1
git push origin rel_master_15.06.02_rc1:refs/heads/master
