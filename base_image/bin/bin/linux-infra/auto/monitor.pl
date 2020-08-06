#!/usr/bin/env python

import urllib2
import httplib
import json
import requests
import datetime
import time
import os
import sys
import re
import glob
import argparse
import smtplib

from subprocess import Popen, PIPE, CalledProcessError
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

# Run a command line command, return stdout, stderr, rc
def check_output3(*popenargs, **kwargs):
    if 'stdout' in kwargs:
        raise ValueError('stdout argument not allowed, it will be overridden.')
    proc = Popen(stdout=PIPE, stderr=PIPE, *popenargs, **kwargs)
    out_value, err_value = proc.communicate()
    rc = proc.poll()
    proc.stdout.close()
    proc.stderr.close()
    return (out_value, err_value, rc)

# Run a command line command.
def check_output(*popenargs, **kwargs):
    if 'stdout' in kwargs:
        raise ValueError('stdout argument not allowed, it will be overridden.')
    proc = Popen(stdout=PIPE, stderr=PIPE, *popenargs, **kwargs)
    out_value, err_value = proc.communicate()
    rc = proc.poll()
    proc.stdout.close()
    proc.stderr.close()
    return (out_value, rc)

#-----------------------------------------------------------------------

# Given a list of parameters, run a git command, do some filtering on the outputs
def git_cmd3(args):
    (out_value, err_value, rc) = check_output3(['git'] + args)

    # filter out the Altera server msg
    regex = re.compile(r"\\033.*\\033\[0m", re.MULTILINE|re.DOTALL)
    err_value = regex.sub('', err_value)

    # split lines, get rid of '\r\n'
    err_value = err_value.splitlines()
    out_value = out_value.splitlines()
    if err_value == ['']:
        err_value = []
    return (out_value, err_value, rc)

def git_cmd(args):
    (out_value, err_value, rc) = git_cmd3(args)
    return out_value

def git_fetch(repo, tags=None):
    global report

    os.chdir(repo['local_path'])

    remote = repo['remote']

    if tags:
        (out, err, rc) = git_cmd3(['fetch', '-p', '--tags', remote])
        report += 'git fetch --tags %s\n' % remote
    else:
        (out, err, rc) = git_cmd3(['fetch', '-p', remote])
        report += 'git fetch %s\n' % remote

    if out != []:
        report += ('\n').join(out)
    if err != []:
        report += ('\n').join(err)

    report += '\n'
    return (out, err, rc)

def get_current_br():
    branches = git_cmd(["branch"]).splitlines()
    for br in branches:
        if br[0] == '*':
            return br[2:]
    return None

fetch_list = []
def add_repo_to_monitor(name, long_name, url):
    basename = os.path.basename(url).replace('.git', '')
    local_path = os.path.join(monitor_repos_dir, basename)

    if not os.path.isdir(local_path):
        local_path = local_path + '.git'

    repo = {
        'long_name': long_name,
        'basename': basename,
        'url':url,
        'cloned': os.path.isdir(local_path),
        'fetched':False,
        'remote':'origin',
        'local_path':local_path
    }
    fetch_list.append(repo)

def send_email(smtp_server, to_addrs, msg):
    # code from http://pymotw.com/2/smtplib/
    server = smtplib.SMTP(smtp_server)
    server.set_debuglevel(True)
    try:
        server.sendmail(msg['From'], to_addrs, msg.as_string())
    except:
        raise
    finally:
        server.quit()

def send_report_email(to_list, subject, report):
    msg = MIMEMultipart('alternative')
    msg['From'] = 'alan.tull@intel.com'
    msg['Subject'] = subject

    to_addrs = []
    for addr in to_list:
        to_addrs.append(addr + '@intel.com')
    COMMASPACE = ', '
    msg['To'] = COMMASPACE.join(to_addrs)

    # Send the email in such a way that it won't get re-formatted by Outlook.
    html_msg = "\n<html>\n<head></head>\n<body><pre><code>"
    html_msg += report
    html_msg += "\n</code></pre>\n</body>\n</html>"

    msg.attach(MIMEText('', 'plain'))
    msg.attach(MIMEText(html_msg, 'html'))

    smtp_server = 'smtp.intel.com:25'
    send_email(smtp_server, to_addrs, msg)

#=======================================================================

#todo get public info, look for email address
#url='https://api.github.com/users/mirror-opensource/events/public'

#contents = urllib2.urlopen(url).read()
#print(contents)

#r = requests.get(url)

#item = json.loads(r.text or r.content)
#print json.dumps(item, indent=1)

#exit(0)

report = '---------------------------------------------------------------------------\n'
report += datetime.datetime.now().strftime('%Y%m%d %H:%M:%S') + '\n\n'
report += 'script will list the raw output of the "git fetch" commands and then\n'
report += 'sort that output by categories (added tags, added branches, deleted, etc.\n\n'

self_full_name = os.path.abspath(sys.argv[0])
self_full_path = os.path.dirname(self_full_name)
self_name = os.path.basename(self_full_name)
base_dir = os.path.abspath(os.path.join(self_full_path, '..', '..'))
monitor_repos_dir = os.path.join(base_dir, 'repos', 'mirror-investigation')

add_repo_to_monitor('mirror-linux-socpfga',
                    'Unauthorized github.com/mirror-opensource/linux-socfpga',
                    'https://github.com/mirror-opensource/linux-socfpga.git')
add_repo_to_monitor('mirror-u-boot-socfpga',
                    'Unauthorized github.com/mirror-opensource/u-boot-socfpga',
                    'https://github.com/mirror-opensource/u-boot-socfpga.git')

#print fetch_list
#exit(0)

# List of 'things' to look for and report on, in order    
things = [ 'new_tags', 'new_branches', 'tag_updates', 'branch_updates', 'deleted', 'other', 'forced_updates' ]
anything_new = False

for repo in fetch_list:
    if not repo['cloned']:
        report += 'Repo is not cloned: %s\n' %(repo[name])
        continue

    if repo['fetched']:
        continue

    for thing in things:
        repo[thing] = []

    report += 'Repo: ' + repo['url'] + '\n'

    (repo['fetch_out'],
     repo['fetch_err'],
     repo['fetch_rc']) = git_fetch(repo)
    if repo['fetch_rc'] != 0:
        report += "get returned nonzero return code (%d)\n" % repo['fetch_rc']

    (repo['fetch_tags_out'],
     repo['fetch_tags_err'],
     repo['fetch_tags_rc']) = git_fetch(repo, tags=True)
    if repo['fetch_tags_rc'] != 0:
        report += "get returned nonzero return code (%d)\n" % repo['fetch_tags_rc']

    for msg in repo['fetch_tags_out'] + repo['fetch_tags_err'] + repo['fetch_out'] + repo['fetch_err']:
        if msg == '':
            continue
        if re.match('^(From |Auto packing the repository|See .*manual housekeeping).*', msg):
            continue
        if re.match('^From .*', msg):
            continue

        if re.match('.*new tag.*', msg):
            repo['new_tags'].append(msg)
            anything_new = True
        elif re.match('.*new branch.*', msg):
            repo['new_branches'].append(msg)
            anything_new = True
        elif re.match('.*tag update.*', msg):
            repo['tag_updates'].append(msg)
            anything_new = True
        elif re.match('.*forced update.*', msg):
            repo['forced_updates'].append(msg)
            anything_new = True
        elif re.match('.*deleted.*', msg):
            repo['deleted'].append(msg)
            anything_new = True
        elif re.match('.*[0-9]*\.\.[0-9a-f]*.*', msg):
            repo['branch_updates'].append(msg)
            anything_new = True
        else:
            repo['other'].append(msg)

    for thing in things:
        if repo[thing] == []:
            continue
        report += '\n' + thing + '\n'
        for foo in repo[thing]:
            report += foo + '\n'
        report += '\n'

#report += '============================================================================='

if anything_new:
    newness = 'Something new\n\n'
else:
    newness = 'Nothing new\n\n'

report = newness + report
print report

to_list = [ 'alan.tull' ]
subject = 'Report on github "mirror-opensource" repos'
if anything_new:
    subject += '+ SOMETHING NEW'

send_report_email(to_list, subject, report)

exit(0)
