#!/usr/bin/env python
#
# Tests that are run on pushed patches
# 
# Copyright (C) 2012 Alan Tull atull@altera.com
#
# Patch tests:
#   checkpatch
# only needed for projects where we aren't running checkpatch:
#   doscrlfs
#   whitespace      = todo
#   forbidden words = todo

import os
import sys
import stat
import re
import string
import subprocess
from tempfile import NamedTemporaryFile

# imports from this project
from GitReceivePack import *
from HooksUtils import *
sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'tools'))
from git_utils import *

class TestPatch:
    def __init__(self):
        self.git = git_utils()
        self.checkpatch_pl_tmp = None
        self.spelling_txt_tmp = None
        self.const_structs_tmp = None

    # Note that this test runs on a bare repo on the git server.  When we run
    # the scripts that are checked into the repo under review, we have to 
    # extract the scripts that we are running.
    def setup_checkpatch(self, commit):
        '''Get checkpatch.pl from the repo that the review is running on.'''

        # *some* repos have spelling.txt, so extract it to /tmp
        spelling_txt = self.git.show(commit.hash + ':scripts/spelling.txt')
        if spelling_txt != '':
            sptmp = NamedTemporaryFile(delete=False, prefix="", suffix="spelling.txt")
            sptmp.write(spelling_txt)
            sptmp.close()
            self.spelling_txt_tmp = sptmp

        # *some* repos have const_structs.checkpatch, so extract it to /tmp
        const_structs = self.git.show(commit.hash + ':scripts/const_structs.checkpatch')
        if const_structs != '':
            cstmp = NamedTemporaryFile(delete=False, prefix="", suffix="const_structs.checkpatch")
            cstmp.write(const_structs)
            cstmp.close()
            self.const_structs_tmp = cstmp

        # need to check out checkpatch from repo since its a bare repo on the server.
        # u-boot : tools/checkpatch.pl
        # linux  : scripts/checkpatch.pl
        # qemu   : scripts/checkpatch.pl
        cp_script = ''
        cp_script = self.git.show(commit.hash + ':scripts/checkpatch.pl')
        if cp_script == '':
            cp_script = self.git.show(commit.hash + ':tools/checkpatch.pl')
            if cp_script == '':
                return False

        # Fix up the name 'spelling.txt' to whatever random name tempdir gave spelling.txt
        if self.spelling_txt_tmp != None:
            cp_script = string.replace(cp_script, 'spelling.txt',
                                       os.path.basename(self.spelling_txt_tmp.name))
        if self.const_structs_tmp != None:
            cp_script = string.replace(cp_script, 'const_structs.checkpatch',
                                       os.path.basename(self.const_structs_tmp.name))

        cptmp = NamedTemporaryFile(delete=False)
        cptmp.write(cp_script)
        cptmp.close()
        st = os.stat(cptmp.name)
        os.chmod(cptmp.name, st.st_mode | stat.S_IEXEC)
        self.checkpatch_pl_tmp = cptmp
        return True

    def cleanup_checkpatch(self):
        if self.checkpatch_pl_tmp != None:
            os.unlink(self.checkpatch_pl_tmp.name)
            self.checkpatch_pl_tmp = None
        if self.spelling_txt_tmp != None:
            os.unlink(self.spelling_txt_tmp.name)
            self.spelling_txt_tmp = None
        if self.const_structs_tmp != None:
            os.unlink(self.const_structs_tmp.name)
            self.const_structs_tmp = None

    def __checkpatch(self, commit, cpargs):
        # First, try to use ARC's 5.10.0 version of perl.  If that's not there, use default perl.
        perl_path = '/tools/perl/5.10/linux64/bin/perl'
        if not os.path.exists(perl_path):
            perl_path = '/usr/bin/perl'

        if not self.setup_checkpatch(commit):
            print 'This git repository does not have checkpatch.pl'
            return None

        try:
            cp_process = subprocess.Popen([perl_path, self.checkpatch_pl_tmp.name] + cpargs,
                                    stdin=subprocess.PIPE,
                                    stdout=subprocess.PIPE,
                                    stderr=subprocess.STDOUT,
                                    )

            patch = commit.patch()
            cp_stdout = cp_process.communicate(patch)[0]

        except:
            print 'we had an exxxxxxxxxxxxxxxxxxxxxxxxxception'
            self.cleanup_checkpatch()
            return None

        self.cleanup_checkpatch()
        return cp_stdout

    def checkpatch(self, commit, status):
        print
        print '================================================================='
        print 'Running checkpatch.pl on:'
        print '  %s %s' % (commit.shorthash, commit.subject)

        cp_stdout = self.__checkpatch(commit, ['--notree', '--nosignoff',  '--strict', '-'])

        print
        print '-------- checkpatch.pl output begins ----------------------------'
        print
        print cp_stdout
        print '-------- end of checkpatch.pl output ----------------------------'
        print

        re_warning = re.compile('^WARNING:', re.MULTILINE)
        re_error = re.compile('^ERROR:', re.MULTILINE)

        if re_warning.findall(cp_stdout):
            print " *** Please minimize checkpatch.pl warnings as much as possible."

        if re_error.findall(cp_stdout):
            print ' *** Please fix all checkpatch.pl errors.'
            status.fail()

        if not re_warning.findall(cp_stdout) and not re_error.findall(cp_stdout):
            print ' *** Yay! checkpatch.pl likes this patch - no errors or warnings!'

    def doscrlfs(self, commit, status):
        print
        print 'Testing for DOS line endings on', commit.hash

        re_doscrlf = re.compile('^.*\r\n', re.MULTILINE)

        doscrlfs = re_doscrlf.findall(commit.patch())
        if doscrlfs:
            print " *** Your patch has DOS cr/lf line endings."
            print " *** Please run 'dos2unix' to fix your DOS line endings."
            status.fail()

    def nomerge(self, commit, status):
        print
        print 'Testing for merge commits on ', commit.hash

        if len(commit.parent_hashes) > 1:
            print " *** Commit %s has more than one parent. Merge commits are not allowed." % commit.hash
            status.fail()
