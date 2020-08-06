#/bin/bash -ex

# ------------------- linux-socfpga -------------------------
cd /home/atull/repos/internal/linux-socfpga

git push origin rel_socfpga-3.15_14.07.01:refs/tags/rel_socfpga-3.15_14.07.01
git push portal rel_socfpga-3.15_14.07.01:refs/tags/rel_socfpga-3.15_14.07.01
git push portal rel_socfpga-3.15_14.07.01:refs/heads/socfpga-3.15

echo d911498161dda005312d3a89bc7b033fa5463638
git push origin rel_socfpga-3.14_14.07.01:refs/tags/rel_socfpga-3.14_14.07.01
git push portal rel_socfpga-3.14_14.07.01:refs/tags/rel_socfpga-3.14_14.07.01
git push portal rel_socfpga-3.14_14.07.01:refs/heads/socfpga-3.14

echo 56295c197e082c6b7420dfc3c109c3757eca5601
git push origin rel_socfpga-3.10-ltsi_14.07.01:refs/tags/rel_socfpga-3.10-ltsi_14.07.01
git push portal rel_socfpga-3.10-ltsi_14.07.01:refs/tags/rel_socfpga-3.10-ltsi_14.07.01
git push portal rel_socfpga-3.10-ltsi_14.07.01:refs/heads/socfpga-3.10-ltsi

echo 63e74b91b3a17cbc77a042b558d85b093df3907c
git push origin rel_socfpga-3.10-ltsi-rt_14.07.01:refs/tags/rel_socfpga-3.10-ltsi-rt_14.07.01
git push portal rel_socfpga-3.10-ltsi-rt_14.07.01:refs/tags/rel_socfpga-3.10-ltsi-rt_14.07.01
git push portal rel_socfpga-3.10-ltsi-rt_14.07.01:refs/heads/socfpga-3.10-ltsi-rt

git push origin rel_socfpga-3.13-rel14.0_14.07.01:refs/tags/rel_socfpga-3.13-rel14.0_14.07.01
git push portal rel_socfpga-3.13-rel14.0_14.07.01:refs/tags/rel_socfpga-3.13-rel14.0_14.07.01
git push portal rel_socfpga-3.13-rel14.0_14.07.01:refs/heads/socfpga-3.13-rel14.0


# ------------------- uboot-socfpga -------------------------
cd /home/atull/repos/internal/uboot-socfpga

git push origin rel_socfpga_v2013.01.01_14.07.01:refs/tags/rel_socfpga_v2013.01.01_14.07.01
git push portal rel_socfpga_v2013.01.01_14.07.01:refs/tags/rel_socfpga_v2013.01.01_14.07.01
git push portal rel_socfpga_v2013.01.01_14.07.01:refs/heads/socfpga_v2013.01.01

git push origin rel_socfpga_v2013.01.01-rel14.0_14.07.01:refs/tags/rel_socfpga_v2013.01.01-rel14.0_14.07.01
git push portal rel_socfpga_v2013.01.01-rel14.0_14.07.01:refs/tags/rel_socfpga_v2013.01.01-rel14.0_14.07.01
git push portal rel_socfpga_v2013.01.01-rel14.0_14.07.01:refs/heads/socfpga_v2013.01.01-rel14.0


# ------------------- poky -------------------------
cd /home/atull/repos/internal/poky

git push origin rel_danny-altera_14.07.01:refs/tags/rel_danny-altera_14.07.01
git push portal rel_danny-altera_14.07.01:refs/tags/rel_danny-altera_14.07.01
git push portal rel_danny-altera_14.07.01:refs/heads/danny-altera

git push origin rel_danny-altera-rel14.0_14.07.01:refs/tags/rel_danny-altera-rel14.0_14.07.01
git push portal rel_danny-altera-rel14.0_14.07.01:refs/tags/rel_danny-altera-rel14.0_14.07.01
git push portal rel_danny-altera-rel14.0_14.07.01:refs/heads/danny-altera-rel14.0


# ------------------- angstrom-socfpga -------------------------
cd /home/atull/repos/internal/angstrom-socfpga

git push origin rel_angstrom-v2012.12-socfpga_14.07.01:refs/tags/rel_angstrom-v2012.12-socfpga_14.07.01
git push portal rel_angstrom-v2012.12-socfpga_14.07.01:refs/tags/rel_angstrom-v2012.12-socfpga_14.07.01
git push portal rel_angstrom-v2012.12-socfpga_14.07.01:refs/heads/angstrom-v2012.12-socfpga

git push origin rel_angstrom-v2013.12-socfpga_14.07.01:refs/tags/rel_angstrom-v2013.12-socfpga_14.07.01
git push portal rel_angstrom-v2013.12-socfpga_14.07.01:refs/tags/rel_angstrom-v2013.12-socfpga_14.07.01
git push portal rel_angstrom-v2013.12-socfpga_14.07.01:refs/heads/angstrom-v2013.12-socfpga

git push origin rel_angstrom-v2014.06-socfpga_14.07.01:refs/tags/rel_angstrom-v2014.06-socfpga_14.07.01
git push portal rel_angstrom-v2014.06-socfpga_14.07.01:refs/tags/rel_angstrom-v2014.06-socfpga_14.07.01
git push portal rel_angstrom-v2014.06-socfpga_14.07.01:refs/heads/angstrom-v2014.06-socfpga


# ------------------- meta-altera -------------------------
cd /home/atull/repos/internal/meta-altera

git push origin rel_angstrom-v2012.12-yocto1.3_14.07.01:refs/tags/rel_angstrom-v2012.12-yocto1.3_14.07.01
git push portal rel_angstrom-v2012.12-yocto1.3_14.07.01:refs/tags/rel_angstrom-v2012.12-yocto1.3_14.07.01
git push portal rel_angstrom-v2012.12-yocto1.3_14.07.01:refs/heads/angstrom-v2012.12-yocto1.3

echo 88ccd0fbd3516adf131b8c0e92d3cabbfab2abfb
git push origin rel_angstrom-v2013.12-yocto1.5_14.07.01:refs/tags/rel_angstrom-v2013.12-yocto1.5_14.07.01
git push portal rel_angstrom-v2013.12-yocto1.5_14.07.01:refs/tags/rel_angstrom-v2013.12-yocto1.5_14.07.01
git push portal rel_angstrom-v2013.12-yocto1.5_14.07.01:refs/heads/angstrom-v2013.12-yocto1.5

echo cbf58fc9d7df88fcb6ec6db9aa109533bf180d5e
git push origin rel_angstrom-v2014.06-yocto1.6_14.07.01:refs/tags/rel_angstrom-v2014.06-yocto1.6_14.07.01
git push portal rel_angstrom-v2014.06-yocto1.6_14.07.01:refs/tags/rel_angstrom-v2014.06-yocto1.6_14.07.01
git push portal rel_angstrom-v2014.06-yocto1.6_14.07.01:refs/heads/angstrom-v2014.06-yocto1.6


