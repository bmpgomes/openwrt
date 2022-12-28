#!/bin/bash
# Script to enable/disable firewall rules by name

# Define here your Router's IP address
HOST="192.168.5.254"
set -x
### Functions
function ssh_command () {
    ssh -i /config/bash_scripts/openwrt -o StrictHostKeyChecking=no root@"$HOST" "$1"
}

function ping_router () {
  if ! ping -c 1 -W 1 "$HOST" &> /dev/null; then exit; fi
}

# Get rule number by name
function get_rule_number_by_name () {

    # Check if rule can be found
    ssh_command "uci show firewall | grep -E "$1" -m1 | awk -F'[^0-9]+' '{print \$2}'"
}

# Get firewall rule state
function get_rule_state () {

    RULE_NUMBER=$(get_rule_number_by_name $1)

    # Rule not found
    if [ -z "$RULE_NUMBER" ]; then
        exit 2;
    fi

    o=$(ssh_command 'uci get firewall.@rule['$RULE_NUMBER'].enabled')
    return_code=$?

    # Function was called but it didn't find the property enabled, which means that is enable
    if [[ ! return_code -eq 0 ]]; then
        return 1
    fi

    echo $o
}


# Set firewall rule
function set_rule_state () {

    RULE_NUMBER=$(get_rule_number_by_name $1)

    # Rule not found
    if [ -z "$RULE_NUMBER" ]; then
        exit 2;
    fi

    # Apply config
    ssh_command 'uci set firewall.@rule['$RULE_NUMBER'].enabled='$2' && uci commit && /etc/init.d/firewall reload > /dev/null 2>&1'
}


if [[ "$1" == "get_rule_state" ]]; then

    # Check the number of parameters
    if [ ! $# -eq 2 ]; then
        exit 2;
    fi

    # Check if Rule Name parameter is not empty
    if [ -z "$2" ]; then
        exit 2;
    fi

    # Check if router is on
    ping_router

    # Check if rule is enabled
    get_rule_state $2

    exit;
fi

if [[ "$1" == "set_rule_state" ]]; then

    # Check the number of parameters
    if [ ! $# -eq 3 ]; then
        exit 2;
    fi

    # Check if Rule Name parameter is not empty
    if [ -z "$2" ]; then
        exit 2;
    fi

    # Check if Enable parameter is either 0 or 1
    if [ -z "$3" ]; then
        exit 2;
    fi

    # Var not valid
    if [ "$3" != "0" ] && [ "$3" != "1" ]; then
        exit 2;
    fi

    # Check if router is on
    ping_router

    # Set rule enable value
    set_rule_state $2 $3

  exit;
fi