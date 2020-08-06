#!/usr/bin/env python
#
# Communicate with Crucible using REST API
#
# Copyright 2012 Altera Corp
# Written by Alan Tull
#
# A few notes:
#  * Atlassian's online documentation is out of date. Google the forums.
#  * Python works nicely with JSON stuff and effortlessy parses it.
#
# example code on:
#   https://developer.atlassian.com/display/FECRUDEV/Writing+a+REST+Client+in+Python
#
# REST API user guide on:
#   https://developer.atlassian.com/display/FECRUDEV/REST+API+Guide
#
# not very accurate REST API reference (list of API's):
#   http://docs.atlassian.com/fisheye-crucible/latest/wadl/crucible.html
#

import os
import json
import requests

# Local lib
from patch_utils import *
from git_utils import *

def print_http_status(status):
    http_errors = {
        200 : { 'status' : 'OK', 'msg' : 'OK', },
        201 : { 'status' : 'OK', 'msg' : 'Created', },
        304 : { 'status' : 'OK', 'msg' : 'Not Modified', },
        400 : { 'status' : 'Error', 'msg' : 'Bad Request', },
        401 : { 'status' : 'Error', 'msg' : 'Unauthorized (check your username/password)', },
        404 : { 'status' : 'Error', 'msg' : 'Not Found', },
    }

    if status in http_errors.keys():
        print ' *** %s %s : %s' % (http_errors[status]['status'], status, http_errors[status]['msg'])
    else:
        print ' *** Error %s' % status

def req_post(url, body={}, good_status={200,304}, auth=None, verbose=False):
    headers = {'content-type':'application/json',
               'accept':'application/json'}

    body=json.dumps(body)
    if verbose:
        print "request url = %s" % (url)
        print "request body = %s" % json.dumps(body, sort_keys=True, indent=4), "\n"

    try:
        req = requests.post(url, headers=headers, data=body, auth=auth)
    except requests.exceptions.RequestException as e:
        print 'requests.post had an exception.'
        print e
        exit(1)
    try:
        status = req.status_code
    except:
        print 'exception getting status_code'
        exit(1)

    print_http_status(status)
    if status not in good_status:
        exit(1)

    try:
        contents = req.text
    except:
        print 'exception getting req.text'
        exit(1)

    if verbose:
        print contents
        print

    try:
        contents = json.loads(contents)
    except:
        print 'exception at json.loads(contents)'
        exit(1)

    return contents

def create_review(git, commit, commit_num, num_commits, username, password, project,
                  gcomment=None, crucible_url=None, verbose=False):

    rest_url = os.path.join(crucible_url, 'rest-service')

    print 'Using Crucible at %s' % (rest_url)

    # http://docs.python-requests.org/en/master/user/authentication/
    auth = ( username, password )

    if verbose:
        print 'Creating new review'
    # Note that the documentation sucks and is out of date.
    # The 'createReview' tag is no longer needed:
    #   https://jira.atlassian.com/browse/CRUC-5317
    rbody = {
        "reviewData": {
            "author":{"userName":username},
            "moderator":{"userName":username},
            "description":"{noformat}" + commit.header() + "{noformat}",
            "name":commit.subject,
            "metricsVersion":1,
            "projectKey":project,
            "creator":{"userName":username},
            "allowReviewersToJoin":"true"
            }
        };
    url = os.path.join(rest_url, "reviews-v1")

    attempts = 4
    for attempt in range(1, attempts + 1):
        # status 201 = Created
        try:
            contents = req_post(url, body=rbody, good_status={201}, auth=auth, verbose=verbose)
            break
        except:
            if attempt < attempts:
                print "Attempt #%d of %d failed, trying again" % (attempt, attempts)
            else:
                print "Attempt #%d of %d failed, giving up" % (attempt, attempts)
                raise
    review_id = contents["permaId"]["id"]

    if gcomment:
        if verbose:
            print 'Adding general comment to review ', gcomment
        rbody = {"message":gcomment};
        url = os.path.join(rest_url, "reviews-v1", review_id, "comments")
        try:
            contents = req_post(url, body=rbody, good_status={201}, auth=auth, verbose=verbose)
        except:
            print 'Error doing POST command to add general comment Crucible. Giving up.'
            raise

    if verbose:
        print 'Adding patch to review ', review_id

    # Crucible likes patches that are *not* in git format-patch -C (or -M) (detect renames) format.
    patch, rc = git.git_cmd_with_status('format-patch', '-1', '--stdout', commit.hash)
    rbody = {"patch" : patch};

    url = os.path.join(rest_url, "reviews-v1", review_id, "patch")
    try:
        contents = req_post(url, body=rbody, auth=auth, verbose=verbose)
    except:
        print 'Error doing POST command to add patch in Crucible. Giving up.'
        raise

    if verbose:
        print 'Changing state of review ', review_id
    url = os.path.join(rest_url, "reviews-v1", review_id, "transition?action=action:approveReview")
    try:
        contents = req_post(url, auth=auth, verbose=verbose)
    except:
        print 'Error doing POST command to change state of review in Crucible. Giving up.'
        raise

    print 'Success posted review %s on Crucible' % review_id

#   https://pg-rdcrucible.altera.com:8080/cru/linux-socfpga-1325
    review_url = os.path.join(crucible_url, 'cru', review_id)
    print
    print '%s' % review_url

