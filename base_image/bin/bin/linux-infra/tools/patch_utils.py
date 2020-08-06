#!/usr/bin/env python
#
# Utilities for patches
#
# Copyright 2012 Altera Corp
# Written by Alan Tull

import re

def open_patch_file(patch_path):
    try:
        f_patch = open(patch_path, 'r')
    except:
        print "Error opening patch file: ", patch_path
        exit(1)
    return f_patch

def get_patch_subject(f_patch):
    f_patch.seek(0)
    re_subject = re.compile("Subject: .*")
    try:
        subject_line = re_subject.findall(f_patch.read())[0]
    except:
        print "Error: couldn't find subject line of patch file: ", patch_path
        exit(1)
    return subject_line

def get_patch_header(f_patch):
    f_patch.seek(0)
    re_header = re.compile("(.*)^---$.*", re.MULTILINE|re.DOTALL)
    if re.match(re_header, f_patch.read()):
        f_patch.seek(0)
        return re.sub(re_header, "\\1", f_patch.read())
    else:
        return "Patch does not have a header"
