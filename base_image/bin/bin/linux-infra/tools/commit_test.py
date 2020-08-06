#!/usr/bin/env python

import os
import sys

# Add the ../tools directory to the path so that we can import git_utils.py
sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'hooks'))
from git_utils import *

#============================================================================
def check_results(expected_status, cmd_status, expected_stdout, cmd_stdout):
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

def test_cmd(commit, cmd, expected_stdout, expected_status, *args, **kwargs):
    global status
    print 'test: \'commit.%s %s\' == %s' % (cmd, ' '.join(args), expected_stdout)

    if cmd in vars(commit):
        cmd_stdout = vars(commit)[cmd]
        cmd_status = 0
    else:
        # get a pointer to the command in our git library
        try:
            methodToCall = getattr(commit, cmd)
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

    check_results(expected_status, cmd_status, expected_stdout, cmd_stdout)

#============================================================================

git = git_utils()
status = 'PASS'
os.chdir('/home/atull/repos/linux-socfpga')

repo = Repo(os.getcwd())
if not repo.in_repo:
    print 'Not in a git repository.  Please cd to your git repository.'
    exit(1)

commit = Commit(repo, 'fe80c85cfb14fb715e7eea02bcdf8771b078e6ed')

print 'Basic Commit operations...'

# test_cmd(commit, cmd, expected_stdout, expected_status, *args, **kwargs)

#test_cmd(commit, 'diff_tree_files', '', 0 )

test_cmd(commit, 'file_blob_hashes',
         {'arch/nios2/kernel/cpuinfo.c': '0b6c8c597674e9cb05e7b52b41afe35be175c432'}, 0)

test_cmd(commit, 'header', 
'''commit fe80c85cfb14fb715e7eea02bcdf8771b078e6ed
Author: Ley Foon Tan <lftan@altera.com>
Date:   Thu Feb 13 11:23:03 2014 +0800

    FogBugz #183586: nios2: Use checking for ALTR,pid-num-ways
    
    Remove checking for ALTR,has-mmu and use ALTR,pid-num-ways instead for
    backward compatibility. pid-num-ways shouldn't be 0 if MMU is enabled.
    This also can prevent division by zero exception when divide with
    cpuinfo.tlb_num_ways later.
    
    Signed-off-by: Ley Foon Tan <lftan@altera.com>
''', 0 )

test_cmd(commit, 'parent_hashes', ['8280d97775ab58cec7e0c20a970f7cce84c81691'], 0)

test_cmd(commit, 'subject', 'FogBugz #183586: nios2: Use checking for ALTR,pid-num-ways', 0 )

# This one fails, due to some text difference I can't find.
test_cmd(commit, 'patch', 
'''From fe80c85cfb14fb715e7eea02bcdf8771b078e6ed Mon Sep 17 00:00:00 2001
From: Ley Foon Tan <lftan@altera.com>
Date: Thu, 13 Feb 2014 11:23:03 +0800
Subject: [PATCH] FogBugz #183586: nios2: Use checking for ALTR,pid-num-ways

Remove checking for ALTR,has-mmu and use ALTR,pid-num-ways instead for
backward compatibility. pid-num-ways shouldn't be 0 if MMU is enabled.
This also can prevent division by zero exception when divide with
cpuinfo.tlb_num_ways later.

Signed-off-by: Ley Foon Tan <lftan@altera.com>
---
 arch/nios2/kernel/cpuinfo.c |   12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

diff --git a/arch/nios2/kernel/cpuinfo.c b/arch/nios2/kernel/cpuinfo.c
index 02bdafa..0b6c8c5 100644
--- a/arch/nios2/kernel/cpuinfo.c
+++ b/arch/nios2/kernel/cpuinfo.c
@@ -56,13 +56,6 @@ void __init setup_cpuinfo(void)
 	if (!cpu)
 		panic("%s: No CPU found in devicetree!\\n", __func__);
 
-	cpuinfo.mmu = fcpu_has(cpu, "ALTR,has-mmu");
-	if (!cpuinfo.mmu) {
-		panic("ERROR: Can't get 'ALTR,has-mmu' from device tree. Only support"
-			" Nios II with MMU enabled. Please enable MMU in Nios II "
-			"hardware.");
-	}
-
 	cpuinfo.cpu_clock_freq = fcpu(cpu, "clock-frequency");
 
 	str = of_get_property(cpu, "ALTR,implementation", &len);
@@ -88,13 +81,16 @@ void __init setup_cpuinfo(void)
 		err_cpu("MULX");
 #endif
 
+	cpuinfo.tlb_num_ways = fcpu(cpu, "ALTR,tlb-num-ways");
+	if (!cpuinfo.tlb_num_ways)
+		panic("ALTR,tlb-num-ways can't be 0. Please check your hardware "
+			"system\\n");
 	cpuinfo.icache_line_size = fcpu(cpu, "icache-line-size");
 	cpuinfo.icache_size = fcpu(cpu, "icache-size");
 	cpuinfo.dcache_line_size = fcpu(cpu, "dcache-line-size");
 	cpuinfo.dcache_size = fcpu(cpu, "dcache-size");
 
 	cpuinfo.tlb_pid_num_bits = fcpu(cpu, "ALTR,pid-num-bits");
-	cpuinfo.tlb_num_ways = fcpu(cpu, "ALTR,tlb-num-ways");
 	cpuinfo.tlb_num_ways_log2 = ilog2(cpuinfo.tlb_num_ways);
 	cpuinfo.tlb_num_entries = fcpu(cpu, "ALTR,tlb-num-entries");
 	cpuinfo.tlb_num_lines = cpuinfo.tlb_num_entries / cpuinfo.tlb_num_ways;
-- 
1.7.9.5


''', 0 )

