#!/bin/bash -ex
# This script tags the local git tree with rc1 tag and pushes to internal git
#

cd /home/atull/repos/internal/linux-socfpga
git tag rel_socfpga-4.2_15.10.02_rc1 913bfbe2e37c7824f555047c207715e09bd5ef4b
git push origin rel_socfpga-4.2_15.10.02_rc1:refs/tags/rel_socfpga-4.2_15.10.02_rc1
echo

git tag rel_socfpga-3.10-ltsi_15.10.02_rc1 6b67245b33cc350ac8f1b27f4d44d27f8955b129
git push origin rel_socfpga-3.10-ltsi_15.10.02_rc1:refs/tags/rel_socfpga-3.10-ltsi_15.10.02_rc1
echo

git tag rel_socfpga-3.10-ltsi-rt_15.10.02_rc1 60a76aa2263ad809131c39181cc2c97c2949ecad
git push origin rel_socfpga-3.10-ltsi-rt_15.10.02_rc1:refs/tags/rel_socfpga-3.10-ltsi-rt_15.10.02_rc1
echo


cd /home/atull/repos/internal/uboot-socfpga
git tag rel_socfpga_v2013.01.01_15.10.02_rc1 4003f38429d308c48773897a1ccf166486b9dd7f
git push origin rel_socfpga_v2013.01.01_15.10.02_rc1:refs/tags/rel_socfpga_v2013.01.01_15.10.02_rc1
echo

git tag rel_socfpga_v2014.10_arria10_bringup_15.10.02_rc1 32d4ff1a3cef7a4e56e72f76999668a20ca7d456
git push origin rel_socfpga_v2014.10_arria10_bringup_15.10.02_rc1:refs/tags/rel_socfpga_v2014.10_arria10_bringup_15.10.02_rc1
echo


cd /home/atull/repos/internal/angstrom-socfpga
git tag rel_angstrom-v2014.12-socfpga_15.10.02_rc1 28881bdf04f230c09a60d4480e8b7d670507f692
git push origin rel_angstrom-v2014.12-socfpga_15.10.02_rc1:refs/tags/rel_angstrom-v2014.12-socfpga_15.10.02_rc1
echo


cd /home/atull/repos/internal/meta-altera
git tag rel_angstrom-v2014.12-yocto1.7_15.10.02_rc1 95a0cf69a25b4a4e448150983896d564e6446b11
git push origin rel_angstrom-v2014.12-yocto1.7_15.10.02_rc1:refs/tags/rel_angstrom-v2014.12-yocto1.7_15.10.02_rc1
echo

git tag rel_angstrom-v2014.12-yocto1.7_a10_15.10.02_rc1 67523b0f770d46a4e363f47b19d3a6a453c66b3f
git push origin rel_angstrom-v2014.12-yocto1.7_a10_15.10.02_rc1:refs/tags/rel_angstrom-v2014.12-yocto1.7_a10_15.10.02_rc1
echo


cd /home/atull/repos/internal/linux-tags
git tag rel_master_15.10.02_rc1 dd2bd523cda3d908554d31f2ccb4df2be6aeeceb
git push origin rel_master_15.10.02_rc1:refs/tags/rel_master_15.10.02_rc1
git push origin rel_master_15.10.02_rc1:refs/heads/master
