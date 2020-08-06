#/bin/bash -ex

# ------------------- linux-socfpga -------------------------
cd /home/atull/repos/internal/linux-socfpga

git push origin rel_socfpga-3.14_14.05.03:refs/tags/rel_socfpga-3.14_14.05.03
git push portal rel_socfpga-3.14_14.05.03:refs/tags/rel_socfpga-3.14_14.05.03
git push portal rel_socfpga-3.14_14.05.03:refs/heads/socfpga-3.14

git push origin rel_socfpga-3.10-ltsi_14.05.03:refs/tags/rel_socfpga-3.10-ltsi_14.05.03
git push portal rel_socfpga-3.10-ltsi_14.05.03:refs/tags/rel_socfpga-3.10-ltsi_14.05.03
git push portal rel_socfpga-3.10-ltsi_14.05.03:refs/heads/socfpga-3.10-ltsi

git push origin rel_socfpga-3.10-ltsi-rt_14.05.03:refs/tags/rel_socfpga-3.10-ltsi-rt_14.05.03
git push portal rel_socfpga-3.10-ltsi-rt_14.05.03:refs/tags/rel_socfpga-3.10-ltsi-rt_14.05.03
git push portal rel_socfpga-3.10-ltsi-rt_14.05.03:refs/heads/socfpga-3.10-ltsi-rt


# ------------------- uboot-socfpga -------------------------
cd /home/atull/repos/internal/uboot-socfpga

git push origin rel_socfpga_v2013.01.01_14.05.03:refs/tags/rel_socfpga_v2013.01.01_14.05.03
git push portal rel_socfpga_v2013.01.01_14.05.03:refs/tags/rel_socfpga_v2013.01.01_14.05.03
git push portal rel_socfpga_v2013.01.01_14.05.03:refs/heads/socfpga_v2013.01.01


