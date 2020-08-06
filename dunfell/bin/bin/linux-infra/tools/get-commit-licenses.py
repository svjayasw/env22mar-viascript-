#!/usr/bin/env python

import os
import sys
import argparse
import textwrap

# Add the ../tools directory to the path so that we can import git_utils.py
sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'hooks'))
from git_utils import *
from License import *

#============================================================================================
# Parse command line arguments

parser = argparse.ArgumentParser(formatter_class=argparse.RawDescriptionHelpFormatter,
                                 description="Determine licenses in files referred to by a commit",
                                 epilog=textwrap.dedent('''\
This script will attempt to determine the software licenses of the
files that are in a commit.  The license headers don't actually
have to be in the commit itself.
'''))

parser.add_argument(dest="commit", help="commit")

args = parser.parse_args()
rev = args.commit

#============================================================================================

git = git_utils()
repo = Repo(os.getcwd())
if not repo.in_repo:
    print 'Not in a git repository.  Please cd to your git repository.'
    exit(1)

tl = TestLicense()
commit = Commit(repo, rev)
licenses = tl.match_commit_licenses(commit)

for file_name in licenses.keys():
    print '%s: %s' % (file_name, licenses[file_name])

exit(0)
