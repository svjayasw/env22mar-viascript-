#!/usr/bin/env python
#
# Library of simple git utilities not using GitPython
#
# Copyright 2012-2013 Altera Corp
# Written by Alan Tull
#
# Intended to be a super lightweight git library for linux-infra only.
#
# General guideline: If you are using a git command from this library and it might
# fail, use it in a try...except
#
import os
import sys
import tempfile
import re
import time
# Unfortunately the server uses Python 2.6 so we don't have subprocess.check_output
from subprocess import Popen, PIPE, CalledProcessError

NULL_HASH = '0000000000000000000000000000000000000000'

def is_hash(hash):
    return re.match(re.compile('[0-9a-fA-F]{40}'), hash)

def is_null_hash(hash):
    return re.match(re.compile('0{40}'), hash)

class git_utils:
    def __init__(self, verbose=False):
        self.verbose = verbose

    #=====================================================================
    # check_output is intended to be like subprocess.check_output which is
    # in Python 2.7.  Implemented here because server has Python 2.6.
    # from http://stackoverflow.com/questions/4814970/subprocess-check-output-doesnt-seem-to-exist-python-2-6-5
    #=====================================================================
    def check_output(self, *popenargs, **kwargs):
        if 'stdout' in kwargs:
            raise ValueError('stdout argument not allowed, it will be overridden.')
	# Try at least 2 times - network problems
	rc = None
	for x in range(3):
	        proc = Popen(stdout=PIPE, stderr=PIPE, *popenargs, **kwargs)
        	out_value, err_value = proc.communicate()
	        rc = proc.poll()
        	proc.stdout.close()
	        proc.stderr.close()
		# exit immediately if passes.
		if rc :
            		#cmd = kwargs.get("args")
			#print "Retry command [%s]; rc = %d" % cmd, rc
			print "Retry command; rc = %d" % rc
			time.sleep(2)
		else:
			break;
        if rc:
            cmd = kwargs.get("args")
            if cmd is None:
                cmd = popenargs[0]
            raise CalledProcessError(rc, cmd)
        return (out_value, rc)

    def check_output_dont_raise(self, *popenargs, **kwargs):
        if 'stdout' in kwargs:
            raise ValueError('stdout argument not allowed, it will be overridden.')
	rc = None
	for x in range(3):
        	proc = Popen(stdout=PIPE, stderr=PIPE, *popenargs, **kwargs)
	        out_value, err_value = proc.communicate()
        	rc = proc.poll()
	        proc.stdout.close()
	        proc.stderr.close()
		# exit immediately if passes.
		if rc :
            		#cmd = kwargs.get("args")
			#print "Retry command [%s]; rc = %d" % cmd, rc
			print "Retry command; rc = %d" % rc
			time.sleep(2)
		else:
			break;
        return (out_value, err_value, rc)

    #=====================================================================
    # Low level commands to do 'git' commands
    #=====================================================================

    # Executes a git command, returns just the standard out.
    def git_cmd(self, cmd, *args):
        (git_msg, rc) = self.check_output(['git', cmd] + list(args))
        return git_msg

    # Executes a git command, returns just standard out and git return code.
    def git_cmd_with_status(self, cmd, *args):
        try:
            (git_msg, rc) = self.check_output(['git', cmd] + list(args))
        except:
            return '', False
        return git_msg, rc

    # Returns stdout, err, rc.
    def git_cmd_stdout_err_rc(self, cmd, *args):
        return self.check_output_dont_raise(['git', cmd] + list(args))

    # Returns true or false, no text output.
    def git_cmd_status_only(self, cmd, *args):
        try:
            (git_msg, rc) = self.check_output(['git', cmd] + list(args))
        except:
            return False
        return True

    #=====================================================================
    # Low level git commands that map 1:1 with actual git commands
    #=====================================================================
    def cat_file(self, *args):
        if (args[0] == '-e'):
            return self.git_cmd_status_only('cat-file', *args)
        elif (args[0] == '-t') or (args[0] == '-s'):
            git_msg = self.git_cmd('cat-file', *args)
            return git_msg.split('\n')[0]
        else:
            return self.git_cmd('cat-file', *args)

    def clone(self, *args):
        return self.git_cmd('clone', *args)

    def config(self, *args):
        return self.git_cmd('config', *args)

    def describe(self, rev=None):
        if rev == None:
            rev = 'HEAD'
        git_msg = self.git_cmd('describe', rev)
        return git_msg.split('\n')[0]

    # Return closest tag
    def upstream_tag(self, rev=None):
        if rev == None:
            rev = 'HEAD'
        git_msg = self.git_cmd('describe', '--abbrev=0', rev)
        return git_msg.split('\n')[0]

    def diff_tree(self, *args):
        return self.git_cmd('diff-tree', *args)

    def fetch(self, *args):
        return self.git_cmd('fetch', *args)

    def format_patch(self, *args):
        git_msg = self.git_cmd('format-patch', *args)
        patches = git_msg.split('\n')
        patches.remove('')
        return patches

    def log(self, *args):
        return self.git_cmd('log', *args)

    def show(self, *args):
        contents, rc = self.git_cmd_with_status('show', *args)
        return contents

    def remote(self, *args):
        return self.git_cmd('remote', *args)

    def reset(self, *args):
        return self.git_cmd('reset', *args)

    def status(self, *args):
        return self.git_cmd('status', *args)

    def tag(self, *args):
        return self.git_cmd('tag', *args)

    #=====================================================================
    # Higher level utilities
    #=====================================================================

    # Get author email from a commit
    def author_email(self, rev):
        return self.log('-1', '--pretty=format:%ae', rev)

    # Get author name + email from a commit
    def author_full(self, rev):
        name = self.author_name(rev)
        email = self.author_email(rev)
        return name + ' <' + email + '>'

    # Get author name from a commit
    def author_name(self, rev):
        return self.log('-1', '--pretty=format:%an', rev)

    # Get the blob (full file contents) from a blob hash
    def blob_from_hash(self, rev):
        # if file was deleted...
        if rev == '0000000000000000000000000000000000000000':
            return ''
        try:
            return self.cat_file('-p', rev)
        except:
            return ''

    # How many commits are between two refs
    def describe_relative(self, ref1, ref2):
        if ref1 == ref2:
            return 0
        sha1s = self.log_of_hashes(ref1, ref2)
        sha1s = sha1s.split('\n')
        if '' in sha1s:
            sha1s.remove('')
        return len(sha1s)

    # Get currently checked out branch name.
    # Note that 'git branch' is much faster than 'git status'
    # Note also that using a regex isn't any faster than this implementation.
    def branch_name(self):
        branches = self.git_cmd('branch').splitlines()
        for br in branches:
            if br[0] == '*':
                return br[2:]
        print "not on a branch"
        return None

    def checkout_branch(self, branch, remote):
        return self.git_cmd_status_only('checkout', '-b', branch, remote + '/' + branch)

    # Create patches.  Specify output path for where the patch file should go.
    # Returns a list of the names of the created patch files.
    def create_patches(self, output_path='', num_commits=1, rev='HEAD'):
        num = '-' + str(num_commits)
        if output_path == '':
            return self.format_patch(num, rev)
        else:
            return self.format_patch('-o', output_path, num, rev)

    # list of dictionaries with info on files touched by a commit.
    def diff_tree_files(self, oldrev, newrev):
        file_list = []
        for line in self.diff_tree('-r', oldrev, newrev).split('\n'):
            fdict = {}
            line = re.sub('\s+', ' ', line)
            if len(line) == 0 or line[0] != ':':
                continue

            fields = line[1:].split(' ')
            if len(fields) < 6:
                continue

            fdict['src_mode'] = fields[0]
            fdict['dest_mode'] = fields[1]
            fdict['src_hash'] = fields[2]
            fdict['dest_hash'] = fields[3]
            fdict['status'] = fields[4][0]
            fdict['file_name'] = fields[5]

            if fdict['dest_hash'] != NULL_HASH:
                fdict['contents'] = self.cat_file('-p', fdict['dest_hash'])
            else:
                fdict['contents'] = ''

            file_list.append(fdict)
        return file_list

    # Get header of a commit
    def header(self, rev):
        return self.log('-1', rev)

    # Is current working dir a git repo?  Assumes repo is non-bare.
    def in_repo(self):
        return self.git_cmd_status_only('status')

    # Get the commit hashes for a range of revs
    def log_of_hashes(self, oldrev, newrev):
        return self.log('--pretty=format:%H', oldrev + '..' + newrev)

    # Get the hash(es) of a rev's parent(s)
    def parent_hashes(self, rev):
        git_msg = self.log('-1', '--pretty=format:%P', rev)
        return git_msg.split(' ')

    # Get the hash for a single rev (HEAD^, HEAD~3, etc)
    def rev_to_hash(self, rev):
        git_msg = self.log('-1', '--pretty=format:%H', rev)
        return git_msg.rstrip('\n')

    def rev_to_shorthash(self, rev):
        git_msg = self.log('-1', '--pretty=format:%h', rev)
        return git_msg.rstrip('\n')

    # Get name of remote for branch
    def remote_for_branch(self, branch):
        try:
            git_msg = self.config('branch.' + branch + '.remote')
            remote = git_msg.split('\n')[0]
            return remote
        except:
            return None

    # A helpful message we can print if remote_for_branch fails.
    def remote_help(self, branch):
        print "Branch (%s) is not configured to track a branch on our server repo." % branch
        print
        print "You can fix this with the following command (change parts in <>)"
        print "   git branch --set-upstream %s <remote>/<remote-branch-name>" % branch
        print
        print " for example:"
        print "   git branch --set-upstream %s origin/socfpga-3.10" % branch

    # Get url of remote.
    def remote_url(self, remote):
        git_msg = self.config('remote.' + remote + '.url')
        return git_msg.split('\n')[0]

    # Return True if repo is a bare repo.
    def repo_is_bare(self):
        git_msg, rc = self.git_cmd_with_status('config', 'core.bare')
        if rc:
            return False
        git_msg = git_msg.strip('\n')
        if git_msg == 'true':
            return True
        return False

    # Get repository name.
    def repo_name(self):
        if self.repo_is_bare():
            server_repo_path = '/usr/local/git/repositories/'
            repo_name = re.sub(server_repo_path, '', os.getcwd())
            repo_name = re.sub('.git', '', repo_name)
            return repo_name

        branch = self.branch_name()
        if not branch:
            return None
        remote = self.remote_for_branch(branch)
        if not remote:
            return None
        url = self.remote_url(remote)
        repo_name = url.split(':')
        if len(repo_name) != 2:
            print "error in get_repo_name - expects that remote url has format <gitolite path>:<repo name>"
            exit(1)
        repo_name = repo_name[1]
        repo_name = re.sub("\.git", "", repo_name)
        repo_name = repo_name.split('/')[-1]
        if self.verbose:
            print "repo_name is", repo_name
        return repo_name

    # Get subject line of a commit
    def subject(self, rev):
        return self.log('-1', '--pretty=format:%s', rev)

    # Get top level directory of git repository
    def toplevel(self):
        git_msg = self.git_cmd('rev-parse', '--show-toplevel')
        return git_msg.split('\n')[0]

    # Check whether tracking branch is up to date
    def up_to_date(self):
        print
        print "Checking that your branch is up-to-date"

        try:
            git_status = self.git_cmd('status')
        except:
            print git_status
            return False

        status_not_staged = re.compile("Changes not staged for commit:", re.MULTILINE).findall(git_status)
        if status_not_staged:
            print git_status
            print "You have uncommitted changes.  Please commit or clean up and try again."
            return False

        status_not_committed = re.compile("Changes to be committed:", re.MULTILINE).findall(git_status)
        if status_not_committed:
            print git_status
            print "You have changes that are stanged for commit, but not committed.  Please commit or clean up and try again."
            return False

        status_behind = re.compile("Your branch is behind .* by .* commits, and can be fast-forwarded", re.MULTILINE).findall(git_status)
        if status_behind:
            print "Your branch %s appears to not have any local commits." % self.branch_name()
            print "  (So update using 'gg' and commit something)"
            return False

        status_diverged = re.compile("Your branch and .* have diverged", re.MULTILINE).findall(git_status)
        if status_diverged:
            print git_status
            print "Your branch %s is not up to date.  Please rebase using 'gg'" % self.branch_name()
            return False

        return True


class Repo:
    def __init__(self, git_dir):
        self.git_dir = git_dir
        git = git_utils()
        self.git = git
        try:
            self.repo_name = git.repo_name()
            self.in_repo = True
        except:
            self.repo_name = ''
            self.in_repo = False

class Commit:
    def __init__(self, repo, rev):
        self.repo = repo
        git = repo.git
        self.git = git
        self.__file_blob_hashes = None

        hash = git.rev_to_hash(rev)
        self.hash = hash
        self.shorthash = hash[:7]
        self.parent_hashes = git.parent_hashes(hash)
        self.subject = git.log('-1', '--pretty=format:%s', hash)

    def file_blob_hashes(self):
        '''Dictionary of file names, hash for file blobs'''
        if self.__file_blob_hashes == None:
            self.__file_blob_hashes = {}
            blob_strs = self.git.diff_tree("-r", self.parent_hashes[0], self.hash).replace("\t", " ").split('\n')
            for blob_str in blob_strs:
                if len(blob_str.split()) > 5:
                    dest = blob_str.split()[3]
                    file_name = blob_str.split()[5]
                    self.__file_blob_hashes[file_name] = dest

        return self.__file_blob_hashes

    def diff_tree_files(self):
        return self.git.diff_tree_files(self.parent_hashes[0], self.hash)

    def header(self):
        return self.git.log('-1', self.hash)

    def patch(self):
        patch, rc = self.git.git_cmd_with_status('format-patch', '-1', '-C', '--stdout', self.hash)
        return patch
