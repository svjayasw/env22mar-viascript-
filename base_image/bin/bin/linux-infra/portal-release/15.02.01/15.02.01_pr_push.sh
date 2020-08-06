#!/bin/bash -ex
# This script copies rcN tags to rcN+1 tags in local git,
# pushes them to internal and RBO git
#

# Note that portal-report.py needs to be fixed again for new branches due to changes
# int the process.

cd /home/atull/repos/internal/linux-socfpga
#git tag rel_socfpga-3.17_15.02.01_pr rel_socfpga-3.17_15.02.01_rc1
#git push origin rel_socfpga-3.17_15.02.01_pr:refs/tags/rel_socfpga-3.17_15.02.01_pr
#echo

#git push portal rel_socfpga-3.17_15.02.01_pr:refs/tags/rel_socfpga-3.17_15.02.01_pr
#git push portal rel_socfpga-3.17_15.02.01_pr:refs/heads/socfpga-3.17
echo

git tag rel_socfpga-3.18_15.02.01_pr ab3f83e671d7a37e1db20d8a90fe0699b3424e76
git push origin rel_socfpga-3.18_15.02.01_pr:refs/tags/rel_socfpga-3.18_15.02.01_pr
echo

git push portal rel_socfpga-3.18_15.02.01_pr:refs/tags/rel_socfpga-3.18_15.02.01_pr
git push portal rel_socfpga-3.18_15.02.01_pr:refs/heads/socfpga-3.18
echo

git tag rel_socfpga-3.10-ltsi_15.02.01_pr rel_socfpga-3.10-ltsi_15.02.01_rc1
git push origin rel_socfpga-3.10-ltsi_15.02.01_pr:refs/tags/rel_socfpga-3.10-ltsi_15.02.01_pr
echo

git push portal rel_socfpga-3.10-ltsi_15.02.01_pr:refs/tags/rel_socfpga-3.10-ltsi_15.02.01_pr
git push portal rel_socfpga-3.10-ltsi_15.02.01_pr:refs/heads/socfpga-3.10-ltsi
echo

git tag rel_socfpga-3.10-ltsi-rt_15.02.01_pr rel_socfpga-3.10-ltsi-rt_15.02.01_rc1
git push origin rel_socfpga-3.10-ltsi-rt_15.02.01_pr:refs/tags/rel_socfpga-3.10-ltsi-rt_15.02.01_pr
echo

git push portal rel_socfpga-3.10-ltsi-rt_15.02.01_pr:refs/tags/rel_socfpga-3.10-ltsi-rt_15.02.01_pr
git push portal rel_socfpga-3.10-ltsi-rt_15.02.01_pr:refs/heads/socfpga-3.10-ltsi-rt
echo


cd /home/atull/repos/internal/uboot-socfpga
git tag rel_socfpga_v2013.01.01_15.02.01_pr rel_socfpga_v2013.01.01_15.02.01_rc1
git push origin rel_socfpga_v2013.01.01_15.02.01_pr:refs/tags/rel_socfpga_v2013.01.01_15.02.01_pr
echo

git push portal rel_socfpga_v2013.01.01_15.02.01_pr:refs/tags/rel_socfpga_v2013.01.01_15.02.01_pr
git push portal rel_socfpga_v2013.01.01_15.02.01_pr:refs/heads/socfpga_v2013.01.01
echo


cd /home/atull/repos/internal/poky
git tag rel_danny-altera_15.02.01_pr rel_danny-altera_15.02.01_rc1
git push origin rel_danny-altera_15.02.01_pr:refs/tags/rel_danny-altera_15.02.01_pr
echo

git push portal rel_danny-altera_15.02.01_pr:refs/tags/rel_danny-altera_15.02.01_pr
git push portal rel_danny-altera_15.02.01_pr:refs/heads/danny-altera
echo


cd /home/atull/repos/internal/angstrom-socfpga
git tag rel_angstrom-v2012.12-socfpga_15.02.01_pr rel_angstrom-v2012.12-socfpga_15.02.01_rc1
git push origin rel_angstrom-v2012.12-socfpga_15.02.01_pr:refs/tags/rel_angstrom-v2012.12-socfpga_15.02.01_pr
echo

git push portal rel_angstrom-v2012.12-socfpga_15.02.01_pr:refs/tags/rel_angstrom-v2012.12-socfpga_15.02.01_pr
git push portal rel_angstrom-v2012.12-socfpga_15.02.01_pr:refs/heads/angstrom-v2012.12-socfpga
echo

git tag rel_angstrom-v2013.12-socfpga_15.02.01_pr rel_angstrom-v2013.12-socfpga_15.02.01_rc1
git push origin rel_angstrom-v2013.12-socfpga_15.02.01_pr:refs/tags/rel_angstrom-v2013.12-socfpga_15.02.01_pr
echo

git push portal rel_angstrom-v2013.12-socfpga_15.02.01_pr:refs/tags/rel_angstrom-v2013.12-socfpga_15.02.01_pr
git push portal rel_angstrom-v2013.12-socfpga_15.02.01_pr:refs/heads/angstrom-v2013.12-socfpga
echo

git tag rel_angstrom-v2014.06-socfpga_15.02.01_pr rel_angstrom-v2014.06-socfpga_15.02.01_rc1
git push origin rel_angstrom-v2014.06-socfpga_15.02.01_pr:refs/tags/rel_angstrom-v2014.06-socfpga_15.02.01_pr
echo

git push portal rel_angstrom-v2014.06-socfpga_15.02.01_pr:refs/tags/rel_angstrom-v2014.06-socfpga_15.02.01_pr
git push portal rel_angstrom-v2014.06-socfpga_15.02.01_pr:refs/heads/angstrom-v2014.06-socfpga
echo


cd /home/atull/repos/internal/meta-altera
git tag rel_angstrom-v2012.12-yocto1.3_15.02.01_pr rel_angstrom-v2012.12-yocto1.3_15.02.01_rc1
git push origin rel_angstrom-v2012.12-yocto1.3_15.02.01_pr:refs/tags/rel_angstrom-v2012.12-yocto1.3_15.02.01_pr
echo

git push portal rel_angstrom-v2012.12-yocto1.3_15.02.01_pr:refs/tags/rel_angstrom-v2012.12-yocto1.3_15.02.01_pr
git push portal rel_angstrom-v2012.12-yocto1.3_15.02.01_pr:refs/heads/angstrom-v2012.12-yocto1.3
echo

git tag rel_angstrom-v2013.12-yocto1.5_15.02.01_pr rel_angstrom-v2013.12-yocto1.5_15.02.01_rc1
git push origin rel_angstrom-v2013.12-yocto1.5_15.02.01_pr:refs/tags/rel_angstrom-v2013.12-yocto1.5_15.02.01_pr
echo

git push portal rel_angstrom-v2013.12-yocto1.5_15.02.01_pr:refs/tags/rel_angstrom-v2013.12-yocto1.5_15.02.01_pr
git push portal rel_angstrom-v2013.12-yocto1.5_15.02.01_pr:refs/heads/angstrom-v2013.12-yocto1.5
echo

git tag rel_angstrom-v2014.06-yocto1.6_15.02.01_pr rel_angstrom-v2014.06-yocto1.6_15.02.01_rc1
git push origin rel_angstrom-v2014.06-yocto1.6_15.02.01_pr:refs/tags/rel_angstrom-v2014.06-yocto1.6_15.02.01_pr
echo

git push portal rel_angstrom-v2014.06-yocto1.6_15.02.01_pr:refs/tags/rel_angstrom-v2014.06-yocto1.6_15.02.01_pr
git push portal rel_angstrom-v2014.06-yocto1.6_15.02.01_pr:refs/heads/angstrom-v2014.06-yocto1.6
echo


cd /home/atull/repos/internal/linux-test
git tag rel_master_15.02.01_pr rel_master_15.02.01_rc1
git push origin rel_master_15.02.01_pr:refs/tags/rel_master_15.02.01_pr
echo

echo


cd /home/atull/repos/internal/linux-infra
git tag rel_tags_v1_15.02.01_pr rel_tags_v1_15.02.01_rc1
git push origin rel_tags_v1_15.02.01_pr:refs/tags/rel_tags_v1_15.02.01_pr
echo

echo


cd /home/atull/repos/internal/linux-tags
git tag rel_master_15.02.01_pr a96424ab8b7e81d644b4821b9f8a6cb1f6702024
git push origin rel_master_15.02.01_pr:refs/tags/rel_master_15.02.01_pr
git push origin rel_master_15.02.01_pr:refs/heads/master
