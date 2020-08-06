#/bin/bash -ex

# ------------------- linux-socfpga -------------------------
cd /home/atull/repos/internal/linux-socfpga

echo 9aefe9edc66e7f658df94749966cc8a5defe7e26
git push origin rel_socfpga-3.15_14.09.01:refs/tags/rel_socfpga-3.15_14.09.01
git push portal rel_socfpga-3.15_14.09.01:refs/tags/rel_socfpga-3.15_14.09.01
git push portal rel_socfpga-3.15_14.09.01:refs/heads/socfpga-3.15

echo 4b124f5314b336384454c9a22abf85e01715be66
git push origin rel_socfpga-3.10-ltsi_14.09.01:refs/tags/rel_socfpga-3.10-ltsi_14.09.01
git push portal rel_socfpga-3.10-ltsi_14.09.01:refs/tags/rel_socfpga-3.10-ltsi_14.09.01
#git push portal rel_socfpga-3.10-ltsi_14.09.01:refs/heads/socfpga-3.10-ltsi

echo 765dc3cafff7642c9c6fb4862129aea5eaf3c897
git push origin rel_socfpga-3.10-ltsi-rt_14.09.01:refs/tags/rel_socfpga-3.10-ltsi-rt_14.09.01
git push portal rel_socfpga-3.10-ltsi-rt_14.09.01:refs/tags/rel_socfpga-3.10-ltsi-rt_14.09.01
git push portal rel_socfpga-3.10-ltsi-rt_14.09.01:refs/heads/socfpga-3.10-ltsi-rt


# ------------------- uboot-socfpga -------------------------
cd /home/atull/repos/internal/uboot-socfpga

echo fcfc02e512294e905681af6e600b16bf67dea5c5
git push origin rel_socfpga_v2013.01.01_14.09.01:refs/tags/rel_socfpga_v2013.01.01_14.09.01
git push portal rel_socfpga_v2013.01.01_14.09.01:refs/tags/rel_socfpga_v2013.01.01_14.09.01
#git push portal rel_socfpga_v2013.01.01_14.09.01:refs/heads/socfpga_v2013.01.01


# ------------------- poky -------------------------
cd /home/atull/repos/internal/poky

git push origin rel_danny-altera_14.09.01:refs/tags/rel_danny-altera_14.09.01
git push portal rel_danny-altera_14.09.01:refs/tags/rel_danny-altera_14.09.01
git push portal rel_danny-altera_14.09.01:refs/heads/danny-altera


# ------------------- angstrom-socfpga -------------------------
cd /home/atull/repos/internal/angstrom-socfpga

git push origin rel_angstrom-v2012.12-socfpga_14.09.01:refs/tags/rel_angstrom-v2012.12-socfpga_14.09.01
git push portal rel_angstrom-v2012.12-socfpga_14.09.01:refs/tags/rel_angstrom-v2012.12-socfpga_14.09.01
git push portal rel_angstrom-v2012.12-socfpga_14.09.01:refs/heads/angstrom-v2012.12-socfpga

git push origin rel_angstrom-v2013.12-socfpga_14.09.01:refs/tags/rel_angstrom-v2013.12-socfpga_14.09.01
git push portal rel_angstrom-v2013.12-socfpga_14.09.01:refs/tags/rel_angstrom-v2013.12-socfpga_14.09.01
git push portal rel_angstrom-v2013.12-socfpga_14.09.01:refs/heads/angstrom-v2013.12-socfpga

git push origin rel_angstrom-v2014.06-socfpga_14.09.01:refs/tags/rel_angstrom-v2014.06-socfpga_14.09.01
git push portal rel_angstrom-v2014.06-socfpga_14.09.01:refs/tags/rel_angstrom-v2014.06-socfpga_14.09.01
git push portal rel_angstrom-v2014.06-socfpga_14.09.01:refs/heads/angstrom-v2014.06-socfpga


# ------------------- meta-altera -------------------------
cd /home/atull/repos/internal/meta-altera

git push origin rel_angstrom-v2012.12-yocto1.3_14.09.01:refs/tags/rel_angstrom-v2012.12-yocto1.3_14.09.01
git push portal rel_angstrom-v2012.12-yocto1.3_14.09.01:refs/tags/rel_angstrom-v2012.12-yocto1.3_14.09.01
#git push portal rel_angstrom-v2012.12-yocto1.3_14.09.01:refs/heads/angstrom-v2012.12-yocto1.3

echo 4c9cfd361e4926eef216fdb39da6288d9a491397
git push origin rel_angstrom-v2013.12-yocto1.5_14.09.01:refs/tags/rel_angstrom-v2013.12-yocto1.5_14.09.01
git push portal rel_angstrom-v2013.12-yocto1.5_14.09.01:refs/tags/rel_angstrom-v2013.12-yocto1.5_14.09.01
git push portal rel_angstrom-v2013.12-yocto1.5_14.09.01:refs/heads/angstrom-v2013.12-yocto1.5

git push origin rel_angstrom-v2014.06-yocto1.6_14.09.01:refs/tags/rel_angstrom-v2014.06-yocto1.6_14.09.01
git push portal rel_angstrom-v2014.06-yocto1.6_14.09.01:refs/tags/rel_angstrom-v2014.06-yocto1.6_14.09.01
git push portal rel_angstrom-v2014.06-yocto1.6_14.09.01:refs/heads/angstrom-v2014.06-yocto1.6

