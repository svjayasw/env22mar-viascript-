#!/bin/bash -ex
# This script tags the local git tree with rc1 tag and pushes to internal git
#

cd /home/atull/repos/internal/linux-socfpga
git tag rel_socfpga-4.4_16.04.02_rc1 4885028447552ea4794d3b70114cf7d617c41373
git push origin rel_socfpga-4.4_16.04.02_rc1:refs/tags/rel_socfpga-4.4_16.04.02_rc1
echo

git tag rel_socfpga-4.1-ltsi_16.04.02_rc1 c816eac2b585ced0418ae9d11565825b9489e0c6
git push origin rel_socfpga-4.1-ltsi_16.04.02_rc1:refs/tags/rel_socfpga-4.1-ltsi_16.04.02_rc1
echo

git tag rel_socfpga-4.1-ltsi-rt_16.04.02_rc1 33676422bf8d512f7c2957bcd901513daa78df2b
git push origin rel_socfpga-4.1-ltsi-rt_16.04.02_rc1:refs/tags/rel_socfpga-4.1-ltsi-rt_16.04.02_rc1
echo


cd /home/atull/repos/internal/uboot-socfpga
git tag rel_socfpga_v2013.01.01_16.04.02_rc1 7dd0473e47ede9fd240969846a42f5646f565ce9
git push origin rel_socfpga_v2013.01.01_16.04.02_rc1:refs/tags/rel_socfpga_v2013.01.01_16.04.02_rc1
echo

git tag rel_socfpga_v2014.10_arria10_bringup_16.04.02_rc1 d693856695347f01ed4fde53534aaf21be7ffb69
git push origin rel_socfpga_v2014.10_arria10_bringup_16.04.02_rc1:refs/tags/rel_socfpga_v2014.10_arria10_bringup_16.04.02_rc1
echo


cd /home/atull/repos/internal/angstrom-socfpga
git tag rel_angstrom-v2014.12-socfpga_16.04.02_rc1 0a2c33dbc636dc02049cfb77f73132d70b36c183
git push origin rel_angstrom-v2014.12-socfpga_16.04.02_rc1:refs/tags/rel_angstrom-v2014.12-socfpga_16.04.02_rc1
echo


cd /home/atull/repos/internal/meta-altera
git tag rel_angstrom-v2014.12-yocto1.7_16.04.02_rc1 8d6e9b468630aa4d9d4c946080f5023dea43d891
git push origin rel_angstrom-v2014.12-yocto1.7_16.04.02_rc1:refs/tags/rel_angstrom-v2014.12-yocto1.7_16.04.02_rc1
echo

git tag rel_angstrom-v2014.12-yocto1.7_a10_16.04.02_rc1 67523b0f770d46a4e363f47b19d3a6a453c66b3f
git push origin rel_angstrom-v2014.12-yocto1.7_a10_16.04.02_rc1:refs/tags/rel_angstrom-v2014.12-yocto1.7_a10_16.04.02_rc1
echo


cd /home/atull/repos/internal/linux-tags
git tag rel_master_16.04.02_rc1 7365a8803886b5db9bbc49c67350267b96b2c58c
git push origin rel_master_16.04.02_rc1:refs/tags/rel_master_16.04.02_rc1
git push origin rel_master_16.04.02_rc1:refs/heads/master
