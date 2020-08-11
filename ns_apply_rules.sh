#!/bin/bash

USAGE="
Usage:
    
ns_apply_rules.sh <vim_num> <ns_name> 
    where:
        <vim_num>: number of the vim instance (1 or 2) 
        <ns_name>: name of the network service instance in OSM 
"

if [[ $# -ne 2 ]]; then
        echo ""       
    echo "ERROR: incorrect number of parameters"
    echo "$USAGE"
    exit 1
fi

DOCKPREFIX="mn.dc$1_$2"

NSNAME=$2
#VNFAXS="$DOCKPREFIX-1-access-1"
#VNFCPE="$DOCKPREFIX-2-cpe-1"
VNFWAN="$DOCKPREFIX-3-wan-1"

RYUIP=$(docker inspect --format='{{.Name}} {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $VNFWAN | awk '{print $2}')

echo "applying rules in $RYUIP"
curl -X POST -d @json/1to2.json http://$RYUIP:8080/stats/flowentry/add |jq 
curl -X POST -d @json/2to1.json http://$RYUIP:8080/stats/flowentry/add |jq 
curl -X POST -d @json/broadcastFrom1.json http://$RYUIP:8080/stats/flowentry/add |jq 
curl -X POST -d @json/from-voip-gw.json http://$RYUIP:8080/stats/flowentry/add |jq 
curl -X POST -d @json/to-voip-gw.json http://$RYUIP:8080/stats/flowentry/add |jq 
curl -X POST -d @json/$NSNAME/to-voip.json http://$RYUIP:8080/stats/flowentry/add |jq 
 
firefox http://$RYUIP:8080/home/
