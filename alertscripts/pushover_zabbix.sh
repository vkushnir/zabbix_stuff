#!/bin/bash

declare -A PFIELDS

# TODO: Receipts and Callbacks API

# Other Variables
CURL="$(which curl)"
CURL_OPTS=""
PUSHOVER_URL="https://api.pushover.net/1/messages.json"

# Functions
validate_token() {
    local field=$1
    local value=$2
    local ret=1
    if [[ -z "${value}" ]]; then
        echo "${field} is unset or empty: Did you specify ${field} on the command line?" >&2
    elif ! echo "${value}" | egrep -q '[A-Za-z0-9]{30}'; then
        echo "Value of ${field}, \"${value}\", does not match expected format. Should be 30 characters of A-Z, a-z and 0-9." >&2;
    else
        ret=0
    fi
    return ${ret}
}

opt_field() {
    local field=$1
    shift
    local value="$*"
    if [[ ! -z "${value}" ]]; then
        echo "-F \"${field}=${value}\""
    fi
}

msg_field() {
    local field=$1
    shift
    local value="$*"
    case ${field} in
        "SEVERITY")     PFIELDS["PRIORITY"]=${SEVERITY["${value}"]} ;;
        "SEVERITY2S")   PFIELDS["SOUND"]=${SEVERITY2S["${value}"]} ;;
        "NSEVERITY")    PFIELDS["PRIORITY"]=${NSEVERITY[${value}]} ;;
        "NSEVERITY2S")  PFIELDS["SOUND"]=${NSEVERITY2S[${value}]} ;;
        "DATETIME")     PFIELDS["TIMESTAMP"]=$(date -d "${value//.//}" '+%s') ;;

        "TOKEN")        PFIELDS["TOKEN"]=${value};
                        validate_token "TOKEN" "${value}" || exit $? ;;
        "USER")         PFIELDS["USER"]=${value}
                        validate_token "USER" "${value}" || exit $? ;;
        *)              PFIELDS[$field]=${value} ;;
    esac
}

send_message() {
    curl_cmd="\"${CURL}\" -s -S ${CURL_OPTS} "

    for field in "${!PFIELDS[@]}"; do
        curl_cmd+="-F \"${field,,}=${PFIELDS[${field}]}\" "
     done
    curl_cmd+="-F \"message=${PMESSAGE}\" \"${PUSHOVER_URL}\""

    # execute and return exit code from curl command
    response="$(eval "${curl_cmd}")"
    # TODO: Parse response for value of status to give better error to user
    r=$?
    if [[ "${r}" -ne 0 ]]; then
        echo "${0}: Failed to send message" >&2
    fi

    return "${r}"
}

# MAIN

# Load vlaues from config file
if [[ -f /etc/zabbix/pushover.conf ]]; then
    . /etc/zabbix/pushover.conf
fi

# Parce CMD recipient
if [[ $# -ge 4 ]]; then
    PFIELDS['TOKEN']=$4
fi
RCPT=$1
PFIELDS['USER']=${RCPT%@*}
if [[ ${#RCPT} -gt ${#PFIELDS['USER']} ]] ; then
        RCPT=${RCPT#*@}
        PFIELDS['DEVICE']=${RCPT%:*}
        if [[ ${#RCPT} -gt ${#PFIELDS['DEVICE']} ]]; then
                PFIELDS['TOKEN']=${RCPT#*:}
        fi
fi
PFIELDS["TITLE"]=$2
# Zabbix use \r fix this
MESSAGE=${3//$'\015'}

# Cut pushover rows from Message
POPTS=$(echo "${MESSAGE}" | grep -i %PUSHOVER:)
PMESSAGE=$(echo "${MESSAGE}" | grep -iv %PUSHOVER:)

OLDIFS=$IFS
IFS=$'\n'
for PL in ${POPTS}
do
    OPT=$(echo ${PL} | cut -f2 -d'%' | cut -f2 -d':')
    VAL=$(echo ${PL} | cut -f3 -d'%')
    msg_field "$OPT" "$VAL"
done
IFS=${OLDIFS}

send_message
