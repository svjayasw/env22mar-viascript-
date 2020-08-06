#!/usr/bin/env python

import httplib2
import json

def get_public_events():
    global report

    # get public info
#    url='https://api.github.com/users/mirror-opensource/events/public'
    url='https://api.github.com/users/altera-opensource/events/public'

    h = httplib2.Http()
    headers = {'content-type':'application/json',
               'accept':'application/json' }
    response, contents = h.request(url, "GET", headers=headers)
    if response['status'] != '200':
        return

    contents = json.loads(contents)
    report += "\nlooking at %s\n\n" % url
    report += json.dumps(contents, sort_keys=True, indent=4)

    # todo look for email address

#========================================================================

report = '---------------------------------------------------------------------------\n'

get_public_events()
print report
exit(0)
