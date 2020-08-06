#!/usr/bin/env python

import os
import sys
import argparse
import textwrap
import signal

script_name = os.path.basename(sys.argv[0])

# Add the ../tools directory to the path so that we can import git_utils.py
sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'hooks'))
from git_utils import *
from License import *

git = git_utils()
status = 'PASS'
tl = TestLicense()
repo = Repo(os.getcwd())

def signal_handler(signal, frame):
    print 'You pressed Ctrl+C!'
    exit(0)

signal.signal(signal.SIGINT, signal_handler)

#============================================================================================
# Parse command line arguments

parser = argparse.ArgumentParser(formatter_class=argparse.RawDescriptionHelpFormatter,
                                 description="Determine license from a source file",
                                 epilog=textwrap.dedent('''\
This script will attempt to determine the software license of a file.
'''))

parser.add_argument(dest="filename", help="file to get license of")

parser.add_argument("-n", dest="show_file_name", action="store_true",
                    help="show file name")

parser.add_argument("-L", dest="show_file_name_if_fail", action="store_true",
                    help="Supress printing.  Only show file name if no license is found.")

parser.add_argument("-v", dest="show_header", action="store_true",
                    help="show file header")

args = parser.parse_args()

#============================================================================================

file_full = os.path.realpath(args.filename)
raw_header = tl.get_header(file_full)
file_license = tl.match_license(raw_header, file_full)

# Decide what all to print
show_file_name = False
show_license_name = False
if args.show_file_name_if_fail:
    if file_license == '':
        show_file_name = True
else:
    show_license_name = True
    if args.show_file_name:
        show_file_name = True

# Now print it
if show_file_name:
    if show_license_name:
        print '%s:%s' % (file_full, file_license)
    else:
        print '%s' % (file_full)
else:
    if show_license_name:
        print '%s' % (file_license)

if args.show_header:
    print raw_header

exit(0)
