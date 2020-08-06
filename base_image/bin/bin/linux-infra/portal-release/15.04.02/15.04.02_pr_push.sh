#!/bin/bash -ex
# This script copies rcN tags to rcN+1 tags in local git,
# pushes them to internal and external git
#

cd /home/atull/repos/internal/linux-socfpga
git tag rel_socfpga-3.18_15.04.02_pr rel_socfpga-3.18_15.04.02_rc1
git push origin rel_socfpga-3.18_15.04.02_pr:refs/tags/rel_socfpga-3.18_15.04.02_pr
echo

git push portal rel_socfpga-3.18_15.04.02_pr:refs/heads/socfpga-3.18
git push portal rel_socfpga-3.18_15.04.02_pr:refs/tags/rel_socfpga-3.18_15.04.02_pr
git push github rel_socfpga-3.18_15.04.02_pr:refs/heads/socfpga-3.18
git push github rel_socfpga-3.18_15.04.02_pr:refs/tags/rel_socfpga-3.18_15.04.02_pr
echo

git tag rel_socfpga-3.10-ltsi_15.04.02_pr rel_socfpga-3.10-ltsi_15.04.02_rc1
git push origin rel_socfpga-3.10-ltsi_15.04.02_pr:refs/tags/rel_socfpga-3.10-ltsi_15.04.02_pr
echo

git push portal rel_socfpga-3.10-ltsi_15.04.02_pr:refs/heads/socfpga-3.10-ltsi
git push portal rel_socfpga-3.10-ltsi_15.04.02_pr:refs/tags/rel_socfpga-3.10-ltsi_15.04.02_pr
git push github rel_socfpga-3.10-ltsi_15.04.02_pr:refs/heads/socfpga-3.10-ltsi
git push github rel_socfpga-3.10-ltsi_15.04.02_pr:refs/tags/rel_socfpga-3.10-ltsi_15.04.02_pr
echo

git tag rel_socfpga-3.10-ltsi-rt_15.04.02_pr rel_socfpga-3.10-ltsi-rt_15.04.02_rc1
git push origin rel_socfpga-3.10-ltsi-rt_15.04.02_pr:refs/tags/rel_socfpga-3.10-ltsi-rt_15.04.02_pr
echo

git push portal rel_socfpga-3.10-ltsi-rt_15.04.02_pr:refs/heads/socfpga-3.10-ltsi-rt
git push portal rel_socfpga-3.10-ltsi-rt_15.04.02_pr:refs/tags/rel_socfpga-3.10-ltsi-rt_15.04.02_pr
git push github rel_socfpga-3.10-ltsi-rt_15.04.02_pr:refs/heads/socfpga-3.10-ltsi-rt
git push github rel_socfpga-3.10-ltsi-rt_15.04.02_pr:refs/tags/rel_socfpga-3.10-ltsi-rt_15.04.02_pr
echo


cd /home/atull/repos/internal/uboot-socfpga
git tag rel_socfpga_v2013.01.01_15.04.02_pr rel_socfpga_v2013.01.01_15.04.02_rc1
git push origin rel_socfpga_v2013.01.01_15.04.02_pr:refs/tags/rel_socfpga_v2013.01.01_15.04.02_pr
echo

git push portal rel_socfpga_v2013.01.01_15.04.02_pr:refs/heads/socfpga_v2013.01.01
git push portal rel_socfpga_v2013.01.01_15.04.02_pr:refs/tags/rel_socfpga_v2013.01.01_15.04.02_pr
git push github rel_socfpga_v2013.01.01_15.04.02_pr:refs/heads/socfpga_v2013.01.01
git push github rel_socfpga_v2013.01.01_15.04.02_pr:refs/tags/rel_socfpga_v2013.01.01_15.04.02_pr
echo

git tag rel_socfpga_v2014.10_arria10_bringup_15.04.02_pr rel_socfpga_v2014.10_arria10_bringup_15.04.02_rc1
git push origin rel_socfpga_v2014.10_arria10_bringup_15.04.02_pr:refs/tags/rel_socfpga_v2014.10_arria10_bringup_15.04.02_pr
echo

git push portal rel_socfpga_v2014.10_arria10_bringup_15.04.02_pr:refs/heads/socfpga_v2014.10_arria10_bringup
git push portal rel_socfpga_v2014.10_arria10_bringup_15.04.02_pr:refs/tags/rel_socfpga_v2014.10_arria10_bringup_15.04.02_pr
git push github rel_socfpga_v2014.10_arria10_bringup_15.04.02_pr:refs/heads/socfpga_v2014.10_arria10_bringup
git push github rel_socfpga_v2014.10_arria10_bringup_15.04.02_pr:refs/tags/rel_socfpga_v2014.10_arria10_bringup_15.04.02_pr
echo


cd /home/atull/repos/internal/angstrom-socfpga
git tag rel_angstrom-v2012.12-socfpga_15.04.02_pr rel_angstrom-v2012.12-socfpga_15.04.02_rc1
git push origin rel_angstrom-v2012.12-socfpga_15.04.02_pr:refs/tags/rel_angstrom-v2012.12-socfpga_15.04.02_pr
echo

git push portal rel_angstrom-v2012.12-socfpga_15.04.02_pr:refs/heads/angstrom-v2012.12-socfpga
git push portal rel_angstrom-v2012.12-socfpga_15.04.02_pr:refs/tags/rel_angstrom-v2012.12-socfpga_15.04.02_pr
git push github rel_angstrom-v2012.12-socfpga_15.04.02_pr:refs/heads/angstrom-v2012.12-socfpga
git push github rel_angstrom-v2012.12-socfpga_15.04.02_pr:refs/tags/rel_angstrom-v2012.12-socfpga_15.04.02_pr
echo

git tag rel_angstrom-v2013.12-socfpga_15.04.02_pr rel_angstrom-v2013.12-socfpga_15.04.02_rc1
git push origin rel_angstrom-v2013.12-socfpga_15.04.02_pr:refs/tags/rel_angstrom-v2013.12-socfpga_15.04.02_pr
echo

git push portal rel_angstrom-v2013.12-socfpga_15.04.02_pr:refs/heads/angstrom-v2013.12-socfpga
git push portal rel_angstrom-v2013.12-socfpga_15.04.02_pr:refs/tags/rel_angstrom-v2013.12-socfpga_15.04.02_pr
git push github rel_angstrom-v2013.12-socfpga_15.04.02_pr:refs/heads/angstrom-v2013.12-socfpga
git push github rel_angstrom-v2013.12-socfpga_15.04.02_pr:refs/tags/rel_angstrom-v2013.12-socfpga_15.04.02_pr
echo

git tag rel_angstrom-v2014.06-socfpga_15.04.02_pr rel_angstrom-v2014.06-socfpga_15.04.02_rc1
git push origin rel_angstrom-v2014.06-socfpga_15.04.02_pr:refs/tags/rel_angstrom-v2014.06-socfpga_15.04.02_pr
echo

git push portal rel_angstrom-v2014.06-socfpga_15.04.02_pr:refs/heads/angstrom-v2014.06-socfpga
git push portal rel_angstrom-v2014.06-socfpga_15.04.02_pr:refs/tags/rel_angstrom-v2014.06-socfpga_15.04.02_pr
git push github rel_angstrom-v2014.06-socfpga_15.04.02_pr:refs/heads/angstrom-v2014.06-socfpga
git push github rel_angstrom-v2014.06-socfpga_15.04.02_pr:refs/tags/rel_angstrom-v2014.06-socfpga_15.04.02_pr
echo

git tag rel_angstrom-v2014.12-socfpga_15.04.02_pr rel_angstrom-v2014.12-socfpga_15.04.02_rc1
git push origin rel_angstrom-v2014.12-socfpga_15.04.02_pr:refs/tags/rel_angstrom-v2014.12-socfpga_15.04.02_pr
echo

git push portal rel_angstrom-v2014.12-socfpga_15.04.02_pr:refs/heads/angstrom-v2014.12-socfpga
git push portal rel_angstrom-v2014.12-socfpga_15.04.02_pr:refs/tags/rel_angstrom-v2014.12-socfpga_15.04.02_pr
git push github rel_angstrom-v2014.12-socfpga_15.04.02_pr:refs/heads/angstrom-v2014.12-socfpga
git push github rel_angstrom-v2014.12-socfpga_15.04.02_pr:refs/tags/rel_angstrom-v2014.12-socfpga_15.04.02_pr
echo


cd /home/atull/repos/internal/meta-altera
git tag rel_angstrom-v2012.12-yocto1.3_15.04.02_pr rel_angstrom-v2012.12-yocto1.3_15.04.02_rc1
git push origin rel_angstrom-v2012.12-yocto1.3_15.04.02_pr:refs/tags/rel_angstrom-v2012.12-yocto1.3_15.04.02_pr
echo

git push portal rel_angstrom-v2012.12-yocto1.3_15.04.02_pr:refs/heads/angstrom-v2012.12-yocto1.3
git push portal rel_angstrom-v2012.12-yocto1.3_15.04.02_pr:refs/tags/rel_angstrom-v2012.12-yocto1.3_15.04.02_pr
git push github rel_angstrom-v2012.12-yocto1.3_15.04.02_pr:refs/heads/angstrom-v2012.12-yocto1.3
git push github rel_angstrom-v2012.12-yocto1.3_15.04.02_pr:refs/tags/rel_angstrom-v2012.12-yocto1.3_15.04.02_pr
echo

git tag rel_angstrom-v2013.12-yocto1.5_15.04.02_pr rel_angstrom-v2013.12-yocto1.5_15.04.02_rc1
git push origin rel_angstrom-v2013.12-yocto1.5_15.04.02_pr:refs/tags/rel_angstrom-v2013.12-yocto1.5_15.04.02_pr
echo

git push portal rel_angstrom-v2013.12-yocto1.5_15.04.02_pr:refs/heads/angstrom-v2013.12-yocto1.5
git push portal rel_angstrom-v2013.12-yocto1.5_15.04.02_pr:refs/tags/rel_angstrom-v2013.12-yocto1.5_15.04.02_pr
git push github rel_angstrom-v2013.12-yocto1.5_15.04.02_pr:refs/heads/angstrom-v2013.12-yocto1.5
git push github rel_angstrom-v2013.12-yocto1.5_15.04.02_pr:refs/tags/rel_angstrom-v2013.12-yocto1.5_15.04.02_pr
echo

git tag rel_angstrom-v2014.06-yocto1.6_15.04.02_pr rel_angstrom-v2014.06-yocto1.6_15.04.02_rc1
git push origin rel_angstrom-v2014.06-yocto1.6_15.04.02_pr:refs/tags/rel_angstrom-v2014.06-yocto1.6_15.04.02_pr
echo

git push portal rel_angstrom-v2014.06-yocto1.6_15.04.02_pr:refs/heads/angstrom-v2014.06-yocto1.6
git push portal rel_angstrom-v2014.06-yocto1.6_15.04.02_pr:refs/tags/rel_angstrom-v2014.06-yocto1.6_15.04.02_pr
git push github rel_angstrom-v2014.06-yocto1.6_15.04.02_pr:refs/heads/angstrom-v2014.06-yocto1.6
git push github rel_angstrom-v2014.06-yocto1.6_15.04.02_pr:refs/tags/rel_angstrom-v2014.06-yocto1.6_15.04.02_pr
echo

git tag rel_angstrom-v2014.12-yocto1.7_15.04.02_pr rel_angstrom-v2014.12-yocto1.7_15.04.02_rc1
git push origin rel_angstrom-v2014.12-yocto1.7_15.04.02_pr:refs/tags/rel_angstrom-v2014.12-yocto1.7_15.04.02_pr
echo

git push portal rel_angstrom-v2014.12-yocto1.7_15.04.02_pr:refs/heads/angstrom-v2014.12-yocto1.7
git push portal rel_angstrom-v2014.12-yocto1.7_15.04.02_pr:refs/tags/rel_angstrom-v2014.12-yocto1.7_15.04.02_pr
git push github rel_angstrom-v2014.12-yocto1.7_15.04.02_pr:refs/heads/angstrom-v2014.12-yocto1.7
git push github rel_angstrom-v2014.12-yocto1.7_15.04.02_pr:refs/tags/rel_angstrom-v2014.12-yocto1.7_15.04.02_pr
echo

git tag rel_angstrom-v2014.12-yocto1.7_a10_15.04.02_pr rel_angstrom-v2014.12-yocto1.7_a10_15.04.02_rc1
git push origin rel_angstrom-v2014.12-yocto1.7_a10_15.04.02_pr:refs/tags/rel_angstrom-v2014.12-yocto1.7_a10_15.04.02_pr
echo

git push portal rel_angstrom-v2014.12-yocto1.7_a10_15.04.02_pr:refs/heads/angstrom-v2014.12-yocto1.7_a10
git push portal rel_angstrom-v2014.12-yocto1.7_a10_15.04.02_pr:refs/tags/rel_angstrom-v2014.12-yocto1.7_a10_15.04.02_pr
git push github rel_angstrom-v2014.12-yocto1.7_a10_15.04.02_pr:refs/heads/angstrom-v2014.12-yocto1.7_a10
git push github rel_angstrom-v2014.12-yocto1.7_a10_15.04.02_pr:refs/tags/rel_angstrom-v2014.12-yocto1.7_a10_15.04.02_pr
echo


cd /home/atull/repos/internal/linux-tags
git tag rel_master_15.04.02_pr 6865703bdfd0c8f23908c643e157fa349a53eef7
git push origin rel_master_15.04.02_pr:refs/tags/rel_master_15.04.02_pr
git push origin rel_master_15.04.02_pr:refs/heads/master
