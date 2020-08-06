#!/bin/bash -ex
# This script tags the local git tree with rc1 tag and pushes to internal git
#

cd /home/atull/repos/internal/linux-socfpga
git tag rel_socfpga-4.2_15.12.01_rc1 be211eb308a6383da2042863ac070bc6e7d0add2
git push origin rel_socfpga-4.2_15.12.01_rc1:refs/tags/rel_socfpga-4.2_15.12.01_rc1
echo

git tag rel_socfpga-3.10-ltsi_15.12.01_rc1 bcf9c6441ec6e785ec1c829b4650a582b5e7559e
git push origin rel_socfpga-3.10-ltsi_15.12.01_rc1:refs/tags/rel_socfpga-3.10-ltsi_15.12.01_rc1
echo

git tag rel_socfpga-3.10-ltsi-rt_15.12.01_rc1 ef8b7fee9f81be67c97e461aa138a1b066f5e0a4
git push origin rel_socfpga-3.10-ltsi-rt_15.12.01_rc1:refs/tags/rel_socfpga-3.10-ltsi-rt_15.12.01_rc1
echo


cd /home/atull/repos/internal/uboot-socfpga
git tag rel_socfpga_v2013.01.01_15.12.01_rc1 d3c9a256d6445129d01d1ea779d2587523190427
git push origin rel_socfpga_v2013.01.01_15.12.01_rc1:refs/tags/rel_socfpga_v2013.01.01_15.12.01_rc1
echo

git tag rel_socfpga_v2014.10_arria10_bringup_15.12.01_rc1 2c7fd1aac5f06ceea822c4d6a8af9ea2b11fdfd4
git push origin rel_socfpga_v2014.10_arria10_bringup_15.12.01_rc1:refs/tags/rel_socfpga_v2014.10_arria10_bringup_15.12.01_rc1
echo


cd /home/atull/repos/internal/angstrom-socfpga
git tag rel_angstrom-v2014.12-socfpga_15.12.01_rc1 bc6ea8d92853abcd09632eb791a2f824f3031b53
git push origin rel_angstrom-v2014.12-socfpga_15.12.01_rc1:refs/tags/rel_angstrom-v2014.12-socfpga_15.12.01_rc1
echo


cd /home/atull/repos/internal/meta-altera
git tag rel_angstrom-v2014.12-yocto1.7_15.12.01_rc1 2477f90c6c0aaedd9fd9d463318f30aa4a3a4df5
git push origin rel_angstrom-v2014.12-yocto1.7_15.12.01_rc1:refs/tags/rel_angstrom-v2014.12-yocto1.7_15.12.01_rc1
echo

git tag rel_angstrom-v2014.12-yocto1.7_a10_15.12.01_rc1 67523b0f770d46a4e363f47b19d3a6a453c66b3f
git push origin rel_angstrom-v2014.12-yocto1.7_a10_15.12.01_rc1:refs/tags/rel_angstrom-v2014.12-yocto1.7_a10_15.12.01_rc1
echo


cd /home/atull/repos/internal/linux-tags
git tag rel_master_15.12.01_rc1 ec58ed635cfc3b0673934ce7536553ebcca16a7e
git push origin rel_master_15.12.01_rc1:refs/tags/rel_master_15.12.01_rc1
git push origin rel_master_15.12.01_rc1:refs/heads/master
