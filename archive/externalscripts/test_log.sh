#!/bin/sh
#
# Use test_log.sh <file> <string> ... [stringn]
# Return 1 - if equal, 0 - if not equal

if [ $# -lt 2 ]; then
  echo "Error: not enoth parameters!!!"
  exit 1
fi

fn=$1
line="$(date '+%Y-%m-%d %H:%M:%S') : "
shift

for val in $@; do
  line+="\"${val}\" : "
done
echo $line >> $fn
