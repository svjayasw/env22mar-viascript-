#!/bin/bash -e

# ACDS15.0.1_REL_GSRD_RC1

cd ~/repos/internal/meta-altera
pwd
git log -1 --pretty=format:'%h %an : %s' ACDS15.0.1_REL_GSRD_RC1
git push portal ACDS15.0.1_REL_GSRD_RC1:refs/tags/ACDS15.0.1_REL_GSRD_RC1
# push to new branch
git push portal ACDS15.0.1_REL_GSRD_RC1:refs/heads/angstrom-v2014.12-yocto1.7_gsrd15.0.1
echo

cd ~/repos/internal/linux-socfpga
pwd
git log -1 --pretty=format:'%h %an : %s' ACDS15.0.1_REL_GSRD_RC1
git push portal ACDS15.0.1_REL_GSRD_RC1:refs/tags/ACDS15.0.1_REL_GSRD_RC1
# current head
git push portal ACDS15.0.1_REL_GSRD_RC1:refs/heads/socfpga-3.10-ltsi
echo

cd ~/repos/internal/linux-refdesigns
pwd
git log -1 --pretty=format:'%h %an : %s' ACDS15.0.1_REL_GSRD_RC1
git push portal ACDS15.0.1_REL_GSRD_RC1:refs/tags/ACDS15.0.1_REL_GSRD_RC1
# push to new branch
git push portal ACDS15.0.1_REL_GSRD_RC1:refs/heads/socfpga-15.0.1
echo

cd ~/repos/internal/angstrom-socfpga
pwd
git log -1 --pretty=format:'%h %an : %s' ACDS15.0.1_REL_GSRD_RC1
git push portal ACDS15.0.1_REL_GSRD_RC1:refs/tags/ACDS15.0.1_REL_GSRD_RC1
# push to new branch
git push portal ACDS15.0.1_REL_GSRD_RC1:refs/heads/angstrom-v2014.12-socfpga_gsrd15.0.1
echo

cd ~/repos/internal/meta-altera-refdes
pwd
git log -1 --pretty=format:'%h %an : %s' ACDS15.0.1_REL_GSRD_RC1
git push portal ACDS15.0.1_REL_GSRD_RC1:refs/tags/ACDS15.0.1_REL_GSRD_RC1
# push to new branch
git push portal ACDS15.0.1_REL_GSRD_RC1:refs/heads/gsrd-15.0.1
