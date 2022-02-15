#!/bin/bash
# Concatinate string with formatting
#
# Usage:
#
# concat_fmt.sh -f <format> [string1] [string2] ... [stringn]
#

#Set a default value for variables

fmt="%s [%s]"

#Check to see if at least one argument was specified 
if [ $# -lt 1 ] ; then
  echo "You must specify at least 1 argument." 
  exit 1
fi

#Process the arguments 
while getopts f: opt; do
  case "$opt" in
    f) fmt=$OPTARG;;
  esac
done

shift $(($OPTIND-1))

IFS=$'\t\n'

printf $fmt $@
