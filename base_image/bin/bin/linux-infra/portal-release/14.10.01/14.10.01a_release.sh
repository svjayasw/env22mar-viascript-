#/bin/bash -ex

# ------------------- linux-socfpga -------------------------
cd /home/atull/repos/internal/linux-socfpga

git push portal 73b8057eedd623269600b233f82d4378631dba8c:refs/tags/rel_socfpga-3.16_14.10.01
git push portal 73b8057eedd623269600b233f82d4378631dba8c:refs/heads/socfpga-3.16

git push portal 8beef1b8853317a29df139ca4bb71c03c55227c1:refs/tags/rel_socfpga-3.10-ltsi_14.10.01
git push portal 8beef1b8853317a29df139ca4bb71c03c55227c1:refs/heads/socfpga-3.10-ltsi

git push portal 37a12476091c71bfe7b023dae534424437116e64:refs/tags/rel_socfpga-3.10-ltsi-rt_14.10.01
git push portal 37a12476091c71bfe7b023dae534424437116e64:refs/heads/socfpga-3.10-ltsi-rt


# ------------------- uboot-socfpga -------------------------
cd /home/atull/repos/internal/uboot-socfpga

git push portal 890e22efc69956237fc19baa75962db11df6e10e:refs/tags/rel_socfpga_v2013.01.01_14.10.01
git push portal 890e22efc69956237fc19baa75962db11df6e10e:refs/heads/socfpga_v2013.01.01


# ------------------- poky -------------------------
cd /home/atull/repos/internal/poky

git push portal 2ea11347bbdbdab3b5d9bb7a4157f9b7b5607a23:refs/tags/rel_danny-altera_14.10.01
git push portal 2ea11347bbdbdab3b5d9bb7a4157f9b7b5607a23:refs/heads/danny-altera


# ------------------- angstrom-socfpga -------------------------
cd /home/atull/repos/internal/angstrom-socfpga

git push portal a7411013b0d87ac0a4596b09a0c19f868e21b667:refs/tags/rel_angstrom-v2012.12-socfpga_14.10.01
git push portal a7411013b0d87ac0a4596b09a0c19f868e21b667:refs/heads/angstrom-v2012.12-socfpga

git push portal 86e17311d05ed87f48f296061200e1b4b05a30b7:refs/tags/rel_angstrom-v2013.12-socfpga_14.10.01
git push portal 86e17311d05ed87f48f296061200e1b4b05a30b7:refs/heads/angstrom-v2013.12-socfpga

git push portal 4460560c5cada124a6da2ae9306305abcf5f2040:refs/tags/rel_angstrom-v2014.06-socfpga_14.10.01
git push portal 4460560c5cada124a6da2ae9306305abcf5f2040:refs/heads/angstrom-v2014.06-socfpga


# ------------------- meta-altera -------------------------
cd /home/atull/repos/internal/meta-altera

git push portal b16478f2ddd65afa7821b1937885dfb96eff266f:refs/tags/rel_angstrom-v2012.12-yocto1.3_14.10.01
git push portal b16478f2ddd65afa7821b1937885dfb96eff266f:refs/heads/angstrom-v2012.12-yocto1.3

git push portal d536811edb414cd85778eaf8fbec9ad0fc480ab1:refs/tags/rel_angstrom-v2013.12-yocto1.5_14.10.01
git push portal d536811edb414cd85778eaf8fbec9ad0fc480ab1:refs/heads/angstrom-v2013.12-yocto1.5

git push portal 9fe06573ef9f9a3b284edc66d590cb32b67a2f00:refs/tags/rel_angstrom-v2014.06-yocto1.6_14.10.01
git push portal 9fe06573ef9f9a3b284edc66d590cb32b67a2f00:refs/heads/angstrom-v2014.06-yocto1.6

