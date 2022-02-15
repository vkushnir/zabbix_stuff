#!/bin/bash
# Get ZyXEL Software ID from Zabbix DATABASE
#
# Usage:
#
# getSwZyXEL.sh -h <host> [PARAMS]
#
# PARAMS:
#   -s <Server>
#   -d <database>
#   -u <user>
#   -p <password>
#   -f <fmt>
#   -k <Key>
#   -o <Keys Order>

#Set a default value for variables
#set -x

db_server="localhost"
db_user="zabbix_reader"
db_pass="D8oK6N3u"
db_name="zabbix"
fmt="%u.%02u(%s.%u)%04u%02u%02u"
key="sysSw%"
order="sysSwPlatformMajorVers,sysSwPlatformMinorVers,sysSwModelString,sysSwVersionControlNbr,sysSwYear,sysSwMonth,sysSwDay"
keys=(	\
	sysSwPlatformMajorVers	\
	sysSwPlatformMinorVers	\
	sysSwModelString	\
	sysSwVersionControlNbr	\
	sysSwYear		\
	sysSwMonth		\
	sysSwDay		\
)



#Check to see if at least one argument was specified 
if [ $# -lt 1 ] ; then
  echo "You must specify at least 1 argument." 
  exit 1
fi

#Process the arguments 
while getopts h:s:u:p:f:k:o: opt; do
  case "$opt" in
    h) host=$OPTARG;;
    s) db_server=$OPTARG;;
    d) db_name=$OPTARG;;
    u) db_user=$OPTARG;;
    p) db_pass=$OPTARG;;
    f) fmt=$OPTARG;;
    k) key=$OPTARG;;
    o) keys=$OPTARG;;
  esac
done

IFS=$'\t\n'

#sql="SELECT IFNULL(i.lastvalue,0) FROM items i WHERE i.hostid = (SELECT h.hostid FROM hosts h WHERE h.host = '${host}') AND i.key_ LIKE '${key}' ORDER BY FIND_IN_SET(i.key_, '${order}')"

# Get hostid
# ----------
sql="
SELECT
  h.hostid
FROM hosts h
WHERE h.host = '${host}'"
hostid=( `mysql -h$db_server -u$db_user -p$db_pass -D$db_name --skip-column-names -B -s -e "$sql;"` )

# Get items
# ---------
sql="
SELECT
  i.itemid, i.value_type
FROM items i
WHERE i.hostid = $hostid
AND i.key_ LIKE '$key'
ORDER BY FIND_IN_SET(i.key_, '$order')"

items=( `mysql -h$db_server -u$db_user -p$db_pass -D$db_name --skip-column-names -B -s -e "$sql;"` )

# Get Values
# ----------
for (( i = 0 ; i < ${#items[@]} ; i++ )) 
do
  itemid=${items[$i]}; ((i++))
  value_type=${items[$i]};
  case $value_type in
    0) table="history";;
    1) table="history_str";;
    3) table="history_uint";;
    4) table="history_text";;
  esac
  sql="
  SELECT
    h.value
  FROM ${table} h
  WHERE h.itemid = ${itemid}
  LIMIT 1;"
  
  values+=( `mysql -h$db_server -u$db_user -p$db_pass -D$db_name --skip-column-names -B -s -e "$sql;"` )
done

printf $fmt ${values[0]} ${values[1]} ${values[2]} ${values[3]} ${values[4]} ${values[5]} ${values[6]}

