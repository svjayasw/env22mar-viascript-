#!/bin/bash -ex
# This script copies rcN tags to rcN+1 tags in local git
#

cd /home/atull/repos/internal/linux-socfpga
git tag rel_socfpga-3.18_15.03.01_rc3 rel_socfpga-3.18_15.03.01_rc2
echo

git tag rel_socfpga-3.10-ltsi_15.03.01_rc3 rel_socfpga-3.10-ltsi_15.03.01_rc2
echo

git tag rel_socfpga-3.10-ltsi-rt_15.03.01_rc3 rel_socfpga-3.10-ltsi-rt_15.03.01_rc2
echo


cd /home/atull/repos/internal/uboot-socfpga
git tag rel_socfpga_v2013.01.01_15.03.01_rc3 rel_socfpga_v2013.01.01_15.03.01_rc2
echo


cd /home/atull/repos/internal/poky
git tag rel_danny-altera_15.03.01_rc3 rel_danny-altera_15.03.01_rc2
echo


cd /home/atull/repos/internal/angstrom-socfpga
git tag rel_angstrom-v2012.12-socfpga_15.03.01_rc3 rel_angstrom-v2012.12-socfpga_15.03.01_rc2
echo

git tag rel_angstrom-v2013.12-socfpga_15.03.01_rc3 rel_angstrom-v2013.12-socfpga_15.03.01_rc2
echo

git tag rel_angstrom-v2014.06-socfpga_15.03.01_rc3 rel_angstrom-v2014.06-socfpga_15.03.01_rc2
echo

git tag rel_angstrom-v2014.12-socfpga_15.03.01_rc3 rel_angstrom-v2014.12-socfpga_15.03.01_rc2
echo


cd /home/atull/repos/internal/meta-altera
git tag rel_angstrom-v2012.12-yocto1.3_15.03.01_rc3 rel_angstrom-v2012.12-yocto1.3_15.03.01_rc2
echo

git tag rel_angstrom-v2013.12-yocto1.5_15.03.01_rc3 rel_angstrom-v2013.12-yocto1.5_15.03.01_rc2
echo

git tag rel_angstrom-v2014.06-yocto1.6_15.03.01_rc3 rel_angstrom-v2014.06-yocto1.6_15.03.01_rc2
echo

git tag rel_angstrom-v2014.12-yocto1.7_15.03.01_rc3 rel_angstrom-v2014.12-yocto1.7_15.03.01_rc2
echo

git tag rel_angstrom-v2014.12-yocto1.7_a10_15.03.01_rc3 rel_angstrom-v2014.12-yocto1.7_a10_15.03.01_rc2
echo


cd /home/atull/repos/internal/linux-test
git tag rel_master_15.03.01_rc3 rel_master_15.03.01_rc2
echo


cd /home/atull/repos/internal/linux-infra
git tag rel_updated_nightly_15.03.01_rc3 rel_updated_nightly_15.03.01_rc2
echo

