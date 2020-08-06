#!/bin/bash -ex
# This script tags the local git tree with rc1 tag and pushes to internal git
#

cd /home/atull/repos/internal/linux-socfpga
git tag rel_socfpga-4.4_16.03.02_rc1 fec26ca032b1a67e89aeabc443504e276d0ac12f
git push origin rel_socfpga-4.4_16.03.02_rc1:refs/tags/rel_socfpga-4.4_16.03.02_rc1
echo

git tag rel_socfpga-3.10-ltsi_16.03.02_rc1 28bac3edbcdc74f98b865986be5d340381896192
git push origin rel_socfpga-3.10-ltsi_16.03.02_rc1:refs/tags/rel_socfpga-3.10-ltsi_16.03.02_rc1
echo

git tag rel_socfpga-3.10-ltsi-rt_16.03.02_rc1 5d6c0ba8572262c29ea3d97fe6d1d5b58650b6e5
git push origin rel_socfpga-3.10-ltsi-rt_16.03.02_rc1:refs/tags/rel_socfpga-3.10-ltsi-rt_16.03.02_rc1
echo

git tag rel_socfpga-4.1-ltsi_16.03.02_rc1 1224831d560bf5c1a215220548163d8663a30ecb
git push origin rel_socfpga-4.1-ltsi_16.03.02_rc1:refs/tags/rel_socfpga-4.1-ltsi_16.03.02_rc1
echo


cd /home/atull/repos/internal/uboot-socfpga
git tag rel_socfpga_v2013.01.01_16.03.02_rc1 d141e218f3195e305c1521a0d67c81b7cb504b71
git push origin rel_socfpga_v2013.01.01_16.03.02_rc1:refs/tags/rel_socfpga_v2013.01.01_16.03.02_rc1
echo

git tag rel_socfpga_v2014.10_arria10_bringup_16.03.02_rc1 e230d2d5beca1255754d3096929f50df2dc423a4
git push origin rel_socfpga_v2014.10_arria10_bringup_16.03.02_rc1:refs/tags/rel_socfpga_v2014.10_arria10_bringup_16.03.02_rc1
echo


cd /home/atull/repos/internal/angstrom-socfpga
git tag rel_angstrom-v2014.12-socfpga_16.03.02_rc1 0a2c33dbc636dc02049cfb77f73132d70b36c183
git push origin rel_angstrom-v2014.12-socfpga_16.03.02_rc1:refs/tags/rel_angstrom-v2014.12-socfpga_16.03.02_rc1
echo


cd /home/atull/repos/internal/meta-altera
git tag rel_angstrom-v2014.12-yocto1.7_16.03.02_rc1 8d6e9b468630aa4d9d4c946080f5023dea43d891
git push origin rel_angstrom-v2014.12-yocto1.7_16.03.02_rc1:refs/tags/rel_angstrom-v2014.12-yocto1.7_16.03.02_rc1
echo

git tag rel_angstrom-v2014.12-yocto1.7_a10_16.03.02_rc1 67523b0f770d46a4e363f47b19d3a6a453c66b3f
git push origin rel_angstrom-v2014.12-yocto1.7_a10_16.03.02_rc1:refs/tags/rel_angstrom-v2014.12-yocto1.7_a10_16.03.02_rc1
echo


cd /home/atull/repos/internal/linux-tags
git tag rel_master_16.03.02_rc1 3172ce8c18ae1ddbaa942030963bed4394ee7834
git push origin rel_master_16.03.02_rc1:refs/tags/rel_master_16.03.02_rc1
git push origin rel_master_16.03.02_rc1:refs/heads/master
