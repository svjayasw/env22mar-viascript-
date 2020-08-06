#!/bin/bash -ex
# This script copies rcN tags to rcN+1 tags in local git,
# pushes them to internal and RBO git
#

cd /home/atull/repos/internal/linux-socfpga
git tag rel_socfpga-3.17_14.11.01_pr rel_socfpga-3.17_14.11.01_rc2
git log --pretty=oneline -1 rel_socfpga-3.17_14.11.01_rc2
git log --pretty=oneline -1 rel_socfpga-3.17_14.11.01_pr
git push origin rel_socfpga-3.17_14.11.01_pr:refs/tags/rel_socfpga-3.17_14.11.01_pr
echo

git push portal rel_socfpga-3.17_14.11.01_pr:refs/tags/rel_socfpga-3.17_14.11.01_pr
git push portal rel_socfpga-3.17_14.11.01_pr:refs/heads/socfpga-3.17
git log --pretty=oneline -1 rel_socfpga-3.17_14.11.01_pr
echo

git tag rel_socfpga-3.16_14.11.01_pr rel_socfpga-3.16_14.11.01_rc2
git log --pretty=oneline -1 rel_socfpga-3.16_14.11.01_rc2
git log --pretty=oneline -1 rel_socfpga-3.16_14.11.01_pr
git push origin rel_socfpga-3.16_14.11.01_pr:refs/tags/rel_socfpga-3.16_14.11.01_pr
echo

git push portal rel_socfpga-3.16_14.11.01_pr:refs/tags/rel_socfpga-3.16_14.11.01_pr
git push portal rel_socfpga-3.16_14.11.01_pr:refs/heads/socfpga-3.16
git log --pretty=oneline -1 rel_socfpga-3.16_14.11.01_pr
echo

git tag rel_socfpga-3.10-ltsi_14.11.01_pr rel_socfpga-3.10-ltsi_14.11.01_rc2
git log --pretty=oneline -1 rel_socfpga-3.10-ltsi_14.11.01_rc2
git log --pretty=oneline -1 rel_socfpga-3.10-ltsi_14.11.01_pr
git push origin rel_socfpga-3.10-ltsi_14.11.01_pr:refs/tags/rel_socfpga-3.10-ltsi_14.11.01_pr
echo

git push portal rel_socfpga-3.10-ltsi_14.11.01_pr:refs/tags/rel_socfpga-3.10-ltsi_14.11.01_pr
git push portal rel_socfpga-3.10-ltsi_14.11.01_pr:refs/heads/socfpga-3.10-ltsi
git log --pretty=oneline -1 rel_socfpga-3.10-ltsi_14.11.01_pr
echo

git tag rel_socfpga-3.10-ltsi-rt_14.11.01_pr rel_socfpga-3.10-ltsi-rt_14.11.01_rc2
git log --pretty=oneline -1 rel_socfpga-3.10-ltsi-rt_14.11.01_rc2
git log --pretty=oneline -1 rel_socfpga-3.10-ltsi-rt_14.11.01_pr
git push origin rel_socfpga-3.10-ltsi-rt_14.11.01_pr:refs/tags/rel_socfpga-3.10-ltsi-rt_14.11.01_pr
echo

git push portal rel_socfpga-3.10-ltsi-rt_14.11.01_pr:refs/tags/rel_socfpga-3.10-ltsi-rt_14.11.01_pr
git push portal rel_socfpga-3.10-ltsi-rt_14.11.01_pr:refs/heads/socfpga-3.10-ltsi-rt
git log --pretty=oneline -1 rel_socfpga-3.10-ltsi-rt_14.11.01_pr
echo


cd /home/atull/repos/internal/uboot-socfpga
git tag rel_socfpga_v2013.01.01_14.11.01_pr rel_socfpga_v2013.01.01_14.11.01_rc2
git log --pretty=oneline -1 rel_socfpga_v2013.01.01_14.11.01_rc2
git log --pretty=oneline -1 rel_socfpga_v2013.01.01_14.11.01_pr
git push origin rel_socfpga_v2013.01.01_14.11.01_pr:refs/tags/rel_socfpga_v2013.01.01_14.11.01_pr
echo

git push portal rel_socfpga_v2013.01.01_14.11.01_pr:refs/tags/rel_socfpga_v2013.01.01_14.11.01_pr
git push portal rel_socfpga_v2013.01.01_14.11.01_pr:refs/heads/socfpga_v2013.01.01
git log --pretty=oneline -1 rel_socfpga_v2013.01.01_14.11.01_pr
echo


cd /home/atull/repos/internal/poky
git tag rel_danny-altera_14.11.01_pr rel_danny-altera_14.11.01_rc2
git log --pretty=oneline -1 rel_danny-altera_14.11.01_rc2
git log --pretty=oneline -1 rel_danny-altera_14.11.01_pr
git push origin rel_danny-altera_14.11.01_pr:refs/tags/rel_danny-altera_14.11.01_pr
echo

git push portal rel_danny-altera_14.11.01_pr:refs/tags/rel_danny-altera_14.11.01_pr
git push portal rel_danny-altera_14.11.01_pr:refs/heads/danny-altera
git log --pretty=oneline -1 rel_danny-altera_14.11.01_pr
echo


cd /home/atull/repos/internal/angstrom-socfpga
git tag rel_angstrom-v2012.12-socfpga_14.11.01_pr rel_angstrom-v2012.12-socfpga_14.11.01_rc2
git log --pretty=oneline -1 rel_angstrom-v2012.12-socfpga_14.11.01_rc2
git log --pretty=oneline -1 rel_angstrom-v2012.12-socfpga_14.11.01_pr
git push origin rel_angstrom-v2012.12-socfpga_14.11.01_pr:refs/tags/rel_angstrom-v2012.12-socfpga_14.11.01_pr
echo

git push portal rel_angstrom-v2012.12-socfpga_14.11.01_pr:refs/tags/rel_angstrom-v2012.12-socfpga_14.11.01_pr
git push portal rel_angstrom-v2012.12-socfpga_14.11.01_pr:refs/heads/angstrom-v2012.12-socfpga
git log --pretty=oneline -1 rel_angstrom-v2012.12-socfpga_14.11.01_pr
echo

git tag rel_angstrom-v2013.12-socfpga_14.11.01_pr rel_angstrom-v2013.12-socfpga_14.11.01_rc2
git log --pretty=oneline -1 rel_angstrom-v2013.12-socfpga_14.11.01_rc2
git log --pretty=oneline -1 rel_angstrom-v2013.12-socfpga_14.11.01_pr
git push origin rel_angstrom-v2013.12-socfpga_14.11.01_pr:refs/tags/rel_angstrom-v2013.12-socfpga_14.11.01_pr
echo

git push portal rel_angstrom-v2013.12-socfpga_14.11.01_pr:refs/tags/rel_angstrom-v2013.12-socfpga_14.11.01_pr
git push portal rel_angstrom-v2013.12-socfpga_14.11.01_pr:refs/heads/angstrom-v2013.12-socfpga
git log --pretty=oneline -1 rel_angstrom-v2013.12-socfpga_14.11.01_pr
echo

git tag rel_angstrom-v2014.06-socfpga_14.11.01_pr rel_angstrom-v2014.06-socfpga_14.11.01_rc2
git log --pretty=oneline -1 rel_angstrom-v2014.06-socfpga_14.11.01_rc2
git log --pretty=oneline -1 rel_angstrom-v2014.06-socfpga_14.11.01_pr
git push origin rel_angstrom-v2014.06-socfpga_14.11.01_pr:refs/tags/rel_angstrom-v2014.06-socfpga_14.11.01_pr
echo

git push portal rel_angstrom-v2014.06-socfpga_14.11.01_pr:refs/tags/rel_angstrom-v2014.06-socfpga_14.11.01_pr
git push portal rel_angstrom-v2014.06-socfpga_14.11.01_pr:refs/heads/angstrom-v2014.06-socfpga
git log --pretty=oneline -1 rel_angstrom-v2014.06-socfpga_14.11.01_pr
echo


cd /home/atull/repos/internal/meta-altera
git tag rel_angstrom-v2012.12-yocto1.3_14.11.01_pr rel_angstrom-v2012.12-yocto1.3_14.11.01_rc2
git log --pretty=oneline -1 rel_angstrom-v2012.12-yocto1.3_14.11.01_rc2
git log --pretty=oneline -1 rel_angstrom-v2012.12-yocto1.3_14.11.01_pr
git push origin rel_angstrom-v2012.12-yocto1.3_14.11.01_pr:refs/tags/rel_angstrom-v2012.12-yocto1.3_14.11.01_pr
echo

git push portal rel_angstrom-v2012.12-yocto1.3_14.11.01_pr:refs/tags/rel_angstrom-v2012.12-yocto1.3_14.11.01_pr
git push portal rel_angstrom-v2012.12-yocto1.3_14.11.01_pr:refs/heads/angstrom-v2012.12-yocto1.3
git log --pretty=oneline -1 rel_angstrom-v2012.12-yocto1.3_14.11.01_pr
echo

git tag rel_angstrom-v2013.12-yocto1.5_14.11.01_pr rel_angstrom-v2013.12-yocto1.5_14.11.01_rc2
git log --pretty=oneline -1 rel_angstrom-v2013.12-yocto1.5_14.11.01_rc2
git log --pretty=oneline -1 rel_angstrom-v2013.12-yocto1.5_14.11.01_pr
git push origin rel_angstrom-v2013.12-yocto1.5_14.11.01_pr:refs/tags/rel_angstrom-v2013.12-yocto1.5_14.11.01_pr
echo

git push portal rel_angstrom-v2013.12-yocto1.5_14.11.01_pr:refs/tags/rel_angstrom-v2013.12-yocto1.5_14.11.01_pr
git push portal rel_angstrom-v2013.12-yocto1.5_14.11.01_pr:refs/heads/angstrom-v2013.12-yocto1.5
git log --pretty=oneline -1 rel_angstrom-v2013.12-yocto1.5_14.11.01_pr
echo

git tag rel_angstrom-v2014.06-yocto1.6_14.11.01_pr rel_angstrom-v2014.06-yocto1.6_14.11.01_rc2
git log --pretty=oneline -1 rel_angstrom-v2014.06-yocto1.6_14.11.01_rc2
git log --pretty=oneline -1 rel_angstrom-v2014.06-yocto1.6_14.11.01_pr
git push origin rel_angstrom-v2014.06-yocto1.6_14.11.01_pr:refs/tags/rel_angstrom-v2014.06-yocto1.6_14.11.01_pr
echo

git push portal rel_angstrom-v2014.06-yocto1.6_14.11.01_pr:refs/tags/rel_angstrom-v2014.06-yocto1.6_14.11.01_pr
git push portal rel_angstrom-v2014.06-yocto1.6_14.11.01_pr:refs/heads/angstrom-v2014.06-yocto1.6
git log --pretty=oneline -1 rel_angstrom-v2014.06-yocto1.6_14.11.01_pr
echo


cd /home/atull/repos/internal/linux-test
git tag rel_master_14.11.01_pr rel_master_14.11.01_rc2
git log --pretty=oneline -1 rel_master_14.11.01_rc2
git log --pretty=oneline -1 rel_master_14.11.01_pr
git push origin rel_master_14.11.01_pr:refs/tags/rel_master_14.11.01_pr
echo

echo


cd /home/atull/repos/internal/linux-infra
git tag rel_tags_v1_14.11.01_pr rel_tags_v1_14.11.01_rc2
git log --pretty=oneline -1 rel_tags_v1_14.11.01_rc2
git log --pretty=oneline -1 rel_tags_v1_14.11.01_pr
git push origin rel_tags_v1_14.11.01_pr:refs/tags/rel_tags_v1_14.11.01_pr
echo

echo


cd /home/atull/repos/internal/linux-tags
git tag rel_master_14.11.01_pr e76f7b06cf3e1f8bb78a1d080c1c6c71626a5475
git push origin rel_master_14.11.01_pr:refs/tags/rel_master_14.11.01_pr
git push origin rel_master_14.11.01_pr:refs/heads/master
