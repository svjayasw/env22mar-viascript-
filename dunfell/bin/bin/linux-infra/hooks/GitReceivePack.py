#!/usr/bin/env python
#
# Copyright (C) 2012 Alan Tull
#
# class GitReceivePack
#     An object of class GitReceivePack can be created in a git update
#     hook, using the parameters that git gives.
#     It can then be passed to test modules to determine whether
#     the git repo should accept the push.

import os
import sys
import tempfile
import re
# We would like to use subprocess.check_output, but Python ver. 2.6 doesn't have it.
from subprocess import Popen, call, PIPE

# imports from this project
sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'tools'))
from git_utils import *


class GitReceivePack:
    """The GitReceivePack class contains information about a push to
      a git repository:
    refname, oldrev, newrev = update parameters from git
    repo                    = the repo that was pushed to
    repo_name               = repo name without most of the path or '.git'
    refs_path               = heads, tags, or remotes
    newrev_type             = commit, tag, or delete
    branch_name             = name of branch that was pushed
    tag_name                = name of tag that was pushed
    describe                = git describe of branch/tag
    branch_base             = base annotated tag of branch
    commits[]               = commit objects"""
    def __init__(self, refname, oldrev, newrev, verbose):
        if (refname == '') or (oldrev == '') or (newrev == ''):
            print "Scripting Error: one of the args was NULL"
            exit(1)

        self.refname = refname
        self.oldrev = oldrev
        self.newrev = newrev
        self.verbose = verbose

        self.commits = []

        self.newrev_type = ""
        self.refs_path = ""

        self.describe = ""
        self.branch_base = ""
        self.branch_name = ""
        self.tag_name = ""

        # repo object of the repository receiving the push
        repo = Repo(os.getcwd())
        self.repo = repo
        self.repo_name = repo.repo_name
        git = repo.git
        self.git = git

        # newrev_type will be 'delete', 'commit', or 'tag' (annotated tag)
        # if $newrev is 0000...0000, it's a commit to delete a ref.
        if is_null_hash(newrev):
            self.newrev_type = "delete"
        elif is_null_hash(oldrev):
            self.newrev_type = "create"
        else:
            self.newrev_type = git.cat_file('-t', newrev)

        if self.newrev_type == '':
            print 'Error: unknown newrev_type for newrev ', newrev
            exit(1)

        try:
            self.describe = git.describe(self.newrev)
            self.branch_base = self.describe.split('-')[0]
        except Exception:
            self.describe = ""
            self.branch_base = ""

        # 'tags', 'heads', or 'remotes'
        self.refs_path = refname.split('/')[1]

        self.update_type = self.refs_path + "-" + self.newrev_type

        print "update type    : %s" % self.update_type

        # Deleting a branch
        if self.update_type == 'heads-delete':
            self.branch_name = refname.split('/')[2]
            hash_str = oldrev
            hashes = hash_str.split()

        # Creating a branch
        elif self.update_type == 'heads-create':
            self.branch_name = refname.split('/')[2]
            hash_str = newrev
            hashes = hash_str.split()
            for hash in hashes:
                self.commits.append(Commit(repo, hash))

        # Normal commit, pushing to an existing branch.
        elif self.update_type == 'heads-commit':
            self.branch_name = refname.split('/')[2]
            hash_str = git.log_of_hashes(oldrev, newrev)
            hashes = hash_str.split()
            for hash in hashes:
                self.commits.append(Commit(repo, hash))

        # Deleting a tag.  Each tag is a separate call to update
        elif self.update_type == 'tags-delete':
            self.tag_name = refname.split('/')[2]
            hash_str = oldrev
            hashes = hash_str.split()

        # Creating a tag.  Each tag is a separate call to update
        elif self.update_type == 'tags-create':
            self.tag_name = refname.split('/')[2]
            hash_str = newrev
            hashes = hash_str.split()

        else:
            print "This update type currently unsupported by hooks."
            exit(1)
