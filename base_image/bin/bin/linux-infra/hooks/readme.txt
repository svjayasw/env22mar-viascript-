=========
Git Hooks
=========

The git hooks run in addition to the gitolite hooks.  They do not replace the gitolite hooks.

========
Location
========

 * /usr/share/gitolite/hooks/common/ ==  where the gitolite hooks are

 * /usr/local/git/linux-infra/hooks/ ==  where the additional python hooks are

 * The /usr/share/gitolite/hooks/common/update.secondary hook will run all the hooks
   in the /usr/share/gitolite/hooks/common/update.secondary.d/ directory.

 * IMPORTANT NOTE: You *must* disable your editor from creating backup files.  Because
   when the update.secondary runs, it will run both update.secondary.d/lala and update.secondary.d/lala~
   for example.  Think about the effects...

=================================
Documentation of our custom hooks
=================================

 * update_safe
   * This is the entry point from gitolite.  It is a small BASH wrapper for update.py.
     Currently it exits with code 0 in most cases, allowing git pushes to happen normally.
 * update.py
   * This is the update hook
 * GitReceivePack.py
   * This is a python class which gets all the information about an attempted push.
   * The idea is that tests can be run using this information. It is sort of expensive
     to get the information, so we want to get it only once and let multiple tests use it.
 * HooksUtils.py
   * The utilites used by the python hooks
 * TestFile.py
   * Runs tests on whole files, not just the submitted patch.
 * TestPatch.py
   * Runs tests on the content (code) in a patch.
 * TestHeader.py
   * Runs tests on the commit headers.

================================================
order in which the hooks scripts call each other
================================================

Flow for branch pushes:
    gitolite's /usr/share/gitolite/hooks/common/update.secondary
    update_safe
    update.py (creates GitReceivePack object)
    Branches.py
      uses functions in TestFile.py, TestPatch.py, TestHeader.py
      TestPatch.py uses testpatch.pl from the kernel.

Flow for tag pushes:
    gitolite's /usr/share/gitolite/hooks/common/update.secondary
    update_safe
    update.py (creates GitReceivePack object)
    Tags.py

Flow after commit has been accepted (if it's accepted):
    gitolite's /usr/share/gitolite/hooks/common/post-receive
    post-receive
    kickoff
    post-receive-email

========================
updating hooks on at-git
========================

Hooks on at-git will need to be updated if either:
 * the hooks scripts in linux-infra/hooks changes
 * the repo settings in linux-infra/repo-settings changes
Neither of these happens often.

How to update the hooks:
 * Make sure all your changes are pushed to linux-infra master branch
 * Log onto at-git:
   * ssh at-git
 * change to gitolite user
   * [alan@at-git ~]$ sudo su - gitolite
     (you will need sudo access from Mark Christian to do this)
 * update linux-infra
   * cd linux-infra
   * tag the current hooks in case you need to revert back.  Edit the following
     command with the current date
     * git tag HAPPY_20190612
   * git fetch origin
   * git reset --hard origin/master

How to revert the hooks if needed:
 * Log onto at-git:
   * ssh at-git
 * change to gitolite user
   * [alan@at-git ~]$ sudo su - gitolite
     (you will need sudo access from Mark Christian to do this)
 * revert linux-infra
   * cd linux-infra
   * git reset --hard HAPPY_20190617


============================
Setting up on the git server
============================

*** You should never have to do this, unless you are rebuilding the git server. ***

 * Clone linux-infra on the git server:
   $ ssh at-git
   $ sudo su - gitolite
   $ cd /usr/local/git
   $ git clone --local --no-hardlinks /usr/local/git/repositories/linux-infra.git
   * Exit such that you are no longer the gitolite user.

 * Set up hooks scripts
   $ cd /usr/share/gitolite/hooks/common

   # Enable the 'secondary' update script
   $ sudo mv update.secondary.sample update.secondary
   $ sudo chmod 755 update.secondary

   # Set up the bash 'update_safe' wrapper that points to linux-infra
   $ sudo mkdir update.secondary.d
   $ sudo ln -s /usr/local/git/linux-infra/hooks/update_safe /usr/share/gitolite/hooks/common/update.secondary.d/update_safe

   # Enable post-receive-email,
   $ sudo ln -s /usr/local/git/linux-infra/hooks/post-receive-email post-receive

   # Enable post_update hook
   $ sudo cp /usr/local/git/linux-infra/.git/hooks/post-update.sample .
   $ sudo mv post-update.sample post-update

   # Run gl-setup to activate the hooks for gitolite
   $ sudo su - gitolite
   $ cd ~/.gitolite/hooks/common/
   $ gl-setup
   * Exit such that you are no longer the gitolite user.

 * If you need to clean up any unused hooks or cruft that gets linked:
   1. *Carefully* delete it from the /usr/local/git/repositories/*/hooks/ directories first!
   2. delete it from ~/.gitolite/hooks/common
