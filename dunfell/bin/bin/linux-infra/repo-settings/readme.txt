====================
repo-settings readme
====================

Definitions of the settings in the repo-settings files and what scripts use these settings.

repo-settings files are used by:
 * linux-infra/hooks
 * linux-infra/tools/review-commits
 * linux-infra/tools/portal-update.py

email:
 * list of email address to send post-receive-emails to.

local_upstream: linux-socfpga
 * name of the Altera git repository that this code will eventually go to
   after developemnt is done and it is cleaned up.  So when we do code 
   reviews, that repo's 'update_tests' get run on the code by review-commits.
   However we don't run those tests on the server.  So fixing at that time is optional.

repo_path: /usr/local/git/repositories/linux-devtree.git
 * path where repo is located on the git server

sync-job: linux
 * We had a crontab that syncs from upstream. Can be linux, uboot, sopc2dts, etc.

update_tests:
 * tests that the update hooks should run before accepting commits.
   * = allow commit with no testing (noop).
   * checkpatch = run checkpatch.pl and refuse if there are errors.  warnings are ok.
   * copyright_year = check that copyright year is correct
   * doscrlfs = check for dos cr/lf line endings.
   * header = check that patch header is the right format
   * license_gplv2_approved = check for the Legal department approved GPLv2 header
   * license_linux_kernel_gplv2 = another GPLv2 header test
   * license_spdx_bsdv2_clause = check for SPDX BSDv2 license line
   * nomerge = ensure there are no merge commits

crucible_project:
 * name of project in crucible associated with this repo.  This is how review-commits
   knows which Crucible project to post a review to.

release_branch:
 * used by nightly build scripts

internal_git:
 * url to git repo on at-git. Used by portal-update.py

external_git:
 * url to git repo on github. Used by portal-update.py

upstream_branches:
 * used by hooks to know which branches could be updated (receive pushes) without
   a FogBugz or HSD# (such as the linux kernel's master branch)

upstream_tag_regex:
 * Appears to not be used.  Was intended to be a regex pattern for which
   tags would be accepted by the hooks, but apparantly not currently implemented.

review_addrs:
 * Used by review-commits.  Who to email reviews to when reviews are done by email
   rather than Crucible.
