#!/bin/bash -ex
# This script tags the local git tree with rc1 tag and pushes to internal git
#

cd /home/atull/repos/internal/linux-socfpga
git tag rel_socfpga-4.2_15.11.01_rc1 0263eafb77b39d6f6e43c7a7b93c6cb06c6af472
git push origin rel_socfpga-4.2_15.11.01_rc1:refs/tags/rel_socfpga-4.2_15.11.01_rc1
echo

git tag rel_socfpga-3.10-ltsi_15.11.01_rc1 b75c2288dfd4864efb19ed7597b6ff55ea3bd210
git push origin rel_socfpga-3.10-ltsi_15.11.01_rc1:refs/tags/rel_socfpga-3.10-ltsi_15.11.01_rc1
echo

git tag rel_socfpga-3.10-ltsi-rt_15.11.01_rc1 ef8b7fee9f81be67c97e461aa138a1b066f5e0a4
git push origin rel_socfpga-3.10-ltsi-rt_15.11.01_rc1:refs/tags/rel_socfpga-3.10-ltsi-rt_15.11.01_rc1
echo


cd /home/atull/repos/internal/uboot-socfpga
git tag rel_socfpga_v2013.01.01_15.11.01_rc1 4003f38429d308c48773897a1ccf166486b9dd7f
git push origin rel_socfpga_v2013.01.01_15.11.01_rc1:refs/tags/rel_socfpga_v2013.01.01_15.11.01_rc1
echo

git tag rel_socfpga_v2014.10_arria10_bringup_15.11.01_rc1 52122ec266d7582d9274d836fdd36670c647c353
git push origin rel_socfpga_v2014.10_arria10_bringup_15.11.01_rc1:refs/tags/rel_socfpga_v2014.10_arria10_bringup_15.11.01_rc1
echo


cd /home/atull/repos/internal/angstrom-socfpga
git tag rel_angstrom-v2014.12-socfpga_15.11.01_rc1 28881bdf04f230c09a60d4480e8b7d670507f692
git push origin rel_angstrom-v2014.12-socfpga_15.11.01_rc1:refs/tags/rel_angstrom-v2014.12-socfpga_15.11.01_rc1
echo


cd /home/atull/repos/internal/meta-altera
git tag rel_angstrom-v2014.12-yocto1.7_15.11.01_rc1 fc9b42bcd28b593d9d23e01e5bd696108864543c
git push origin rel_angstrom-v2014.12-yocto1.7_15.11.01_rc1:refs/tags/rel_angstrom-v2014.12-yocto1.7_15.11.01_rc1
echo

git tag rel_angstrom-v2014.12-yocto1.7_a10_15.11.01_rc1 67523b0f770d46a4e363f47b19d3a6a453c66b3f
git push origin rel_angstrom-v2014.12-yocto1.7_a10_15.11.01_rc1:refs/tags/rel_angstrom-v2014.12-yocto1.7_a10_15.11.01_rc1
echo


cd /home/atull/repos/internal/linux-tags
git tag rel_master_15.11.01_rc1 34c13b6ee57b84e53066e9b13d796cd123a896a4
git push origin rel_master_15.11.01_rc1:refs/tags/rel_master_15.11.01_rc1
git push origin rel_master_15.11.01_rc1:refs/heads/master
