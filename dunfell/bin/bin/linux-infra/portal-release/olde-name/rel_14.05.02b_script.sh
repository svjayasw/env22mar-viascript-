#/bin/bash -ex

# ------------------- linux-socfpga -------------------------
cd /home/atull/repos/internal/linux-socfpga

git tag -f rel_socfpga-3.10-ltsi-rt_14.05.02 origin/socfpga-3.10-ltsi-rt
git describe origin/socfpga-3.10-ltsi-rt
git describe rel_socfpga-3.10-ltsi-rt_14.05.02
sleep 2

git push origin rel_socfpga-3.10-ltsi-rt_14.05.02:refs/tags/rel_socfpga-3.10-ltsi-rt_14.05.02
git push portal rel_socfpga-3.10-ltsi-rt_14.05.02:refs/tags/rel_socfpga-3.10-ltsi-rt_14.05.02
git push portal rel_socfpga-3.10-ltsi-rt_14.05.02:refs/heads/socfpga-3.10-ltsi-rt


