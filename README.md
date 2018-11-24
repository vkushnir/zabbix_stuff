# Zabbix Scriprts

Zabbix alertscripts and externalscripts

## External Scripts

### strcomp.sh

_Compare two or more strings_

    Use strcom.sh <string1> <string2> ... <stringn>

Returns: 
* 0 - strings are not equal
* 1 - strings are equal 

### discovery.snmp.mac.if.sh

_If device return list of mac address in format `<OID>.<MAC>.<IFINDEX>` export them to **json** and add interfaces names_

    Use discovery.snmp.mac.if.sh <snmp version> <snmp commutity> <agent> <OID>

**Sample json**

```json
{
  "data": [
    {
      "{#MACD}": "76.94.12.128.18.143",
      "{#MACX}": "4C:5E:0C:80:12:8F",
      "{#IFINDEX}": "3",
      "{#IFNAME}": "wlan1",
      "{#IFALIAS}": "",
      "{#IFDESCR}": "wlan1"
    },
    {
      "{#MACD}": "212.202.109.72.198.97",
      "{#MACX}": "D4:CA:6D:48:C6:61",
      "{#IFINDEX}": "3",
      "{#IFNAME}": "wlan1",
      "{#IFALIAS}": "",
      "{#IFDESCR}": "wlan1"
    },
    {
      "{#MACD}": "212.202.109.80.223.123",
      "{#MACX}": "D4:CA:6D:50:DF:7B",
      "{#IFINDEX}": "3",
      "{#IFNAME}": "wlan1",
      "{#IFALIAS}": "",
      "{#IFDESCR}": "wlan1"
    }
  ]
}
```
    
## Zabbix  server configuration file

Parameter |	Mandatory |	Default |	Description
----------|-----------|---------|------------
AlertScriptsPath | no | `/usr/lib/zabbix/alertscripts` | Location of custom alert scripts<br/>(depends on compile-time installation variable datadir).
ExternalScripts | no | `/usr/lib/zabbix/externalscripts` | Location of external scripts<br/>(depends on compile-time installation variable datadir).
