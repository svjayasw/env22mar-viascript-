#!/usr/bin/env python

import os
import sys

# Add the ../tools directory to the path so that we can import git_utils.py
sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'hooks'))
from git_utils import *

#============================================================================

def test_cmd(cmd, expected_stdout, expected_status, *args, **kwargs):
    global status
    print 'test: \'git.%s %s\' == %s' % (cmd, ' '.join(args), expected_stdout)

    # get a pointer to the command in our git library
    try:
        methodToCall = getattr(git, cmd)
    except:
        print 'This command does not exist in git_utils.py : %s' % cmd
        cmd_status = 1
        exit(1)

    # Run the command and note whether there was a failure.  Might be expected.
    cmd_status = 0
    try:
        if len(args) == 0 and len(kwargs) == 0:
            cmd_stdout = methodToCall()
        elif len(args) == 0 and len(kwargs) != 0:
            cmd_stdout = methodToCall(**kwargs)
        elif len(args) != 0 and len(kwargs) == 0:
            cmd_stdout = methodToCall(*args)
        else:
            cmd_stdout = methodToCall(*args, **kwargs)
    except:
        cmd_status = 1

    # expect to succeed
    if (expected_status == 0):
        if (cmd_status == 1):
            print 'FAIL : command failed'
            status = 'FAIL'
        elif (cmd_stdout == expected_stdout):
            print 'PASS'
        else:
            print 'FAIL : output was %s' % cmd_stdout
            status = 'FAIL'
    else:
        if (cmd_status == 1):
            print 'PASS'
        else:
            print 'FAIL : expected command to fail, but it did not fail.'
            status = 'FAIL'

    print
    return

#============================================================================

git = git_utils()
status = 'PASS'
os.chdir('/home/atull/repos/linux-socfpga')

# Test each git command in git_utils.py in alpha order:

print 'Basic git operations...'

test_cmd('cat_file', 'commit', 0, '-t', 'HEAD')
test_cmd('cat_file', True, 0, '-e', 'HEAD')
test_cmd('cat_file', False, 0, '-e', 'HEasdfasdfasdfAD')

test_cmd('config', 'origin\n', 0, 'branch.socfpga-3.8.remote')
test_cmd('config', '', 1, 'brdddanch.socfpga-3.8.remote')

#test_cmd('fetch', '',

patches = [ '0001-FogBugz-119143-Base-socfpga.dtsi-is-incomplete.patch', '0002-FogBugz-1011105-document-gpio-dw-device-tree-binding.patch', '0003-FogBugz-108269-Enable-PMU-through-the-CTI.patch' ]
test_cmd('format_patch', patches, 0, '-3', '7fc7cbf')
for patch in patches:
    os.remove(patch)

test_cmd('describe', 'v3.8-85-g7fc7cbf', 0, '7fc7cbf8798')
test_cmd('describe', '', 1, 'asdflkjsdfldsfd')

#test_cmd('diff_tree', 'create mode 100644 Documentation/devicetree/bindings/gpio/gpio-dw.txt', 0, 'f50d4b0^', 'f50d4b0')

test_cmd('log', '7fc7cbf', 0, '-1', '--pretty=format:%h', '7fc7cbf8798')

#test_cmd('show',
#test_cmd('status',

print 'Higher level functions...'

test_cmd('author_email', 'dinguyen@altera.com', 0, '7fc7cbf')
test_cmd('author_full', 'Dinh Nguyen <dinguyen@altera.com>', 0, '7fc7cbf')
test_cmd('author_name', 'Dinh Nguyen', 0, '7fc7cbf')

#test_cmd('branch_name',

patches = [ '0001-FogBugz-119143-Base-socfpga.dtsi-is-incomplete.patch', '0002-FogBugz-1011105-document-gpio-dw-device-tree-binding.patch', '0003-FogBugz-108269-Enable-PMU-through-the-CTI.patch' ]
test_cmd('create_patches', patches, 0, num_commits=3, rev='7fc7cbf')
for patch in patches:
    os.remove(patch)

#test_cmd('header',

test_cmd('in_repo', True, 0, )

test_cmd('log_of_hashes', 'dc45ca3bc91010c04f3c563e3621e14c7b9dddb4\n46c7ce960c1ea706a13d94ec4abcc30a10ef19b9\n7bb66e6a0cabf95a46abd02dcd329f17d4e4b8a8', 0, 'dc45ca3^^^', 'dc45ca3')

test_cmd('parent_hashes', ['7c45512df987c5619db041b5c9b80d281e26d3db', '9937c026820baabd1e908a9c1e6bdc846293000a'], 0, 'v3.8^')

test_cmd('rev_to_hash', '19f949f52599ba7c3f67a5897ac6be14bfcb1200', 0, 'v3.8')

test_cmd('remote_for_branch', 'origin', 0, 'master')
test_cmd('remote_for_branch', 'origin', 1, 'maasdfasdfster')

test_cmd('remote_url', 'gitolite@at-git:linux-socfpga', 0, 'origin')

test_cmd('repo_is_bare', False, 0)

test_cmd('repo_name', 'linux-socfpga', 0)

test_cmd('subject', 'Linux 3.8', 0, 'v3.8')

test_cmd('toplevel', '/home/atull/repos/linux-socfpga', 0)

#test_cmd('up_to_date',

print '===================='
print 'Overall status: %s' % status
print '===================='


exit(0)


print git.branch_name()
exit(0)

try:
    patches = git.create_patches(output_path='lala_patches', num_commits=3, rev='HEAD^^^')
except:
    print 'I could not create the patches, sir.'

print patches
exit(0)
