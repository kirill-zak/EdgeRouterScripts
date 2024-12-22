# !/bin/vbash

#######################################
## Intial settings                   ##
#######################################

SCRIPT_DIR=`pwd`
CURL_URL='https://raw.githubusercontent.com/touhidurrr/iplist-youtube/main/cidr4.txt'
FIREWALL_RULE_NAME='Youtube'
FIREWALL_GROUP_DESCRIPTION='List of addresses'
YOUTUBE_IP_LIST='/tmp/youtube_ip.txt'

#######################################
## Get Youtube IP list               ##
#######################################

curl "$CURL_URL" -o "$YOUTUBE_IP_LIST"
if [ $? -ne 0 ]; then
    echo "Get Youtube IP list failed!" >&2
    exit 1
fi

## Check count of IPs in list
IP_COUNT=$(wc -l "$YOUTUBE_IP_LIST" | awk '{print $1}')

if [ "$IP_COUNT" -eq 0 ]; then
    echo "IP list is empty" >&2
    exit 1
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
## Process YouTube IP list           ##
#######################################

/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper begin

IP_ADDED=0

while read -r IP
do
    echo "Start to process IP [$IP]..." >&2
    if /opt/vyatta/sbin/vyatta-cfg-cmd-wrapper show firewall group address-group "$FIREWALL_RULE_NAME" address "$IP" | grep -q "empty" ; then
        echo "Try to add IP ["$IP"] into firewall group" >&2
        
        /opt/vyatta/sbin/vyatta-cfg-cmd-wrapper set firewall group address-group "$FIREWALL_RULE_NAME" address "$IP"
        ((IP_ADDED++))
    else
        echo "Address already in firewall group" >&2
    fi
    
done < "$YOUTUBE_IP_LIST"

echo "Added [$IP_ADDED] YouTube IPs" >&2

#######################################                                                                                                                         
## Save configuration                ##                                                                                                                         
#######################################

if [ "$IP_ADDED" -ne 0 ]; then
    echo "Save configuration" >&2
    /opt/vyatta/sbin/vyatta-cfg-cmd-wrapper commit
    /opt/vyatta/sbin/vyatta-cfg-cmd-wrapper save
fi