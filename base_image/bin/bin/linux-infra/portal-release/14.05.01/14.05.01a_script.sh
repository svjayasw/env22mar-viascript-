#/bin/bash -ex

# ------------------- angstrom-socfpga -------------------------
#cd /home/atull/repos/internal/angstrom-socfpga

#git tag -f rel_angstrom-v2012.12-socfpga_14.05.01 origin/angstrom-v2012.12-socfpga
#git log -1 --pretty=oneline  rel_angstrom-v2012.12-socfpga_14.05.01
#git log -1 --pretty=oneline  origin/angstrom-v2012.12-socfpga

#git tag -f rel_angstrom-v2013.12-socfpga_14.05.01 origin/angstrom-v2013.12-socfpga
#git log -1 --pretty=oneline  rel_angstrom-v2013.12-socfpga_14.05.01
#git log -1 --pretty=oneline  origin/angstrom-v2013.12-socfpga


#git push origin rel_angstrom-v2012.12-socfpga_14.05.01:refs/tags/rel_angstrom-v2012.12-socfpga_14.05.01
#git push portal rel_angstrom-v2012.12-socfpga_14.05.01:refs/tags/rel_angstrom-v2012.12-socfpga_14.05.01
#git push portal rel_angstrom-v2012.12-socfpga_14.05.01:refs/heads/angstrom-v2012.12-socfpga

#git push origin rel_angstrom-v2013.12-socfpga_14.05.01:refs/tags/rel_angstrom-v2013.12-socfpga_14.05.01
#git push portal rel_angstrom-v2013.12-socfpga_14.05.01:refs/tags/rel_angstrom-v2013.12-socfpga_14.05.01
#git push portal rel_angstrom-v2013.12-socfpga_14.05.01:refs/heads/angstrom-v2013.12-socfpga

# ------------------- meta-altera -------------------------
cd /home/atull/repos/internal/meta-altera

git tag -f rel_angstrom-v2012.12-yocto1.3_14.05.01 origin/angstrom-v2012.12-yocto1.3
git log -1 --pretty=oneline  rel_angstrom-v2012.12-yocto1.3_14.05.01
git log -1 --pretty=oneline  origin/angstrom-v2012.12-yocto1.3

git tag -f rel_angstrom-v2013.12-yocto1.5_14.05.01 origin/angstrom-v2013.12-yocto1.5
git log -1 --pretty=oneline  rel_angstrom-v2013.12-yocto1.5_14.05.01
git log -1 --pretty=oneline  origin/angstrom-v2013.12-yocto1.5


git push origin rel_angstrom-v2012.12-yocto1.3_14.05.01:refs/tags/rel_angstrom-v2012.12-yocto1.3_14.05.01
git push portal rel_angstrom-v2012.12-yocto1.3_14.05.01:refs/tags/rel_angstrom-v2012.12-yocto1.3_14.05.01
git push portal rel_angstrom-v2012.12-yocto1.3_14.05.01:refs/heads/angstrom-v2012.12-yocto1.3

git push origin rel_angstrom-v2013.12-yocto1.5_14.05.01:refs/tags/rel_angstrom-v2013.12-yocto1.5_14.05.01
git push portal rel_angstrom-v2013.12-yocto1.5_14.05.01:refs/tags/rel_angstrom-v2013.12-yocto1.5_14.05.01
git push portal rel_angstrom-v2013.12-yocto1.5_14.05.01:refs/heads/angstrom-v2013.12-yocto1.5

exit





# ------------------- linux-socfpga -------------------------
cd /home/atull/repos/internal/linux-socfpga

#git tag -f rel_socfpga-3.10-ltsi-rt_14.05.01 origin/socfpga-3.10-ltsi-rt
#git describe rel_socfpga-3.10-ltsi-rt_14.05.01
#git describe origin/socfpga-3.10-ltsi-rt
#exit

git push origin rel_socfpga-3.10-ltsi-rt_14.05.01:refs/tags/rel_socfpga-3.10-ltsi-rt_14.05.01
git push portal rel_socfpga-3.10-ltsi-rt_14.05.01:refs/tags/rel_socfpga-3.10-ltsi-rt_14.05.01
git push portal rel_socfpga-3.10-ltsi-rt_14.05.01:refs/heads/socfpga-3.10-ltsi-rt


git push origin rel_socfpga-3.14_14.05.01:refs/tags/rel_socfpga-3.14_14.05.01
git push portal rel_socfpga-3.14_14.05.01:refs/tags/rel_socfpga-3.14_14.05.01
git push portal rel_socfpga-3.14_14.05.01:refs/heads/socfpga-3.14

git push origin rel_socfpga-3.13_14.05.01:refs/tags/rel_socfpga-3.13_14.05.01
git push portal rel_socfpga-3.13_14.05.01:refs/tags/rel_socfpga-3.13_14.05.01
git push portal rel_socfpga-3.13_14.05.01:refs/heads/socfpga-3.13

git push origin rel_socfpga-3.10-ltsi_14.05.01:refs/tags/rel_socfpga-3.10-ltsi_14.05.01
git push portal rel_socfpga-3.10-ltsi_14.05.01:refs/tags/rel_socfpga-3.10-ltsi_14.05.01
git push portal rel_socfpga-3.10-ltsi_14.05.01:refs/heads/socfpga-3.10-ltsi


# ------------------- uboot-socfpga -------------------------
cd /home/atull/repos/internal/uboot-socfpga

git push origin rel_socfpga_v2013.01.01_14.05.01:refs/tags/rel_socfpga_v2013.01.01_14.05.01
git push portal rel_socfpga_v2013.01.01_14.05.01:refs/tags/rel_socfpga_v2013.01.01_14.05.01
git push portal rel_socfpga_v2013.01.01_14.05.01:refs/heads/socfpga_v2013.01.01


