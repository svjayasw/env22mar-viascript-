#!/bin/bash -ex
# This script tags the local git tree with rc1 tag and pushes to internal git
#

cd /home/atull/repos/internal/linux-socfpga
git tag rel_socfpga-4.6_16.07.02_rc1 c9ff868173b9bcb64a6716fb19529bae305cdaa8
git push origin rel_socfpga-4.6_16.07.02_rc1:refs/tags/rel_socfpga-4.6_16.07.02_rc1
echo

git tag rel_socfpga-4.1.22-ltsi_16.07.02_rc1 81954e11d57c0e641ac9e5605e47db81e3f553fb
git push origin rel_socfpga-4.1.22-ltsi_16.07.02_rc1:refs/tags/rel_socfpga-4.1.22-ltsi_16.07.02_rc1
echo

git tag rel_socfpga-4.1.22-ltsi-rt_16.07.02_rc1 4b26b40093e7c48dbd4bfa8178b1b6498fcba026
git push origin rel_socfpga-4.1.22-ltsi-rt_16.07.02_rc1:refs/tags/rel_socfpga-4.1.22-ltsi-rt_16.07.02_rc1
echo


cd /home/atull/repos/internal/uboot-socfpga
git tag rel_socfpga_v2013.01.01_16.07.02_rc1 7dd0473e47ede9fd240969846a42f5646f565ce9
git push origin rel_socfpga_v2013.01.01_16.07.02_rc1:refs/tags/rel_socfpga_v2013.01.01_16.07.02_rc1
echo

git tag rel_socfpga_v2014.10_arria10_bringup_16.07.02_rc1 8444415a7d7910726b22a49470fd9717bf20f5b7
git push origin rel_socfpga_v2014.10_arria10_bringup_16.07.02_rc1:refs/tags/rel_socfpga_v2014.10_arria10_bringup_16.07.02_rc1
echo


cd /home/atull/repos/internal/angstrom-socfpga
git tag rel_angstrom-v2014.12-socfpga_16.07.02_rc1 993831b4830af2341ca26cd96e16732fa2d00e19
git push origin rel_angstrom-v2014.12-socfpga_16.07.02_rc1:refs/tags/rel_angstrom-v2014.12-socfpga_16.07.02_rc1
echo


cd /home/atull/repos/internal/meta-altera
git tag rel_angstrom-v2014.12-yocto1.7_16.07.02_rc1 3ad0ad36359c5b032d512525c5c6c4007c56f80d
git push origin rel_angstrom-v2014.12-yocto1.7_16.07.02_rc1:refs/tags/rel_angstrom-v2014.12-yocto1.7_16.07.02_rc1
echo

git tag rel_angstrom-v2014.12-yocto1.7_a10_16.07.02_rc1 67523b0f770d46a4e363f47b19d3a6a453c66b3f
git push origin rel_angstrom-v2014.12-yocto1.7_a10_16.07.02_rc1:refs/tags/rel_angstrom-v2014.12-yocto1.7_a10_16.07.02_rc1
echo


cd /home/atull/repos/internal/linux-tags
git tag rel_master_16.07.02_rc1 0ab7a682511167c0eccc1fc24fff88b99ff402ea
git push origin rel_master_16.07.02_rc1:refs/tags/rel_master_16.07.02_rc1
git push origin rel_master_16.07.02_rc1:refs/heads/master
