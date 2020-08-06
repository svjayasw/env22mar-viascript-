#!/usr/bin/env python

import argparse
import glob
import re
import sys
import textwrap
from os.path import isdir, isfile

#from os import path, chdir, getcwd, remove
#from shutil import rmtree
#from subprocess import Popen, PIPE, STDOUT

team_members = [
    'Alan Tull',
    'David Koltak',
    'Dinh Nguyen',
    'Richard Gong',
    'Thor Thayer',
    'Graham Moore',
    'Matthew Gerlach',
    'Yves Vandervennet'
]

def write_file(fn, contents):
    try:
        f = open(fn, 'w')
        f.write(contents)
        f.close()
    except:
        print('Error writing %s' % fn)
        exit(1)

def read_file(fn):
    try:
        f = open(fn, 'r')
        contents = f.read()
        f.close()
    except:
        print('Error reading %s' % fn)
        exit(1)
    return contents

#=================================================================================================
parser = argparse.ArgumentParser(formatter_class=argparse.RawDescriptionHelpFormatter,
                                 description="Filter Klocwork scan results by team member names",
                                 epilog=textwrap.dedent('''\

Examples:
   %(prog)s 
      Klocwork scan will happen on the currently checked out branch of the repo cloned at the specified path (.)

   %(prog)s -p linux-socfpga -m stratix10 -b origin/socfpga-4.9.78-ltsi -r v4.9.78..ACDS18.1_REL_GSRD_PR -v ~/linux/intel
   %(prog)s -p intel-rsu -m stratix10 -b origin/master -v ~/linux/intel
      Both these examples assume user has created ~/linux/intel directory for source and results.
'''))

# Parameters
#parser.add_argument("--list-names", action="store_true", help="list all names detected in results")
parser.add_argument("--in", dest="input_fn", required=True, help="point this to 'kw-results-filtered.txt'")
parser.add_argument("--out", dest="output_fn", default=None, help="save results in this file name")

#==============================================================================================================
args = parser.parse_args()

print 'Filtering for the following names:'
for name in team_members:
    print '  ' + name
print

team_re=''
for name in team_members:
    if team_re == '':
        team_re += '(' + name
    else:
        team_re += '|' + name
team_re += ') -- .*'
# print team_re

filt_out = ''
prefiltered = read_file(args.input_fn)
for line in prefiltered.split('\n'):
    if re.match(re.compile(team_re), line):
        filt_out += line + '\n'

if args.output_fn != None:
    write_file(args.output_fn, filt_out)

print filt_out
        
exit(0)
