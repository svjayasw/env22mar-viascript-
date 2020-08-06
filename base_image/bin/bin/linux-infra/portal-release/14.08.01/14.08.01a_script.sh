#/bin/bash -ex

# ------------------- linux-socfpga -------------------------
cd /home/atull/repos/internal/linux-socfpga

echo 25deacde98fd5771e5e3ffee008113d0bea56180
git push origin rel_socfpga-3.15_14.08.01:refs/tags/rel_socfpga-3.15_14.08.01
git push portal rel_socfpga-3.15_14.08.01:refs/tags/rel_socfpga-3.15_14.08.01
git push portal rel_socfpga-3.15_14.08.01:refs/heads/socfpga-3.15

echo 3c9c2baa8b74ea3834503ce7df899325c3bd4303
git push origin rel_socfpga-3.10-ltsi_14.08.01:refs/tags/rel_socfpga-3.10-ltsi_14.08.01
git push portal rel_socfpga-3.10-ltsi_14.08.01:refs/tags/rel_socfpga-3.10-ltsi_14.08.01
git push portal rel_socfpga-3.10-ltsi_14.08.01:refs/heads/socfpga-3.10-ltsi

echo dfe62c07571b3ef37034c0ebd2910847288a904b
git push origin rel_socfpga-3.10-ltsi-rt_14.08.01:refs/tags/rel_socfpga-3.10-ltsi-rt_14.08.01
git push portal rel_socfpga-3.10-ltsi-rt_14.08.01:refs/tags/rel_socfpga-3.10-ltsi-rt_14.08.01
git push portal rel_socfpga-3.10-ltsi-rt_14.08.01:refs/heads/socfpga-3.10-ltsi-rt


# ------------------- uboot-socfpga -------------------------
cd /home/atull/repos/internal/uboot-socfpga

git push origin rel_socfpga_v2013.01.01_14.08.01:refs/tags/rel_socfpga_v2013.01.01_14.08.01
git push portal rel_socfpga_v2013.01.01_14.08.01:refs/tags/rel_socfpga_v2013.01.01_14.08.01
git push portal rel_socfpga_v2013.01.01_14.08.01:refs/heads/socfpga_v2013.01.01


# ------------------- poky -------------------------
cd /home/atull/repos/internal/poky

git push origin rel_danny-altera_14.08.01:refs/tags/rel_danny-altera_14.08.01
git push portal rel_danny-altera_14.08.01:refs/tags/rel_danny-altera_14.08.01
git push portal rel_danny-altera_14.08.01:refs/heads/danny-altera


# ------------------- angstrom-socfpga -------------------------
cd /home/atull/repos/internal/angstrom-socfpga

git push origin rel_angstrom-v2012.12-socfpga_14.08.01:refs/tags/rel_angstrom-v2012.12-socfpga_14.08.01
git push portal rel_angstrom-v2012.12-socfpga_14.08.01:refs/tags/rel_angstrom-v2012.12-socfpga_14.08.01
git push portal rel_angstrom-v2012.12-socfpga_14.08.01:refs/heads/angstrom-v2012.12-socfpga

git push origin rel_angstrom-v2013.12-socfpga_14.08.01:refs/tags/rel_angstrom-v2013.12-socfpga_14.08.01
git push portal rel_angstrom-v2013.12-socfpga_14.08.01:refs/tags/rel_angstrom-v2013.12-socfpga_14.08.01
git push portal rel_angstrom-v2013.12-socfpga_14.08.01:refs/heads/angstrom-v2013.12-socfpga

git push origin rel_angstrom-v2014.06-socfpga_14.08.01:refs/tags/rel_angstrom-v2014.06-socfpga_14.08.01
git push portal rel_angstrom-v2014.06-socfpga_14.08.01:refs/tags/rel_angstrom-v2014.06-socfpga_14.08.01
git push portal rel_angstrom-v2014.06-socfpga_14.08.01:refs/heads/angstrom-v2014.06-socfpga


# ------------------- meta-altera -------------------------
cd /home/atull/repos/internal/meta-altera

git push origin rel_angstrom-v2012.12-yocto1.3_14.08.01:refs/tags/rel_angstrom-v2012.12-yocto1.3_14.08.01
git push portal rel_angstrom-v2012.12-yocto1.3_14.08.01:refs/tags/rel_angstrom-v2012.12-yocto1.3_14.08.01
git push portal rel_angstrom-v2012.12-yocto1.3_14.08.01:refs/heads/angstrom-v2012.12-yocto1.3

echo 4f25637302c4713325271298c11c2ade3956f190
git push origin rel_angstrom-v2013.12-yocto1.5_14.08.01:refs/tags/rel_angstrom-v2013.12-yocto1.5_14.08.01
git push portal rel_angstrom-v2013.12-yocto1.5_14.08.01:refs/tags/rel_angstrom-v2013.12-yocto1.5_14.08.01
git push portal rel_angstrom-v2013.12-yocto1.5_14.08.01:refs/heads/angstrom-v2013.12-yocto1.5

git push origin rel_angstrom-v2014.06-yocto1.6_14.08.01:refs/tags/rel_angstrom-v2014.06-yocto1.6_14.08.01
git push portal rel_angstrom-v2014.06-yocto1.6_14.08.01:refs/tags/rel_angstrom-v2014.06-yocto1.6_14.08.01
git push portal rel_angstrom-v2014.06-yocto1.6_14.08.01:refs/heads/angstrom-v2014.06-yocto1.6

