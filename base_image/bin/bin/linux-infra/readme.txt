======================
linux-infra readme.txt
======================

This repo contains infrastructure for the PSG Linux team.

==========================
Directories of linux-infra
==========================

 * auto			= scripting for the git crontab sync job
 * drivers		= driver source code for the serial interface of the hammerhead devkit (no longer used)
 * hooks		= git hooks that are used on at-git
 * nightlybuild		= nightly build scripting
 * portal-release	= portal update logs, including both ACDS and biweekly Linux updates
 * release		= old release stuff from 2012-2013 when we did auto-self-extracting release files
 * repo-settings	= settings for hooks and review-commits for each git repository
 * tools		= scripts used by the team

============================
Documentation in linux-infra
============================

 * readme.txt			= this file
 * auto/readme.txt		= notes on the git sync job
 * repo-settings/readme.txt	= notes on repo-settings
 * hooks/readme.txt		= notes about the hooks scripts
 * hooks/readme-portal.txt	= notes about setting up gitolite on the old old portal server (out of date)
 * tools/readme.txt		= how to install this repo on your linux host properly
 * tools/portal-update-doc.txt	= policies and howto regarding the portal update scripts

=====================================
Useful scripts (in linux-infra/tools)
=====================================

 * gbls		= list git branches in reverse order of top commit.  'gbls -h' has help.
		  very useful if you have a lot of local branches

 * ack		= print out signoff lines such "Acked-by: (your name and email from your gitconfig file)"

==========================================
Special mention - the glo suite of scripts
==========================================

 'glo' stands for 'git log'.  These are handy scripts that give one line per commit logs,
       but more useful info than 'git log --oneline'

 glo = gives sha, date, author, subject such as
   $ glo -3
   7c1e31d 2019-04-09 14:58:41 -0500 : Thor Thayer : ARM: dts: socfpga: Fix SDRAM node address for Arria10
   21ae082 2019-04-09 14:56:58 -0500 : Dinh Nguyen : ARM: dts: socfpga: add timer resets for SoCFPGA platform
   b3971b1 2019-04-09 14:53:56 -0500 : Dinh Nguyen : clocksource/drivers/dw_apb: Add reset control

 glos = includes --stat info

 glog = give numbered commits such as
   $ glog -5
   socfpga-4.14.73-ltsi
   05/05 : f5160f4 : Dinh Nguyen : net: stmmac: socfpga: add RMII phy mode
   04/05 : 1f0a719 : Dinh Nguyen : ARM: dts: arria10: Add EMAC OCP reset property
   03/05 : b5ef098 : Alan Tull : ARM: dts: socfpga: add ltc2497 on arria10 devkit
   02/05 : e5db34d : Alan Tull : ARM: socfpga_defconfig: enable LTC2497
   01/05 : 0d1cf88 : Dinh Nguyen : ARM: dts: socfpga: update missing reset property peripherals

 glon = number down such as:
   $ glon
   0 f5160f4 2019-05-15 10:01:51 -0500 : Dinh Nguyen : net: stmmac: socfpga: add RMII phy mode
   1 1f0a719 2019-05-13 11:11:12 -0500 : Dinh Nguyen : ARM: dts: arria10: Add EMAC OCP reset property
   2 b5ef098 2019-04-29 15:58:52 -0500 : Alan Tull : ARM: dts: socfpga: add ltc2497 on arria10 devkit
   3 e5db34d 2019-04-29 15:58:47 -0500 : Alan Tull : ARM: socfpga_defconfig: enable LTC2497

 glor = list all branches on all remotes

 gloabbrev = Useful when you are writing a commit message that needs to refer to another commit.
   $ gloabbrev HEAD
   Commit f5160f45e3c4 ("net: stmmac: socfpga: add RMII phy mode")
