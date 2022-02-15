#!/usr/bin/python2
#
# Use sql.grpitem.py <{HOST.NAME}> <RE_KEY>
# create login-path for sql access
# sudo -u zabbix mysql_config_editor set --login-path=zabbix-login --host=<host> --user=<user> --password

import os
import sys
from subprocess import check_output

os.environ['HOME'] = '/var/lib/zabbix'
SQL = '/usr/bin/mysql'
db_name = 'zabbix'

args = sys.argv[1:]

if len(args) < 2:
    print "Error: not enoth parameters!!!"
    sys.exit(1)

host = args[0]
re_key = args[1]

hostid = check_output([SQL, '--login-path=zabbix-login', db_name, '--skip-column-names', '-B', '-s', '-e',
                       "SELECT hostid FROM hosts WHERE host=\"{}\";".format(host)])
if hostid == "":
    print "Error: host \"{}\" not found!!!".format(host)
    sys.exit(1)

str_values = check_output([SQL, '--login-path=zabbix-login', db_name, '--skip-column-names', '-B', '-s', '-e',
                           "SELECT (SELECT value FROM history h WHERE h.itemid=i.itemid ORDER BY clock DESC LIMIT 1) AS value FROM items i WHERE hostid={} AND key_ REGEXP \"{}\";".format(
                               hostid, re_key)]).split()
cnt = len(str_values)
if cnt <= 0:
    print "Error: items not found!!!"
    sys.exit(1)

values = [float(val) for val in str_values]
sum = sum(values)
print "cnt:{}, max:{}, min:{}, avg:{}, sum:{}".format(cnt, max(values), min(values), sum / cnt, sum)
