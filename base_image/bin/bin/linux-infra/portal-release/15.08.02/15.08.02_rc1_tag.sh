#!/bin/bash -ex
# This script tags the local git tree with rc1 tag and pushes to internal git
#

cd /home/atull/repos/internal/linux-socfpga
git tag rel_socfpga-4.1_15.08.02_rc1 60fd5d498abedaee238effc63af806453bd87836
git push origin rel_socfpga-4.1_15.08.02_rc1:refs/tags/rel_socfpga-4.1_15.08.02_rc1
echo

git tag rel_socfpga-3.10-ltsi_15.08.02_rc1 8418e933ae4b227af04718bc9a6d9fb42dc8afca
git push origin rel_socfpga-3.10-ltsi_15.08.02_rc1:refs/tags/rel_socfpga-3.10-ltsi_15.08.02_rc1
echo

git tag rel_socfpga-3.10-ltsi-rt_15.08.02_rc1 8a34ee1d8d4d64ae7bf20f7c5104b3cb3f28fe9a
git push origin rel_socfpga-3.10-ltsi-rt_15.08.02_rc1:refs/tags/rel_socfpga-3.10-ltsi-rt_15.08.02_rc1
echo


cd /home/atull/repos/internal/uboot-socfpga
git tag rel_socfpga_v2013.01.01_15.08.02_rc1 353283b6e75eabdcc48dadf08507b4b86c229d78
git push origin rel_socfpga_v2013.01.01_15.08.02_rc1:refs/tags/rel_socfpga_v2013.01.01_15.08.02_rc1
echo

git tag rel_socfpga_v2014.10_arria10_bringup_15.08.02_rc1 2ffbb7d6e8a5967b682da642b996069415fe43a7
git push origin rel_socfpga_v2014.10_arria10_bringup_15.08.02_rc1:refs/tags/rel_socfpga_v2014.10_arria10_bringup_15.08.02_rc1
echo


cd /home/atull/repos/internal/angstrom-socfpga
git tag rel_angstrom-v2014.12-socfpga_15.08.02_rc1 7e781b1650493f4ec3121b599132c8f8c367d7e7
git push origin rel_angstrom-v2014.12-socfpga_15.08.02_rc1:refs/tags/rel_angstrom-v2014.12-socfpga_15.08.02_rc1
echo


cd /home/atull/repos/internal/meta-altera
git tag rel_angstrom-v2014.12-yocto1.7_15.08.02_rc1 8aaa263431c1c75653d4d93c12ccd6984cd4f084
git push origin rel_angstrom-v2014.12-yocto1.7_15.08.02_rc1:refs/tags/rel_angstrom-v2014.12-yocto1.7_15.08.02_rc1
echo

git tag rel_angstrom-v2014.12-yocto1.7_a10_15.08.02_rc1 d58b31190428328e703ed2bcc148b31c49caa670
git push origin rel_angstrom-v2014.12-yocto1.7_a10_15.08.02_rc1:refs/tags/rel_angstrom-v2014.12-yocto1.7_a10_15.08.02_rc1
echo


cd /home/atull/repos/internal/linux-tags
git tag rel_master_15.08.02_rc1 dafce3c9ccfa8160323175f0940deb35d3e675dd
git push origin rel_master_15.08.02_rc1:refs/tags/rel_master_15.08.02_rc1
git push origin rel_master_15.08.02_rc1:refs/heads/master
