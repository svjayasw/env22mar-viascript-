#!/bin/bash

function usage()
{
    echo "$(basename $0)"
    echo " print unique email addresses in 'email:' lines"
}

case "$1" in
    -h ) usage ; exit 0;;
esac

cd $(dirname $0)
grep -h '^email:' * | cut -d: -f2 | xargs -n1 | sort -u
