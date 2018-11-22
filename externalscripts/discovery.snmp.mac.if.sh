#!/bin/sh
#
# Use discovery.snmp.mac.if.sh <snmp version> <snmpcommutity> <agent> <OID>

echo "$(date) CMD: $@" > /tmp/discovery.snmp.mac.if.log
if [ $# -ne 4 ]; then
  exit 0
fi

ifName=".1.3.6.1.2.1.31.1.1.1.1"
ifDescr=".1.3.6.1.2.1.2.2.1.2"
ifAlias=".1.3.6.1.2.1.31.1.1.1.18"

# Scan for MAC list
#list=$(snmpwalk -v $1 -c $2 -Otnq $3 $4 | cut -f1 -d' ')
list=$(snmpbulkwalk -v $1 -c $2 -Otnq $3 $4 | cut -f1 -d' ')
if [ ${#4} -gt ${#list} ]; then
  exit 1
fi

mac_list=()
macx_list=()
maci_list=()
for line in $list; do
  value=${line#$4.}
  mac=${value%.*}
  macx=$(printf '%02X:' ${mac//./ } | tr [:lower:] [:upper:])
  mac_list+=(${mac})
  maci_list+=(${value##*.})
  macx_list+=(${macx%:})
done

# Get interfaces data
maci_uniq=($(echo "${maci_list[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
if_name_list=()
id_descr_list=()
if_alias_list=()
for idx in $maci_uniq; do
  if_name_list[$idx]=$(snmpget -v $1 -c $2 -Oqv $3 $ifName.$idx)
  if_descr_list[$idx]=$(snmpget -v $1 -c $2 -Oqv $3 $ifDescr.$idx)
  if_alias_list[$idx]=$(snmpget -v $1 -c $2 -Oqv $3 $ifAlias.$idx)
done

# Print result
i=0
data=''
for mac in ${mac_list[@]}; do
  idx=${maci_list[$i]}
  data+="{ \"{#MACD}\":\"${mac_list[$i]}\", \"{#MACX}\":\"${macx_list[$i]}\", \"{#IFINDEX}\":\"${idx}\", \"{#IFNAME}\":\"${if_name_list[$idx]}\", \"{#IFALIAS}\":\"${if_alias[$idx]}\", \"{#IFDESCR}\":\"${if_descr_list[$idx]}\" },"
done
echo "{ \"data\":[ ${data%,} ]}"

