#/bin/bash -ex

# ------------------- linux-socfpga -------------------------
cd /home/atull/repos/internal/linux-socfpga

git push portal rel_socfpga-3.16_14.09.02:refs/tags/rel_socfpga-3.16_14.09.02
git push portal rel_socfpga-3.16_14.09.02:refs/heads/socfpga-3.16

echo 96c4077ae475640f2a6234b29192f34a05471264
git push portal rel_socfpga-3.10-ltsi_14.09.02:refs/tags/rel_socfpga-3.10-ltsi_14.09.02
git push portal rel_socfpga-3.10-ltsi_14.09.02:refs/heads/socfpga-3.10-ltsi

echo 2db6cf80b26737313534e6592ec7160cc76cc41c
git push portal rel_socfpga-3.10-ltsi-rt_14.09.02:refs/tags/rel_socfpga-3.10-ltsi-rt_14.09.02
git push portal rel_socfpga-3.10-ltsi-rt_14.09.02:refs/heads/socfpga-3.10-ltsi-rt


# ------------------- uboot-socfpga -------------------------
cd /home/atull/repos/internal/uboot-socfpga

echo 890e22efc69956237fc19baa75962db11df6e10e
git push portal rel_socfpga_v2013.01.01_14.09.02:refs/tags/rel_socfpga_v2013.01.01_14.09.02
git push portal rel_socfpga_v2013.01.01_14.09.02:refs/heads/socfpga_v2013.01.01


# ------------------- poky -------------------------
cd /home/atull/repos/internal/poky

git push portal rel_danny-altera_14.09.02:refs/tags/rel_danny-altera_14.09.02
git push portal rel_danny-altera_14.09.02:refs/heads/danny-altera


# ------------------- angstrom-socfpga -------------------------
cd /home/atull/repos/internal/angstrom-socfpga

git push portal rel_angstrom-v2012.12-socfpga_14.09.02:refs/tags/rel_angstrom-v2012.12-socfpga_14.09.02
git push portal rel_angstrom-v2012.12-socfpga_14.09.02:refs/heads/angstrom-v2012.12-socfpga

git push portal rel_angstrom-v2013.12-socfpga_14.09.02:refs/tags/rel_angstrom-v2013.12-socfpga_14.09.02
git push portal rel_angstrom-v2013.12-socfpga_14.09.02:refs/heads/angstrom-v2013.12-socfpga

git push portal rel_angstrom-v2014.06-socfpga_14.09.02:refs/tags/rel_angstrom-v2014.06-socfpga_14.09.02
git push portal rel_angstrom-v2014.06-socfpga_14.09.02:refs/heads/angstrom-v2014.06-socfpga


# ------------------- meta-altera -------------------------
cd /home/atull/repos/internal/meta-altera

git push portal rel_angstrom-v2012.12-yocto1.3_14.09.02:refs/tags/rel_angstrom-v2012.12-yocto1.3_14.09.02
git push portal rel_angstrom-v2012.12-yocto1.3_14.09.02:refs/heads/angstrom-v2012.12-yocto1.3

echo d536811edb414cd85778eaf8fbec9ad0fc480ab1
git push portal rel_angstrom-v2013.12-yocto1.5_14.09.02:refs/tags/rel_angstrom-v2013.12-yocto1.5_14.09.02
git push portal rel_angstrom-v2013.12-yocto1.5_14.09.02:refs/heads/angstrom-v2013.12-yocto1.5

git push portal rel_angstrom-v2014.06-yocto1.6_14.09.02:refs/tags/rel_angstrom-v2014.06-yocto1.6_14.09.02
git push portal rel_angstrom-v2014.06-yocto1.6_14.09.02:refs/heads/angstrom-v2014.06-yocto1.6

