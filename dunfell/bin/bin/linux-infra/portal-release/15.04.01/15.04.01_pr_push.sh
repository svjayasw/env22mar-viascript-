#!/bin/bash -ex
# This script copies rcN tags to rcN+1 tags in local git,
# pushes them to internal and RBO git
#

cd /home/atull/repos/internal/linux-socfpga
git tag rel_socfpga-3.18_15.04.01_pr rel_socfpga-3.18_15.04.01_rc2
git push origin rel_socfpga-3.18_15.04.01_pr:refs/tags/rel_socfpga-3.18_15.04.01_pr
echo

git push portal rel_socfpga-3.18_15.04.01_pr:refs/heads/socfpga-3.18
git push portal rel_socfpga-3.18_15.04.01_pr:refs/tags/rel_socfpga-3.18_15.04.01_pr
echo

git tag rel_socfpga-3.10-ltsi_15.04.01_pr rel_socfpga-3.10-ltsi_15.04.01_rc2
git push origin rel_socfpga-3.10-ltsi_15.04.01_pr:refs/tags/rel_socfpga-3.10-ltsi_15.04.01_pr
echo

git push portal rel_socfpga-3.10-ltsi_15.04.01_pr:refs/heads/socfpga-3.10-ltsi
git push portal rel_socfpga-3.10-ltsi_15.04.01_pr:refs/tags/rel_socfpga-3.10-ltsi_15.04.01_pr
echo

git tag rel_socfpga-3.10-ltsi-rt_15.04.01_pr rel_socfpga-3.10-ltsi-rt_15.04.01_rc2
git push origin rel_socfpga-3.10-ltsi-rt_15.04.01_pr:refs/tags/rel_socfpga-3.10-ltsi-rt_15.04.01_pr
echo

git push portal rel_socfpga-3.10-ltsi-rt_15.04.01_pr:refs/heads/socfpga-3.10-ltsi-rt
git push portal rel_socfpga-3.10-ltsi-rt_15.04.01_pr:refs/tags/rel_socfpga-3.10-ltsi-rt_15.04.01_pr
echo


cd /home/atull/repos/internal/uboot-socfpga
git tag rel_socfpga_v2013.01.01_15.04.01_pr rel_socfpga_v2013.01.01_15.04.01_rc2
git push origin rel_socfpga_v2013.01.01_15.04.01_pr:refs/tags/rel_socfpga_v2013.01.01_15.04.01_pr
echo

git push portal rel_socfpga_v2013.01.01_15.04.01_pr:refs/heads/socfpga_v2013.01.01
git push portal rel_socfpga_v2013.01.01_15.04.01_pr:refs/tags/rel_socfpga_v2013.01.01_15.04.01_pr
echo

git tag rel_socfpga_v2014.10_arria10_bringup_15.04.01_pr rel_socfpga_v2014.10_arria10_bringup_15.04.01_rc2
git push origin rel_socfpga_v2014.10_arria10_bringup_15.04.01_pr:refs/tags/rel_socfpga_v2014.10_arria10_bringup_15.04.01_pr
echo

git push portal rel_socfpga_v2014.10_arria10_bringup_15.04.01_pr:refs/heads/socfpga_v2014.10_arria10_bringup
git push portal rel_socfpga_v2014.10_arria10_bringup_15.04.01_pr:refs/tags/rel_socfpga_v2014.10_arria10_bringup_15.04.01_pr
echo


cd /home/atull/repos/internal/poky
git tag rel_danny-altera_15.04.01_pr rel_danny-altera_15.04.01_rc2
git push origin rel_danny-altera_15.04.01_pr:refs/tags/rel_danny-altera_15.04.01_pr
echo

git push portal rel_danny-altera_15.04.01_pr:refs/heads/danny-altera
git push portal rel_danny-altera_15.04.01_pr:refs/tags/rel_danny-altera_15.04.01_pr
echo


cd /home/atull/repos/internal/angstrom-socfpga
git tag rel_angstrom-v2012.12-socfpga_15.04.01_pr rel_angstrom-v2012.12-socfpga_15.04.01_rc2
git push origin rel_angstrom-v2012.12-socfpga_15.04.01_pr:refs/tags/rel_angstrom-v2012.12-socfpga_15.04.01_pr
echo

git push portal rel_angstrom-v2012.12-socfpga_15.04.01_pr:refs/heads/angstrom-v2012.12-socfpga
git push portal rel_angstrom-v2012.12-socfpga_15.04.01_pr:refs/tags/rel_angstrom-v2012.12-socfpga_15.04.01_pr
echo

git tag rel_angstrom-v2013.12-socfpga_15.04.01_pr rel_angstrom-v2013.12-socfpga_15.04.01_rc2
git push origin rel_angstrom-v2013.12-socfpga_15.04.01_pr:refs/tags/rel_angstrom-v2013.12-socfpga_15.04.01_pr
echo

git push portal rel_angstrom-v2013.12-socfpga_15.04.01_pr:refs/heads/angstrom-v2013.12-socfpga
git push portal rel_angstrom-v2013.12-socfpga_15.04.01_pr:refs/tags/rel_angstrom-v2013.12-socfpga_15.04.01_pr
echo

git tag rel_angstrom-v2014.06-socfpga_15.04.01_pr rel_angstrom-v2014.06-socfpga_15.04.01_rc2
git push origin rel_angstrom-v2014.06-socfpga_15.04.01_pr:refs/tags/rel_angstrom-v2014.06-socfpga_15.04.01_pr
echo

git push portal rel_angstrom-v2014.06-socfpga_15.04.01_pr:refs/heads/angstrom-v2014.06-socfpga
git push portal rel_angstrom-v2014.06-socfpga_15.04.01_pr:refs/tags/rel_angstrom-v2014.06-socfpga_15.04.01_pr
echo

git tag rel_angstrom-v2014.12-socfpga_15.04.01_pr rel_angstrom-v2014.12-socfpga_15.04.01_rc2
git push origin rel_angstrom-v2014.12-socfpga_15.04.01_pr:refs/tags/rel_angstrom-v2014.12-socfpga_15.04.01_pr
echo

git push portal rel_angstrom-v2014.12-socfpga_15.04.01_pr:refs/heads/angstrom-v2014.12-socfpga
git push portal rel_angstrom-v2014.12-socfpga_15.04.01_pr:refs/tags/rel_angstrom-v2014.12-socfpga_15.04.01_pr
echo


cd /home/atull/repos/internal/meta-altera
git tag rel_angstrom-v2012.12-yocto1.3_15.04.01_pr rel_angstrom-v2012.12-yocto1.3_15.04.01_rc2
git push origin rel_angstrom-v2012.12-yocto1.3_15.04.01_pr:refs/tags/rel_angstrom-v2012.12-yocto1.3_15.04.01_pr
echo

git push portal rel_angstrom-v2012.12-yocto1.3_15.04.01_pr:refs/heads/angstrom-v2012.12-yocto1.3
git push portal rel_angstrom-v2012.12-yocto1.3_15.04.01_pr:refs/tags/rel_angstrom-v2012.12-yocto1.3_15.04.01_pr
echo

git tag rel_angstrom-v2013.12-yocto1.5_15.04.01_pr rel_angstrom-v2013.12-yocto1.5_15.04.01_rc2
git push origin rel_angstrom-v2013.12-yocto1.5_15.04.01_pr:refs/tags/rel_angstrom-v2013.12-yocto1.5_15.04.01_pr
echo

git push portal rel_angstrom-v2013.12-yocto1.5_15.04.01_pr:refs/heads/angstrom-v2013.12-yocto1.5
git push portal rel_angstrom-v2013.12-yocto1.5_15.04.01_pr:refs/tags/rel_angstrom-v2013.12-yocto1.5_15.04.01_pr
echo

git tag rel_angstrom-v2014.06-yocto1.6_15.04.01_pr rel_angstrom-v2014.06-yocto1.6_15.04.01_rc2
git push origin rel_angstrom-v2014.06-yocto1.6_15.04.01_pr:refs/tags/rel_angstrom-v2014.06-yocto1.6_15.04.01_pr
echo

git push portal rel_angstrom-v2014.06-yocto1.6_15.04.01_pr:refs/heads/angstrom-v2014.06-yocto1.6
git push portal rel_angstrom-v2014.06-yocto1.6_15.04.01_pr:refs/tags/rel_angstrom-v2014.06-yocto1.6_15.04.01_pr
echo

git tag rel_angstrom-v2014.12-yocto1.7_15.04.01_pr rel_angstrom-v2014.12-yocto1.7_15.04.01_rc2
git push origin rel_angstrom-v2014.12-yocto1.7_15.04.01_pr:refs/tags/rel_angstrom-v2014.12-yocto1.7_15.04.01_pr
echo

git push portal rel_angstrom-v2014.12-yocto1.7_15.04.01_pr:refs/heads/angstrom-v2014.12-yocto1.7
git push portal rel_angstrom-v2014.12-yocto1.7_15.04.01_pr:refs/tags/rel_angstrom-v2014.12-yocto1.7_15.04.01_pr
echo

git tag rel_angstrom-v2014.12-yocto1.7_a10_15.04.01_pr rel_angstrom-v2014.12-yocto1.7_a10_15.04.01_rc2
git push origin rel_angstrom-v2014.12-yocto1.7_a10_15.04.01_pr:refs/tags/rel_angstrom-v2014.12-yocto1.7_a10_15.04.01_pr
echo

git push portal rel_angstrom-v2014.12-yocto1.7_a10_15.04.01_pr:refs/heads/angstrom-v2014.12-yocto1.7_a10
git push portal rel_angstrom-v2014.12-yocto1.7_a10_15.04.01_pr:refs/tags/rel_angstrom-v2014.12-yocto1.7_a10_15.04.01_pr
echo


cd /home/atull/repos/internal/linux-tags
git tag rel_master_15.04.01_pr 09d3edc9d2c6a494ef49196d80367787ea27a261
git push origin rel_master_15.04.01_pr:refs/tags/rel_master_15.04.01_pr
git push origin rel_master_15.04.01_pr:refs/heads/master
