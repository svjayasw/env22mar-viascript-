#!/usr/bin/env python

# List of license defenitions.  We compare in order, so put pickier ones at the top!
#
# Each license is a dictionary.  Can have these fields:
#  name          : Text name of license
#  rev           : Text revision of license (optional)
#  source        : Text (optional)
#  approved      : True|False  (optional, defaults to False)
#  license_text  : List of literal text licenses to compare.
#  license_regex : List of regular expression licenses to compare.
#  license_linux_kernel_spdx : List of literal text licenses to compare.  Text must be first line of file and have appropriate comment style.

license_list = [
# Kernel-specific SPDX GPLv2
    { 'name':'Linux Kernel SPDX GPLv2',
      'source':'https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/tree/Documentation/process/license-rules.rst',
      'approved': True,
      'license_linux_kernel_spdx':['''SPDX-License-Identifier: GPL-2.0''']
      },

    { 'name':'beer-ware',
      'rev':'42',
      'source':'http://en.wikipedia.org/wiki/Beerware#License',
      'license_text':['''THE BEER-WARE LICENSE" (Revision 42):
<phk@FreeBSD.ORG> wrote this file. As long as you retain this notice you
can do whatever you want with this stuff. If we meet some day, and you think
this stuff is worth it, you can buy me a beer in return Poul-Henning Kamp''']
    },

# Altera approved GPLv2
    { 'name':'GPLv2 Approved',
      'rev':'20130612',
      'source':'http://sw-wiki.altera.com/twiki/bin/view/Software/HPSOpenSourceRulesGPLv2#Approved_License_Header_GPLv2',
      'approved': True,
      'license_text':['''
This program is free software; you can redistribute it and/or modify it
under the terms and conditions of the GNU General Public License,
version 2, as published by the Free Software Foundation.

This program is distributed in the hope it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
more details.

You should have received a copy of the GNU General Public License along with
this program.  If not, see <http://www.gnu.org/licenses/>.''']
      },

    { 'name':'SPDX BSD-2-Clause',
      'license_linux_kernel_spdx':['''SPDX-License-Identifier: BSD-2-Clause''']
      },

# Non-approved GPLv2+ (SPDX version)
    { 'name':'SPDX GPLv2+',
      'rev':'20151123',
      'source':'somewhere',
      'license_text':['''SPDX-License-Identifier: GPL-2.0+''']
      },

# Altera approved GPLv2 (SPDX version) - but not the kernel's strict version!
    { 'name':'SPDX GPLv2',
      'rev':'20151123',
      'source':'somewhere',
      'approved': True,
      'license_text':['''SPDX-License-Identifier: GPL-2.0''']
      },

# GPL v2 or later
    { 'name':'GPLv2 or later',
      'license_regex': ['(GPL|GNU General Public License) .*(Version|version|V|v) ?2 .*later'],
      'license_text': ['GPL-2 or later']
      },

# GPL v2
    { 'name':'GPLv2',
      'license_regex': ['(GPL|GNU General Public License) .*(Version|version|V|v) ?2',
                        '(Version|version|V|v) ?2 (|of )the (GPL|GNU General Public License)']
      },

# GPL
    { 'name':'GPL',
      'license_regex': ['(GPL|GNU General Public License)',
                        '(Version|version|V|v) ?2 (|of )the (GPL|GNU General Public License)']
      },

# LGPL v2.1 or later
    { 'name':'LGPLv2.1 or later',
      'license_regex':['GNU Lesser General Public License .*[Vv]ersion 2.1 .*later',
                       '[Vv]ersion 2.1 .*later .*GNU Lesser General Public License']
      },

# LGPL
    { 'name':'LGPL',
      'license_text':['GNU Lesser General Public License']
      },
];
