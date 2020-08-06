#/bin/bash -ex

# ------------------- linux-socfpga -------------------------
cd /home/atull/repos/internal/linux-socfpga

git push origin 73b8057eedd623269600b233f82d4378631dba8c:refs/tags/rel_socfpga-3.16_14.10.01

git push origin 8beef1b8853317a29df139ca4bb71c03c55227c1:refs/tags/rel_socfpga-3.10-ltsi_14.10.01

git push origin 37a12476091c71bfe7b023dae534424437116e64:refs/tags/rel_socfpga-3.10-ltsi-rt_14.10.01


# ------------------- uboot-socfpga -------------------------
cd /home/atull/repos/internal/uboot-socfpga

git push origin 890e22efc69956237fc19baa75962db11df6e10e:refs/tags/rel_socfpga_v2013.01.01_14.10.01


# ------------------- poky -------------------------
cd /home/atull/repos/internal/poky

git push origin 2ea11347bbdbdab3b5d9bb7a4157f9b7b5607a23:refs/tags/rel_danny-altera_14.10.01


# ------------------- angstrom-socfpga -------------------------
cd /home/atull/repos/internal/angstrom-socfpga

git push origin a7411013b0d87ac0a4596b09a0c19f868e21b667:refs/tags/rel_angstrom-v2012.12-socfpga_14.10.01

git push origin 86e17311d05ed87f48f296061200e1b4b05a30b7:refs/tags/rel_angstrom-v2013.12-socfpga_14.10.01

git push origin 4460560c5cada124a6da2ae9306305abcf5f2040:refs/tags/rel_angstrom-v2014.06-socfpga_14.10.01


# ------------------- meta-altera -------------------------
cd /home/atull/repos/internal/meta-altera

git push origin b16478f2ddd65afa7821b1937885dfb96eff266f:refs/tags/rel_angstrom-v2012.12-yocto1.3_14.10.01

git push origin d536811edb414cd85778eaf8fbec9ad0fc480ab1:refs/tags/rel_angstrom-v2013.12-yocto1.5_14.10.01

git push origin 9fe06573ef9f9a3b284edc66d590cb32b67a2f00:refs/tags/rel_angstrom-v2014.06-yocto1.6_14.10.01


# ------------------- linux-test -------------------------
cd /home/atull/repos/internal/linux-test

git push origin 6752c00d38ea7cca61f178b9d4d2e5fd9c096b4c:refs/tags/rel_master_14.10.01


# ------------------- linux-infra -------------------------
cd /home/atull/repos/internal/linux-infra

git push origin 0551b6170588be6d7281cf8cdd530295118c3435:refs/tags/rel_tags_v1_14.10.01


# ------------------- linux-tags -------------------------
cd /home/atull/repos/internal/linux-tags

git push origin c5d4ec2c387788a71305f801ddc54f5bd9f0e0b6:refs/tags/rel_master_14.10.01

git push origin c5d4ec2c387788a71305f801ddc54f5bd9f0e0b6:refs/heads/master

