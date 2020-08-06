#!/bin/bash -ex
# pushes them to internal and RBO git
#

cd /home/atull/repos/internal/linux-socfpga
git push portal :refs/tags/socfpga-3.16
git push portal :refs/tags/socfpga-3.10-ltsi
git push portal :refs/tags/socfpga-3.10-ltsi-rt

cd /home/atull/repos/internal/uboot-socfpga
git push portal :refs/tags/socfpga_v2013.01.01

cd /home/atull/repos/internal/poky
git push portal :refs/tags/danny-altera

cd /home/atull/repos/internal/angstrom-socfpga
git push portal :refs/tags/angstrom-v2012.12-socfpga
git push portal :refs/tags/angstrom-v2013.12-socfpga
git push portal :refs/tags/angstrom-v2014.06-socfpga

cd /home/atull/repos/internal/meta-altera
git push portal :refs/tags/angstrom-v2012.12-yocto1.3
git push portal :refs/tags/angstrom-v2013.12-yocto1.5
git push portal :refs/tags/angstrom-v2014.06-yocto1.6

