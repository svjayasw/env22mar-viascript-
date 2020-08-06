#/bin/bash -ex

# ------------------- linux-socfpga -------------------------
cd /home/atull/repos/internal/linux-socfpga

git push origin rel_socfpga-3.13_14.03.01:refs/tags/rel_socfpga-3.13_14.03.01
git push portal rel_socfpga-3.13_14.03.01:refs/tags/rel_socfpga-3.13_14.03.01
git push portal rel_socfpga-3.13_14.03.01:refs/heads/socfpga-3.13


# ------------------- uboot-socfpga -------------------------
cd /home/atull/repos/internal/uboot-socfpga

git push origin rel_socfpga_v2013.01.01_14.03.01:refs/tags/rel_socfpga_v2013.01.01_14.03.01
git push portal rel_socfpga_v2013.01.01_14.03.01:refs/tags/rel_socfpga_v2013.01.01_14.03.01
git push portal rel_socfpga_v2013.01.01_14.03.01:refs/heads/socfpga_v2013.01.01


