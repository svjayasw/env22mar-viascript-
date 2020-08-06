----------------------------------
Open source project automated sync
----------------------------------

opensource repos typically have an upstream project.  This automated
cronjob wakes up a couple of times a day to do the following:
 * Fetch from the upstream git repo
 * Push to our git repos (at-git and github) to update their 'master' branch
 * Push upstream tags to our git repos also
 * Note that this is the general case and some repos need something different
   from the above.

========
Location
========

Currently located in /home/atull/syncjob on linuxheads98
The rest of this document will assume this is in the mainatiner's home dir,
so using '~/syncjob' instead of '/home/atull/syncjob'

==============
Code structure
==============

 * ~/syncjob/		The directory that contains the automated syncjob. This
			path is hardcoded in the crontab (crontab has to have
			absolute paths). linux-infra is cloned here.
 * ~/syncjob/repos/	Contains a directory per project which contain cloned
			git repos.  The directory names are the preface to the
			names of the *-sync scripts, i.e armstrong directory and
			armstrong-sync script.
 * ~/syncjob/olde/	Contains archived sync logs in datestamped directories.

All the scripting is in ~/syncjob/linux-infra/auto/:

 * sync-cronjob		File used to configure cron.  This sets the times
			to run the scripts.
 * *-sync		Scripts that are called by the cronjob to sync each
			project repo.  Each project may have different sync
			needs, these scripts contain that customization.
 * sync_repo_common.sh	Common code, including scripts to do git fetch,
			git branch push, git tag pushes.  This is sourced
			by each of the *-sync scripts and not called directly
			by the cronjob.
 * logrotate.sh		Saves off the logs in datestamped directories in
			~/syncjob/olde/
 * manual-sync.sh	Run this script to manually sync up a repo
 * health-report.sh	Check for cronjob failures, send an email once a day
 * removed-projects/	Old sync jobs that have been removed from the cron job
 * monitor-public-events.sh  Script to monitor the unauthorized clone of our
			github for any changes.This is really not part of the
			sync job, but is here since it's run by the same crontab.

======================
To install the cronjob
======================

  cd ~
  mkdir syncjob
  cd syncjob
  git clone gitolite@at-git.intel.com:linux-infra.git

run once by hand and watch for wierdnesses:
  $ cd ~/syncjob/linux-infra/auto
  (run each of the *-sync scripts by hand once, such as)
  $ ./angstrom-sync

If that succeeds, set up crontab by doing:
  $ crontab cronjob-sync

=============================
Switching or adding git hosts
=============================

If we switch or add git hosts that we are pushing to, ssh on the machine
that is running the cronjob will need the chance to add the new git host
to is known-hosts list.  Until that happens, these scripts will probably
hang at that point waiting for the user to type 'yes'

============
Maintainence
============

The logs get rotated out and saved once in a while.  To do that manually:
 $ cd ~/syncjob
 $ ./linux-infra/auto/logrotate.sh -f

The health report script will wake up and send an email of any issues it
sees.  Once the cronjob is set up and running, usually it just work except
for temporary network glitches.  Sometimes the upstream changes where it
is hosted and that can of course cause a failure that needs the url updated
in the scripting.

If the health report email reports errors, do a manual run to see
if the situation has cleared up.  Note that you will need to do a
manual logrotate or the health-report.sh script will keep finding
the errors you already know about:

  cd ~/syncjob/linux-infra/auto/
  ./logrotate.sh -f
  ./manual-sync.sh --all
  (watch for errors)
  ./health-report.sh
