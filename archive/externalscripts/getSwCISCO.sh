#!/bin/bash
# Get CISCO Software ID from Zabbix DATABASE
#
# Usage:
#
# getSwCISCO.sh -h <host> [-t|-v] [PARAMS]
#
# OPTIONS:
#  -t Get software type 
#  -s Get software version
# PARAMS:
#  -s <Server>
#  -d <Database>
#  -u <User>
#  -p <Password>
#  -f <Format>

#Set a default value for variables

db_server="localhost"
db_user="zabbix_reader"
db_pass="D8oK6N3u"
db_name="zabbix"
key="sysDescr"
fmt="%s [%s]"
md=3

#Check to see if at least one argument was specified 
if [ $# -lt 1 ] ; then
  echo "You must specify at least 1 argument." 
  exit 1
fi

#Process the arguments 
while getopts h:s:d:u:p:tvf: opt; do
  case "$opt" in
    h) host=$OPTARG;;
    s) db_server=$OPTARG;;
    d) db_name=$OPTARG;;
    u) db_user=$OPTARG;;
    p) db_pass=$OPTARG;;
    t) md=1;;
    v) md=2;;
    f) fmt=$OPTARG;;
  esac
done

IFS=$'\t\n'

sql="
SELECT
  hs.value
FROM history_str hs
WHERE hs.itemid = (
    SELECT
      i.itemid
    FROM items i
    WHERE i.hostid = (
        SELECT
          h.hostid
        FROM hosts h
        WHERE h.host = '${host}')
    AND i.key_ = '${key}') 
LIMIT 1;"

res=( `mysql -h$db_server -u$db_user -p$db_pass -D$db_name --skip-column-names -B -s -e "$sql;"` )

# Get softare ID parts
if [[ "$res" =~ IOS ]]; then
  sysDescr=`echo $res | grep IOS`
  swType=`echo $sysDescr | grep -Eo  'Software +(\([[:alnum:]\_\-]+\))' | cut -d'(' -f2 | cut -d')' -f1`
  swVer=`echo $sysDescr | grep -Eo  'Version +([[:alnum:]\.\)\(]+)' | cut -d' ' -f2`
fi

# Print Result
case "$md" in
  1) echo -n $swType;;
  2) echo -n $swVer;;
  3) printf "$fmt" "$swType" "$swVer";;
esac


