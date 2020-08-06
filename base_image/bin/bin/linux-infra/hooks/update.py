#!/usr/bin/env python
#
# git update hook
# 
# Copyright (C) 2012 Alan Tull

import os
import sys
import tempfile
import subprocess

# imports from this project
from GitReceivePack import GitReceivePack
from HooksUtils import *
from TestCommits import *
sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'tools'))
from git_utils import *

# verbose level 0, 1, 2, 3
verbose = 1

def test_branch_commit(gitrp, status):
    print
    print "branch name   :", gitrp.branch_name
    print "describe      :", gitrp.describe
    print "branch_base   :", gitrp.branch_base
    test_commits(gitrp.commits, gitrp.repo_name, status)
    print
        
def test_branch_create(gitrp, status):
    print "create branch :", gitrp.branch_name
       
def test_branch_delete(gitrp, status):
    print "delete branch :", gitrp.branch_name

def test_branches(gitrp, status):
    print "branch        :", gitrp.branch_name

    if gitrp.newrev_type == 'commit':
        test_branch_commit(gitrp, status)
    elif gitrp.newrev_type == 'create':
        test_branch_create(gitrp, status)
    elif gitrp.newrev_type == 'delete':
        test_branch_delete(gitrp, status)
    else:
        # We should not get here
        print "branch        :", gitrp.branch_name
        print 'newrev_type not supported: ', gitrp.newrev_type
        status.fail()

#---------------------------------------------------------------------------

# *** In the future, if we ever start testing tags, make sure that sync_repo.sh can push tags.
def test_tag_create(gitrp, status):
    print "create tag    :", gitrp.tag_name
        
def test_tag_delete(gitrp, status):
    print "delete tag    :", gitrp.tag_name

def test_tags(gitrp, status):
    if gitrp.newrev_type == 'create':
        test_tag_create(gitrp, status)
    elif gitrp.newrev_type == 'delete':
        test_tag_delete(gitrp, status)
    else:
        # We should not get here
        print "tag           :", gitrp.tag_name
        print 'Tag newrev_type not supported: ', gitrp.newrev_type
        status.fail()

#========================================================================

git = git_utils()
status = test_status()

# Allow all pushes from the sync job script to the upstream branch
refname = sys.argv[1]
refs_path = refname.split('/')[1]

if refs_path == 'heads':
    upstream_branches = get_repo_setting(git.repo_name(), 'upstream_branches')

    branch_name = refname.split('/')[2]

    for upregex in upstream_branches:
        if re.match(re.compile(upregex), branch_name):
            print 'Allowing push to upstream branch %s' % branch_name
            exit(0)

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

if gitrp.refs_path == 'heads':
    test_branches(gitrp, status)
elif gitrp.refs_path == 'tags':
    test_tags(gitrp, status)
else:
    # Fall through in case the above didn't catch it.
    print 'ref is not a head or a tag, not supported: ', gitrp.refs_path
    print "update.py denied!!!"
    status.fail()
    
if status.is_good():
    print "allowed"
    exit(0)

print "denied"
exit(1)
