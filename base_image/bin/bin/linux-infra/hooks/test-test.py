#!/usr/bin/env python
#
# Run tests by hand - for hooks development only

import os
import sys
import tempfile
import subprocess

# imports from this project
from GitReceivePack import GitReceivePack
from HooksUtils import *
from TestPatch import TestPatch
from TestFile import TestFile
from TestHeader import TestHeader
from TestCommits import *
sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'tools'))
from git_utils import *

verbose = 1

#======================================================================

#def run_test(commits, repo_name, status, update_tests):

#======================================================================

git = git_utils()
status = test_status()

refname = sys.argv[1]
refs_path = refname.split('/')[1]

update_tests = ['copyright_year']

# refname, oldrev, newrev
gitrp = GitReceivePack(sys.argv[1], sys.argv[2], sys.argv[3], verbose)

# For development purposes, dump information on what got pushed:
print "refname       :", gitrp.refname
print "oldrev        :", gitrp.oldrev
print "newrev        :", gitrp.newrev
print
print "repo          :", gitrp.repo_name
print "# of commits  :", len(gitrp.commits)
print "refs path     :", gitrp.refs_path
print "newrev_type   :", gitrp.newrev_type
print

if gitrp.refs_path != 'heads' or gitrp.newrev_type != 'commit':
    print "This test script only handles pushes to refs/heads/... for now"
    exit(1)

print "branch name   :", gitrp.branch_name
print "describe      :", gitrp.describe
print "branch_base   :", gitrp.branch_base
print
print "update_tests  :", update_tests

run_update_tests(gitrp.commits, gitrp.repo_name, status, update_tests)
