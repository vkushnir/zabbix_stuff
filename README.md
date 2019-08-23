# Zabbix Scriprts

Zabbix alertscripts and externalscripts

## External Scripts

### strcomp.sh

_Compare two or more strings_

    Use strcom.sh <string1> <string2> ... <stringn>

Returns: 
* 0 - strings are not equal
* 1 - strings are equal 

### snmp.str2num.sh

_Extract numbers from snmp device returned string_

    Use snmp.str2num.sh <snmp version> <snmp commutity> <agent> <OID>

**Sample**
```
[user@home]$ snmpget -v 1 -c public 172.0.0.1 .1.3.6.1.4.1.41112.1.3.2.1.43.1
SNMPv2-SMI::enterprises.41112.1.3.2.1.43.1 = STRING: "1000Mbps-Full"

[user@home]$ ./snmp.str2num.sh 1 public 127.0.0.1 .1.3.6.1.4.1.41112.1.3.2.1.43.1
1000
```

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

# Alert Scripts

## Pushover

_Usage:_

    pushover_zabbix.sh <recipient> <subject> <message> [token]
    
* **recipient** &ndash; **user**[@**device**[:**token**]]
* **subject** &ndash; message title
* **message** &ndash; formatted message

Configuration file: ```/etc/zabbix/pushover.conf```

```
PTOKEN=""       # (required) - your application's API token
PUSER=""        # (required) - the user/group key (not e-mail address) of your user (or you)
PMESSAGE=""     # (required) - your message
PATTACHMENT=""	# an image attachment to send with the message;
PDEVICE=""	    # your user's device name to send the message directly to that device, rather than all of the user's devices (multiple devices may be separated by a comma)
PTITLE=""	    # your message's title, otherwise your app's name is used
PURL=""		    # a supplementary URL to show with your message
PURL_TITLE=""	# a title for your supplementary URL, otherwise just the URL is shown
PPRIORITY=""	# send as -2 to generate no notification/alert, -1 to always send as a quiet notification, 1 to display as high-priority and bypass the user's quiet hours, or 2 to also require confirmation from the user
PSOUND=""	    # the name of one of the sounds supported by device clients to override the user's default sound choice
PTIMESTAMP=""	# a Unix timestamp of your message's date and time to display to the user, rather than the time your message is received by our API
PHTML=""	    # enable HTML formatting
PMONOSPACE=""	# enable monospace formatting

CURL_OPTS=""    # curl options
PUSHOVER_URL="https://api.pushover.net/1/messages.json"
```
Override order:  **pushover_zabbix.sh** &raquo; **pushover.conf** &raquo; **CMD ARGS** &raquo; **&lt;message fields&gt;**

### Message parameters

Format: **%PUSHOVER:&lt;PARAM&gt;%&lt;value&gt;**

* **TOKEN** &ndash; your application's API token
* **USER** &ndash; the user/group key (not e-mail address) of your user (or you)
* **MESSAGE** &ndash; your message
* **ATTACHMENT** &ndash; an image attachment to send with the message;
* **DEVICE** &ndash; your user's device name to send the message directly to that device, rather than all of the user's devices (multiple devices may be separated by a comma)
* **TITLE** &ndash; your message's title, otherwise your app's name is used
* **URL** &ndash; a supplementary URL to show with your message
* **URL_TITLE** &ndash; a title for your supplementary URL, otherwise just the URL is shown
* **PRIORITY** &ndash; # send as -2 to generate no notification/alert, -1 to always send as a quiet notification, 1 to display as high-priority and bypass the user's quiet hours, or 2 to also require confirmation from the user
* **SOUND** &ndash; # the name of one of the sounds supported by device clients to override the user's default sound choice
* **TIMESTAMP** &ndash; a Unix timestamp of your message's date and time to display to the user, rather than the time your message is received by our API
* **HTML** &ndash; enable HTML formatting (0|1)
* **MONOSPACE** &ndash; enable monospace formatting (0|1)

* **SEVERITY** &ndash; name of the event severity (convert to **PRIORITY**)<br/>
Convert severity name to priority. Add associative SEVERITY array (with yore local severity values) to ```/etc/zabbix/pushover.conf```<br/>
Sample:
```
declare -A SEVERITY
SEVERITY["Not classified"]=-2
SEVERITY["Information"]=-2
SEVERITY["Warning"]=-1
SEVERITY["Average"]=0
SEVERITY["High"]=1
SEVERITY["Disaster"]=2
``` 
* **NSEVERITY** &ndash; numeric value of the event severity (convert to **PRIORITY**)<br/>
Convert severity value to priority. Add indexed NSEVERITY array to ```/etc/zabbix/pushover.conf```<br/>
Sample:
```
declare -a NSEVERITY
NSEVERITY[0]=-2
NSEVERITY[1]=-2
NSEVERITY[2]=-1
NSEVERITY[3]=0
NSEVERITY[4]=1
NSEVERITY[5]=2
```
* **SEVERITY2S** &ndash; name of the event severity (convert to **SOUND**)
Convert severity name to sound name. Add associative SEVERITY2S array (with yore local severity values) to ```/etc/zabbix/pushover.conf```<br/>
Sample:
```
declare -A SEVERITY2S
SEVERITY2S["Not classified"]="none"
SEVERITY2S["Information"]="none"
SEVERITY2S["Warning"]="intermission"
SEVERITY2S["Average"]="default"
SEVERITY2S["High"]="siren"
SEVERITY2S["Disaster"]="alien"
```
* **NSEVERITY2S** &ndash; numeric value of the event severity (convert to **SOUND**)<br/>
Convert severity value to sound name. Add indexed NSEVERITY2S array to ```/etc/zabbix/pushover.conf```<br/>
Sample:
```
declare -a NSEVERITY2S
NSEVERITY2S[0]="none"
NSEVERITY2S[1]="none"
NSEVERITY2S[2]="intermission"
NSEVERITY2S[3]="default"
NSEVERITY2S[4]="siren"
NSEVERITY2S[5]="alien"
```
* **DATETIME** &ndash; datetime of event (convert to **TIMESTAMP**)
  - format: DDDD.MM.YY hh:mm:ss
  - format: DDDD/MM/YY hh:mm:ss

**Sound** parameter allowed values:

* **pushover** - Pushover (default)  
* **bike** - Bike  
* **bugle** - Bugle  
* **cashregister** - Cash Register  
* **classical** - Classical  
* **cosmic** - Cosmic  
* **falling** - Falling  
* **gamelan** - Gamelan  
* **incoming** - Incoming  
* **intermission** - Intermission  
* **magic** - Magic  
* **mechanical** - Mechanical  
* **pianobar** - Piano Bar  
* **siren** - Siren  
* **spacealarm** - Space Alarm  
* **tugboat** - Tug Boat  
* **alien** - Alien Alarm (long)  
* **climb** - Climb (long)  
* **persistent** - Persistent (long)  
* **echo** - Pushover Echo (long)  
* **updown** - Up Down (long)  
* **none** - None (silent) 

#### Message sample

```
pushover_zabbix.sh 'TSWYzLEVwBqye83kg6MrA08WiwQfv5@iPhone' \
"Problem: Unavailable by ICMP ping" \
"%PUSHOVER:HTML%0
%PUSHOVER:DATETIME%2019.06.24 16:14:50
%PUSHOVER:TITLE%Unavailable by ICMP ping
%PUSHOVER:SEVERITY%High
Problem started at 16:14:50 on 2019.06.24
Problem name: Unavailable by ICMP ping
Host: Astarta 00
Severity: High

%PUSHOVER:URL_TITLE%Original problem ID: 47921496
%PUSHOVER:URL%http://zabbix.local" \
'8Qf3IRcfyUmZgsGQsDvcJdRcjhOE6W'
```
    
## Zabbix  server configuration file

Parameter |	Mandatory |	Default |	Description
----------|-----------|---------|------------
AlertScriptsPath | no | `/usr/lib/zabbix/alertscripts` | Location of custom alert scripts<br/>(depends on compile-time installation variable datadir).
ExternalScripts | no | `/usr/lib/zabbix/externalscripts` | Location of external scripts<br/>(depends on compile-time installation variable datadir).
