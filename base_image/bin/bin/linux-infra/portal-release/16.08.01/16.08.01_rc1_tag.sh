#!/bin/bash -ex
# This script tags the local git tree with rc1 tag and pushes to internal git
#

cd /home/atull/repos/internal/linux-socfpga
git tag rel_socfpga-4.6_16.08.01_rc1 c9ff868173b9bcb64a6716fb19529bae305cdaa8
git push origin rel_socfpga-4.6_16.08.01_rc1:refs/tags/rel_socfpga-4.6_16.08.01_rc1
echo

git tag rel_socfpga-4.1.22-ltsi_16.08.01_rc1 81954e11d57c0e641ac9e5605e47db81e3f553fb
git push origin rel_socfpga-4.1.22-ltsi_16.08.01_rc1:refs/tags/rel_socfpga-4.1.22-ltsi_16.08.01_rc1
echo

git tag rel_socfpga-4.1.22-ltsi-rt_16.08.01_rc1 4b26b40093e7c48dbd4bfa8178b1b6498fcba026
git push origin rel_socfpga-4.1.22-ltsi-rt_16.08.01_rc1:refs/tags/rel_socfpga-4.1.22-ltsi-rt_16.08.01_rc1
echo


cd /home/atull/repos/internal/uboot-socfpga
git tag rel_socfpga_v2013.01.01_16.08.01_rc1 7dd0473e47ede9fd240969846a42f5646f565ce9
git push origin rel_socfpga_v2013.01.01_16.08.01_rc1:refs/tags/rel_socfpga_v2013.01.01_16.08.01_rc1
echo

git tag rel_socfpga_v2014.10_arria10_bringup_16.08.01_rc1 8444415a7d7910726b22a49470fd9717bf20f5b7
git push origin rel_socfpga_v2014.10_arria10_bringup_16.08.01_rc1:refs/tags/rel_socfpga_v2014.10_arria10_bringup_16.08.01_rc1
echo


cd /home/atull/repos/internal/angstrom-socfpga
git tag rel_angstrom-v2014.12-socfpga_16.08.01_rc1 9a77a4b560faebc54f2ef124e16e422adb4ac21d
git push origin rel_angstrom-v2014.12-socfpga_16.08.01_rc1:refs/tags/rel_angstrom-v2014.12-socfpga_16.08.01_rc1
echo


cd /home/atull/repos/internal/meta-altera
git tag rel_angstrom-v2014.12-yocto1.7_16.08.01_rc1 3ad0ad36359c5b032d512525c5c6c4007c56f80d
git push origin rel_angstrom-v2014.12-yocto1.7_16.08.01_rc1:refs/tags/rel_angstrom-v2014.12-yocto1.7_16.08.01_rc1
echo

git tag rel_angstrom-v2014.12-yocto1.7_a10_16.08.01_rc1 67523b0f770d46a4e363f47b19d3a6a453c66b3f
git push origin rel_angstrom-v2014.12-yocto1.7_a10_16.08.01_rc1:refs/tags/rel_angstrom-v2014.12-yocto1.7_a10_16.08.01_rc1
echo


cd /home/atull/repos/internal/linux-tags
git tag rel_master_16.08.01_rc1 c516cbe0261c68f7423b2ed4b32ad5ee8fefbb44
git push origin rel_master_16.08.01_rc1:refs/tags/rel_master_16.08.01_rc1
git push origin rel_master_16.08.01_rc1:refs/heads/master
