#!/bin/bash -ex
# This script tags the local git tree with rc1 tag and pushes to internal git
#

cd /home/atull/repos/internal/linux-socfpga
git tag rel_socfpga-4.1_15.09.02_rc1 186070d46805086fe9b46d95ac6d0e257203e5a4
git push origin rel_socfpga-4.1_15.09.02_rc1:refs/tags/rel_socfpga-4.1_15.09.02_rc1
echo

git tag rel_socfpga-3.10-ltsi_15.09.02_rc1 bdab83643ff8f5fd4039202b980b6b6806306236
git push origin rel_socfpga-3.10-ltsi_15.09.02_rc1:refs/tags/rel_socfpga-3.10-ltsi_15.09.02_rc1
echo

git tag rel_socfpga-3.10-ltsi-rt_15.09.02_rc1 8a34ee1d8d4d64ae7bf20f7c5104b3cb3f28fe9a
git push origin rel_socfpga-3.10-ltsi-rt_15.09.02_rc1:refs/tags/rel_socfpga-3.10-ltsi-rt_15.09.02_rc1
echo


cd /home/atull/repos/internal/uboot-socfpga
git tag rel_socfpga_v2013.01.01_15.09.02_rc1 4003f38429d308c48773897a1ccf166486b9dd7f
git push origin rel_socfpga_v2013.01.01_15.09.02_rc1:refs/tags/rel_socfpga_v2013.01.01_15.09.02_rc1
echo

git tag rel_socfpga_v2014.10_arria10_bringup_15.09.02_rc1 5dc2c1c96476df232b4e5c0fd2b4c21d0f5afb0e
git push origin rel_socfpga_v2014.10_arria10_bringup_15.09.02_rc1:refs/tags/rel_socfpga_v2014.10_arria10_bringup_15.09.02_rc1
echo


cd /home/atull/repos/internal/angstrom-socfpga
git tag rel_angstrom-v2014.12-socfpga_15.09.02_rc1 627d4b6f99bf2a97b3368e70190665359aecb24a
git push origin rel_angstrom-v2014.12-socfpga_15.09.02_rc1:refs/tags/rel_angstrom-v2014.12-socfpga_15.09.02_rc1
echo


cd /home/atull/repos/internal/meta-altera
git tag rel_angstrom-v2014.12-yocto1.7_15.09.02_rc1 05a8d6e234349feaa719667dc97553b387e1adf8
git push origin rel_angstrom-v2014.12-yocto1.7_15.09.02_rc1:refs/tags/rel_angstrom-v2014.12-yocto1.7_15.09.02_rc1
echo

git tag rel_angstrom-v2014.12-yocto1.7_a10_15.09.02_rc1 67523b0f770d46a4e363f47b19d3a6a453c66b3f
git push origin rel_angstrom-v2014.12-yocto1.7_a10_15.09.02_rc1:refs/tags/rel_angstrom-v2014.12-yocto1.7_a10_15.09.02_rc1
echo


cd /home/atull/repos/internal/linux-tags
git tag rel_master_15.09.02_rc1 83bee963bf7c9d821e0b5d64183bed741cb32774
git push origin rel_master_15.09.02_rc1:refs/tags/rel_master_15.09.02_rc1
git push origin rel_master_15.09.02_rc1:refs/heads/master
