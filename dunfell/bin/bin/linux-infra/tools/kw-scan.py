#!/usr/bin/env python

import argparse
import glob
import os
import re
import stat
import sys
import textwrap
from os import path, chdir, getcwd, remove
from os.path import isdir, isfile
from shutil import copytree, rmtree
from subprocess import Popen, PIPE, STDOUT

# Local libraries in linux-infra
from git_utils import *
sys.path.append(path.join(path.dirname(__file__), '..', 'hooks'))
from HooksUtils import *

# globals
registry = "amr-registry-pre.caas.intel.com"
docker_image = "psg-klocwork/psg_klocwork_ubuntu_16.04"
docker_tag = "0.26"

script_name = path.basename(sys.argv[0])
container_user = 'build'
container_home_dir = path.join('/home', container_user)
container_mount = path.join(container_home_dir, 'code')

# Note to maintainers: when adding new projects to scan, please don't hack this
# script up with complicated conditionals.  Let's keep it simple and flat.
# Each project adds a dict to the 'projects' dict below and a callbacks script to
# linux-infra/nightlybuild/update/configs/klocwork/
#
# Each Klocwork project on the Klocwork server gets a 'project' in the dict below.
# We started out with two Klocwork projects: 'linux-socfpga' and 'intel-rsu'
#
# Note that:
# * each project is a dict and
# * each machine is a dict that can override the project settings if the setting is present
#
# Current settings for each project:
#   * 'repo_name'    = main source git repo   (default = {project})
#   * 'repo_names'   = other (bringup) repos  (no default)
#   * 'callbacks_fn' = callbacks-kw-*.sh file (default = "callbacks-kw-{project}.sh")
#   * 'machines'     = valid machines         (no default)
#   * 'lastest_name' = results symbolic link  (no default)
#
projects = {
    'linux-socfpga': {
        'machines': {
            'cyclone5': {'latest_name': 'latest-KW-arm-linux'},
            'stratix5': {'latest_name': 'latest-KW-arm-linux'},
            'arria10': {'latest_name': 'latest-KW-arm-linux'},
            'stratix10': {'latest_name': 'latest-KW-arm64-linux'},
            'nios2': {'latest_name': 'latest-KW-nios2-linux'},
        },
        'repo_names' : {
            'linux-socfpga': {},
            'linux-devtree': {},
            'linux-bringup': {},
            'linux-socfpga-up': {},
        },
    },
    'intel-rsu': {
        'latest_name': 'latest-KW-intel-rsu',
        'machines': {
            'stratix10': {},
        },
        'repo_names' : {
            'intel-rsu': {},
            'intel-rsu-bringup': {},
        },
    },
}

def get_project_setting(setting, project, machine, default=None):
    global projects
    if setting in projects[project]['machines'][machine]:
        return projects[project]['machines'][machine][setting]
    if setting in projects[project]:
        return projects[project][setting]
    if default != None:
        return default
    print "Scripting error: project dict needs setting '%s' for project %s" % (setting, project)
    exit(0)

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

def vprint(msg):
    global args
    if args.verbose:
        print msg

def get_infra_version(git):
    global args
    saved_path = getcwd()
    infra_path = get_infra_path()
    chdir(infra_path)

    if not git.in_repo():
        print "It appears that you are running this script without having cloned linux-infra."
        exit(1)

    infra_version = git.log('-1', '--pretty=format:"%h %cd %an %s"')

    chdir(saved_path)
    return infra_version

# Given a cloned repo, figure out what repo it was cloned from and from that
# figure out which Klocwork project that corresponds to, if any.
def project_from_repo(git, repo_fullpath):
    current_dir = getcwd()
    if not isdir(repo_fullpath):
        print "I don't see a directory at %s" % args.repo
        exit(1)
    chdir(repo_fullpath)
    if not git.in_repo():
        print "I don't see a git repo at %s" % args.repo
        exit(1)
    repo_name = git.repo_name()
    chdir(current_dir)
    if repo_name in projects:
        print "Detected kw project %s for repo %s" % (repo_name, repo_name)
        return repo_name
    for project in projects:
        if 'repo_names' in projects[project]:
            if repo_name in projects[project]['repo_names']:
                print "Detected kw project %s for repo %s" % (project, repo_name)
                return project
    print "repo not supported for Klocwork scans: %s" % repo_name
    exit(1)

# Print a list, add lf and indention for any elements that match 'lfmatch'
def pretty_print_cmd(cmd, lfmatch):
    output = cmd[0]
    for foo in cmd[1:]:
        if re.match(lfmatch, foo):
            output += ' \\\n  '
        output += ' ' + foo
    print output

# Returns a list of detected DNS server IP addresses
def get_dns_server_ip():
    dns_server_ips = []
    # we're doing: nmcli -t dev show | grep DNS
    cmd = [ 'nmcli', '-t', 'dev', 'show' ]
    cmd_process = Popen(cmd, stdout=PIPE, stderr=STDOUT)

    # Stream output from process
    while True:
        output = cmd_process.stdout.readline().decode("utf-8", "ignore").encode("ascii", "ignore")
        if output == '' and cmd_process.poll() is not None:
            break
        if output:
            try:
                # Output is like:
                #   IP4.DNS[1]:10.248.2.1
                #   IP4.DNS[2]:10.2.71.6
                #   IP4.DNS[3]:10.31.40.4
                output = output.strip('\n')
                if not re.match(".*DNS.*", output):
                    continue
                print "Got DNS server IP: %s" % output
                dns = output.split(':')[1]
                dns_server_ips.append(dns)
            except:
                continue
    rc = cmd_process.poll()
    return dns_server_ips

def docker_pull_img(docker_img_full):
    cmd = [ 'docker', 'pull', docker_img_full ]
    print cmd
    cmd_process = Popen(cmd, stdout=PIPE, stderr=STDOUT)

    # Stream output from process
    while True:
        output = cmd_process.stdout.readline().decode("utf-8", "ignore").encode("ascii", "ignore")
        if output == '' and cmd_process.poll() is not None:
            break
        if output:
            try:
                print output.strip('\n')
            except:
                continue
    rc = cmd_process.poll()
    print "docker pull exited with return code %d" % rc

#=================================================================================================
parser = argparse.ArgumentParser(formatter_class=argparse.RawDescriptionHelpFormatter,
                                 description="Start a Klocwork scan in a container",
                                 epilog=textwrap.dedent('''\

Most parameters are optional.  Normally run as either:
 * Running by hand on a cloned repo with the proper branch checked out:
    %(prog)s --repo CLONED_REPO -m MACHINE [-f]
      - or -
 * Run happening under control of an automated script
    %(prog)s -p PROJECT -v HOST_MOUNT -b BRANCH -m MACHINE [--cloned][-f]

Examples:
   %(prog)s --repo . -m stratix10 -f
      Klocwork scan will happen on the currently checked out branch of the repo cloned at the specified path (.)

   %(prog)s -p linux-socfpga -m stratix10 -b origin/socfpga-4.9.78-ltsi -r v4.9.78..ACDS18.1_REL_GSRD_PR -v ~/linux/intel
   %(prog)s -p intel-rsu -m stratix10 -b origin/master -v ~/linux/intel
      Both these examples assume user has created ~/linux/intel directory for source and results.

Regarding DNS:
This script will attempt to autodetect your DNS server and pass that info to the container.
However this may not be needed if you configure Docker using the following settings in
/etc/systemd/system/docker.service.d/http-proxy.conf :
-----------------------------------------------------------------------------------------
[Service]
Environment="http_proxy=http://proxy-chain.intel.com:911" "https_proxy=http://proxy-chain.intel.com:911"
ExecStart=
ExecStart=/usr/bin/dockerd --dns 10.248.2.1 --dns 10.2.71.6 --dns 10.31.40.4 -H fd://
-----------------------------------------------------------------------------------------
'''))

# Parameters
group_manual_run = parser.add_argument_group('run scan by hand')
group_manual_run.add_argument("--repo", help="path to source repo that is already cloned")

group_scripted_run = parser.add_argument_group('run by automated script')
group_scripted_run.add_argument("-p", "--project", help="one of: %s" % projects.keys())
group_scripted_run.add_argument("-v", "--volume", dest="host_mount", help="user created host dir to mount")
group_scripted_run.add_argument("-b", "--source-branch", help="source repo branch to scan, i.e. origin/master")
group_scripted_run.add_argument("--cloned", action="store_true", help="repo was already cloned by script")

parser.add_argument("-m", "--machine", required=True, help="machine, i.e. stratix10")
parser.add_argument("-r", "--range", dest="commit_range", default="", help="range of commits, i.e. v4.18..HEAD")
parser.add_argument("-f", "--force", action="store_true", help="clean up (delete build and output dirs) before running scan")
parser.add_argument("-o", "--output", help="specify directory to copy results to")
parser.add_argument("--dns", default=None, help="IP address of dns server")
parser.add_argument("--verbose", action="store_true", help="verbose messages for debugging")

# For development use, not used normally
parser.add_argument("--dev", action="store_true",
		    help="for development use. do not use.")
parser.add_argument("--nup", action="store_true",
		    help="use non-uploaded conainer development image, do not use.")

#==============================================================================================================
args = parser.parse_args()
git = git_utils(args.verbose)

commit_range = args.commit_range

project = None
host_mount = None
repo_name = None        # name of source repo on git server
repo_basename = None    # base name of cloned/to-be-cloned repo (can be different from name of repo on git server)
source_branch = None

cloned_flag = args.cloned or args.repo != None

if args.repo != None:
    if args.cloned:
        print "Don't specify both '--cloned' and '--repo'"
        exit(1)

    # '--repo' overrides several parameters: -p, -v, and -b
    if args.project:
        print "Shoudn't specify both '--repo' and '-p PROJECT'"
        exit(1)

    if args.host_mount:
        print "Shoudn't specify both '--repo' and '-v HOST_MOUNT'"
        exit(1)

    if args.source_branch != None:
        print "Shoudn't specify both '--repo' and '-b BRANCH'"
        exit(1)

    repo_fullpath = path.abspath(args.repo)
    project = project_from_repo(git, repo_fullpath)
    repo_basename = path.basename(repo_fullpath)
    host_mount = path.abspath(path.join(repo_fullpath, '..'))
    source_branch = 'HEAD'
else:
    project = args.project
    host_mount = args.host_mount
    source_branch = args.source_branch
    if project == None:
        print "Need to specify -p PROJECT"
        exit(1)
    if project not in projects:
        print "Project not supported: %s" % project
        exit(1)
    if source_branch == None:
        print "Need to specify '-b SOURCE_BRANCH'"
        exit(1)

machines = projects[project]['machines'].keys()
machine = args.machine
if machine not in machines:
    print "Machine (%s) not supported for this project (%s)" % (machine, project)
    print "Need to specify -m MACHINE as one of: %s" % machines
    exit(1)

latest_name = get_project_setting('latest_name', project, machine)
callbacks_fn = get_project_setting('callbacks_fn', project, machine, default='callbacks-kw-%s.sh' % project)
repo_name = get_project_setting('repo_name', project, machine, default=project)
if repo_basename == None:
    repo_basename = repo_name

# location of linux-infra *in the container*
if not args.dev:
    container_infra_dir = path.join(container_home_dir, 'linux-infra')
else:
    # if in development mode change container_infra_dir to mounted directory
    print "ERROR do not run script with '--dev' unless you know what you are doing"
    container_infra_dir = path.join(container_mount, 'linux-infra')

infra_nightly_dir = path.join(container_infra_dir, 'nightlybuild/update')
callbacks_dir = path.join(infra_nightly_dir, 'configs/klocwork')
callbacks_fn = path.join(callbacks_dir, callbacks_fn)

print 'linux-infra version   : %s' % get_infra_version(git)

if host_mount == None:
    print "Need to specify '-v HOST_MOUNT'"
    exit(1)

host_mount = path.abspath(host_mount)
if not isdir(host_mount):
    print "I don't see a directory %s" % host_mount
    exit(1)

host_source_path = path.join(host_mount, repo_basename)
if cloned_flag and not isdir(host_source_path):
    print "I don't see the cloned repo at %s" % host_source_path
    exit(1)
if not cloned_flag and isdir(host_source_path):
    print "I see source repo already cloned (%s).  Either run with --cloned or --repo or delete it." % host_source_path
    exit(1)

# Check to see if host mount and source dir (if it exists) are writable by 'other'
iwoth_host_mount = os.stat(host_mount).st_mode & stat.S_IWOTH

# if --repo is None, either repo was cloned by script or it's about to be, so we don't need to
# check for permissions of the source directory.
# if --repo is not None, then repo was cloned by user so check that mode is 777
iwoth_source_mount = args.repo == None or os.stat(host_source_path).st_mode & stat.S_IWOTH

if not iwoth_host_mount or not iwoth_source_mount:
    print
    print 'The container needs some directories to be mode 777 to be writable'
    print 'You will need to run the following:'
    if not iwoth_host_mount:
        print ' chmod 777 %s' % host_mount
    if not iwoth_source_mount:
        print ' chmod -R 777 %s' % host_source_path
        print "note that later your git repo will show lots of files that were chmod'ed"
        print "when your are done scanning you can cd to your repo and do 'git reset --hard' to clean up."
    exit(1)

# Clean up stuff generated by previous container first
build_dir = path.join(host_mount, 'build')
clean_list = []
for to_clean in [ build_dir ]:
    if isdir(to_clean) or isfile(to_clean):
        clean_list.append(to_clean)
if args.output != None:
    clean_list.append(args.output)
if len(clean_list) != 0:
    if args.force:
        for to_clean in clean_list:
            if isdir(to_clean):
                rmtree(to_clean)
            elif isfile(to_clean):
                remove(to_clean)
    else:
        print "The following need to be deleted before running this script (or run with '-f' to delete them all):"
        for to_clean in clean_list:
            print '  %s' % to_clean
        exit(1)

dns_msg = ""
if args.dns != None:
    dns_servers = [ args.dns ]
else:
    dns_servers = get_dns_server_ip()
if dns_servers == []:
    dns_msg = "none detected"
else:
    for dns_ip in dns_servers:
        if dns_ip != "":
            dns_msg += " "
        dns_msg += "%s" % dns_ip

if args.nup:
    docker_img_full = docker_image + ':' + docker_tag
else:
    docker_img_full = registry + '/' + docker_image + ':' + docker_tag
        
print "docker image          : %s" % docker_img_full
print "host mount dir        : %s" % host_mount
print "container mount dir   : %s" % container_mount
print "project               : %s" % project
if commit_range != "":
    print "commit range          : %s" % commit_range
print "cloned_flag           : %s" % cloned_flag
print "callbacks             : %s" % callbacks_fn
print "dns servers           : %s" % dns_msg

# Scripting note on cloning from at-git:
# Not all repos have unrestricted read-only git access but some do.
#
# Cloning using read-only git access (no ssh key needed):
#    source_repo = 'git://at-git.intel.com/%s' % repo_name
#
# Cloning using gitolite (requires ssh key):
#    source_repo = 'gitolite@at-git.intel.com:%s' % repo_name
container_source_path = path.join(container_mount, repo_basename)
if cloned_flag and source_branch == 'HEAD':
    source_repo = 'file://' + container_source_path
else:
    source_repo = 'gitolite@at-git.intel.com:%s' % repo_name

# Create the config file for the nightly build script
host_config_fn = path.join(host_mount, 'config-kw.sh')
container_config_fn = path.join(container_mount, 'config-kw.sh')
config = ''

# required by linux-nightly.sh:
config += 'RELEASE_NAME="auto"\n'
config += 'PACKAGING="txt"\n'
config += 'LATEST_NAME=%s\n' % latest_name

# required by linux-nightly.sh, klockwork/callbacks*, and lib/kw-common.sh
config += 'MACHINE=%s\n' % machine

# required by klockwork/callbacks or lib/kw-common.sh
config += 'PROJECT_NAME=%s\n' % project
config += 'SOURCE_CLONE=%s\n' % container_source_path
config += 'SOURCE_BRANCH=%s\n' % source_branch
config += 'SOURCE_REPO=%s\n' % source_repo

# Add optional parameters, used by klockwork/callbacks or lib/kw-common.sh
if commit_range != "":
    config += 'COMMIT_RANGE=%s\n' % commit_range

write_file(host_config_fn, config)
print
print "Generated config for linux-nightly.sh (%s):" % host_config_fn
for line in read_file(host_config_fn).split('\n'):
    print '  ' + line

# Get latest docker image from registry
if not args.nup:
    docker_pull_img(docker_img_full)
    
# Launching linux-nightly.sh in Docker container
nightly_full_path = path.join(container_infra_dir, 'nightlybuild/update/linux-nightly.sh')
#docker_cmd = [ nightly_full_path, '-w', container_mount, '-c', container_config_fn, '-f', callbacks_fn ]
# For debug output, use the following command.
docker_cmd = [ nightly_full_path, '-w', container_mount, '-c', container_config_fn, '-f', callbacks_fn , '-d']

# docker run --rm -v ${HOST_MOUNT}/:/home/build/code --dns ${DNS_IP} -t $(DOCKER_IMG) ${script_full_path} ${PARAMS} 
# --rm : Automatically remove the container when it exits
# -v <path1>:<path2> : Bind mount a volume
# --dns : Set custom DNS servers
# -t : Allocate a psuedo-TTY
# Then the linux-nightly.sh script has the following
# -w : Working directory inside the container
# -c : configuration file.
# -f : callbacks. required.
cmd = [ 'docker', 'run', '--rm', '-v', '%s:%s' % (host_mount, container_mount) ]
for dns in dns_servers:
    cmd += [ '--dns', dns ]
cmd += [ '-t', docker_img_full ]
cmd += docker_cmd

print "Running the following Docker command:"
pretty_print_cmd(cmd, "(^-.*|%s)" % nightly_full_path)
print

# Launch docker container
docker_process = Popen(cmd, stdout=PIPE, stderr=STDOUT)

# Stream output from container launched
while True:
    # Our container is set to use utf-8.  Get each line of output, encode as ascii, throwing
    # away characters that trash the terminal or confuse stripping newlines below.
    output = docker_process.stdout.readline().decode("utf-8", "ignore").encode("ascii", "ignore")
    if output == '' and docker_process.poll() is not None:
        break
    if output:
        # 'try' to keep the script from bombing if the above output filtering was insufficient.
        try:
            print output.strip('\n')
        except:
            print
rc = docker_process.poll()
print "Docker process exited with return code %d" % rc
print

results_dir = path.join(host_mount, latest_name)
results = glob.glob(path.join(results_dir, 'kw-results*filtered.txt'))
if results == []:
    results = glob.glob(path.join(results_dir, 'kw-results*.txt'))
if results == []:
    print "Error, no results"
else:
    print "Results are in:"
    for result in results:
        print "   %s" % result

if args.output != None:
    copytree(results_dir, args.output)

exit(0)
