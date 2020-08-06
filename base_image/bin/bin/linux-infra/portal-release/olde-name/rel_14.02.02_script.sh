#/bin/bash -ex

# ------------------- linux-socfpga -------------------------
cd /home/atull/repos/internal/linux-socfpga

git push portal origin/master:refs/heads/master

git push origin rel_socfpga-3.13_14.02.02:refs/tags/rel_socfpga-3.13_14.02.02
git push portal rel_socfpga-3.13_14.02.02:refs/tags/rel_socfpga-3.13_14.02.02
git push portal rel_socfpga-3.13_14.02.02:refs/heads/socfpga-3.13

git push origin rel_socfpga-3.9-rel_14.02.02:refs/tags/rel_socfpga-3.9-rel_14.02.02
git push portal rel_socfpga-3.9-rel_14.02.02:refs/tags/rel_socfpga-3.9-rel_14.02.02
git push portal rel_socfpga-3.9-rel_14.02.02:refs/heads/socfpga-3.9-rel


# ------------------- uboot-socfpga -------------------------
cd /home/atull/repos/internal/uboot-socfpga

git push portal origin/master:refs/heads/master

git push origin rel_socfpga_v2013.01.01_14.02.02:refs/tags/rel_socfpga_v2013.01.01_14.02.02
git push portal rel_socfpga_v2013.01.01_14.02.02:refs/tags/rel_socfpga_v2013.01.01_14.02.02
git push portal rel_socfpga_v2013.01.01_14.02.02:refs/heads/socfpga_v2013.01.01

git push origin rel_socfpga_v2013.01.01-rel_14.02.02:refs/tags/rel_socfpga_v2013.01.01-rel_14.02.02
git push portal rel_socfpga_v2013.01.01-rel_14.02.02:refs/tags/rel_socfpga_v2013.01.01-rel_14.02.02
git push portal rel_socfpga_v2013.01.01-rel_14.02.02:refs/heads/socfpga_v2013.01.01-rel


