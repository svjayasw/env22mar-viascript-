#/bin/bash -ex

# ------------------- linux-socfpga -------------------------
cd /home/atull/repos/internal/linux-socfpga

echo 734deeb63fffad4cd78564cca65a2912daf0a31b
git push origin rel_socfpga-3.15_14.07.02:refs/tags/rel_socfpga-3.15_14.07.02
git push portal rel_socfpga-3.15_14.07.02:refs/tags/rel_socfpga-3.15_14.07.02
git push portal rel_socfpga-3.15_14.07.02:refs/heads/socfpga-3.15

echo 78002dcddc9735fcff039f760c2d5b2a3221b678
git push origin rel_socfpga-3.10-ltsi_14.07.02:refs/tags/rel_socfpga-3.10-ltsi_14.07.02
git push portal rel_socfpga-3.10-ltsi_14.07.02:refs/tags/rel_socfpga-3.10-ltsi_14.07.02
git push portal rel_socfpga-3.10-ltsi_14.07.02:refs/heads/socfpga-3.10-ltsi

git push origin rel_socfpga-3.10-ltsi-rt_14.07.02:refs/tags/rel_socfpga-3.10-ltsi-rt_14.07.02
git push portal rel_socfpga-3.10-ltsi-rt_14.07.02:refs/tags/rel_socfpga-3.10-ltsi-rt_14.07.02
git push portal rel_socfpga-3.10-ltsi-rt_14.07.02:refs/heads/socfpga-3.10-ltsi-rt


# ------------------- uboot-socfpga -------------------------
cd /home/atull/repos/internal/uboot-socfpga

git push origin rel_socfpga_v2013.01.01_14.07.02:refs/tags/rel_socfpga_v2013.01.01_14.07.02
git push portal rel_socfpga_v2013.01.01_14.07.02:refs/tags/rel_socfpga_v2013.01.01_14.07.02
git push portal rel_socfpga_v2013.01.01_14.07.02:refs/heads/socfpga_v2013.01.01


# ------------------- poky -------------------------
cd /home/atull/repos/internal/poky

git push origin rel_danny-altera_14.07.02:refs/tags/rel_danny-altera_14.07.02
git push portal rel_danny-altera_14.07.02:refs/tags/rel_danny-altera_14.07.02
git push portal rel_danny-altera_14.07.02:refs/heads/danny-altera


# ------------------- angstrom-socfpga -------------------------
cd /home/atull/repos/internal/angstrom-socfpga

git push origin rel_angstrom-v2012.12-socfpga_14.07.02:refs/tags/rel_angstrom-v2012.12-socfpga_14.07.02
git push portal rel_angstrom-v2012.12-socfpga_14.07.02:refs/tags/rel_angstrom-v2012.12-socfpga_14.07.02
git push portal rel_angstrom-v2012.12-socfpga_14.07.02:refs/heads/angstrom-v2012.12-socfpga

git push origin rel_angstrom-v2013.12-socfpga_14.07.02:refs/tags/rel_angstrom-v2013.12-socfpga_14.07.02
git push portal rel_angstrom-v2013.12-socfpga_14.07.02:refs/tags/rel_angstrom-v2013.12-socfpga_14.07.02
git push portal rel_angstrom-v2013.12-socfpga_14.07.02:refs/heads/angstrom-v2013.12-socfpga

git push origin rel_angstrom-v2014.06-socfpga_14.07.02:refs/tags/rel_angstrom-v2014.06-socfpga_14.07.02
git push portal rel_angstrom-v2014.06-socfpga_14.07.02:refs/tags/rel_angstrom-v2014.06-socfpga_14.07.02
git push portal rel_angstrom-v2014.06-socfpga_14.07.02:refs/heads/angstrom-v2014.06-socfpga


# ------------------- meta-altera -------------------------
cd /home/atull/repos/internal/meta-altera

echo b16478f2ddd65afa7821b1937885dfb96eff266f
git push origin rel_angstrom-v2012.12-yocto1.3_14.07.02:refs/tags/rel_angstrom-v2012.12-yocto1.3_14.07.02
git push portal rel_angstrom-v2012.12-yocto1.3_14.07.02:refs/tags/rel_angstrom-v2012.12-yocto1.3_14.07.02
git push portal rel_angstrom-v2012.12-yocto1.3_14.07.02:refs/heads/angstrom-v2012.12-yocto1.3

echo 62fe00848b43c6f9860861e17e5aa61af996c5a8
git push origin rel_angstrom-v2013.12-yocto1.5_14.07.02:refs/tags/rel_angstrom-v2013.12-yocto1.5_14.07.02
git push portal rel_angstrom-v2013.12-yocto1.5_14.07.02:refs/tags/rel_angstrom-v2013.12-yocto1.5_14.07.02
git push portal rel_angstrom-v2013.12-yocto1.5_14.07.02:refs/heads/angstrom-v2013.12-yocto1.5

echo 9fe06573ef9f9a3b284edc66d590cb32b67a2f00
git push origin rel_angstrom-v2014.06-yocto1.6_14.07.02:refs/tags/rel_angstrom-v2014.06-yocto1.6_14.07.02
git push portal rel_angstrom-v2014.06-yocto1.6_14.07.02:refs/tags/rel_angstrom-v2014.06-yocto1.6_14.07.02
git push portal rel_angstrom-v2014.06-yocto1.6_14.07.02:refs/heads/angstrom-v2014.06-yocto1.6


