#!/bin/bash

USAGE="
Usage:
    
ns_lan_route.sh <vim_num> <ns_name> <cus_corp_prefix>
    where:
        <vim_num>: number of the vim instance (1 or 2) 
        <ns_name>: name of the network service instance in OSM 
        <cus_corp_prefix>: ip prefix for the corporate lan network at this customer premises 
"

if [[ $# -ne 3 ]]; then
        echo ""       
    echo "ERROR: incorrect number of parameters"
    echo "$USAGE"
    exit 1
fi

DOCKPREFIX="mn.dc$1_$2"

VNFAXS="$DOCKPREFIX-1-access-1"
VNFCPE="$DOCKPREFIX-2-cpe-1"

CUSCORPREFIX="$3"

## 1. En VNF:cpe activar ruta hacia la red corporativa 
sudo docker exec -it $VNFCPE ip route add $CUSCORPREFIX via 192.168.255.253

