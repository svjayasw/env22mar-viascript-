#!/bin/bash -ex
# This script copies rcN tags to rcN+1 tags in local git,
# pushes them to internal and external git
#
# We wanted to tag these branches and not push out the A10 PR support
# for two weeks.



cd /home/atull/repos/internal/linux-socfpga

# 9d08aba 2016-06-16 16:58:14 -0500 : Alan Tull : FogBugz #365525-4: socfpga: dts: add remaining fpga bridges
git tag -f rel_socfpga-4.6_16.06.02_pr 9d08aba

# 48a39ae 2016-06-16 16:59:34 -0500 : Alan Tull : FogBugz #365525-4: socfpga: dts: add remaining fpga bridges
git tag -f rel_socfpga-4.1.22-ltsi_16.06.02_pr 48a39ae

# 0e938a8 2016-06-16 17:02:49 -0500 : Alan Tull : FogBugz #365525-4: socfpga: dts: add remaining fpga bridges
git tag -f rel_socfpga-4.1.22-ltsi-rt_16.06.02_pr 0e938a8


git push -f origin :refs/tags/rel_socfpga-4.6_16.06.02_pr
git push -f origin rel_socfpga-4.6_16.06.02_pr:refs/tags/rel_socfpga-4.6_16.06.02_pr
echo

git push -f portal rel_socfpga-4.6_16.06.02_pr:refs/heads/socfpga-4.6
git push -f portal rel_socfpga-4.6_16.06.02_pr:refs/tags/rel_socfpga-4.6_16.06.02_pr
echo

git push -f origin rel_socfpga-4.1.22-ltsi_16.06.02_pr:refs/tags/rel_socfpga-4.1.22-ltsi_16.06.02_pr
echo

git push -f portal rel_socfpga-4.1.22-ltsi_16.06.02_pr:refs/heads/socfpga-4.1.22-ltsi
git push -f portal rel_socfpga-4.1.22-ltsi_16.06.02_pr:refs/tags/rel_socfpga-4.1.22-ltsi_16.06.02_pr
echo

git push -f origin rel_socfpga-4.1.22-ltsi-rt_16.06.02_pr:refs/tags/rel_socfpga-4.1.22-ltsi-rt_16.06.02_pr
echo

git push -f portal rel_socfpga-4.1.22-ltsi-rt_16.06.02_pr:refs/heads/socfpga-4.1.22-ltsi-rt
git push -f portal rel_socfpga-4.1.22-ltsi-rt_16.06.02_pr:refs/tags/rel_socfpga-4.1.22-ltsi-rt_16.06.02_pr
echo

