#!/usr/bin/env python
#
# Tests that are run on the per file level
#
# Copyright (C) 2013 Alan Tull atull@altera.com

import os
import sys
import re
import tempfile
import subprocess

# imports from this project
from GitReceivePack import *
from HooksUtils import *
from license_defs import license_list

class TestLicense:
    def __init__(self):
        infra = get_infra_path()

    # Given a string, remove comments /* * */, linefeeds, and convert
    # all whitespace into single spaces.
    def clean_up_header(self, header):
        header = re.sub('\n', ' ', header)
        header = re.sub('/\*|\*/', ' ', header)
        header = re.sub('\s\*', ' ', header)
        header = re.sub('\s+', ' ', header)
        header = re.sub('^ ', '', header)
        header = re.sub(' $', "", header)
        return header

    # Get a header from a source file or from a commit
    def get_header(self, file_name, commit=None):
        if commit:
            git = commit.git
            if file_name not in commit.file_blob_hashes():
                return ''

            blob_hash = commit.file_blob_hashes()[file_name]

            file_text = git.blob_from_hash(blob_hash)
        else:
            try:
                srcfile = open(file_name, 'r')
                file_text = srcfile.read()
                srcfile.close()
            except:
                return ''

        # get all text in the file up to the first preprocessor command
        header = ''
        for line in file_text.split('\n'):
            if re.match(re.compile('^#(include|define|ifdef|ifndef)'), line):
                break
            elif header == '':
                header = line
            else:
                header = header + '\n' + line

        return header

    def match_license(self, raw_header, file_full):
        base_name = os.path.basename(file_full)

        top_line = raw_header.split('\n')[0]
        header = self.clean_up_header(raw_header)

        for lic in license_list:
            if 'license_linux_kernel_spdx' in lic:
                for lic_text in lic['license_linux_kernel_spdx']:
                # https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/tree/Documentation/process/license-rules.rst
                    if re.compile(".*\.(c|dts|dtsi)$").match(base_name):
                        lic_commented = "// " + lic_text
                    elif re.compile(".*\.(h|asm)$").match(base_name):
                        lic_commented = "/* " + lic_text + " */"
                    elif re.compile(".*\.rst$").match(base_name):
                        lic_commented = ".. " + lic_text
                    else:
                        lic_commented = "# " + lic_text

                    if top_line == lic_commented:
                        return lic['name']
            if 'license_text' in lic:
                for lic_text in lic['license_text']:
                    license_text = self.clean_up_header(lic_text)
                    if header.find(license_text) >= 0:
                        return lic['name']
            if 'license_regex' in lic:
                for lic_regex in lic['license_regex']:
                    license_regex = re.compile(lic_regex, re.MULTILINE)
                    if license_regex.findall(header):
                        return lic['name']

        # No license found
        return ''

    def match_commit_licenses(self, commit):
        commit_licenses = {}
        for file_name in commit.file_blob_hashes().keys():
            raw_header = self.get_header(file_name, commit)
            file_license = self.match_license(raw_header, file_name)
            commit_licenses[file_name] = file_license
        return commit_licenses
