#!/usr/bin/env python
#
# Common tests for git commits
# 
# Copyright (C) 2012 Alan Tull

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
sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'tools'))
from git_utils import *

def run_update_tests(commits, repo_name, status, update_tests):
    # Classes which have tests whose names correspond to words in the 'update_tests' repo-setting.
    test_classes = ( TestPatch(), TestFile(), TestHeader() )

    for commit in commits:
        for test in update_tests:
            for tclass in test_classes:
                # Get pointer to function whose name is in test, from the namespace in the test class
                method = getattr(tclass, test, None)
                if method:
                    break
            else:
                print 'Error in repo-settings/%s: update_test is %s which does not exist in Test*.py' % \
                    (repo_name, test)
                exit(1)

            # Run the test, mark the resulting failures in status object
            method(commit, status)
            status.print_status()

def test_commits(commits, repo_name, status):
    update_tests = get_repo_setting(repo_name, 'update_tests')
    print 'Running update_tests:', update_tests

    if update_tests == '':
        print "update_tests setting does not exist"
        return

    run_update_tests(commits, repo_name, status, update_tests)
