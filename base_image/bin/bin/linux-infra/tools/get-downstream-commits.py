#!/usr/bin/env python

import argparse
import datetime
import os
import re
import textwrap

from shutil import copyfile, rmtree, copytree
from subprocess import Popen, PIPE, CalledProcessError

# Local libraries
from git_utils import *

commit_list = []
authors_list = []

def commits_between(repo, start, end):
    global git
    global commit_list
    shas = git.log_of_hashes(start, end).split("\n")
    for sha in shas:
        commit = Commit(repo, sha)
        commit.keep = True
        commit.author = git.author_full(sha)
        commit_list.append(commit)

# create list of authors
def commit_authors():
    global commit_list
    global authors_list
    for commit in commit_list:
        author = commit.author
        if author not in authors_list:
            authors_list.append(author)

# mark all commits with FogBugz to keep            
def keep_fogbugz():
    global commit_list
    for commit in commit_list:
        if not re.match(re.compile(".*(FogBugz|HSD).*"), commit.subject):
            commit.keep = False

def get_datestamp():
    now = datetime.datetime.now()
    datestamp = "%d%d%d" % (now.year, now.month, now.day)
    return datestamp

def copy_filtered_tree(dest):
    global commit_list
    for commit in commit_list:
        if not commit.keep:
            continue
        for file_name in commit.file_blob_hashes().keys():
            blob_hash = commit.file_blob_hashes()[file_name]
            file_text = git.blob_from_hash(blob_hash)

            dest_fn = os.path.join(dest, file_name)
            dest_dir = os.path.join(dest, os.path.dirname(file_name))

            if not os.path.exists(dest_dir):
                os.makedirs(dest_dir)
            try:
                blob_file = open(dest_fn, 'w')
                blob_file.write(file_text)
                blob_file.close()
            except:
                print 'Error writing %s' % dest_fn
                exit(1)

def copy_dot_git(source, dest):
    source_dir = os.path.join(source, '.git')
    dest_dir = os.path.join(dest, '.git')
    copytree(source_dir, dest_dir)

#=======================================================================

parser = argparse.ArgumentParser(formatter_class=argparse.RawDescriptionHelpFormatter,
                                 description="Create filtered git tree for analysis",
                                 epilog=textwrap.dedent('''\
This script will:
* Cd to the git repo
* Look at commits from the start ref to end ref.
  * If --start is not specified, uses upstream release tag to use as start tag.
* Filter out some commits depending on --keep parameter.
  * --keep all = keep all commits in the range
  * --keep fb  = keep only commits that have "FogBugz" or "HSD" in the subject line.
* Copy their files to dest directory.
  * Note that the file contents are extracted from the git index.
  * It doesn't matter what branch is checked out in the repo.
* Optionally copy the .git dir
  * Note that git may not think that the "end" ref is checked out.
'''))

parser.add_argument("--repo", dest="source", help="unfiltered git tree (source) [default = .]")
parser.add_argument("--start", dest="start", help="start ref [default is upstream tag]")
parser.add_argument("--end", dest="end", default='HEAD', help="end ref (default = 'HEAD')")
parser.add_argument("--keep", help="filter method [default is 'fb']", default='fb')
parser.add_argument("--ad", "--auto-dest", dest="auto_dest", action="store_true", help="create named dest dir as subdir of -d dest")
parser.add_argument("-d", "--dest", dest="dest", required=True, help="filtered tree to create (destination)")
parser.add_argument("-g", "--copy-git", dest="copy_git", action="store_true", help="copy source .git directory")
#parser.add_argument("-f", "--force", dest="force", action="store_true", help="overwrite (clean) destination")
parser.add_argument("-v", dest="verbose", action="store_true", help="verbose messages")

args = parser.parse_args()

#-----------------------------------------------------------------------

if args.source != None:
    os.chdir(args.source)

source = os.getcwd()
repo = Repo(source)
git = repo.git
branch_name = git.branch_name()

valid_filters = ('fb', 'all')
if args.keep not in valid_filters:
    print 'Invalid filter specified: %s' % args.keep
    print ' must be one of %s' % str(valid_filters)
    exit(1)

end = args.end
if args.start:
    start = args.start
else:
    start = git.upstream_tag(end)
    print "Using this tag as starting point: %s" % start

dest = args.dest
if args.auto_dest:
    sha = git.rev_to_shorthash(end)
    dest = os.path.join(dest, "%s-%s-%s" % (get_datestamp(), sha, branch_name))
print "Filtered code will go into %s" % dest
    
if os.path.exists(dest):
    print "Directory already exists! please delete %s" % dest
    exit(1)

os.makedirs(dest)

#---------------------------------------------------------------------------------------

commits_between(repo, start, end)
if args.verbose:
    print "Between %s and %s there are total %d commits." % (start, end, len(commit_list))

#commit_authors()
#if args.verbose:
#    print authors_list

if args.keep == 'fb':
    if args.verbose:
        print "Filtering to keep only commits that have 'FogBugz' or 'HSD' in subject line"
    keep_fogbugz()

if args.verbose:
    count_keep = 0
    count_skip = 0
    for commit in commit_list:
        if commit.keep:
            count_keep += 1
        else:
            count_skip += 1
    print "After filtering, keeping %d commits, eliminating %d commits" % (count_keep, count_skip)
    for commit in commit_list:
        if commit.keep:
            keep = 'KEEP'
        else:
            keep = ''
        print "%4s : %s : %s : %s" % (keep, commit.shorthash, commit.author, commit.subject)
    print
    print 'exporting files to dest dir %s' % dest

copy_filtered_tree(dest)
if args.copy_git:
    copy_dot_git(source, dest)

print 'Done'
exit(0)
