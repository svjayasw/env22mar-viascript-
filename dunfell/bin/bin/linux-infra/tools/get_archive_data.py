#!/usr/bin/env python
#
# Copyright (c) 2014, Altera Corporation
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of Altera Corporation nor the
#       names of its contributors may be used to endorse or promote products
#       derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED.  IN NO EVENT SHALL ALTERA CORPORATION BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import os
import sys
import re
import glob
import argparse
import textwrap
import subprocess
import time
import xlsxwriter
from urllib2 import urlopen, URLError, HTTPError
from datetime import date
import mailbox

#
#  ######  #    #  #    #   ####    ####
#  #       #    #  ##   #  #    #  #
#  #####   #    #  # #  #  #        ####
#  #       #    #  #  # #  #            #
#  #       #    #  #   ##  #    #  #    #
#  #        ####   #    #   ####    ####
#
#==============================================================================

def split_date_string_month(user_date):

    month, year = user_date.split('/')
  
    return int(month)

def split_date_string_year(user_date):

    month, year = user_date.split('/')
  
    return int(year)

def next_month(current_y, current_m):

       if current_m == 12:
           current_m = 1
           return current_m

       current_m = current_m + 1

       return current_m

def next_year(current_y, current_m):

       if current_m == 12:

           current_y = current_y + 1
           return current_y

       return current_y
  
def dlfile(url):
    # Open the url
    try:
        f = urlopen(url)
        print "downloading " + url

        stuff=os.path.basename(url)

        # Open our local file for writing
        with open(stuff, "wb") as local_file:
            local_file.write(f.read())

        return stuff

    #handle errors
    except HTTPError, e:
        print "HTTP Error:", e.code, url
    except URLError, e:
        print "URL Error:", e.reason, url

    return None

def collect_data(start_date, end_date, server, lists, workbook):
####
#  Sequence of operations
#!  Open Workbook                                          ## module = xlswriter
#!  For each list
#!    For(date, start_date,end_date) 
#!       download archive                                  ## module = urlgrabber
#!       extract data                                      ## module = mailbox
#!       save to worksheet  


    workbook = xlsxwriter.Workbook(args.workbook)

    # dates, using the class 'date'
    # dates are mm/yyyy
    o_date = date(split_date_string_year(start_date), split_date_string_month(start_date), 1)
    o_end_date = date(split_date_string_year(end_date), split_date_string_month(end_date), 1)
    
    for ml in lists:
        print "processing mailing list <"+ml+">"
        worksheet = workbook.add_worksheet("dates for "+ml)
        i = 2
        worksheet.write('A1', 'Month')
        worksheet.write('B1', 'Subject')
        worksheet.write('C1', 'From')
        worksheet.write('D1', 'Date')
        
        while o_date <= o_end_date:
           # now we have the date, we can Download
           print o_date
           
           url=server+"/pipermail/"+ml+"/"+o_date.strftime("%Y-%B")+".txt"
           f = dlfile(url)
           if f == None:
               url = url + ".gz"
               f = dlfile(url)
               if f == None:
                   print "Error: there is no archive file for date",  o_date.strftime("%Y-%B"), "on server "+server
                   worksheet.write('A'+str(i), o_date.strftime("%Y-%B"))
                   worksheet.write('B'+str(i), "Archive Not found, skipped")
                   i=i+1
                   o_date = o_date.replace(next_year(o_date.year, o_date.month), next_month(o_date.year, o_date.month), 1)
                   continue
               fi
           
           # and now, we parse!
           for message in mailbox.mbox(f):
               worksheet.write('A'+str(i), o_date.strftime("%Y-%B"))
               worksheet.write('B'+str(i), message['subject'])
               worksheet.write('C'+str(i), message['from'])
               worksheet.write('D'+str(i), message['date'])

               i=i+1

           os.remove(o_date.strftime(f))
           o_date = o_date.replace(next_year(o_date.year, o_date.month), next_month(o_date.year, o_date.month), 1)


        # let's download the text archive
        
        
    workbook.close()

    return


#
#   ####    #####    ##    #####    #####
#  #          #     #  #   #    #     #
#   ####      #    #    #  #    #     #
#       #     #    ######  #####      #
#  #    #     #    #    #  #   #      #
#   ####      #    #    #  #    #     #
#

#==============================================================================

# options and switches
parser = argparse.ArgumentParser(description='Collects data from mailman archives and stores into an XLS workbook',
                                 epilog = textwrap.dedent('''\
Usage: PROG [-h] --start <date> --end <date> -o <file.xls> --server <lists.blob.org> --list list [--list list,...]
   dates: <year>-<month>, example: 2013-June
          format for a date: mm/yyyy
          example --start 06/2013 --end 08/2014
'''
))

parser.add_argument('--start', dest='start_date', action='store',
                    help='''specifies the start date for the search''')
parser.add_argument('--end', dest='end_date', action='store',
                    help='''specifies the end date for the search''')
parser.add_argument('-o', dest='workbook', action='store',
                    help='''specifies the name of the workbook''')
parser.add_argument('--server', dest='server', action='store',
                    help='''specifies the name of the mailman server''')
parser.add_argument('--list', dest='mailinglists', action='append',
                    help='''specifies the name the list to scan. Can be used multiple times''')
parser.add_argument('--debug', dest='do_debug', action='store_true',
                    help='''turns on debug mode''')

# parse command line
args = parser.parse_args()

# process internals, modes.
debug = args.do_debug

if debug:
    print "start = "+args.start_date
    print "end   = "+args.end_date
    print "xls   = "+args.workbook
    print "lists = "+",".join(args.mailinglists)

                               ## 
collect_data(args.start_date, args.end_date, args.server, args.mailinglists, args.workbook)





