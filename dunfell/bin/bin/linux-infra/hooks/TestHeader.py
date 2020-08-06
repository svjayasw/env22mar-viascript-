#!/usr/bin/env python
#
# Tests for headers of pushes to refs/heads/
# 
# Copyright (C) 2012 Alan Tull atull@altera.com
#
# Tests to implement:
# Header tests:
#   basic header format (single subject line, skip line, descr, skip line, signoff)
#   signoff
#   fogbugs number
#       fogbugs number not used before (NO because can be reopened)
#       multiple patches on one fogbugs can be -1, -2 (NO for now, maybe later)
#   forbidden words
#   Subject line tests:
#       minimum/maximum legnth
#       forbidden words
#       can't have the word '.patch'

import os
import sys
import re
import tempfile
import subprocess

# imports from this project
from GitReceivePack import *
from HooksUtils import *

def header_error(line_num, msg):
    print "**Error in patch header line # %d : %s" % (line_num, msg)

printed_header_format_already = False
printed_merge_advice_already = False
max_line_legnth = 79

def print_header_format_once():
    if printed_header_format_already:
        return

    print '''
     commit header should have the following:
     1. A brief subject line that starts 'FogBugz #123456: ' or 'HSD #123456:'
     2. One blank line.
     3. A description.
     4. One blank line.
     5. The author signoff line.  Other signoffs, cc's, and acked-by lines may follow.
'''

def print_merge_advice():
    if printed_merge_advice_already:
        return

    print '''
     If you need to update your branch when you have local commits, you should do a
     'git fetch origin' followed by a 'git rebase'.  That will rebase your local commits
     to come after the all the commits that have already been pushed to the tracking branch.

     If you need to merge work on another branch into your this branch, you should use
     'git cherry-pick' to get all the commits into this branch.  That way we won't lose history.
'''

def next_line(header, line_num, status):
    line_num += 1
    try:
        line = header[line_num - 1]
    except:
        status.fail()
        return '', -1

    print "%3d: %s" % (line_num, line)
    if len(line) > max_line_legnth:
        header_error(line_num, "Header line legnth > %d chars" % max_line_legnth)
        status.fail()

    return line, line_num

def prev_line(header, line_num, status):
    line_num -= 1
    try:
    	line = header[line_num - 1]
    except:
        status.fail()
        return '', -1

    if len(line) > max_line_legnth:
        header_error(line_num, "Header line legnth > %d chars" % max_line_legnth)
        status.fail()

    return line, line_num

def is_blank(line):
    return (line == '    ') or (line == '')

def check_internal_email(line_num, line):
    match = re.match(re.compile(".*: .* <[a-zA-Z0-9.]*@(intel\.com|linux\.intel\.com>|kernel\.org|opensource\.altera\.com|altera\.com)"), line)
    if match == None:
        header_error(line_num, "Email address should contain @intel.com, @linux.intel.com, @kernel.org, @opensource.altera.com, or @altera.com")
    return match

def is_signoff(line):
    return re.match(re.compile("    Signed-off-by: "), line)

def is_acked(line):
    return re.match(re.compile("    Acked-by: "), line)

def is_reported_by(line):
    return re.match(re.compile("    Reported-by: "), line)

def is_cc(line):
    return re.match(re.compile("    Cc: "), line)

# Check for correct git-generated patch info: hash, Author, Date.
def check_header_pre_subject(header, line_num, status):
    line, line_num = next_line(header, line_num, status)
    if line_num < 0:
        return line_num

    if not re.match(re.compile("commit [0-9a-f]{40}"), line):
        header_error(line_num, "Expecting: 'commit <sha>'")
        status.fail()

    line, line_num = next_line(header, line_num, status)
    if line_num < 0:
        return line_num

    if re.match("Merge: ", line):
        header_error(line_num, "Merge commits are not generally allowed.")
        print_merge_advice()
        status.fail()
        line, line_num = next_line(header, line_num, status)
        if line_num < 0:
            return line_num

    if not re.match("Author: ", line):
        header_error(line_num, "Expecting: 'Author: DeveloperName <email>'")
        status.fail()

    line, line_num = next_line(header, line_num, status)
    if line_num < 0:
        return line_num

    if not re.match("Date: ", line):
        header_error(line_num, "Expecting: 'Date: <date>'")
        status.fail()

    line, line_num = next_line(header, line_num, status)
    if line_num < 0:
        return line_num

    if not is_blank(line):
        header_error(line_num, "This line should be blank.")
        status.fail()

    return line_num

# Subject: [PATCH] FogBugz #71677: Update clock speed for proper system time.
# Subject: [PATCH] HSD #71677: Update clock speed for proper system time.
def check_header_subject(header, line_num, status):
    line, line_num = next_line(header, line_num, status)
    if line_num < 0:
        return line_num

    if re.match(re.compile("    Merge branch .*"), line):
        header_error(line_num, "Merge commits are not generally allowed.")
        print_merge_advice()
        status.fail()

    if not re.match(re.compile("    (FogBugz|HSD) #([0-9-]+):.*"), line):
        header_error(line_num, "Error: couldn't find 'FogBugz #' or 'HSD #'")
        status.fail()

    # Expecting a single blank line.
    line, line_num = next_line(header, line_num, status)
    if line_num < 0:
        return line_num

    if not is_blank(line):
        header_error(line_num, "Subject line should be one line, followed by one blank line.")
        status.fail()

    return line_num

def check_header_description(header, line_num, status):
    # Expecting the first line of the description.
    line, line_num = next_line(header, line_num, status)
    if line_num < 0:
        return line_num

    if is_blank(line) or is_signoff(line) or is_acked(line) or is_cc(line):
        header_error(line_num, "Header should have a subject line, one blank line, a then description.")
        status.fail()

    return line_num

def check_header_signoff(header, line_num, status):
    line, line_num = next_line(header, line_num, status)
    if line_num < 0:
        return line_num

    while True:
        # Skip over a section of nonblank lines
        while not is_blank(line):
            if is_acked(line) or is_cc(line):
                check_internal_email(line_num, line)
                header_error(line_num, "shouldn't have Acked-by: or Cc: line here.")
                status.fail()

            if is_signoff(line):
                email_match = check_internal_email(line_num, line)
                if email_match == None:
                    status.fail()

	        line, line_num = prev_line(header, line_num, status)
		if is_reported_by(line):
                    email_match = check_internal_email(line_num, line)
                    if email_match == None:
                        status.fail()

		    line, line_num = prev_line(header, line_num, status)
		    if not is_blank(line):
			header_error(line_num, "should have a blank line before the Reported-by line.")
			line_num += 2
			status.fail()
			break;
		    else:
            		line_num += 1
			return line_num
		elif not is_blank(line):
		   header_error(line_num, "should have a blank line before the signoff line.")
		   line_num += 1
		   status.fail()
		   break

            line, line_num = next_line(header, line_num, status)
            if line_num < 0:
                return line_num

        line, line_num = next_line(header, line_num, status)
        if line_num < 0:
            return line_num

        if is_signoff(line):
            email_match = check_internal_email(line_num, line)
            if email_match == None:
                status.fail()
            break

    return line_num

class TestHeader:
    # This function is a 'test' in repo_settings' update_tests setting. Don't change its name!
    def header(self, commit, status):
        line_num = 0
        header = commit.header().split('\n')

        print
        print '-----------------------------------------------------------------'
        print '---------------------checking header format----------------------'

        header_tests = ( check_header_pre_subject,
                         check_header_subject,
                         check_header_description,
                         check_header_signoff )

        for header_test in header_tests:
            line_num = header_test(header, line_num, status)
            if line_num < 0:
                status.fail()
                print_header_format_once()
                return

        print '-----------------------------------------------------------------'
        print '-----------------------------------------------------------------'
