#/bin/bash -ex

# ------------------- linux-socfpga -------------------------
cd /home/atull/repos/internal/linux-socfpga

git push origin rel_socfpga-3.13_14.03.02:refs/tags/rel_socfpga-3.13_14.03.02
git push portal rel_socfpga-3.13_14.03.02:refs/tags/rel_socfpga-3.13_14.03.02
git push portal rel_socfpga-3.13_14.03.02:refs/heads/socfpga-3.13

git push origin rel_socfpga-3.10-ltsi_14.03.02:refs/tags/rel_socfpga-3.10-ltsi_14.03.02
git push portal rel_socfpga-3.10-ltsi_14.03.02:refs/tags/rel_socfpga-3.10-ltsi_14.03.02
git push portal rel_socfpga-3.10-ltsi_14.03.02:refs/heads/socfpga-3.10-ltsi


# ------------------- uboot-socfpga -------------------------
cd /home/atull/repos/internal/uboot-socfpga

git push origin rel_socfpga_v2013.01.01_14.03.02:refs/tags/rel_socfpga_v2013.01.01_14.03.02
git push portal rel_socfpga_v2013.01.01_14.03.02:refs/tags/rel_socfpga_v2013.01.01_14.03.02
git push portal rel_socfpga_v2013.01.01_14.03.02:refs/heads/socfpga_v2013.01.01

#git push origin rel_socfpga_v2013.01.01-rel-amp_14.03.02:refs/tags/rel_socfpga_v2013.01.01-rel-amp_14.03.02
#git push portal rel_socfpga_v2013.01.01-rel-amp_14.03.02:refs/tags/rel_socfpga_v2013.01.01-rel-amp_14.03.02
#git push portal rel_socfpga_v2013.01.01-rel-amp_14.03.02:refs/heads/socfpga_v2013.01.01-rel-amp


# ------------------- poky -------------------------
#cd /home/atull/repos/internal/poky

#git push origin rel_danny-altera-rel-amp_14.03.02:refs/tags/rel_danny-altera-rel-amp_14.03.02
#git push portal rel_danny-altera-rel-amp_14.03.02:refs/tags/rel_danny-altera-rel-amp_14.03.02
#git push portal rel_danny-altera-rel-amp_14.03.02:refs/heads/danny-altera-rel-amp


