#!/usr/bin/env python
#
# This script currently supports ACDS releases and Linux releases.
#
# Both are released from our internal repo to our portal repo.  The differences are:
#
# ACDS
# * Tags are set and approved in PNG.
# * All tag branches/repos get the same tag name such as ACDS16.0_REL_GSRD_RC6
# * There are usually 8 RC's, then a PR
# * All RC's and the PR are pushed the portal
#
# Linux
# * Tags are set by this script.
# * Tag names are branch specific as they include the name of the branch
#    such as rel_socfpga-4.1.22-ltsi_16.07.02_pr
# * Usually 1 or 2 rc's
# * rc tags are pushed to internal repos only; rc tags are not pushed to the portal
# * pr tags are pushed to internal and portal repo.
#
# In all cases we DO NOT REBASE branches that have been pushed to the portal.
#

import argparse
import datetime
import getpass
import json
import os
import re
import smtplib
import sys
import textwrap
import time
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

g_linux_infra = os.path.split(os.path.dirname(__file__))[0]

# Local libraries
sys.path.append(g_linux_infra + 'tools')
from git_utils import *

acds_release_targets = ('GSRD', 'SGMII', 'PCIE')

#=========================================================================================
# Global Constants
#=========================================================================================
class GlobalsConstants:
    smtp_server = 'smtp.intel.com:25'

    #todo allow user to set this.  Save paths in user conf file
    # Path to where the repos are cloned locally
    internal_repos_base = os.path.expanduser("~/repos/internal")
    portal_repos_base = os.path.expanduser("~/repos/portal")

    # Email list for 'all', script adds @intel.com to each; emailing out of the org not supported.
    #
    # Regarding the pswp.boot alias that is in this list:
    # As of 4/24/2019 the pswp.boot alias includes the following people:
    #
    # Abdul Halim, Muhammad Hadi Asyrafi <muhammad.hadi.asyrafi.abdul.halim@intel.com>
    # Ang, Chee Hong <chee.hong.ang@intel.com>
    # Chee, Tien Fong <tien.fong.chee@intel.com>
    # Loh, Tien Hock <tien.hock.loh@intel.com>
    # Ong, Hean Loong <hean.loong.ong@intel.com>
    # Ooi, Joyce <joyce.ooi@intel.com>
    # See, Chin Liang <chin.liang.see@intel.com>
    # Tan, Ley Foon <ley.foon.tan@intel.com>
    portal_recipients = [ 'findlay.shearer',
                          'richard.gong',
                          'sen.li',
                          'thor.thayer',
                          'dinh.nguyen',
                          'pswp.boot',
                          'matthew.gerlach',
                          'christopher.chun.yee.tan',
                          'chung.weng.gooi',
                          'soo.min.ooi',
                          'jeffrey.da.silva',
                          'chee.nouk.phoon',
                          'ying.cheh.tan',
                          'sue.cozart' ]

    # repos we use, but do not update on external git
    linux_tags_repo = 'linux-tags'
    linux_altera_tags_name = 'linux-altera-tags'

    infra_repo_list = [
        linux_tags_repo,
    ]

    infra_repo_dict = {
        linux_tags_repo : {
            'internal_git_url':'gitolite@at-git:linux-tags',
            'branch':'master',
        },
    }

#=========================================================================================
# Low level functions for GIT operations
#=========================================================================================

class GitOperations(git_utils):
    def git__reset_hard_to_branch(self, branch):
       self.git_cmd('reset', '--hard', branch)

    def git__add(self, file_name):
        self.git_cmd('add', file_name)

    def git__commit(self, msg):
        self.git_cmd('commit', '-m', msg)

    def git__fetch(self, remote, tags=False):
        if tags:
            self.pr_log('git fetch --tags %s' % remote)
            self.fetch('--tags', remote)
        else:
            self.pr_log('git fetch %s' % remote)
            self.fetch(remote)

    def git__checkout_branch(self, branch, remote):
        if self.branch_name() == branch:
            self.pr_log('on branch %s' % branch)
            return branch

        self.pr_log('git branch -D %s' % (branch))
        self.git_cmd_with_status('branch', '-D', branch)

        self.pr_log('git checkout -b %s %s/%s' % (branch, remote, branch))
        self.checkout_branch(branch, remote)
        return self.branch_name()

    def git__clone(self, url, localname=None):
        if localname:
            self.pr_log('git clone %s %s' % (url, localname))
            self.clone(url, localname)
        else:
            self.pr_log('git clone %s' % url)
            self.clone(url)

    def git__tag(self, name, sha):
        self.tag('-f', name, sha)

    # pattern = list of admissible tag names
    def git__get_tag_list(self, pattern):
        (log, rc) = self.check_output(['git', 'tag', '-l'] + pattern)
        return log.splitlines()

    def git__sha(self, git_rev):
        try:
            sha = self.log('-1', '--pretty=%H', git_rev)
            sha = sha.strip('\n')
        except:
            sha = None
        if sha == '':
            sha = None
        return sha

    def git__remote_add_portal(self, repo):
        url = self.repo_dict[repo]['external_git_url']
        self.pr_log('git remote add portal %s' % url)
        self.remote('add', 'portal', url)

    #=========================================================================================
    # Higher level GIT functions
    #=========================================================================================

    def repo_ref_exists(self, ref):
        return self.git_cmd_status_only('log', '-1', ref)

    def remote_tag_matching_pattern(self, remote, pattern):
        log = self.git_cmd('ls-remote', '--tags', remote, pattern)
        if log == '':
            return None
        tags = []
        for log_line in log.split('\n'):
            tag = re.sub('.*refs/tags/', '', log_line)
            if tag != '':
                tags.append(tag)
        return tags

    # Returns sha for a tag on a remote or None
    def remote_tag_sha(self, remote, tag):
        if tag == None:
            return None
        log = self.git_cmd('ls-remote', '--tags', remote, tag)
        if log == '':
            return None
        return log.split()[0]

    def remote_head_sha(self, remote, branch):
        log = self.git_cmd('ls-remote', '--heads', remote, branch)
        if log == '':
            return None
        return log.split()[0]

    # Returns True or False
    def remote_branch_contains_sha(self, remote, branch, sha):
        if sha == None:
            return False
        log = self.git_cmd('branch', '-r', '--contains', sha, remote + '/' + branch)
        return log != ''

    # Returns branch name from origin or None
    def git__branch_contains(self, sha):
        if sha == None:
            return None
        log = self.git_cmd('branch', '-r', '--contains', sha, 'origin/*')
        if log == '':
            return None
        branches = []
        for log_line in log.split('\n'):
            if log_line == '':
                continue
            if re.match(re.compile(".*HEAD.*"), log_line):
                continue                        
            branch = log_line.split('/')[1]
            if branch != '':
                branches.append(branch)
        return branches

    # Check that we have repos cloned
    def check_cloned_repos(self):
        for repo in self.repo_list + self.infra_repo_list:
            if not os.path.isdir(self.internal_repo_path(repo)):
                self.pr_log('Internal repo %s is not cloned (and maybe others)! Re-run with -u option.' % repo)
                exit(1)
        for repo in self.repo_list:
            if 'external_git_url' in self.repo_dict[repo]:
                if not os.path.isdir(self.portal_repo_path(repo)):
                    self.pr_log('Portal repo %s is not cloned (and maybe others)! Re-run with -u option.' % repo)
                    exit(1)

    def checkout_branch(self, parent_dir, repo, branch):
        repo_path = os.path.join(self.internal_repos_base, repo)
        os.chdir(repo_path)
        current_branch = self.git__checkout_branch(branch, 'origin')
        if branch != current_branch:
            self.pr_log("tried to checkout %s branch %s but on branch %s" % (repo, branch, current_branch))
            exit(1)

    def check_remote_url(self, remote, repo_url):
        url = self.remote('-v')
        re_origin = re.compile(remote + ".*\(fetch\)")
        url = re_origin.findall(url)
        if not url:
            self.pr_log("Error checking remote origin, giving up")
            exit(0)
        url = url[0].split()[1]
        if url != repo_url:
            self.pr_log("Error checking remote %s, does not match" % remote)
            self.pr_log(" expected %s" % repo_url)
            self.pr_log(" got      %s" % url)
            exit(0)

    # Clone repo in parent_dir from repo_url.  If already cloned, fetch.
    def basic_fetch_clone(self, parent_dir, repo, repo_url):
        repo_path = os.path.join(parent_dir, repo)
        self.pr_log()
        if os.path.isdir(repo_path):
            os.chdir(repo_path)
            self.pr_log("updating %s" % os.getcwd())
            self.check_remote_url("origin", repo_url)
            self.git__fetch('origin')
            self.git__fetch('origin', tags=True)
            return 'fetch'
        else:
            if not os.path.isdir(parent_dir):
                os.mkdir(parent_dir)
            os.chdir(parent_dir)
            self.git__clone(repo_url, repo)
            if not os.path.isdir(repo_path):
                self.pr_log('Error when cloning %s, giving up.' % repo_path)
                exit(1)
            return'clone'

    def fetch_infra_repos(self):
        self.pr_log('Updating internal infrastructure repos (%s)' % self.internal_repos_base)
        for repo in self.infra_repo_list:
            url = self.infra_repo_dict[repo]['internal_git_url']
            self.basic_fetch_clone(self.internal_repos_base, repo, url)

            branch = self.infra_repo_dict[repo]['branch']
            self.checkout_branch(self.internal_repos_base, repo, branch)
        self.pr_log()

    def fetch_source_repos(self):
        self.pr_log('Updating repos that point to internal and portal git (%s)' % self.internal_repos_base)
        for repo in self.repo_list:
            url = self.repo_dict[repo]['internal_git_url']
            fetch_clone = self.basic_fetch_clone(self.internal_repos_base, repo, url)
            if 'external_git_url' in self.repo_dict[repo]:
                # fetch branches but not tags from external git
                if fetch_clone == 'clone':
                    os.chdir(self.internal_repo_path(repo))
                    self.git__remote_add_portal(repo)
                external_url = self.repo_dict[repo]['external_git_url']
                self.check_remote_url("portal", external_url)
                self.git__fetch('portal')
        self.pr_log()
        self.pr_log('Updating repos that point to portal git only (%s)' % self.portal_repos_base)
        for repo in self.repo_list:
            if 'external_git_url' in self.repo_dict[repo]:
                url = self.repo_dict[repo]['external_git_url']
                self.basic_fetch_clone(self.portal_repos_base, repo, url)

    def fetch_all_repos(self):
        if not os.path.isdir(self.internal_repos_base):
            os.mkdir(self.internal_repos_base)
        if not os.path.isdir(self.portal_repos_base):
            os.mkdir(self.portal_repos_base)
        self.fetch_infra_repos()
        self.fetch_source_repos()
        self.pr_log('Done')
        self.pr_log()
        self.pr_log('========================================================================')

#=========================================================================================
# Generate Portal Report
#=========================================================================================
class PortalReport:
    def repo_string(self, repo):
        repo = self.external_repo_name(repo)
        return "\nrepository: %s\n\n" % repo

    def repo_tag_report(self, repo):
        report = ''

        if self.stage_is_pr:
            report += "Tags pushed out to external git:\n"
        else:
            report += "Tags added to internal git:\n"
        for branch in self.repo_dict[repo]['branches']:
            report += "tag:    %s\n" % self.branch_info[repo][branch]['tag_name']
            report += 'commit: %s\n' % self.branch_info[repo][branch]['shortlog1']

        return report + '\n'

    def branch_wiki(self, repo, branch):
        if not self.stage_is_pr:
            return ''

        portal_repo = self.external_repo_name(repo)
        tag_name = self.branch_info[repo][branch]['tag_name']

        new_br = self.branch_info[repo][branch]['new_branch']
        if not new_br and len(self.branch_info[repo][branch]['commits']) == 0:
            return ''

        wiki = ''
        wiki += '\n\n'
        wiki += "++wiki:\n"

        if new_br:
            wiki += "*New branch added:*\n"
            wiki += "*Repo name*: %s *Branch name*: %s *Tag name:* %s\n" % (portal_repo, branch, tag_name)
        else:
            wiki += "*Repo name*: %s *Branch name*: %s *Tag name:* %s\n" % (portal_repo, branch, tag_name)
            wiki += "| %s | %s | %s |\n" % ('*ID*','*Comment*','*GIT Commit*')
            for commit in self.branch_info[repo][branch]['commits']:
                sha = commit['sha']
                subject = commit['subject']
                bug_id = commit['bug_id']
                longsha = commit['longsha']

                commit_path = '[[ https://github.com/altera-opensource/%s/commit/%s ][ %s ]]' % \
                    (portal_repo, longsha, longsha)

                wiki += "| %s | %s | %s |\n" % (bug_id, subject, commit_path)

        wiki += "--wiki:\n"
        return wiki

    def repo_branch_report(self, repo, branch):
        tag_name = self.branch_info[repo][branch]['tag_name']

        # Human readable part of report for this branch
        report = ''
        report += "branch      : %s\n" % branch
        report += "branch tag  : %s\n" % tag_name
        if self.branch_info[repo][branch]['new_branch']:
            report += 'Pushing new branch to external git\n\n'
        else:
            report += "new commits : %s\n" % len(self.branch_info[repo][branch]['commits'])
            report += self.branch_info[repo][branch]['shortlog']

        report += self.branch_wiki(repo, branch)
        report += '\n\n'
        return report

    def one_line_of_hyphens(self):
        return "-----------------------------------------------------------------------\n"

    def one_line_of_equals(self):
        return "=======================================================================\n"

    def create_full_report(self):
        # One blank line at top of report.
        report = '\n'

        # Report header for rc or pr.
        if self.rel_stage == 'rc1':
            report += 'Script-generated report of what we tagged today in internal git.\n'
            report += 'These rc tags/branches will retagged as pr and pushed to the portal in two weeks.\n\n'
        elif self.stage_is_rc:
            report += 'Script-generated report of what we tagged today in internal git.\n'
            report += 'These tags/branches will be pushed to the portal on the next\n\n'
            report += 'scheduled update day.\n\n'
        elif self.stage_is_pr:
            report += 'Script-generated report of tags/branches that were pushed to the portal git today.\n\n'
        elif self.stage_is_eap:
            print "Do EAP releases go to the portal? - update script for this."
            # report += 'Script-generated report of tags/branches that were pushed to the portal git today.\n\n'
            exit(0)
        else:
            print "Unknown release stage"
            exit(0)

        new_branches = ''
        for repo in self.repo_list:
            if 'external_repo_name' not in self.repo_dict[repo]:
                continue

            for branch in self.repo_dict[repo]['branches']:
                if self.branch_info[repo][branch]['new_branch']:
                    new_branches = new_branches + 'repo : %-20s   branch : %s\n' % (repo, branch)

        if new_branches != '':
            if self.stage_is_rc:
                report += 'The following new branches were tagged:\n'
            elif self.stage_is_pr:
                report += 'The following new branches were pushed:\n'
            elif self.stage_is_eap:
                print 'are new branches pushed to github for eap?'
                exit(0)
            report += new_branches

        first_name = self.email_user.split('.')[0].capitalize()
        report += '\n' + first_name + '\n'

        # Summary report section
        report += self.one_line_of_equals()
        for repo in self.repo_list:
            if 'external_repo_name' not in self.repo_dict[repo]:
                continue
            report += self.repo_string(repo)
            for branch in self.repo_dict[repo]['branches']:
                report += self.repo_branch_report(repo, branch)

            report += self.repo_tag_report(repo)
            report += self.one_line_of_hyphens()

        # Full log of changes
        report += self.one_line_of_equals() + self.one_line_of_hyphens() + '\n'
        for repo in self.repo_list:
            if 'external_repo_name' not in self.repo_dict[repo]:
                continue

            for branch in self.repo_dict[repo]['branches']:
                if not self.branch_info[repo][branch]['new_branch']:
                    log = self.branch_info[repo][branch]['log']
                    if log != '':
                        report += 'log of %s branch %s\n\n' % (repo, branch)
                        report += log
                        report += '\n' + self.one_line_of_hyphens() + '\n'
                else:
                    report += 'log of %s branch %s\n\n' % (repo, branch)
                    report += '  Too many commits to list because this is a new branch\n\n'
                    report += '\n' + self.one_line_of_hyphens() + '\n'

        self.portal_report = report

    #=========================================================================================
    # Email functions
    #=========================================================================================

    def send_email(self, smtp_server, to_addrs, msg):
        self.pr_log('smtp_server             : %s' % smtp_server)
        
        # reply-to email address
        user_corporate_email = self.email_user + '@intel.com'
        
        # code from http://pymotw.com/2/smtplib/
        try:
            server = smtplib.SMTP(smtp_server)
#            server = smtplib.SMTP('smtp.office365.com', '587')
            # server.set_debuglevel(True)

            # If server has STARTTLS, it is the office365 server and needs
            # authentication and the opensouce.altera.com from address.
            server.ehlo()
            msg['From'] = user_corporate_email

            self.pr_log('From: %s' % msg['From'])
            self.pr_log('Email subject: %s' % msg['Subject'])
            self.pr_log()

            server.sendmail(msg['From'], to_addrs, msg.as_string())
        except:
            raise
        finally:
            server.quit()

    def send_report_email(self, to_list, fn, subject):
        to_list.append(self.email_user)
        self.pr_log('sending to this list: ' + str(to_list))

        try:
            rf = open(fn, 'r')
            report = rf.read()
            rf.close()
        except:
            self.pr_log('Could not open report file %s' % fn)
            exit(1)

        to_addrs = []
        cc_addrs = []

        for addr in to_list:
            to_addrs.append(addr + '@intel.com')

        self.pr_log('to                      : %s' % str(to_addrs))
        self.pr_log('cc                      : %s' % str(cc_addrs))

        msg = MIMEMultipart('alternative')
        msg['Subject'] = subject
        COMMASPACE = ', '
        msg['To'] = COMMASPACE.join(to_addrs)
        if cc_addrs != []:
            msg['Cc'] = COMMASPACE.join(cc_addrs)

        # Send the email in such a way that it won't get re-formatted by Outlook.
        html_msg = "\n<html>\n<head></head>\n<body><pre><code>"
        html_msg += report
        html_msg += "\n</code></pre>\n</body>\n</html>"

        msg.attach(MIMEText('', 'plain'))
        msg.attach(MIMEText(html_msg, 'html'))

        self.send_email(self.smtp_server, to_addrs, msg)

        self.pr_log('Success (posted as email)...')

    def send_file_email(self, to_list, which_file):
        if which_file == 'report':
            fn = self.report_file_name_full
            subject = 'Portal git report : ' + self.release
        else:
            fn = self.log_file_name_full
            subject = 'portal-update.py log for : ' + self.release

        self.send_report_email(to_list, fn, subject)

    def email_report(self, args_email):
        if args_email == 'all':
            self.send_file_email(self.portal_recipients, 'report')
        elif args_email == 'me':
            self.send_file_email([], 'report')
            self.send_file_email([], 'log')
        else:
            self.pr_log("Invalid parameter - specify 'me' or 'all'")

        exit(0)

#=========================================================================================
# class Release - parent class of specific release targets
#=========================================================================================
class Release(GitOperations, GlobalsConstants):
    # Initialize log
    logging = ''

    # Release configuration (i.e. which branches)
    repo_list = []
    repo_dict = {}

    # Info from git branches
    branch_info = {}

    # Info on tags that were found or are going to be created
    tag_info = {}

    # Urls to pushed tags/commits/branches on github
    external_git_pushed_urls = []

    tag_errors = False
    need_to_push = False

    def __init__(self, rel, prev, platforms):
        self.platforms = platforms

        self.conf_file = os.path.expanduser("~/.portal-update-%s.conf" % self.rel_type)
        self.global_conf_file = os.path.expanduser("~/.portal-update.conf")

        # get user email address user (email.user@intel.com)
        self.email_user = None
        self.get_global_conf()

        # If some repos aren't cloned yet, get them because we need their config info
        self.fetch_infra_repos()

        # Determine name of report file and where to save it in git, i.e.
        #   linux-infra/portal-release/<rel num>/
        self.set_global_release_parameters(rel, prev)

        # Get list of repos with branches, paths to git repos
        self.get_release_config()

        self.print_release_conf()
        self.verify_release_conf()

    def print_release_conf(self):
        self.pr_log('rel_type                : %s' % self.rel_type)
        self.pr_log('rel_target              : %s' % self.rel_target)
        self.pr_log('release                 : %s' % self.release)
        if len(self.platforms) == 0:
            self.pr_log('platforms               : %s' % "none specified")
        else:
            self.pr_log('platforms               : %s' % self.platforms)
        self.pr_log('rel_num                 : %s' % self.rel_num)
        self.pr_log('rel_stage               : %s' % self.rel_stage)
        if self.prev_release != None:
            self.pr_log('prev_release            : %s' % self.prev_release)
        self.pr_log('branch_config_file_name : %s' % self.branch_config_file_name)
        self.pr_log('report_file_name_full   : %s' % self.report_file_name_full)
        self.pr_log('repo_list               : %s' % self.repo_list)
        self.pr_log('num of repos            : %s' % len(self.repo_list))

        # specific to ACDS type releases
        self.pr_log('update_num              : %s' % self.update_num)
        self.pr_log()

    def save_file(self, file_name, contents, quiet=False):
        if not contents or contents == '':
            self.pr_log('Error - no contents for report/script %s' % file_name)
            exit(1)

        try:
            report_file = open(file_name, 'w')
            report_file.write(contents)
            report_file.close()
            if not quiet:
                self.pr_log('Saved report : %s' % file_name)
        except:
            self.pr_log('Error writing %s' % file_name)
            exit(1)

    def save_report(self):
        # From this point on, we are goint to:
        #    create and save a new report
        if not os.path.isdir(self.reports_dir):
            os.makedirs(self.reports_dir)

        # such as /home/atull/bin/linux-infra/portal-release/14.07.02/14.07.02_rc1.txt
        report_fn = self.release + '.txt'
        full_fn = os.path.join(self.reports_dir, report_fn)

        # generate the report
        self.save_file(full_fn, self.portal_report)
        self.pr_log('')

    def pr_log(self, msg=''):
        print msg
        self.logging += msg + '\n'

    def save_log(self):
        # From this point on, we are goint to:
        #    create and save a new report (and push script)
        if not os.path.isdir(self.reports_dir):
            os.makedirs(self.reports_dir)

        # generate the report
        self.save_file(self.log_file_name_full, self.logging)

    def set_global_email(self, set_email=None):
        re_email = re.compile('(.*)@intel.com')

        if set_email == None:
            while True:
                set_email = raw_input("What is your email address? (...@intel.com) >> ")
                if not re.match(re_email, set_email):
                    print("*** Email must end with '@intel.com'")
                    print("*** Let's try again...")
                else:
                    break
        else:
            if not re.match(re_email, set_email):
                print("*** Email must end with '@intel.com'")
            exit(0)

        email_user = re.sub(re_email, '\\1', set_email)
        print "setting email to " + email_user + "@intel.com"
        self.email_user = email_user
        self.update_global_conf()
        
    def get_global_conf(self):
        try:
            fn = self.global_conf_file
            pr_f = open(fn, 'r')
            pr_conf_lines = pr_f.readlines()
            pr_f.close()
        except:
            self.set_global_email()
            return

        conf = { 'email_user':None }
        for line in pr_conf_lines:
            line = line.strip()
            key = line.split("=")[0]
            value = line.split("=")[1]
            conf[key] = value

        self.email_user = conf['email_user']

    def update_global_conf(self):
        pr_conf = ''
        if self.email_user != None:
            pr_conf += 'email_user=%s\n' % self.email_user
        self.save_file(self.global_conf_file, pr_conf, quiet=True)

    # save release and prevous release numbers in ~
    def get_saved_conf(self):
        try:
            pr_f = open(self.conf_file, 'r')
            pr_conf_lines = pr_f.readlines()
            pr_f.close()
        except:
            # self.pr_log('Could not open config file "%s"' % self.conf_file)
            return (None, None)

        conf = { 'rel':None, 'prev':None }
        for line in pr_conf_lines:
            line = line.strip()
            key = line.split("=")[0]
            value = line.split("=")[1]
            conf[key] = value

        return (conf['rel'], conf['prev'])

    def update_saved_conf(self):
        pr_conf = ''
        pr_conf += 'rel=%s\n' % self.release
        if self.prev_release != None:
            pr_conf += 'prev=%s\n' % self.prev_release
        self.save_file(self.conf_file, pr_conf, quiet=True)

    def set_global_release_parameters(self, rel, prev):
        (conf_rel, conf_prev) = self.get_saved_conf()

        if rel == None:
            rel = conf_rel
        if rel == None:
            self.pr_log("Need to specify --rel")
            exit(1)

        if self.prev_required:
            if prev == None:
                prev = conf_prev
            if prev == None:
                self.pr_log("Need to specify --prev")
                exit(1)
            if self.rel_to_rel_stage(prev, False) == None:
                prev = prev + '_pr'
            if self.rel_to_rel_stage(prev, False) != 'pr':
                self.pr_log("--prev (%s) must be a pr, such as 18.07.01_pr" % prev)
                exit(1)
            if self.rel_to_rel_stage(prev) != 'pr':
                self.pr_log("--prev must be a pr, such as 18.07.01_pr")
                exit(1)
        else:
            prev = None

        self.release = rel
        self.prev_release = prev

        self.rel_num = self.rel_to_rel_num(rel)
        self.prev_num = self.rel_to_rel_num(prev)
        self.rel_stage = self.rel_to_rel_stage(rel)
        self.stage_is_rc = self.rel_stage[0:2] in {'rc', 'RC'}
        self.stage_is_pr = self.rel_stage in {'pr', 'PR'}
        self.stage_is_eap = self.rel_stage == 'EAP'
        self.update_num = self.rel_to_update_num(rel)
        self.platform = self.rel_to_platform(rel)
        self.rel_target = self.rel_to_rel_target(rel)
        self.generate_all_platform_tags()

        # Exits in case of errors
        self.validate_rel_descriptors()

        self.update_saved_conf()

        self.reports_dir = os.path.join(os.path.dirname(__file__), '..', 'portal-release', self.rel_num)
        self.report = self.release + '.txt'
        self.report_file_name_full = os.path.join(self.reports_dir, self.report)
        self.log_fn = self.release + '-log.txt'
        self.log_file_name_full = os.path.join(self.reports_dir, self.log_fn)

        self.branch_config_file_name = os.path.join(self.internal_repos_base,
                                                    self.linux_tags_repo,
                                                    self.branch_config_file)

    #-----------------------------------------------------------
    # Routines for getting configuration from branch config list
    #-----------------------------------------------------------
    # Look at config file to find out:
    #  * Which branches are to be pushed
    #  * Which internl git repos are involved
    #  * Which remote git repos to push them to
    def get_release_config(self):
        temp_config_dict = {}
        cfg = self.branch_config_file_name

        # Read config file into a list of lines
        try:
            cfg_f = open(cfg, 'r')
            config = cfg_f.readlines()
            cfg_f.close()
        except:
            self.pr_log('Could not open config file %s' % cfg)
            exit(1)

        # Convert to a dictionary of lists
        for line in config:
            line = line.strip()
            # skip comments
            if re.match(re.compile(".*#.*"), line):
                continue
            # skip lines that don't have =
            if not re.match(re.compile(".*=.*"), line):
                continue
            list_name = line.split("=")[0]
            temp = line.split("=")[1]
            temp = re.sub("'", '', temp)
            list_value = temp.split(",")
            temp_config_dict[list_name] = list_value

        # the 'repo_list' in the config file gives us config_repo_list
        # config_repo_list has BASH-friendly names of internal repos.
        # These names have _ instead of -
        config_repo_list = temp_config_dict['repo_list']
        temp_config_dict.pop('repo_list')

        if len(config_repo_list) != len(set(config_repo_list)):
            self.pr_log("error: an internal repo name is repeated in the repo_list")
            self.pr_log("- error is in config file %s" % cfg)
            self.pr_log(config_repo_list)
            exit(1)

        for repo in config_repo_list:
            dict_config_list = temp_config_dict[repo]
            temp_config_dict.pop(repo)
            internal_url = dict_config_list.pop(0)
            external_url = dict_config_list.pop(0)
            if external_url == '':
                continue

            branches = dict_config_list

            internal_repo_name = internal_url.split(":")[1]

            if internal_repo_name in self.repo_dict:
                self.pr_log("error: an internal repo name is repeated in the self.repo_dict %s" % internal_repo_name)
                self.pr_log("- error is in config file %s" % cfg)
                exit(1)

            if internal_url == '':
                self.pr_log("error: an internal url is not specified for repo %s" % internal_repo_name)
                self.pr_log("- error is in config file %s" % cfg)
                exit(1)

            if branches == []:
                self.pr_log("error: branches not specified for repo %s" % internal_repo_name)
                self.pr_log("- error is in config file %s" % cfg)
                exit(1)

            self.repo_dict[internal_repo_name] = {}
            self.repo_dict[internal_repo_name]['branches'] = branches
            self.repo_dict[internal_repo_name]['internal_git_url'] = internal_url
            self.repo_dict[internal_repo_name]['external_git_url'] = external_url
            try:
                self.repo_dict[internal_repo_name]['external_repo_name'] = external_url.split("/")[1]
            except:
                self.pr_log("ERROR: for repo %s, external_repo_name is missing an expected slash" % internal_repo_name)
                self.pr_log("- error is in config file %s" % cfg)
                exit(1)

            self.repo_list.append(internal_repo_name)

        config_error_repos = []
        for repo in temp_config_dict.keys():
            dict_config_list = temp_config_dict[repo]
            temp_config_dict.pop(repo)
            internal_url = dict_config_list.pop(0)
            external_url = dict_config_list.pop(0)
            if external_url != '':
                config_error_repos.append(repo)
        if config_error_repos != []:
            self.pr_log("error: config file has repo with external repo that is not in repo_list")
            self.pr_log("- error is in config file %s" % cfg)
            exit(1)

    def print_release_config(self):
        self.pr_log()
        for repo in self.repo_list:
            self.pr_log(repo + ' : ' + json.dumps(self.repo_dict[repo], indent=4))

    def internal_repo_path(self, repo):
        return os.path.join(self.internal_repos_base, repo)

    def portal_repo_path(self, repo):
        return os.path.join(self.portal_repos_base, repo)

    def external_repo_name(self, repo):
        if 'external_repo_name' in self.repo_dict[repo]:
            return self.repo_dict[repo]['external_repo_name']
        return repo

    #=======================================================================
    # Get info from git on this release
    #=======================================================================
    def describe_if_possible(self, name, ref):
        if ref == None:
            self.pr_log('%-20s : %s' % (name, 'None'))
            return
        try:
            shortlog = self.log('--pretty=%an %s', '-1', ref).strip()
            descr = self.describe(ref)
            self.pr_log('%-20s : %s %s' % (name, descr, shortlog))
        except:
            shortlog = self.log('--pretty=%h %an %s', '-1', ref).strip()
            self.pr_log('%-20s : %s' % (name, shortlog))

    def gather_log_info(self, repo, branch):
        self.branch_info[repo][branch]['commits'] = []
        self.branch_info[repo][branch]['log'] = ''
        self.branch_info[repo][branch]['shortlog'] = ''

        # Try getting log starting with either:
        # * previous release tag (use the sha since it will be None if it wasn't previously tagged) or
        # * current portal branch HEAD (is None if branch has not been pushed in another release before)
        for range_start in [ self.branch_info[repo][branch]['portal_prev_tag_sha'],
                             self.branch_info[repo][branch]['portal_head_sha'] ]:
            if range_start != None:
                break
        if range_start == None:
            return
        log_range = range_start + '..' + self.branch_info[repo][branch]['tag_sha']

        self.branch_info[repo][branch]['log'] = self.log(log_range)
        self.branch_info[repo][branch]['shortlog'] = self.log('--pretty=%h %an %s', log_range)

        #todo extract sha's from stortlog instead
        sha1s = self.log('--pretty=%H', log_range)
        #todo try using splitline
        sha1s = sha1s.split('\n')
        sha1s.remove('')

        for longsha in sha1s:
            sha = longsha[0:7]
            subject_line = self.subject(longsha)
            re_fb = re.compile("^(((Fog(B|b)ugz|HSD)) #([0-9-]+))(:| -|) (.*)")
            if re.match(re_fb, subject_line):
                bug_id = re.sub(re_fb, '\\1', subject_line)
                subject = re.sub(re_fb, '\\7', subject_line)
            else:
                bug_id = 'community'
                subject = subject_line

            commit = { 'sha':sha,
                       'longsha':longsha,
                       'bug_id':bug_id,
                       'subject':subject }
            self.branch_info[repo][branch]['commits'].append(commit)

    def detect_rebased_branch(self, repo, branch, info):
        if self.remote_branch_contains_sha('origin', branch, info['portal_head_sha']):
            return False

        self.pr_log('************************************************************************')
        self.pr_log(' origin branch does not contain the portal head.')
        self.pr_log(' It appears that the branch was rebased after already being released')
        self.pr_log('************************************************************************')
        return True

    def gather_branch_info_common(self, repo, branch):
        info = self.branch_info[repo][branch]

        info['portal_head_sha'] = self.remote_head_sha('portal', branch)

        info['tag_error'] = False
        info['tag_explanation'] = None

        # Flags that say what pushes need to be done for this branch
        info['push_origin_tag'] = False
        info['push_portal_tag'] = False
        info['push_portal_head'] = False

        # Get the tag name that has been set for this release
        info['tag_name'] = self.get_current_tag_name(repo, branch)

        # Get some history/context
        info['latest_rc_tag'] = self.latest_rc(branch)
        info['prev_tag_name'] = self.get_prev_tag_name(repo, branch)

        # Determine whether local, origin, or portal has already been tagged
        info['local_tag_sha'] = self.git__sha(info['tag_name'])
        info['origin_tag_sha'] = self.remote_tag_sha('origin', info['tag_name'])
        info['portal_tag_sha'] = self.remote_tag_sha('portal', info['tag_name'])
        info['portal_prev_tag_sha'] = self.remote_tag_sha('portal', info['prev_tag_name'])

        # Has this branch been pushed to the portal before?
        info['new_branch'] = info['portal_head_sha'] == None and info['portal_prev_tag_sha'] == None
#        if self.prev_required:
#            if self.remote_tag_sha('portal', info['prev_tag_name']) == None:
#                info['new_branch'] = True
        if info['new_branch']:
            self.pr_log('New branch detected')
        # Detect rebased branches == ERROR
        if info['portal_head_sha'] != None and self.detect_rebased_branch(repo, branch, info):
            self.save_log()
            exit(1)

        info['local_is_tagged'] = info['local_tag_sha'] != None
        info['portal_is_tagged'] = info['portal_tag_sha'] != None
        info['origin_is_tagged'] = info['origin_tag_sha'] != None

        info['tag_local_equals_origin'] = info['origin_is_tagged'] and info['local_tag_sha'] == info['origin_tag_sha']
        info['tag_local_equals_portal'] = info['portal_is_tagged'] and info['local_tag_sha'] == info['portal_tag_sha']

        return info

    def gather_all_branch_info(self):
        if self.prev_required:
            self.pr_log('Gathering info from git on commits between these two sets of tags:')
            self.pr_log(' * %s' % self.release)
            self.pr_log(' * %s' % self.prev_release)
        else:
            self.pr_log('Gathering info from git for these tags:')
            self.pr_log(' * %s' % self.all_platform_tags)

        for repo in self.repo_list:
            os.chdir(self.internal_repo_path(repo))
            self.branch_info[repo] = {}
            self.tag_info[repo] = {}
            self.gather_tag_info(repo)
            for branch in self.repo_dict[repo]['branches']:
                self.pr_log()
                self.pr_log('repo: %-20s  br: %s' % (repo, branch))

                self.branch_info[repo][branch] = {}

                self.gather_branch_info(repo, branch)

                # If not a huge # of commits, break out log info on new changes
                if self.prev_required:
                    self.gather_log_info(repo, branch)

        self.pr_log()
        if self.tag_errors:
            self.pr_log("There were tag errors. See above.  Exiting.")
            self.save_log()
            exit(1)
        if not self.need_to_push:
            self.pr_log("Everything was already pushed, so no need to push.")
#            self.save_log()
#            exit(0)

    # Print out some helpful url's for doublechecking that pushes happened
    def links_to_github(self):
        report = ''
    
        for repo in self.repo_list:
            if 'external_repo_name' not in self.repo_dict[repo]:
                continue
            report += '\n'
            report += "-----------------------------------------------------------------------\n"
            report += 'repo:   %s\n' % repo

            for branch in self.repo_dict[repo]['branches']:
                portal_repo = self.external_repo_name(repo)
                longsha = self.branch_info[repo][branch]['tag_sha']
                tag_name = self.branch_info[repo][branch]['tag_name']

                report += "-----------------------------------------------------------------------\n"
#                report += 'branch: %s\n' % branch
#                report += 'tag:    %s\n' % tag_name
#                report += self.branch_info[repo][branch]['shortlog1'] + '\n'
                report += self.branch_info[repo][branch]['shortlog1']

                url = 'https://github.com/altera-opensource/%s/releases/tag/%s' % (portal_repo, tag_name)
                report += "tag    : %s\n" % url
                self.external_git_pushed_urls.append(url)

                url = 'https://github.com/altera-opensource/%s/tree/%s' % (portal_repo, branch)
                report += "branch : %s\n" % url
                self.external_git_pushed_urls.append(url)

                url = 'https://github.com/altera-opensource/%s/commit/%s' % (portal_repo, longsha)
                report += "commit : %s\n" % url
                self.external_git_pushed_urls.append(url)
            report += "-----------------------------------------------------------------------\n"

        return report

    #=======================================================================
    # Functions for pushing tags/branches out to git
    #=======================================================================

    # Returns True if error
    def git__push(self, push_cmd, remote, sha, ref_type, name):
        rc = 0
        refspec = '%s:refs/%s/%s' % (sha, ref_type, name)

        if push_cmd == 'push':
            self.pr_log(' $ git push %s %s' % (remote, refspec))
        else:
            self.pr_log(' $ git push %s %s %s' % ('--dry-run', remote, refspec))

        if push_cmd != 'push' and push_cmd != 'dry_run':
            return rc != 0

        if push_cmd == 'push':
            (msg, err, rc) = self.git_cmd_stdout_err_rc('push', remote, refspec)
        else:
            (msg, err, rc) = self.git_cmd_stdout_err_rc('push', '--dry-run', remote, refspec)

        regex = re.compile(r"\\033.*\\033\[0m", re.MULTILINE|re.DOTALL)
        err = regex.sub('\n [server responded with usual security boilerplate]\n', err)

        err = err.replace('\r\n','\n')

        if msg != '':
            self.pr_log(msg)
        if err != '':
            self.pr_log(err)

        return rc != 0

    def push_release_to_repos(self, push_cmd, remote):
        err_status = 0

        for repo in self.repo_list:
            repo_path = os.path.join(self.internal_repos_base, repo)
            os.chdir(repo_path)

            for branch in self.repo_dict[repo]['branches']:
                tag_name = self.branch_info[repo][branch]['tag_name']
                tag_sha = self.branch_info[repo][branch]['tag_sha']
                self.pr_log('repo   : %-30s remote : %s' % (repo, remote))
                self.pr_log('branch : %-30s tag    : %s' % (branch, tag_name))

                # Push tag to either internal or portal git
                if remote == 'origin':
                    push_tag = self.branch_info[repo][branch]['push_origin_tag']
                else:
                    push_tag = self.branch_info[repo][branch]['push_portal_tag']

                if push_tag:
                    if self.branch_info[repo][branch]['tag_explanation'] != None:
                        self.pr_log('  * '.join(self.branch_info[repo][branch]['tag_explanation'].splitlines(True)))
                    if self.git__push(push_cmd, remote, tag_sha, 'tags', tag_name):
                        err_status = 1
                        if push_cmd == 'push':
                            self.save_log()
                            exit(1)
                else:
                    self.pr_log("Tag already pushed to %s" % remote)

                # Do not adjust HEAD of branch on internal git.
                # For portal, set head of branch to be the tag.
                if remote == 'portal':
                    if self.branch_info[repo][branch]['push_portal_head']:
                        if self.git__push(push_cmd, remote, tag_sha, 'heads', branch):
                            err_status = 1
                            if push_cmd == 'push':
                                self.save_log()
                                exit(1)
                    else:
                        self.pr_log("Don't need to push branch head since commit already exists in %s branch" % remote)

                self.pr_log("---   ----   ---   ----   ---   ----   ---   ----   ---   ----   ---   ----   ---   ----")
                self.pr_log()

        # if this is a dry run, let the dry run run and give up before doing the real push
        if err_status != 0:
            self.pr_log("There were errors in this dry run.  Giving up.  Not doing the real push.")
            self.save_log()
            exit(1)

#=========================================================================================
# release_Linux = specifics for Linux releases
#=========================================================================================
class release_Linux(Release, PortalReport):
    rel_type = 'Linux'
    branch_config_file = 'release-branch-config.sh'
    # We need to know what previous PR to diff from
    prev_required = True

    def rel_to_update_num(self, rel):
        return None

    def rel_to_platform(self, rel):
        return None

    def rel_to_rel_target(self, rel):
        return None

    def verify_release_conf(self):
        return

    def generate_all_platform_tags(self):
        return

    def generate_tag_name_for_br(self, branch, rel_num):
        if rel_num == None:
            return None
        return 'rel_' + branch + '_' + rel_num

    def rel_to_rel_num(self, rel):
        if rel == None:
            return None
        try:
            rel_num = rel.split('_')[0]
            return rel_num
        except:
            self.complain_rel_num_format(rel)
            exit(1)

    def rel_to_rel_stage(self, rel, complain=True):
        try:
            stage = rel.split('_')[1]
            if re.match(re.compile('^(rc[1-8]|pr)$'), stage):
                return stage
            self.complain_rel_num_format(rel, 'stage looks wrong %s' % stage)
            exit(1)
        except:
            if complain:
                self.complain_rel_num_format(rel)
                exit(1)

    def complain_rel_num_format(self, rel_num, details=None):
        year = time.strftime("%y")
        self.pr_log()
        self.pr_log('Incorrect release specifier: %s' % rel_num)
        if details:
            self.pr_log(details + ' <----<<<')
            self.pr_log()
        self.pr_log('Release number format is: YY.MM.RR_STAGE')
        self.pr_log(' YY is year (%s)' % year)
        self.pr_log(' MM is month (01-12)')
        self.pr_log(' RR is release number of that month (01,02,03)')
        self.pr_log(' STAGE is rc1, rc2, rc3, or pr')
        self.pr_log()
        self.pr_log('If you are in doubt, please ask.')
        self.pr_log('If you get this wrong, you will have to fix a *lot*')
        self.pr_log('of tags.  It will be a big pain. You were warned :)')
        self.pr_log()
        self.pr_log(' for example: %s.10.01_rc1 or %s.10.01_pr' % (year, year))
        exit(0)

    def validate_rel_descriptor(self, rel_num):
        if len(rel_num.split('.')) != 3:
            self.complain_rel_num_format(rel_num,
                                         'yy.mm.rr field looks wrong')
        if len(rel_num.split('-')) != 1:
            self.complain_rel_num_format(rel_num,
                                         'Note: "-" is forbidden.')
        if len(rel_num.split('_')) != 2:
            self.complain_rel_num_format(rel_num,
                                         'Note: should have "_" followed by stage.')

        rel_num_num = rel_num.split('_')[0]
        yy = rel_num_num.split('.')[0]
        mm = rel_num_num.split('.')[1]
        rr = rel_num_num.split('.')[2]

        now = datetime.datetime.now()
        current_yy = str(now.year - 2000)
        current_mm = str(now.month)

        valid_yy = [current_yy]
        if current_mm == '12':
            next_yy = str(now.year - 2000 + 1)
            valid_yy.append(next_yy)
        elif current_mm == '01':
            prev_yy = str(now.year - 2000 - 1)
            valid_yy.append(prev_yy)

        if yy not in valid_yy:
            self.complain_rel_num_format(rel_num, "Invalid YY (%s) in YY.MM.RR" % (yy))
            exit(1)

        valid_mm = ['01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12']
        if mm not in valid_mm:
            self.complain_rel_num_format(rel_num, "Invalid MM (%s) in YY.MM.RR" % (mm))
            exit(1)

        valid_rr = ['01', '02', '03', '04']
        if rr not in valid_rr:
            self.complain_rel_num_format(rel_num, "Invalid RR (%s) in YY.MM.RR" % (rr))

    def validate_rel_descriptors(self):
        self.validate_rel_descriptor(self.release)
        if self.prev_release == None:
            return
        # todo, this can break if previous release was last year
        #self.validate_rel_descriptor(self.prev_release)
        if self.release == self.prev_release:
            self.pr_log("Error: release == previous release.")
            self.pr_log('release        : %s' % rel)
            self.pr_log('previous rel   : %s' % prev)
            self.pr_log(' Need to specify --rel and --prev')
            exit(1)
        if self.rel_num == self.prev_num:
            self.pr_log("Error: release number == previous release number.")
            self.pr_log('release        : %s' % self.release)
            self.pr_log('previous rel   : %s' % self.prev_release)
            self.pr_log(' Need to specify --rel and --prev')
            exit(1)

    # Linux release specific: create a tagging report for the
    # linux-tags repo
    def create_tags_report(self):
        tags_list_report = ''
        for repo in self.repo_list:
            for branch in self.repo_dict[repo]['branches']:
                tag_name = self.branch_info[repo][branch]['tag_name']
                tags_list_report += '%s:%s\n' % (repo, tag_name)
        return tags_list_report

    # Linux release specific: create a tagging report for the
    # linux-tags repo and commit it
    def create_commit_tags_report(self):
        self.linux_tags_repo_path = os.path.join(self.internal_repos_base,
                                                 self.linux_tags_repo)
        altera_tags_file_name = os.path.join(self.linux_tags_repo_path,
                                             self.linux_altera_tags_name)

        # tags report: generate it, commit it
        os.chdir(self.linux_tags_repo_path)
        branch = self.infra_repo_dict[self.linux_tags_repo]['branch']

        self.git__reset_hard_to_branch('origin/' + branch)
        self.save_file(altera_tags_file_name, self.create_tags_report())
        self.git__add(self.linux_altera_tags_name)
        self.git__commit("portal update %s" % self.release)

        # tags report: save info for tagging it by the tagging script
        tag_name = self.generate_tag_name_for_br('master', self.release)
        sha = self.git__sha(branch)
        if not sha:
            self.pr_log("pwd: %s" % os.getcwd())
            self.pr_log('Error getting sha of %s' % (branch))
            self.save_log()
            exit(1)
        self.infra_repo_dict[self.linux_tags_repo]['tag_name'] = tag_name
        self.infra_repo_dict[self.linux_tags_repo]['sha'] = sha

    # Not used during dry run.  Only on real push.    
    def push_linux_tags_repo(self):
        err_status = 0

        branch = self.infra_repo_dict[self.linux_tags_repo]['branch']
        tag_name = self.infra_repo_dict[self.linux_tags_repo]['tag_name']
        sha = self.infra_repo_dict[self.linux_tags_repo]['sha']

        os.chdir(self.linux_tags_repo_path)

        # git push origin sha:refs/heads/master
        # git push origin sha:refs/tags/tagname
        if self.git__push('push', 'origin', sha, 'tags', tag_name):
            err_status = 1
            self.pr_log("Error pushing tag to linux-tags repo.")
            self.save_log()
            exit(1)

        if self.git__push('push', 'origin', sha, 'heads', branch):
            err_status = 1
            self.pr_log("Error pushing new HEAD to linux-tags repo.  Giving up.")
            self.save_log()
            exit(1)

    def push_release(self, push_cmd):
        if push_cmd == '':
            self.pr_log("* Not doing actual push, just printing out the git commands to console for review. *\n")
        elif push_cmd == 'dry_run':
            self.pr_log("*---------------------------------------*")
            self.pr_log("* Not doing actual push, doing dry run. *")
            self.pr_log("*---------------------------------------*\n")
        elif push_cmd == 'push':
            self.pr_log("*--------------------*")
            self.pr_log("* Doing actual push. *")
            self.pr_log("*--------------------*\n")
#            raw_input("Press Enter to continue...")
        else:
            print("error calling push_release, unsupported push_cmd=%s\n" % push_cmd)
            exit(1)

        if self.stage_is_rc:
            self.push_release_to_repos(push_cmd, 'origin')
        elif self.stage_is_pr:
            self.push_release_to_repos(push_cmd, 'origin')
            self.push_release_to_repos(push_cmd, 'portal')
        else:
            self.pr_log("Error - release is not pr or rc???")
            self.save_log()
            exit(1)
        if push_cmd == 'push':
            self.create_commit_tags_report()
            self.push_linux_tags_repo()

    # Assumes Linux releases
    # Assumes we have cd'd to the local repo
    def latest_rc(self, branch):
        tag_filter = 'rel_' + branch + '_' + self.rel_num + '_rc'
        rc_tags = self.git__get_tag_list([tag_filter + '*'])
        if len(rc_tags) == 0:
            return None

        rc = 0
        for tag in rc_tags:
            tag_rc = int(tag[-1])
            if tag_rc > rc:
                rc = tag_rc

        based_on_tag = tag_filter + str(tag_rc)
        return based_on_tag

    def need_to_tag(self, repo, branch, info):
        # for Linux release rc's are not pushed to portal
        if self.stage_is_rc:
            info['push_portal_tag'] = False

            # if none of local, origin, and portal have been tagged, then good.  We need to tag.
            if not info['local_is_tagged'] and not info['origin_is_tagged']:
                info['push_origin_tag'] = True
                return info

            # If all have been tagged and the tags match, then good, we've already tagged for this release
            if info['tag_local_equals_origin']:
                info['tag_sha'] = info['local_tag_sha']
                info['push_origin_tag'] = False
                info['push_portal_head'] = False
                return info
        else:
            # if none of local, origin, and portal have been tagged, then good.  We need to tag.
            if not info['local_is_tagged'] and not info['origin_is_tagged'] and not info['portal_is_tagged']:
                info['push_origin_tag'] = True
                info['push_portal_tag'] = True
                return info

            # If all have been tagged and the tags match, then good, we've already tagged for this release
            if info['tag_local_equals_origin'] and info['tag_local_equals_portal']:
                info['push_origin_tag'] = False
                info['push_portal_tag'] = False
                info['push_portal_head'] = False
                return info

        # We got here becase either not all have been tagged or the tags don't match.  Ugh.
        self.pr_log("ERROR, some but not all tagging done or tags don't match.")

        self.describe_if_possible('local tag', info['local_tag_sha'])
        self.describe_if_possible('origin tag', info['origin_tag_sha'])
        self.describe_if_possible('portal tag', info['portal_tag_sha'])
        info['tag_error'] = True
        return info

    # Now we know that tagging has not happened yet.  Determine the commit to tag.
    def determine_commit_to_tag(self, repo, branch, info):
        info['tag_explanation'] = ''
        if info['new_branch']:
            info['tag_explanation'] += '\nnew branch'

        if info['new_branch'] or self.rel_stage == 'rc1' or info['latest_rc_tag'] == None:
            info['tag_ref'] = 'origin/' + branch
            info['tag_explanation'] += '\ntag will be == internal branch head'
        else:
            info['tag_ref'] = info['latest_rc_tag']
            info['tag_explanation'] += '\ntag will be == previous release tag (%s)' % info['latest_rc_tag']

#        self.pr_log(json.dumps(info, indent=4))

        info['tag_sha'] = self.git__sha(info['tag_ref'])
        if info['tag_sha'] == None or info['tag_ref'] == None:
            self.pr_log("Error, tag_sha = %s for tag_ref = %s" % (info['tag_sha'], info['tag_ref']))
            exit(1)

        info['shortlog1'] = self.log('-1', '--pretty=%h %an %s', info['tag_sha'])
        
        info['tag_explanation'] += '\n ' + info['shortlog1']

        if info['new_branch']:
            info['push_portal_head'] = self.stage_is_pr
        elif info['portal_head_sha'] == info['tag_sha']:
            info['push_portal_head'] = False
        elif self.remote_branch_contains_sha('portal', branch, info['tag_sha']):
            # if portal branch contains the tag, move tag to == portal head    
            info['tag_ref'] = 'portal/' + branch
            info['tag_sha'] = self.git__sha(info['tag_ref'])
            info['shortlog1'] = self.log('-1', '--pretty=%h %an %s', info['tag_sha'])
            info['push_portal_head'] = False
            info['tag_explanation'] += ' tag adjusted to be == portal branch head'
            info['tag_explanation'] += '\n ' + info['shortlog1']
        elif self.remote_branch_contains_sha('origin', branch, info['portal_head_sha']):
            info['push_portal_head'] = self.stage_is_pr
        else:
            self.pr_log('error branch has been rebased')
            info['tag_error'] = True
        return info

    def get_prev_tag_name(self, repo, branch):
        return self.generate_tag_name_for_br(branch, self.prev_release)

    def get_current_tag_name(self, repo, branch):
        return self.generate_tag_name_for_br(branch, self.release)

    def gather_tag_info(self, repo):
        return

    # Linux release version
    # Generate a tag name for this branch, decide what commit to tag.
    def gather_branch_info(self, repo, branch):
        info = self.gather_branch_info_common(repo, branch)
        info = self.need_to_tag(repo, branch, info)

        if info['push_origin_tag'] or info['push_portal_head']:
            info = self.determine_commit_to_tag(repo, branch, info)
        else:
            info['shortlog1'] = self.log('-1', '--pretty=%h %an %s', info['local_tag_sha'])

        if info['tag_error']:
            self.tag_errors = True
        else:
            if info['push_origin_tag'] or info['push_portal_tag'] or info['push_portal_head']:
                self.need_to_push = True

        self.branch_info[repo][branch] = info

    def helpful_links(self):
        if self.stage_is_pr:
            self.pr_log(self.links_to_github())

#=========================================================================================
# release_ACDS = specifics for ACDS releases
#=========================================================================================
class release_ACDS(Release, PortalReport):
    rel_type = 'GSRD'
    branch_config_file = 'acds-release-branch-config.sh'
    # We NOT need to know what previous PR to diff from
    prev_required = False

    # todo add as parameter
    acds_platforms = ('A10', 'M10', 'S10')

    # For this type of release we will need to go to git to find tag names
    repo_tags = {}

    # <rel_num>_REL_[<platform>_]<target>__[_<update>]<stage>
    # i.e.
    # ACDS14.1_REL_GSRD_PR_UPDATE2  == olde, not supported any more
    # ACDS15.1_REL_GSRD_UPDATE1_RC1 == update moved before stage
    # ACDS14.0.2_REL_SGMII_PR
    #
    # * rel_num =  ACDS<yy>.<rn>[IR#]
    #     yy  = year (16,17,18)
    #     rn  = release number for the year (0, 0.1, 1, 1.1, etc)
    #     IR# = Intermediate Release IR1 IR2, etc or not present
    # * platform = A10, M10, S10 or not present
    # * target   = GSRD, PCIE, SGMI
    # * update   = UPDATE1 UPDATE2, or not present
    # * stage    = RC1..RC8, PR, EAP
    #     RC  = Release Candidates do not go to public github
    #     PR  = releases go to public github
    #     EAP = Early Access Program (may not go to public github)
    def rel_to_rel_num(self, rel):
        if rel == None:
            return None
        rel_num = rel.split('_')[0]
        if re.match(re.compile('^ACDS[0-9][0-9]\.[0-9](\.[0-9]|)(IR[1-9]|)$'), rel_num):
            return rel_num
        self.complain_rel_num_format(rel, 'First field looks wrong %s' % rel_num)

    # <rel_num>_REL_[<platform>_]<target>__[_<update>]<stage>
    # platform could be A10, M10, S10, or not present
    def rel_to_platform(self, rel):
        rel = self.release.split('_')
        if rel[2] in acds_release_targets:
            return None
        if rel[2] in self.acds_platforms:
            return rel[2]
        self.pr_log("ERROR: unknown platform (%s) in" % rel[2])
        self.pr_log("%s" % str(rel))
        exit(0)

    # <rel_num>_REL_[<platform>_]<target>__[_<update>]<stage>
    def rel_to_rel_target(self, rel):
        rel = self.release.split('_')
        if rel[2] in acds_release_targets:
            return rel[2]
        if rel[3] in acds_release_targets:
            return rel[3]
        self.pr_log('ERROR: target %s should be in field 2 or 3' % acds_release_targets)
        exit(1)

    # UPDATE# now appears before stage
    def rel_to_update_num(self, rel):
        update = self.release.split('_')[-2]
        if re.match(re.compile('^UPDATE[1-8]$'), update):
            return update[6:]
        return None

    def rel_to_rel_stage(self, rel):
        stage = rel.split('_')[-1]
        if re.match(re.compile('^(RC[1-8]|PR|EAP)$'), stage):
            return stage
        self.complain_rel_num_format(rel, 'stage looks wrong %s' % stage)

    def complain_rel_num_format(self, rel_num, details=None):
        year = time.strftime("%y")

        self.pr_log()
        self.pr_log('Incorrect release specifier: %s' % rel_num)
        self.pr_log()
        if details:
            self.pr_log(details + ' <----<<<')
            self.pr_log()
        self.pr_log('Release number format is: ACDS<yy>.<rel#>_REL_[<platform>_]<target>__[_<update>]<stage>')
        self.pr_log(' yy is year (%s)' % year)
        self.pr_log(' rel# can be 0, 1, 0.0, 0.1, etc')
        self.pr_log(' platform can be %s or not present' % str(self.acds_platforms))
        self.pr_log(' target can be %s' % str(acds_release_targets))
        self.pr_log(' update can be UPDATE1, UPDATE2, etc or not present.')
        self.pr_log(' stage is RC[1-8], PR, or EAP')
        self.pr_log()
        self.pr_log('If you are in doubt, please ask.')
        self.pr_log('If you get this wrong, you will have to fix a *lot*')
        self.pr_log('of tags.  It will be a big pain. You were warned :)')
        self.pr_log()
        self.pr_log(' i.e. ACDS%s.0_REL_GSRD_RC4' % year)
        exit(0)

    # only validate current release, the previous release is not specified for ACDS
    def validate_rel_descriptors(self):
        self.validate_rel_descriptor(self.release)

    def verify_release_conf(self):
        self.validate_rel_descriptor(self.release)

    def build_acds_tag_name(self, num, platform, target, update_num, stage):
        release = num + '_REL'
        if platform == '*':
            release += '*'
        elif platform != None and platform != '':
            release += '_' + platform
        release += '_' + target
        if update_num != None:
            release += '_UPDATE' + update_num
        release += '_' + stage
        return release

    def validate_rel_descriptor(self, rel):
        if len(rel.split('-')) != 1:
            self.complain_rel_num_format(rel, 'Note: "-" is forbidden.')
        
        num = self.rel_to_rel_num(rel)
        platform = self.rel_to_platform(rel)
        target = self.rel_to_rel_target(rel)
        update_num = self.rel_to_update_num(rel)
        stage = self.rel_to_rel_stage(rel)

        release = self.build_acds_tag_name(num, platform, target, update_num, stage)

        if rel != release:
            self.pr_log ('  release num = %s' % num)
            self.pr_log ('  platform    = %s' % platform)
            self.pr_log ('  target      = %s' % target)
            self.pr_log ('  update_num  = %s' % update_num)
            self.pr_log ('  stage       = %s' % stage)
            self.pr_log('ERROR: unable to properly parse release')
            self.pr_log('  release is : %s' % rel)
            self.pr_log('  parsed as  : %s' % release)
            self.complain_rel_num_format(rel, '')

    def need_to_push_tag(self, repo, branch, info):
        # If tags exist and are pushed, no need to push
        if info['tag_local_equals_origin'] and info['tag_local_equals_portal']:
            info['push_portal_tag'] = False
            info['push_portal_head'] = False 
            info['tag_sha'] = info['local_tag_sha']
            info['shortlog1'] = self.log('-1', '--pretty=%h %an %s', info['local_tag_sha'])
            return info

        # If origin is tagged but hasn't been pushed, we need to push
        if info['tag_local_equals_origin'] and not info['portal_is_tagged']:
            info['push_portal_tag'] = True
            info['tag_sha'] = info['local_tag_sha']
            info['shortlog1'] = self.log('-1', '--pretty=%h %an %s', info['local_tag_sha'])

            if info['portal_head_sha'] == info['local_tag_sha']:
                info['push_portal_head'] = False
            elif self.remote_branch_contains_sha('portal', branch, info['local_tag_sha']):
                info['push_portal_head'] = False
            else:
                info['push_portal_head'] = True
            return info

        if not info['origin_is_tagged']:
            self.pr_log("ERROR branch is not tagged yet")

        if info['portal_is_tagged'] and not info['tag_local_equals_portal']:
            self.pr_log("ERROR portal tag doesn't match")

        self.pr_log("ERROR there are tagging error(s)")
        info['tag_error'] = True
        info['push_portal_tag'] = False
        info['push_portal_head'] = False 
        return info

    def latest_rc(self, branch):
        return None

    def get_prev_tag_name(self, repo, branch):
        return None

    # Create list of all tags possible from self.release and self.platforms
    def generate_all_platform_tags(self):
        self.all_platform_tags = []

        num = self.rel_to_rel_num(self.release)
        target = self.rel_to_rel_target(self.release)
        update_num = self.rel_to_update_num(self.release)
        stage = self.rel_to_rel_stage(self.release)

        tag = self.build_acds_tag_name(num, '', target, update_num, stage)
        self.all_platform_tags.append(tag)
        for platform in self.platforms:
            tag = self.build_acds_tag_name(num, platform, target, update_num, stage)
            self.all_platform_tags.append(tag)
        #print self.all_platform_tags

    def gather_tag_info(self, repo):
        tags = self.git__get_tag_list(self.all_platform_tags)
        #print tags
        if len(tags) == 0:
            self.pr_log('Error, did not find any tags fitting this pattern for repo %s' % repo)
            self.pr_log(tag_pattern)
            exit(0)
        for tag in tags:
            branches = self.git__branch_contains(tag)
            if not branches:
                self.pr_log('Error, branch for tag %s was not found' % tag)
                print "branch for tag " + str(tag) + " was not found in repo " + str(repo)
                exit(0)
            for branch in branches:
                self.tag_info[repo][branches[0]] = tag
                #self.pr_log('tag %-30s on branch %s' % (tag, branch))
        #print self.tag_info[repo]

    def get_current_tag_name(self, repo, branch):
        if branch in self.tag_info[repo]:
            return self.tag_info[repo][branch]
        return None

    def tag_relative_describe(self, repo, branch):
        tag_name = self.branch_info[repo][branch]['tag_name']
        behind = self.describe_relative(tag_name, 'origin/' + branch)
        return behind

    # ACDS version - tags should already exist on 'origin'
    def gather_branch_info(self, repo, branch):
        info = self.gather_branch_info_common(repo, branch)
        info = self.need_to_push_tag(repo, branch, info)

        if info['tag_error']:
            self.tag_errors = True
        else:
            if info['push_portal_tag'] or info['push_portal_head']:
                self.need_to_push = True

        info['behind'] = self.tag_relative_describe(repo, branch)

        self.branch_info[repo][branch] = info

    # Tagging has already been done on internal repo, so only need to push to portal
    def push_release(self, push_cmd):
        self.push_release_to_repos(push_cmd, 'portal')

    def create_full_report(self):
        # One blank line at top of report.
        report = '\n'

        report = '\n'
        tags = []
        for repo in self.repo_list:
            if 'external_repo_name' not in self.repo_dict[repo]:
                continue
            for branch in self.repo_dict[repo]['branches']:
                tags.append(self.branch_info[repo][branch]['tag_name'])

        tags = list(set(tags))
        report += 'Tags found:\n' + '\n'.join(tags) + '\n\n'

        # Summary report section
        report += '%-20s %-35s %-7s   %6s  %s\n' % ('   repo', '   branch', ' commit', 'behind', '   tag name')
        report2 = ''
        for repo in self.repo_list:
            if 'external_repo_name' not in self.repo_dict[repo]:
                continue
            for branch in self.repo_dict[repo]['branches']:
                commit_id = self.branch_info[repo][branch]['origin_tag_sha'][0:7]
                tag_name = self.branch_info[repo][branch]['tag_name']
                behind = self.branch_info[repo][branch]['behind']
                line = '%-20s %-35s  %7s   %3d   %s\n' % (repo, branch, commit_id, behind, tag_name)
                # List tags that are in addition to self.release secondly
                if tag_name == self.release:
                    report += line
                else:
                    report2 += line
        report += report2
        report += self.links_to_github()

        self.pr_log(report)
        self.portal_report = report

    def helpful_links(self):
        # Already included in the report
        print

#--------------------------------------------------------------
parser = argparse.ArgumentParser(formatter_class=argparse.RawDescriptionHelpFormatter,
                                 description="generate reports and sync to the portal.",
                                 epilog=textwrap.dedent('''\
Script used to update our external portal git with releases.

See also linux-infra/tools/portal-update-doc.txt for more detail.

The '-u' operation will update the repos that are cloned on the user's Linux host.
The first time running this script on a new host machine, that can take a long time.

Whenever this script is run, it creates a release directory based on the --rel release
and leaves the portal report and run log in that directory.  It is up to the person running
this script to commit the report to git and push it to document the release.  Such as:
 * linux-infra/portal-release/15.12.02/

Don't just run through the steps below!  Look at logs and commit them after each step.

First time run:
Set your email address, i.e.:
   %(prog)s --type Linux --rel 15.12.02_rc1 --prev 15.12.01_pr --set-email YOUR.ADDRESS@intel.com

GSRD releases:
Note that for GSRD releases:
 * the tagging was done by the team in PNG, so this script will verify the tags rather than
   generating the tags.
 * this script only handles PR, not the RC's.
 * the -p PLATFORM paramater is additive, so you can specify multiple platforms.
 * the portal report email does not get sent out.  The PSG team sends out its own email.

   %(prog)s --type GSRD --rel ACDS19.1_REL_GSRD_PR -p S10 -p MAX10 -u
      Update (fetch) local repos and check that tags exist.

   %(prog)s --type GSRD --rel ACDS19.1_REL_GSRD_PR -p S10 -p MAX10 --push
      Push tags out to portal, abort before pushing anything on errors.

Linux releases (aka 'the biweekly release'):
In this case, tags are created by this script.

 Linux rc1:
   %(prog)s --type Linux --rel 15.12.02_rc1 --prev 15.12.01_pr -u
      Update the local clones of git repositories, run some tests, abort on error.

   %(prog)s --type Linux --rel 15.12.02_rc1 --prev 15.12.01_pr --push
      Create tags if they don't already exist (the normal case).
      Abort before doing push if there are any errors.
      For rc's, push tags to internal git server only.

   %(prog)s --type Linux --rel 15.12.02_rc1 --email me
      Send report email to me using saved report file

   %(prog)s --type Linux --rel 15.12.02_rc1 --email all
      Send report email using saved report file

 Linux rc2 if necessary:
   %(prog)s --type Linux --rel 15.12.02_rc2 --prev 15.12.01_pr -u
      Update the local clones of git repositories, run some tests, abort on error.

   %(prog)s --type Linux --rel 15.12.02_rc2 --prev 15.12.01_pr --push
      Same as above, but actually create and push the rc2 tags.
      If tags already exist locally, use them.

 Linux pr:
   %(prog)s --type Linux --rel 15.12.02_pr --prev 15.12.01_pr -u
      Update the local clones of git repositories, run some tests, abort on error.

   %(prog)s --type Linux --rel 15.12.02_pr --prev 15.12.01_pr --push
      Create tags based on previous rc.
      Abort before doing push if there are any errors.
      For pr, push tags to internal git server and portal.

   %(prog)s --type Linux --rel 15.12.02_pr --email me
      Send report email to me using saved report file

   %(prog)s --type Linux --rel 15.12.02_pr --email all
      Send report email using saved report file

'''))

# Parameters
parser.add_argument("--type", dest="release_type", default=None, help="release type %s" % str(('Linux',) + acds_release_targets))
parser.add_argument("--rel", dest="rel", default=None, help="specify yy.mm.rr_stage or ACDS tag name")
parser.add_argument("--prev", dest="prev", default=None, help="previous pr release")
parser.add_argument("-p", dest="platforms", default=[], action='append', help="platform")

# For development use, not used normally
parser.add_argument("-c", "--print-config", action="store_true", help="print out release branches configuration")

# Actions
actions = parser.add_mutually_exclusive_group(required=True)
actions.add_argument("-u", "--update", dest="fetch_all", action="store_true",
                     help="update (fetch) from internal/portal repos to local cloned repos")
actions.add_argument("--dry-run", action="store_true", help="do a dry run but don't push")
actions.add_argument("--push", action="store_true", help="do a dry run, then do actual push")
actions.add_argument("--email", default=None, help="send report email to list [me|all]")
actions.add_argument("--set-email", default=None, help="set user email address [blah@intel.com]")
actions.add_argument("-C", "--print-config-exit", action="store_true", help="print out release config and exit")

#==============================================================================================================
# 'args' should not appear above this line in this script. Don't use it as a global.
args = parser.parse_args()

# Instantiate a class for the target of release we are doing (ACDS or Linux)
if args.release_type == 'Linux':
    rel_class = release_Linux(args.rel, args.prev, [])
elif args.release_type in acds_release_targets:
    if args.prev:
        print "--prev is not required for the ACDS release process"
        exit(1)
    if args.email:
        if args.email == 'all':
            print "--email all is not supported for the ACDS release process"
            exit(1)
    rel_class = release_ACDS(args.rel, None, args.platforms)
else:
    print "Need to specify --type %s" % str(('Linux',) + acds_release_targets)
    exit(1)

if args.set_email != None:
    rel_class.set_global_email(args.set_email)
    exit(0)

if rel_class.email_user == None:
    print "It appears that this is the first time you are running this script on this"
    print "machine.  Either switch to the machine you usually use or save your email"
    print "by running again with '--set-email [your email addr]'"
    exit(0)

if args.print_config or args.print_config_exit:
    rel_class.print_release_config()
    if args.print_config_exit:
        exit(0)

if args.email:
    rel_class.email_report(args.email)
    exit(0)

if args.fetch_all:
    rel_class.pr_log('Fetching from repos, then doing a dry run, not actually pushing.')
elif args.dry_run:
    rel_class.pr_log('Just doing a dry run, not actually pushing.')
else:
    rel_class.pr_log('Doing dry run, followed by actual push (unless dry run fails)')
rel_class.pr_log('')

if args.fetch_all:
    rel_class.fetch_all_repos()

rel_class.check_cloned_repos()
rel_class.gather_all_branch_info()
rel_class.create_full_report()
rel_class.save_report()
rel_class.helpful_links()

# do a dry run for fetch_all or dry_run or push
rel_class.push_release('dry_run')
    
if args.push:
    rel_class.push_release('push')

rel_class.save_log()

exit(0)
