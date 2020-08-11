#!/bin/bash

USAGE="
Usage:
    
ns_sdwan <vim_num> <ns_name> <remote_site_ip>
    where:
        <vim_num>: number of the vim instance (1 or 2) 
        <ns_name>: name of the network service instance in OSM 
        <remote_site_ip>: ip of the remote site for sd-wan tunnel
"

if [[ $# -ne 3 ]]; then
        echo ""       
    echo "ERROR: incorrect number of parameters"
    echo "$USAGE"
    exit 1
fi

DOCKPREFIX="mn.dc$1_$2"

#VNFAXS="$DOCKPREFIX-1-access-1"
VNFCPE="$DOCKPREFIX-2-cpe-1"
#VNFWAN="$DOCKPREFIX-3-wan-1"

REMOTESITE="$3"

## 1. Crea un tunel hacia otra sede 
sudo docker exec -it $VNFCPE ovs-vsctl add-port brwan vxlan1 -- set interface vxlan1 type=vxlan options:remote_ip=$REMOTESITE

## 2. Aplica las reglas de la sdwan con ryu
./ns_apply_rules.sh $1 $2

