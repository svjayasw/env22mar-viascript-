#!/bin/bash -ex
# This script copies rcN tags to rcN+1 tags in local git,
# pushes them to internal and external git
#

cd /home/atull/repos/internal/linux-socfpga
git tag rel_socfpga-4.4_16.03.02_pr rel_socfpga-4.4_16.03.02_rc1
git push origin rel_socfpga-4.4_16.03.02_pr:refs/tags/rel_socfpga-4.4_16.03.02_pr
echo

git push portal rel_socfpga-4.4_16.03.02_pr:refs/heads/socfpga-4.4
git push portal rel_socfpga-4.4_16.03.02_pr:refs/tags/rel_socfpga-4.4_16.03.02_pr
echo

git tag rel_socfpga-3.10-ltsi_16.03.02_pr rel_socfpga-3.10-ltsi_16.03.02_rc1
git push origin rel_socfpga-3.10-ltsi_16.03.02_pr:refs/tags/rel_socfpga-3.10-ltsi_16.03.02_pr
echo

git push portal rel_socfpga-3.10-ltsi_16.03.02_pr:refs/heads/socfpga-3.10-ltsi
git push portal rel_socfpga-3.10-ltsi_16.03.02_pr:refs/tags/rel_socfpga-3.10-ltsi_16.03.02_pr
echo

git tag rel_socfpga-3.10-ltsi-rt_16.03.02_pr rel_socfpga-3.10-ltsi-rt_16.03.02_rc1
git push origin rel_socfpga-3.10-ltsi-rt_16.03.02_pr:refs/tags/rel_socfpga-3.10-ltsi-rt_16.03.02_pr
echo

git push portal rel_socfpga-3.10-ltsi-rt_16.03.02_pr:refs/heads/socfpga-3.10-ltsi-rt
git push portal rel_socfpga-3.10-ltsi-rt_16.03.02_pr:refs/tags/rel_socfpga-3.10-ltsi-rt_16.03.02_pr
echo

git tag rel_socfpga-4.1-ltsi_16.03.02_pr rel_socfpga-4.1-ltsi_16.03.02_rc1
git push origin rel_socfpga-4.1-ltsi_16.03.02_pr:refs/tags/rel_socfpga-4.1-ltsi_16.03.02_pr
echo

git push portal rel_socfpga-4.1-ltsi_16.03.02_pr:refs/heads/socfpga-4.1-ltsi
git push portal rel_socfpga-4.1-ltsi_16.03.02_pr:refs/tags/rel_socfpga-4.1-ltsi_16.03.02_pr
echo


cd /home/atull/repos/internal/uboot-socfpga
git tag rel_socfpga_v2013.01.01_16.03.02_pr rel_socfpga_v2013.01.01_16.03.02_rc1
git push origin rel_socfpga_v2013.01.01_16.03.02_pr:refs/tags/rel_socfpga_v2013.01.01_16.03.02_pr
echo

git push portal rel_socfpga_v2013.01.01_16.03.02_pr:refs/heads/socfpga_v2013.01.01
git push portal rel_socfpga_v2013.01.01_16.03.02_pr:refs/tags/rel_socfpga_v2013.01.01_16.03.02_pr
echo

git tag rel_socfpga_v2014.10_arria10_bringup_16.03.02_pr rel_socfpga_v2014.10_arria10_bringup_16.03.02_rc1
git push origin rel_socfpga_v2014.10_arria10_bringup_16.03.02_pr:refs/tags/rel_socfpga_v2014.10_arria10_bringup_16.03.02_pr
echo

git push portal rel_socfpga_v2014.10_arria10_bringup_16.03.02_pr:refs/heads/socfpga_v2014.10_arria10_bringup
git push portal rel_socfpga_v2014.10_arria10_bringup_16.03.02_pr:refs/tags/rel_socfpga_v2014.10_arria10_bringup_16.03.02_pr
echo


cd /home/atull/repos/internal/angstrom-socfpga
git tag rel_angstrom-v2014.12-socfpga_16.03.02_pr rel_angstrom-v2014.12-socfpga_16.03.02_rc1
git push origin rel_angstrom-v2014.12-socfpga_16.03.02_pr:refs/tags/rel_angstrom-v2014.12-socfpga_16.03.02_pr
echo

git push portal rel_angstrom-v2014.12-socfpga_16.03.02_pr:refs/heads/angstrom-v2014.12-socfpga
git push portal rel_angstrom-v2014.12-socfpga_16.03.02_pr:refs/tags/rel_angstrom-v2014.12-socfpga_16.03.02_pr
echo


cd /home/atull/repos/internal/meta-altera
git tag rel_angstrom-v2014.12-yocto1.7_16.03.02_pr rel_angstrom-v2014.12-yocto1.7_16.03.02_rc1
git push origin rel_angstrom-v2014.12-yocto1.7_16.03.02_pr:refs/tags/rel_angstrom-v2014.12-yocto1.7_16.03.02_pr
echo

git push portal rel_angstrom-v2014.12-yocto1.7_16.03.02_pr:refs/heads/angstrom-v2014.12-yocto1.7
git push portal rel_angstrom-v2014.12-yocto1.7_16.03.02_pr:refs/tags/rel_angstrom-v2014.12-yocto1.7_16.03.02_pr
echo

git tag rel_angstrom-v2014.12-yocto1.7_a10_16.03.02_pr rel_angstrom-v2014.12-yocto1.7_a10_16.03.02_rc1
git push origin rel_angstrom-v2014.12-yocto1.7_a10_16.03.02_pr:refs/tags/rel_angstrom-v2014.12-yocto1.7_a10_16.03.02_pr
echo

git push portal rel_angstrom-v2014.12-yocto1.7_a10_16.03.02_pr:refs/heads/angstrom-v2014.12-yocto1.7_a10
git push portal rel_angstrom-v2014.12-yocto1.7_a10_16.03.02_pr:refs/tags/rel_angstrom-v2014.12-yocto1.7_a10_16.03.02_pr
echo


cd /home/atull/repos/internal/linux-tags
git tag rel_master_16.03.02_pr 5bec71e8358329ff180e21938890b9cf74e7d14d
git push origin rel_master_16.03.02_pr:refs/tags/rel_master_16.03.02_pr
git push origin rel_master_16.03.02_pr:refs/heads/master
