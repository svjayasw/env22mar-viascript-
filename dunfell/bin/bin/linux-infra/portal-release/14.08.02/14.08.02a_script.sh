#/bin/bash -ex

# ------------------- linux-socfpga -------------------------
cd /home/atull/repos/internal/linux-socfpga

git push origin rel_socfpga-3.15_14.08.02:refs/tags/rel_socfpga-3.15_14.08.02
git push portal rel_socfpga-3.15_14.08.02:refs/tags/rel_socfpga-3.15_14.08.02
git push portal rel_socfpga-3.15_14.08.02:refs/heads/socfpga-3.15

echo a3a81b05580dd2342768cc05899e590114ba8f37
git push origin rel_socfpga-3.10-ltsi_14.08.02:refs/tags/rel_socfpga-3.10-ltsi_14.08.02
git push portal rel_socfpga-3.10-ltsi_14.08.02:refs/tags/rel_socfpga-3.10-ltsi_14.08.02
git push portal rel_socfpga-3.10-ltsi_14.08.02:refs/heads/socfpga-3.10-ltsi

echo 6cd4f82d805176e7f117276c0f26fc717c566d95
git push origin rel_socfpga-3.10-ltsi-rt_14.08.02:refs/tags/rel_socfpga-3.10-ltsi-rt_14.08.02
git push portal rel_socfpga-3.10-ltsi-rt_14.08.02:refs/tags/rel_socfpga-3.10-ltsi-rt_14.08.02
git push portal rel_socfpga-3.10-ltsi-rt_14.08.02:refs/heads/socfpga-3.10-ltsi-rt


# ------------------- uboot-socfpga -------------------------
cd /home/atull/repos/internal/uboot-socfpga

echo fe010493a1754e761f77ba19243ba93a9d038443
git push origin rel_socfpga_v2013.01.01_14.08.02:refs/tags/rel_socfpga_v2013.01.01_14.08.02
git push portal rel_socfpga_v2013.01.01_14.08.02:refs/tags/rel_socfpga_v2013.01.01_14.08.02
git push portal rel_socfpga_v2013.01.01_14.08.02:refs/heads/socfpga_v2013.01.01


# ------------------- poky -------------------------
cd /home/atull/repos/internal/poky

git push origin rel_danny-altera_14.08.02:refs/tags/rel_danny-altera_14.08.02
git push portal rel_danny-altera_14.08.02:refs/tags/rel_danny-altera_14.08.02
git push portal rel_danny-altera_14.08.02:refs/heads/danny-altera


# ------------------- angstrom-socfpga -------------------------
cd /home/atull/repos/internal/angstrom-socfpga

git push origin rel_angstrom-v2012.12-socfpga_14.08.02:refs/tags/rel_angstrom-v2012.12-socfpga_14.08.02
git push portal rel_angstrom-v2012.12-socfpga_14.08.02:refs/tags/rel_angstrom-v2012.12-socfpga_14.08.02
git push portal rel_angstrom-v2012.12-socfpga_14.08.02:refs/heads/angstrom-v2012.12-socfpga

git push origin rel_angstrom-v2013.12-socfpga_14.08.02:refs/tags/rel_angstrom-v2013.12-socfpga_14.08.02
git push portal rel_angstrom-v2013.12-socfpga_14.08.02:refs/tags/rel_angstrom-v2013.12-socfpga_14.08.02
git push portal rel_angstrom-v2013.12-socfpga_14.08.02:refs/heads/angstrom-v2013.12-socfpga

git push origin rel_angstrom-v2014.06-socfpga_14.08.02:refs/tags/rel_angstrom-v2014.06-socfpga_14.08.02
git push portal rel_angstrom-v2014.06-socfpga_14.08.02:refs/tags/rel_angstrom-v2014.06-socfpga_14.08.02
git push portal rel_angstrom-v2014.06-socfpga_14.08.02:refs/heads/angstrom-v2014.06-socfpga


# ------------------- meta-altera -------------------------
cd /home/atull/repos/internal/meta-altera

git push origin rel_angstrom-v2012.12-yocto1.3_14.08.02:refs/tags/rel_angstrom-v2012.12-yocto1.3_14.08.02
git push portal rel_angstrom-v2012.12-yocto1.3_14.08.02:refs/tags/rel_angstrom-v2012.12-yocto1.3_14.08.02
git push portal rel_angstrom-v2012.12-yocto1.3_14.08.02:refs/heads/angstrom-v2012.12-yocto1.3

echo a7724b697d730a5c640069f875f0d0d5e1ae24d9
git push origin rel_angstrom-v2013.12-yocto1.5_14.08.02:refs/tags/rel_angstrom-v2013.12-yocto1.5_14.08.02
git push portal rel_angstrom-v2013.12-yocto1.5_14.08.02:refs/tags/rel_angstrom-v2013.12-yocto1.5_14.08.02
git push portal rel_angstrom-v2013.12-yocto1.5_14.08.02:refs/heads/angstrom-v2013.12-yocto1.5

git push origin rel_angstrom-v2014.06-yocto1.6_14.08.02:refs/tags/rel_angstrom-v2014.06-yocto1.6_14.08.02
git push portal rel_angstrom-v2014.06-yocto1.6_14.08.02:refs/tags/rel_angstrom-v2014.06-yocto1.6_14.08.02
git push portal rel_angstrom-v2014.06-yocto1.6_14.08.02:refs/heads/angstrom-v2014.06-yocto1.6

