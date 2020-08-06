#!/usr/bin/env python

# Written by Thor Thayer on Aug 13, 2019
# Copied extensively from ips800-powerstrip.py
# Written by Alan Tull on Jan 25, 2017

# Supports Raritan series ethernet controlled powerstrip
# Manual : https://www.wti.com/guides/ips816b.pdf

import ast
import argparse
import getpass
import os
import re
import sys
import telnetlib
import textwrap
import socket
import time

from pprint import pprint

rc_fn = os.path.expanduser("~/.rar_powerstrip.rc")
    
# Print msg to user console if in '-v' verbose mode
def verbose_console(msg):
    global verbose
    if verbose:
        print msg

# read script config from rc file        
def read_config():
    global rc_fn
    try:
        rcf = open(rc_fn, 'r')
        conf = ast.literal_eval(rcf.read())
        rcf.close()
        verbose_console(str(conf))
        verbose_console('')
        verbose_console('%-10s  | %-25s | %s | %-15s |' % ('alias', 'host', 'outlet', 'password'))
        for alias in conf:
            verbose_console('%-10s  | %-25s |   %s    | %-15s |' % (alias, conf[alias]['host'], conf[alias]['outlet'], conf[alias]['password']))
        verbose_console('')
        return conf
    except:
        return {}

# write script config to rc file        
def write_config(config):
    global rc_fn
    rcf = open(rc_fn, 'w')
    rcf.write(str(config))
    rcf.close()

def add_alias(alias, config):
    if alias in config:
        print "overwriting existing alias (%s).  Hit ctrl-c to abort." % alias

    host = raw_input('enter powerstrip ip or hostname : ')
    outlet = raw_input('enter powerstrip socket [1-24] : ')
    password = getpass.getpass()
    
    config[alias] = {'outlet':outlet, 'host':host, 'password':password }
    verbose_console(config)
    write_config(config)
    
# extract one line of outlet status from console msg    
def status_line(tn, outlet, msgs):
#    try:
#        return re.findall(re.compile(' %s .*' % outlet), msgs)[0]
#    except:
#        return ''
    tn.write("show outlets\r\n")
    verbose_console("outlet set to %d\r\n" % int(outlet))
    msgs = read_until(tn, "> ", 2)
    msg_array = msgs.split('\r\n')
#    for line in msgs.split(': \r\n'):
    for line,next_line in zip(msg_array, msg_array[1:]):
	str_int = [int(s) for s in line.split() if s.isdigit()]
        if len(str_int) > 0 and int(str_int[-1]) == int(outlet):
	    line2 = next_line
            return line2
    return ''
    
# extract 'ON' or 'OFF' from the outlet status console msg
def outlet_status(tn, outlet, msgs):
    st = status_line(tn, outlet, msgs)
    verbose_console('status line : ' + st)
    try:
        on_off = st.split(':')[-1].strip()
        if on_off.upper() == 'ON':
            return 'on'
        elif on_off.upper() == 'OFF':
            return 'off'
        else:
            return 'unknown'
    except:
        return 'unknown'
    
# Telnet functions
def read_until(tn, until_str, timeout=None):
    if timeout == None:
        msgs = tn.read_until(until_str)
    else:
        msgs = tn.read_until(until_str, timeout)
    verbose_console(msgs)
    return msgs

# Start a telnet session, log on, return telnet and telnet console msgs
def log_on(host, password):
    global verboser

    hostname = socket.gethostname().strip().upper()
    verbose_console("Creating telnet session...")
    # args are: host, port, timeout
    try:
        tn = telnetlib.Telnet(host, 23, 3)
    except:
        print "Couldn't establish telnet connection, gave up before logon."
        exit(0)
    if verboser:
        tn.set_debuglevel(5)

    verbose_console("Logging on...")
    msgs = read_until(tn, "Username: ")
    #tn.write(hostname.strip() + "\r\n")
    tn.write(password.upper() + "\r\n")
    msgs = read_until(tn, "Password: ")
    tn.write(password + "\r\n")

    msgs = read_until(tn, "> ", 2)
    # should watch for "Invalid Password."

    verbose_console("Connected to powerstrip...")
    return (tn, msgs)

# Answer 'Sure?' dialog with 'y'
def yes_i_am_sure(tn):
    msg = read_until(tn, "[y/n] ", 1)
    telnet_write(tn, "y\r\n")
    return msg

# Write cmd out to telnet and optionally echo to user console
def telnet_write(tn, cmd):
    tn.write(cmd)
    verbose_console(cmd)

# Action can be : /[on|off|boot] [1-8]
def do_action(tn, action, outlet):
    action = action.lower()
    cmd = "power outlets " + outlet + ' ' + action + "\r\n"
    telnet_write(tn, cmd)
    yes_i_am_sure(tn)
    msgs = read_until(tn, "> ", 2)
    status = outlet_status(tn, outlet, msgs)
    if action in ['on', 'off'] and status != action:
        print 'Error: powerstrip returned status = %s' % status

# Disconnect from telnet session
def disconnect(tn):
    telnet_write(tn, "exit\r\n")
   # yes_i_am_sure(tn)
    read_until(tn, "Connection closed by foreign host.", 2)

def do_action_on_alias(alias, action):
    password = config[alias]['password']
    host = config[alias]['host']
    outlet = config[alias]['outlet']

    verbose_console("host     : %s" % host)
    verbose_console("outlet   : %s" % outlet)
    verbose_console("password : %s" % password)

    (tn,msgs) = log_on(host, password)
    if action in ['on','off','cycle']:
        do_action(tn, action, outlet)
        # Returns after sending cycle command so add delay.
        if action == 'cycle' :
            time.sleep(10)
    elif action == 'status':
        print outlet_status(tn, outlet,msgs)
    disconnect(tn)
    tn = None

#==========================================================================================

parser = argparse.ArgumentParser(formatter_class=argparse.RawDescriptionHelpFormatter,
                                 description="Control powerstrip.",
                                 epilog=textwrap.dedent('''\

%(prog)s keeps a set of aliases for powerstrip outlets saved locally in
the user home directory.

To add an alias, use the 'add' command like:
  %(prog)s -a a10 add

To remove an alias, use the 'rm' command like:
  %(prog)s -a a10 rm

To remove config file, use the 'rm' command with '--all':
  %(prog)s --all rm

To list aliases:
  %(prog)s ls

Most of the time you'll be using commands to turn on, off, or power cycle
an outlet such as:
  %(prog)s -a a10 on
  %(prog)s -a a10 off
  %(prog)s -a a10 cycle

To get status (on/off) of an outlet:
  %(prog)s -a a10 status
'''))


parser.add_argument("-v", dest="verbose", action="store_true", help="nice helpful verbose for debugging")
parser.add_argument("-vv", dest="verboser", action="store_true", help="ugly low level verbose. don't use unless you have to.")
group = parser.add_mutually_exclusive_group()
group.add_argument("-a", dest="alias", help="your own alias for the outlet, such as 'a10' or 'c5'")
group.add_argument("--all", dest="all_aliases", action="store_true", help="do action for all outlets in config")
parser.add_argument("action", choices=['on','off','cycle','status','rm','add','ls'],
                    help="do this action.")

args = parser.parse_args()

action = args.action
alias = args.alias
all_aliases = args.all_aliases
verbose = args.verbose
verboser = args.verboser

#-------------------------------------------------------------------------------------------

config = read_config()

if action == 'ls':
    if alias != None or all_aliases:
        print "Error: do not specify '-a' or '--all' with 'ls' command"
        exit(0)
    print('%-10s  | %-25s | %s |' % ('alias', 'host', 'outlet'))
    for alias in config:
        print('%-10s  | %-25s |   %s    |' % (alias, config[alias]['host'], config[alias]['outlet']))
    print('')
    exit(0)

if action == 'rm':
    if all_aliases:
        os.unlink(rc_fn)
        exit(0)
    if alias == None:
        print "Error: must specify '-a ALIAS' or '--all' with 'rm'"
        exit(0)
    if alias in config:
        del config[alias]
        write_config(config)
        print "Deleted alias %s" % alias
    else:
        print "Alias %s not in config file" % alias
    exit(0)

if action == 'add':
    if alias == None:
        print "Error must specify '-a ALIAS' with 'add'"
    else:
        add_alias(alias, config)
    exit(0)

if action not in ['on','off','cycle', 'status']:
    print 'Programming error, should not have gotten this far for command %s' % action
    exit(0)
    
if all_aliases:
    for alias in config:
        do_action_on_alias(alias, action)
    exit(0)

if alias not in config:
    print "alias (%s) not in config.  Specify 'add' to add it." % alias
    exit(0)

do_action_on_alias(alias, action)
exit(0)
