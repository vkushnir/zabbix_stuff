#!/bin/sh
#
# Use snmp.str2num.sh <snmp version> <snmpcommutity> <agent> <OID>

if [ $# -ne 4 ]; then
  exit 1
fi
snmpget="/usr/bin/snmpget"

value=$(${snmpget} -v $1 -c $2 -Oqv $3 $4 )
if [ $? -ne 0 ]; then
  exit 1
fi

echo ${value//[!0-9]/}

