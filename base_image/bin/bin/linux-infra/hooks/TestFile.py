#!/usr/bin/env python
#
# Tests that are run on the per file level
# 
# Copyright (C) 2012 Alan Tull atull@altera.com
#
# File tests:
#   chmod test  = only needed for projects where we aren't running checkpatch:
#   copyright
#   copyright year
#   branch name restrictions
#   forbidden words

import os
import sys
import re
import tempfile
import subprocess
import datetime

# imports from this project
from GitReceivePack import *
from HooksUtils import *
from License import *

def print_copyright_expectations(message, year):
    print 'ERROR: %s Should be either of these:' % message
    print '  Copyright (C) %s Intel Corporation' % year
    print '  Copyright (C) %s Intel Corporation. All rights reserved' % year
    print '   see also:'
    print '  http://sw-wiki.altera.com/twiki/bin/view/Software/HPSOpenSourceRulesGPLv2'
    print

class TestFile:
    # TODO finish this test.  Not needed for now as is covered by other tests.
    def chmod(self, commit, status):
        git = commit.git
        print
        print 'Testing for files with wrong permissions'
        print commit.parent_hashes[0], commit.hash

        # 'git diff-tree' output is like this:
        #   create mode 100755 sound/lala-duck.c
        #   mode change 100644 => 100755 sound/soc/soc-core.c
        #   delete mode 100644 COPYING
        #   rename MAINTAINERS => stuff (100%)
        diff_tree_summary = git.diff_tree("--summary", commit.parent_hashes[0], commit.hash).split('\n')
        print '---------------------------------------------------------------'
        for mode_msg in diff_tree_summary:
            print mode_msg

            file_name = re.sub('.*[755|644]', '', mode_msg)
            try:
                mode_action = re.compile('(create mode|mode change)').findall(mode_msg)[0]
                if mode_action == 'create mode':
                    ending_mode = re.compile('create mode 100(755|644)').findall(mode_msg)[0]
                else:
                    ending_mode = re.compile('mode change 100.*=> 100(755|644)').findall(mode_msg)[0]
            except:
                mode_action = 'other'
                ending_mode = 'ok'

            print mode_action, 'to mode', ending_mode, file_name
            print
        print '---------------------------------------------------------------'
        # To do: check to see if file is a source file.  If it is being set as executable, fail.
        status.fail()

    def copyright_year(self, commit, status):
        git = commit.git
        year = str(datetime.date.today().year)

        print
        print 'Testing new files for copyright date'
        #print commit.parent_hashes[0], commit.hash
        commit_files = commit.diff_tree_files()
        for cfile in commit_files:
            file_name = cfile['file_name']
            contents = cfile['contents']
            if cfile['src_hash'] != '0000000000000000000000000000000000000000':
                continue
            intel_copy = re.compile('Copyright.*Intel.*\n').findall(contents)
            if not intel_copy:
                continue

            intel_copy = intel_copy[0].strip()

            re_intel_copy = re.compile('Copyright \(C\) (.*) Intel Corporation(|\.  ?All rights reserved(|\.))$')

            print '%s :' % file_name
            print '  %s' % intel_copy

            if not re.match(re_intel_copy, intel_copy):
                print_copyright_expectations('Copyright looks wrong', year)
                status.fail()
                continue

            re_intel_copyyear = re.compile('Copyright \(C\) (.*) Intel.*')

            file_year = re.sub(re_intel_copyyear, '\\1', intel_copy).strip()

            # let's just get the last 4 chars of '1999, 2011 - 2013' types of dates
            file_year_reduced = file_year[-4:]
            
            if file_year_reduced != year:
                print_copyright_expectations('Copyright year (%s) looks wrong.' % file_year, year)
                status.fail()
                continue

            print

    def license_gplv2_approved(self, commit, status):
        print
        print 'Testing for approved GPLv2 license in new files'
        license_pf = 'PASS'
        tl = TestLicense()
        licenses = tl.match_commit_licenses(commit)
        commit_files = commit.diff_tree_files()
        for cfile in commit_files:
            file_name = cfile['file_name']
            contents = cfile['contents']
            file_license = licenses[file_name]

            lic_status = ''

            # Don't care about files we aren't creating with this commit
            if cfile['src_hash'] == '0000000000000000000000000000000000000000':
                file_new = '  new file  '
            else:
                file_new = 'file not new'
                lic_status = '    skip    '

            # Skip testing certain types of files
            re_no_license_needed = re.compile('(Makefile|Kconfig|defconfig|Documentation|.*\.h)')
            if re_no_license_needed.findall(file_name):
                lic_status = '    skip    '

            # The rest of the files are files we care about.  Give pass or fail on each.
            if lic_status == '':
                if file_license == 'GPLv2 Approved':
                    lic_status = '    pass    '
                elif file_license == 'SPDX GPLv2':
                    lic_status = '    pass    '
                elif file_license == 'Linux Kernel SPDX GPLv2':
                    lic_status = '    pass    '
                else:
                    lic_status = '< MUST FIX >'
                    license_pf = 'FAIL'
                    status.fail()

            print ' | %12s | %12s | %14s | %s' % (file_new, lic_status, file_license, file_name)
        print 'License test result: %s' % (license_pf)
        if license_pf != 'PASS':
            print ' Please fix the headers of the files marked "MUST FIX" above to the'
            print ' approved header in:'
            print '  http://sw-wiki.altera.com/twiki/bin/view/Software/HPSOpenSourceRulesGPLv2'

        print

    def license_linux_kernel_gplv2(self, commit, status):
        print
        print 'Testing for Linux Kernel SPDX GPLv2 license in new files'
        license_pf = 'PASS'
        tl = TestLicense()
        licenses = tl.match_commit_licenses(commit)
        commit_files = commit.diff_tree_files()
        for cfile in commit_files:
            file_name = cfile['file_name']
            base_name = os.path.basename(file_name)
            contents = cfile['contents']
            file_license = licenses[file_name]

            lic_status = ''

            # Skip testing unless it's a source file or Makefile (skip documentation files, etc)
            if not re.compile('(Makefile|Kconfig|.*\.(c|h|asm|dts|dtsi))').match(base_name):
                lic_status = '    skip    '

            # Don't care about files we aren't creating with this commit
            if cfile['src_hash'] == '0000000000000000000000000000000000000000':
                file_new = '  new file  '
            else:
                file_new = 'file not new'
                lic_status = '    skip    '

            # NOTE that for the kernel, we are no longer skipping testing on any files.

            # The rest of the files are files we care about.  Give pass or fail on each.
            if lic_status == '':
                if file_license == 'Linux Kernel SPDX GPLv2':
                    lic_status = '    pass    '
                else:
                    lic_status = '< MUST FIX >'
                    license_pf = 'FAIL'
                    status.fail()

            print ' | %12s | %12s | %14s | %s' % (file_new, lic_status, file_license, file_name)
        print 'License test result: %s' % (license_pf)
        if license_pf != 'PASS':
            print ' Please fix the headers of the files marked "MUST FIX" above to the'
            print ' approved header in:'
            print '  http://sw-wiki.altera.com/twiki/bin/view/Software/HPSOpenSourceRulesGPLv2'

        print

    def license_spdx_bsdv2_clause(self, commit, status):
        print
        print 'Testing for SPDX BSDv2 Clause license in new files'
        license_pf = 'PASS'
        tl = TestLicense()
        licenses = tl.match_commit_licenses(commit)
        commit_files = commit.diff_tree_files()
        for cfile in commit_files:
            file_name = cfile['file_name']
            base_name = os.path.basename(file_name)
            contents = cfile['contents']
            file_license = licenses[file_name]

            lic_status = ''

            # Skip testing unless it's a source file or Makefile
            if not re.compile('(Makefile|Kconfig|.*\.(c|h|asm|dts|dtsi))').match(base_name):
                lic_status = '    skip    '

            # Don't care about files we aren't creating with this commit
            if cfile['src_hash'] == '0000000000000000000000000000000000000000':
                file_new = '  new file  '
            else:
                file_new = 'file not new'
                lic_status = '    skip    '

            # The rest of the files are files we care about.  Give pass or fail on each.
            if lic_status == '':
                if file_license == 'SPDX BSD-2-Clause':
                    lic_status = '    pass    '
                else:
                    lic_status = '< MUST FIX >'
                    license_pf = 'FAIL'
                    status.fail()

            print ' | %12s | %12s | %14s | %s' % (file_new, lic_status, file_license, file_name)
        print 'License test result: %s' % (license_pf)
        if license_pf != 'PASS':
            print ' Please fix the headers of the files marked "MUST FIX" above to the'
            print ' SPDX header which is: "SPDX-License-Identifier: BSD-2-Clause"'
            print ' Note that his header must be the first line in the file and have the'
            print ' appropriate commenting style, similar to used in the Linux kernel'
            print ' as described in:'
            print '  http://sw-wiki.altera.com/twiki/bin/view/Software/HPSOpenSourceRulesGPLv2'

        print
