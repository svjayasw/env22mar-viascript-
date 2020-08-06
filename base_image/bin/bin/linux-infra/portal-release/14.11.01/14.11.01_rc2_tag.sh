#!/bin/bash -ex
# This script tags the local git tree with rc1 tag and pushes to internal git
#

cd /home/atull/repos/internal/linux-socfpga
git push origin rel_socfpga-3.17_14.11.01_rc2:refs/tags/rel_socfpga-3.17_14.11.01_rc2
git log --pretty=oneline -1 rel_socfpga-3.17_14.11.01_rc2
echo

git push origin rel_socfpga-3.16_14.11.01_rc2:refs/tags/rel_socfpga-3.16_14.11.01_rc2
git log --pretty=oneline -1 rel_socfpga-3.16_14.11.01_rc2
echo

git push origin rel_socfpga-3.10-ltsi_14.11.01_rc2:refs/tags/rel_socfpga-3.10-ltsi_14.11.01_rc2
git log --pretty=oneline -1 rel_socfpga-3.10-ltsi_14.11.01_rc2
echo

git push origin rel_socfpga-3.10-ltsi-rt_14.11.01_rc2:refs/tags/rel_socfpga-3.10-ltsi-rt_14.11.01_rc2
git log --pretty=oneline -1 rel_socfpga-3.10-ltsi-rt_14.11.01_rc2
echo


cd /home/atull/repos/internal/uboot-socfpga
git push origin rel_socfpga_v2013.01.01_14.11.01_rc2:refs/tags/rel_socfpga_v2013.01.01_14.11.01_rc2
git log --pretty=oneline -1 rel_socfpga_v2013.01.01_14.11.01_rc2
echo


cd /home/atull/repos/internal/poky
git push origin rel_danny-altera_14.11.01_rc2:refs/tags/rel_danny-altera_14.11.01_rc2
git log --pretty=oneline -1 rel_danny-altera_14.11.01_rc2
echo


cd /home/atull/repos/internal/angstrom-socfpga
git push origin rel_angstrom-v2012.12-socfpga_14.11.01_rc2:refs/tags/rel_angstrom-v2012.12-socfpga_14.11.01_rc2
git log --pretty=oneline -1 rel_angstrom-v2012.12-socfpga_14.11.01_rc2
echo

git push origin rel_angstrom-v2013.12-socfpga_14.11.01_rc2:refs/tags/rel_angstrom-v2013.12-socfpga_14.11.01_rc2
git log --pretty=oneline -1 rel_angstrom-v2013.12-socfpga_14.11.01_rc2
echo

git push origin rel_angstrom-v2014.06-socfpga_14.11.01_rc2:refs/tags/rel_angstrom-v2014.06-socfpga_14.11.01_rc2
git log --pretty=oneline -1 rel_angstrom-v2014.06-socfpga_14.11.01_rc2
echo


cd /home/atull/repos/internal/meta-altera
git push origin rel_angstrom-v2012.12-yocto1.3_14.11.01_rc2:refs/tags/rel_angstrom-v2012.12-yocto1.3_14.11.01_rc2
git log --pretty=oneline -1 rel_angstrom-v2012.12-yocto1.3_14.11.01_rc2
echo

git push origin rel_angstrom-v2013.12-yocto1.5_14.11.01_rc2:refs/tags/rel_angstrom-v2013.12-yocto1.5_14.11.01_rc2
git log --pretty=oneline -1 rel_angstrom-v2013.12-yocto1.5_14.11.01_rc2
echo

git push origin rel_angstrom-v2014.06-yocto1.6_14.11.01_rc2:refs/tags/rel_angstrom-v2014.06-yocto1.6_14.11.01_rc2
git log --pretty=oneline -1 rel_angstrom-v2014.06-yocto1.6_14.11.01_rc2
echo


cd /home/atull/repos/internal/linux-test
git push origin rel_master_14.11.01_rc2:refs/tags/rel_master_14.11.01_rc2
git log --pretty=oneline -1 rel_master_14.11.01_rc2
echo


cd /home/atull/repos/internal/linux-infra
git push origin rel_tags_v1_14.11.01_rc2:refs/tags/rel_tags_v1_14.11.01_rc2
git log --pretty=oneline -1 rel_tags_v1_14.11.01_rc2
echo


cd /home/atull/repos/internal/linux-tags
git tag rel_master_14.11.01_rc2 805deba0685ec794c57da16941526d3a9a1047cf
git push origin rel_master_14.11.01_rc2:refs/tags/rel_master_14.11.01_rc2
git push origin rel_master_14.11.01_rc2:refs/heads/master
