#!/bin/bash -ex
# pushes them to internal and RBO git
#

cd /home/atull/repos/internal/linux-socfpga
git push portal rel_socfpga-3.16_14.10.01_pr:refs/heads/socfpga-3.16
git push portal rel_socfpga-3.10-ltsi_14.10.01_pr:refs/heads/socfpga-3.10-ltsi
git push portal rel_socfpga-3.10-ltsi-rt_14.10.01_pr:refs/heads/socfpga-3.10-ltsi-rt

cd /home/atull/repos/internal/uboot-socfpga
git push portal rel_socfpga_v2013.01.01_14.10.01_pr:refs/heads/socfpga_v2013.01.01

cd /home/atull/repos/internal/poky
git push portal rel_danny-altera_14.10.01_pr:refs/heads/danny-altera

cd /home/atull/repos/internal/angstrom-socfpga
git push portal rel_angstrom-v2012.12-socfpga_14.10.01_pr:refs/heads/angstrom-v2012.12-socfpga
git push portal rel_angstrom-v2013.12-socfpga_14.10.01_pr:refs/heads/angstrom-v2013.12-socfpga
git push portal rel_angstrom-v2014.06-socfpga_14.10.01_pr:refs/heads/angstrom-v2014.06-socfpga

cd /home/atull/repos/internal/meta-altera
git push portal rel_angstrom-v2012.12-yocto1.3_14.10.01_pr:refs/heads/angstrom-v2012.12-yocto1.3
git push portal rel_angstrom-v2013.12-yocto1.5_14.10.01_pr:refs/heads/angstrom-v2013.12-yocto1.5
git push portal rel_angstrom-v2014.06-yocto1.6_14.10.01_pr:refs/heads/angstrom-v2014.06-yocto1.6

