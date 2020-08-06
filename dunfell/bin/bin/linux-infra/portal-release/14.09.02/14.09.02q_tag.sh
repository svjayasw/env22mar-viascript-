#/bin/bash -ex

# ------------------- linux-socfpga -------------------------
cd /home/atull/repos/internal/linux-socfpga

git push origin rel_socfpga-3.16_14.09.02:refs/tags/rel_socfpga-3.16_14.09.02

echo 96c4077ae475640f2a6234b29192f34a05471264
git push origin rel_socfpga-3.10-ltsi_14.09.02:refs/tags/rel_socfpga-3.10-ltsi_14.09.02

echo 2db6cf80b26737313534e6592ec7160cc76cc41c
git push origin rel_socfpga-3.10-ltsi-rt_14.09.02:refs/tags/rel_socfpga-3.10-ltsi-rt_14.09.02


# ------------------- uboot-socfpga -------------------------
cd /home/atull/repos/internal/uboot-socfpga

echo 890e22efc69956237fc19baa75962db11df6e10e
git push origin rel_socfpga_v2013.01.01_14.09.02:refs/tags/rel_socfpga_v2013.01.01_14.09.02


# ------------------- poky -------------------------
cd /home/atull/repos/internal/poky

git push origin rel_danny-altera_14.09.02:refs/tags/rel_danny-altera_14.09.02


# ------------------- angstrom-socfpga -------------------------
cd /home/atull/repos/internal/angstrom-socfpga

git push origin rel_angstrom-v2012.12-socfpga_14.09.02:refs/tags/rel_angstrom-v2012.12-socfpga_14.09.02

git push origin rel_angstrom-v2013.12-socfpga_14.09.02:refs/tags/rel_angstrom-v2013.12-socfpga_14.09.02

git push origin rel_angstrom-v2014.06-socfpga_14.09.02:refs/tags/rel_angstrom-v2014.06-socfpga_14.09.02


# ------------------- meta-altera -------------------------
cd /home/atull/repos/internal/meta-altera

git push origin rel_angstrom-v2012.12-yocto1.3_14.09.02:refs/tags/rel_angstrom-v2012.12-yocto1.3_14.09.02

echo d536811edb414cd85778eaf8fbec9ad0fc480ab1
git push origin rel_angstrom-v2013.12-yocto1.5_14.09.02:refs/tags/rel_angstrom-v2013.12-yocto1.5_14.09.02

git push origin rel_angstrom-v2014.06-yocto1.6_14.09.02:refs/tags/rel_angstrom-v2014.06-yocto1.6_14.09.02

