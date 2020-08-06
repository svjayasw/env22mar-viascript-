#!/usr/bin/env python
#
# HooksUtils = Various things used by the hooks
#
# Copyright (C) 2012 Alan Tull

import os
import sys
import re

# imports from this project
from GitReceivePack import *

# Paths on at-git
server_git_path = '/usr/local/git/'
repo_path = server_git_path + 'repositories/'

# This can get confused and broken if you do os.chdir() before calling.  So do it early.
def get_infra_path():
    self_realpath = os.path.abspath(__file__)
    self_dir_path = os.path.dirname(self_realpath)
    infra_rel_path = os.path.join(self_dir_path, '..')
    return os.path.abspath(infra_rel_path)

def get_repo_setting(repo_name, setting_name):
    try:
        repo_settings_full = os.path.join(get_infra_path(), 'repo-settings', repo_name)

        with open(repo_settings_full, 'r') as settings_file:
            re_setting = re.compile('^' + setting_name + ':.*', re.MULTILINE)
            settings = re_setting.findall(settings_file.read())

            if settings == []:
                return ''

            settings = settings[0]
            settings = re.sub(setting_name + ':', '', settings).split()
            if settings == []:
                return ''

            settings_file.close()
            return settings

    except:
        return ''

# For settings that will have only one setting or nothing...
def get_first_repo_setting(repo_name, setting_name, default=''):
    settings = get_repo_setting(repo_name, setting_name)
    if settings == '':
        setting = default
    else:
        setting = settings[0]
    return setting


class test_status:
    def __init__(self):
        self.status = 'PASS'

    def fail(self):
        self.status = 'FAIL'

    def is_good(self):
        return self.status == 'PASS'

    def print_status(self):
        print "testing status is %s" % self.status
