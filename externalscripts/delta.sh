#!/bin/sh
#
# Use delta.sh <value1> <value2> ... <valuen>
# Return 1 - if equal, 0 - if not equal

if [ $# -lt 2 ]; then
  exit 1
fi

min=`echo $@ | tr "[:space:]" "\n" | sort -rn | tail -1`
max=`echo $@ | tr "[:space:]" "\n" | sort -rn | head -1`
diff=`expr $max - $min`
echo $diff
