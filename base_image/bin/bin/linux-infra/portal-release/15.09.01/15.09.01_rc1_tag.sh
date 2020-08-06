#!/bin/bash -ex
# This script tags the local git tree with rc1 tag and pushes to internal git
#

cd /home/atull/repos/internal/linux-socfpga
git tag rel_socfpga-4.1_15.09.01_rc1 186070d46805086fe9b46d95ac6d0e257203e5a4
git push origin rel_socfpga-4.1_15.09.01_rc1:refs/tags/rel_socfpga-4.1_15.09.01_rc1
echo

git tag rel_socfpga-3.10-ltsi_15.09.01_rc1 8418e933ae4b227af04718bc9a6d9fb42dc8afca
git push origin rel_socfpga-3.10-ltsi_15.09.01_rc1:refs/tags/rel_socfpga-3.10-ltsi_15.09.01_rc1
echo

git tag rel_socfpga-3.10-ltsi-rt_15.09.01_rc1 8a34ee1d8d4d64ae7bf20f7c5104b3cb3f28fe9a
git push origin rel_socfpga-3.10-ltsi-rt_15.09.01_rc1:refs/tags/rel_socfpga-3.10-ltsi-rt_15.09.01_rc1
echo


cd /home/atull/repos/internal/uboot-socfpga
git tag rel_socfpga_v2013.01.01_15.09.01_rc1 353283b6e75eabdcc48dadf08507b4b86c229d78
git push origin rel_socfpga_v2013.01.01_15.09.01_rc1:refs/tags/rel_socfpga_v2013.01.01_15.09.01_rc1
echo

git tag rel_socfpga_v2014.10_arria10_bringup_15.09.01_rc1 383953202356edc9c069d3eed0052865521befb2
git push origin rel_socfpga_v2014.10_arria10_bringup_15.09.01_rc1:refs/tags/rel_socfpga_v2014.10_arria10_bringup_15.09.01_rc1
echo


cd /home/atull/repos/internal/angstrom-socfpga
git tag rel_angstrom-v2014.12-socfpga_15.09.01_rc1 627d4b6f99bf2a97b3368e70190665359aecb24a
git push origin rel_angstrom-v2014.12-socfpga_15.09.01_rc1:refs/tags/rel_angstrom-v2014.12-socfpga_15.09.01_rc1
echo


cd /home/atull/repos/internal/meta-altera
git tag rel_angstrom-v2014.12-yocto1.7_15.09.01_rc1 0465ae7ec155e364a1ec44d8f888e62a21b583dd
git push origin rel_angstrom-v2014.12-yocto1.7_15.09.01_rc1:refs/tags/rel_angstrom-v2014.12-yocto1.7_15.09.01_rc1
echo

git tag rel_angstrom-v2014.12-yocto1.7_a10_15.09.01_rc1 90dd886cb060260e775e6796606622c335342905
git push origin rel_angstrom-v2014.12-yocto1.7_a10_15.09.01_rc1:refs/tags/rel_angstrom-v2014.12-yocto1.7_a10_15.09.01_rc1
echo


cd /home/atull/repos/internal/linux-tags
git tag rel_master_15.09.01_rc1 a7a38687f635384118d45cc7b81299bd2396a3d7
git push origin rel_master_15.09.01_rc1:refs/tags/rel_master_15.09.01_rc1
git push origin rel_master_15.09.01_rc1:refs/heads/master
