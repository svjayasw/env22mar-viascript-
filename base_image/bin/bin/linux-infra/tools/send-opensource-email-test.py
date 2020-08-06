#!/usr/bin/env python

import argparse
import getpass
import json
import os
import re
import sys
import textwrap
import time
import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

# Local libraries
sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'tools'))
from git_utils import *

#=============================================================
# Globals

# These assume linux-infra cloned as ~/bin/linux-infra and that
# linux-infra/bin is in the PATH

smtp_server = 'smtp.office365.com:587'

#====================================================
# Email functions

def send_email(smtp_server, to_addrs, msg):
    # I am assuming your user name is not all jacked up
    user = getpass.getuser()

    user_corporate_email = user + '@altera.com'
    # actual account does not have the period
    user_opensource_user = user + '@opensourcealtera.com'
    user_opensource_email = user + '@opensource.altera.com'

    # code from http://pymotw.com/2/smtplib/
    try:
        server = smtplib.SMTP(smtp_server)
        # server.set_debuglevel(True)

        # If server has STARTTLS, it is the office365 server and needs
        # authentication and the opensouce.altera.com from address.
        server.ehlo()

        if server.has_extn('STARTTLS'):
            msg['From'] = user_opensource_email
            msg.add_header('reply-to', user_corporate_email)
        else:
            msg['From'] = user_corporate_email

        print 'From: %s' % msg['From']
        print 'Email subject: %s' % msg['Subject']

        if server.has_extn('STARTTLS'):
            password = getpass.getpass("%s's opensource email password (maybe not corporate password): " % msg['From'])
            server.starttls()
            server.ehlo()
            server.login(user_opensource_user, password)

        server.sendmail(msg['From'], to_addrs, msg.as_string())
    except:
        raise
    finally:
        server.quit()

def send_report_email(to_list, report):
    print 'sending to this list: ' + str(to_list)

    to_addrs = []
    cc_addrs = []

    for addr in to_list:
        to_addrs.append(addr + '@altera.com')

    print 'to: ', to_addrs
    print 'cc: ', cc_addrs

    msg = MIMEMultipart('alternative')
    msg['Subject'] = 'This is a test'
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

    send_email(smtp_server, to_addrs, msg)

    print 'Success (posted as email)...'

#--------------------------------------------------------------
report='This is a test. Only a test'

to_list = [ 'atull' ]
send_report_email(to_list, report)

exit(0)
