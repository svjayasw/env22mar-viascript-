#!/bin/bash -ex
# This script copies rcN tags to rcN+1 tags in local git,
# pushes them to internal and external git
#

cd /home/atull/repos/internal/linux-socfpga
git tag rel_socfpga-4.0_15.05.03_pr rel_socfpga-4.0_15.05.03_rc2
git push origin rel_socfpga-4.0_15.05.03_pr:refs/tags/rel_socfpga-4.0_15.05.03_pr
echo

git push portal rel_socfpga-4.0_15.05.03_pr:refs/heads/socfpga-4.0
git push portal rel_socfpga-4.0_15.05.03_pr:refs/tags/rel_socfpga-4.0_15.05.03_pr
echo

git tag rel_socfpga-3.10-ltsi_15.05.03_pr rel_socfpga-3.10-ltsi_15.05.03_rc2
git push origin rel_socfpga-3.10-ltsi_15.05.03_pr:refs/tags/rel_socfpga-3.10-ltsi_15.05.03_pr
echo

git push portal rel_socfpga-3.10-ltsi_15.05.03_pr:refs/heads/socfpga-3.10-ltsi
git push portal rel_socfpga-3.10-ltsi_15.05.03_pr:refs/tags/rel_socfpga-3.10-ltsi_15.05.03_pr
echo

git tag rel_socfpga-3.10-ltsi-rt_15.05.03_pr rel_socfpga-3.10-ltsi-rt_15.05.03_rc2
git push origin rel_socfpga-3.10-ltsi-rt_15.05.03_pr:refs/tags/rel_socfpga-3.10-ltsi-rt_15.05.03_pr
echo

git push portal rel_socfpga-3.10-ltsi-rt_15.05.03_pr:refs/heads/socfpga-3.10-ltsi-rt
git push portal rel_socfpga-3.10-ltsi-rt_15.05.03_pr:refs/tags/rel_socfpga-3.10-ltsi-rt_15.05.03_pr
echo


cd /home/atull/repos/internal/uboot-socfpga
git tag rel_socfpga_v2013.01.01_15.05.03_pr rel_socfpga_v2013.01.01_15.05.03_rc2
git push origin rel_socfpga_v2013.01.01_15.05.03_pr:refs/tags/rel_socfpga_v2013.01.01_15.05.03_pr
echo

git push portal rel_socfpga_v2013.01.01_15.05.03_pr:refs/heads/socfpga_v2013.01.01
git push portal rel_socfpga_v2013.01.01_15.05.03_pr:refs/tags/rel_socfpga_v2013.01.01_15.05.03_pr
echo

git tag rel_socfpga_v2014.10_arria10_bringup_15.05.03_pr rel_socfpga_v2014.10_arria10_bringup_15.05.03_rc2
git push origin rel_socfpga_v2014.10_arria10_bringup_15.05.03_pr:refs/tags/rel_socfpga_v2014.10_arria10_bringup_15.05.03_pr
echo

git push portal rel_socfpga_v2014.10_arria10_bringup_15.05.03_pr:refs/heads/socfpga_v2014.10_arria10_bringup
git push portal rel_socfpga_v2014.10_arria10_bringup_15.05.03_pr:refs/tags/rel_socfpga_v2014.10_arria10_bringup_15.05.03_pr
echo


cd /home/atull/repos/internal/angstrom-socfpga
git tag rel_angstrom-v2014.12-socfpga_15.05.03_pr rel_angstrom-v2014.12-socfpga_15.05.03_rc2
git push origin rel_angstrom-v2014.12-socfpga_15.05.03_pr:refs/tags/rel_angstrom-v2014.12-socfpga_15.05.03_pr
echo

git push portal rel_angstrom-v2014.12-socfpga_15.05.03_pr:refs/heads/angstrom-v2014.12-socfpga
git push portal rel_angstrom-v2014.12-socfpga_15.05.03_pr:refs/tags/rel_angstrom-v2014.12-socfpga_15.05.03_pr
echo


cd /home/atull/repos/internal/meta-altera
git tag rel_angstrom-v2014.12-yocto1.7_15.05.03_pr rel_angstrom-v2014.12-yocto1.7_15.05.03_rc2
git push origin rel_angstrom-v2014.12-yocto1.7_15.05.03_pr:refs/tags/rel_angstrom-v2014.12-yocto1.7_15.05.03_pr
echo

git push portal rel_angstrom-v2014.12-yocto1.7_15.05.03_pr:refs/heads/angstrom-v2014.12-yocto1.7
git push portal rel_angstrom-v2014.12-yocto1.7_15.05.03_pr:refs/tags/rel_angstrom-v2014.12-yocto1.7_15.05.03_pr
echo

git tag rel_angstrom-v2014.12-yocto1.7_a10_15.05.03_pr rel_angstrom-v2014.12-yocto1.7_a10_15.05.03_rc2
git push origin rel_angstrom-v2014.12-yocto1.7_a10_15.05.03_pr:refs/tags/rel_angstrom-v2014.12-yocto1.7_a10_15.05.03_pr
echo

git push portal rel_angstrom-v2014.12-yocto1.7_a10_15.05.03_pr:refs/heads/angstrom-v2014.12-yocto1.7_a10
git push portal rel_angstrom-v2014.12-yocto1.7_a10_15.05.03_pr:refs/tags/rel_angstrom-v2014.12-yocto1.7_a10_15.05.03_pr
echo


cd /home/atull/repos/internal/linux-tags
git tag rel_master_15.05.03_pr b2e2324d2ee15ee08a228389844020feb544fbc1
git push origin rel_master_15.05.03_pr:refs/tags/rel_master_15.05.03_pr
git push origin rel_master_15.05.03_pr:refs/heads/master