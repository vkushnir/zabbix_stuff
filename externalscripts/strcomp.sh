#!/bin/sh
#
# Use strcomp.sh <string1> <string2> ... <stringn>
# Return 1 - if equal, 0 - if not equal

if [ $# -lt 2 ]; then
  exit 1
fi

str=''
for s in $@; do
  if [ -z $str ]; then
    str=$s
  else
    if [ "$str" == "$s" ]; then 
      echo 1
      exit 0
    fi
  fi
done
echo 0
exit 0 
