#!/bin/vbash

#######################################
## Intial settings                   ##
#######################################

SCRIPT_DIR=`pwd`
FIREWALL_RULE_NAME='UnblockByVpn'
FIREWALL_GROUP_DESCRIPTION='List of addresses for unblock via VPN'
DOMAINS_PATH="$SCRIPT_DIR/domains.conf"

#######################################
## Check and read configuration file ##
#######################################

## Check domain configuration file
if [ ! -f "$DOMAINS_PATH" ]; then
    echo "Domains file is not exit!" >&2
    exit 1
fi


## Check count of domains in list
DOMAINS_COUNT=$(wc -l "$DOMAINS_PATH" | awk '{print $1}')

if [ "$DOMAINS_COUNT" -eq 0 ]; then
    echo "Domains list is empty" >&2
    exit 0
fi

#######################################
## Check firewall group              ##
#######################################

CHECK_GROUP_RESULT=$(/opt/vyatta/bin/vyatta-op-cmd-wrapper show firewall group "$FIREWALL_RULE_NAME")
GROUP_NOT_EXIST_MESSAGE="Group [$FIREWALL_RULE_NAME] has not been defined"

if [ "$CHECK_GROUP_RESULT" == "$GROUP_NOT_EXIST_MESSAGE" ]; then
    echo "Group not exist. Try to create group" >&2

    /opt/vyatta/sbin/vyatta-cfg-cmd-wrapper begin
    ADD_GROUP_RESULT=$(/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper set firewall group address-group "$FIREWALL_RULE_NAME" description "$FIREWALL_GROUP_DESCRIPTION")
    /opt/vyatta/sbin/vyatta-cfg-cmd-wrapper commit
    
    if [ $? -ne 0 ]; then
        echo "Create firewall group [$FIREWALL_RULE_NAME] failed" >&2
        exit 1
    else
        echo "Firewall group [$FIREWALL_RULE_NAME] was created successfully" >&2
    fi
    
fi

#######################################
## Process domains                   ##
#######################################

/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper begin

ADDED_ADDRESS=0

while read -r DOMAIN
do
    echo "Start to process domain [$DOMAIN]..." >&2
    
    DOMAIN_IPS="$(host -t a "$DOMAIN" | awk '{print $4}' | egrep ^[1-9] | awk -F. '{print $1"."$2"."$3".0/24"}' | sort | uniq)"
    
    for IP in ${DOMAIN_IPS}
    do
        if /opt/vyatta/sbin/vyatta-cfg-cmd-wrapper show firewall group address-group "$FIREWALL_RULE_NAME" address "$IP" | grep -q "empty" ; then
            echo "Try to add address ["$IP"] into firewall group" >&2
            
            /opt/vyatta/sbin/vyatta-cfg-cmd-wrapper set firewall group address-group "$FIREWALL_RULE_NAME" address "$IP"
            ((ADDED_ADDRESS++))
        else
            echo "Address already in firewall group" >&2
        fi
         
    done
    
done < "$DOMAINS_PATH"

echo "Added [$ADDED_ADDRESS] address" >&2

#######################################                                                                                                                         
## Save configuration                ##                                                                                                                         
#######################################

if [ "$ADDED_ADDRESS" -ne 0 ]; then
    echo "Save configuration" >&2
    /opt/vyatta/sbin/vyatta-cfg-cmd-wrapper commit
    /opt/vyatta/sbin/vyatta-cfg-cmd-wrapper save
fi
