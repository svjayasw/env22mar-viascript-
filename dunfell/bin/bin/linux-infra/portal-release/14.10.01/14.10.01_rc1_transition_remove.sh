#!/bin/bash -ex
# This script removes the old tags (that have been copied to rc1 tag names
# on the same sha's)
#

cd /home/atull/repos/internal/linux-socfpga
git push origin :refs/tags/rel_socfpga-3.16_14.10.01
echo

git push origin :refs/tags/rel_socfpga-3.10-ltsi_14.10.01
echo

git push origin :refs/tags/rel_socfpga-3.10-ltsi-rt_14.10.01
echo


cd /home/atull/repos/internal/uboot-socfpga
git push origin :refs/tags/rel_socfpga_v2013.01.01_14.10.01
echo


cd /home/atull/repos/internal/poky
git push origin :refs/tags/rel_danny-altera_14.10.01
echo


cd /home/atull/repos/internal/angstrom-socfpga
git push origin :refs/tags/rel_angstrom-v2012.12-socfpga_14.10.01
echo

git push origin :refs/tags/rel_angstrom-v2013.12-socfpga_14.10.01
echo

git push origin :refs/tags/rel_angstrom-v2014.06-socfpga_14.10.01
echo


cd /home/atull/repos/internal/meta-altera
git push origin :refs/tags/rel_angstrom-v2012.12-yocto1.3_14.10.01
echo

git push origin :refs/tags/rel_angstrom-v2013.12-yocto1.5_14.10.01
echo

git push origin :refs/tags/rel_angstrom-v2014.06-yocto1.6_14.10.01
echo


cd /home/atull/repos/internal/linux-test
git push origin :refs/tags/rel_master_14.10.01
echo


cd /home/atull/repos/internal/linux-infra
git push origin :refs/tags/rel_tags_v1_14.10.01
echo

