#!/bin/bash -ex
# This script copies rcN tags to rcN+1 tags in local git,
# pushes them to internal and RBO git
#

cd /home/atull/repos/internal/linux-socfpga
git push origin :refs/tags/rel_socfpga-3.18_15.04.01_pr
echo

git push origin :refs/tags/rel_socfpga-3.18_15.04.01_pr
echo

git push origin :refs/tags/rel_socfpga-3.10-ltsi_15.04.01_pr
echo

git push origin :refs/tags/rel_socfpga-3.10-ltsi_15.04.01_pr
echo

git push origin :refs/tags/rel_socfpga-3.10-ltsi-rt_15.04.01_pr
echo

git push origin :refs/tags/rel_socfpga-3.10-ltsi-rt_15.04.01_pr
echo


cd /home/atull/repos/internal/uboot-socfpga
git push origin :refs/tags/rel_socfpga_v2013.01.01_15.04.01_pr
echo

git push origin :refs/tags/rel_socfpga_v2013.01.01_15.04.01_pr
echo


cd /home/atull/repos/internal/poky
git push origin :refs/tags/rel_danny-altera_15.04.01_pr
echo

git push origin :refs/tags/rel_danny-altera_15.04.01_pr
echo


cd /home/atull/repos/internal/angstrom-socfpga
git push origin :refs/tags/rel_angstrom-v2012.12-socfpga_15.04.01_pr
echo

git push origin :refs/tags/rel_angstrom-v2012.12-socfpga_15.04.01_pr
echo

git push origin :refs/tags/rel_angstrom-v2013.12-socfpga_15.04.01_pr
echo

git push origin :refs/tags/rel_angstrom-v2013.12-socfpga_15.04.01_pr
echo

git push origin :refs/tags/rel_angstrom-v2014.06-socfpga_15.04.01_pr
echo

git push origin :refs/tags/rel_angstrom-v2014.06-socfpga_15.04.01_pr
echo

git push origin :refs/tags/rel_angstrom-v2014.12-socfpga_15.04.01_pr
echo

git push origin :refs/tags/rel_angstrom-v2014.12-socfpga_15.04.01_pr
echo


cd /home/atull/repos/internal/meta-altera
git push origin :refs/tags/rel_angstrom-v2012.12-yocto1.3_15.04.01_pr
echo

git push origin :refs/tags/rel_angstrom-v2012.12-yocto1.3_15.04.01_pr
echo

git push origin :refs/tags/rel_angstrom-v2013.12-yocto1.5_15.04.01_pr
echo

git push origin :refs/tags/rel_angstrom-v2013.12-yocto1.5_15.04.01_pr
echo

git push origin :refs/tags/rel_angstrom-v2014.06-yocto1.6_15.04.01_pr
echo

git push origin :refs/tags/rel_angstrom-v2014.06-yocto1.6_15.04.01_pr
echo

git push origin :refs/tags/rel_angstrom-v2014.12-yocto1.7_15.04.01_pr
echo

git push origin :refs/tags/rel_angstrom-v2014.12-yocto1.7_15.04.01_pr
echo

git push origin :refs/tags/rel_angstrom-v2014.12-yocto1.7_a10_15.04.01_pr
echo

git push origin :refs/tags/rel_angstrom-v2014.12-yocto1.7_a10_15.04.01_pr
echo


cd /home/atull/repos/internal/linux-tags
git push origin :refs/tags/rel_master_15.04.01_pr
